--[[
    https://wiki.facepunch.com/gmod/Calling_net.Start_with_unpooled_message_name
    "Ideally you'd do this when your Lua files are being loaded - but where that's not
    possible you need to do it at least a couple of seconds before calling the message
    to be sure that it'll work."

    That's why I'm joining the AddNetworkString here. People with VERY slow computers
    have had severe problems with unpooled messages even with me doing extra checks.
]]

-- Addons
util.AddNetworkString("gm13_curse_vc_fireplace")

util.AddNetworkString("gm13_set_spys_night_vision")
util.AddNetworkString("gm13_set_arctics_night_vision")
util.AddNetworkString("gm13_drop_night_vision_goggles")
util.AddNetworkString("gm13_drop_night_vision_goggles_inspired")

-- Effects
util.AddNetworkString("gm13_create_sparks")
util.AddNetworkString("gm13_create_smoke_stream")
util.AddNetworkString("gm13_create_ring_explosion")

-- Events
util.AddNetworkString("gm13_event_set_render_cl")
util.AddNetworkString("gm13_event_Remove_render_cl")
util.AddNetworkString("gm13_event_send_all_render_cl")
util.AddNetworkString("gm13_event_request_all_render_sv")
util.AddNetworkString("gm13_event_remove_all_cl")
util.AddNetworkString("gm13_event_remove_all_ents_cl")
util.AddNetworkString("gm13_event_remove_cl")
util.AddNetworkString("gm13_event_initialize_tier_cl")

-- Memories
util.AddNetworkString("gm13_broadcast_memory")
util.AddNetworkString("gm13_broadcast_memories")
util.AddNetworkString("gm13_ask_for_memories")
util.AddNetworkString("gm13_clear_memories")

-- Lobby
util.AddNetworkString("gm13_lobby_debug_text")

-- Portals
util.AddNetworkString("GM13_PORTALS_FREEZE")

-- Nodraw trigger
util.AddNetworkString("gm13_trigger_nodraw_add_area")
util.AddNetworkString("gm13_trigger_nodraw_remove_area")
util.AddNetworkString("gm13_trigger_nodraw_toggle_area")
util.AddNetworkString("gm13_trigger_nodraw_add_ent")
util.AddNetworkString("gm13_trigger_nodraw_remove_ent")

-- Vacuum event
util.AddNetworkString("gm13_garageVacuum_start_particle_cl")

-- Minge event
util.AddNetworkString("gm13_print_cough")
util.AddNetworkString("gm13_hide_minges")

-- Transmission event
util.AddNetworkString("gm13_minge_attractor_stage")
