-- Player spawn

function GM13.Ply:CallOnSpawn(ply, isOnce, callback, ...)
    if callback then
        ply.gm13_on_ply_spawn_callback = { func = callback, once = isOnce, args = { ... } }
    end
end

function GM13.Ply:GetOnSpawnCallback(ply)
    return ply.gm13_on_ply_spawn_callback
end

function GM13.Ply:RemoveOnSpawnCallback(ply)
    ply.gm13_on_ply_spawn_callback = nil
end

hook.Add("PlayerSpawn", "gm13_ply_spawn_control", function(ply, transition)
    local callbackInfo = GM13.Ply:GetOnSpawnCallback(ply)

    if callbackInfo and isfunction(callbackInfo.func) then
        callbackInfo.func(ply, transition, unpack(callbackInfo.args))

        if callbackInfo.once then
            GM13.Ply:RemoveOnSpawnCallback(ply)
        end
    end
end)

-- Switch noclip mode

function GM13.Ply:BlockNoclip(ply, value)
    ply.gm13_noclip = value

    if value and ply:GetMoveType() == MOVETYPE_NOCLIP then
        ply:SetMoveType(MOVETYPE_WALK)
    end
end

function GM13.Ply:IsNoclipBlocked(ply)
    return ply.gm13_noclip
end

hook.Add("Move", "gm13_player_noclip_control", function(ply, mv)
    -- With this hook I prevent noclip via SetMoveType
    if ply:GetMoveType() == MOVETYPE_NOCLIP and GM13.Ply:IsNoclipBlocked(ply) then
        ply:SetMoveType(MOVETYPE_WALK)
    end
end)
