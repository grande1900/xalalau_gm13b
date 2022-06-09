-- Trigger to teleport entities

ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:Initialize()
    GM13.Event:SetRenderInfoEntity(self)
end

function ENT:Setup(eventName, entName, vecA, vecB, filter, target)
    self:Spawn()

    self:SetVar("eventName", eventName)
    self:SetVar("entName", entName)
    self:SetVar("vecA", vecA)
    self:SetVar("vecB", vecB)
    self:SetVar("vecCenter", (vecA - vecB)/2 + vecB)
    self:SetVar("color", Color(252, 119, 3, 255)) -- Orange

    self:SetName(entName)

    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBoundsWS(vecA, vecB)
    self:SetTrigger(true)

    -- everything, npc, bot, player, invehicle, prop
    local filter = {}
    for _,v in pairs(filter or {}) do
        filter[v] = true
    end

    self:SetVar("filter", filter)
    self:SetVar("target", target)

    GM13.Ent:SetCursed(self, true)
end

function ENT:StartTouch(ent)
    if not ent:IsValid() then return end
    local filter = self:GetVar("filter")

    if filter.everything or
       filter.player and ent:IsPlayer() or
       filter.npc and ent:IsNPC() or
       filter.bot and ent:IsBot() or
       filter.prop and ent:GetClass() and string.find(ent:GetClass(), "prop_")
       then

        if ent.Health then
            if ent.InVehicle and ent:InVehicle() and not filter.vehicle then
                return
            end

            local destiny = ents.FindByName(self:GetVar("target"))[1]

            if destiny and destiny:IsValid() then
                ent:SetPos(destiny:GetPos())
            end
        end
    end
end
