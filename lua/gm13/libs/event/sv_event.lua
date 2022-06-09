-- Events base

-- New players, devMode: ask for entities information to enable rendering their areas
net.Receive("gm13_event_request_all_render_sv", function(len, ply)
    GM13.Event:SendCustomEnts(ply)
end)

-- Send all custom events to a player or all players
function GM13.Event:SendCustomEnts(ply)
    if not GM13.devMode then return end

    local sendTab = {}
    local currentChuncksID = tostring(sendTab)

    self.lastSentChunksID = currentChuncksID

    for eventName, eventEntlist in pairs(self.customEntityList) do
        for ent, entRenderInfo in pairs(eventEntlist) do
            if not ent:IsValid() then
                self.customEntityList[ent] = nil
            else
                table.insert(sendTab, GM13.Event:GetEntityRenderInfo(ent))
            end
        end
    end

    local sendTab = util.Compress(util.TableToJSON(sendTab))
    local totalSize = string.len(sendTab)
    local chunkSize = 3000 -- 3KB
    local totalChunks = math.ceil(totalSize / chunkSize)

    for i = 1, totalChunks, 1 do
        local startByte = chunkSize * (i - 1) + 1
        local remaining = totalSize - (startByte - 1)
        local endByte = remaining < chunkSize and (startByte - 1) + remaining or chunkSize * i
        local chunk = string.sub(sendTab, startByte, endByte)

        timer.Simple(i * 0.1, function()
            if GM13.Event.lastSentChunksID ~= currentChuncksID then return end

            local isLastChunk = i == totalChunks

            net.Start("gm13_event_send_all_render_cl")
            net.WriteString(currentChuncksID)
            net.WriteUInt(#chunk, 16)
            net.WriteData(chunk, #chunk)
            net.WriteBool(isLastChunk)
            if ply then
                net.Send(ply)
            else
                net.Broadcast()
            end
        end)
    end
end

-- Exposed interface to change events tier
local undoingInvalidTier = false
function GM13.Event:ChangeTier(oldTier, newTier, forceNewTier)
    if undoingInvalidTier then
        undoingInvalidTier = false
        return
    end

    local maxTier = GM13.Event:GetMaxPossibleTier()
    oldTier = tonumber(oldTier)
    newTier = tonumber(newTier)

    if not isnumber(newTier) or (newTier ~= math.floor(newTier)) or not (forceNewTier or GM13.devMode) and (newTier < 1 or newTier > 4) then
        undoingInvalidTier = true
        RunConsoleCommand("gm13_tier", oldTier)
        print("Invalid tier. Choose between 1 and 4.")

        return
    end

    if oldTier ~= newTier or forceNewTier then
        if not (forceNewTier or GM13.devMode) and newTier > maxTier then
            undoingInvalidTier = true
            RunConsoleCommand("gm13_tier", oldTier)
            print("Sorry, not enough power to increase the tier.")
    
            return
        end

        self:InitializeTier()

        if oldTier then -- A single person managed to run this with an uninitialized oldTier, so I added a check.
            print("gm_construct 13 beta " .. (forceNewTier and "forced" or (oldTier > newTier) and "decreased" or "increased") .. " to tier " .. newTier .. ".")
        end
    end
end

-- Reset the map
function GM13.Event:Reset()
    GM13.Event:RemoveAll()
    GM13.Event.Memory:Reset()
    hook.Run("gm13_reset")
    timer.Simple(0.3, function()
        game.CleanUpMap()

        timer.Simple(1, function()
            tier = GetConVar("gm13_tier"):GetInt(1)

            if tier == 1 then
                GM13.Event:ChangeTier(1, 1, true)
            else
                GetConVar("gm13_tier"):SetInt(1)
            end
        end)
    end)
end

-- Cvar callbacks
cvars.AddChangeCallback("gm13_tier", function(cvarName, oldTier, newTier)
    GM13.Event:ChangeTier(oldTier, newTier)
end)

concommand.Add("gm13_reset", function(ply, cmd, args)
    if args[1] ~= "yes" then
        print("If you want to force the map back to its initial state, type \"gm13_reset yes\".")
    else
        GM13.Event:Reset()
    end
end)
