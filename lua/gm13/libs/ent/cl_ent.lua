-- Context menu

local _propertiesGetHovered = properties.GetHovered
function properties.GetHovered(eyepos, eyevec)
    local ent, tr = _propertiesGetHovered(eyepos, eyevec)

    if ent and (GM13.Ent:IsContextMenuBlocked(ent) or GM13.Ent:IsContextMenuBlocked(ent, LocalPlayer())) then
        ent = nil
    end

    return ent, tr
end