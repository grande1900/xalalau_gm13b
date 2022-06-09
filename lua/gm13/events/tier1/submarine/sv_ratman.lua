local eventName = "submarineRatman"
local Ratman = {}

GM13.Event.Memory.Dependency:SetProvider(eventName, "ratmanReady")
GM13.Event.Memory.Dependency:SetDependent(eventName, "ratmanInit")

function Ratman:BringRatman() -- Ratman walking from the darkroom
    local darkroomRatmanPathVecs = {
        Vector(-3488.3, -1271.4, -143.9),
        Vector(-3340, -1173.2, -143.9),
        Vector(-3156.6, -1153.7, -143.9),
        Vector(-3138.4, -1472.5, -143.9),
        Vector(-2633.7, -1450.2, -143.9),
        Vector(-2132.2, -1402.3, -143.9),
        Vector(-1623.5, -1367.2, -143.9),        
        Vector(-1258.5, -1320.8, -143.9),
        Vector(-919.5, -1274.2, -143.9),
        Vector(-592, -1163, -143.9),
        Vector(-211, -1049.4, -143.9),
        Vector(142.8, -1029.4, -143.9),
        Vector(482.3, -985.6, -143.9),
        Vector(735.7, -837.1, -143.9),
        Vector(825, -531.4, -143.9),
        Vector(836.3, -291, -143.9),
        Vector(950, -62.3, -143.9),
        Vector(1137.3, 144.9, -143.9),
        Vector(1361, 306.6, -143.9),
        Vector(1582.7, 546.1, -143.9),
        Vector(1695.9, 823.6, -143.9),
        Vector(1675.4, 1131.4, -303.9),
        Vector(1681.1, 1405.7, -303.9),
        Vector(2005.7, 1377.9, -303.9),
        Vector(2367.9, 1376.5, -234.8),
        Vector(2655.1, 1378.1, -143.9),
        Vector(2921.5, 1458.8, -143.9),
        Vector(2898.7, 1967.8, -148.2),
        Vector(2901, 2286.3, -150.9),
        Vector(2902, 2621.7, -153.8),
        Vector(2901.9, 3161.9, -158.4),
        Vector(2899.6, 3493.2, -167.9),
        Vector(2307.2, 3742.8, -167.9)
    }

    local pathCounter = 0
    local trail
    local pathEnts

    local function postionTouchCallback(ent, curVec, nextVec)
        if ent:GetName() ~= "ratman" then return end

        pathCounter = pathCounter + 1

        if pathCounter == 1 then
            timer.Simple(1, function()
                if not self.ratman:IsValid() or not ent:IsValid() then return end

                self.ratman:EmitSound("npc/stalker/breathing3.wav", 75)
                trail = util.SpriteTrail(ent, 0, Color(255, 0, 0), false, 19, 1, 15, 1 / (15 + 1) * 0.5, "trails/plasma")

                timer.Remove("gm13_ratman_failsafe_1")
            end)
        end

        if pathCounter <= 2 or pathCounter == #darkroomRatmanPathVecs - 1 then
            ent:SetSaveValue("m_vecLastPosition", nextVec)
            ent:SetSchedule(SCHED_FORCED_GO)

            timer.Create("gm13_ratman_failsafe_2", 10, 0, function()
                if ent and IsValid(ent) and ent:IsValid() and ent:Health() > 0 then
                    ent:SetSaveValue("m_vecLastPosition", nextVec)
                    ent:SetSchedule(SCHED_FORCED_GO)
                    self.ratman:ClearEnemyMemory()
                else
                    timer.Remove("gm13_ratman_failsafe_2")
                end
            end)
        else
            timer.Simple(0.4, function()
                if not ent:IsValid() then return end

                ent:EmitSound("npc/footsteps/hardboot_generic" .. math.random(1, 8) .. ".wav", 100)
                ent:SetPos(nextVec)
            end)
        end

        if pathCounter == #darkroomRatmanPathVecs - 1 then
            trail:Remove()
        end
    end

    local function lastPositionTouchCallback(ent)
        if ent:GetName() ~= "ratman" then return end

        Ratman:BlinkCenterLights()
        Ratman:CreateCompleteScene()

        timer.Remove("gm13_ratman_failsafe_2")

        for k, gm13path in ipairs(pathEnts) do
            GM13.Event:RemoveGameEntity(eventName, gm13path)
            GM13.Event:RemoveRenderInfoEntity(gm13path)
            gm13path:Remove()
        end
    end

    pathEnts = GM13.Custom:CreatePath(darkroomRatmanPathVecs, eventName, postionTouchCallback, lastPositionTouchCallback)

    self.ratman:ClearEnemyMemory()

    self.ratman:SetSaveValue("m_vecLastPosition", darkroomRatmanPathVecs[1])
    self.ratman:SetSchedule(SCHED_FORCED_GO)

    timer.Create("gm13_ratman_failsafe_1", 5, 0, function()
        if self.ratman:IsValid() and self.ratman:Health() > 0 then
            self.ratman:SetSaveValue("m_vecLastPosition", darkroomRatmanPathVecs[1])
            self.ratman:SetSchedule(SCHED_FORCED_GO)
            self.ratman:ClearEnemyMemory()
        else
            timer.Remove("gm13_ratman_failsafe_1")
        end
    end)
end

function Ratman:SpawnRatman(forceSpawn)
    if not forceSpawn and ents.FindByName("ratman")[1] then return end

    local ratman = ents.Create("npc_stalker")
    ratman:SetPos(Vector(2419.9, 3706.9, -167.9))
    ratman:SetAngles(Angle(0, math.random(0, 360), 0))
    ratman:SetName("ratman")
    ratman:SetKeyValue("BeamPower", "2")
    ratman:SetKeyValue("squadname", "ratpeople")
    ratman:Activate()
    ratman:Spawn()

    GM13.Ent:SetInvulnerable(ratman, true)
    GM13.Ent:BlockPhysgun(ratman, true)
    GM13.Ent:FadeIn(ratman, 3)
    GM13.Ent:BlockToolgun(ratman, true)
    GM13.Ent:BlockContextMenu(ratman, true)

    timer.Simple(2, function()
        if not ratman:IsValid() then return end

        ratman:SetSaveValue("m_vecLastPosition", Vector(2306.2, 3742.8, -167.9))
        ratman:SetSchedule(SCHED_FORCED_GO)
    end)

    self.ratman = ratman
end

function Ratman:AttackPlayer()
    if not (self.disturbed > 2) then return 0 end
    if not self.ratman:IsValid() then return end

    self:BlinkCenterLights()

    self.ratman:EmitSound("npc/stalker/go_alert2.wav", 75)

    self.disturbed = 0

    GM13.NPC:AttackClosestPlayer(self.ratman)
    GM13.Ent:SetInvulnerable(self.ratman, false)
    GM13.Ent:SetReflectDamage(self.ratman, true, function()
        GM13.Ent:SetReflectDamage(self.ratman, true, "")
        GM13.Ent:FadeOut(self.ratman, 7, function()
            if self.ratman:IsValid() then
                self.ratman:Remove()
                timer.Simple(30, function()
                    for propName, _ in pairs (self.props) do
                        self.touchedProps[propName] = true
                    end

                    Ratman:SpawnRatman()
                end)
            end
        end)
    end)

    return 25
end

local function SetTableAntiMove(table)
    timer.Create("gm13_set_ratmans_table_callback", 2, 1, function() -- timer.Create to better handle map cleanups
        if not table:IsValid() then return end
        
        local callbackId

        callbackId = table:AddCallback("OnAngleChange", function()
            if not table:IsValid() then return end

            table:RemoveCallback("OnAngleChange", callbackId)
            table:Ignite(30)
        end)
    end)
end

function Ratman:CreateProp(name, model, pos, ang, callback)
    local propMarker = ents.Create("gm13_marker_prop")
    propMarker:Setup(eventName, "ratman" .. name, pos)

    local prop = ents.Create("prop_dynamic")
    prop:SetModel(model)
    prop:SetPos(pos)
    prop:SetAngles(ang)
    prop:Spawn()
    GM13.Event:SetGameEntity(eventName, prop)
    prop:PhysicsInit(SOLID_VPHYSICS)
    prop:SetMoveType(MOVETYPE_VPHYSICS)
    prop:SetSolid(SOLID_VPHYSICS)
    prop:SetName(name)

    local phys = prop:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    GM13.Ent:FadeIn(prop, 1)
    GM13.Ent:BlockToolgun(prop, true)
    GM13.Ent:BlockContextMenu(prop, true)
    GM13.Prop:CallOnBreak(prop, "ratman_prop", function()
        self.touchedProps[name] = true
        self:StartRestoreProps(name)
    end)

    timer.Simple(1, function() -- Ignore initial collisions
        if not prop:IsValid() then return end

        local id
        id = prop:AddCallback("PhysicsCollide", function(data, phys)
            if pos:Distance(prop:GetPos()) > 100 then
                prop:RemoveCallback("PhysicsCollide", id)
                self.touchedProps[name] = true
                self:StartRestoreProps(name)
            end
        end)
    end)

    if callback then
        callback(prop)
    end

    return prop, propMarker
end

function Ratman:BlinkCenterLights()
    local lightCenter = ents.FindByName("submarineStalkerCenterLight")[1]
    local lightCenterProp = ents.FindByName("submarineStalkerCenterLightProp")[1]

    GM13.Light:Blink(lightCenter, 1, true,
        function()
            lightCenterProp:SetSkin(1)
        end,
        function()
            lightCenterProp:SetSkin(0)
        end
    )
end

function Ratman:StartRestoreProps()
    if self.creatingProps then return end

    local attackDelay = self:AttackPlayer()

    if not attackDelay then return end

    self.creatingProps = true
    self.disturbed = self.disturbed + 1

    local function goToCenter()
        if not self.ratman:IsValid() then return end

        self.ratman:SetSaveValue("m_vecLastPosition", Vector(2307.2, 3742.8, -167.9))
        self.ratman:SetSchedule(SCHED_FORCED_GO)
    end

    timer.Simple(attackDelay, function()
        if not self.ratman:IsValid() then return end

        if attackDelay == 0 then
            self.ratman:EmitSound("npc/stalker/breathing3.wav", 75)
        end

        goToCenter()
        timer.Create("gm13_ratman_go_restore", 4, 0, function()
            goToCenter()
        end)
    end)
end

function Ratman:RestoreProps()
    if not next(self.touchedProps) then return end

    GM13.NPC:PlaySequences(self.ratman, "console_work_loop")

    for propName, _ in pairs(self.touchedProps) do
        local movedProp = ents.FindByName(propName)[1]

        if movedProp then
            GM13.Ent:Dissolve(movedProp)
        end

        timer.Simple(2, function()
            self:CreateProp(propName, unpack(self.props[propName]))
        end)
    end

    timer.Simple(2.01, function()
        self.creatingProps = false
    end)

    self.touchedProps = {}

    self:BlinkCenterLights()

    timer.Simple(0.3, function()
        timer.Remove("gm13_ratman_go_restore")
    end)
end

function Ratman:SetRandomTravels()
    timer.Create("gm13_ratman_random_travels", 400, 0, function()
        if not Ratman.ratman:IsValid() then
            timer.Remove("gm13_ratman_random_travels")
            return
        end

        if math.random(1, 100) <= 15 then
            GM13.Ent:FadeOut(Ratman.ratman, 3, function()
                if not Ratman.ratman:IsValid() then return end

                timer.Remove("gm13_ratman_random_travels")
                Ratman.ratman:Remove()

                timer.Simple(math.random(10, 60), function()
                    Ratman:SpawnRatman()
                    self:SetRandomTravels()
                end)
            end)
        end
    end)
end

function Ratman:CreateCompleteScene()
    local function Precache(propList)
        for propName, propDetails in pairs(propList) do
            util.PrecacheModel(propDetails[1])
        end
    end

    self.touchedProps = {}
    self.isAngry = false
    self.disturbed = 0
    self.props = {
        ["ratman_chair"] = { "models/props_interiors/Furniture_chair03a.mdl", Vector(2266.9, 3556.5, -148), Angle(0, 0, 0) },
        ["ratman_table"] = { "models/props_c17/FurnitureTable002a.mdl", Vector(2286, 3554.9, -150), Angle(0, 0, 0), SetTableAntiMove },
        ["ratman_locker"] = { "models/props_c17/FurnitureDresser001a.mdl", Vector(2290.2, 3370.5, -128), Angle(0, 90, 0) },
        ["ratman_fridge"] = { "models/props_c17/FurnitureFridge001a.mdl", Vector(2229.5, 3368.8, -131), Angle(0, 90, 0) },
        ["ratman_bed"] = { "models/props_c17/FurnitureMattress001a.mdl", Vector(2035.1, 3385.6, -164.9), Angle(0, 0, 0) },
        ["ratman_mobile"] = { "models/props_c17/FurnitureDrawer001a.mdl", Vector(2000.4, 3445.1, -140), Angle(0, 0, 0) }
    }

    Precache(self.props)

    local ratmanCenterTrigger = ents.Create("gm13_trigger")
    ratmanCenterTrigger:Setup(eventName, "ratmanCenterTrigger", Vector(2283.8, 3749.2, -167.9), Vector(2326.4, 3724, -81.7))

    local id = ratmanCenterTrigger:StartLoopingSound("ambient/atmosphere/hole_amb3.wav")

    ratmanCenterTrigger:CallOnRemove("gm13_stop_sound_loop", function()
        ratmanCenterTrigger:StopLoopingSound(id)
    end)

    self:SetRandomTravels()

    local ratmanLimit = ents.Create("gm13_trigger")
    ratmanLimit:Setup(eventName, "ratmanLimit", Vector(2969.5, 3355.4, -167.9), Vector(2840, 3352.7, -16))
    GM13.Ent:HideCurse(ratmanLimit, true)

    local ratmanMoveAway = ents.Create("gm13_marker_info_target")
    ratmanMoveAway:Setup(eventName, "ratmanMoveAway", Vector(2816.5, 3446.8, -167.9))

    function ratmanLimit:StartTouch(ent)
        if not ent.gm13_ratman_in then return end

        GM13.Ent:FadeOut(Ratman.ratman, 3, function()
            if not Ratman.ratman:IsValid() then return end

            Ratman.ratman:Remove()

            timer.Simple(math.random(10, 60), function()
                Ratman:SpawnRatman()
            end)
        end)
    end

    for propName, propInfo in pairs(self.props) do
        self:CreateProp(propName, unpack(propInfo))
    end

    function ratmanCenterTrigger:StartTouch(ent)
        if ent:GetName() ~= "ratman" then return end

        if not ent.gm13_ratman_in then
            ent.gm13_ratman_in = true
        end

        if not GM13.Event.Memory:Get("ratmanReady") then
            timer.Simple(1, function() -- Hack: delay the new memory to try to load the transmission event decals correctly
                GM13.Event.Memory:Set("ratmanReady", true)
            end)
        end

        Ratman:RestoreProps()
    end

    self:SetBackLights(false)
end

function Ratman:SetBackLights(state)
    local lightBack = ents.FindByName("submarineStalkerBackLight")[1]
    local lightBackProp = ents.FindByName("submarineStalkerBackLightProp")[1]
    
    if state then
        if lightBack and IsValid(lightBack) and lightBack:IsValid() then
            lightBack:Fire("TurnOn")
        end
        if lightBackProp and IsValid(lightBackProp) and lightBackProp:IsValid() then
            lightBackProp:SetSkin(1)
        end
    else
        if lightBack and IsValid(lightBack) and lightBack:IsValid() then
            lightBack:Fire("TurnOff")
        end
        if lightBackProp and IsValid(lightBackProp) and lightBackProp:IsValid() then
            lightBackProp:SetSkin(0)
        end
    end
end

function Ratman:CreateRatman()
    timer.Simple(0.2, function() -- Wait so we can detect ratman if we load a Save
        self.ratman = ents.FindByName("ratman")[1]

        if self.ratman and self.ratman:GetPos():Distance(Vector(2308.4, 3738.2, -167.9)) < 500 then
            self.ratman:Remove() -- Hack: remove ratman from GMod saves
            self.ratman = nil
        end
  
        if self.ratman then
            self:BringRatman()
        else
            self:SpawnRatman(true)
            self:CreateCompleteScene()
        end

        GM13.Event:SetGameEntity(eventName, self.ratman)
    end)

    return true
end

local function CreateEvent()
    return Ratman:CreateRatman()
end

function Ratman:UndoLights()
    self:SetBackLights(true)
end
local function UndoLights()
    return Ratman:UndoLights()
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetFailCall(eventName, UndoLights)
