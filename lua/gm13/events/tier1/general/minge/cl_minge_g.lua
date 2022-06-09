net.Receive("gm13_print_cough", function()
    timer.Create("gm13_minge_cough", 0.05, math.random(100, 200), function()
        local message = ""

        for i = 0, math.random(1, 7) do
            message = message .. " cough "
        end

        chat.AddText(Color(255, 255, 255), message)
    end)
end)

net.Receive("gm13_hide_minges", function()
    for k, aliveMinge in ipairs(ents.FindByClass("gm13_mingebag")) do
        aliveMinge:Hide()
    end
end)