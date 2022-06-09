--[[
	SandEv - gmc13b custom Sandbox Event System
	'Cause Hammer alone is not enough

	Created by Xalalau Xubilozo, 2021 - 2022
	MIT License
]]

local curMap = game.GetMap()
ISGM13 = curMap == "gm_construct_13_beta"
ISCOMMONMAP = curMap == 'gm_construct' or
			  curMap == 'gm_flatgrass' or
			  curMap == 'gm_bigcity' or
			  curMap == 'gm_bigcity_improved' or
			  curMap == 'gm_genesis' or
			  curMap == 'gm_construct_in_flatgrass' or 
			  curMap == 'gm_ratte_b1' or
			  curMap == 'gm_backrooms' or
			  curMap == 'gm_fork' or
			  curMap == 'gm_construct_redesign' or 
			  curMap == 'gm_novenka'


GM13 = {
	devMode = false, -- The devMode enables access to SandEv's in-game commands and messages. They are used to control, visualize and create events
	bases = { "gm13" }, -- Folders to load events from
	toolCategories = { "GM13 Tools" }, -- Devmove tool categories
	Event = { -- Lib to deal with events
		list = {}, -- { [string event name] = function create event, ... }
		loadingOrder = {}, -- { string event name, ... } -- The load order is the file inclusion order
		customEntityList = {}, -- { [string event name] = { [entity ent] = table entity rendering info, ... }, ... }
		gameEntityList = {}, -- { [string event name] = { [entity ent] = bool, ... }, ... }
		Memory = { -- Lib to remember player map progress
			filename = "gm13/memories.txt", -- Location to save Memories.List
			list = {}, -- { [string memory name] = bool is active, ... } -- Controlled on serverside and copied to clientside
			swaped = {}, -- { [string memory name] = bool is active || var the memory, ... } -- Hold toggled memories values
			Incompatibility = { -- Sublib to block events based on memories
				list = {} -- { [string memory name] = { ["string memory name"] = true, ... }, ... }
			},
			Dependency = { -- Sublib to deal with memory dependencies
				providers = {}, -- { [string event name] = { ["string memory name"] = true, ... } } -- Events that provide memories
				dependents = {} -- { [string event name] = { ["string memory name"] = true, ... } } -- Events that require memories
				-- The above two tables above when crossed produce a dependency logic and evidence errors.
			}
		},
	},
	Addon = {}, -- General addons support
	Custom = {},
	Effect = {},
	Ent = {},
	Light = {},
	Map = {
		nodesFolder = "nodes",
		nodesCacheFilename = "gm13/nodes/" .. game.GetMap() .. "_nodes.txt", -- Location to save the map node positions
		nodesList, -- { [int index] = Vector position, ... } -- Map node positions
		blockCleanup = false
	},
	Lobby = {},
	NPC = {},
	Ply = {},
	Portals = {
		portalIndex = 0,
		enableFunneling = false
	},
	Prop = {},
	Tool = {
		categoriesPanel,
		categoryNames = {},
		categoryControllers = {}
	}
}

if SERVER then
	GM13.Event.lastSentChunksID = nil -- str -- Internal. Prevent older chunks from being uploaded if the map is reloaded

	-- Lobby system (lua/gm13/base/sv_lobby.lua):
	GM13.Lobby.servers = { -- We can have multiple server links
		"https://gmc13b.xalalau.com/"
	}
	-- SomeDB1 = gmc13b, SomeDB2 = common maps, SomdeDB3 = rare maps.
	GM13.Lobby.selectedServerDB = ISGM13 and "1" or ISCOMMONMAP and "2" or "3"
	GM13.Lobby.version = "3"
	GM13.Lobby.isEnabled = false
	GM13.Lobby.selectedServerLink = nil
	GM13.Lobby.lobbyChecksLimit = ISGM13 and 10 or 45
	GM13.Lobby.lobbyChecks = 0
	GM13.Lobby.isNewEntry = true
	GM13.Lobby.gameID = math.random(1, 999999) -- Used to identify multiple GMod instances
	GM13.Lobby.printResponses = false -- Flood the console with information returned from the server
end 

if CLIENT then
	GM13.Event.renderEvent = {} -- { [string event name] = { enabled = bool should render event, [string entID] = { entRenderInfo }, ... } }

	GM13.Lobby.lastPercent = 0

	-- Spy's Night Vision:
	GM13.Addon.spysNightVision = true
	GM13.Addon.NV_ToggleNightVision = nil
end

-- Improve random number generation
math.randomseed(os.time())

-- Particles
game.AddParticles("particles/train_steam.pcf")
PrecacheParticleSystem("steam_train")

-- Decals
game.AddDecal("justamissingtexture", "13beta/justamissingtexture")

-- Include code

-- Prefixes:
local prefixes = {
	"sh_",
	"sv_",
	"cl_"
}

--[[
	Suffixes (optional):

	_g   =   global. Will load the event on any map
	_t   =   tier. Will load the event only when the correct tier is loaded
	_gt  =   global and tier.
]]

-- Load source files
local function HandleFile(filePath, prefix)
	if SERVER then
		if prefix ~= "cl_" then
			include(filePath)
		end

		if prefix ~= "sv_" then
			AddCSLuaFile(filePath)
		end
	end

	if CLIENT then
		if prefix ~= "sv_" then
			include(filePath)
		end
	end
end

local function ReadDir(dir, prefix, isCurrentTier, ignoreSuffixes)
	local files, dirs = file.Find(dir .. "*", "LUA")
	local selectedFiles = {}

	-- Separate files by type
	for _, file in ipairs(files) do
		if string.sub(file, -4) == ".lua" then
			local filePath = dir .. file

			if string.sub(file, 0, 3) == prefix then
				table.insert(selectedFiles, filePath)
			end
		end
	end

	-- Load separated files
	for _, filePath in ipairs(selectedFiles) do
		-- Check suffixes
		if not ignoreSuffixes then
			if ISGM13 then
				if (string.find(filePath, "_t.", 1, true) or string.find(filePath, "_gt.", 1, true)) and not isCurrentTier then continue end 
			else
				if string.find(filePath, "_gt.", 1, true) then
					if not isCurrentTier then continue end 
				else
					if not string.find(filePath, "_g.", 1, true) then continue end
				end
			end
		end

		HandleFile(filePath, prefix)
	end

	-- Open the next directory
	for _, subDir in ipairs(dirs) do
		ReadDir(dir .. subDir .. "/", prefix, isCurrentTier, ignoreSuffixes)
	end
end

function GM13:IncludeFiles(folder, isCurrentTier, ignoreSuffixes)
	for _, prefix in ipairs(prefixes) do
        ReadDir(folder, prefix, isCurrentTier, ignoreSuffixes)
    end
end

function GM13:IncludeBase(base)
	table.insert(GM13.bases, base.luaFolder)

	if CLIENT then
		GM13:RegisterToolCategories(base)
	end
end

-- Init functions
GM13:IncludeFiles(GM13.bases[1] .. "/init/", nil, true)

-- Protect map entities after cleanups
if SERVER then
	hook.Add("PostCleanupMap", "gm13_protect_togglable", function()
		GM13:ProtectMapEntities()
	end)
end

-- Event initialization
hook.Add("InitPostEntity", "gm13_init", function()
	file.CreateDir(GM13.bases[1] .. "/" .. GM13.Map.nodesFolder)

	if CLIENT then
		GM13:RegisterToolCategories(GM13)
	end

	for k, base in ipairs(GM13.bases) do
		file.CreateDir(base)
		GM13:IncludeFiles(base .. "/libs/", nil, true)
	end

	if GM13.devMode then
		GM13:EnableDevMode()
	end

	if SERVER then
		GM13:ProtectMapEntities()

		if ISGM13 then
			timer.Simple(1, function()
				GM13.Addon:BlindEntInfoAddons()
			end)
		end

		GM13.Map:LoadGroundNodes()
		GM13.Event.Memory:Load()
		GM13.Event:InitializeTier()
	end

	if CLIENT then
		-- I'm checking when one of my nets becomes available and assuming they all will be at that time.
		net.Start("gm13_ask_for_memories")
		net.SendToServer()

		if ISGM13 then
			timer.Simple(0.4, function() -- Just to be sure
				GM13.Addon:StealSpysNightVisionControl()
				GM13.Addon:BlindEntInfoAddons()
			end)
		end

		timer.Remove("gm13_wait_until_old_computers_include_files")

		hook.Add("gm13_memories_received", "gm13_initialize_cl_events", function()
			GM13.Event:InitializeTier()
		end)
	end
end)
