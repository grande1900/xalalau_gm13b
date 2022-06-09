-- Make the darkness curse drones
-- https://steamcommunity.com/sharedfiles/filedetails/?id=429126576 -- 1
-- https://steamcommunity.com/sharedfiles/filedetails/?id=669642096 -- Rewrite
-- https://steamcommunity.com/sharedfiles/filedetails/?id=497536995 -- 2


-- Main logic
-- ---------------------

local droneCurses -- { [string curse name] = function callback }
local darkRoomDrones = {} 
--[[
   { [entity ent] = bool state }

    states:
        true = normal drone
        false = insane drone
        nil = new/killed drone
]]

local function IsDrones1(ent)
    return string.find(ent:GetClass(), "entity") and true or false
end

local function IsDronesRewrite(ent)
    return string.find(ent:GetClass(), "dronesrewrite") and true or false
end

local function IsDrones2(ent)
    return not IsDronesRewrite(ent) and ent.IsDroneDestroyed and true or false
end

local function SetCurse(ent, eventName)
    if math.random(1, 100) <= 50 then
        darkRoomDrones[ent] = false

        timer.Simple(math.random(7, 13), function()
            if not ent:IsValid() then return end

            local callback = table.Random(droneCurses)

            callback(ent, eventName)
        end)
    end
end

local function SetCurseRetry(trigger, eventName)
    local timerName = "gm13_darkroom_crazy_drones_" .. tostring(trigger)

    timer.Create(timerName, 15, 0, function()
        if not trigger:IsValid() then
            timer.Remove(timerName)
            return
        end

        for ent, state in pairs(darkRoomDrones) do
            if ent:IsValid() then
                if state then
                    SetCurse(ent, eventName)
                end
            else
                darkRoomDrones[ent] = nil
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
    local isValidDrone = ent:GetClass() and string.find(ent:GetClass(), "drone") and ent.SetDriver and (IsDrones1(ent) or IsDronesRewrite(ent) or IsDrones2(ent)) and darkRoomDrones[ent] == nil

    if not isValidDrone then return end

    local eventName = self:GetVar("eventName")

    darkRoomDrones[ent] = true
 
    SetCurse(ent, eventName)
end

function ENT:AddCurse(name, callback)
    droneCurses[name] = callback
end

function ENT:RemoveCurse(name)
    droneCurses[name] = nil
end

-- Curses
-- ---------------------

-- Ragdollify and throw
local function ThrowUp(ent, eventName)
    if not ent:IsValid() then return end

    local obj = ent:GetPhysicsObject(ent)

    if not obj:IsValid() then return end

    obj:SetMass(10)
    obj:ApplyForceCenter(Vector(0, 0, 30000))
    obj:SetMass(100)

    ent:EmitSound("ambient/energy/weld2.wav")

    timer.Simple(0.6, function()
        if not ent:IsValid() then return end

        if IsDronesRewrite(ent) then
            ent:Destroy()
        elseif IsDrones1(ent) or IsDrones2(ent) then
            ent:TakeDamage(10000)
        end
    end)
end

-- Spin death
local function DieSpinning(ent)
    if not ent:IsValid() then return end

    local obj = ent:GetPhysicsObject(ent)

    if not obj:IsValid() then return end

    local name = tostring(ent)
    hook.Add("Tick", name, function()
        if not obj:IsValid() then
            hook.Remove("Tick", name)
            return
        end

        obj:SetAngles(obj:GetAngles() + Angle(0, 100))
        obj:SetPos(obj:GetPos() + Vector(0, 0, 1.1))
    end)

    local id = ent:StartLoopingSound("ambient/atmosphere/city_beacon_loop1.wav")

    ent:CallOnRemove("gm13_stop_engine_sound", function(ent)
        ent:StopLoopingSound(id)
    end)

    GM13.Ent:FadeOut(ent, 10, function()
        if not ent:IsValid() then return end

        ent:Remove()
    end)
end

-- Stop flying
local function RemoveFuel(ent)
    if IsDronesRewrite(ent) then
        ent.FuelReduction = 50 

        if ent.flashlight then
            GM13.Light:Blink(ent.flashlight, 1, false, nil, nil, function()
                ent.flashlight = function() return end
            end)
        end
    
        ent.UseNightVision = false
    elseif IsDrones2(ent) then
        ent.Fuel = 0
        ent.MaxFuel = 0

        ent.UseNightVision = false
    elseif IsDrones1(ent) then
        ent:StopMotionController()
        ent:SetNWBool("nightvision", false)
    end
end

-- Swap driver and drone pos
local function Swap(ent)
    local ply
    if not IsDronesRewrite(ent) then
        ply = ent:GetDriver()
    else
        ply = GM13.Ply:GetClosestPlayer(ent:GetPos()) -- haha, I love this map
    end

    if not IsValid(ply) then return end

    if ent.SetDriver then
        ent:SetDriver(NULL) 
    end

    local plyPos = ply:GetPos()
    local dronePos = ent:GetPos()

    dronePos.z = plyPos.z

    ent:SetPos(plyPos)
    ply:SetPos(dronePos)

    darkRoomDrones[ent] = nil
end

-- Break the drone
local function Break(ent)
    if IsDronesRewrite(ent) then
        local function FireNothing()
            net.Start("gm13_create_sparks")
            net.WriteVector(ent:GetPos())
            net.Broadcast()
        end
    
        ent.Attack1 = FireNothing
        ent.Attack2 = FireNothing
    
        ent.RotateSpeed = 1
        ent.Speed = 500
        ent.UpSpeed = 500

        ent.UseNightVision = false
        ent.Immortal = false
    
        if ent.flashlight then
            GM13.Light:Blink(ent.flashlight, 5, false, nil, nil, function()
                ent.flashlight = function() return end
            end)
        end

        ent:SetDefaultHealth(15)
    elseif IsDrones2(ent) then
        ent.Ammo = 0
        ent.Ammo2 = 0
        ent.MaxAmmo = 0

        ent.curSpeed = 0
        ent.Speed = 100
        ent.RotateSpeed = 100

        ent.UseNightVision = false

        ent.defArmor = 15
    elseif IsDrones1(ent) then
        ent.armor = 15
        ent.defArmor = 15
    end

    ent:Ignite(30, 100)
end

droneCurses = {
    ["ThrowUp"] = ThrowUp,
    ["DieSpinning"] = DieSpinning,
    ["RemoveFuel"] = RemoveFuel,
    ["Swap"] = Swap,
    ["Break"] = Break
}
