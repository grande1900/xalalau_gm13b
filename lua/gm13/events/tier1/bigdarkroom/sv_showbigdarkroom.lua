local eventName = "bigDarkShow"

GM13.Event.Memory.Dependency:SetDependent(eventName, "openThePortal", "showBigDarkRoom")

local function ToggleRoom()
    timer.Create("gm13_big_dark_show", 0.2, 100, function()
        local bigDarkRoom = ents.FindByName("BigDarkRoom")[1]

        if not bigDarkRoom.Fire2 then return end

        bigDarkRoom:Fire2("Toggle")

        timer.Create("gm13_toggle_pitstopper", 3, 1, function()
            local pitStopper = ents.FindByName("BigDarkRoomStopper")[1]

            if not pitStopper.Fire2 then return end

            pitStopper:Fire2("Toggle")
        end)

        timer.Remove("gm13_big_dark_show")   
    end)

    return true
end

GM13.Event:SetCall(eventName, ToggleRoom)
GM13.Event:SetDisableCall(eventName, ToggleRoom)