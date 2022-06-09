-- Prevent the player from lighting vc fireplace (CLIENT)
-- https://steamcommunity.com/workshop/filedetails/?id=131759821

net.Receive("gm13_curse_vc_fireplace", function()
    GM13.Addon:CurseVJFirePlace(net.ReadEntity())
end)

function GM13.Addon:CurseVJFirePlace(ent)
    ent:SetNW2Bool("VJ_FirePlace_Activated", false)
    ent.FirePlaceOn = false

    if ent.StopParticles then
        ent:StopParticles()
    end

    if VJ_STOPSOUND then
        VJ_STOPSOUND(ent.firesd)
    end

    timer.Simple(2, function()
        if ent:IsValid() then
            ent.Think = function() return end
        end
    end)
end
