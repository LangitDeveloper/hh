local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local AdminPanel = {
    Players = {},
    IsAdmin = false
}

function AdminPanel:CheckAdmin()
    local localPlayer = Players.LocalPlayer
    print("[Admin] Checking admin for:", localPlayer.Name, "ID:", localPlayer.UserId)
    
    local adminIds = {
        8515724699
    }
    
    local adminNames = {
        "dytihfay"
    }
    
    -- AUTO CHECK: Tampilkan semua info
    print("[Admin] Admin IDs:", table.concat(adminIds, ", "))
    print("[Admin] Admin Names:", table.concat(adminNames, ", "))
    
    for _, id in ipairs(adminIds) do
        if localPlayer.UserId == id then
            print("[Admin] ✓ Admin by ID:", id)
            self.IsAdmin = true
            return true
        end
    end
    
    for _, name in ipairs(adminNames) do
        if localPlayer.Name == name then
            print("[Admin] ✓ Admin by name:", name)
            self.IsAdmin = true
            return true
        end
    end
    
    print("[Admin] ✗ Not admin")
    return false
end

function AdminPanel:SendCommandToAll(command, data)
    if not self.IsAdmin then
        warn("[Admin] You are not admin!")
        return false
    end
    
    print("[Admin] Sending command:", command, "data:", data)
    
    local adminEvent = ReplicatedStorage:FindFirstChild("MahiruAdminEvent")
    if not adminEvent then
        print("[Admin] Creating MahiruAdminEvent...")
        adminEvent = Instance.new("RemoteEvent")
        adminEvent.Name = "MahiruAdminEvent"
        adminEvent.Parent = ReplicatedStorage
        print("[Admin] MahiruAdminEvent created")
    else
        print("[Admin] MahiruAdminEvent found")
    end
    
    local successCount = 0
    local totalPlayers = #Players:GetPlayers() - 1
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local success, err = pcall(function()
                adminEvent:FireClient(player, command, data)
            end)
            
            if success then
                successCount = successCount + 1
                print("[Admin] ✓ Sent to:", player.Name)
            else
                warn("[Admin] ✗ Failed to send to", player.Name, "Error:", err)
            end
        end
    end
    
    print(string.format("[Admin] Command '%s' sent to %d/%d players", 
        command, successCount, totalPlayers))
    
    return successCount > 0
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
                    print("[Admin] Found Mahiru user:", player.Name)
                end
            end
        end
    end
    
    return mahiruUsers
end

-- LOAD UI
print("[Admin] Loading UI...")
local success, AdminUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LangitDeveloper/hh/main/mahiruui.lua"))()
end)

if not success or not AdminUI then
    warn("[Admin] Failed to load UI!")
    return
end

print("[Admin] Creating window...")
local AdminWindow = AdminUI:CreateWindow({
    Title = "MAHIRU ADMIN PANEL",
    Icon = "rbxassetid://78018573702743",
    Size = UDim2.fromOffset(450, 500),
})

-- CHECK ADMIN
print("[Admin] Checking admin status...")
if not AdminPanel:CheckAdmin() then
    print("[Admin] Not admin, showing access denied...")
    
    -- Tampilkan window kosong untuk non-admin
    local DeniedTab = AdminWindow:Tab({Title = "ACCESS DENIED", Icon = "lock"})
    DeniedTab:Section({Title = "🔒 UNAUTHORIZED"})
    
    DeniedTab:Paragraph({
        Title = "Admin Panel Locked",
        Desc = "This panel is only for developers.\n\nYour User ID: " .. Players.LocalPlayer.UserId,
    })
    
    AdminUI:Notify({
        Title = "Access Denied",
        Content = "You are not authorized to use Admin Panel",
        Duration = 5,
        Icon = "shield-off",
    })
    
    return
end

print("[Admin] Access granted, creating control tab...")

-- ADMIN CONTROL TAB
local ControlTab = AdminWindow:Tab({Title = "Remote Control", Icon = "radio"})


ControlTab:Section({Title = "🚨 FORCE RESTART"})

local RestartMessage = ControlTab:Input({
    Title = "Restart Message",
    Placeholder = "Server restarting...",
    Value = "Admin forced server restart!",
})

ControlTab:Button({
    Title = "🔥 RESTART ALL PLAYERS",
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
    end,
})

-- BROADCAST SECTION
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
    Title = "📤 SEND TO ALL PLAYERS",
    Callback = function()
        if BroadcastMessage.Value == "" then
            AdminUI:Notify({
                Title = "Error",
                Content = "Please enter a message",
                Icon = "alert-circle",
            })
            return
        end
        
        local success = AdminPanel:SendCommandToAll("broadcast", {
            title = BroadcastTitle.Value,
            message = BroadcastMessage.Value,
            duration = 10,
            icon = "megaphone"
        })
        
        if success then
            AdminUI:Notify({
                Title = "✅ Message Sent!",
                Content = "Broadcast sent to all players",
                Duration = 3,
                Icon = "check-circle",
            })
            BroadcastMessage:Set("")
        else
            AdminUI:Notify({
                Title = "❌ Failed",
                Content = "Could not send broadcast",
                Duration = 3,
                Icon = "circle-x",
            })
        end
    end,
})

-- FEATURE CONTROL
ControlTab:Section({Title = "⚙️ CONTROL FEATURES"})

local FeatureSelect = ControlTab:Dropdown({
    Title = "Select Feature",
    Values = {"auto_fishing", "auto_sell", "fps_booster", "ghost_mode", "esp"},
    Value = "auto_fishing",
})

local FeatureState = ControlTab:Toggle({
    Title = "Feature State",
    Default = true,
})

ControlTab:Button({
    Title = "🔄 TOGGLE FOR ALL",
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

-- MASS CONTROL
ControlTab:Section({Title = "🎯 MASS CONTROL"})

ControlTab:Button({
    Title = "🔄 RESTART SERVER (INCLUDING YOU)",
    Callback = function()
        AdminPanel:SendCommandToAll("restart_all", {
            message = "Server restarting now!"
        })
        
        AdminUI:Notify({
            Title = "Restarting...",
            Content = "You will restart in 3 seconds",
            Duration = 3,
            Icon = "refresh-cw",
        })
        
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    end,
})

ControlTab:Button({
    Title = "⏸️ STOP ALL FISHING",
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

-- ADMIN TOOLS
ControlTab:Section({Title = "🛠️ ADMIN TOOLS"})

ControlTab:Button({
    Title = "📊 GET PLAYER INFO",
    Callback = function()
        local users = AdminPanel:GetMahiruUsers()
        local info = string.format("Total Players: %d\nMahiru Users: %d\n\n", 
            #Players:GetPlayers(), #users)
        
        if #users > 0 then
            for i, player in ipairs(users) do
                info = info .. string.format("%d. %s (ID: %d)\n", i, player.Name, player.UserId)
            end
        else
            info = info .. "No Mahiru users found."
        end
        
        AdminUI:Alert({
            Title = "Player Information",
            Description = info,
            Buttons = {{Title = "Close"}}
        })
    end,
})

ControlTab:Button({
    Title = "🎮 TELEPORT TO ME",
    Callback = function()
        local char = Players.LocalPlayer.Character
        if not char then 
            AdminUI:Notify({
                Title = "Error",
                Content = "Character not found",
                Icon = "alert-circle",
            })
            return 
        end
        
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
                        tostring(root.Position.Y + 5) .. [[, ]] .. tostring(root.Position.Z) .. [[)
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

-- SUCCESS NOTIFICATION
AdminUI:Notify({
    Title = "🔓 ADMIN PANEL UNLOCKED",
    Content = "Welcome, Developer!",
    Duration = 5,
    Icon = "shield-check",
})

print("[Admin] Admin panel loaded successfully!")