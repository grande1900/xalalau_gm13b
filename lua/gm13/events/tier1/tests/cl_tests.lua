do return end

local eventName = "gm13Tests"

--GM13.Event.Memory.Dependency:SetProvider(eventName, "bla1")
--GM13.Event.Memory.Incompatibility:Set(eventName, "awake")

local function CreateEvent()
    GM13.Lobby.isEnabled = true
    GM13.Lobby.selectedServer = "https://gmc13b2.000webhostapp.com/"
    GM13.Lobby:Join(0.25, 15)

    return true
end

--CreateEvent()
GM13.Event:SetCall(eventName, CreateEvent)


