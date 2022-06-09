-- Broadcast portal

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    if not GM13.Event.Memory:Get("ratmanReady") then
        local explo = ents.Create("env_explosion")
        explo:SetPos(self:GetPos())
        explo:Spawn()
        explo:Fire("Explode")
        explo:SetKeyValue("IMagnitude", 20)
        self:Remove()
        return
    end

    local olderRadio
    for k, ent in ipairs(ents.FindByClass("gm13_sent_radio")) do
        if ent ~= self then
            olderRadio = ent
            GM13.Event:RemoveRenderInfoEntity(ent)
            ent:SetNoDraw(true)
        end
    end

    timer.Simple(0.5, function()
        if not self:IsValid() then
            if olderRadio and olderRadio:IsValid() then
                olderRadio:SetNoDraw(false)
            end

            return
        end

        if not self:GetVar("entName") then
            GM13.Event:RemoveRenderInfoEntity(self)
            self:Remove()

            if olderRadio and olderRadio:IsValid() then
                GM13.Event:SetRenderInfoEntity(olderRadio)
                olderRadio:SetNoDraw(false)
            end
        else
            if olderRadio and olderRadio:IsValid() then
                olderRadio:Remove()
            end
        end
    end)

    GM13.Event:SetRenderInfoEntity(self)

    self.minge_attractor = false
    self.forced_exit = false
    self.radioSounds = {}

    for i = 1, 7 do
        table.insert(self.radioSounds, "ambient/levels/prison/radio_random" .. i .. ".wav")
    end

    self.gm13_radio = true
    self.playing = nil
    self.broadcasting = nil
    self.main = "gm13/radio/main.wav"

    GM13.Ent:BlockContextMenu(self, true)
    GM13.Ent:SetCursed(self, true)

    self:SetName("radio")
    self:SetModel("models/props_lab/citizenradio.mdl")
    self:SetUseType(SIMPLE_USE)

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Setup(eventName, vecA, vecB)
    local vecDiff = (vecA - vecB)/2
    local vecCenter = vecDiff + vecB

    self:SetVar("eventName", eventName)
    self:SetVar("entName", "radio")
    self:SetVar("vecA", vecA)
    self:SetVar("vecB", vecB)
    self:SetVar("vecCenter", vecCenter)
    self:SetVar("color", Color(153, 50, 168, 255)) -- Purple

    self:SetPos(vecCenter)

    self:SetVar("vecDiff", vecDiff)

    self:SetVar("isReady", true)
end

function ENT:PhysicsCollide(data, phys)
    self:SetVar("vecCenter", self:GetPos())
    self:SetVar("vecA", self:GetPos() + self:GetVar("vecDiff"))
    self:SetVar("vecB", self:GetPos() - self:GetVar("vecDiff"))
    GM13.Event:SetRenderInfoEntity(self)
end

function ENT:Use(activator)
    if self.broadcasting then return end

    if self.playing then
        self:StopSound(self.playing)
    end

    self:RemoveMingeAttractor()

    if math.random(1, 100) <= 20 then
        self.playing = self.main

        if self.playing ~= self.main then -- Beware of sounds containing loops!
            timer.Create("gm13_finish_main_radio", SoundDuration(self.playing), 1, function()
                if not self:IsValid() then return end

                self.playing = ""
            end)
        end
    else
        self.playing = self.radioSounds[math.random(1, #self.radioSounds)]

        if timer.Exists("gm13_finish_main_radio") then
            timer.Remove("gm13_finish_main_radio")
        end

        if self.playing == "gm13/radio/mingev2glitch.wav" then
            self.playing = ""
            self:SetMingeAttractor()
            return
        end
    end

    self:EmitSound(self.playing)
end

function ENT:OnRemove()
    if self.playing then
        self:StopSound(self.playing)
    end

    if self.broadcasting then
        self:StopSound(self.broadcasting)
    end

    if ISGM13 then
        if not GM13.Event.Memory:Get("ratmanReady") then return end

        local eventName = self:GetVar("eventName")

        timer.Simple(0.25, function()
            local totalRadios = #ents.FindByClass("gm13_sent_radio")

            if totalRadios == 0 then
                local radio = ents.Create("gm13_sent_radio")
                radio:Setup(eventName, Vector(700.18, -865.23, -143.97), Vector(717.18, -895.23, -123.97))
                radio:Spawn()
            end
        end)
    end
end

local function BreakMingeSeal()
    do return end -- it's too extreme

    if not GM13.Event.Memory:Get("mingeSeal") then return end

    if ISGM13 then
        local skull = ents.FindByName("SealSkull")[1]

        if skull then
            local ent = ents.Create("prop_physics")

            ent:PhysicsInit(SOLID_VPHYSICS)
            ent:SetMoveType(MOVETYPE_VPHYSICS)
            ent:SetSolid(SOLID_VPHYSICS)
        
            local phys = ent:GetPhysicsObject()

            if phys:IsValid() then
                phys:Wake()
            end
        
            ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
            ent:SetPos(skull:GetPos() + Vector(0, 0, 10))
        
            ent:Spawn()
        end
    end

    GM13.Event.Memory:Set("mingeSeal")
end

function ENT:SetMingeAttractor()
    if self.minge_attractor then return end

    BreakMingeSeal()

    self.minge_attractor = true

    local totalStages = 6

    self:EmitSound("buttons/blip1.wav")

    local function SendStage(curStage, hookName, hookID)
        if not self:IsValid() or not self.minge_attractor then
            hook.Remove(hookName, hookID)
            return false
        end

        net.Start("gm13_minge_attractor_stage")
        net.WriteEntity(self)
        net.WriteFloat(curStage/totalStages)
        net.Broadcast()

        return true
    end

    hook.Add("gm13_lobby_select_server", "gm13_radio_lobby_select_server", function()
        if SendStage(1, "gm13_lobby_select_server", "gm13_radio_lobby_select_server") then
            self.playing = "gm13/radio/mingenet/modem_1.wav"
            self:EmitSound(self.playing)
        end
    end)

    hook.Add("gm13_lobby_get_info", "gm13_radio_lobby_get_info", function()
        SendStage(2, "gm13_lobby_get_info", "gm13_radio_lobby_get_info")
    end)

    hook.Add("gm13_lobby_sync", "gm13_radio_lobby_sync", function()
        if SendStage(3, "gm13_lobby_sync", "gm13_radio_lobby_sync") then
            self.playing = "gm13/radio/mingenet/modem_2.wav"
            self:EmitSound(self.playing)
        end
    end)

    hook.Add("gm13_lobby_sync_late", "gm13_radio_lobby_sync_late", function()
        SendStage(3, "gm13_lobby_sync_late", "gm13_radio_lobby_sync_late")
    end)

    hook.Add("gm13_lobby_sync_extra", "gm13_radio_lobby_sync_extra", function()
        SendStage(3, "gm13_lobby_sync_extra", "gm13_radio_lobby_sync_extra")
    end)

    hook.Add("gm13_lobby_apply_in", "gm13_radio_lobby_apply_in", function()
        if SendStage(4, "gm13_lobby_apply_in", "gm13_radio_lobby_apply_in") then
            self.playing = "gm13/radio/mingenet/modem_3.wav"
            self:EmitSound(self.playing)
        end
    end)

    hook.Add("gm13_lobby_check", "gm13_radio_lobby_check", function()
        if SendStage(5, "gm13_lobby_check", "gm13_radio_lobby_check") then
            self.playing = "gm13/radio/mingenet/modem_4.wav"
            self:EmitSound(self.playing)
        end
    end)

    hook.Add("gm13_lobby_play", "gm13_radio_lobby_play", function()
        if SendStage(6, "gm13_lobby_play", "gm13_radio_lobby_play") then
            self.playing = "gm13/radio/mingenet/modem_5.wav"
            self:EmitSound(self.playing)
        end
    end)

    hook.Add("gm13_lobby_exit", "gm13_radio_lobby_exit", function()
        if SendStage(0, "gm13_lobby_exit", "gm13_radio_lobby_exit") then
            if not self.forced_exit then
                self.playing = "gm13/radio/mingenet/occupied.wav"
                self:EmitSound(self.playing)
            else
                self.forced_exit = false
            end
        end
    end)

    GM13.Lobby:SelectBestServer()
end

function ENT:RemoveMingeAttractor()
    if not self.minge_attractor then return end
    self.forced_exit = true

    self:EmitSound("buttons/button8.wav")

    GM13.Lobby:ForceDisconnect()

    self.minge_attractor = false
end