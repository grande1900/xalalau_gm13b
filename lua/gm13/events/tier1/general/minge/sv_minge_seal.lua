local eventName = "generalMingeSeal"

GM13.Event.Memory.Dependency:SetProvider(eventName, "mingeSeal")

local function ValidateDisposition(skull)
    if not skull or not skull:IsValid() then return false end

    skullPos = skull:GetPos()

    local dolls = {}

    for k, ent in ipairs(ents.FindInSphere(skullPos, 50)) do
        if ent:GetModel() == "models/props_c17/doll01.mdl" then
            table.insert(dolls, ent)
        end
    end
   
    if #dolls == 5 then
        for k, checkDoll in ipairs(dolls) do
            local checkDollPos = checkDoll:GetPos()

            if checkDollPos:Distance(skullPos) < 20 or checkDollPos:Distance(skullPos) > 36 then
                return false
            end

            local nearbyEnts = ents.FindInSphere(checkDollPos, 34)
            local nearbyDolls = -1

            for k, ent in ipairs(nearbyEnts) do
                if ent:GetModel() == "models/props_c17/doll01.mdl" then
                    nearbyDolls = nearbyDolls + 1
                end
            end

            if nearbyDolls ~= 2 then
                return false
            end
        end
    else
        return false
    end

    local seal = {
        ["skull"] = {
            ent = skull,
            model = "models/gibs/hgibs.mdl",
            pos = skullPos,
            ang = skull:GetAngles()
        },
        ["dolls"] = {}
    }

    for k, doll in ipairs(dolls) do
        table.insert(seal["dolls"], {
            ent = doll,
            model = "models/props_c17/doll01.mdl",
            pos = doll:GetPos(),
            ang = doll:GetAngles()
        })
    end

    return seal
end

local function SpawnSealPart(ent, model, pos, ang)
    if ent and IsValid(ent) and ent:IsValid() then
        ent:Remove()
    end

    ent = ents.Create("prop_physics")

    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS)

    timer.Simple(0.1, function()
        if not ent:IsValid() then return end

        local phys = ent:GetPhysicsObject()

        if phys:IsValid() then
            phys:EnableMotion(false)
        end
    end)

    ent:SetModel(model)
    ent:SetPos(pos)
    ent:SetAngles(ang)

    ent:Spawn()

    GM13.Ent:BlockPhysgun(ent, true)
    GM13.Ent:BlockToolgun(ent, true)
    GM13.Ent:BlockContextMenu(ent, true)

    return ent
end

local function BreakSealPart(ent)
    if not ent or not ent:IsValid() then return end

    local phys = ent:GetPhysicsObject()

    if phys:IsValid() then
        phys:EnableMotion(true)
        phys:Wake()
    end

    timer.Simple(3, function()
        GM13.Ent:Dissolve(ent)
    end)
end

local function SetSealRevalidation(ent, seal)
    local sealCenter = seal['skull'].ent:GetPos()

    ent:AddCallback("PhysicsCollide", function(ent, data)
        local ent = data.HitEntity

        if ent and ent:IsValid() and (ent:IsPlayer() or ent:GetClass() == "prop_physics") then
            GM13.Event.Memory:Set("mingeSeal")

            local skull = seal['skull']
            if skull then
                BreakSealPart(skull.ent)
                seal['skull'] = nil
            end
        
            local dolls = seal['dolls']
            if dolls then
                for k, doll in ipairs(dolls) do
                    BreakSealPart(doll.ent)
                end
                seal['dolls'] = nil
            end

            local explo = ents.Create("env_explosion")
            explo:SetPos(sealCenter + Vector(0, 0, math.random(5, 15)))
            explo:Spawn()
            explo:Fire("Explode")
            explo:SetKeyValue("IMagnitude", 20)
        end
    end)
end

local function SpawnSeal(seal)
    local skull = seal['skull']

    skull.ent = SpawnSealPart(skull.ent, skull.model, skull.pos, skull.ang)
    SetSealRevalidation(skull.ent, seal)
    skull.ent:SetName("SealSkull")

    for k, doll in ipairs(seal['dolls']) do
        doll.ent = SpawnSealPart(doll.ent, doll.model, doll.pos, doll.ang)
        SetSealRevalidation(doll.ent, seal)
        doll.ent:SetName("SealDoll" .. k)
    end

    local sealConfirmation = ents.Create("gm13_func_sprite")
    sealConfirmation:Setup(eventName, "sealConfirmation", Vector(skull.pos.x, skull.pos.y, skull.pos.z - 2), 64, 64, Angle(0, 0, -90), "13beta/transmission_hole")

    skull.ent:CallOnRemove("gm13_minge_seal_clean_decal", function()
        if sealConfirmation:IsValid() then
            GM13.Event:RemoveRenderInfoEntity(sealConfirmation)
            sealConfirmation:Remove()
        end
    end)

    GM13.Lobby:ForceDisconnect()
end

local function RemoveEvent()
    timer.Remove("gm13_check_minge_seal")
end

local function CreateEvent()
	local mingeSealArea = ents.Create("gm13_trigger")
	mingeSealArea:Setup(eventName, "mingeSealArea", Vector(-2482.4, -1056, 41.1), Vector(-2911.8, -1919, -143.9))

    if GM13.Event.Memory:Get("mingeSeal") then
        SpawnSeal(GM13.Event.Memory:Get("mingeSeal"))
    end

	function mingeSealArea:StartTouch(ent)
		if ent:GetModel() ~= "models/gibs/hgibs.mdl" then return end
        if GM13.Event.Memory:Get("mingeSeal") then return end

        timer.Create("gm13_check_minge_seal", 1, 0, function()
            if GM13.Event.Memory:Get("mingeSeal") or not self:IsValid() then
                timer.Remove("gm13_check_minge_seal")
                return
            end

            local dispositionResult = ValidateDisposition(ent)
            
            if dispositionResult then
                GM13.Event.Memory:Set("mingeSeal", dispositionResult)
                SpawnSeal(dispositionResult)
            end
        end)
	end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
