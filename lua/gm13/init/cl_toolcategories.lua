-- Show our tools only in devmode

local function HandleToolCategories()
    if not GM13.Tool.categoriesPanel:IsValid() then
        GM13.Tool.categoriesPanel = nil
        return
    end

    if #GM13.Tool.categoryControllers == 0 then
        local categoryNamesSearch = {}
        for k, categoryName in ipairs(GM13.Tool.categoryNames) do
            categoryNamesSearch[categoryName] = true
        end

        for k, GModCategory in ipairs(GM13.Tool.categoriesPanel:GetChildren()) do
            if GModCategory.Header then
                local GModCategoryName = GModCategory.Header:GetText()

                if categoryNamesSearch[GModCategoryName] then
                    table.insert(GM13.Tool.categoryControllers, GModCategory)
                end
            end
        end
    end

    for k, GModCategory in ipairs(GM13.Tool.categoryControllers) do
        if not GModCategory:IsValid() then
            GM13.Tool.categoryControllers = {}
            break
        else
            if GM13.devMode then
                GModCategory:Show()
                GModCategory:DoExpansion(true)
            else
                GModCategory:Hide()
                GModCategory:DoExpansion(false)
            end
        end
    end
end

hook.Add("OnSpawnMenuOpen", "gm13_deal_with_tools_category", function()
    if GM13.Tool.categoriesPanel then
        HandleToolCategories()
    else
        timer.Create("gm13_handle_tools_category", 0.2, 60, function()
            local categoriesPanel = istable(g_SpawnMenu:GetChildren()) and
                                           #g_SpawnMenu:GetChildren() >= 2 and
                                    istable(g_SpawnMenu:GetChildren()[2]:GetChildren()) and
                                           #g_SpawnMenu:GetChildren()[2]:GetChildren() >= 2 and
                                    istable(g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()) and
                                           #g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren() >= 2 and
                                    istable(g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren()) and
                                           #g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren() >= 1 and
                                    istable(g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren()[1]:GetChildren()) and
                                           #g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren()[1]:GetChildren() >=2 and
                                    istable(g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren()[1]:GetChildren()[2]:GetChildren()) and
                                           #g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren()[1]:GetChildren()[2]:GetChildren() >=2 and
                                    istable(g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren()[1]:GetChildren()[2]:GetChildren()[2]:GetChildren()) and
                                           #g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren()[1]:GetChildren()[2]:GetChildren()[2]:GetChildren() >=1 and
                                            g_SpawnMenu:GetChildren()[2]:GetChildren()[2]:GetChildren()[2]:GetChildren()[1]:GetChildren()[2]:GetChildren()[2]:GetChildren()[1]

            if categoriesPanel then
                GM13.Tool.categoriesPanel = categoriesPanel
                timer.Remove("gm13_handle_tools_category")
                HandleToolCategories()
            end
        end)
    end
end)

function GM13:RegisterToolCategories(base)
    if not base.toolCategories then return end

    table.Add(GM13.Tool.categoryNames, base.toolCategories)
end