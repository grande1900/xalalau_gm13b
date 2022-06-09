local eventName = "garageCorridorSwap"

local function CreateEvent()
    local maxAreaTriggersInfo = {
        {
            vecA = Vector(-2521.72, -2558.23, -255.97),
            vecB = Vector(-1606.66, -2133.27, -34.27),
        }
    }

    local startTriggersInfo = {
        {
            vecA = Vector(-2135.97, -2104.07, -42.68),
            vecB = Vector(-1992.38, -2123.54, -143.97),
            probability = 18
        }
    }

    local portalInfo = {
        {
            {
                pos = Vector(-1626.14, -2488.33, -193.05),
                ang = Angle(90, 0, 180),
                sizeX = 1.32,
                sizeY = 1.5,
                sizeZ = 1.1
            },
            {
                pos = Vector(-2514.47, -2488.33, -193.031),
                ang = Angle(90, 0, 180),
                sizeX = 1.32,
                sizeY = 1.5,
                sizeZ = 1.1
            },
        },
        {
            {
                pos = Vector(-2509.44, -2488.33, -193.031),
                ang = Angle(90, 180, 180),
                sizeX = 1.32,
                sizeY = 1.5,
                sizeZ = 1.1
            },
            {
                pos = Vector(-1607.45, -2488.33, -193.031),
                ang = Angle(90, 180, 180),
                sizeX = 1.32,
                sizeY = 1.5,
                sizeZ = 1.1
            }
        }
    }

    local callbacks = {
        startPortals = function(ply)
            ply:Flashlight(false)
            ply:AllowFlashlight(false)
        end,
        plyEnterMaxAreas = function(ply)
            ply:Flashlight(false)
            ply:AllowFlashlight(false)
        end,
        plyExitMaxAreas = function(ply)
            ply:AllowFlashlight(true)
        end
    }

    GM13.Custom:CreatePortalAreas(eventName, maxAreaTriggersInfo, startTriggersInfo, portalInfo, callbacks)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
