-- Prop breaking

function GM13.Prop:CallOnBreak(ent, id, callback, ...)
    if callback then
        ent.gm13_on_break_callback = ent.gm13_on_break_callback or {}
        ent.gm13_on_break_callback[id] = { func = callback, args = { ... } }
    end
end

function GM13.Prop:RemoveOnBreakCallback(ent, id)
    if ent.gm13_on_break_callback then
        ent.gm13_on_break_callback[id] = nil
    end
end

function GM13.Prop:GetOnBreakCallbacks(ent)
    return ent.gm13_on_break_callback
end

hook.Add("PropBreak", "gm13_prop_breaking_control", function(client, prop)
    local callbacks = GM13.Prop:GetOnBreakCallbacks(prop)

    if callbacks then
        for id, callback in pairs(callbacks) do
            if isfunction(callback.func) then
                callback.func(unpack(callback.args))
            end
        end
    end
end)