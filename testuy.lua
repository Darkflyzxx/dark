if not getgenv().StingrayLoaded then
    getgenv().StingrayLoaded = true -- Init
    local StartTime = tick()
    local LocalPlayer = game:GetService("Players").LocalPlayer

    -- Load Configs--
    -- Webhook
    pcall(function()
        if getgenv().Webhook then
            writefile("JJI_Webhook.txt", getgenv().Webhook)
        end
        if readfile("JJI_Webhook.txt") then
            getgenv().Webhook = readfile("JJI_Webhook.txt")
        end
    end)

    -- Luck Boosts
    getgenv().LuckBoosts = {}
    pcall(function()
        local LuckConfigs = game:HttpGet("http://de3.bot-hosting.net:21824/jji/getconfig?username=" .. LocalPlayer.Name)
        if LuckConfigs ~= "None Found" then
            for Item in string.gmatch(LuckConfigs, "([^,]+)") do
                Item = string.gsub(Item, "^%s+", "")
                table.insert(getgenv().LuckBoosts, Item)
            end
        else
            getgenv().LuckBoosts = {"Luck Vial", "Withered Beckoning Cat"}
        end
    end)    

    -- Constants
    local Cats = {"Withered Beckoning Cat", "Wooden Beckoning Cat", "Polished Beckoning Cat"}
    local Highlight = {"Maximum Scroll", "Domain Shard", "Iridescent Lotus", "Polished Beckoning Cat", "Sapphire Lotus", "Fortune Gourd", "Demon Finger", "Energy Nature Scroll", "Purified Curse Hand", "Jade Lotus", "Cloak of Inferno", "Split Soul", "Soul Robe", "Playful Cloud", "Ocean Blue Sailor's Vest", "Deep Black Sailor's Vest", "Demonic Tobi", "Demonic Robe", "Rotten Chains"}

    if Toggle == "ON" then
        local s, e = pcall(function()
            queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Proxidy/Prodigy-Script/refs/heads/main/BOSS2.lua"))()')
        end)
    end)

    -- Destroy fx --
    Effects.ChildAdded:Connect(function(Child)
        if Child.Name ~= "DomainSphere" then
            game:GetService("Debris"):AddItem(Child, 0)
        end
    end)

    game:GetService("Lighting").ChildAdded:Connect(function(Child)
        game:GetService("Debris"):AddItem(Child, 0)
    end)

    Destructibles.ChildAdded:Connect(function(Child)
        game:GetService("Debris"):AddItem(Child, 0)
    end)

    -- Uh, ignore this spaghetti way of determining screen center --
    local MouseTarget = Instance.new("Frame", LocalPlayer.PlayerGui:FindFirstChildWhichIsA("ScreenGui"))
    MouseTarget.Size = UDim2.new(0, 0, 0, 0)
    MouseTarget.Position = UDim2.new(0.5, 0, 0.5, 0)
    MouseTarget.AnchorPoint = Vector2.new(0.5, 0.5)
    local X, Y = MouseTarget.AbsolutePosition.X, MouseTarget.AbsolutePosition.Y

    -- Use boosts --
    for _, Item in pairs(getgenv().LuckBoosts) do
        task.wait()
        if (not table.find(Cats, Item)) or LocalPlayer.ReplicatedData.luckBoost.duration.Value == 0 then
            print(Item .. " used:", game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Data"):WaitForChild("EquipItem"):InvokeServer(Item))
        end
    end

    -- Overwrite chest collection function --
    local s, e = pcall(function()
        game:GetService("ReplicatedStorage").Remotes.Client.CollectChest.OnClientInvoke = function()
            print("Chest Collected")
            return {}
        end
    end)

    task.spawn(function()
        while Drops:FindFirstChild("Chest") or LootUI.Enabled do
            if not LootUI.Enabled then
                OpenChest()
            else
                repeat
                    Click(Flip)
                until not LootUI.Enabled
            end
            task.wait()
        end
    end)

    repeat
        task.wait()
    until not (Drops:FindFirstChild("Chest") or LootUI.Enabled)

    -- Send webhook message --
    pcall(function()
        if getgenv().Webhook then
            task.wait(2)
            local embed = {
                ["title"] = LocalPlayer.Name .. " has defeated " .. Boss .. " in " .. tostring(math.floor((tick() - StartTime) * 10) / 10) .. " seconds",
                ['description'] = "Collected Items: " .. Items,
                ["color"] = tonumber(000000)
            }
            local a = request({
                Url = getgenv().Webhook,
                Headers = {['Content-Type'] = 'application/json'},
                Body = game:GetService("HttpService"):JSONEncode({['embeds'] = {embed}, ['avatar_url'] = "https://static1.personality-database.com/profile_images/5ffd2b8117ec4108ab69efcb70983731.png"}),
                Method = "POST"
            })
        end
    end)

    -- Click replay --
    task.wait()
    pcall(function()
        writefile("JJI_LastBoss.txt", Boss)
    end)
    task.wait(2)
    for i = 1, 10, 1 do
        Click(Replay)
        task.wait(1)
    end
end
