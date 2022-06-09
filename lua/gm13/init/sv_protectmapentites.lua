-- I must protect the func_brush and func_wall_toggle, even 
-- if the curses are off. So don't move this code to an event!
function GM13:ProtectMapEntities()
	if not ISGM13 then return end

	timer.Simple(0.5, function()
		local entNames = {
			"BigDarkRoom",
			"DarkRoomPit",
			"DarkRoomPitWalls",
			"DarkRoomNewFloor",
			"BigDarkRoomStopper",
			"oracleWall",
			"evil_goodbye_trapdoor",
			"evil_goodbye_pit2",
			"evil_hello",
			"seRcret_room",
			"seRcret_room_door"
		}
		
		for k, entName in ipairs(entNames) do
			for k, ent in ipairs(ents.FindByName(entName) or {}) do
				GM13.Map:SetProtectedEntity(ent)
			end
		end
	end)
end
