local eventName = "buildingBOracle"
local isNoisy = false
local isToggled = false
local props = {}
local ambientSound = "gm13/ambient/oracle.wav"

hook.Add("PostCleanupMap", "gm13_refresh_oracle", function()
    isNoisy = false
    isToggled = false
    props = {}
end)

local function FinishOracle(oracleWall, oracleSound)
    isToggled = false

    if not oracleWall:IsValid() then return end

    if oracleSound:IsValid() then
        oracleSound:StopSound(ambientSound)
    end

    local delay = isNoisy and 0.2 or 7

    GM13.Ent:FadeOut(oracleWall, delay, function()
        if not oracleWall:IsValid() then return end

        oracleWall:SetColor(Color(255, 255, 255, 0))
    end)
    
    for k, prop in ipairs(props) do
        GM13.Ent:FadeOut(prop, delay, function()
            if not prop:IsValid() then return end

            prop:Remove()
        end)
    end

    timer.Remove("gm13_oracle_finish")
end

local function AddInterferenceHook(oracleWall, oracleSound)
    hook.Add("gm13_oracle_interference", "StartInterference", function()
        if isNoisy then return end
        isNoisy = true

        oracleWall:SetColor(Color(255, 255, 255, 255))

        timer.Create("gm13_start_interference", 0.05, 40, function()
            if not oracleWall:IsValid() then return end

            oracleWall:SetMaterial("13beta/oracle/interference" .. math.random(1, 12))

            if timer.RepsLeft("gm13_start_interference") == 0 then
                FinishOracle(oracleWall, oracleSound)
                isNoisy = false
            end
        end)
    end)
end

local function CreateProp(modelList, pos, ang, blockContact)
    local prop = ents.Create("prop_dynamic")
    prop:SetModel(modelList[math.random(1, #modelList)])
    prop:SetPos(pos)
    prop:SetAngles(ang)
    prop:Spawn()
    prop:PhysicsInit(SOLID_VPHYSICS)
    prop:SetMoveType(MOVETYPE_VPHYSICS)
    prop:SetSolid(SOLID_VPHYSICS)

    local phys = prop:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    GM13.Event:SetGameEntity(eventName, prop)
    GM13.Ent:BlockToolgun(prop, true)
    GM13.Ent:BlockContextMenu(prop, true)

    if blockContact then
        GM13.Ent:BlockPhysgun(prop, true)

        timer.Simple(2, function()
            if not prop:IsValid() then return end

            prop:PhysicsDestroy()
            prop:SetNotSolid(true)
        end)
    end

    GM13.Ent:FadeIn(prop, 3)

    return prop
end

local function SpawnTrash(propMarker1, propMarker2, propMarker3)
    local trashModels = {
        "models/props_junk/garbage128_composite001a.mdl",
        "models/props_junk/garbage128_composite001b.mdl"
    }

    local objectModels = {
        "models/props_lab/clipboard.mdl",
        "models/props_junk/MetalBucket01a.mdl",
        "models/props_junk/Shoe001a.mdl",
        "models/props_c17/BriefCase001a.mdl",
        "models/props_c17/doll01.mdl",
        "models/props_junk/PlasticCrate01a.mdl",
        "models/props_junk/garbage_carboard002a.mdl"
    }

    local foodModels = {
        "models/props_junk/garbage_newspaper001a.mdl",
        "models/props_junk/PopCan01a.mdl",
        "models/props_junk/garbage_glassbottle003a.mdl",
        "models/props_junk/garbage_metalcan001a.mdl",
        "models/props_junk/garbage_milkcarton002a.mdl",
        "models/props_junk/garbage_bag001a.mdl",
        "models/props_junk/GlassBottle01a.mdl"
    }

    local function Precache(modelsTab)
        for k, model in ipairs(modelsTab) do
            util.PrecacheModel(model)
        end
    end

    Precache(trashModels)
    Precache(objectModels)
    Precache(foodModels)

    local createdPros = {}

    table.insert(createdPros, CreateProp(trashModels, propMarker1:GetPos(), Angle(0, 90, 0), true))
    table.insert(createdPros, CreateProp(objectModels, propMarker2:GetPos(), Angle(0, math.random(0, 270), 0), true))
    table.insert(createdPros, CreateProp(foodModels, propMarker3:GetPos(), Angle(0, math.random(0, 270), 0), true))

    return createdPros
end

local function CheckTipMemories(memoryTab, memoryExistence)
    local isSatisfied = true

    if memoryTab then
        if istable(memoryTab) then
            for k, memory in ipairs(memoryTab) do
                if memoryExistence then
                    if not GM13.Event.Memory:Get(memory) then
                        isSatisfied = false
                        break
                    end
                else
                    if GM13.Event.Memory:Get(memory) then
                        isSatisfied = false
                        break
                    end
                end
            end
        else
            if memoryExistence then
                if not GM13.Event.Memory:Get(memoryTab) then
                    isSatisfied = false
                end
            else
                if GM13.Event.Memory:Get(memoryTab) then
                    isSatisfied = false
                end
            end
        end
    end

    return isSatisfied
end

local function CreateEvent()
    local oracleWall = ents.FindByName("oracleWall")[1]
    oracleWall:SetColor(Color(255, 255, 255, 0))
    oracleWall:Fire("Toggle")

    local triggerOracle = ents.Create("gm13_trigger")
    triggerOracle:Setup(eventName, "triggerOracle", Vector(-2872.1, -2368, 157.9), Vector(-2913.7, -2407.9, 114.7))
    GM13.Ent:HideCurse(triggerOracle, true)

    local oracleSound = ents.Create("gm13_marker")
    oracleSound:Setup(eventName, "oracleSound", Vector(-2231.3, -2467.7, 70))

    local propMarker1 = ents.Create("gm13_marker_prop")
    propMarker1:Setup(eventName, "propMarker1", Vector(-2248.6, -2452.4, 50))

    local propMarker2 = ents.Create("gm13_marker_prop")
    propMarker2:Setup(eventName, "propMarker2", Vector(-2179.5, -2473.7, 50))

    local propMarker3 = ents.Create("gm13_marker_prop")
    propMarker3:Setup(eventName, "propMarker3", Vector(-2171.2, -2448.8, 50))

    AddInterferenceHook(oracleWall, oracleSound)

    function triggerOracle:StartTouch(ent)
        if isToggled then return end
        if not GM13.Event.Memory:Get("firstStream") then return end

        local tips = {}
        local insertTipsTier1 = {
            -- {
            --     image = "",
            --     showsUntil = "", -- Memory, can be a table
            --     showsAfter = ""  -- Memory, can be a table
            -- },
            -- Before completing the dark room
            { image = "13beta/oracle/danger", showsUntil = { "openThePortal", "ratmanReady" } },
            { image = "13beta/oracle/darkroom1", showsUntil = "openThePortal" },
            { image = "13beta/oracle/minge", showsUntil = "openThePortal" },
            { image = "13beta/oracle/01doll", showsUntil = { "openThePortal", "ratmanReady" } },
            { image = "13beta/oracle/bigdarkroom", showsUntil = "openThePortal" },
            -- Arc base
            { image = "13beta/oracle/arcbase", showsAfter = "savedCitizen", showsUntil = "arcBaseDiscovered" },
            -- Transmissions
            { image = "13beta/oracle/transmissions", showsAfter = "ratmanReady", showsUntil = { "transmission1", "transmission2", "transmission3", "mingeAttractor" } },
            { image = "13beta/oracle/mingegod", showsAfter = "ratmanReady", showsUntil = "mingeAttractor" },
            { image = "13beta/oracle/notgrigori", showsAfter = "savedCitizen", showsUntil = "coneMaxLevel" },
        }

        for k, tipTab in ipairs(insertTipsTier1) do
            if not CheckTipMemories(tipTab.showsAfter, true) then continue end
            if not CheckTipMemories(tipTab.showsUntil, false) then continue end

            table.insert(tips, tipTab.image)
        end

        for k, tip in ipairs(tips) do -- HACK: For some reason Booleans sometimes appear in the table
            if isbool(tip) then
                table.remove(tips, k)
            end
        end

        if #tips == 0 then return end
        if oracleWall:GetColor() == Color(255, 255, 255, 255) then return end
        if not ent:IsPlayer() then return end

        if math.random(1, 100) <= 85 then
            isToggled = true

            oracleWall:SetColor(Color(255, 255, 255, 255))
            oracleWall:SetMaterial(tips[math.random(1, #tips)])

            oracleSound:EmitSound(ambientSound, 65)

            props = SpawnTrash(propMarker1, propMarker2, propMarker3)

            timer.Create("gm13_oracle_finish", 80, 1, function()
                FinishOracle(oracleWall, oracleSound)
            end)
        end
	end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
