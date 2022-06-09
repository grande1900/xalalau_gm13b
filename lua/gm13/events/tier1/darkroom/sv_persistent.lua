local eventName = "darkRoomPersistent"

local function CreateEvent()
    local persistentArea = ents.Create("gm13_trigger_persistent")
    persistentArea:Setup(eventName, "darkRoomPersistentArea", Vector(-3248.03, -2559.69, 159.34), Vector(-5245.81, -1057.97, -143.97))

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
