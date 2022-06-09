-- Persistent event memories
-- Events can have unlimited memories

net.Receive("gm13_ask_for_memories", function(_, ply)
    GM13.Event.Memory:SendAllMemories(ply)
end)

-- Load memories from file
function GM13.Event.Memory:Load()
    local memoriesFile = file.Read(self.filename, "Data")

    self.list = util.JSONToTable(memoriesFile or "{}")
end

-- Save a memory
function GM13.Event.Memory:Save()
    file.Write(self.filename, util.TableToJSON(self.list, true))
end

-- Writes active server memories on clients
function GM13.Event.Memory:SendAllMemories(ply)
    net.Start("gm13_broadcast_memories")
    net.WriteTable(self.list)
    net.Send(ply)
end
