local eventName = "garageDarkroomGateKeeper"
local waitToPlayNotice = false

local function GetPhysicsObject(ent)
    if ent:IsValid() and not ent:IsPlayer() and not ent:IsRagdoll() and not ent:IsNPC() then
        return ent:GetPhysicsObject()
    end
end

local function ClearTheWay(vecs)
    for _, ent in ipairs(ents.FindInBox(vecs.prohibitedZone[1], vecs.prohibitedZone[2])) do
        if GM13.Prop:IsSpawnedByPlayer(ent) then
            local obj = GetPhysicsObject(ent)

            if obj and obj:IsValid() then
                local pos = ent:GetPos()
                local mass = obj:GetMass()

                if not obj:IsMotionEnabled() then
                    obj:EnableMotion(true)
                    obj:Wake()
                end

                obj:SetMass(10)
                obj:ApplyForceCenter((vecs.destine[math.random(1, #vecs.destine)] - ent:GetPos()) * 500)
                obj:SetMass(mass)
                
                timer.Simple(0.3, function()
                    if ent:IsValid() then
                        ent.gm13_is_obstruction = true 
                    end
                end)
            end
        end
    end
end

local function PlayNotice(notice)
    if waitToPlayNotice or not notice:IsValid() then return end

    notice:EmitSound("ambient/creatures/town_zombie_call1.wav", 130)

    waitToPlayNotice = true

    timer.Simple(20, function()
        waitToPlayNotice = false
    end)
end

local function CreateEvent()
    local noticeVec = Vector(-3215.9, -1481.6, -77.2)

    local keepFree = {
        gate_large = {
            A = Vector(-1139, -1798.3, 95),
            B = Vector(-957.7, -1180.7, -143.9),
            origin = Vector(-986.6, -1475.1, -98.5),
            destine = {
                Vector(-912.5, -1431.4, 281.8),
                Vector(-798.9, -1764.7, 256.4),
                Vector(-702.3, -1582.1, 87.9),
                Vector(-668.5, -1293, 112.5),
                Vector(-839.5, -1158.4, 59.9)
            },
            prohibitedZone = {
                Vector(-1311.9, -1919.9, 168.3),
                Vector(-843, -1125.2, -143.9)                
            }
        },
        gate_small = {
            A = Vector(-2184.1, -1226.1, -89.3),
            B = Vector(-2190.8, -931.9, -101),
            origin = Vector(-2187.8, -1010.2, -96.2),
            destine = {
                Vector(-2336.7, -863.6, 76.1),
                Vector(-2296.3, -751.4, 42.6),
                Vector(-2132.3, -782.3, 108.5),
                Vector(-2067, -776.2, -5.1),
                Vector(-1967.2, -871.6, 14.7),
            },
            prohibitedZone = {
                Vector(-2284.5, -895.7, -10.3),
                Vector(-2063.1, -1131.2, -143.9)
            }
        },
        roof = {
            A = Vector(-1610.7, -1709.7, 252.5),
            B = Vector(-1824.3, -1219.4, 181),
            origin = Vector(-1639.3, -1645.4, 275.8),
            destine = {
                Vector(-1798.8, -1421.5, 579.5),
                Vector(-1834.4, -1716, 622.8),
                Vector(-1493.2, -1851.4, 670.2),
                Vector(-1430, -1502.5, 877),
                Vector(-1478.6, -1330.1, 768.7)
            },
            prohibitedZone = {
                Vector(-1194.9, -1130.7, 190.9),
                Vector(-2250.3, -1802.6, 246.3)               
            }
        },
        door_up = {
            A = Vector(-2981.1, -976.3, 87.5),
            B = Vector(-2971.4, -1153.7, 100),
            origin = Vector(-2976.5, -1032.9, 87.7),
            destine = {
                Vector(-3157.6, -887.6, 215.4),
                Vector(-2991.9, -788.2, 195),
                Vector(-2878.5, -946.2, 151.5)
            },
            prohibitedZone = {
                Vector(-3072.2, -936.9, 161.4),
                Vector(-2864.3, -1114.7, 48)
            }
        },
        door_down = {
            A = Vector(-2061.6, -2144.6, -94),
            B = Vector(-2072.9, -1992.9, -105.4),
            origin = Vector(-2067.3, -2049.2, -99.4),
            destine = {
                Vector(-1909.2, -1766.5, -34.9),
                Vector(-2059.1, -1660.5, -3.3),
                Vector(-2163.6, -1824.1, -49.6)
            },
            prohibitedZone = {
                Vector(-1992.2, -2153, -41.3),
                Vector(-2141.2, -1978, -143.9)                
            }
        },
        darkroom_front = {
            A = Vector(-3213.4, -1439.2, -35),
            B = Vector(-1350.2, -1508.7, -143.6),
            origin = Vector(-2894, -1472.6, -100.5),
            destine = {
                Vector(-2369.8, -1720.8, 26.3),
                Vector(-2173.6, -1527.4, 28.5),
                Vector(-2416.8, -1204.2, -7.4)
            },
            prohibitedZone = {
                Vector(-3210.8, -1916.3, 184.5),
                Vector(-1332.8, -1060.9, -143.9)
            }
        },
        darkroom_inside_front1 = {
            A = Vector(-3120, -1186, -74.6),
            B = Vector(-3351.2, -1168.5, -92.6),
            origin = Vector(-3266, -1170.8, -92.8),
            destine = {
                Vector(-3431.7, -1152, -33),
                Vector(-3436.1, -1271.7, -28.4),
                Vector(-3342.7, -1339.3, -53.9)
            },
            prohibitedZone = {
                Vector(-3120, -1250.6, -40.2),
                Vector(-3369.8, -1099.3, -143.9)                
            }
        },
        darkroom_inside_front2 = {
            A = Vector(-3120, -1815.9, -80),
            B = Vector(-3301.3, -1800.2, -94.1),
            origin = Vector(-3267.7, -1804.7, -92.6),
            destine = {
                Vector(-3404.2, -1959.7, -44),
                Vector(-3413.2, -1639.8, -52.4),
                Vector(-3417.3, -1832.3, 42.1)
            },
            prohibitedZone = {
                Vector(-3120, -1711.2, -42.2),
                Vector(-3346.6, -1907.8, -143.9)
            }
        },
        darkroom_inside_back = {
            A = Vector(-5471.9, -2454.7, -76.8),
            B = Vector(-5161.2, -2442.1, -92.5),
            origin = Vector(-5217.7, -2449.7, -92.7),
            destine = {
                Vector(-5152, -2309.8, -59.4),
                Vector(-5049.8, -2369, -6.8),
                Vector(-5021.7, -2455.8, -73.6)
            },
            prohibitedZone = {
                Vector(-5466, -2326, -21.5),
                Vector(-5121.6, -2554, -143.9)
            }
        },
        darkroom_back_upstairs = {
            A = Vector(-5145, -3429, 354.5),
            B = Vector(-5275.5, -3579.6, 256.2),
            origin = Vector(-5243.3, -3511.4, 307.8),
            destine = {
                Vector(-5126.1, -3595.1, 360.7),
                Vector(-5057.4, -3521, 310.9),
                Vector(-5099.7, -3442.1, 402.5),
                Vector(-5175.9, -3329.1, 433.2)
            },
            prohibitedZone = {
                Vector(-5529.4, -3279.1, 405.2),
                Vector(-5119.7, -3662.4, 256)
            }
        }
    }

    local notice = ents.Create("gm13_marker")
    notice:Setup(eventName, "notice", noticeVec)

    for gate, vecs in pairs(keepFree) do
        for k, vecEnd in ipairs(vecs.destine) do
            timer.Simple(0.1 * k, function()
                local throwVec = ents.Create("gm13_marker_vector")
                throwVec:Setup(eventName, gate .. "_throwVec" .. k, vecEnd, vecs.origin)
            end)
        end

        local prohibitedZone = ents.Create("gm13_marker")
        prohibitedZone:Setup(eventName, gate .. " prohibitedZone", vecs.prohibitedZone[1], vecs.prohibitedZone[2])

        local keepFreeTrigger = ents.Create("gm13_trigger")
        keepFreeTrigger:Setup(eventName, gate .. " keepFreeTrigger", vecs.A, vecs.B)

        function keepFreeTrigger:StartTouch(ent)
            if not (
                ent:GetClass() or
                string.find(ent:GetClass(), "prop_") or
                ent:GetClass() == "minecraft_block"
               ) then
                return
            end

            local inAreaBeginning = {}

            for _, ent in ipairs(ents.FindInBox(vecs.prohibitedZone[1], vecs.prohibitedZone[2])) do
                if GM13.Prop:IsSpawnedByPlayer(ent) then
                    inAreaBeginning[ent] = true
                end
            end

            timer.Simple(8, function()
                local isCleanupNeeded = false

                for _, ent in ipairs(ents.FindInBox(vecs.prohibitedZone[1], vecs.prohibitedZone[2])) do
                    if inAreaBeginning[ent] then
                        isCleanupNeeded = true
                        break
                    end
                end

                if isCleanupNeeded then
                    PlayNotice(notice)

                    timer.Simple(5, function()
                        ClearTheWay(vecs)
                    end)
                end
            end)
        end

        function keepFreeTrigger:Touch(ent)
            if ent.gm13_is_obstruction then
                GM13.Ent:Dissolve(ent, 1)
                ent.gm13_is_obstruction = false
            end
        end
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
