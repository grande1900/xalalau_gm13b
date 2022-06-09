local eventName = "darkRoomNewFloor"

GM13.Event.Memory.Dependency:SetDependent(eventName, "openThePortal")

local function CreateEvent()
    timer.Create("gm13_init_dark_room_new_floor", 3, 1, function()
        if not GM13.Event.Memory:Get("openThePortal") then return end -- It can happen if the player closes the game before finishing the first GladosDoll encounter

        local pitDoor = ents.FindByName("DarkRoomPit")[1]
        if pitDoor then
            pitDoor:Remove()

            local darkRoomNewFloor = ents.FindByName("DarkRoomNewFloor")[1]
            darkRoomNewFloor:Fire2("Toggle")
        end
    end)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
