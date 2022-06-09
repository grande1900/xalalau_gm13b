local eventName = "darkRoomStream"

GM13.Event.Memory.Dependency:SetProvider(eventName, "firstStream")

local function CreateEvent()    
    local streamMarker = ents.Create("gm13_marker")
    streamMarker:Setup(eventName, "streamMarker", Vector(-3203.1, -1472.6, -340))

    local streamTrigger = ents.Create("gm13_trigger")
    streamTrigger:Setup(eventName, "streamTrigger", Vector(-992.3, -1919.9, -7.2), Vector(-1000.3, -1145.3, -143.9))

    local streamTriggerNear

    if not GM13.Event.Memory:Get("firstStream") then
        streamTriggerNear = ents.Create("gm13_trigger")
        streamTriggerNear:Setup(eventName, "streamTriggerNear", Vector(-2270.8, -1057.6, -143.9), Vector(-2283.3, -2047.9, -30.7))
    end

    local sound = {
        "wind_moan1.wav",
        "wind_moan2.wav",
        "wind_snippet2.wav",
        "wind_snippet4.wav"
    }

    local function StartStream(ent)
        ent:EmitSound("ambient/wind/" .. sound[math.random(1, 3)], 30)

        GM13.Effect:StartSmokeStream(streamMarker:GetPos(), Angle(0, 90, 0))
        util.ScreenShake(Vector(0, 0, 0), 3, 3, 3, 3000)

        local cone = ents.FindByName("dark_room_pspotl")[1]
        local light = ents.FindByName("dark_room_lspot")[1]
        GM13.Light:Blink(light, 3, true,
            function()
                cone:Fire("LightOn")
            end,
            function()
                cone:Fire("LightOff")
            end,
            function() -- Sometimes the cone fails to end on the right mode, so it's needed
                cone:Fire("LightOff")

                timer.Simple(0.2, function()
                    if not cone:IsValid() then return end

                    cone:Fire("LightOn")
                end)
            end
        )
    end

    function streamTrigger:StartTouch(ent)
        if not ent:IsPlayer() or not GM13.Event.Memory:Get("firstStream") then return end

        if math.random(1, 100) <= 14 then
            StartStream(ent)
        end
    end

    if not GM13.Event.Memory:Get("firstStream") then
        function streamTriggerNear:StartTouch(ent)
            if not ent:IsPlayer() then return end

            if math.random(1, 100) <= 50 then
                StartStream(ent)

                GM13.Event.Memory:Set("firstStream", true)
                GM13.Event:RemoveRenderInfoEntity(streamTriggerNear)
                streamTriggerNear:Remove()
            end
        end
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)