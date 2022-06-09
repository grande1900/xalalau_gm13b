-- Persistent event memories
-- Events can have unlimited memories

net.Receive("gm13_broadcast_memory", function()
    local memoryName = net.ReadString()
    local doNotRefreshScenes = net.ReadBool()
    local value = util.JSONToTable(net.ReadString())

    value = value and unpack(value)

    GM13.Event.Memory:Set(memoryName, value, doNotRefreshScenes, true)
end)

net.Receive("gm13_broadcast_memories", function()
    GM13.Event.Memory:ReceiveAllMemories(net.ReadTable())
    hook.Run("gm13_memories_received")
end)

-- Send active server memories to clients
function GM13.Event.Memory:ReceiveAllMemories(serverMemories)
    for memoryName, value in pairs(serverMemories) do
        self.list[memoryName] = value
    end
end 
