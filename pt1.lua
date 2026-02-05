--[[
    Mahiru Script for Fish It! - WindUI Edition
    UI Library: WindUI by Footagesus
    Script by: LangitDev
    Version: 1.0.0
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

-- Variables
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerGui = LocalPlayer.PlayerGui

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/WindUI.lua"))()

-- Game Variables
local Net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local Remotes = {
    RE_FishCaught = Net:WaitForChild("RE/FishCaught"),
    RE_Fishing = Net:WaitForChild("RE/FishingCompleted"),
    RF_Charge = Net:WaitForChild("RF/ChargeFishingRod"),
    RF_Minigame = Net:WaitForChild("RF/RequestFishingMinigameStarted"),
    RF_Cancel = Net:WaitForChild("RF/CancelFishingInputs"),
    RF_Sell = Net:WaitForChild("RF/SellAllItems"),
    RF_Weather = Net:WaitForChild("RF/PurchaseWeatherEvent"),
    RF_Radar = Net:WaitForChild("RF/UpdateFishingRadar"),
    RF_EquipDiving = Net:WaitForChild("RF/EquipOxygenTank"),
    RF_UnequipDiving = Net:WaitForChild("RF/UnequipOxygenTank"),
    RF_PurchaseRod = Net:WaitForChild("RF/PurchaseFishingRod"),
    RF_PurchaseBait = Net:WaitForChild("RF/PurchaseBait"),
    RF_PurchaseBoat = Net:WaitForChild("RF/PurchaseBoat"),
    RE_Cutscene = Net:WaitForChild("RE/ReplicateCutscene"),
    RE_StopCutscene = Net:WaitForChild("RE/StopCutscene"),
    RF_AutoFishing = Net:WaitForChild("RF/UpdateAutoFishingState"),
    RE_EquipItem = Net:WaitForChild("RE/EquipItem"),
    RE_Altar = Net:WaitForChild("RE/ActivateEnchantingAltar"),
    RE_Altar2 = Net:WaitForChild("RE/ActivateSecondEnchantingAltar"),
    RE_Equip = Net:WaitForChild("RE/EquipToolFromHotbar"),
    RE_Unequip = Net:WaitForChild("RE/UnequipToolFromHotbar"),
    RE_Favorite = Net:WaitForChild("RE/FavoriteItem"),
    RE_FavoriteChanged = Net:WaitForChild("RE/FavoriteStateChanged"),
    RE_ReplicateTextEffect = Net:WaitForChild("RE/ReplicateTextEffect"),
    RE_ObtainedNewFishNotification = Net:WaitForChild("RE/ObtainedNewFishNotification"),
    RE_FishingMinigameEvent = Net:WaitForChild("RE/FishingMinigameChanged"),
    RF_Trade = Net:WaitForChild("RF/InitiateTrade"),
}

local Replion = require(ReplicatedStorage.Packages.Replion)
local FishingController = require(ReplicatedStorage.Controllers.FishingController)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

-- State Variables
local LegitFishingDelay = 0.2
local ShakeDelay = 0.15
local InstantFishingDelay = 0.1
local BlatantReelDelay = 1.9
local BlatantFishingDelay = 1.1
local BlatantBaitDelay = 0.3 
local BlatantCastDelay = 0.70    
local IsLegitFishing = false
local IsAutoShake = false
local IsInstantFishing = false
local IsBlatantFishing = false

local IsBlatantV3 = false
local V3_CastDelay     = 0.3   
local V3_CancelDelay   = 3      
local V3_CompleteDelay= 0.8    
local CurrentFishCount = 0

local AutoSellMode = "Delay" 
local AutoSellValue = 60
local IsAutoSell = false
local LastSellTick = 0

local IsNoClip = false
local IsInfiniteJump = false
local IsFlyEnabled = false
local FlySpeed = 1
local IsNoAnimation = false
local IsHideRod = false
local IsWalkOnWater = false
local IsMaxZoom = false
local IsDisableVFX = false
local IsDisableCutscene = false
local IsDisableFishNotification = false

local ESPEnabled = false
local ESPObjects = {}

-- Fish Data
local FishData = {}

-- Webhook Config
local WebhookConfig = {
    Enabled = false,
    URL = "",
    TierFilter = {},
    NameFilter = {},
    HideName = ""
}

-- Create Main Window
local Window = WindUI:CreateWindow("Mahiru Script", UDim2.new(0, 650, 0, 550))

-- Create Toggle Button
local function CreateToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Name = "ToggleUIButton"
    
    local button = Instance.new("ImageButton")
    button.Parent = screenGui
    button.Size = UDim2.new(0, 40, 0, 40)
    button.Position = UDim2.new(0, 20, 0, 100)
    button.BackgroundTransparency = 1
    button.Image = "rbxassetid://78018573702743"
    button.ScaleType = Enum.ScaleType.Fit
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
     
    button.MouseButton1Click:Connect(function()
        Window.MainFrame.Visible = not Window.MainFrame.Visible
    end)
    
    local dragging = false
    local dragStart, startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

CreateToggleButton()

-- Toggle Window with F3
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F3 then
        Window.MainFrame.Visible = not Window.MainFrame.Visible
    end
end)

-- Helper Functions
local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.0fK", num / 1000)
    end
    return tostring(num)
end

local function GetFishCount()
    local bagLabel = PlayerGui.Inventory.Main.Top.Options.Fish.Label.BagSize
    local text = bagLabel.Text or "0/???"
    local current = tonumber(text:match("(%d+)/")) or 0
    return current
end

local function GetThumbnailUrl(assetId)
    local id = assetId:match("rbxassetid://(%d+)")
    if not id then return nil end
    
    local url = string.format("https://thumbnails.roblox.com/v1/assets?assetIds=%s&type=Asset&size=420x420&format=Png", id)
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    return success and response.data and response.data[1] and response.data[1].imageUrl
end

local function SendWebhook(url, data)
    if not url or url == "" then return end
    
    local requestFunc = syn and syn.request or http_request or http and http.request or fluxus and (fluxus.request or request)
    if not requestFunc then
        warn("Executor doesn't support HTTP requests")
        return
    end
    
    pcall(function()
        requestFunc({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Fishing Functions
local function StartLegitFishing()
    IsLegitFishing = true
    FishingController._autoLoop = true
    
    task.spawn(function()
        while IsLegitFishing do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.05)

            local chargeBar = PlayerGui.Charge.Main.CanvasGroup.Bar
            local startTime = tick()
            
            while chargeBar:IsDescendantOf(PlayerGui) do
                if chargeBar.Size.Y.Scale < 0.95 then
                    task.wait(0.001)
                    if tick() - startTime > 1 then break end
                else
                    break
                end
            end
            
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

            local fishCaught = false
            local waitStart = tick()
            
            while tick() - waitStart < 3 do
                if FishingController:GetCurrentGUID() then
                    fishCaught = true
                    break
                end
                task.wait(0.05)
            end
            
            if fishCaught then
                if IsAutoShake then
                    while FishingController:GetCurrentGUID() do
                        pcall(function()
                            FishingController:RequestFishingMinigameClick()
                        end)
                        task.wait(ShakeDelay)
                    end
                end
                
                task.wait(LegitFishingDelay)
                pcall(function()
                    Remotes.RE_Fishing:FireServer()
                end)

                task.wait(1.3)
            end
            
            task.wait(0.05)
        end
    end)
end

local function StartInstantFishing()
    IsInstantFishing = true
    Remotes.RF_AutoFishing:InvokeServer(true)
    
    task.spawn(function()
        while IsInstantFishing do
            local success, guid, power = pcall(function()
                return Remotes.RF_Charge:InvokeServer(workspace:GetServerTimeNow())
            end)
            
            if success and type(power) == "number" then
                task.wait(0.3)
                pcall(function()
                    Remotes.RF_Minigame:InvokeServer(-1, 0.999, power)
                end)
                
                task.wait(InstantFishingDelay)
                pcall(function()
                    Remotes.RE_Fishing:FireServer()
                end)
            end
            
            task.wait(0.05)
        end
    end)
end

local function StartBlatantFishing()
    IsBlatantFishing = true
    Remotes.RF_AutoFishing:InvokeServer(true)
    
    task.spawn(function()
        while IsBlatantFishing do
            pcall(function()
                Remotes.RF_Cancel:InvokeServer()
            end)
            local _, _, power = Remotes.RF_Charge:InvokeServer(workspace:GetServerTimeNow())
            Remotes.RF_Minigame:InvokeServer(-1, 0.999, power)
            task.wait(BlatantBaitDelay)
            Remotes.RE_Fishing:FireServer()
            task.wait(BlatantCastDelay)
        end
    end)
end

-- Auto Sell Function
local function StartAutoSell()
    IsAutoSell = true
    
    task.spawn(function()
        while IsAutoSell do
            local bagLabel = PlayerGui.Inventory.Main.Top.Options.Fish.Label.BagSize
            local current, max = 0, 0
            
            if bagLabel and bagLabel:IsA("TextLabel") then
                local currentStr, maxStr = (bagLabel.Text or ""):match("(%d+)%s*/%s*(%d+)")
                current = tonumber(currentStr) or 0
                max = tonumber(maxStr) or 0
            end
            
            if AutoSellMode == "Delay" then
                Remotes.RF_Sell:InvokeServer()
                task.wait(AutoSellValue * 60) 
            elseif AutoSellMode == "Count" then
                if current >= AutoSellValue then
                    Remotes.RF_Sell:InvokeServer()
                end
                task.wait(1)
            end
        end
    end)
end

-- Create Sections
local InfoSection = Window:Section("Info")
local PlayerSection = Window:Section("Player")
local FishingSection = Window:Section("Fishing")
local AutoSection = Window:Section("Automatic")
local WebhookSection = Window:Section("Webhook")
local QuestSection = Window:Section("Quest")
local ShopSection = Window:Section("Shop")
local TeleportSection = Window:Section("Teleport")

-- Info Section
InfoSection:Label("Mahiru Script for Fish It!")
InfoSection:Label("WindUI Edition")
InfoSection:Label("By LangitDev")

InfoSection:Button("Copy Discord", function()
    if setclipboard then
        setclipboard("discord.gg/mahiruscript")
    end
end)

InfoSection:Button("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- Player Section
PlayerSection:Label("Movement")
local walkSpeedSlider = PlayerSection:Slider("Walk Speed", 16, 200, 16, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

local jumpPowerSlider = PlayerSection:Slider("Jump Power", 50, 500, 50, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
end)

PlayerSection:Toggle("Infinite Jump", false, function(value)
    IsInfiniteJump = value
end)

UserInputService.JumpRequest:Connect(function()
    if IsInfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerSection:Toggle("NoClip", false, function(value)
    IsNoClip = value
end)

RunService.Stepped:Connect(function()
    if IsNoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fishing Section
FishingSection:Label("Legit Fishing")
FishingSection:Input("Legit Delay", "0.2", function(value)
    LegitFishingDelay = tonumber(value) or 0.2
end)

FishingSection:Input("Shake Delay", "0.15", function(value)
    ShakeDelay = tonumber(value) or 0.15
end)

local legitToggle = FishingSection:Toggle("Legit Fishing", false, function(value)
    if value then
        StartLegitFishing()
    else
        IsLegitFishing = false
        FishingController._autoLoop = false
    end
end)

local shakeToggle = FishingSection:Toggle("Auto Shake", false, function(value)
    IsAutoShake = value
end)

FishingSection:Label("Instant Fishing")
FishingSection:Input("Instant Delay", "0.1", function(value)
    InstantFishingDelay = tonumber(value) or 0.1
end)

local instantToggle = FishingSection:Toggle("Instant Fishing", false, function(value)
    if value then
        StartInstantFishing()
    else
        IsInstantFishing = false
        Remotes.RF_AutoFishing:InvokeServer(false)
    end
end)

FishingSection:Label("Blatant Fishing")
FishingSection:Input("Bait Delay", "0.3", function(value)
    BlatantBaitDelay = tonumber(value) or 0.3
end)

FishingSection:Input("Cast Delay", "0.70", function(value)
    BlatantCastDelay = tonumber(value) or 0.70
end)

local blatantToggle = FishingSection:Toggle("Blatant Fishing", false, function(value)
    if value then
        StartBlatantFishing()
    else
        IsBlatantFishing = false
        Remotes.RF_AutoFishing:InvokeServer(false)
    end
end)

FishingSection:Button("Recovery Fishing", function()
    pcall(function()
        Remotes.RF_Cancel:InvokeServer()
    end)
end)

-- Auto Section
AutoSection:Dropdown("Sell Mode", {"Delay", "Count"}, "Delay", function(value)
    AutoSellMode = value
end)

AutoSection:Input("Sell Value", "60", function(value)
    AutoSellValue = tonumber(value) or 60
end)

AutoSection:Toggle("Auto Sell", false, function(value)
    if value then
        StartAutoSell()
    else
        IsAutoSell = false
    end
end)

-- Webhook Section
WebhookSection:Input("Webhook URL", "", function(value)
    WebhookConfig.URL = value
end)

WebhookSection:Dropdown("Tier Filter", {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}, {"Mythic", "Secret"}, function(value)
    WebhookConfig.TierFilter = value
end)

WebhookSection:Input("Hide Name", "", function(value)
    WebhookConfig.HideName = value
end)

WebhookSection:Toggle("Enable Webhook", false, function(value)
    WebhookConfig.Enabled = value
end)

-- Quest Section
QuestSection:Button("Deep Sea Quest", function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-3763, -135, -995)
    end
end)

QuestSection:Button("Treasure Room", function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-3601, -283, -1611)
    end
end)

QuestSection:Button("Element Quest", function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(1484, 3, -336)
    end
end)

-- Shop Section
local Rods = {
    ["Starter Rod (50)"] = 1,
    ["Chrome Rod (43.7K)"] = 7,
    ["Lucky Rod (15K)"] = 4,
    ["Steampunk Rod (215K)"] = 6,
    ["Astral Rod (1M)"] = 5,
}

local Baits = {
    ["Starter Bait (0)"] = 1,
    ["Chroma Bait (290K)"] = 6,
    ["Gold Bait (0)"] = 4,
    ["Hyper Bait (0)"] = 5,
    ["Luck Bait (1K)"] = 2,
}

ShopSection:Dropdown("Select Rod", {"Starter Rod (50)", "Chrome Rod (43.7K)", "Lucky Rod (15K)", "Steampunk Rod (215K)", "Astral Rod (1M)"}, "Starter Rod (50)", function(value)
    SelectedRod = value
end)

ShopSection:Button("Purchase Rod", function()
    if SelectedRod and Rods[SelectedRod] then
        pcall(function()
            Remotes.RF_PurchaseRod:InvokeServer(Rods[SelectedRod])
        end)
    end
end)

ShopSection:Dropdown("Select Bait", {"Starter Bait (0)", "Chroma Bait (290K)", "Gold Bait (0)", "Hyper Bait (0)", "Luck Bait (1K)"}, "Starter Bait (0)", function(value)
    SelectedBait = value
end)

ShopSection:Button("Purchase Bait", function()
    if SelectedBait and Baits[SelectedBait] then
        pcall(function()
            Remotes.RF_PurchaseBait:InvokeServer(Baits[SelectedBait])
        end)
    end
end)

-- Teleport Section
local Locations = {
    ["Ancient Jungle"] = Vector3.new(1272.5, 7.8, -191.5),
    ["Coral Reefs"] = Vector3.new(-3031.9, 2.5, 2276.4),
    ["Fisherman Island"] = Vector3.new(33, 3.3, 2764),
    ["Kohana"] = Vector3.new(-684.1, 3, 800.8),
    ["Tropical Grove"] = Vector3.new(-2018.9, 9, 3750.6),
    ["Weather Machine"] = Vector3.new(-1524.9, 2.9, 1915.6),
}

TeleportSection:Dropdown("Select Location", {"Ancient Jungle", "Coral Reefs", "Fisherman Island", "Kohana", "Tropical Grove", "Weather Machine"}, "Ancient Jungle", function(value)
    SelectedLocation = value
end)

TeleportSection:Button("Teleport", function()
    if SelectedLocation and Locations[SelectedLocation] then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(Locations[SelectedLocation])
        end
    end
end)

-- Anti-AFK
local VirtualUserRef = cloneref(game:GetService("VirtualUser")) or game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
   VirtualUserRef:CaptureController()
   VirtualUserRef:ClickButton2(Vector2.new())
end)

-- Cleanup Function
Window.CloseButton.MouseButton1Click:Connect(function()
    -- Stop all fishing loops
    IsLegitFishing = false
    IsInstantFishing = false
    IsBlatantFishing = false
    IsAutoSell = false
    
    -- Reset player stats
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
    
    -- Disable fishing
    FishingController._autoLoop = false
    pcall(function()
        Remotes.RF_AutoFishing:InvokeServer(false)
    end)
    
    print("Mahiru Script closed!")
end)

-- Load Fish Data
task.spawn(function()
    local ItemsFolder = ReplicatedStorage:WaitForChild("Items")
    if not ItemsFolder then return end
    
    for _, module in ipairs(ItemsFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local success, data = pcall(require, module)
            if success and data and data.Data and data.Data.Type == "Fish" then
                FishData[data.Data.Id] = {
                    Name = data.Data.Name,
                    Tier = data.Data.Tier,
                    Icon = data.Data.Icon,
                    SellPrice = data.SellPrice
                }
            end
        end
    end
end)

print("Mahiru Script Loaded Successfully!")
print("WindUI Edition by LangitDev")
print("Press F3 to toggle UI")