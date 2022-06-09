local eventName = "darkRoomTrapdoor"

local function CreateTrapdoor()
    local trapdoorTrigger = ents.Create("gm13_trigger")
    trapdoorTrigger:Setup(eventName, "trapdoorTrigger", Vector(-2917, -1519.9, -137.4), Vector(-2938.9, -1424, -33.8))

	function trapdoorTrigger:StartTouch(ent)
        if ent:IsPlayer() and math.random(1, 100) <= 11 then
            -- I don't have the patience to port this event from Hammer. It was one of the first 10 and will mostly stay there.
            ents.FindByName("cursed_stuff_old")[1]:Fire("PickRandom")
        end
	end

    return true
end

GM13.Event:SetCall(eventName, CreateTrapdoor)
