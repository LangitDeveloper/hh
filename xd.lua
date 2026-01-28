local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))()
local WindowConfig = {
    Title = "Chloe X |",
    Footer = "Version 1.0.8",
    Image = "132435516080103",
    Color = Color3.fromRGB(0, 208, 255),
    Theme = 9542022979,
    Version = 4,
}

local MainWindow = Library:Window(WindowConfig)
if MainWindow then
    chloex("Window loaded!")
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Workspace = game:GetService("Workspace")

local Net
local function findNetRemotes()
    local success, result = pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages")
        for _, pkg in pairs(packages:GetChildren()) do
            if string.find(pkg.Name:lower(), "sleitnick") or string.find(pkg.Name:lower(), "net") then
                local netModule = require(pkg)
                if netModule and netModule.Client then
                    Net = netModule.Client
                    print("✅ Found Net library:", pkg.Name)
                    return true
                end
            end
        end
        return false
    end)
    
    if not success or not Net then
        Net = {}
        local remoteCount = 0
        
        local function scanFolder(folder)
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("RemoteEvent") then
                    Net["RE/" .. obj.Name] = obj
                    remoteCount = remoteCount + 1
                elseif obj:IsA("RemoteFunction") then
                    Net["RF/" .. obj.Name] = obj
                    remoteCount = remoteCount + 1
                end
                
                if #obj:GetChildren() > 0 then
                    scanFolder(obj)
                end
            end
        end
        
        scanFolder(ReplicatedStorage)
        print("📡 Found " .. remoteCount .. " remotes manually")
    end
    
    return true
end

for attempt = 1, 5 do
    if findNetRemotes() then
        break
    end
    task.wait(1)
    print("Attempt " .. attempt .. " to find remotes...")
end

local Services = {
    ReplicatedStorage = ReplicatedStorage,
    Players = Players
}

local GameModules = {
    Net = Services.ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net,
    Replion = require(Services.ReplicatedStorage.Packages.Replion),
    FishingController = require(Services.ReplicatedStorage.Controllers.FishingController),
    TradingController = require(Services.ReplicatedStorage.Controllers.ItemTradingController),
    ItemUtility = require(Services.ReplicatedStorage.Shared.ItemUtility),
    VendorUtility = require(Services.ReplicatedStorage.Shared.VendorUtility),
    PlayerStatsUtility = require(Services.ReplicatedStorage.Shared.PlayerStatsUtility),
    Effects = require(Services.ReplicatedStorage.Shared.Effects),
    NotifierFish = require(Services.ReplicatedStorage.Controllers.TextNotificationController),
    InputControl = require(Services.ReplicatedStorage.Modules.InputControl),
    VFX = require(Services.ReplicatedStorage.Controllers.VFXController),
}

local Network = {}
Network.Events = {
    RECutscene = GameModules.Net["RE/ReplicateCutscene"],
    REStop = GameModules.Net["RE/StopCutscene"],
    REFav = GameModules.Net["RE/FavoriteItem"],
    REFavChg = GameModules.Net["RE/FavoriteStateChanged"],
    REFishDone = GameModules.Net["RE/FishingCompleted"],
    REFishGot = GameModules.Net["RE/FishCaught"],
    RENotify = GameModules.Net["RE/TextNotification"],
    REEquip = GameModules.Net["RE/EquipToolFromHotbar"],
    REEquipItem = GameModules.Net["RE/EquipItem"],
    REAltar = GameModules.Net["RE/ActivateEnchantingAltar"],
    REAltar2 = GameModules.Net["RE/ActivateSecondEnchantingAltar"],
    UpdateOxygen = GameModules.Net["URE/UpdateOxygen"],
    REPlayFishEffect = GameModules.Net["RE/PlayFishingEffect"],
    RETextEffect = GameModules.Net["RE/ReplicateTextEffect"],
    REEvReward = GameModules.Net["RE/ClaimEventReward"],
    Totem = GameModules.Net["RE/SpawnTotem"],
    REObtainedNewFishNotification = GameModules.Net["RE/ObtainedNewFishNotification"],
    FishingMinigameChanged = GameModules.Net["RE/FishingMinigameChanged"],
    FishingStopped = GameModules.Net["RE/FishingStopped"],
}

Network.Functions = {
    Trade = GameModules.Net["RF/InitiateTrade"],
    BuyRod = GameModules.Net["RF/PurchaseFishingRod"],
    BuyBait = GameModules.Net["RF/PurchaseBait"],
    BuyWeather = GameModules.Net["RF/PurchaseWeatherEvent"],
    ChargeRod = GameModules.Net["RF/ChargeFishingRod"],
    StartMini = GameModules.Net["RF/RequestFishingMinigameStarted"],
    UpdateRadar = GameModules.Net["RF/UpdateFishingRadar"],
    Cancel = GameModules.Net["RF/CancelFishingInputs"],
    Dialogue = GameModules.Net["RF/SpecialDialogueEvent"],
    SellItem = GameModules.Net["RF/SellItem"],
    Done = GameModules.Net["RF/RequestFishingMinigameStarted"],
    AutoEnabled = GameModules.Net["RF/UpdateAutoFishingState"],
}

local DataStorage = {
    Data = GameModules.Replion.Client:WaitReplion("Data"),
    Items = Services.ReplicatedStorage:WaitForChild("Items"),
    PlayerStat = require(Services.ReplicatedStorage.Packages._Index:FindFirstChild("ytrev_replion@2.0.0-rc.3").replion),
}

local Config = {
    BlatantMode = false, 
    NoAnimation = false, 
    FlyEnabled = false, 
    SpeedEnabled = false, 
    NoclipEnabled = false,
    WalkOnWater = false,
    FlySpeed = 50, 
    WalkSpeed = 50, 
    ReelDelay = 0.1, 
    FishingDelay = 0.2, 
    ChargeTime = 0.3,
    MultiCast = false, 
    CastAmount = 3, 
    CastPower = 0.55, 
    CastAngleMin = -0.8, 
    CastAngleMax = 0.8,
    InstantFish = false, 
    AutoSell = false, 
    AutoSellThreshold = 50,
    AutoBuyEventEnabled = false, 
    SelectedEvent = "Wind", 
    AutoBuyCheckInterval = 5,
    AntiAFKEnabled = true, 
    AutoRejoinEnabled = false, 
    AutoRejoinDelay = 5, 
    AntiLagEnabled = false,
    FullBright = false,
    XRayWater = false
}

local EventList = { "Wind", "Cloudy", "Snow", "Storm", "Radiant", "Shark Hunt" }
local Stats = { StartTime = 0, FishCaught = 0, TotalSold = 0 }
local FishingActive = false

local AnimationController = { IsDisabled = false, Connection = nil }
local FlyController = { BodyVelocity = nil, BodyGyro = nil, Connection = nil }
local NoclipController = { Connection = nil }
local WalkOnWaterController = { Connection = nil }
local AntiAFKController = { Connection = nil, IdleConnection = nil }

function AntiAFKController:Enable()
    if self.IdleConnection then return end
    self.IdleConnection = Player.Idled:Connect(function() 
        if Config.AntiAFKEnabled then 
            VirtualUser:CaptureController() 
            VirtualUser:ClickButton2(Vector2.zero) 
        end 
    end)
    self.Connection = task.spawn(function() 
        while Config.AntiAFKEnabled do 
            pcall(function() 
                VirtualUser:CaptureController() 
                VirtualUser:ClickButton2(Vector2.zero) 
            end) 
            task.wait(30) 
        end 
    end)
end

function AntiAFKController:Disable()
    if self.IdleConnection then 
        self.IdleConnection:Disconnect() 
        self.IdleConnection = nil 
    end
    if self.Connection then 
        task.cancel(self.Connection) 
        self.Connection = nil 
    end
end

if Config.AntiAFKEnabled then 
    AntiAFKController:Enable() 
end

local function toggleNoAnimation(state)
    Config.NoAnimation = state
    
    if state then
        local char = Player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
                
                if AnimationController.Connection then
                    AnimationController.Connection:Disconnect()
                end
                
                AnimationController.Connection = humanoid.AnimationPlayed:Connect(function(track)
                    if Config.NoAnimation then
                        track:Stop()
                    end
                end)
            end
        end
        library:MakeNotification({
            Name = "No Animation",
            Content = "✅ Enabled - All animations stopped",
            Time = 3
        })
    else
        if AnimationController.Connection then
            AnimationController.Connection:Disconnect()
            AnimationController.Connection = nil
        end
        library:MakeNotification({
            Name = "No Animation",
            Content = "❌ Disabled",
            Time = 3
        })
    end
end

function FlyController:Enable()
    if self.Connection then return end
    local function setup()
        local char = Player.Character 
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart") 
        if not root then return end
        
        if self.BodyVelocity then self.BodyVelocity:Destroy() end
        if self.BodyGyro then self.BodyGyro:Destroy() end
        
        self.BodyVelocity = Instance.new("BodyVelocity") 
        self.BodyVelocity.Velocity = Vector3.zero 
        self.BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4) 
        self.BodyVelocity.P = 1000 
        self.BodyVelocity.Parent = root
        
        self.BodyGyro = Instance.new("BodyGyro") 
        self.BodyGyro.MaxTorque = Vector3.new(4e4,4e4,4e4) 
        self.BodyGyro.P = 1000 
        self.BodyGyro.D = 50 
        self.BodyGyro.Parent = root
        
        self.Connection = RunService.Heartbeat:Connect(function()
            if not Config.FlyEnabled or not root then 
                self:Disable() 
                return 
            end
            local cam = Workspace.CurrentCamera 
            if not cam then return end
            self.BodyGyro.CFrame = cam.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            self.BodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * Config.FlySpeed or Vector3.zero
        end)
    end
    setup()
    Player.CharacterAdded:Connect(function() 
        if Config.FlyEnabled then 
            task.wait(1) 
            setup() 
        end 
    end)
end

function FlyController:Disable()
    if self.BodyVelocity then self.BodyVelocity:Destroy() self.BodyVelocity = nil end
    if self.BodyGyro then self.BodyGyro:Destroy() self.BodyGyro = nil end
    if self.Connection then self.Connection:Disconnect() self.Connection = nil end
end

local function updateSpeed()
    local char = Player.Character 
    if char and char:FindFirstChild("Humanoid") then 
        char.Humanoid.WalkSpeed = Config.SpeedEnabled and Config.WalkSpeed or 16 
    end
end

function NoclipController:Enable()
    if self.Connection then return end
    self.Connection = RunService.Stepped:Connect(function()
        if not Config.NoclipEnabled then 
            self:Disable() 
            return 
        end
        local char = Player.Character 
        if char then 
            for _, p in pairs(char:GetDescendants()) do 
                if p:IsA("BasePart") then 
                    p.CanCollide = false 
                end 
            end 
        end
    end)
end

function NoclipController:Disable()
    if self.Connection then self.Connection:Disconnect() self.Connection = nil end
    local char = Player.Character 
    if char then 
        for _, p in pairs(char:GetDescendants()) do 
            if p:IsA("BasePart") then 
                p.CanCollide = true 
            end 
        end 
    end
end

function WalkOnWaterController:Enable()
    if self.Connection then return end
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Config.WalkOnWater then 
            if self.Connection then
                self.Connection:Disconnect()
                self.Connection = nil
            end
            return 
        end
        
        local char = Player.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(0, -50, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if raycastResult then
            local hitPart = raycastResult.Instance
            local hitName = hitPart.Name:lower()
            
            if hitName:find("water") or hitName:find("sea") or hitName:find("ocean") or hitName:find("lake") then
                local waterHeight = hitPart.Position.Y + (hitPart.Size.Y / 2)
                hrp.CFrame = CFrame.new(hrp.Position.X, waterHeight + 2.5, hrp.Position.Z)
            end
        end
    end)
end

function WalkOnWaterController:Disable()
    if self.Connection then 
        self.Connection:Disconnect() 
        self.Connection = nil 
    end
end

local function toggleFullBright(state)
    Config.FullBright = state
    if state then
        Lighting.Brightness = 10
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
    else
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end

local function toggleXRayWater(state)
    Config.XRayWater = state
    if state then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("water") then
                part.Transparency = 0.5
                part.Material = Enum.Material.Glass
            end
        end
    else
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("water") then
                part.Transparency = 0
                part.Material = Enum.Material.Water
            end
        end
    end
end

local function ExecuteFishing()
    pcall(function()
        if Config.MultiCast then
            for i = 1, Config.CastAmount do
                task.spawn(function()
                    pcall(function() Net["RF/ChargeFishingRod"]:InvokeServer() end)
                    if Config.ChargeTime > 0 then task.wait(Config.ChargeTime) end
                    local angle = Config.CastAngleMin + (math.random() * (Config.CastAngleMax - Config.CastAngleMin))
                    pcall(function() Net["RF/RequestFishingMinigameStarted"]:InvokeServer(angle, Config.CastPower, os.clock()) end)
                    if Config.ReelDelay > 0 then task.wait(Config.ReelDelay) end
                    pcall(function() Net["RE/ShakeFish"]:FireServer() Net["RE/ShakeFish"]:FireServer() end)
                    pcall(function() Net["RE/FishingCompleted"]:FireServer() Net["RE/FishingCompleted"]:FireServer() end)
                    Stats.FishCaught = Stats.FishCaught + 1
                end)
            end
            task.wait(Config.ChargeTime + Config.ReelDelay + 0.05)
        elseif Config.InstantFish then
            pcall(function() Net["RF/ChargeFishingRod"]:InvokeServer() end)
            local angle = Config.CastAngleMin + (math.random() * (Config.CastAngleMax - Config.CastAngleMin))
            pcall(function() Net["RF/RequestFishingMinigameStarted"]:InvokeServer(angle, Config.CastPower, os.clock()) end)
            for i = 1, 3 do pcall(function() Net["RE/FishingCompleted"]:FireServer() Net["RE/ShakeFish"]:FireServer() end) end
            Stats.FishCaught = Stats.FishCaught + 1
        else
            pcall(function() Net["RF/ChargeFishingRod"]:InvokeServer() end)
            if Config.ChargeTime > 0 then task.wait(Config.ChargeTime) end
            local angle = Config.CastAngleMin + (math.random() * (Config.CastAngleMax - Config.CastAngleMin))
            pcall(function() Net["RF/RequestFishingMinigameStarted"]:InvokeServer(angle, Config.CastPower, os.clock()) end)
            if Config.ReelDelay > 0 then task.wait(Config.ReelDelay) end
            pcall(function() Net["RE/ShakeFish"]:FireServer() Net["RE/ShakeFish"]:FireServer() end)
            pcall(function() Net["RE/FishingCompleted"]:FireServer() Net["RE/FishingCompleted"]:FireServer() end)
            Stats.FishCaught = Stats.FishCaught + 1
        end
    end)
end

local function StartBlatantLoop()
    while Config.BlatantMode do
        if not FishingActive then
            FishingActive = true
            ExecuteFishing()
            if Config.AutoSell and Stats.FishCaught > 0 and Stats.FishCaught % Config.AutoSellThreshold == 0 then
                -- Auto sell logic will be added here
            end
            FishingActive = false
            task.wait(Config.FishingDelay)
        end
        task.wait(0.01)
    end
end

local AntiLagOriginalSettings = {}
local function toggleAntiLag(state)
    Config.AntiLagEnabled = state
    
    if state then
        AntiLagOriginalSettings = {
            GlobalShadows = Lighting.GlobalShadows,
            FogEnd = Lighting.FogEnd,
            QualityLevel = settings().Rendering.QualityLevel
        }
        
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = 1
            
            if Terrain then
                Terrain.Decoration = false
            end
            
            for _, v in pairs(Workspace:GetDescendants()) do
                pcall(function()
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    elseif v:IsA("MeshPart") or v:IsA("Part") then
                        v.Material = Enum.Material.Plastic
                        v.CastShadow = false
                    end
                end)
            end
        end)
        
        library:MakeNotification({
            Name = "Anti Lag",
            Content = "✅ Enabled - Fps Booster",
            Time = 3
        })
    else
        pcall(function()
            Lighting.GlobalShadows = AntiLagOriginalSettings.GlobalShadows or true
            Lighting.FogEnd = AntiLagOriginalSettings.FogEnd or 10000
            settings().Rendering.QualityLevel = AntiLagOriginalSettings.QualityLevel or 10
            
            if Terrain then
                Terrain.Decoration = true
            end
        end)
        
        library:MakeNotification({
            Name = "Anti Lag",
            Content = "❌ Disabled",
            Time = 3
        })
    end
end

local function SellAllFish()
    local success = false
    
    if Net and Net["RF/SellAllItems"] then
        local s, err = pcall(function()
            Net["RF/SellAllItems"]:InvokeServer()
        end)
        success = s
    end
    
    if not success then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteFunction") and obj.Name:lower():find("sell") then
                local s, err = pcall(function()
                    obj:InvokeServer()
                end)
                if s then
                    success = true
                    break
                end
            end
        end
    end
    
    if success then
        Stats.TotalSold = Stats.TotalSold + 1
        library:MakeNotification({
            Name = "Auto Sell",
            Content = "Successfully sell all fish!",
            Time = 3
        })
        return true
    else
        library:MakeNotification({
            Name = "❌ Auto Sell",
            Content = "Failed to sell fish!",
            Time = 3
        })
        return false
    end
end

local MapLocations = {
    ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
    ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),
    ["Crater Island Top"] = Vector3.new(1011.29, 22.68, 5076.27),
    ["Crater Island Ground"] = Vector3.new(1079.57, 3.64, 5080.35),
    ["Coral Reefs SPOT 1"] = Vector3.new(-3031.88, 2.52, 2276.36),
    ["Coral Reefs SPOT 2"] = Vector3.new(-3270.86, 2.5, 2228.1),
    ["Coral Reefs SPOT 3"] = Vector3.new(-3136.1, 2.61, 2126.11),
    ["Lost Shore"] = Vector3.new(-3737.97, 5.43, -854.68),
    ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
    ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
    ["Kohana SPOT 1"] = Vector3.new(-367.77, 6.75, 521.91),
    ["Kohana SPOT 2"] = Vector3.new(-623.96, 19.25, 419.36),
    ["Tropical Grove"] = Vector3.new(-2018.91, 9.04, 3750.59),
    ["Tropical Grove Highground"] = Vector3.new(-2139, 53, 3624),
    ["Fisherman Island Underground"] = Vector3.new(-62, 3, 2846),
    ["Fisherman Island Mid"] = Vector3.new(33, 3, 2764),
    ["Fisherman Island Rift Left"] = Vector3.new(-26, 10, 2686),
    ["Fisherman Island Rift Right"] = Vector3.new(95, 10, 2684),
    ["Secred Temple"] = Vector3.new(1475, -22, -632),
    ["Ancient Jungle Outside"] = Vector3.new(1488, 8, -392),
    ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
    ["Underground Cellar"] = Vector3.new(2136, -91, -699),
    ["Crystaline Pessage"] = Vector3.new(6051, -539, 4386),
    ["Ancient Ruin"] = Vector3.new(6090, -586, 4634),
    ["Esoteric Deep"] = Vector3.new(3181, -1303, 1425),
    ["Pirate Cove"] = Vector3.new(3207.78, 9.10, 3546.13),
}

local Fish = {
    Reel = 1.9,
    FishingDelay = 1.1,
    FBlatant = false
}

local function SaveConfig()
    -- Placeholder function
end

local function chloex(message)
    library:MakeNotification({
        Name = "Info",
        Content = message,
        Time = 3
    })
end

local PlayerTab = MainWindow:MakeTab({Name = "Player Info", Icon = "rbxassetid://4483345998", PremiumOnly = false})

PlayerTab:AddSection({Name = "Player Info"})
PlayerTab:AddParagraph("Display Name", Player.DisplayName)
PlayerTab:AddParagraph("Username", Player.Name)
PlayerTab:AddParagraph("UserID", tostring(Player.UserId))

local FishingTab = MainWindow:MakeTab({Name = "Fishing", Icon = "rbxassetid://4483345998", PremiumOnly = false})

FishingTab:AddSection({Name = "Fishing Features"})

FishingTab:AddToggle({
    Name = "No Animation",
    Default = false,
    Flag = "NoAnimation",
    Callback = function(v)
        Config.NoAnimation = v
        toggleNoAnimation(v)
    end
})

local function Fastest()
    task.spawn(function()
        pcall(function()
            if Network.Functions.Cancel then
                Network.Functions.Cancel:InvokeServer()
            end
        end)
        
        local serverTime = workspace:GetServerTimeNow()
        
        pcall(function()
            if Network.Functions.ChargeRod then
                Network.Functions.ChargeRod:InvokeServer(serverTime)
            end
        end)
        
        pcall(function()
            if Network.Functions.StartMini then
                Network.Functions.StartMini:InvokeServer(-1, 0.999)
            end
        end)
        
        task.wait(Fish.FishingDelay)
        
        pcall(function()
            if Network.Events.REFishDone then
                Network.Events.REFishDone:FireServer()
            end
        end)
    end)
end

FishingTab:AddInput({
    Title = "Delay Reel",
    Value = tostring(_G.Reel),
    Default = "1.9",
    Callback = function(input)
        local reelValue = tonumber(input)
        if reelValue and reelValue > 0 then
            _G.Reel = reelValue
        end
        SaveConfig()
    end,
})

FishingTab:AddInput({
    Title = "Delay Fishing",
    Value = tostring(_G.FishingDelay),
    Default = "1.1",
    Callback = function(input)
        local fishingDelay = tonumber(input)
        if fishingDelay and fishingDelay > 0 then
            _G.FishingDelay = fishingDelay
        end
        SaveConfig()
    end,
})

FishingTab:AddToggle({
    Title = "Blatant Fishing",
    Default = _G.FBlatant,
    Callback = function(enabled)
        _G.FBlatant = enabled
        Network.Functions.AutoEnabled:InvokeServer(enabled)
        
        if enabled then
            LocalPlayer:SetAttribute("Loading", nil)
            
            task.spawn(function()
                while _G.FBlatant do
                    Fastest()
                    task.wait(_G.Reel)
                end
            end)
        else
            LocalPlayer:SetAttribute("Loading", false)
        end
    end,
})

FishingTab:AddButton({
    Name = "Recovery Fishing",
    Callback = function()
        task.spawn(function()
            pcall(function()
                if Network.Functions.Cancel then
                    Network.Functions.Cancel:InvokeServer()
                end
            end)
            
            Player:SetAttribute("Loading", nil)
            task.wait(0.05)
            Player:SetAttribute("Loading", false)
            chloex("Recovery Successfully!")
        end)
    end
})

FishingTab:AddButton({
    Name = "SELL ALL FISH NOW",
    Callback = function()
        SellAllFish()
    end
})

FishingTab:AddSection({Name = "Fishing Stats"})
local statsLabel = FishingTab:AddLabel("Fish: 0 | Sold: 0")

local CheatTab = MainWindow:MakeTab({Name = "Tools", Icon = "rbxassetid://4483345998", PremiumOnly = false})

CheatTab:AddSection({Name = "Movement"})

CheatTab:AddToggle({
    Name = "Fly",
    Default = false,
    Flag = "Fly",
    Callback = function(v)
        Config.FlyEnabled = v
        if v then
            FlyController:Enable()
        else
            FlyController:Disable()
        end
        library:MakeNotification({
            Name = "Fly",
            Content = v and "✅ Enabled" or "❌ Disabled",
            Time = 3
        })
    end
})

CheatTab:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Flag = "SpeedHack",
    Callback = function(v)
        Config.SpeedEnabled = v
        updateSpeed()
        library:MakeNotification({
            Name = "Speed Hack",
            Content = v and "✅ Enabled" or "❌ Disabled",
            Time = 3
        })
    end
})

CheatTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Flag = "Noclip",
    Callback = function(v)
        Config.NoclipEnabled = v
        if v then
            NoclipController:Enable()
        else
            NoclipController:Disable()
        end
        library:MakeNotification({
            Name = "Noclip",
            Content = v and "✅ Enabled" or "❌ Disabled",
            Time = 3
        })
    end
})

CheatTab:AddToggle({
    Name = "Walk on Water",
    Default = false,
    Flag = "WalkOnWater",
    Callback = function(v)
        Config.WalkOnWater = v
        if v then
            WalkOnWaterController:Enable()
        else
            WalkOnWaterController:Disable()
        end
        library:MakeNotification({
            Name = "Walk on Water",
            Content = v and "✅ Enabled" or "❌ Disabled",
            Time = 3
        })
    end
})

CheatTab:AddSection({Name = "Performance"})

CheatTab:AddToggle({
    Name = "Anti Lag",
    Default = false,
    Flag = "AntiLag",
    Callback = function(v)
        toggleAntiLag(v)
    end
})

CheatTab:AddSection({Name = "Movement Settings"})

CheatTab:AddSlider({
    Name = "Fly Speed",
    Min = 1,
    Max = 500,
    Default = Config.FlySpeed,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "speed",
    Flag = "FlySpeed",
    Callback = function(value)
        Config.FlySpeed = value
        library:MakeNotification({
            Name = "Fly Speed",
            Content = "Set to " .. value,
            Time = 2
        })
    end
})

CheatTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = Config.WalkSpeed,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "speed",
    Flag = "WalkSpeed",
    Callback = function(value)
        Config.WalkSpeed = value
        if Config.SpeedEnabled then
            updateSpeed()
        end
        library:MakeNotification({
            Name = "Walk Speed",
            Content = "Set to " .. value,
            Time = 2
        })
    end
})

local VisualTab = MainWindow:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})

VisualTab:AddSection({Name = "Visual Effects"})

VisualTab:AddToggle({
    Name = "Full Bright",
    Default = false,
    Flag = "FullBright",
    Callback = function(v)
        toggleFullBright(v)
        library:MakeNotification({
            Name = "Full Bright",
            Content = v and "✅ Enabled" or "❌ Disabled",
            Time = 3
        })
    end
})

VisualTab:AddToggle({
    Name = "X-Ray",
    Default = false,
    Flag = "XRay",
    Callback = function(v)
        toggleXRayWater(v)
        library:MakeNotification({
            Name = "X-Ray Water",
            Content = v and "✅ Enabled" or "❌ Disabled",
            Time = 3
        })
    end
})

local TeleportTab = MainWindow:MakeTab({Name = "Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})

TeleportTab:AddSection({Name = "Map Teleport"})

local MapNames = {}
for mapName, _ in pairs(MapLocations) do
    table.insert(MapNames, mapName)
end
table.sort(MapNames)

local SelectedMap = MapNames[1]

local mapDropdown = TeleportTab:AddDropdown({
    Name = "Select Map Location",
    Default = SelectedMap,
    Options = MapNames,
    Flag = "MapLocation",
    Callback = function(v)
        SelectedMap = v
    end
})

TeleportTab:AddButton({
    Name = "TELEPORT TO MAP",
    Callback = function()
        local cframe = MapLocations[SelectedMap]
        if cframe then
            local char = Player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(cframe)
                    library:MakeNotification({
                        Name = "Teleport",
                        Content = "Teleported to " .. SelectedMap,
                        Time = 3
                    })
                else
                    library:MakeNotification({
                        Name = "❌ Error",
                        Content = "HumanoidRootPart not found!",
                        Time = 3
                    })
                end
            else
                library:MakeNotification({
                    Name = "❌ Error",
                    Content = "Character not found!",
                    Time = 3
                })
            end
        end
    end
})

TeleportTab:AddSection({Name = "Player Teleport"})

local playerList = {"Select Player..."}
local selectedPlayer = "Select Player..."

local playerDropdown = TeleportTab:AddDropdown({
    Name = "Select Player",
    Default = "Select Player...",
    Options = playerList,
    Flag = "PlayerSelect",
    Callback = function(v)
        selectedPlayer = v
    end
})

local function updatePlayerList()
    local newList = {"Select Player..."}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            table.insert(newList, p.Name)
        end
    end
    playerDropdown:Refresh(newList, true)
end

TeleportTab:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        updatePlayerList()
        library:MakeNotification({
            Name = "Players",
            Content = "Player list refreshed!",
            Time = 3
        })
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        if selectedPlayer ~= "Select Player..." then
            local target = Players:FindFirstChild(selectedPlayer)
            if target and target.Character then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                local localChar = Player.Character
                if targetRoot and localChar then
                    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 5, 0)
                        library:MakeNotification({
                            Name = "Teleport",
                            Content = "Teleported to " .. selectedPlayer,
                            Time = 3
                        })
                    else
                        library:MakeNotification({
                            Name = "❌ Error",
                            Content = "Your HRP not found!",
                            Time = 3
                        })
                    end
                else
                    library:MakeNotification({
                        Name = "❌ Error",
                        Content = "Target HRP not found!",
                        Time = 3
                    })
                end
            else
                library:MakeNotification({
                    Name = "❌ Error",
                    Content = "Player not found or no character!",
                    Time = 3
                })
            end
        else
            library:MakeNotification({
                Name = "Warning",
                Content = "Please select a player first!",
                Time = 3
            })
        end
    end
})

TeleportTab:AddSection({Name = "Quick Teleports"})

TeleportTab:AddButton({
    Name = "Teleport Up 50 studs",
    Callback = function()
        local char = Player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
                library:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported up 50 studs",
                    Time = 2
                })
            end
        end
    end
})

TeleportTab:AddButton({
    Name = "Teleport Down 50 studs",
    Callback = function()
        local char = Player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, -50, 0)
                library:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported down 50 studs",
                    Time = 2
                })
            end
        end
    end
})

local EventsTab = MainWindow:MakeTab({Name = "Shop", Icon = "rbxassetid://4483345998", PremiumOnly = false})

EventsTab:AddSection({Name = "Auto Buy Cuaca"})

local eventDropdown = EventsTab:AddDropdown({
    Name = "Select Cuaca",
    Default = Config.SelectedEvent,
    Options = EventList,
    Flag = "EventSelect",
    Callback = function(v)
        Config.SelectedEvent = v
        library:MakeNotification({
            Name = "Cuaca Selected",
            Content = "Selected: " .. v,
            Time = 2
        })
    end
})

EventsTab:AddButton({
    Name = "BUY SELECTED CUACA",
    Callback = function()
        library:MakeNotification({
            Name = "Buying Cuaca",
            Content = "Purchasing " .. Config.SelectedEvent .. "...",
            Time = 2
        })
        
        local success = pcall(function()
            if Net and Net["RF/PurchaseWeatherEvent"] then
                Net["RF/PurchaseWeatherEvent"]:InvokeServer(Config.SelectedEvent)
                return true
            end
            return false
        end)
        
        if success then
            library:MakeNotification({
                Name = "Cuaca Purchase",
                Content = "Successfully bought " .. Config.SelectedEvent .. "!",
                Time = 3
            })
        else
            library:MakeNotification({
                Name = "❌ Cuaca Purchase",
                Content = "Failed to buy event!",
                Time = 3
            })
        end
    end
})

EventsTab:AddSection({Name = "Utility"})

EventsTab:AddToggle({
    Name = "Anti AFK",
    Default = Config.AntiAFKEnabled,
    Flag = "AntiAFK",
    Callback = function(v)
        Config.AntiAFKEnabled = v
        if v then
            AntiAFKController:Enable()
        else
            AntiAFKController:Disable()
        end
        library:MakeNotification({
            Name = "Anti AFK",
            Content = v and "✅ Enabled" or "❌ Disabled",
            Time = 3
        })
    end
})

local AboutTab = MainWindow:MakeTab({Name = "About", Icon = "rbxassetid://4483345998", PremiumOnly = false})

AboutTab:AddSection({Name = "Script Information"})
AboutTab:AddParagraph("Mahiru Script V1", "A fishing script for Roblox")
AboutTab:AddParagraph("Developer", "LangitDev")
AboutTab:AddParagraph("GitHub", "github.com/LangitDeveloper")
AboutTab:AddParagraph("Discord", "discord.gg/mahiruscript")

AboutTab:AddButton({
    Name = "Discord Information",
    Callback = function()
        setclipboard("https://discord.gg/mahiruscript")
        library:MakeNotification({
            Name = "Copied",
            Content = "Discord Copied!",
            Time = 3
        })
    end
})

AboutTab:AddButton({
    Name = "🔄 Reset All Settings",
    Callback = function()
        Config.BlatantMode = false
        FishingActive = false
        
        if Config.NoAnimation then
            toggleNoAnimation(false)
        end
        
        if Config.FlyEnabled then
            Config.FlyEnabled = false
            FlyController:Disable()
        end
        
        if Config.SpeedEnabled then
            Config.SpeedEnabled = false
            updateSpeed()
        end
        
        if Config.NoclipEnabled then
            Config.NoclipEnabled = false
            NoclipController:Disable()
        end
        
        if Config.WalkOnWater then
            Config.WalkOnWater = false
            WalkOnWaterController:Disable()
        end
        
        if Config.AntiLagEnabled then
            toggleAntiLag(false)
        end
        
        if Config.FullBright then
            toggleFullBright(false)
        end
        
        if Config.XRayWater then
            toggleXRayWater(false)
        end
        
        library:MakeNotification({
            Name = "Reset",
            Content = "✅ Reset All Default!",
            Time = 5
        })
    end
})

AboutTab:AddButton({
    Name = "❌ Destroy UI",
    Callback = function()
        Config.BlatantMode = false
        FishingActive = false
        
        if Config.NoAnimation then
            toggleNoAnimation(false)
        end
        
        if Config.FlyEnabled then
            FlyController:Disable()
        end
        
        if Config.SpeedEnabled then
            Config.SpeedEnabled = false
            updateSpeed()
        end
        
        if Config.NoclipEnabled then
            NoclipController:Disable()
        end
        
        if Config.WalkOnWater then
            WalkOnWaterController:Disable()
        end
        
        if Config.AntiAFKEnabled then
            AntiAFKController:Disable()
        end
        
        if Config.AntiLagEnabled then
            toggleAntiLag(false)
        end
        
        library:Destroy()
    end
})

task.spawn(function()
    while task.wait(1) do
        if statsLabel then
            statsLabel:Set("Fish: " .. Stats.FishCaught .. " | Sold: " .. Stats.TotalSold)
        end
    end
end)

Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if Config.BlatantMode then
            Config.BlatantMode = false
            FishingActive = false
            library:MakeNotification({
                Name = "Character Died",
                Content = "Blatant fishing stopped!",
                Time = 3
            })
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(10)
        updatePlayerList()
    end
end)

Player.CharacterAdded:Connect(function()
    task.wait(1)
    updateSpeed()
end)

library:Init()

library:MakeNotification({
    Name = "Welcome to Mahiru Script!",
    Content = "By LangitDev!",
    Time = 5
})

print([[
Mahiru Script V1
]])