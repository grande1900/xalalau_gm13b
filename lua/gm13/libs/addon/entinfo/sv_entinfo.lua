-- Entity Info
-- https://steamcommunity.com/sharedfiles/filedetails/?id=500527779
local function BlindEntInfoAddons()
    if not DrawInfo then return end

    function DrawInfo()
        for k, v in pairs(player.GetAll()) do
            if not v:GetNWBool("PhysPickup") then
                local tr = util.GetPlayerTrace(v, v:GetAimVector())
                local trace = util.TraceLine(tr)
                if not trace.Hit then v:SetNWBool("AimingAtEntity", false); return end
                if not trace.HitNonWorld then v:SetNWBool("AimingAtEntity", false); return end
                local ent = trace.Entity
                if GM13.Ent:IsInfoHidden(ent) then return end
                v:SetNWEntity("AimingAt", ent)
                v:SetNWBool("AimingAtEntity", true)
            end
        end
    end

    local _DrawInfoPhysPickup = DrawInfoPhysPickup

    function DrawInfoPhysPickup(ply, ent)
        if GM13.Ent:IsInfoHidden(ent) then return end
        _DrawInfoPhysPickup(ply, ent)
    end

    hook.Add("PhysgunPickup", "EntInfoDraw", DrawInfoPhysPickup)
    hook.Add("Think", "EntInfoDraw", DrawInfo)
end

-- Hide protected map entities from other addons
function GM13.Addon:BlindEntInfoAddons()
    BlindEntInfoAddons()
end