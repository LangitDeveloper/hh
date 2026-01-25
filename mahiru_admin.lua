local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local AdminPanel = {
    Players = {},
    IsAdmin = false
}

function AdminPanel:CheckAdmin()
    local localPlayer = Players.LocalPlayer
    local adminIds = {
        8515724699
    }
    
    local adminNames = {
        "LangitDev"
    }
    
    for _, id in ipairs(adminIds) do
        if localPlayer.UserId == id then
            self.IsAdmin = true
            return true
        end
    end
    
    for _, name in ipairs(adminNames) do
        if localPlayer.Name == name then
            self.IsAdmin = true
            return true
        end
    end
    
    return false
end

function AdminPanel:SendCommandToAll(command, data)
    if not self.IsAdmin then
        warn("[Admin] You are not admin!")
        return false
    end
    
    local adminEvent = ReplicatedStorage:FindFirstChild("MahiruAdminEvent")
    if not adminEvent then
        adminEvent = Instance.new("RemoteEvent")
        adminEvent.Name = "MahiruAdminEvent"
        adminEvent.Parent = ReplicatedStorage
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            adminEvent:FireClient(player, command, data)
        end
    end
    
    print("[Admin] Command sent to all players:", command)
    return true
end

function AdminPanel:GetMahiruUsers()
    local mahiruUsers = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
           
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local mahiruGui = playerGui:FindFirstChild("Mahiru") or 
                                 playerGui:FindFirstChild("MahiruPingFPS")
                if mahiruGui then
                    table.insert(mahiruUsers, player)
                end
            end
        end
    end
    
    return mahiruUsers
end

local AdminUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LangitDeveloper/hh/main/mahiruui.lua"))()
local AdminWindow = AdminUI:CreateWindow({
    Title = "MAHIRU ADMIN PANEL",
    Icon = "rbxassetid://78018573702743",
    Size = UDim2.fromOffset(450, 500),
})

if not AdminPanel:CheckAdmin() then
    AdminWindow:Destroy()
    warn("[Admin] Access denied! You are not admin.")
    return
end

local ControlTab = AdminWindow:Tab({Title = "Remote Control", Icon = "radio"})

local playerList = ControlTab:Label({
    Title = "Connected Players",
    Desc = "Loading...",
})

task.spawn(function()
    while task.wait(5) do
        local users = AdminPanel:GetMahiruUsers()
        playerList:Set(string.format("Mahiru Users: %d/%d", 
            #users, #Players:GetPlayers() - 1))
    end
end)

ControlTab:Section({Title = "🚨 FORCE RESTART"})

local RestartMessage = ControlTab:Input({
    Title = "Restart Message",
    Placeholder = "Server restarting...",
    Value = "Admin forced server restart!",
})

ControlTab:Button({
    Title = "🔥 RESTART ALL PLAYERS",
    Desc = "Force all Mahiru users to restart",
    Callback = function()
        local confirm = AdminUI:Confirm({
            Title = "CONFIRM RESTART",
            Desc = "This will restart ALL Mahiru users in this server!\n\nAre you sure?",
            Buttons = {
                {
                    Title = "YES, RESTART EVERYONE",
                    Callback = function()
                        AdminPanel:SendCommandToAll("restart_all", {
                            message = RestartMessage.Value
                        })
                        
                        AdminUI:Notify({
                            Title = "RESTART COMMAND SENT!",
                            Content = "All players will restart in 5 seconds",
                            Duration = 5,
                            Icon = "refresh-cw",
                        })
                    end
                },
                {Title = "Cancel"}
            }
        })
    end,
})

ControlTab:Section({Title = "📢 BROADCAST MESSAGE"})

local BroadcastTitle = ControlTab:Input({
    Title = "Message Title",
    Placeholder = "Important Announcement",
    Value = "ADMIN BROADCAST",
})

local BroadcastMessage = ControlTab:Input({
    Title = "Message Content",
    Placeholder = "Type your message here...",
    Value = "",
})

ControlTab:Button({
    Title = "SEND TO ALL PLAYERS",
    Callback = function()
        if BroadcastMessage.Value == "" then
            AdminUI:Notify({
                Title = "Error",
                Content = "Please enter a message",
                Icon = "alert-circle",
            })
            return
        end
        
        AdminPanel:SendCommandToAll("broadcast", {
            title = BroadcastTitle.Value,
            message = BroadcastMessage.Value,
            duration = 10,
            icon = "megaphone"
        })
        
        AdminUI:Notify({
            Title = "Message Sent!",
            Content = "Broadcast sent to all players",
            Duration = 3,
            Icon = "check-circle",
        })
        
        BroadcastMessage:Set("")
    end,
})

ControlTab:Section({Title = "⚙️ CONTROL FEATURES"})

local FeatureSelect = ControlTab:Dropdown({
    Title = "Select Feature",
    Values = {"auto_fishing", "auto_sell", "fps_booster", "ghost_mode", "esp"},
    Value = "auto_fishing",
})

local FeatureState = ControlTab:Toggle({
    Title = "Feature State",
    Desc = "ON = Enable, OFF = Disable",
    Default = true,
})

ControlTab:Button({
    Title = "TOGGLE FOR ALL",
    Desc = "Enable/disable feature for everyone",
    Callback = function()
        AdminPanel:SendCommandToAll("toggle_feature", {
            feature = FeatureSelect.Value,
            state = FeatureState.Value
        })
        
        AdminUI:Notify({
            Title = "Feature Control Sent",
            Content = FeatureSelect.Value .. " set to " .. tostring(FeatureState.Value),
            Icon = "toggle-right",
        })
    end,
})

ControlTab:Section({Title = "🎯 MASS CONTROL"})

ControlTab:Button({
    Title = "🔄 RESTART SERVER",
    Desc = "Restart server (including yourself)",
    Callback = function()
        AdminPanel:SendCommandToAll("restart_all", {
            message = "Server restarting now!"
        })
        
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    end,
})

ControlTab:Button({
    Title = "⏸️ STOP ALL FISHING",
    Desc = "Disable all fishing features",
    Callback = function()
        local features = {"auto_fishing", "auto_shake", "instant_fishing", "blatant_fishing"}
        
        for _, feature in ipairs(features) do
            AdminPanel:SendCommandToAll("toggle_feature", {
                feature = feature,
                state = false
            })
            task.wait(0.1)
        end
        
        AdminUI:Notify({
            Title = "All Fishing Stopped",
            Content = "Disabled fishing for all players",
            Duration = 3,
            Icon = "square-slash",
        })
    end,
})

ControlTab:Button({
    Title = "▶️ START ALL FISHING",
    Desc = "Enable all fishing features",
    Callback = function()
        AdminPanel:SendCommandToAll("toggle_feature", {
            feature = "auto_fishing",
            state = true
        })
        
        AdminUI:Notify({
            Title = "Fishing Started",
            Content = "Enabled fishing for all players",
            Duration = 3,
            Icon = "play",
        })
    end,
})

ControlTab:Section({Title = "🛠️ ADMIN TOOLS"})

ControlTab:Button({
    Title = "📊 GET PLAYER INFO",
    Callback = function()
        local users = AdminPanel:GetMahiruUsers()
        local info = string.format("Total Players: %d\nMahiru Users: %d\n\n", 
            #Players:GetPlayers(), #users)
        
        for i, player in ipairs(users) do
            info = info .. string.format("%d. %s (Level: ?)\n", i, player.Name)
        end
        
        AdminUI:Alert({
            Title = "Player Information",
            Desc = info,
            Buttons = {{Title = "Close"}}
        })
    end,
})

ControlTab:Button({
    Title = "🎮 TELEPORT TO ME",
    Desc = "Bring all players to your location",
    Callback = function()
        local char = Players.LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
     
        AdminPanel:SendCommandToAll("execute_all", {
            code = [[
                local player = game.Players.LocalPlayer
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(]] .. tostring(root.Position.X) .. [[, ]] .. 
                        tostring(root.Position.Y) .. [[, ]] .. tostring(root.Position.Z) .. [[)
                    end
                end
            ]]
        })
        
        AdminUI:Notify({
            Title = "Teleport Command Sent",
            Content = "All players coming to your location",
            Icon = "map-pin",
        })
    end,
})

AdminUI:Notify({
    Title = "🔓 ADMIN PANEL UNLOCKED",
    Content = "Welcome, Developer!",
    Duration = 5,
    Icon = "shield-check",
})