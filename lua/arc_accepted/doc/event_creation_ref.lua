-- This is a reference file for creating events. Several features of this addon are not listed here.

--[[
    The first thing to notice is the way the SandEv loads scripts. Events are located in "lua/gm13/events/tierX",
    where X is an integer starting from 1, and they can even be added by external addons. Subfolders are supported

    The filenames have this pattern of prefixes:
        sh_   =   shared
        sv_   =   server
        cl_   =   client

    The filenames have this pattern of suffixes:
    	_g   =   global. Will load the event on any map
        _t   =   tier. Will load the event only when the correct tier is loaded
        _gt  =   global and tier.

    This means that a file called sv_myevent_g.lua will be loaded server-side and on all maps while the addon
    is active.

    If you are interested in creating libraries inside SandEv, consider that the load order is alphabetical. It
    starts with files and goes to folders, so sub-libraries must be in sub-folders.
]]

-- Now, about creating the event itself:

-- Always set a unique event name
local eventName = "myEvent"

-- Set some variables that are kept when the map is cleared
local saved = false

-- Set some memory dependencies. An event can provide or request memories
-- When a memory is provided, events that require this memory are automatically loaded
GM13.Event.Memory.Dependency:SetProvider(eventName, "myMemory1", "myMemory2", ...)
GM13.Event.Memory.Dependency:SetDependent(eventName, "iNeedMemoryX", "iNeedMemoryY", ...)

-- It's also possible to declare a memory incompatibility and force the event to terminate
-- automatically when this memory is provided.
GM13.Event.Memory.Incompatibility:Set(eventName, "anyMemoryIDontLike", ...)

-- Create your own stuff with as many functions as you need
local function SomeAuxFunc()
    -- Do something
end

-- Create the event main function
local function CreateEvent()
    -- Create custom GM13 entities
    -- The purpose of GM13 entities is to mark areas, make triggers and create sents
    -- Marked areas and triggers can be rendered on the clientside to facilitate development
    local someEnt = ents.Create("gm13_some_ent")
	someEnt:Setup(eventName, "entName", Vector(x,y,z), otherVars)

    -- Create entities and connect them to the event so that they are automatically cleared if the it ends
    local citizen = ents.Create("npc_citizen")
    citizen:Spawn()
    GM13.Event:SetGameEntity(eventName, citizen)

    -- Use SandEv libs to set custom behaviours, such as
    GM13.Ent:BlockPhysgun(ent, value)
    GM13.Ent:BlockTools(ent, ...)
    GM13.Ent:SetInvulnerable(ent, value, callback, ...)
    GM13.Ent:SetReflectDamage(ent, value, callback, ...)
    GM13.Ent:SetMute(ent, value)
    GM13.Ent:FadeIn(ent, fadingTime, callback, ...)
    GM13.Ent:FadeOut(ent, fadingTime, callback, ...)
    GM13.Ent:Dissolve(ent, dissolveType)
    GM13.Ent:CallOnCondition(ent, condition, callback, ...)
    GM13.Ent:BlockContextMenu(ent, value)
    GM13.Ent:SetFakeInvalid(ent, value)
    GM13.Ent:HideInfo(ent, value)
    GM13.Light:SetBurnResistant(ent, value)
    GM13.Light:Burn(ent)
    GM13.Light:FadeOut(ent, callback)
    GM13.Light:FadeIn(ent, callback)
    GM13.Light:Blink(ent, maxTime, finalState, callbackOn, callbackOff, callbackEnd)
    GM13.Map:BlockCleanup(value)
    GM13.NPC:AttackClosestPlayer(npc, duration)
    GM13.NPC:PlaySequences(npc, ...)
    GM13.NPC:CallOnKilled(npc, id, callback, ...)
    GM13.Prop:CallOnBreak(ent, id, callback, ...)
    GM13.Ply:GetClosestPlayer(pos)
    GM13.Ply:BlockNoclip(ply, value)
    GM13.Ply:CallOnSpawn(ply, isOnce, callback, ...)
    CGM13.Vehicle:Break(vehicle, value)
    -- And many more

    -- A common thing in events are triggers, so create and populate them here. E.G.
    local someTrigger = ents.Create("gm13_trigger")
    someTrigger:Setup(eventName, "someTrigger", Vector(-100, -100, 25), Vector(100, 100, 125))

	function someTrigger:StartTouch(ent)
        -- In this case, only accept players
        if not ent:IsPlayer() then return end

        -- Let's set a random chance of activating the event
        if (math.random(1, 100) <= 20) then -- 20%
            ply:Kill() -- Oh no, the player is dead

            -- Now I'm going to set some memories to remember this. We can store any information we
            -- want as long as GMod can save it in JSON and retrieve the values correctly afterwards.
            -- Beware of this conversion, it can be problematic! Documentation:
            -- https://wiki.facepunch.com/gmod/util.TableToJSON
            -- https://github.com/Facepunch/garrysmod-issues/issues/3561
            -- But fear not, it usually works.
            GM13.Event.Memory:Set("firstDeath", anyVariable) 
        end

        -- Call any extra
        SomeAuxFunc()
	end

    -- More touch functions...
    function someTrigger:EndTouch(ent)
        -- Do something
    end
    
    function someTrigger:Touch(ent)
        -- Do something
    end

    -- Besides these things, there's a still unused system that allows for complete integrations
    -- Every time an event is added, removed or started, a GMod hook is fired. This allows other events to react
    -- immediately without needing to fully reload. But be careful! These reactions must ensure consistency of memory
    -- checks or generate momentary situations that don't interfere with the current event's operation. NEVER use these
    -- hooks to create new event parts!! ONLY memories can guarantee correct continuation experiences.

    -- Loaded event
    hook.Add("gm13_add_OtherEvent", "MyHookName1", function()
        -- Adjust memory checks or do something unusual and momentary
    end)

    -- Ran event
    hook.Add("gm13_run_OtherEvent", "MyHookName2", function()
        -- Adjust memory checks or do something unusual and momentary
    end)
    
    -- Unloaded event
    hook.Add("gm13_remove_OtherEvent", "MyHookName3", function()
        -- Adjust memory checks or do something unusual and momentary
    end)

    -- Note: these hooks also work during game startup

    -- We must return true when this function is successful
    return true
end

-- When removing the event it may be necessary to do some cleaning
local function RemoveEvent()
    -- Remove hooks and timers for example 
    timer.Remove("identifier")
    hook.Remove("eventName", "hookName")

    -- We must return true when this function is successful
    return true
end

-- If the event is blocked by missing or incompatible memories, we can also run a callback
local function IgnoreEvent()
    -- Do something

    -- We must return true when this function is successful
    return true
end

-- Link functions to the event system
GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
GM13.Event:SetBlockedByMemoryCall(eventName, IgnoreEvent)
