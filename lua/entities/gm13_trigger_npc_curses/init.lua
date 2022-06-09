-- Make darkness curse NPCs

-- Main logic
-- ---------------------

local NPCCurses = {} -- { [string curse name] = function callback }
local darkRoomNPCs = {} 
--[[
   { [entity ent] = bool state }

    states:
        true = normal NPC
        false = insane NPC
        nil = new/killed NPC
]]

local function IsValidNPC(npc)
    return npc:IsNPC() and darkRoomNPCs[npc] == nil and GM13.Ent:IsSpawnedByPlayer(npc) or false
end

local function CleanDarkRoomNPCsTab()
    for ent, _ in pairs(darkRoomNPCs) do
        if not ent:IsValid() then
            darkRoomNPCs[ent] = nil
        end
    end
end

local function ShuffleNPCRelationships(ent)
    if ent.SetSquad then
        ent:SetSquad(tostring(math.random(1, 999)))
    end

    local getEnemy = math.random(1, table.Count(darkRoomNPCs))
    local newEnemy
    local count = 0
    for target, state in pairs(darkRoomNPCs) do
        if not state or not ent.AddEntityRelationship then continue end

        count = count + 1

        if count == getEnemy then
            newEnemy = target
        end

        local rel = math.random(1, 4)
        ent:AddEntityRelationship(target, rel, 99) -- https://wiki.facepunch.com/gmod/Enums/D
    end

    if newEnemy then
        ent:SetEnemy(newEnemy)
        ent:UpdateEnemyMemory(newEnemy, newEnemy:GetPos())
    end
end

local function SetCurse(ent, eventName)
    if math.random(1, 100) <= 50 then
        darkRoomNPCs[ent] = false

        timer.Simple(math.random(7, 45), function()
            if not ent:IsValid() then return end

            local callback = table.Random(NPCCurses)

            CleanDarkRoomNPCsTab()

            if math.random(1, 100) <= 50 then
                ShuffleNPCRelationships(ent)
            end

            callback(ent, eventName)
        end)
    end
end

local function SetCurseRetry(trigger, eventName)
    local timerName = "gm13_darkroom_crazy_npcs_" .. tostring(trigger)

    timer.Create(timerName, 15, 0, function()
        if not trigger:IsValid() then
            timer.Remove(timerName)
            return
        end

        for ent, state in pairs(darkRoomNPCs) do
            if ent:IsValid() and state then
                SetCurse(ent, eventName)
            end
        end

        local foundEnts = ents.FindInBox(trigger:GetVar("vecA"), trigger:GetVar("vecB"))

        for k, ent in pairs(foundEnts) do
            if IsValidNPC(ent) and darkRoomNPCs[ent] == nil then
                SetCurse(ent, eventName)
            end
        end
    end)
end

-- Entity
-- ---------------------

ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:Initialize()
    GM13.Event:SetRenderInfoEntity(self)
end

function ENT:Setup(eventName, entName, vecA, vecB)
    self:Spawn()

    local vecCenter = (vecA - vecB)/2 + vecB

    self:SetVar("eventName", eventName)
    self:SetVar("entName", entName)
    self:SetVar("vecA", vecA)
    self:SetVar("vecB", vecB)
    self:SetVar("vecCenter", vecCenter)
    self:SetVar("color", Color(252, 119, 3, 255)) -- Orange

    self:SetName(entName)
    self:SetPos(vecCenter)

    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBoundsWS(vecA, vecB)
    self:SetTrigger(true)

    GM13.Ent:SetCursed(self, true)

    SetCurseRetry(self, eventName)
end

function ENT:StartTouch(ent)
    if not IsValidNPC(ent) then return end

    local eventName = self:GetVar("eventName")

    darkRoomNPCs[ent] = true
 
    SetCurse(ent, eventName)

    -- Free NPCs who activated touch and didn't die from the curse in 1 minute
    timer.Simple(60, function()
        if not ent:IsValid() then return end

        darkRoomNPCs[ent] = true
    end)
end

function ENT:AddCurse(name, callback)
    NPCCurses[name] = callback
end

function ENT:RemoveCurse(name)
    NPCCurses[name] = nil
end

-- Curses
-- ---------------------

-- Drop weapons
local function DropWeapons(ent)
    if not ent:IsValid() then return end -- Note: don't remove the extra checks! They are being needed due to the game's delay in calling the functions.

    if ent.DropWeapon and ent:GetActiveWeapon() then
        ent:DropWeapon()
    end

    darkRoomNPCs[ent] = true
end

-- Fade out and go away
local function FadeOut(ent)
    if not ent:IsValid() then return end

    GM13.Ent:FadeOut(ent, 10, function()
        ent:Remove()
    end)
end

-- Fade out and came back as angry ratpeople
local function TurnIntoRatPerson(ent, eventName)
    if not ent:IsValid() then return end

    GM13.Ent:FadeOut(ent, 10, function()
        if not ent:IsValid() then return end

        local stalker = ents.Create("npc_stalker")
        stalker:SetPos(ent:GetPos())
        stalker:SetAngles(ent:GetAngles())
        ent:Remove()
        stalker:Activate()
        stalker:Spawn()
        stalker:SetKeyValue("BeamPower", "2")
        stalker:SetKeyValue("squadname", "ratpeople")
        stalker:SetNotSolid(true)
        GM13.Ent:SetInvulnerable(stalker, true)
        GM13.Ent:BlockPhysgun(stalker, true)
        GM13.Ent:BlockToolgun(stalker, true)
        GM13.Ent:BlockContextMenu(stalker, true)
        GM13.Ent:FadeIn(stalker, 6)
        GM13.Event:SetGameEntity(eventName, stalker)

        GM13.Ent:FadeIn(stalker, 3, function()
            if not stalker:IsValid() then return end

            GM13.NPC:AttackClosestPlayer(stalker)

            timer.Simple(7, function()
                if not stalker:IsValid() then return end

                GM13.Ent:FadeOut(stalker, 3, function()
                    if not stalker:IsValid() then return end

                    stalker:Remove()
                end)
            end)
        end)
    end)
end

-- Ragdollify and throw
local function ThrowUp(ent, eventName)
    if not ent:IsValid() then return end

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetPos(ent:GetPos())
    ragdoll:SetModel(ent:GetModel())
    ragdoll:SetAngles(ent:GetAngles())
    ent:Remove()
    ragdoll:Spawn()
    ragdoll:Activate()
    GM13.Event:SetGameEntity(eventName, ragdoll)

    ragdoll:EmitSound("ambient/energy/weld2.wav")

    for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local phys = ragdoll:GetPhysicsObjectNum(i)
		phys:ApplyForceCenter(Vector(0, 0, 10000))
	end

    GM13.Ent:FadeOut(ragdoll, 10, function()
        if not ragdoll:IsValid() then return end

        ragdoll:Remove()
    end)
end

-- Burn
local function Burn(ent)
    if not ent:IsValid() then return end

    ent:Ignite(30, 100)
end

-- Spin death
local function DieSpinning(ent)
    if not ent:IsValid() then return end

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetPos(ent:GetPos())
    ragdoll:SetModel(ent:GetModel())
    ragdoll:SetAngles(ent:GetAngles())
    ent:Remove()
    ragdoll:Spawn()
    ragdoll:Activate()

    local phys = ragdoll:GetPhysicsObject()

    local name = tostring(ragdoll)
    hook.Add("Tick", name, function()
        if not phys:IsValid() then
            hook.Remove("Tick", name)
            return
        end

        phys:SetAngles(phys:GetAngles() + Angle(0, 100))
        phys:SetPos(phys:GetPos() + Vector(0, 0, 1.1))
    end)

    local id = ragdoll:StartLoopingSound("ambient/atmosphere/city_beacon_loop1.wav")

    ragdoll:CallOnRemove("gm13_stop_engine_sound", function(ent)
        ent:StopLoopingSound(id)
    end)

    GM13.Ent:FadeOut(ragdoll, 10, function()
        if not ragdoll:IsValid() then return end

        ragdoll:Remove()
    end)
end

NPCCurses["DropWeapons"] = DropWeapons
NPCCurses["FadeOut"] = FadeOut
NPCCurses["TurnIntoRatPerson"] = TurnIntoRatPerson
NPCCurses["ThrowUp"] = ThrowUp
NPCCurses["Burn"] = Burn
NPCCurses["DieSpinning"] = DieSpinning 