local eventName = "garageGladosDoll"

local function CreateEvent()
    local gladosDollRemoved = ents.Create("gm13_marker_changed_ent")
    gladosDollRemoved:Setup(eventName, "gladosDollRemoved", Vector(-2946.66, -1384.91, -121.22), Vector(-2933.91, -1366.57, -96.27))

    local GladosDoll = ents.FindByName("GladosDoll")[1]

    if GladosDoll then
        if GM13.Event.Memory:Get("startTesting") then
            GladosDoll:Remove()
        else
            GM13.Ent:SetCursed(GladosDoll, true)
        end
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
