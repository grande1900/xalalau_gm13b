local eventName = "bigDarkConfinement"

GM13.Event.Memory.Dependency:SetDependent(eventName, "showBigDarkRoom")

local function CreateEvent()
    local confinementAreas = {
        { Vector(2542.8, 4078.5, -7081.9), Vector(-11247.8, -7663.7, -2176) },
        { Vector(-5248, -2560, -164), Vector(-3210, -990, -2160) },
        { Vector(-4992.45, -2300.19, -143.97), Vector(-3509.25, -1242.25, 159.97) }
    }

    for k, areaTab in ipairs(confinementAreas) do
        local bigConfinement = ents.Create("gm13_trigger_ply_confinement")
        bigConfinement:Setup(eventName, "bigConfinement" .. k, areaTab[1], areaTab[2], "gm13_big_dark_confinement")

        GM13.Event:SetGameEntity(eventName, bigConfinement)
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)