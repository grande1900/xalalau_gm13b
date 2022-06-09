-- Func to create sprites

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    GM13.Event:SetRenderInfoEntity(self)
end

function ENT:Setup(eventName, entName, vecCenter, width, height, angles, materialName)
    self:Spawn()

    local relVecA = Vector(height / 2, 0, width / 2)
    relVecA:Rotate(angles)

    local vecA = vecCenter + relVecA
    local vecB = vecCenter - relVecA

    self:SetVar("eventName", eventName)
    self:SetVar("entName", entName)
    self:SetVar("vecA", vecA)
    self:SetVar("vecB", vecB)

    self:SetVar("vecCenter", vecCenter)
    self:SetVar("color", Color(252, 244, 5, 255)) -- Yellow

    self:SetName(entName)
    self:SetPos(vecCenter)
    self:SetAngles(angles)
    self:SetModel("models/squad/sf_plates/sf_plate1x1.mdl")
    self:SetModelScale(0.001)
    self:DrawShadow(false)

    GM13.Ent:BlockPhysgun(self, true)
    GM13.Ent:BlockContextMenu(self, true)

    self:SetNWVector("vecA", vecA)
    self:SetNWVector("vecB", vecB)
    self:SetNWInt("width", width)
    self:SetNWInt("height", height)
    self:SetNWBool("initialized", false)
    self:SetNWString("materialName", materialName)

    GM13.Map:SetProtectedEntity(self)
end
