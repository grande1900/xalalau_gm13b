-- Only functions that apply to entities in general!!

-- Detour management

local ENT = FindMetaTable("Entity")
GM13_ENT_GetClass = GM13_ENT_GetClass or ENT.GetClass
GM13_IsValid = GM13_IsValid or IsValid

-- Is ent spawned by a player

function GM13.Ent:IsSpawnedByPlayer(ent)
    return ent:GetNWBool("gm13_spawned")
end

-- Physgun

function GM13.Ent:BlockPhysgun(ent, value, ply)
    if ply and ply:IsPlayer() then
        ply.gm13_physgyun = ply.gm13_physgyun or {}
        ply.gm13_physgyun[ent] = value
    else
        ent.gm13_physgyun = value
    end
end

function GM13.Ent:IsPhysgunBlocked(ent, ply)
    if ply and ply:IsPlayer() then
        return ply.gm13_physgyun and ply.gm13_physgyun[ent]
    else
        return ent.gm13_physgyun
    end
end

hook.Add("PhysgunPickup", "gm13_physgun_pickup_control", function(ply, ent)
    local isBlocked = GM13.Ent:IsPhysgunBlocked(ent, ply) or GM13.Ent:IsPhysgunBlocked(ent)

    if isBlocked ~= nil then
        return not isBlocked
    end
end)

hook.Add("OnPhysgunFreeze", "gm13_physgun_freeze_control", function(weapon, physobj, ent, ply)
    return GM13.Ent:IsPhysgunBlocked(ent) or GM13.Ent:IsPhysgunBlocked(ent, ply) or nil
end)

hook.Add("CanPlayerUnfreeze", "gm13_physgun_unfreeze_control", function(ply, ent, phys)
    if GM13.Ent:IsPhysgunBlocked(ent) or GM13.Ent:IsPhysgunBlocked(ent, ply) then
        return false
    end
end)

-- Toolgun

function GM13.Ent:BlockTools(ent, ...)
    local newTab = ent.gm13_blocked_tools or {}

    for k, toolname in ipairs({ ... }) do
        newTab[toolname] = true
    end

    ent.gm13_blocked_tools = newTab
end

function GM13.Ent:UnblockTools(ent, ...)
    if ent.gm13_blocked_tools then
        for k, toolname in ipairs({ ... }) do
            ent.gm13_blocked_tools[toolname] = nil
        end
    end
end

function GM13.Ent:GetBlockedTools(ent)
    return ent.gm13_blocked_tools
end

function GM13.Ent:BlockToolgun(ent, value, ply)
    if ply and ply:IsPlayer() then
        ply.gm13_toolgun = ply.gm13_toolgun or {}
        ply.gm13_toolgun[ent] = value
    else
        ent.gm13_toolgun = value
    end
end

function GM13.Ent:IsToolgunBlocked(ent, ply)
    if ply and ply:IsPlayer() then
        return ply.gm13_toolgun and ply.gm13_toolgun[ent]
    else
        return ent.gm13_toolgun
    end
end

hook.Add("CanTool", "gm13_toolgun_permission_control", function(ply, tr, toolname, tool, button)
    local ent = tr.Entity
    local IsToolgunBlocked = GM13.Ent:IsToolgunBlocked(ent) or GM13.Ent:IsToolgunBlocked(ent, ply)

    if IsValid(ent) then
        if IsToolgunBlocked ~= nil then
            return not ent.gm13_toolgun
        end

        local blockedTools = GM13.Ent:GetBlockedTools(ent)

        if blockedTools then
            return not blockedTools[toolname]
        end
    end
end)

-- Context menu

function GM13.Ent:BlockContextMenu(ent, value, ply)
    if ply and ply:IsPlayer() then
        ent:SetNWBool("gm13_context_menu_" .. ply:SteamID(), value)
    else
        ent:SetNWBool("gm13_context_menu", value)
    end
end

function GM13.Ent:IsContextMenuBlocked(ent, ply)
    if ply and ply:IsPlayer() then
        return ent:GetNWBool("gm13_context_menu_" .. ply:SteamID())
    else
        return ent:GetNWBool("gm13_context_menu")
    end
end

-- Set fake invalid (breaks numerous iterations, mainly used to simulate a brush) (wild)

function GM13.Ent:IsFakeInvalid(ent)
    return ent:GetNWBool("gm13_fake_invalid") and true
end

function GM13.Ent:SetFakeInvalid(ent, value)
    ent:SetNWBool("gm13_fake_invalid", value)
end

function IsValid(var)
    if not GM13_IsValid(var) then return false end
    if IsEntity(var) and var.GetNWBool and GM13.Ent:IsFakeInvalid(var) then return false end
    return true
end

-- Curse (events use this information in a variety of ways)

function GM13.Ent:SetCursed(ent, value)
    ent.gm13_cursed = value
end

function GM13.Ent:IsCursed(ent)
    return ent.gm13_cursed
end

function GM13.Ent:HideCurse(ent, value)
    ent.gm13_hide_curse = value
end

function GM13.Ent:IsCurseHidden(ent)
    return ent.gm13_hide_curse
end

-- Sounds

function GM13.Ent:SetMute(ent, value)
    ent.gm13_muted = value
end

function GM13.Ent:IsMuted(ent)
    return ent.gm13_muted
end

hook.Add("EntityEmitSound", "gm13_sound_control", function(soundTab)
    if soundTab.Entity and GM13.Ent:IsMuted(soundTab.Entity) then
        return false
    end
end)

-- Fade

local function Fade(ent, fadingTime, callback, args, isIn)
    if not ent or not ent:IsValid() then return end

    local hookName = "gm13_fade_" .. (isIn and "in" or "out") .. "_" .. tostring(ent)
    local maxTime = CurTime() + fadingTime
    local renderMode = ent:GetRenderMode()
    local color = ent:GetColor()

    -- Make fade out prevail over fade in
    if not isIn and hook.GetTable()["Tick"] and hook.GetTable()["Tick"]["gm13_fade_in_" .. tostring(ent)] then
        hook.Remove("Tick", "gm13_fade_in_" .. tostring(ent))
    end

    ent:SetRenderMode(RENDERMODE_TRANSCOLOR) -- Note: it doesn't work with everything

    hook.Add("Tick", hookName, function()
        if CurTime() >= maxTime or not ent:IsValid() then
            if ent:IsValid() then
                ent:SetRenderMode(renderMode)

                if callback and isfunction(callback) then
                    callback(unpack(args))
                end
            end

            hook.Remove("Tick", hookName)
        else
            local percentage = (isIn and 1 or 0) - (maxTime - CurTime()) / fadingTime * (isIn and 1 or -1)

            ent:SetColor(Color(color.r, color.g, color.b, color.a * percentage))
        end
    end)
end

function GM13.Ent:FadeIn(ent, fadingTime, callback, ...)
    Fade(ent, fadingTime, callback, { ... }, true)
end

function GM13.Ent:FadeOut(ent, fadingTime, callback, ...)
    Fade(ent, fadingTime, callback, { ... })
end

-- Set fake classname (By Zaurzo - A.R.C.)

function GM13.Ent:IsClassFake(ent)
    return ent:GetNWBool("gm13_fake_class_name") and true
end

function GM13.Ent:SetFakeClass(ent, class)
    ent:SetNWString("gm13_fake_class_name", class)
end

function GM13.Ent:GetRealClass(ent)
    return GM13_ENT_GetClass(ent)
end

ENT.GetClass = function(self)
    if GM13.Ent:IsClassFake(self) then return self:GetNWString("gm13_fake_class_name") end
    return GM13_ENT_GetClass(self)
end

-- Hide information from HUDs and ent finders
-- See /base/addon/entinfo

function GM13.Ent:IsInfoHidden(ent)
    return ent:GetNWBool("gm13_cover_ent_name") and true
end

function GM13.Ent:HideInfo(ent, value)
    ent:SetNWBool("gm13_cover_ent_name", value)
end

-- Conditional callback

function GM13.Ent:CallOnCondition(ent, condition, callback, ...)
    local name = tostring(ent)
    local args = { ... }

    timer.Create(name, 0.2, 0, function()
        if not ent:IsValid() then
            timer.Remove(name)
            return
        end

        if not condition() then return end

        timer.Remove(name)

        callback(unpack(args))
    end)
end