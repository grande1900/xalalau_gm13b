local eventName = "positionMesh"

local function CreateEvent()
    local validVecs = {
        Vector(756.1, 411.2, -143.9),
        Vector(-3298.1, 5392.6, -105.5),
        Vector(-2971.5, 3805.8, -129.5),
        Vector(-4357.6, 3897.3, -101.7),
        Vector(-3584.3, 3362.4, -101),
        Vector(-4842.6, 2892.4, -100.4),
        Vector(-4003, 2502.3, -106.3),
        Vector(-3058.2, 2222.5, -136.1),
        Vector(-4719.9, 1531, -65.4),
        Vector(-3759.3, 1751.7, -97.5),
        Vector(-4607.7, 629.1, 90.4),
        Vector(-3651, 801, 0.2),
        Vector(-4502.9, -355, 212.8),
        Vector(-3223.6, -332.1, 78.7),
        Vector(-2982.3, 881.3, -42.3),
        Vector(-2954.1, 1709.6, -113.8),
        Vector(-2148.8, 1772.7, -120.3),
        Vector(-1945.3, 630.9, -147.9),
        Vector(-1307.5, 1718.3, -133.9),
        Vector(-1392, -639.5, -148),
        Vector(-850.1, 339.8, -148.5),
        Vector(-157.8, -680.2, -148),
        Vector(307.2, 521.3, -148),
        Vector(-9.8, 1505.6, -135.3),
        Vector(1107.9, 1517.1, -37),
        Vector(291.1, -894.8, -148.9),
        Vector(1763.8, -767, 64),
        Vector(1167, -168.8, 64),
        Vector(1472, 438.9, 64),
        Vector(1459, 2019.3, -31.9),
        Vector(985.8, 1781.8, -31.9),
        Vector(1126, 2651.4, -31.9),
        Vector(1605.7, 3180.8, -31.9),
        Vector(1156.5, 3620.9, -31.9),
        Vector(723, 4261.7, -31.9),
        Vector(1204.5, 4215.7, -31.9),
        Vector(1526.8, 4887.7, -31.9),
        Vector(1071.5, 5137.4, -31.9),
        Vector(1571.1, 5699.1, -31.9),
        Vector(1115.9, 5909.5, -31.9),
        Vector(-3875.8, -1264.3, 250),
        Vector(-4920.1, -1451.4, 249.9),
        Vector(-4765.2, -3073.6, 249.9),
        Vector(-4517.8, -2205, 250),
        Vector(-3693.1, -2967.3, 250),
        Vector(-3857.9, -2158.5, 249.9),
        Vector(-3229.1, -2134.3, 250),
        Vector(-3019.9, -1540.7, 240),
        Vector(-2356.4, -1093.4, 240),
        Vector(-2470.8, -1741.9, 240),
        Vector(-2097.5, -2007, 256),
        Vector(-1239.3, -1732.9, 240),
        Vector(-1138.1, -1206.6, 240),
        Vector(-1235.1, -2332.6, 253.5),
        Vector(-1102.2, -3203.5, 262.2),
        Vector(-391.2, -3235.2, 187.8),
        Vector(-867.1, -2486, 260.2),
        Vector(-271.4, -2451.9, 63.1),
        Vector(458.9, -3232.4, 37.4),
        Vector(633.7, -2566.5, -117.8),
        Vector(50.4, -2545.5, -29.2),
        Vector(1369.8, -3577.8, 58.7),
        Vector(874.1, -3068.2, -27.2),
        Vector(1395.8, -2841.9, -80),
        Vector(773.2, -1059.7, 1296),
        Vector(-1630.5, -2288.8, 2816),
        Vector(-2978, -2281, 2816),
        Vector(-4021.3, 4712.8, 2496),
        Vector(961.5, 1064.8, -143.9),
        Vector(948, 639, -143.9),
        Vector(712.3, 591.5, -143.9),
        Vector(966, 368.5, -143.9),
        Vector(702.5, 173, -143.9),
        Vector(852.4, 114.2, -143.9),
        Vector(724.8, -25.1, -143.9),
        Vector(949.4, -98.9, -143.9),
        Vector(731.3, -260, -143.9),
        Vector(876.9, -295.1, -143.9),
        Vector(700.2, -438.7, -143.9),
        Vector(883.2, -428.9, -143.9),
        Vector(691.3, -623.5, -143.9),
        Vector(964.1, -661.7, -143.9),
        Vector(811.2, -878.3, -143.9),
        Vector(-200.9, 102, -148),
        Vector(-742.8, 1121.2, -147.5),
        Vector(-2156.9, -56, -122.4),
        Vector(-1934.4, -2348.4, 2848),
        Vector(-2249.4, -2344.4, 2848),
        Vector(-2586.9, -2340.1, 2848),
        Vector(-1789.1, -2489.6, 2976),
        Vector(1054.3, -1041.8, 1296),
        Vector(734.1, -1380.4, 1296),
        Vector(738.5, -1827.5, 1296),
        Vector(741.9, -2150, 1296),
        Vector(1234, -1169.4, 1424),
        Vector(-4271.6, 4705.1, 2496),
        Vector(-3998.1, 5014.3, 2496),
        Vector(-4123.6, 4825.5, 2624),
        Vector(-4911, 4697.2, 2496),
        Vector(-4752.4, 4835.8, 2624),
        Vector(-2589.08, 524.29, -527.97),
        Vector(-2579.7, 780.83, -527.97)
    }
    
    for k, vec in ipairs(validVecs) do
        local infoTarget = ents.Create("gm13_marker_info_target")
        infoTarget:Setup(eventName, "positionMesh" .. k, vec)
        infoTarget:SetName("positionMesh")
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent, true)
