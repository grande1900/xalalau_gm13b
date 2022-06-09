local eventName = "darkRoomCrazyDrones"

local fleeVecs = {
    Vector(-1545.5, -994.9, -143.9),
    Vector(-242.8, -1543.4, -143.9),
    Vector(-2018.5, -2163.6, 256)
}

local function CreateEvent()
    local curseAreas = {
        { Vector(-5246.6, -1057.7, 159.9), Vector(-3249.2, -2558.8, -160) },
        { Vector(-3248, -1856.5, -32), Vector(-2815.5, -1123.1, -143.9) },
        { Vector(-5296, -2821, 146.5), Vector(-5469.5, -2072.4, -143.9) }
    }

    for k, posTab in ipairs(curseAreas) do
        local crazyDronesTrigger = ents.Create("gm13_trigger_drone_curses")
        crazyDronesTrigger:Setup(eventName, "crazyDronesTrigger" .. k, posTab[1], posTab[2])
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
