include("shared.lua")

killicon.Add("gm13_mingebag", "HUD/killicons/default", Color( 255, 80, 0, 255 ))

function ENT:Initialize()
    timer.Simple(0.3, function() -- Wait until we have proper networked values
        if not self:IsValid() then return end

        local weaponRelPos = Vector(-5, 0, 35)
        local mingeAng = self:GetForward():Angle()
        weaponRelPos:Rotate(mingeAng)

        local weapon = ents.CreateClientProp("models/weapons/w_physics.mdl")
        self.weapon = weapon
        self.weapon:SetPos(self:GetPos() + weaponRelPos)

        self.weapon:SetAngles(mingeAng)
        self.weapon:SetParent(self)
        self.weapon:Spawn()
        self.weapon:SetNotSolid(true)

        GM13.Ent:HideInfo(self.weapon, true)
        GM13.Ent:SetFakeInvalid(self.weapon, true)
        GM13.Ent:BlockPhysgun(self.weapon, true)
        GM13.Ent:BlockToolgun(self.weapon, true)
        GM13.Ent:BlockContextMenu(self.weapon, true)

        timer.Simple(self:GetNWInt('max_seconds'), function()
            if not self:IsValid() or not weapon:IsValid() then return end
            weapon:Remove()
        end)
    end)
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    self:DrawLaser()
end

function ENT:DrawLaser()
    if self:GetNWAngle('dataTime') == self.lastDataTime then return end
    if not (self:GetNWFloat('delay') > 0 and self:GetNWInt('repetitions') > 0) then return end

    self.lastDataTime = self:GetNWAngle('dataTime')

    local realAng = self:GetNWAngle('ang')

    if not self.lastLaserAng then
        self.lastLaserAng = realAng
        return
    end

    local moveRefreshs = self:GetNWInt('repetitions')
    local moveTick = self:GetNWFloat('delay') / moveRefreshs
    local moveRatio = 0

    local angLaserStart = self.lastLaserAng
    local angLaserEnd = realAng
    local angLaserNormal = angLaserStart:Forward()
    
    local timerName = "gm13_draw_laser_timer_" .. tostring(self)

    timer.Create(timerName, moveTick, moveRefreshs, function()
        if not self:IsValid() then
            timer.Remove(timerName)
            return
        end

        moveRatio = moveRatio + 1 / moveRefreshs
        angLaserNormal = LerpAngle(moveRatio, angLaserStart, angLaserEnd):Forward() 
    end)

    local hookName = "gm13_draw_laser_hook_" .. tostring(self)

    local canPlaceDecal = 0
    hook.Add("PostDrawTranslucentRenderables", hookName, function(bDepth, bSkybox)
        if not self:IsValid() then
            hook.Remove("PostDrawTranslucentRenderables", hookName)
            return
        end

        if self:GetNWInt('isFiring') ~= 0 then
            local startLaserPos = self:GetPos() + Vector(0, 0, 35) + self:GetForward() * 18
            local endLaserTracePos = angLaserNormal * 32768
            local tr = util.QuickTrace(startLaserPos, endLaserTracePos)

            if LocalPlayer():IsValid() and LocalPlayer():GetNWInt("gm13_lobby") == 1 then
                local color = self:GetNWInt('isFiring') == 1 and Color(235, 137, 52) or Color(77, 255, 255)

                GM13.Effect:CreateBeam(startLaserPos, tr.HitPos, 1, color)
            end

            if self:GetNWInt('isFiring') == 2 and canPlaceDecal ~= 2 then
                util.Decal("justamissingtexture", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
                canPlaceDecal = canPlaceDecal + 1
            else
                canPlaceDecal = 0
            end
        end
    end)

    self.lastLaserAng = angLaserEnd
end

function ENT:Hide()
    if self:IsValid() then
        self:SetNotSolid(true)
        self:SetNoDraw(true)

        if self.weapon and self.weapon:IsValid() then
            self.weapon:Remove()
        end
    end
end

function ENT:OnRemove()
    if self.weapon and self.weapon:IsValid() then
        self.weapon:Remove()
   end
end
