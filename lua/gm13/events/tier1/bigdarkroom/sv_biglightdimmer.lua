local eventName = "bigDarkLightDimmer"

GM13.Event.Memory.Dependency:SetDependent(eventName, "openThePortal", "showBigDarkRoom")

local function CreateEvent()
    local bigDimmer = ents.Create("gm13_trigger_light_dimmer")
    bigDimmer:Setup(eventName, "bigDimmer", Vector(2542.8, 4078.5, -7081.9), Vector(-11247.8, -7663.7, -2176))

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
