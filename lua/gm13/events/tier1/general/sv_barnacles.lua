local eventName = "generalBarnacles"

local function VanishSpinning(ent)
    if not ent:IsValid() then return end

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetPos(ent:GetPos())
    ragdoll:SetModel(ent:GetModel())
    ragdoll:SetAngles(ent:GetAngles())
    ent:Remove()
    ragdoll:Spawn()
    ragdoll:Activate()
    ragdoll:SetColor(Color(0, 0, 0, 255))

    local phys = ragdoll:GetPhysicsObject()

    local name = tostring(ragdoll)
    hook.Add("Tick", name, function()
        if not phys:IsValid() then
            hook.Remove("Tick", name)
            return
        end

        phys:SetAngles(phys:GetAngles() + Angle(0, 100))
        phys:SetPos(phys:GetPos() + Vector(0, 0, 1.15))
    end)

    local id = ragdoll:StartLoopingSound("ambient/atmosphere/city_beacon_loop1.wav")

    ragdoll:CallOnRemove("gm13_stop_engine_sound", function(ent)
        ent:StopLoopingSound(id)
    end)

    GM13.Ent:FadeOut(ragdoll, 3, function()
        if not ragdoll:IsValid() then return end

        ragdoll:Remove()
    end)
end

local function PlaySound(ent, guilty)
    local hydraSounds = guilty:GetSounds()
    local sound

    if math.random(1, 100) <= 10 then
        sound = hydraSounds["Need"]
    else
        sound = hydraSounds[math.random(0, 1) == 1 and "Uhh" or "Ahh"]
    end

    ent:EmitSound(sound)
end

local function CreateEvent()
    local guilty = ents.Create("gm13_npc_hydra")
	guilty:Setup(eventName, "barnaclesKiller", Vector(-1045.8, -1044.8, 240))

    hook.Add("OnEntityCreated", "gm13_barnacle_victim_control", function(ent)
        if ent:GetClass() == "npc_barnacle" and not ent.gm13_barn then
            timer.Simple(math.random(20, 60), function()
                if ent:IsValid() then
                    PlaySound(ent, guilty)
                    ent:TakeDamage(100000, guilty)
                end
            end)
        elseif ent:GetClass() == "prop_ragdoll_attached" then
            local soundDelay = 0

            for _, barnacle in ipairs(ents.FindByClass("npc_barnacle")) do
                if not barnacle.gm13_barn then
                    soundDelay = soundDelay + 0.07
                    timer.Simple(soundDelay, function()
                        if barnacle:IsValid() then
                            PlaySound(barnacle, guilty)
                        end
                    end)
                    barnacle:TakeDamage(100000, guilty)
                end
            end

            timer.Simple(0.2, function()
                if not ent:IsValid() then return end
                VanishSpinning(ent)
            end)
        end
    end)

    return true
end

local function RemoveEvent()
    hook.Remove("OnEntityCreated", "gm13_barnacle_victim_control")

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
