-- Duplicates the entities and contraptions making them persistent in relation to the trigger area

-- I avoided the default sandbox persistence system because it has no support across
-- maps (obviously) and is extremely annoying to manipulate.
--   - Xala

ENT.Base = "base_entity"
ENT.Type = "brush"

local dumpInfoToTxtFile = false

local isCleaningMap = false
hook.Add("PreCleanupMap", "gm13_protect_persistent_props", function()
    isCleaningMap = true

    timer.Create("gm13_protect_persistent_props", 0.2, 1, function()
        isCleaningMap = false
    end)
end)

function ENT:Initialize()
    GM13.Event:SetRenderInfoEntity(self)
end

function ENT:Setup(eventName, entName, vecA, vecB, protectConstruction)
    self:Spawn()

    local vecCenter = (vecA - vecB)/2 + vecB

    self:SetVar("eventName", eventName)
    self:SetVar("entName", entName)
    self:SetVar("vecA", vecA)
    self:SetVar("vecB", vecB)
    self:SetVar("vecCenter", vecCenter)
    self:SetVar("color", Color(252, 119, 3, 255)) -- Orange

    self:SetVar("protectConstruction", protectConstruction)

    self:SetName(entName)
    self:SetPos(vecCenter)

    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBoundsWS(vecA, vecB)
    self:SetTrigger(true)

    GM13.Ent:SetCursed(self, true)

    local persistentFolder = GM13.bases[1] .. "/persistent"
    file.CreateDir(persistentFolder)

    self.persistentFile = persistentFolder .. "/" .. entName .. ".dat"
    self.persistentFileDump = persistentFolder .. "/" .. entName .. ".txt"
    self.duplications = self:ReadFile() or {}

    self:SpawnSavedEnts()

    local canToolHookName = "gm13_check_persistence_tool_" .. tostring(self)
    hook.Add("CanTool", canToolHookName, function(ply, tr, toolname)
        if not self:IsValid() then
            hook.Remove("CanTool", canToolHookName)
            return
        end

        local ent = tr.Entity
        if ent:IsValid() and self.duplications[tostring(ent)] and (ent.gm13_duplicated or ent.gm13_constraint) then
            if toolname == "remover" then
                self:UnsaveEnt(ent)
            else
                timer.Simple(0.15, function()
                    if not self:IsValid() then return end

                    self:RefreshSavedEnts()
                end)
            end
        end
    end)

    local physgunFreezeHookName = "gm13_check_persistence_tool_" .. tostring(self)
    hook.Add("OnPhysgunFreeze", physgunFreezeHookName, function(weapon, phys, ent, ply)
        if not self:IsValid() then
            hook.Remove("OnPhysgunFreeze", physgunFreezeHookName)
            return
        end

        if ent:IsValid() and self.duplications[tostring(ent)] and ent.gm13_duplicated then
            self:SaveEnt(ent)
        end
    end)
end

function ENT:ModifyEntAndConstrainedEnts(ent)
    if not ent.gm13_constraint then
        ent.gm13_duplicated = true
    end

    local constrainedEntities = constraint.GetAllConstrainedEntities(ent) or {}
    for _, constrainedEnt in pairs(constrainedEntities) do
        if not constrainedEnt.gm13_duplicated then
            constrainedEnt.gm13_constraint = true
        end
    end
end

function ENT:ReadFile(ent)
    local compressedDupJson = file.Read(self.persistentFile, "Data")

    if compressedDupJson then
        local dupJson = util.Decompress(compressedDupJson)
        local dupTab = util.JSONToTable(dupJson)
        return dupTab
    else
        return {}
    end
end

function ENT:SaveFile(ent)
    timer.Create("gm13_set_persistence", 1, 1, function() -- This timer cause the list to be saved only when entities are stationary
        if not self:IsValid() then return end

        local dupJson = util.TableToJSON(self.duplications)
        local conpressedDupJson = util.Compress(dupJson)
        file.Write(self.persistentFile, conpressedDupJson)

        if dumpInfoToTxtFile then
            file.Write(self.persistentFileDump, dupJson)
        end
    end)
end

function ENT:SaveEnt(ent)
    if not IsValid(ent) or not ent:IsValid() or not ent.gm13_duplicated then return end

    self.duplications[tostring(ent)] = duplicator.Copy(ent)
    self:SaveFile()
end

function ENT:UnsaveEnt(ent) -- lol
    if not ent.gm13_duplicated then return end

    if ent.gm13_on_angle_change_id then
        ent:RemoveCallback("OnAngleChange", ent.gm13_on_angle_change_id)
    end

    ent:RemoveCallOnRemove("gm13_remove_persistence")

    self.duplications[tostring(ent)] = nil
    self:SaveFile()

    local constrainedEntities = constraint.GetAllConstrainedEntities(ent) or {}
    for _, constrainedEnt in pairs(constrainedEntities) do
        if not constrainedEnt.gm13_duplicated then
            constrainedEnt.gm13_constraint = nil
        end
    end

    ent.gm13_duplicated = nil
end

function ENT:SpawnSavedEnts()
    local ply = player.GetHumans()[1]

    local duplications = table.Copy(self.duplications)
    self.duplications = {}

    local unfrozenEntsPhys = {}
    local NPCs = {}

    local delay = 0
    local delayIncrement = 0.1
    for entStr, entDuplication in pairs(duplications) do
        local isNPC = false

        for _, entInfo in pairs(entDuplication.Entities) do
            if entInfo.gm13_is_npc then
                table.insert(NPCs, entInfo)
                isNPC = true
            end
            break    
        end

        if isNPC then continue end

        timer.Simple(delay, function()
            if not self:IsValid() then return end

            local createdEnts = duplicator.Paste(ply, entDuplication.Entities, entDuplication.Constraints)

            for _, createdEnt in pairs(createdEnts) do
                GM13.Ent:SetSpawnedByPlayer(createdEnt, true)

                local physObj = createdEnt:GetPhysicsObject()

                if physObj:IsValid() and physObj:IsMotionEnabled() then
                    physObj:EnableMotion(false)
                    table.insert(unfrozenEntsPhys, physObj)
                end

                if self:GetVar("protectConstruction") then
                    local model = createdEnt:GetModel()

                    if string.find(model, "models/props_phx") or 
                       string.find(model, "models/hunter") or
                       string.find(model, "models/squad") 
                        then

                        GM13.Ent:BlockPhysgun(createdEnt, true)
                        GM13.Ent:BlockToolgun(createdEnt, true)
                        GM13.Ent:BlockContextMenu(createdEnt, true)
                    end
                end
            end
        end)

        delay = delay + delayIncrement
    end

    timer.Simple(delay, function()
        if not self:IsValid() then return end

        delay = 0

        for k, entInfo in ipairs(NPCs) do
            timer.Simple(delay, function()
                local createdNPCs = duplicator.Paste(ply, { entInfo }, {})

                for _, createdNPC in ipairs(createdNPCs) do
                    GM13.Ent:SetSpawnedByPlayer(createdNPC, true)
                    self:StartTouch(createdNPC)
                end
            end)

            delay = delay + delayIncrement
        end
    end)

    local restoreMotionDelay = table.Count(duplications) * delayIncrement
    timer.Simple(restoreMotionDelay, function()
        if not self:IsValid() then return end

        for _, physObj in ipairs(unfrozenEntsPhys) do
            if physObj:IsValid() then
                physObj:EnableMotion(true)
            end
        end
    end)
end

function ENT:RefreshSavedEnts()
    self.duplications = {}

    local foundEnts = ents.FindInBox(self:GetVar("vecA"), self:GetVar("vecB"))

    for k, ent in ipairs(foundEnts) do
        ent.gm13_duplicated = nil
        ent.gm13_constraint = nil
    end

    for k, ent in ipairs(foundEnts) do
        if GM13.Ent:IsSpawnedByPlayer(ent) then
            if not ent.gm13_constraint then
                self:ModifyEntAndConstrainedEnts(ent)
                self.duplications[tostring(ent)] = duplicator.Copy(ent)
            end
        end
    end

    self:SaveFile()
end

function ENT:StartTouch(ent)
    if not GM13.Ent:IsSpawnedByPlayer(ent) or ent.gm13_duplicated or ent.gm13_constraint then return end

    ent:CallOnRemove("gm13_remove_persistence", function()
        if self:IsValid() and not isCleaningMap then
            self:UnsaveEnt(ent)
        end
    end)

    ent.gm13_on_angle_change_id = ent:AddCallback("OnAngleChange", function()
        if not ent:IsValid() then return end

        timer.Create(tostring(ent), 0.15, 1, function()
            if not self:IsValid() then return end
    
            if ent:IsValid() and ent.gm13_duplicated then
                self:SaveEnt(ent)
            end
        end)
    end)

    timer.Simple(0.16, function()
        if not self:IsValid() then return end

        self:ModifyEntAndConstrainedEnts(ent)
        GM13.Event:SetGameEntity(self:GetVar("eventName"), ent)
        self:SaveEnt(ent)
    end)
end

function ENT:EndTouch(ent)
    self:UnsaveEnt(ent)
    GM13.Event:RemoveGameEntity(self:GetVar("eventName"), ent)
end
