-- Key to a giant sleeping dark room
-- This entity is not flexible, it was created just to facilitate access and organize the code

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

function ENT:Setup(eventName, doll, chair, lamp)
    self.doll = doll
    self.chair = chair
    self.lamp = lamp
    self.activated = false

    local fixedOrigin = self.chair:GetPos()

    local changeChairPosTrigger = ents.Create("gm13_trigger")
    changeChairPosTrigger:Setup(eventName, "changeChairPosTrigger", Vector(-2165.3, 29.3, -7081.9), Vector(-6460.4, -3486, -6900))

    local function setNewPos(ent)
        if not ent:IsValid() or not chair:IsValid() then
            timer.Remove("gm13_big_dark_key_" .. tostring(ent))
            return
        end

        local newPos = ent:GetPos() + ent:GetPos():GetNormalized() * 15

        if not util.IsInWorld(newPos) then
            newPos = ent:GetPos() - ent:GetPos():GetNormalized() * 15
        end

        if util.IsInWorld(newPos) then
            fixedOrigin = newPos
        end

        return true
    end

    function changeChairPosTrigger:StartTouch(ent)
        if not ent:IsPlayer() then return end
        if timer.Exists("gm13_big_dark_key_" .. tostring(ent)) then return end

        timer.Create("gm13_big_dark_key_" .. tostring(ent), 15, 0, function()
            if setNewPos(ent) then
                GM13.Ent:SetInvulnerable(chair, false)
                timer.Create("gm13_big_dark_key_" .. tostring(ent), 40, 0, function()
                    setNewPos(ent)
                end)
            end
        end)
    end

    local count = 0
    local fixedDistance = Vector(30, 30, -20)

    timer.Create("gm13_chair_waiting_for_01doll", 0.05, 0, function()
        if not self.chair or not self.chair:IsValid() or not self.doll:IsValid() then
            timer.Remove("gm13_chair_waiting_for_01doll")
            return
        end
    
        local distanceVec = self.chair:GetPos() - self.doll:GetPos()
        local ang = distanceVec:Angle()
    
        self.chair:SetAngles(Angle(0, ang.y + 90, 0))
    
        if self.activated then
            fixedDistance:Rotate(Angle(0, 35, 0))

            local newPos = self.chair:GetPos() - fixedDistance * math.random(1, 4)

            self.doll:SetPos(newPos)
            self.doll:SetAngles(Angle(0, self.doll:GetAngles().y - 30, 0))

            GM13.Ent:BlockPhysgun(self.doll, true)
            GM13.Ent:BlockToolgun(self.doll, true)
            GM13.Ent:BlockContextMenu(self.doll, true)
        end
    
        count = count + 1
        if count == 40 then
            count = 0
            self.chair:SetPos(fixedOrigin)
        end
    end)
end

function ENT:Sleep()
    GM13.Map:BlockCleanup(false)

    if self.soundId then
        self.chair:StopLoopingSound(self.soundId)
    end

    self.doll:StopSound("ambient/atmosphere/captain_room.wav")

    if self.lamp:IsValid() then
        self.lamp:Remove()
    end

    timer.Simple(0.1, function()
        if self.chair:IsValid() then
            self.chair:Remove()

            if self.doll:IsValid() then
                self.doll:Remove()
            end
        end
    end)
end

function ENT:Awake()
    local taunts = {
        "vo/npc/female01/strider_run.wav",
        "vo/npc/female01/uhoh.wav",
        "vo/npc/female01/gethellout.wav"
    }

    util.ScreenShake(self.chair:GetPos(), 3, 3, 3, 3000)

    -- Note: both files looped, but since StopLoopingSound apparently can't stop 2 sounds, I'm also using EmitSound
    self.soundId = self.chair:StartLoopingSound("gm13/ambient/crazychair.wav")
    self.doll:EmitSound("ambient/atmosphere/captain_room.wav")

    timer.Simple(math.random(5, 13) / 10, function()
        if not self.doll:IsValid() then return end
        self.doll:EmitSound(taunts[math.random(1, #taunts)])
    end)

    self.chair:CallOnRemove("gm13_removed_chair_2", function()
        self:Sleep()
    end)

    GM13.Prop:CallOnBreak(self.chair, "gm13_awake", function()
        self:Sleep()
    end)

    self.activated = true
end