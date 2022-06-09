-- A real Mingebag

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.PrecacheModel("models/weapons/w_physics.mdl")

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

function ENT:Initialize()
    if not (self:GetNWFloat('delay') and self:GetNWInt('max_seconds')) then
        print("Run ENT:SetTiming() before you can spawn it.")
        return
    end

    self:SetModel("models/kleiner.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    self:SetPos(Vector(1965.7, 1647.5, -1997.9))
    GM13.Ent:HideInfo(self, true)
	GM13.Ent:SetFakeInvalid(self, true)
    GM13.Ent:BlockPhysgun(self, true)
    GM13.Ent:BlockToolgun(self, true)
    GM13.Ent:BlockContextMenu(self, true)

    timer.Simple(self:GetNWInt('max_seconds'), function()
        if not self:IsValid() then return end
        self:Remove()
    end)
end

function ENT:SetTiming(delay, max_seconds)
    -- Note: The timers and ping unfortunately aren't consistent and can cause the minge to teleport.
    -- At least I can improve the timers situation by using less repetitions. Take this test:
    --[[
        local fullTime = 0.20

        print("\nExpected: " .. fullTime)

        local repetitions = 20
        local splitTime = fullTime / repetitions

        local startTime = SysTime()

        timer.Simple(2, function() -- Small delay for me to decide to focus the game window or not
            timer.Create("test_timer", splitTime, repetitions, function()
                if timer.RepsLeft("test_timer") == 0 then
                    print("Actual result: " .. (SysTime() - startTime))
                end
            end)
        end)
    ]]

    self:SetNWFloat('delay', delay * 0.6)
    self:SetNWInt('repetitions', 10)
    self:SetNWInt('max_seconds', max_seconds)
end

function ENT:Control(data)
    if not data or not istable(data) or not data.pos then return end
    if not (self:GetNWFloat('delay') and self:GetNWInt('repetitions')) then return end

    self:SetNWString('dataTime', tostring(CurTime()))
    self:SetNWAngle('ang', data.ang)

    local pos = data.pos
    local mingeAng = Angle(0, data.ang[2], 0)

    if not self.lastPos then
        self.lastPos = pos
        self.lastAng = mingeAng
        self:SetPos(pos)
        self:SetAngles(mingeAng)
        return
    end

    local moveRefreshs = self:GetNWInt('repetitions')
    local moveTick = self:GetNWFloat('delay') / moveRefreshs
    local moveRatio = 0

    local posStart = self.lastPos
    local posEnd = pos

    local angStart = self.lastAng
    local angEnd = mingeAng

    local timerName = "gm13_move_minge_" .. tostring(self)

    timer.Create(timerName, moveTick, moveRefreshs, function()
        if not self:IsValid() then
            timer.Remove(timerName)
            return
        end

        moveRatio = moveRatio + 1 / moveRefreshs
        self:SetPos(LerpVector(moveRatio, posStart, posEnd))
        self:SetAngles(LerpAngle(moveRatio, angStart, angEnd))
    end)

    if self:GetNWInt('isFiring') ~= data.is_firing then
        self:SetNWInt('isFiring', data.is_firing)
    end

    self.lastAng = angEnd
    self.lastPos = posEnd
end
