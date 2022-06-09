local eventName = "generalTransmission"

GM13.Event.Memory.Dependency:SetProvider(eventName, "transmission1", "transmission2", "transmission3", "mingeAttractor")
GM13.Event.Memory.Dependency:SetDependent(eventName, "ratmanReady")

local function CreateCCon(areaTab, radio)
    if GM13.Event.Memory:Get("helpMeBrother") then return end

    concommand.Add("2796-1646-20", function(ply, cmd, args)
        concommand.Remove("2796-1646-20")

        if not GM13.Event.Memory:Get(areaTab.setMemory) then
            return
        end

        ply.gm13_submarine_cvar_teleport = true
        ply:SetPos(Vector(-5070.5, -1226.4, -143.9))
        ply:SetAngles(Angle(0, 135, 0))
        ply:SetEyeAngles(Angle(0, 135, 0))

        timer.Simple(1, function()
            if not ply:IsValid() then return end

            ply.gm13_submarine_cvar_teleport = false
        end)
    end)

    if not GM13.Event.Memory:Get(areaTab.setMemory) then
        GM13.Event.Memory:Set(areaTab.setMemory, true)
    end

    hook.Add("gm13_reset", "gm13_remove_grigori_ccon", function()
        concommand.Remove("2796-1646-20")
    end)
end

local function CreateGladosDollAlive(areaTab, radio)
    if not GM13.Event.Memory:Get(areaTab.setMemory) then
        local doll = ents.Create("prop_dynamic")
        GM13.Event:SetGameEntity(eventName, doll)
        GM13.Ent:BlockToolgun(doll, true)
        GM13.Ent:BlockPhysgun(doll, true)
        GM13.Ent:BlockContextMenu(doll, true)

        doll:SetPos(Vector(-530.4, 1463, -240.2))
        doll:SetAngles(Angle(0, 270, 0))
        doll:SetModel("models/maxofs2d/companion_doll.mdl")
        doll:SetMaterial("models/props_c17/paper01")
        doll:Spawn()
        doll:EmitSound("vo/npc/female01/help01.wav")

        GM13.Ent:FadeIn(doll, 0.2, function()
            if not doll:IsValid() then return end

            GM13.Ent:FadeOut(doll, 0.9, function()
                if not doll:IsValid() then return end

                doll:Remove()
            end)
        end)

        GM13.Event.Memory:Set(areaTab.setMemory, true)
    end

    timer.Simple(1, function()
        local delay = 0
        local entIndex = 1

        local ent = ents.FindByName("tunnels_lc" .. entIndex)
        local blinkingEnts

        while #ent > 0 do
            local light = ent[1]
            local lightBack = ents.FindByName("tunnels_lc" .. entIndex .. "_back")[1]
            delay = delay + math.random(0.2, 0.4)  

            timer.Simple(delay, function()
                if not light:IsValid() then return end

                light:Fire("TurnOff")
                light:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 90)
                lightBack:SetSkin(0)
                net.Start("gm13_create_sparks")
                net.WriteVector(light:GetPos())
                net.Broadcast()
            end)

            if entIndex == 7 then
                blinkingEnts = { light, lightBack }
            end

            entIndex = entIndex + 1
            ent = ents.FindByName("tunnels_lc" .. entIndex)
        end

        timer.Simple(delay + 0.2, function()
            if not istable(blinkingEnts) or not blinkingEnts[1]:IsValid() or not blinkingEnts[2]:IsValid() then return end

            GM13.Light:Blink(blinkingEnts[1], 1.5, false,
            function()
                blinkingEnts[1]:Fire("TurnOn")
                blinkingEnts[2]:SetSkin(1)
            end,
            function()
                blinkingEnts[1]:Fire("TurnOff")
                blinkingEnts[2]:SetSkin(0)
            end)
        end)        
    end)
end

local function StartOraceInterference(areaTab, radio)
    hook.Run("gm13_oracle_interference")
end

local function FinishOraceInterference(areaTab, radio)
    timer.Simple(0.3, function()
        if not radio:IsValid() then return end

        local explo = ents.Create("env_explosion")
        explo:SetPos(radio:GetPos())
        explo:Spawn()
        explo:Fire("Explode")
        explo:SetKeyValue("IMagnitude", 20)

        local ply = GM13.Ply:GetClosestPlayer(radio:GetPos())

        if ply then
            ply:Ignite(4, 200)
        end
    end)
end

local function StartBigDarkRoomInterference(areaTab, radio)
    timer.Simple(0.3, function()
        if not radio:IsValid() then return end

        local explo = ents.Create("env_explosion")
        explo:SetPos(radio:GetPos())
        explo:Spawn()
        explo:Fire("Explode")
        explo:SetKeyValue("IMagnitude", 20)

        local ply = GM13.Ply:GetClosestPlayer(radio:GetPos())

        if ply then
            ply:Ignite(4, 200)
        end

        radio:SetPos(radio:GetVar("vecCenter"))
    end) 
end

local function EndBuildingCRoofTransmission(areaTab, radio)
    if not radio:IsValid() then return end
    if GM13.Event.Memory:Get(areaTab.setMemory) then return end

    GM13.Event.Memory:Set(areaTab.setMemory, true)

    radio:EmitSound("ambient/atmosphere/thunder4.wav")
    radio:EmitSound("ambient/explosions/exp4.wav")
    radio:EmitSound("ambient/explosions/explode_2.wav")

    local startPos = radio:GetPos()

    local function StartFireTornado()
        local spread = 2000
        local height = 2000
        local rate = 100
        local size = 450
        local start = 1
        local delay = 5.5
        
        for i = 1, 20 do
            spread = spread * 0.9
            height = height - 100
            rate = rate * 0.9
            size = size * 0.95
            start = start + 0.1
            delay = delay + 0.07

            local fireTornado = ents.Create("env_smokestack")
            fireTornado:SetKeyValue("smokematerial", "effects/fire_cloud2.vmt")
            fireTornado:SetKeyValue("rendercolor", "255 100 100")
            fireTornado:SetKeyValue("targetname", "fireTornado")
            fireTornado:SetKeyValue("basespread", spread)
            fireTornado:SetKeyValue("spreadspeed", "10")
            fireTornado:SetKeyValue("speed", "100")
            fireTornado:SetKeyValue("startsize", size)
            fireTornado:SetKeyValue("endzide", size)
            fireTornado:SetKeyValue("rate", rate)
            fireTornado:SetKeyValue("jetlength", "100")
            fireTornado:SetKeyValue("twist", "900")
            fireTornado:Spawn()
            fireTornado:Fire("turnon", "", start)
            fireTornado:Fire("Kill", "", delay)
            fireTornado:SetPos(startPos + Vector(0, 0, height))
        end
    end

    timer.Create("gm13_start_fire_tornado", 0.1, 2, StartFireTornado)

    local shaker = ents.Create("env_shake")
    shaker:SetKeyValue("amplitude", "140")
    shaker:SetKeyValue("radius", "10000")
    shaker:SetKeyValue("duration", "5.6")
    shaker:SetKeyValue("frequency", "100")
    shaker:SetKeyValue("spawnflags", "8")
    shaker:Spawn()
    shaker:Fire("startshake", "", 0)
    shaker:Fire("Kill", "", 6)
    shaker:SetPos(startPos)

    timer.Create("gm13_radio_minge_explosions", 0.1, 30, function()
        local x = math.random(-500, 500)
        local y = math.random(-500, 500)
        local z = math.random(0, 550)
        local radius = math.random(10, 40) * .1

        local explo = ents.Create("env_explosion")
        explo:SetPos(startPos + Vector(x, y, z))
        explo:SetKeyValue("iMagnitude", "100")
        explo:Spawn()
        explo:Fire("explode", "", radius)
        explo:Fire("kill", "", 1 + radius)
    end)

    local lightning  = ents.Create("env_laser")
    lightning:SetKeyValue("lasertarget", "radio")
    lightning:SetKeyValue("renderamt", "255")
    lightning:SetKeyValue("renderfx", "15")
    lightning:SetKeyValue("rendercolor", "0 100 255")
    lightning:SetKeyValue("texture", "sprites/laserbeam.spr")
    lightning:SetKeyValue("texturescroll", "35")
    lightning:SetKeyValue("dissolvetype", "1")
    lightning:SetKeyValue("spawnflags", "32")
    lightning:SetKeyValue("width", "15")
    lightning:SetKeyValue("damage", "50000")
    lightning:SetKeyValue("noiseamplitude", "10")
    lightning:Spawn()
    lightning:Fire("Kill", "", 2)
    lightning:Fire("turnon", "", 1)
    lightning:SetPos(startPos + Vector(0, 0, 2000))

    local hurt = ents.Create("point_hurt")
    hurt:SetPos(startPos)
    hurt:SetKeyValue("DamageRadius", "250")
    hurt:SetKeyValue("Damage", "60")
    hurt:SetKeyValue("DamageDelay", "0.01")
    hurt:SetKeyValue("DamageRadius", "700")
    hurt:SetKeyValue("DamageType", "8")
    hurt:Fire("turnon", "", 1)
    hurt:Fire("kill", "", 2)
    hurt:Spawn()
end

local function StartMadGrigory(areaTab, radio)
    -- Tier 2 stuff
end

local function RunStartCallback(areaTab, radio)
    if areaTab.setMemory and GM13.Event.Memory:Get(areaTab.setMemory) then return end
    if not areaTab.startCallback then return end

    areaTab.startCallback(areaTab, radio)
end

local function RunEndCallback(areaTab, radio)
    if not areaTab.endCallback then return end

    areaTab.endCallback(areaTab, radio)
end

local function FinishTransmission(area, ambientSound, wallHole, areaTab, radioSounds, delay, isSettingUp)
    if areaTab.setMemory and not GM13.Event.Memory:Get(areaTab.setMemory) then return end
    if not areaTab.setMemory and isSettingUp then return end

    if wallHole and wallHole:IsValid() then
        GM13.Event:RemoveRenderInfoEntity(wallHole)
        wallHole:Remove()
    end

    if areaTab.addSoundAfterComplete and radioSounds then
        table.insert(radioSounds, areaTab.broadcast)
    end

    if areaTab.disableTrigger and area and area:IsValid() then
        GM13.Event:RemoveRenderInfoEntity(area)
        area:Remove()
    end

    if areaTab.decal then
        timer.Simple(delay, function() -- Usefull when the game starts
            if not ambientSound or not ambientSound:IsValid() then return end

            ambientSound:EmitSound("ambient/atmosphere/indoor2.wav", 45)
        end)
    end

    return true
end

local function SetupTransmission(areaName, areaTab, radio, isGM13Transmission)
    if not (areaTab.tier <= GetConVar("gm13_tier"):GetInt()) then return end
    if isGM13Transmission and not ISGM13 or not isGM13Transmission and ISGM13 then return end

    local area
    local ambientSound
    
    if not isGM13Transmission and not ISGM13 or isGM13Transmission and ISGM13 then
        area = ents.Create("gm13_trigger")
        area:Setup(eventName, "radio_" .. areaName, areaTab.trigger[1], areaTab.trigger[2])
        
        if areaTab.decal then
            ambientSound = ents.Create("gm13_marker")
            ambientSound:Setup(eventName, "ambientSound_" .. areaName, areaTab.decal.pos)
        end
    end

    if FinishTransmission(area, ambientSound, nil, areaTab, radio.radioSounds, 2, true) then
        RunEndCallback(areaTab, radio)
        return
    end

    if not radio:GetVar("isReady") then
        radio:Setup(eventName, Vector(1989.9, 3460.1, -107.6), Vector(2007.4, 3433.1, -90.4))
        radio:Spawn()
    end

    local wallHole

    if areaTab.decal then
        wallHole = ents.Create("gm13_func_sprite")
        wallHole:Setup(eventName, "wallHole_" .. areaName, areaTab.decal.pos, 128, 128, areaTab.decal.ang, "13beta/transmission_hole")
    end

    if not area then return end

    function area:StartTouch(ent)
        if not ent.gm13_radio then return end

        local isEnabled = true
        if areaTab.requireMemory and not GM13.Event.Memory:Get(areaTab.requireMemory) then
            isEnabled = false
        end

        if isEnabled and ent.playing and ent.playing == ent.main then
            ent.broadcasting = areaTab.broadcast
        else
            ent.broadcasting = "gm13/radio/buzz.wav"
        end

        if timer.Exists("gm13_finish_main_radio") then
            timer.Remove("gm13_finish_main_radio")
        end

        if ent.playing then
            ent:StopSound(ent.playing)
        end
        ent:EmitSound(ent.broadcasting)

        local duration = SoundDuration(ent.broadcasting)

        timer.Simple(duration, function()
            if not ent:IsValid() or not ent.broadcasting or ent.broadcasting == "gm13/radio/buzz.wav" then return end

            RunEndCallback(areaTab, radio)
            FinishTransmission(area, ambientSound, wallHole, areaTab, radio.radioSounds, 0, false)

            ent:StopSound(ent.broadcasting)

            timer.Simple(3, function()
                if not ent.broadcasting then return end
                if not ent:IsValid() then return end

                ent.broadcasting = nil

                ent:EmitSound(ent.playing)
            end)
        end)

        RunStartCallback(areaTab, radio)
    end

    function area:EndTouch(ent)
        if not ent.gm13_radio then return end
        if not ent.broadcasting then return end

        ent:StopSound(ent.broadcasting)
        ent.broadcasting = nil
 
        if ent.playing then
            if ent.playing ~= ent.main and not string.find(ent.playing, "radio_random") then
                ent.playing = "ambient/levels/prison/radio_random1.wav"
            end

            ent:EmitSound(ent.playing)
        end
    end
end

local function CreateEvent()
    util.PrecacheModel("models/props_lab/citizenradio.mdl")
    util.PrecacheModel("models/maxofs2d/companion_doll.mdl")

    local radio = ents.Create("gm13_sent_radio")

    local radioBadSounds = {}

    for i = 1, 7 do
        table.insert(radioBadSounds, "ambient/levels/prison/radio_random" .. i .. ".wav")
    end

    local GM13TransmissionAreas = {
        submarine = {
            trigger = {
                Vector(1984, 5512.8, -114.5),
                Vector(1986.4, 5541.9, -167.9)
            },
            decal = {
                pos = Vector(1986, 5529, -122.3),
                ang = Angle(0, 90, 0)
            },
            broadcast = "gm13/radio/transmission1.wav",
            addSoundAfterComplete = true,
            disableTrigger = true,
            endCallback = CreateCCon,
            setMemory = "transmission1",
            tier = 1
        },
        tunnels = {
            trigger = {
                Vector(-517.1, 1469.5, -303.9),
                Vector(-539.2, 1471.9, -255.7)
            },
            decal = {
                pos = Vector(-527.2, 1471.9, -267.4),
                ang = Angle(0, 0, 0)
            },
            broadcast = "gm13/radio/transmission2.wav",
            addSoundAfterComplete = false,
            disableTrigger = true,
            endCallback = CreateGladosDollAlive,
            setMemory = "transmission2",
            tier = 1
        },
        garage = {
            trigger = {
                Vector(-2081.8, -2494.6, -254.9),
                Vector(-2055.8, -2475.3, -255.9)
            },
            decal = {
                pos = Vector(-2068.9, -2484.6, -255.9),
                ang = Angle(0, 0, 90)
            },
            broadcast = "music/ravenholm_1.mp3",
            addSoundAfterComplete = true,
            disableTrigger = true,
            endCallback = StartMadGrigory,
            setMemory = "transmission3",
            tier = 2
        },
        darkRoom = {
            trigger = {
                Vector(-5246.6, -1057.7, 159.9),
                Vector(-3249.2, -2558.8, -160)
            },
            broadcast = "ambient/levels/streetwar/city_riot2.wav",
            addSoundAfterComplete = false,
            disableTrigger = true,
            tier = 1
        },
        oracle = {
            trigger = {
                Vector(-2155.7, -2485.9, 157.7),
                Vector(-2310.7, -2464.1, 40)
            },
            broadcast = "ambient/levels/citadel/zapper_warmup1.wav",
            addSoundAfterComplete = false,
            disableTrigger = false,
            startCallback = StartOraceInterference,
            endCallback = FinishOraceInterference,
            tier = 1
        },
        bigDarkRoom = {
            trigger = {
                Vector(2542.8, 4078.5, -7081.9),
                Vector(-11247.8, -7663.7, -2176)
            },
            broadcast = radioBadSounds[math.random(1, #radioBadSounds)],
            addSoundAfterComplete = false,
            disableTrigger = false,
            startCallback = StartBigDarkRoomInterference,
            tier = 1
        },
        buildingCRoof = {
            trigger = {
                Vector(-4940.31, 5962.91, 2894.32),
                Vector(-3984.94, 4684.22, 2496.03)
            },
            broadcast = "gm13/radio/mingev2glitch.wav",
            addSoundAfterComplete = true,
            disableTrigger = true,
            setMemory = "mingeAttractor",
            endCallback = EndBuildingCRoofTransmission,
            tier = 1
        }
    }
    
    for areaName, areaTab in pairs(GM13TransmissionAreas) do
        SetupTransmission(areaName, areaTab, radio, true)
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
