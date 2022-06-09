-- Persistent event memories
-- Events can have unlimited memories

-- FULLY reset memories
if CLIENT then
    net.Receive("gm13_clear_memories", function()
        GM13.Event.Memory:Reset()
    end)
end

function GM13.Event.Memory:Reset()
    file.Delete(self.filename)

    self.list = {}
    self.swaped = {}
    self.Incompatibility.list = {}
    self.Dependency.providers = {}
    self.Dependency.dependents = {}

    if SERVER then
        net.Start("gm13_clear_memories")
        net.Broadcast()
    end
end

-- Set a memory
function GM13.Event.Memory:Set(memoryName, value, doNotRefreshScenes, broadcasted)
    if CLIENT and not broadcasted then
        Error("ERROR! Clientside gm13 memories are intended to be a copy of the server memories. Do not define clientside exclusive memories!")
        return
    end

    self.list[memoryName] = value

    if SERVER then
        self:Save()
    end

    if not doNotRefreshScenes then
        GM13.Event:ReloadByMemory()
    end

    if SERVER then
        net.Start("gm13_broadcast_memory")
        net.WriteString(memoryName)
        net.WriteBool(doNotRefreshScenes)
        net.WriteString(value and util.TableToJSON({ value }) or "")
        net.Broadcast()
    end
end

-- Get a memory
function GM13.Event.Memory:Get(memoryName)
    return memoryName and self.list[memoryName]
end

-- Get the memories list
function GM13.Event.Memory:GetList()
    return self.list
end

-- Toggle existing memories
function GM13.Event.Memory:Toggle(ply, cmd, args, doNotRefreshScenes)
    local memoryNameIn = args[1]

    if not memoryNameIn then return end

    local function swapValue(memoryNameIn)
        local value = self.list[memoryNameIn]
        local swapedValue = not value and self.swaped[memoryNameIn] or nil
        
        self.swaped[memoryNameIn] = value
        self:Set(memoryNameIn, swapedValue, doNotRefreshScenes)
    end

    if memoryNameIn == "enabled" then
        for memoryName, memoryValue in pairs(self.list) do
            swapValue(memoryName)
        end

        print("Done")
    elseif memoryNameIn == "disabled" then
        for memoryName, memoryValue in pairs(self.swaped) do
            swapValue(memoryName)
        end

        print("Done")
    elseif self.list[memoryNameIn] ~= nil or self.swaped[memoryNameIn] ~= nil then
        swapValue(memoryNameIn)
        print("  " .. memoryNameIn .. " = " .. tostring(self.list[memoryNameIn]))
    end
end

-- List memories information
function GM13.Event.Memory:List()
    local enabled, disabled = {}, {}

    for memoryName, memoryState in pairs(self.list) do
        if memoryState then
            table.insert(enabled, memoryName)
        else
            table.insert(disabled, memoryName)
        end
    end

    for memoryName, _ in pairs(self.swaped) do
        table.insert(disabled, memoryName)
    end

    print([[Options:
  enabled
  disabled]])

    if #enabled > 0 then
        print("\nEnabled:")
        for k, memoryName in SortedPairs(enabled) do
            print("  " .. memoryName)
        end
    end

    if #disabled > 0 then
        print("\nDisabled:")
        for k, memoryName in SortedPairs(disabled) do
            print("  " .. memoryName)
        end
    end
end

