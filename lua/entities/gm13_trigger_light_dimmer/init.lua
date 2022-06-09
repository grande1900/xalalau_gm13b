-- Trigger to kill illumination

ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:Initialize()
    GM13.Event:SetRenderInfoEntity(self)
end

function ENT:Setup(eventName, entName, vecA, vecB)
    self.supportedLights = {
        ["gmod_light"] = true,
        ["gmod_lamp"] = true,
        ["gmod_softlamp"] = true,
        ["classiclight"] = true,
        ["gmod_wire_light"] = true,
        ["gmod_wire_lamp"] = true,
        ["expensive_light"] = true,
        ["expensive_light_new"] = true,
        ["cheap_light"] = true,
        ["projected_light"] = true,
        ["projected_light_new"] = true,
        ["light_spot"] = true,
        ["spot_light"] = true
    }

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

    self:SearchForExternalLights()
    self:SearchInside()

    GM13.Ent:SetCursed(self, true)
end

-- Some entities doesn't active the trigger touch, so we go after them
function ENT:SearchInside()
    local timerName = "gm13_force_dimming_" .. tostring(self)

    timer.Create(timerName, 5, 0, function()
        if not self:IsValid() then
            timer.Remove(timerName)
            return
        end

        for _, ent in ipairs(ents.FindInBox(self:GetVar("vecA"), self:GetVar("vecB"))) do
            if not ent:GetClass() or not self.supportedLights[ent:GetClass()] then continue end

            local spotlight
            for __, nearEnt in ipairs(ents.FindInSphere(ent:GetPos(), 30)) do
                if nearEnt:GetClass() == "point_spotlight" then
                    spotlight = nearEnt
                    break
                end
            end

            if GM13.Light:IsBurnResistant(ent) then
                if math.random(1, 1000) <= (spotlight and 5 or 100) then
                    local blinkTime = math.random(1, 2)

                    GM13.Light:Blink(ent, blinkTime, true,
                        function()
                            if spotlight then
                                spotlight:Fire("LightOn")
                            end
                        end,
                        function()
                            if spotlight then
                                spotlight:Fire("LightOff")
                            end
                        end,
                        function()
                            if spotlight then -- Sometimes the cone fails to end on the right mode, so it's needed
                                timer.Simple(0.1, function() 
                                    if not spotlight:IsValid() then return end
    
                                    spotlight:Fire("LightOn")
                                end)
                            end
                        end
                    )
                end
            elseif not ent.gm13_tryed_to_burn then
                self:BurnLight(ent, spotlight)
            end
        end
    end)
end

-- Burn lights
-- Note: Burn-Resistant Lights will turn off, dim and even release sparks, but can still be turned on.
function ENT:BurnLight(ent, spotlight)
    if GM13.Addon:BurnSimfphysLights(ent) then return end
    if GM13.Addon:CurseVJFirePlace(ent) then return end
    if GM13.Addon:CurseVJFlareRound(ent) then return end

    ent.gm13_tryed_to_burn = true
    if spotlight then
        spotlight.gm13_tryed_to_burn = true
    end

    local startBlinking = math.random(1, 100) <= 17
    local burned = false

    GM13.Ent:BlockContextMenu(ent, true) -- Prematurely lock context menu

    if startBlinking then
        burned = GM13.Light:Blink(ent, math.random(1, 2), false,
            function()
                if spotlight then
                    spotlight:Fire("LightOn")
                end
            end,
            function()
                if spotlight then
                    spotlight:Fire("LightOff")
                end
            end,
            function()
                GM13.Light:Burn(ent)

                if spotlight then -- Sometimes the cone fails to end on the right mode, so it's needed
                    timer.Simple(0.1, function()
                        if not spotlight:IsValid() then return end

                        spotlight:Fire("LightOff")
                        GM13.Light:Burn(spotlight)
                    end)
                end
            end
        )
    end

    if not startBlinking or not burned then
        burned = GM13.Light:FadeOut(ent, function()
            GM13.Light:Burn(ent)
        end)
    end

    if burned then
        if math.random(1, 100) <= 10 then
            timer.Simple(math.random(3, 9)/10, function()
                if not ent:IsValid() then return end

                net.Start("gm13_create_sparks")
                net.WriteVector(ent:GetPos())
                net.Broadcast()
            end)
        end
    end
end

-- Look for lights that rays hit vecCenter
function ENT:SearchForExternalLights()
    local hookName = "gm13_check_lights_" .. tostring(self)

    hook.Add("OnEntityCreated", hookName, function(ent)
        if not self:IsValid() then
            hook.Remove("OnEntityCreated", hookName)
            return
        end

        if not ent:GetClass() or not self.supportedLights[ent:GetClass()] then return end

        local lastPost = ent:GetPos()
        local timerName = "gm13_check_lights_" .. tostring(ent) .. "_" .. tostring(self)

        timer.Create(timerName, 1, 0, function()
            if not self:IsValid() or not ent:IsValid() or GM13.Light:IsBurned(ent) then
                timer.Remove(timerName)
                return
            end

            if lastPost == ent:GetPos() then return end
            lastPost = ent:GetPos()

            local GetRadius = ent.GetLightSize or ent.GetDistance or ent.GetRadius or ent.GetFarZ

            if ent:GetPos():Distance(self:GetVar("vecCenter")) - GetRadius(ent) <= 0 then
                self:BurnLight(ent)
            end
        end)
    end)
end

function ENT:StartTouch(ent)
    self:BurnLight(ent)

    if not ent:IsPlayer() then return end

    local ply = ent

    timer.Create("gm13_light_dimmer_addons_" .. tostring(ply), math.random(3, 10), 1, function()
        if not ply:IsValid() or not ply.gm13_in_dimmer then return end

        GM13.Addon:BreakNWMVGs(ply)
        GM13.Addon:RemoveRaskosNightvisionSWEP(ply)
        GM13.Addon:DropNightVisionGoggles(ply)
        GM13.Addon:DropNightVisionGogglesInspired(ply)

        net.Start("gm13_set_spys_night_vision")
        net.WriteBool(false)
        net.Send(ply)

        net.Start("gm13_set_arctics_night_vision")
        net.WriteBool()
        net.Send(ply)
    end)
end

function ENT:Touch(ent)
    if ent:IsPlayer() then
        if not ent.gm13_in_dimmer then
            ent.gm13_in_dimmer = true
        end
            
        if GetConVar("mat_fullbright"):GetBool() then
            RunConsoleCommand("mat_fullbright", "0")
        end
    end
end

function ENT:EndTouch(ent)
    if not ent:IsPlayer() then return end

    ent.gm13_in_dimmer = false

    local timerName = "gm13_light_dimmer_addons_" .. tostring(ent)

    timer.Simple(0.5, function()
        if not ent.gm13_in_dimmer then
            timer.Remove(timerName)
        end
    end)

    net.Start("gm13_set_spys_night_vision")
    net.WriteBool(true)
    net.Send(ent)
end
