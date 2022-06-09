local eventName = "bigDarkCrazyNPCs"

GM13.Event.Memory.Dependency:SetDependent(eventName, "openThePortal", "showBigDarkRoom")

local function CreateEvent()
    local bigCrazyNPCsTrigger = ents.Create("gm13_trigger_npc_curses")
    bigCrazyNPCsTrigger:Setup(eventName, "bigCrazyNPCsTrigger", Vector(2542.8, 4078.5, -7081.9), Vector(-11247.8, -7663.7, -2176))

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
