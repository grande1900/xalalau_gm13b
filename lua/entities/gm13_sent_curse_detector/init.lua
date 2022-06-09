-- Nice curse detector

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    if GM13.Event.Memory:Get("sempersHat") and #ents.FindByName("Semper") == 0 then
        self:Remove()
        return
    end

    if not GM13.Event.Memory:Get("savedCitizen") then
        local explo = ents.Create("env_explosion")
        explo:SetPos(self:GetPos())
        explo:Spawn()
        explo:Fire("Explode")
        explo:SetKeyValue("IMagnitude", 20)

        self:Remove()

        return
    end

    for k, ent in ipairs(ents.FindByClass("gm13_sent_curse_detector")) do
        if ent ~= self then
            ent:Remove()
        end
    end

    self.isReceivingMessage = false

    self:SetModel("models/props_junk/TrafficCone001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    self:SetPos(Vector(666.2, -884.1, -125.6))

    local light = ents.Create("gmod_light")

    light:SetPos(Vector(666.2, -884.1, -105))
    light:SetAngles(Angle(0, 0, 180))
    light:SetParent(self)
    light:SetBrightness(2)
    light:SetLightSize(256)
    light:Spawn()

    self.light = light

    GM13.Light:SetBurnResistant(light, true)
    GM13.Ent:BlockContextMenu(light, true)
    GM13.Ent:BlockPhysgun(light, true)

    timer.Create("gm13_timer_curse_detector", 0.5, 0, function()
        if self.isReceivingMessage then return end
        if GM13.Event.Memory:Get("sempersHat") then return end

        if not (self and light and self:IsValid() and light:IsValid()) then
            if ISGM13 and GM13.Event.Memory:Get("savedCitizen") then
                local detector = ents.Create("gm13_sent_curse_detector")
                detector:Spawn()
            else
                timer.Remove("gm13_timer_curse_detector")
            end

            return
        end

        light:SetOn(false)

        for k, ent in ipairs(ents.FindInSphere(light:GetPos(), 64)) do
            if ent:IsValid() and GM13.Ent:IsCursed(ent) and not GM13.Ent:IsCurseHidden(ent) then
                light:SetOn(true)
            end
        end
    end)

    hook.Add("gm13_lobby_event_started", "gm13_start_red_alert", function(data)
        if not self:IsValid() then
            hook.Remove("gm13_lobby_event_started", "gm13_start_red_alert")
            return
        end

        local endVecTab = {}
        for k, invaderData in pairs(data['invaders']) do
            table.insert(endVecTab, invaderData.pos)
        end

        self:StartRedAlert(endVecTab)
    end)

    if GM13.Event.Memory:Get("sempersHat") then
        local colorDelay = 2

        timer.Create("gm13_cone_random_colors", colorDelay, 0, function()
            if not GM13.Event.Memory:Get("sempersHat") or not self:IsValid() then
                timer.Remove("gm13_cone_random_colors")
                return
            end
            
            self:StartRandomColors(colorDelay)
        end)
    end
end

function ENT:StartRedAlert(endVecTab)
    if GM13.Event.Memory:Get("sempersHat") then return end
    if not self.light or not self.light:IsValid() then return end

    self.isReceivingMessage = true

    local alertColor = Color(255, 0, 0, 255)
    self.light:SetColor(alertColor)

    local hookName = "gm13_detector_invader"
    local delay = 3

    local index = 1
    local singleDetectionDelay = delay / #endVecTab
    timer.Create("gm13_red_alert_minges", singleDetectionDelay, #endVecTab, function()
        index = index + 1
    end)

    GM13.Light:Blink(self.light, delay, false, 
        function()
            self:SetNWBool("gm13_enable_red_beam", true)
            self:SetNWVector("gm13_draw_red_beam_start", self.light:GetPos())
            self:SetNWVector("gm13_draw_red_beam_end", endVecTab[index])
        end,
        function()
            self:SetNWBool("gm13_enable_red_beam", false)
        end,
        function()
            self.light:SetColor(Color(255, 255, 255, 255))
            self.isReceivingMessage = false
        end
    )
end

function ENT:StartRandomColors(colorDelay)
    if not self.light or not self.light:IsValid() then return end

    GM13.Light:Blink(self.light, colorDelay, true, 
        function()
            self.light:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255))
        end,
        nil,
        function()
            self.light:SetColor(Color(255, 255, 255, 255))
        end
    )
end