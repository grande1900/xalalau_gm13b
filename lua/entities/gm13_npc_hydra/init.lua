-- The Hydra (Yea)

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

hydraSounds = {
    ["Ueee"] = "/npc/vort/vort_pain3.wav",
    ["Need"] = "/vo/citadel/br_youneedme.wav",
    ["Ahh"] = "/vo/npc/alyx/hurt04.wav",
    ["Uhh"] = "/vo/npc/alyx/hurt05.wav"
}

function ENT:Initialize()
    GM13.Event:SetRenderInfoEntity(self)
end

function ENT:Setup(eventName, entName, vec)
    self:Spawn()

    self:SetVar("eventName", eventName)
    self:SetVar("entName", entName)
    self:SetVar("vecA", vec - Vector(15, 15, 0))
    self:SetVar("vecB", vec + Vector(15, 15, 40))
    self:SetVar("vecCenter", vec)
    self:SetVar("color", Color(252, 244, 5, 255)) -- Yellow

    self:SetSolidFlags(FSOLID_NOT_SOLID)
    self:SetName(entName)
    self:SetPos(vec)
end

function ENT:GetSounds()
    return hydraSounds
end

function ENT:PlaySound(soundID)
    self:EmitSound(hydraSounds[soundID])
end