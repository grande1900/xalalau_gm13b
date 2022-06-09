-- Events are blocked or removed if incompatible memories are set

-- Set an event incompatible with a memory
function GM13.Event.Memory.Incompatibility:Set(eventName, ...)
	for _, memoryName in ipairs({ ... }) do
        self.list[eventName] = self.list[eventName] or {}
        self.list[eventName][memoryName] = true
    end
end

-- Get the incompatible event memories
function GM13.Event.Memory.Incompatibility:Get(eventName)
    return self.list[eventName]
end

-- Get the incompatibilities list
function GM13.Event.Memory.Incompatibility:GetList()
    return self.list
end

-- Check if the event is incompatible with the loaded memories
function GM13.Event.Memory.Incompatibility:Check(eventName)
    if self.list[eventName] then
        for memoryName, memoryValue in pairs(GM13.Event.Memory:GetList()) do
            if self.list[eventName][memoryName] then
                return true
            end
        end
    end

    return false
end
