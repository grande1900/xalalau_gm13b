-- Auxiliar function to help rendering only the names of unprotected map entities
local function ShowOnlyUnprotectedEnts(callback, ...)
    local tr = LocalPlayer():GetEyeTrace()
    if tr.HitWorld then return end
    if GM13.Ent:IsInfoHidden(tr.Entity) then return end
    if not tr.Entity or not tr.Entity:IsValid() then return end
    callback(...)
end

-- Auxiliar function to steal HUDPaint from other addons
local function StealHUDPaint(hookName)
    local func = hook.GetTable()["HUDPaint"][hookName]

    if func then
        hook.Add("HUDPaint", hookName, function()
            ShowOnlyUnprotectedEnts(func)
        end)
    end
end

-- Prop info hud
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2573011318
local function BlindPropInfoHud()
    local HudInfoAddonFunc = hook.GetTable()["HUDPaint"]["HudInfoAddon"]

    if HudInfoAddonFunc then
        hook.Add("HUDPaint", "HudInfoAddon", function()
            ShowOnlyUnprotectedEnts(HudInfoAddonFunc)
        end)
    end
end

-- Ike HUD
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2124047361
local function BlindIkeHUD()
    if EntityHud then
        local _EntityHud = EntityHud

        function EntityHud()
            ShowOnlyUnprotectedEnts(_EntityHud)
        end
    end
end

-- DepthHUD Inline
-- https://steamcommunity.com/sharedfiles/filedetails/?id=420804290
local function BlindDepthHUDInline()
    if dhinline_theme then
        local theme = dhinline_theme.GetCurrentThemeObject()
        local myElement = theme:GetElement("info_target")
        local DrawFunction = myElement.DrawFunction

        function myElement:DrawFunction()
            ShowOnlyUnprotectedEnts(DrawFunction, myElement)
        end
    end
end

-- Hide protected map entities from other addons
function GM13.Addon:BlindEntInfoAddons()
    local HUDPaintNames = {
        "qtg_hpbar", --  QTG Health Bar: https://steamcommunity.com/sharedfiles/filedetails/?id=1937418413
        "bleh", -- NPC Health Bar v1.13: https://steamcommunity.com/sharedfiles/filedetails/?id=197623047
        "BellOfTheBell", -- NPC Health Bar: https://steamcommunity.com/sharedfiles/filedetails/?id=1452536113
        "vj_hud_traceinfo", -- VJ HUD: https://steamcommunity.com/sharedfiles/filedetails/?id=1611146324
        "HUD_Info_main", -- HUD Info: https://steamcommunity.com/sharedfiles/filedetails/?id=305475602
        "SEI", -- Simple Entity Info: https://steamcommunity.com/sharedfiles/filedetails/?id=2072385990
        "NADMOD.HUDPaint", -- Nadmod Prop Protection: https://steamcommunity.com/sharedfiles/filedetails/?id=159298542
    }

    for k, hookName in ipairs(HUDPaintNames) do
        StealHUDPaint(hookName)
    end

    BlindPropInfoHud()
    BlindIkeHUD()
    BlindDepthHUDInline()
end