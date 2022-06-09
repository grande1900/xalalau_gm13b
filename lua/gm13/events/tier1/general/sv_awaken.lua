local eventName = "generalAwaken"

GM13.Event.Memory.Dependency:SetProvider(eventName, "awaken")
GM13.Event.Memory.Incompatibility:Set(eventName, "awaken")

local function CreateEvent()
    GM13.Event.Memory:Set("awaken", true)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
