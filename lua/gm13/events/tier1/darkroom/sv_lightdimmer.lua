local eventName = "darkRoomLightDimmer"

local function CreateEvent()
    local areas = {
        { Vector(-5471.9, -2574.4, -16.8), Vector(-5280.8, -2329.1, -143.9) },
        { Vector(-5244.9, -2506.5, -2.5), Vector(-5280.3, -2386.4, -143.9) },
        { Vector(-3248, -1933.3, -143.6), Vector(-2448.6, -1060, 207.9) },
        { Vector(-4244.8, -1750.1, -143.9), Vector(-5247.8, -1056.2, 159.9) },
        { Vector(-4244.8, -1750.1, -143.9), Vector(-5247.1, -2558.2, 159.9) },
        { Vector(-4244.8, -1750.1, -143.9), Vector(-3249.3, -2559.8, 159.9) },
        { Vector(-4244.8, -1750.1, -143.9), Vector(-3248.1, -1056.5, 159.9) }
    }

    for k, areaVecs in ipairs(areas) do
        local dimmer = ents.Create("gm13_trigger_light_dimmer")
        dimmer:Setup(eventName, "dimmer_" .. k, areaVecs[1], areaVecs[2])
    end

    local cone = ents.FindByName("dark_room_pspotl")[1]
    local light = ents.FindByName("dark_room_lspot")[1]

    if cone and cone:IsValid() then
        GM13.Light:SetBurnResistant(cone, true)
    end

    if light and light:IsValid() then
        GM13.Light:SetBurnResistant(light, true)
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
