-- Events base

CreateConVar("gm13_tier", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED })

-- In singleplayer the client starts fast enough to get only part of the entities, so
-- I manually block sending them and let him request the full list when he's done.
local blockSendFirstEntities = true
timer.Simple(2, function()
    blockSendFirstEntities = false
end)

-- After a cleanup
hook.Add("PostCleanupMap", "gm13_reload_map_sh", function()
    GM13.Event:ReloadCurrent()
end)

-- Return the rendering info table from an entity
function GM13.Event:GetEntityRenderInfo(ent)
    return {
        class = ent:GetClass() or "",
        eventName = ent:GetVar("eventName"),
        entName = ent:GetVar("entName"),
        entID = tostring(ent),
        vecA = ent:GetVar("vecA"),
        vecB = ent:GetVar("vecB"),
        vecCenter = ent:GetVar("vecCenter"),
        color = ent:GetVar("color"),
        vecConnection = ent:GetVar("vecConnection")
    }
end

-- Get events list
function GM13.Event:GetList()
    return GM13.Event.list
end

-- Check for an event entity
function GM13.Event:IsGameEntity(ent)
    for eventName, entList in pairs(self.gameEntityList) do
        if entList[ent] then
            return eventName
        end
    end
end

-- Set any event entity
function GM13.Event:SetGameEntity(eventName, ent)
    self.gameEntityList[eventName] = self.gameEntityList[eventName] or {}
    self.gameEntityList[eventName][ent] = true
end

-- Remove any event entity
function GM13.Event:RemoveGameEntity(eventName, ent)
    if self.gameEntityList[eventName] then
        self.gameEntityList[eventName][ent] = nil
    end
end

-- Set a custom event entity which can have the area rendered on the clientside
function GM13.Event:SetRenderInfoEntity(ent)
    -- Register entity rendering information
    timer.Simple(0.1, function() -- Wait to get valid entity keys/values
        if not ent:IsValid() then return end

        local entRenderInfo = self:GetEntityRenderInfo(ent)
        local eventName = entRenderInfo.eventName

        if not eventName then return end
        -- This check isn't true normally, only when someone wants to force spawn an object, as some of the external bases have done.
        -- However I believe that saves and duplications can also cause problems with unloaded events.

        self.customEntityList[eventName] = self.customEntityList[eventName] or {}
        self.customEntityList[eventName][ent] = entRenderInfo

        -- Send entRenderInfo to render
        if not GM13.devMode then return end

        if SERVER then
            if blockSendFirstEntities then return end

            net.Start("gm13_event_set_render_cl")
                net.WriteTable(entRenderInfo)
            net.Broadcast()
        else
            self:Render(entRenderInfo)
        end
    end)
end

-- Remove a custom event entity
function GM13.Event:RemoveRenderInfoEntity(ent)
    if not ent:IsValid() then return end

    local entRenderInfo = self:GetEntityRenderInfo(ent)

    if not entRenderInfo then return end

    timer.Simple(0.2, function() -- Wait to be sure that self.customEntityList is initialized
        local eventName = entRenderInfo.eventName

        if not eventName then return end

        if self.customEntityList[eventName] then
            self.customEntityList[eventName][ent] = nil
        end

        if not GM13.devMode or not SERVER then return end

        local entID = entRenderInfo.entID

        net.Start("gm13_event_remove_render_cl")
            net.WriteString(eventName)
            net.WriteString(entID)
        net.Broadcast()
    end)
end

-- Check if a event is enabled
function GM13.Event:IsEnabled(eventName)
    return self.list[eventName] and self.list[eventName].enabled or false
end

-- Remove all entities from the table and the map
function GM13.Event:RemoveAll()
    local function dissolveEnts(list)
        for eventName, entList in pairs(list) do
            for ent, _ in pairs(entList) do
                if ent:IsValid() then
                    if not GM13.Ent:Dissolve(ent) then
                        ent:Remove()
                    end
                end
            end
        end
    end

    dissolveEnts(self.customEntityList)
    dissolveEnts(self.gameEntityList)

    for k, eventName in ipairs(self.loadingOrder) do
        if self.list[eventName].enabled and self.list[eventName].disableFunc then
            self.list[eventName].disableFunc()
        end
    end

    self.customEntityList = {}
    self.gameEntityList = {}
    self.loadingOrder = {}
    self.list = {}

    if SERVER then
        net.Start("gm13_event_remove_all_cl")
        net.Broadcast()
    end
end

-- Remove event entities from the table and the map
function GM13.Event:Remove(eventNameOut)
    local function removeEventEntities(eventName, list)
        if not list[eventName] then return end

        for ent, _ in pairs(list[eventName]) do
            if ent:IsValid() then
                if not GM13.Ent:Dissolve(ent) then
                    ent:Remove()
                end
            end
        end

        list[eventName] = nil
    end

    local hasEntities = false

    if self.customEntityList[eventNameOut] then
        removeEventEntities(eventNameOut, self.customEntityList)
        hasEntities = true
    end

    if self.gameEntityList[eventNameOut] then
        removeEventEntities(eventNameOut, self.gameEntityList)
        hasEntities = true
    end

    if self.list[eventNameOut] then
        if self.list[eventNameOut].disableFunc then
            self.list[eventNameOut].disableFunc()
        end

        self.list[eventNameOut].enabled = false
    end

    hook.Run("gm13_remove_" .. eventNameOut)

    if SERVER and hasEntities then
        net.Start("gm13_event_remove_cl")
            net.WriteString(eventNameOut)
        net.Broadcast()
    end
end

-- Run an event
function GM13.Event:Run(eventName)
    local failFunc = self.list[eventName].failFunc

    -- Check if the required memories are loaded
    if not GM13.Event.Memory.Dependency:Check(eventName) then
        return failFunc and failFunc()
    end

    -- Check if there are incompatible memories loaded
    if GM13.Event.Memory.Incompatibility:Check(eventName) then
        return failFunc and failFunc()
    end

    -- Initialize
    if self.list[eventName] then
        if self.list[eventName].func() then
            self.list[eventName].enabled = true
        end

        -- Call hook
        timer.Simple(0.4, function() -- Load everything before calling hooks!
            hook.Run("gm13_run_" .. eventName)
        end)
    end
end

-- Set event initialization
function GM13.Event:SetCall(eventNameIn, initFunc)
    local isEnabled

    if self.list[eventNameIn] then
        local index = table.KeyFromValue(self.loadingOrder, eventNameIn)
        isEnabled = self.list[eventNameIn].enabled

        self.loadingOrder[index] = eventNameIn
    else
        isEnabled = false

        table.insert(self.loadingOrder, eventNameIn)
    end

    hook.Run("gm13_add_" .. eventNameIn)
    self.list[eventNameIn] = { func = initFunc, enabled = isEnabled }
end

-- Set event initialization fail callback
function GM13.Event:SetFailCall(eventNameIn, callback)
    if self.list[eventNameIn] then
        self.list[eventNameIn].failFunc = callback
    end
end

-- Set event disabling callback
function GM13.Event:SetDisableCall(eventNameIn, callback)
    if self.list[eventNameIn] then
        self.list[eventNameIn].disableFunc = callback
    end
end

-- Get the max tier players can enable
function GM13.Event:GetMaxPossibleTier()
    local maxTier = 1

    if GM13.Event.Memory:Get("MeatyFight") then
        maxTier = maxTier + 1
        if GM13.Event.Memory:Get("INeedFight") then
            maxTier = maxTier + 1
        end
    end

    return maxTier
end

-- Load event tiers
function GM13.Event:InitializeTier()
    local maxTier = GM13.Event:GetMaxPossibleTier()
    local tier = GetConVar("gm13_tier"):GetInt()

    -- Force players to roll back to the higher valid tier
    if not GM13.devMode and tier > maxTier then
        GetConVar("gm13_tier"):SetInt(maxTier)
        return
    end

    -- Clear any loaded events
    self:RemoveAll()

    -- Include all events
    for i=1, tier do
    	for k, base in ipairs(GM13.bases) do
            local tierFolder = base .. "/events/tier" .. i .. "/"

            GM13:IncludeFiles(tierFolder, i == tier)
        end
    end

    -- Load events
    for k, eventName in ipairs(self.loadingOrder) do
        self:Run(eventName)
    end

    if SERVER then
        net.Start("gm13_event_initialize_tier_cl")
        net.Broadcast()
    end
end

-- Reload the already loaded events
function GM13.Event:ReloadCurrent()
    if SERVER and GM13.devMode then
        for eventName, ent in pairs(GM13.Event.customEntityList) do
            GM13.Event.customEntityList[eventName] = {}
        end

        for eventName, ent in pairs(GM13.Event.gameEntityList) do
            GM13.Event.gameEntityList[eventName] = {}
        end
    end

    for k, eventName in ipairs(self.loadingOrder) do
        if GM13.Event:IsEnabled(eventName) then
            GM13.Event:Run(eventName)
        end
    end

    if SERVER and GM13.devMode then
        net.Start("gm13_event_remove_all_ents_cl")
        net.Broadcast()

        timer.Simple(1, function()
            GM13.Event:SendCustomEnts(ply)
        end)
    end
end

-- Reload events according to the logic of memory dependencies and incompatibilities
-- Note: this system is automatic and for it to work it's necessary to make all events assume the
-- correct state, so everything that was manually toggled will be automatically restaured here.
function GM13.Event:ReloadByMemory()
    local crossedEvents = GM13.Event.Memory.Dependency:GetDependentEventsState()
    local memories = GM13.Event.Memory:GetList()
    local block = {}

    -- Remove or block events that now are incompatible due to new memories
    for k, eventName in ipairs(self.loadingOrder) do
        local incompatTab = GM13.Event.Memory.Incompatibility:Get(eventName)

        for memoryName, _ in pairs(incompatTab or {}) do
            if memories[memoryName] then
                if self:IsEnabled(eventName) then
                    self:Remove(eventName)
                    block[eventName] = true
                end

                break
            end
        end
    end

    -- Disable events that don't meet their dependencies anymore
    for _, eventName in ipairs(crossedEvents.disabled) do
        if self:IsEnabled(eventName) then
            self:Remove(eventName)
        end
    end

    -- Activate compatible events that now meet their dependencies but are disabled
    for _, eventName in ipairs(crossedEvents.enabled) do
        if not block[eventName] and not self:IsEnabled(eventName) then
            self:Run(eventName)
        end
    end

    -- Activate events that have no reason to be disabled
    for k, eventName in ipairs(self.loadingOrder) do
        if not self:IsEnabled(eventName) and not block[eventName] then
            self:Run(eventName)
        end
    end
end

-- Toggle events
-- Warning! Toogle "disabled" is a broken operation! Since we have memory dependencies and incompatibilities,
-- it's common that we can't activate all events at once. This option is here only because it's still useful
-- to make things faster, then use it knowing it.
function GM13.Event:Toggle(ply, cmd, args)
    local eventNameIn = args[1]

    if not eventNameIn then return end
    if not self.list[eventNameIn] and not (eventNameIn == "enabled" or eventNameIn == "disabled") then return end

    local function toggle(state, eventName)
        local memories = GM13.Event.Memory.Dependency:GetProviders()[eventName] or {}

        for memoryName, _ in pairs(memories) do
            GM13.Event.Memory:Toggle(ply, cmd, { memoryName }, true)
        end

        if state then
            self:Remove(eventName)
        else
            self:Run(eventName)
        end
    end

    if eventNameIn == "enabled" or eventNameIn == "disabled" then
        local state = eventNameIn == "enabled"

        for k, eventName in ipairs(self.loadingOrder) do
            if self:IsEnabled(eventName) == state then
                toggle(state, eventName)
            end
        end

        print("Done")
        return
    end

    if self.list[eventNameIn] then
        print(eventNameIn .. " = " .. tostring(not self:IsEnabled(eventNameIn)))
        toggle(self:IsEnabled(eventNameIn), eventNameIn)
    end
end

-- List events
function GM13.Event:List()
    local enabled, disabled = {}, {}

    for k, eventName in ipairs(self.loadingOrder) do
        if self:IsEnabled(eventName) then
            table.insert(enabled, eventName)
        else
            table.insert(disabled, eventName)
        end
    end

    print([[Options:
  enabled
  disabled]])

    if #enabled > 0 then
        print("\nEnabled:")
        for k, eventName in SortedPairs(enabled) do
            print("  " .. eventName)
        end
    end

    if #disabled > 0 then
        print("\nDisabled:")
        for k, eventName in SortedPairs(disabled) do
            print("  " .. eventName)
        end
    end
end
