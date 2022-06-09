-- Events base

local wireframe = Material("models/wireframe")

surface.CreateFont("GM13EntName", {
    font = "TargetID",
    size = 20,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    shadow = true,
})

surface.CreateFont("GM13EventName", {
    font = "TargetID",
    size = 24,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    shadow = true,
})

-- Load event tiers by server order
net.Receive("gm13_event_initialize_tier_cl", function()
    GM13.Event:InitializeTier()
end)

-- Remove events by server order
net.Receive("gm13_event_remove_all_cl", function()
    GM13.Event:RemoveAll()

    if GM13.devMode then
        GM13.Event.renderEvent = {}
    end
end)

net.Receive("gm13_event_remove_all_ents_cl", function()
    if GM13.devMode then
        GM13.Event.renderEvent = {}
    end
end)

-- Remove an event by server order
net.Receive("gm13_event_remove_cl", function()
    local eventName = net.ReadString()

    GM13.Event:Remove(eventName)

    if GM13.devMode then
        GM13.Event.renderEvent[eventName] = nil
    end
end)

-- Receive entity rendering info
net.Receive("gm13_event_set_render_cl", function()
    GM13.Event:Render(net.ReadTable())
end)

-- Remove an event entity by server order
net.Receive("gm13_event_Remove_render_cl", function()
    local eventName = net.ReadString()
    local entID = net.ReadString()

    if GM13.devMode and GM13.Event.renderEvent[eventName] then
        GM13.Event.renderEvent[eventName][entID] = nil
    end
end)

-- Receive all events
local receivedTab = {}
net.Receive("gm13_event_send_all_render_cl", function()
    local currentChuncksID = net.ReadString()
    local len = net.ReadUInt(16)
    local chunk = net.ReadData(len)
    local lastPart = net.ReadBool()

    if not receivedTab[currentChuncksID] then
        receivedTab = {}
        receivedTab[currentChuncksID] = ""
    end

    receivedTab[currentChuncksID] = receivedTab[currentChuncksID] .. chunk

    if lastPart then
        local eventEntTab = util.JSONToTable(util.Decompress(receivedTab[currentChuncksID]))

        receivedTab = {}

        if eventEntTab and istable(eventEntTab) then
            for k,eventEntInfo in ipairs(eventEntTab) do
                GM13.Event:Render(eventEntInfo)
            end
        end
	end
end)

-- Event rendering
function GM13.Event:Render(entRenderInfo)
    if not GM13.devMode then return end

    -- Render event name
    if self.renderEvent[entRenderInfo.eventName] == nil then
        self.renderEvent[entRenderInfo.eventName] = { enabled = false }

        hook.Add("HUDPaint", entRenderInfo.eventName, function()
            if self.renderEvent[entRenderInfo.eventName] == nil then
                hook.Remove("HUDPaint", entRenderInfo.eventName)
                return
            end

            if not GetConVar("gm13_events_show_names"):GetBool() then return end

            local drawposscreen = entRenderInfo.vecCenter:ToScreen()

            draw.DrawText(entRenderInfo.eventName, "GM13EventName", drawposscreen.x, drawposscreen.y - 25, color_white, TEXT_ALIGN_CENTER)
        end)
    end

    -- Current event entity
    self.renderEvent[entRenderInfo.eventName][entRenderInfo.entID] = entRenderInfo

    -- Render event entity locator
    hook.Add("PostDrawTranslucentRenderables", entRenderInfo.entName, function()
        if self.renderEvent[entRenderInfo.eventName] == nil or not self.renderEvent[entRenderInfo.eventName][entRenderInfo.entID] then
            hook.Remove("PostDrawTranslucentRenderables", entRenderInfo.entName)
            return
        end

        if not self.renderEvent[entRenderInfo.eventName].enabled then return end

        render.SetMaterial(wireframe)

        if entRenderInfo.vecA and entRenderInfo.vecB and entRenderInfo.color then
            render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), entRenderInfo.vecA, entRenderInfo.vecB, entRenderInfo.color, true)
        end

        if entRenderInfo.vecCenter and entRenderInfo.vecConnection then
            render.DrawBeam(entRenderInfo.vecCenter, entRenderInfo.vecConnection, 1, 1, 1, { entRenderInfo.color })
        end
    end)

    -- Render event entity name
    hook.Add("HUDPaint", entRenderInfo.entName, function()
        if self.renderEvent[entRenderInfo.eventName] == nil or not self.renderEvent[entRenderInfo.eventName][entRenderInfo.entID] then
            hook.Remove("HUDPaint", entRenderInfo.entName)
            return
        end

        if not self.renderEvent[entRenderInfo.eventName].enabled then return end

        local distance = LocalPlayer():GetPos():Distance(entRenderInfo.vecCenter)

        if distance > 1000 then return end

        local up = Vector(0, 0, 1 * distance/1000)
        local drawposscreen = (entRenderInfo.vecCenter + up):ToScreen()

        draw.DrawText(entRenderInfo.entName, "GM13EntName", drawposscreen.x, drawposscreen.y, entRenderInfo.color, TEXT_ALIGN_CENTER)
    end)

    if GetConVar("gm13_events_render_auto"):GetBool() then
        self.renderEvent[entRenderInfo.eventName].enabled = true
    end
end

-- Toggle rendering from console
function GM13.Event:ToggleRender(ply, cmd, args)
    local eventNameIn = args[1]

    if not eventNameIn then return end

    if eventNameIn == "all" then
        for eventName, eventTab in pairs(self.renderEvent) do
            if not eventTab.enabled then
                eventTab.enabled = true
            end
        end

        print("Done")
        return
    elseif eventNameIn == "none" then
        for eventName, eventTab in pairs(self.renderEvent) do
            if eventTab.enabled then
                eventTab.enabled = false
            end
        end

        print("Done")
        return
    elseif eventNameIn == "invert" then
        for eventName, eventTab in pairs(self.renderEvent) do
            eventTab.enabled = not eventTab.enabled
        end

        print("Done")
        return
    end

    if self.renderEvent[eventNameIn] ~= nil then
        self.renderEvent[eventNameIn].enabled = not self.renderEvent[eventNameIn].enabled
        print(eventNameIn .. " = " .. tostring(self.renderEvent[eventNameIn].enabled))
    end
end

-- List information about event rendering
function GM13.Event:ListRender()
    print([[Options:
  all
  invert
  none

Events:]])

    for k,v in SortedPairs(self.renderEvent) do
        print("  " .. k, (v and "(Rendered)" or ""))
    end
end
