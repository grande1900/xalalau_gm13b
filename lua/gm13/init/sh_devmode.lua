function GM13:EnableDevMode()
	GM13.devMode = true

	concommand.Add("gm13_events_toggle", function(ply, cmd, args) GM13.Event:Toggle(ply, cmd, args) end)
    concommand.Add("gm13_events_list", function() GM13.Event:List() end)
    concommand.Add("gm13_memories_toggle", function(ply, cmd, args) GM13.Event.Memory:Toggle(ply, cmd, args) end)
    concommand.Add("gm13_memories_list", function() GM13.Event.Memory:List() end)
    concommand.Add("gm13_memories_print_logic", function() GM13.Event.Memory.Dependency:PrintLogic(GM13.Event.Memory.Dependency:GeLayers()) end)

    if CLIENT then
        net.Start("gm13_event_request_all_render_sv")
        net.SendToServer()

        CreateClientConVar("gm13_events_show_names", "0", true, false)
        CreateClientConVar("gm13_events_render_auto", "0", true, false)
		GM13.Portals.VarDrawDistance = CreateClientConVar("gm13_portal_drawdistance", "3500", true, false, "Sets the size of the portal along the Y axis", 0)

        concommand.Add("gm13_events_render", function(ply, cmd, args) GM13.Event:ToggleRender(ply, cmd, args) end)
        concommand.Add("gm13_events_render_list", function() GM13.Event:ListRender() end)
    end
end

function GM13:DisableDevMode()
	GM13.devMode = false

	concommand.Remove("gm13_events_toggle")
	concommand.Remove("gm13_events_list")
	concommand.Remove("gm13_memories_toggle")
	concommand.Remove("gm13_memories_list")
	concommand.Remove("gm13_memories_print_logic")

    if CLIENT then
		concommand.Remove("gm13_events_render")
		concommand.Remove("gm13_events_render_list")

		-- Apparently we can't remove cvars.
    end
end

if SERVER then
	function GM13:ToggleDevMode()
		local toggleFuncName = GM13.devMode and "DisableDevMode" or "EnableDevMode"

		GM13[toggleFuncName]()

		for k, ply in ipairs(player.GetHumans()) do
			ply:SendLua("GM13['" .. toggleFuncName .. "']()")
		end

		print("GM13 devmode is " .. (GM13.devMode and "On" or "Off"))
	end

	concommand.Add("devmode_gm13_toggle", function() GM13:ToggleDevMode() end)
end