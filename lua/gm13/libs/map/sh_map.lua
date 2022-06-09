-- Manage detours

GM13_gameCleanUpMap = GM13_gameCleanUpMap or game.CleanUpMap

-- Cleanup

function GM13.Map:BlockCleanup(value)
    self.blockCleanup = value
end

function GM13.Map:IsCleanupBlocked()
    return self.blockCleanup
end

function game.CleanUpMap(...)
    if not GM13.Map:IsCleanupBlocked() then
        GM13_gameCleanUpMap(...)
    end
end
