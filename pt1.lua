-- MAHIRU SCRIPT - CONVERTED TO CHLOE X LIBRARY
-- By LangitDev
-- DECRYPT BY MAHIRU

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

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
local ItemTradingController = require(ReplicatedStorage.Controllers.ItemTradingController)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local VendorUtility = require(ReplicatedStorage.Shared.VendorUtility)
local PlayerStatsUtility = require(ReplicatedStorage.Shared.PlayerStatsUtility)

local PlayerData = Replion.Client:WaitReplion("Data")
local ItemsFolder = ReplicatedStorage:WaitForChild("Items")
local DivingGearData = ItemUtility.GetItemDataFromItemType("Gears", "Diving Gear")

local PlayerGui = LocalPlayer.PlayerGui
local MerchantUI = {
    MerchantRoot = PlayerGui.Merchant.Main.Background,
    ItemsFrame = PlayerGui.Merchant.Main.Background.Items.ScrollingFrame,
    RefreshMerchant = PlayerGui.Merchant.Main.Background.RefreshLabel,
}

-- LOAD CHLOE X LIBRARY
local ChloeX = loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))()
CURRENT_VERSION = "Mahiru_v2.0"

-- CREATE WINDOW WITH CHLOE X LIBRARY
local Window = ChloeX:CreateWindow({
    Title = "Mahiru - Fish It!",
    SubTitle = "By LangitDev",
    TabWidth = 160,
    TabPadding = 4,
    Size = UDim2.new(0, 600, 0, 450),
    Theme = "Dark"
})

-- CREATE TABS (Menggunakan AddTab seperti yang diminta)
local InfoTab = Window:AddTab({Title = "Info", Icon = "info"})
local PlayerTab = Window:AddTab({Title = "Player", Icon = "player"})
local FishingTab = Window:AddTab({Title = "Fishing", Icon = "rod"})
local AutomaticTab = Window:AddTab({Title = "Automatic", Icon = "next"})
local WebhookTab = Window:AddTab({Title = "Webhook", Icon = "web"})
local QuestTab = Window:AddTab({Title = "Quest", Icon = "scroll"})
local UtilitiesTab = Window:AddTab({Title = "Utilities", Icon = "settings"})
local ShopTab = Window:AddTab({Title = "Shop", Icon = "shop"})
local TeleportTab = Window:AddTab({Title = "Teleport", Icon = "gps"})

-- KONFIGURASI AWAL
local ConfigData = {}
local Elements = {}

-- Fungsi untuk save config
local function SaveConfig()
    for key, element in pairs(Elements) do
        if element.Get then
            ConfigData[key] = element:Get()
        end
    end
    SaveConfig()
end

-- Fungsi untuk load config
local function LoadConfig()
    LoadConfigFromFile()
    LoadConfigElements()
end

-- SECTION CREATION FUNCTION
local function CreateSection(tab, title)
    return tab:AddSection({Title = title})
end

-- NOTIFICATION FUNCTION
local function Notify(title, content, color)
    ChloeX:MakeNotify({
        Title = title,
        Description = content,
        Color = color or Color3.fromRGB(255, 0, 255),
        Delay = 3
    })
end

-- ============================
-- INFO TAB
-- ============================
local InfoSection = CreateSection(InfoTab, "Information")

InfoSection:AddLabel({
    Title = "Mahiru Script",
    Description = "Welcome to Mahiru Script for Fish It!\nConverted to Chloe X Library"
})

InfoSection:AddButton({
    Title = "Copy Discord Link",
    Description = "Click to copy Mahiru Discord link",
    Callback = function()
        if setclipboard then
            setclipboard("discord.gg/mahiruscript")
            Notify("Success", "Discord link copied!", Color3.fromRGB(0, 255, 0))
        end
    end
})

InfoSection:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

InfoSection:AddButton({
    Title = "Server Hop",
    Callback = function()
        local placeId = game.PlaceId
        local servers = {}
        local cursor = nil
        
        while true do
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor then url = url .. "&cursor=" .. cursor end
            
            local success, response = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            
            if success and response and response.data then
                for _, server in pairs(response.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                    end
                end
                
                cursor = response.nextPageCursor
                if not cursor then break end
            else
                break
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
        else
            Notify("Error", "No servers available", Color3.fromRGB(255, 0, 0))
        end
    end
})

-- ============================
-- PLAYER TAB
-- ============================
local InterfaceSection = CreateSection(PlayerTab, "User Interface")
local MovementSection = CreateSection(PlayerTab, "Movement")
local ModesSection = CreateSection(PlayerTab, "Modes")
local BoostSection = CreateSection(PlayerTab, "Boost Player")

-- Theme Toggle
local ThemeToggle = InterfaceSection:AddToggle({
    Title = "Change Theme",
    Description = "Dark = OFF | Light = ON",
    Default = false,
    Callback = function(value)
        if value then
            Window:SetTheme("Light")
        else
            Window:SetTheme("Dark")
        end
    end
})
Elements["themeToggle"] = ThemeToggle

-- WalkSpeed Slider
local WalkSpeedSlider = MovementSection:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})
Elements["walkSpeed"] = WalkSpeedSlider

-- JumpPower Slider
local JumpPowerSlider = MovementSection:AddSlider({
    Title = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end
})
Elements["jumpPower"] = JumpPowerSlider

-- Reset Button
MovementSection:AddButton({
    Title = "Reset Speed and Jump",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
            WalkSpeedSlider:Set(16)
            JumpPowerSlider:Set(50)
            Notify("Success", "Speed and jump reset", Color3.fromRGB(0, 255, 0))
        end
    end
})

-- No Animation Toggle
local NoAnimationToggle = ModesSection:AddToggle({
    Title = "No Animations",
    Default = false,
    Callback = function(value)
        IsNoAnimation = value
        if value then
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop(0)
                    end
                end
            end
        end
    end
})
Elements["noAnimation"] = NoAnimationToggle

-- Infinite Jump Toggle
local InfiniteJumpToggle = ModesSection:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(value)
        IsInfiniteJump = value
    end
})
Elements["infiniteJump"] = InfiniteJumpToggle

-- Noclip Toggle
local NoClipToggle = ModesSection:AddToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(value)
        IsNoClip = value
        if value then
            Notify("Noclip", "Noclip enabled", Color3.fromRGB(0, 255, 0))
        end
    end
})
Elements["noclip"] = NoClipToggle

-- ============================
-- FISHING TAB
-- ============================
local FishingSection = CreateSection(FishingTab, "Auto Fishing")

-- Legit Fishing Variables
local LegitFishingDelay = 0.2
local ShakeDelay = 0.15
local IsLegitFishing = false
local IsAutoShake = false

-- Legit Fishing Delay Input
local LegitDelayInput = FishingSection:AddTextBox({
    Title = "Legit Delay",
    Placeholder = "Default: 0.2",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            LegitFishingDelay = num
        end
    end
})
Elements["legitDelay"] = LegitDelayInput

-- Shake Delay Input
local ShakeDelayInput = FishingSection:AddTextBox({
    Title = "Shake Delay",
    Placeholder = "Default: 0.15",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            ShakeDelay = num
        end
    end
})
Elements["shakeDelay"] = ShakeDelayInput

-- Legit Fishing Toggle
local LegitFishingToggle = FishingSection:AddToggle({
    Title = "Legit Fishing",
    Default = false,
    Callback = function(value)
        if value then
            StartLegitFishing()
        else
            IsLegitFishing = false
            FishingController._autoLoop = false
        end
    end
})
Elements["legitFishing"] = LegitFishingToggle

-- Auto Shake Toggle
local AutoShakeToggle = FishingSection:AddToggle({
    Title = "Auto Shake",
    Description = "Spam click during fishing",
    Default = false,
    Callback = function(value)
        IsAutoShake = value
    end
})
Elements["autoShake"] = AutoShakeToggle

-- Instant Fishing Section
local InstantSection = CreateSection(FishingTab, "Instant Fishing")

InstantSection:AddLabel({
    Title = "Instant Fishing Settings",
    Description = "For instant fishing, set the completion delay"
})

local InstantFishingDelay = 0.1
local InstantDelayInput = InstantSection:AddTextBox({
    Title = "Delay Complete",
    Placeholder = "Default: 0.1",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            InstantFishingDelay = num
        end
    end
})
Elements["instantDelay"] = InstantDelayInput

local InstantFishingToggle = InstantSection:AddToggle({
    Title = "Instant Fishing",
    Description = "Auto instantly catch fish",
    Default = false,
    Callback = function(value)
        if value then
            StartInstantFishing()
        else
            IsInstantFishing = false
            Remotes.RF_AutoFishing:InvokeServer(false)
        end
    end
})
Elements["instantFishing"] = InstantFishingToggle

-- ============================
-- AUTOMATIC TAB
-- ============================
local SellSection = CreateSection(AutomaticTab, "Auto Sell")
local WeatherSection = CreateSection(AutomaticTab, "Auto Buy Weather")
local FavoriteSection = CreateSection(AutomaticTab, "Favorite Features")

-- Auto Sell Variables
local AutoSellMode = "Delay"
local AutoSellValue = 60
local IsAutoSell = false

-- Sell Mode Dropdown
SellSection:AddDropdown({
    Title = "Select Sell Mode",
    Options = {"Delay", "Count"},
    Default = "Delay",
    Callback = function(value)
        AutoSellMode = value
    end
})

-- Sell Value Input
SellSection:AddTextBox({
    Title = "Sell Value",
    Placeholder = "Delay = Minute | Count = Fish Count",
    Callback = function(value)
        local num = tonumber(value) or 1
        AutoSellValue = num
    end
})

-- Auto Sell Toggle
local AutoSellToggle = SellSection:AddToggle({
    Title = "Auto Sell All",
    Default = false,
    Callback = function(value)
        if value then
            StartAutoSell()
        else
            IsAutoSell = false
        end
    end
})
Elements["autoSell"] = AutoSellToggle

-- Weather Dropdown
local WeatherDropdown = WeatherSection:AddDropdown({
    Title = "Select Weather",
    Options = {
        "Cloudy ($10,000)",
        "Wind ($10,000)",
        "Snow ($15,000)",
        "Storm ($35,000)",
        "Radiant ($50,000)",
        "Shark Hunt ($300,000)"
    },
    Multi = true,
    Callback = function(value)
        SelectedWeathers = {}
        for _, weather in ipairs(value) do
            local name = weather:match("^(.-) %(") or weather
            table.insert(SelectedWeathers, name)
        end
    end
})
Elements["weatherSelect"] = WeatherDropdown

-- ============================
-- WEBHOOK TAB
-- ============================
local WebhookSection = CreateSection(WebhookTab, "Webhook Configuration")

local WebhookURLInput = WebhookSection:AddTextBox({
    Title = "Webhook URL",
    Placeholder = "Input Discord Webhook URL",
    Callback = function(value)
        WebhookConfig.URL = value
    end
})
Elements["webhookURL"] = WebhookURLInput

WebhookSection:AddDropdown({
    Title = "Tier Filter",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = true,
    Callback = function(value)
        WebhookConfig.TierFilter = value
    end
})

local WebhookToggle = WebhookSection:AddToggle({
    Title = "Send Fish Webhook",
    Default = false,
    Callback = function(value)
        WebhookConfig.Enabled = value
    end
})
Elements["webhookEnabled"] = WebhookToggle

-- ============================
-- SHOP TAB
-- ============================
local RodSection = CreateSection(ShopTab, "Purchase Rod")
local BaitSection = CreateSection(ShopTab, "Purchase Bait")
local BoatSection = CreateSection(ShopTab, "Purchase Boat")

-- Rods Database
local Rods = {
    ["Chrome Rod (43.7K)"] = {Id = 7, Price = 43700},
    ["Lucky Rod (15K)"] = {Id = 4, Price = 15000},
    ["Magma Rod (0)"] = {Id = 3, Price = 0},
    ["Starter Rod (50)"] = {Id = 1, Price = 50},
    ["Steampunk Rod (215K)"] = {Id = 6, Price = 215000},
    ["Hyper Rod (0)"] = {Id = 9, Price = 0},
    ["Gold Rod (0)"] = {Id = 8, Price = 0},
    ["Lava Rod (0)"] = {Id = 2, Price = 0},
    ["Carbon Rod (750)"] = {Id = 76, Price = 750},
    ["Gingerbread Rod (0)"] = {Id = 103, Price = 0},
    ["Ice Rod (5K)"] = {Id = 78, Price = 5000},
    ["Luck Rod (325)"] = {Id = 79, Price = 325},
    ["Midnight Rod (50K)"] = {Id = 80, Price = 50000},
    ["Toy Rod (0)"] = {Id = 84, Price = 0},
    ["Grass Rod (1.5K)"] = {Id = 85, Price = 1500},
    ["Candy Cane Rod (0)"] = {Id = 100, Price = 0},
    ["Christmas Tree Rod (0)"] = {Id = 101, Price = 0},
    ["Demascus Rod (3K)"] = {Id = 77, Price = 3000},
    ["Frozen Rod (0)"] = {Id = 102, Price = 0},
    ["Cute Rod (0)"] = {Id = 123, Price = 0},
    ["Angelic Rod (75K)"] = {Id = 124, Price = 75000},
    ["Astral Rod (1M)"] = {Id = 5, Price = 1000000},
    ["Ares Rod (3M)"] = {Id = 126, Price = 3000000},
    ["Ghoul Rod (0)"] = {Id = 129, Price = 0},
    ["Angler Rod (8M)"] = {Id = 168, Price = 8000000},
    ["Ghostfinn Rod (0)"] = {Id = 169, Price = 0},
    ["Element Rod (0)"] = {Id = 257, Price = 0},
    ["Hazmat Rod (0)"] = {Id = 256, Price = 0},
    ["Fluorescent Rod (715K)"] = {Id = 255, Price = 715000},
    ["Bamboo Rod (12M)"] = {Id = 258, Price = 12000000},
    ["Studded Rod (0)"] = {Id = 400, Price = 0},
}

local RodOptions = {}
for name, _ in pairs(Rods) do
    table.insert(RodOptions, name)
end
table.sort(RodOptions)

local SelectedRod = nil
local RodDropdown = RodSection:AddDropdown({
    Title = "Select Rod",
    Options = RodOptions,
    Callback = function(value)
        SelectedRod = value
    end
})

RodSection:AddButton({
    Title = "Purchase Rod",
    Callback = function()
        if not SelectedRod then
            Notify("Error", "Select rod first!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        local rodData = Rods[SelectedRod]
        if rodData then
            pcall(function()
                Remotes.RF_PurchaseRod:InvokeServer(rodData.Id)
                Notify("Success", "Purchased: " .. SelectedRod, Color3.fromRGB(0, 255, 0))
            end)
        end
    end
})

-- ============================
-- TELEPORT TAB
-- ============================
local LocationSection = CreateSection(TeleportTab, "Location")
local PlayerSection = CreateSection(TeleportTab, "Player Teleport")

-- Locations Database
local Locations = {
    "Ancient Jungle",
    "Ancient Jungle Outside",
    "Ancient Ruin",
    "Coral Reefs SPOT 1",
    "Coral Reefs SPOT 2",
    "Coral Reefs SPOT 3",
    "Creater Island Grounds",
    "Creater Island Top",
    "Crystaline Pessage",
    "Esotoric Deep",
    "Fishermand Island",
    "Kohana",
    "Kohana SPOT 1",
    "Kohana SPOT 2",
    "Kohana Volcano",
    "Lost Shore",
    "Sacred Temple",
    "Sisyphus Statue",
    "Stingray Shores",
    "Treasure Room",
    "Tropical Grove",
    "Tropical Grove Cafe 1",
    "Tropical Grove Cafe 2",
    "Tropical Grove Highground",
    "Underground Cellar",
    "Weather Machine",
    "Pirate Cove"
}

local LocationCoordinates = {
    ["Ancient Jungle"] = Vector3.new(1272.5, 7.8, -191.5),
    ["Ancient Jungle Outside"] = Vector3.new(1488, 7.6, -392),
    ["Ancient Ruin"] = Vector3.new(6090, -585.9, 4634),
    ["Coral Reefs SPOT 1"] = Vector3.new(-3031.9, 2.5, 2276.4),
    ["Coral Reefs SPOT 2"] = Vector3.new(-3270.9, 2.5, 2228.1),
    ["Coral Reefs SPOT 3"] = Vector3.new(-3136.1, 2.6, 2126.1),
    ["Creater Island Grounds"] = Vector3.new(1079.6, 3.6, 5080.4),
    ["Creater Island Top"] = Vector3.new(1011.3, 22.7, 5076.3),
    ["Crystaline Pessage"] = Vector3.new(6051, -538.9, 4386),
    ["Esotoric Deep"] = Vector3.new(3181, -1302.7, 1425),
    ["Fishermand Island"] = Vector3.new(33, 3.3, 2764),
    ["Kohana"] = Vector3.new(-684.1, 3, 800.8),
    ["Kohana SPOT 1"] = Vector3.new(-367.8, 6.8, 521.9),
    ["Kohana SPOT 2"] = Vector3.new(-624, 19.3, 419.4),
    ["Kohana Volcano"] = Vector3.new(-561.8, 21.2, 156.7),
    ["Lost Shore"] = Vector3.new(-3738, 5.4, -854.7),
    ["Sacred Temple"] = Vector3.new(1475, -21.9, -632),
    ["Sisyphus Statue"] = Vector3.new(-3703.7, -135.6, -1017.2),
    ["Stingray Shores"] = Vector3.new(32.5, 24.8, 3039.4),
    ["Treasure Room"] = Vector3.new(-3602, -266.6, -1577.2),
    ["Tropical Grove"] = Vector3.new(-2018.9, 9, 3750.6),
    ["Tropical Grove Cafe 1"] = Vector3.new(-2151, 2.5, 3671),
    ["Tropical Grove Cafe 2"] = Vector3.new(-2018, 4.5, 3756),
    ["Tropical Grove Highground"] = Vector3.new(-2139, 53.5, 3624),
    ["Underground Cellar"] = Vector3.new(2136, -91.2, -699),
    ["Weather Machine"] = Vector3.new(-1524.9, 2.9, 1915.6),
    ["Pirate Cove"] = Vector3.new(3207.78, 9.10, 3546.13),
}

local LocationDropdown = LocationSection:AddDropdown({
    Title = "Choose Location",
    Options = Locations,
    Default = "Ancient Jungle",
    Callback = function(value)
        SelectedLocation = value
    end
})
Elements["teleportLocation"] = LocationDropdown

LocationSection:AddButton({
    Title = "Teleport to Location",
    Callback = function()
        if not SelectedLocation then
            Notify("Error", "Select location first!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        local coordinates = LocationCoordinates[SelectedLocation]
        if coordinates then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(coordinates) + Vector3.new(0, 3, 0)
                Notify("Teleported", "Teleported to: " .. SelectedLocation, Color3.fromRGB(0, 255, 0))
            end
        end
    end
})

-- ============================
-- FUNCTIONS YANG DIPERLUKAN
-- ============================

function StartLegitFishing()
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

function StartInstantFishing()
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

function StartAutoSell()
    IsAutoSell = true
    
    task.spawn(function()
        while IsAutoSell do
            if AutoSellMode == "Delay" then
                pcall(function()
                    Remotes.RF_Sell:InvokeServer()
                end)
                task.wait(AutoSellValue * 60)
            elseif AutoSellMode == "Count" then
                local bagLabel = PlayerGui.Inventory.Main.Top.Options.Fish.Label.BagSize
                if bagLabel and bagLabel:IsA("TextLabel") then
                    local currentStr = (bagLabel.Text or ""):match("(%d+)%s*/")
                    local current = tonumber(currentStr) or 0
                    
                    if current >= AutoSellValue then
                        pcall(function()
                            Remotes.RF_Sell:InvokeServer()
                        end)
                    end
                end
                task.wait(1)
            end
        end
    end)
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Window Toggle Button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleUIButton"
ToggleButton.Parent = game:GetService("CoreGui")
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Image = "rbxassetid://78018573702743"

ToggleButton.MouseButton1Click:Connect(function()
    Window:Toggle()
end)

-- Set Toggle Key
Window:SetToggleKey(Enum.KeyCode.F3)

-- Load Configuration
LoadConfig()

-- Cleanup on destroy
Window:OnDestroy(function()
    -- Save config
    SaveConfig()
    
    -- Turn off all toggles
    if LegitFishingToggle then LegitFishingToggle:Set(false) end
    if AutoShakeToggle then AutoShakeToggle:Set(false) end
    if InstantFishingToggle then InstantFishingToggle:Set(false) end
    if AutoSellToggle then AutoSellToggle:Set(false) end
    if WebhookToggle then WebhookToggle:Set(false) end
    
    -- Reset player stats
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
    
    -- Remove toggle button
    if ToggleButton then
        ToggleButton:Destroy()
    end
    
    print("Mahiru cleaned up successfully!")
end)

print("Mahiru Script - Converted to Chloe X Library")
print("Happy Fishing!")