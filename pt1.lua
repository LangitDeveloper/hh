local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Window = library:MakeWindow({
    Name = "Mahiru Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "MahiruConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Mahiru Script",
    Icon = "https://files.catbox.moe/x531zq.jpg"
})

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
local HttpService = game:GetService("HttpService")

local Net = {}
local Network = {
    Events = {},
    Functions = {},
    Loaded = false,
    Attempts = 0,
    MaxAttempts = 10
}

-- Tambahkan di bagian atas setelah Network
-- Tambahkan setelah Network
local function DebugAllRemotes()
    print("\n🔍 === DEBUG ALL REMOTES ===")
    
    -- Cari semua remote di ReplicatedStorage
    local allRemotes = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(allRemotes, {
                Name = obj.Name,
                Type = obj.ClassName,
                Path = obj:GetFullName()
            })
        end
    end
    
    -- Sort by name
    table.sort(allRemotes, function(a, b)
        return a.Name < b.Name
    end)
    
    -- Print semua
    print("📋 Found " .. #allRemotes .. " remotes:")
    for i, remote in ipairs(allRemotes) do
        print(string.format("%d. %s [%s]", i, remote.Name, remote.Type))
    end
    
    -- Cari yang berhubungan dengan fishing
    print("\n🎣 FISHING-RELATED REMOTES:")
    for _, remote in ipairs(allRemotes) do
        local nameLower = remote.Name:lower()
        if nameLower:find("fish") or 
           nameLower:find("cast") or 
           nameLower:find("reel") or
           nameLower:find("shake") or
           nameLower:find("complete") or
           nameLower:find("charge") then
            print("→ " .. remote.Name .. " [" .. remote.Type .. "]")
        end
    end
    
    print("=============================\n")
    
    return allRemotes
end
      
local function loadNetwork()
    print("🔄 Loading Network (Updated Method)...")
    
    -- Reset
    Net = {}
    Network.Events = {}
    Network.Functions = {}
    
    -- Cari semua remote fishing-related
    local fishingRemotes = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local nameLower = obj.Name:lower()
            
            -- Fishing-related keywords
            if nameLower:find("fish") or 
               nameLower:find("cast") or 
               nameLower:find("reel") or
               nameLower:find("shake") or
               nameLower:find("complete") or
               nameLower:find("charge") or
               nameLower:find("equip") or
               nameLower:find("sell") then
                
                fishingRemotes[obj.Name] = obj
                print("📝 Found: " .. obj.Name .. " [" .. obj.ClassName .. "]")
            end
        end
    end
    
    -- Coba identifikasi remotes
    for name, remote in pairs(fishingRemotes) do
        local nameLower = name:lower()
        
        -- CHARGE / CAST
        if nameLower:find("charge") and remote:IsA("RemoteFunction") then
            Net["RF/ChargeFishingRod"] = remote
            Network.Functions.ChargeRod = remote
            print("✅ Identified as ChargeRod: " .. name)
        
        -- START FISHING / CAST
        elseif (nameLower:find("start") or nameLower:find("request")) and remote:IsA("RemoteFunction") then
            Net["RF/RequestFishingMinigameStarted"] = remote
            Network.Functions.StartMini = remote
            print("✅ Identified as StartMini: " .. name)
        
        -- SHAKE
        elseif nameLower:find("shake") and remote:IsA("RemoteEvent") then
            Net["RE/ShakeFish"] = remote
            Network.Events.ShakeFish = remote
            print("✅ Identified as ShakeFish: " .. name)
        
        -- COMPLETE / FISHING COMPLETED
        elseif (nameLower:find("complete") or nameLower:find("finish")) and remote:IsA("RemoteEvent") then
            Net["RE/FishingCompleted"] = remote
            Network.Events.FishComplete = remote
            print("✅ Identified as FishComplete: " .. name)
        
        -- EQUIP
        elseif nameLower:find("equip") and remote:IsA("RemoteEvent") then
            Net["RE/EquipToolFromHotbar"] = remote
            Network.Events.Equip = remote
            print("✅ Identified as Equip: " .. name)
        
        -- SELL
        elseif nameLower:find("sell") and remote:IsA("RemoteFunction") then
            Net["RF/SellAllItems"] = remote
            Network.Functions.SellAll = remote
            print("✅ Identified as SellAll: " .. name)
        end
    end
    
    -- Cek jika ada remote baru yang mungkin
    print("\n🔍 Checking for new/updated remotes...")
    
    -- Cari remote dengan pattern baru
    for name, remote in pairs(fishingRemotes) do
        -- Mungkin ada remote baru seperti:
        if name:find("Fishing") and not Net["RE/FishingCompleted"] then
            print("⚠️ Possible new fishing remote: " .. name)
        end
    end
    
    -- Update Network status
    local hasRequired = (Net["RF/ChargeFishingRod"] or Network.Functions.ChargeRod) and 
                       (Net["RF/RequestFishingMinigameStarted"] or Network.Functions.StartMini)
    
    if hasRequired then
        Network.Loaded = true
        print("✅ Network loaded successfully!")
        
        -- Debug info
        print("\n📊 NETWORK STATUS:")
        print("ChargeRod: " .. tostring(Net["RF/ChargeFishingRod"] or Network.Functions.ChargeRod))
        print("StartMini: " .. tostring(Net["RF/RequestFishingMinigameStarted"] or Network.Functions.StartMini))
        print("ShakeFish: " .. tostring(Net["RE/ShakeFish"] or Network.Events.ShakeFish))
        print("FishComplete: " .. tostring(Net["RE/FishingCompleted"] or Network.Events.FishComplete))
        print("Equip: " .. tostring(Net["RE/EquipToolFromHotbar"] or Network.Events.Equip))
        
        return true
    else
        print("❌ Missing required fishing functions!")
        return false
    end
end

task.spawn(function()
    while not Network.Loaded and Network.Attempts < Network.MaxAttempts do
        Network.Attempts = Network.Attempts + 1
        print("Network loading attempt " .. Network.Attempts .. "/" .. Network.MaxAttempts)
        
        local success = loadNetwork()
        if success then
            library:MakeNotification({
                Name = "Network Ready", 
                Content = "Fishing system loaded!", 
                Time = 3
            })
            break
        else
            if Network.Attempts < Network.MaxAttempts then
                task.wait(2) 
            end
        end
    end
    
    if not Network.Loaded then
        warn("Failed to load network " .. Network.MaxAttempts .. " attempts")
        library:MakeNotification({
            Name = "Warning", 
            Content = "Network not fully loaded, some features may not work", 
            Time = 5
        })
    end
end)

local Fish = {
    Reel = 0.1,
    FishingDelay = 0.2,
    FBlatant = false,
    Delay = 1.0,
    DelayComplete = 0.5,
    FAutoEquip = true  
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
    ChargeTime = 0.3,
    MultiCast = false, 
    AutoBuyWeather = false, 
    CastAmount = 3, 
    CastPower = 0.55, 
    CastAngleMin = -0.8, 
    CastAngleMax = 0.8,
    InstantFish = false, 
    AutoSell = false, 
AutoSellEnabled = false,
    SellMode = "Delay", 
    SellDelay = 60,     
    SellCount = 50,      
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
local Stats = { StartTime = os.time(), FishCaught = 0, LastSellTime = 0, TotalSold = 0 }
local FishingActive = false
local AutoSellActive = false

local function getBackpackInfo()
    local currentCount = 0
    local maxCapacity = 0
    
    local success, result = pcall(function()
        local playerGui = Player:WaitForChild("PlayerGui")
        if not playerGui then return 0, 0 end
        
        local inventory = playerGui:FindFirstChild("Inventory")
        if not inventory then return 0, 0 end
        
        local main = inventory:FindFirstChild("Main")
        if not main then return 0, 0 end
        
        local top = main:FindFirstChild("Top")
        if not top then return 0, 0 end
        
        local options = top:FindFirstChild("Options")
        if not options then return 0, 0 end
        
        local fish = options:FindFirstChild("Fish")
        if not fish then return 0, 0 end
        
        for _, child in pairs(fish:GetChildren()) do
            if child:IsA("TextLabel") and child.Name == "Label" then
                for _, subChild in pairs(child:GetChildren()) do
                    if subChild:IsA("TextLabel") and subChild.Name == "BagSize" then
                        local text = subChild.Text or ""
                        local currentText, maxText = text:match("(%d+)%s*/%s*(%d+)")
                        if currentText and maxText then
                            currentCount = tonumber(currentText) or 0
                            maxCapacity = tonumber(maxText) or 0
                        end
                        break
                    end
                end
                break
            end
        end
        
        if currentCount == 0 then
            local bagLabel = fish:FindFirstChild("BagSize", true)
            if bagLabel and bagLabel:IsA("TextLabel") then
                local text = bagLabel.Text or ""
                local currentText, maxText = text:match("(%d+)%s*/%s*(%d+)")
                if currentText and maxText then
                    currentCount = tonumber(currentText) or 0
                    maxCapacity = tonumber(maxText) or 0
                end
            end
        end
        
        return currentCount, maxCapacity
    end)
    
    if not success then
        return 0, 0
    end
    
    return currentCount, maxCapacity
end


local function ensureNetworkLoaded()
    if Network.Loaded then return true end
    
    print("Network not loaded, attempting quick load...")
    local success = loadNetwork()
    
    if success then
        Network.Loaded = true
        print("Network loaded in emergency")
        return true
    else
        library:MakeNotification({
            Name = "Network Error", 
            Content = "Cannot fish - network not available", 
            Time = 3
        })
        return false
    end
end

local function equipFishingRod()
    if not Fish.FAutoEquip then return false end
    
    local char = Player.Character
    if not char then return false end
    
    if char:FindFirstChild("Fishing Rod") then
        return true
    end
    
    print("equip rod...")
    local equipped = false
    
    if Network.Events.Equip then
        local s, err = pcall(function()
            Network.Events.Equip:FireServer(1)
            equipped = true
            print("Equipped via Network.Events.Equip")
        end)
        if not s then print("❌ Equip failed:", err) end
    end
    
    if not equipped and Net["RE/EquipToolFromHotbar"] then
        local s, err = pcall(function()
            Net["RE/EquipToolFromHotbar"]:FireServer(1)
            equipped = true
            print("Equipped via Net[RE/EquipToolFromHotbar]")
        end)
        if not s then print("❌ Equip failed:", err) end
    end
    
    if not equipped then
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("equip") then
                local s, err = pcall(function()
                    remote:FireServer(1)
                    equipped = true
                    print("Equipped via " .. remote.Name)
                end)
                if s then break end
            end
        end
    end
    
    if equipped then
        task.wait(0.8) 
        return true
    else
        print("Failed to equip fishing rod")
        library:MakeNotification({
            Name = "❌ Equip Failed", 
            Content = "Could not equip fishing rod", 
            Time = 3
        })
        return false
    end
end

local function ExecuteFishing()
    if not ensureNetworkLoaded() then 
        print("❌ Network not ready")
        return false 
    end
    
    -- Equip rod
    if Fish.FAutoEquip then
        if not equipFishingRod() then
            print("❌ Failed to equip rod")
            return false
        end
    end
    
    -- Dapatkan remotes (coba berbagai kemungkinan)
    local chargeFunc = Net["RF/ChargeFishingRod"] or Network.Functions.ChargeRod
    local startFunc = Net["RF/RequestFishingMinigameStarted"] or Network.Functions.StartMini
    
    -- Cari remote complete/shake yang benar
    local shakeFunc = Net["RE/ShakeFish"] or Network.Events.ShakeFish
    local completeFunc = Net["RE/FishingCompleted"] or Network.Events.FishComplete
    
    -- JIKA TIDAK ADA, COBA CARI ALTERNATIF
    if not completeFunc then
        print("⚠️ FishComplete not found, searching alternatives...")
        
        -- Cari remote dengan nama berbeda
        for name, remote in pairs(Network.Events) do
            if name:lower():find("complete") or 
               name:lower():find("finish") or
               name:lower():find("catch") then
                completeFunc = remote
                print("✅ Using alternative: " .. name)
                break
            end
        end
    end
    
    if not chargeFunc or not startFunc then
        print("❌ Missing critical functions")
        return false
    end
    
    -- ============================================
    // TEST DENGAN BERBAGAI METODE
    // ============================================
    local testMethods = {
        "Method A: Double fire",
        "Method B: Triple fire with delay",
        "Method C: Sequential fire",
        "Method D: Burst fire"
    }
    
    local currentTestMethod = 1  -- VARIABLE GLOBAL UNTUK TEST METHOD

local function ExecuteFishing()
    if not ensureNetworkLoaded() then 
        print("❌ Network not ready")
        return false 
    end
    
    -- Equip rod
    if Fish.FAutoEquip then
        if not equipFishingRod() then
            print("❌ Failed to equip rod")
            return false
        end
    end
    
    -- Dapatkan remotes
    local chargeFunc = Net["RF/ChargeFishingRod"] or Network.Functions.ChargeRod
    local startFunc = Net["RF/RequestFishingMinigameStarted"] or Network.Functions.StartMini
    local shakeFunc = Net["RE/ShakeFish"] or Network.Events.ShakeFish
    local completeFunc = Net["RE/FishingCompleted"] or Network.Events.FishComplete
    
    if not chargeFunc or not startFunc then
        print("❌ Missing critical functions: chargeFunc=", chargeFunc, "startFunc=", startFunc)
        return false
    end
    
    -- TEST METHODS
    local testMethods = {
        "Method A: Double fire",
        "Method B: Triple fire with delay",
        "Method C: Sequential fire",
        "Method D: Burst fire"
    }
    
    local success, err = pcall(function()
        print("🧪 Testing method: " .. testMethods[currentTestMethod])
        
        -- 1. CHARGE ROD
        chargeFunc:InvokeServer()
        print("✅ Charged rod")
        task.wait(Config.ChargeTime or 0.3)
        
        -- 2. CAST
        local angle = Config.CastAngleMin + (math.random() * (Config.CastAngleMax - Config.CastAngleMin))
        startFunc:InvokeServer(angle, Config.CastPower or 0.55, os.clock())
        print("✅ Casted with angle: " .. angle)
        
        task.wait(Fish.Reel or 0.1)
        
        -- 3. EXECUTE FISHING BASED ON METHOD
        if currentTestMethod == 1 then
            -- METHOD A: DOUBLE FIRE
            if shakeFunc then
                shakeFunc:FireServer()
                shakeFunc:FireServer()
                print("✅ Shake fish: Double fire")
            end
            if completeFunc then
                completeFunc:FireServer()
                completeFunc:FireServer()
                print("✅ Complete fish: Double fire")
            end
            
        elseif currentTestMethod == 2 then
            -- METHOD B: TRIPLE FIRE WITH DELAY
            for i = 1, 3 do
                if shakeFunc then 
                    shakeFunc:FireServer()
                    print("✅ Shake #" .. i)
                end
                if completeFunc then 
                    completeFunc:FireServer()
                    print("✅ Complete #" .. i)
                end
                task.wait(0.05)
            end
            
        elseif currentTestMethod == 3 then
            -- METHOD C: SEQUENTIAL (SHAKE THEN COMPLETE)
            if shakeFunc then
                for i = 1, 2 do
                    shakeFunc:FireServer()
                    print("✅ Shake sequential #" .. i)
                    task.wait(0.03)
                end
            end
            task.wait(0.1)
            if completeFunc then
                for i = 1, 2 do
                    completeFunc:FireServer()
                    print("✅ Complete sequential #" .. i)
                    task.wait(0.03)
                end
            end
            
        elseif currentTestMethod == 4 then
            -- METHOD D: BURST FIRE
            local fires = {}
            for i = 1, 5 do
                table.insert(fires, task.spawn(function()
                    if shakeFunc then 
                        shakeFunc:FireServer()
                    end
                    if completeFunc then 
                        completeFunc:FireServer()
                    end
                end))
                print("✅ Burst fire #" .. i .. " spawned")
            end
            -- Tunggu semua
            for _, f in ipairs(fires) do
                task.wait(0.01)
            end
        end
        
        Stats.FishCaught = Stats.FishCaught + 1
        
        -- Next method untuk test berikutnya
        currentTestMethod = currentTestMethod + 1
        if currentTestMethod > #testMethods then
            currentTestMethod = 1
        end
    end)
    
    if not success then
        print("❌ Fishing error:", err)
        return false
    end
    
    print("✅ Fishing attempt completed. Total: " .. Stats.FishCaught)
    return true
end

local function StopBlatantLoop()
    Config.BlatantMode = false 
    FishingActive = false
end

local function StartBlatantLoop()
    task.spawn(function()
        if not Network.Loaded then
            library:MakeNotification({
                Name = "⏳ Please Wait", 
                Content = "Loading fishing system...", 
                Time = 2
            })
            
            for i = 1, 30 do  
                if Network.Loaded then break end
                task.wait(0.5)
            end
            
            if not Network.Loaded then
                library:MakeNotification({
                    Name = "❌ Timeout", 
                    Content = "Fishing system not ready", 
                    Time = 5
                })
                Config.BlatantMode = false
                return
            end
        end
        
        library:MakeNotification({
            Name = "🎣 Starting", 
            Content = "Auto fishing activated!", 
            Time = 3
        })
        
        task.wait(1)
        
        Stats.StartTime = os.time()
        Stats.FishCaught = 0
        
        local failCount = 0
        local maxFails = 5
        
        while Config.BlatantMode do
            if not FishingActive then
                FishingActive = true
                
                local success = ExecuteFishing()
                
                if success then
                    failCount = 0
                    
                    if Config.AutoSell and Stats.FishCaught > 0 and Stats.FishCaught % Config.AutoSellThreshold == 0 then
                        SellAllFish()
                    end
                else
                    failCount = failCount + 1
                    print("Fishing failed (" .. failCount .. "/" .. maxFails .. ")")
                    
                    if failCount >= maxFails then
                        library:MakeNotification({
                            Name = "❌ Too Many Failures", 
                            Content = "Stopping auto fishing", 
                            Time = 5
                        })
                        Config.BlatantMode = false
                        break
                    end
                end
                
                FishingActive = false
                
                local delay = Fish.FishingDelay > 0 and Fish.FishingDelay or 1.0
                task.wait(delay)
            end
            task.wait(0.01)
        end
        
        if not Config.BlatantMode then
            library:MakeNotification({
                Name = "Stopped", 
                Content = "Auto fishing stopped", 
                Time = 3
            })
        end
    end)
end

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
    if self.IdleConnection then self.IdleConnection:Disconnect() self.IdleConnection = nil end
    if self.Connection then task.cancel(self.Connection) self.Connection = nil end
end

if Config.AntiAFKEnabled then AntiAFKController:Enable() end

local AnimationController = { Connection = nil }
local function toggleNoAnimation(state)
    Config.NoAnimation = state
    if state then
        local char = Player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do track:Stop() end
                if AnimationController.Connection then AnimationController.Connection:Disconnect() end
                AnimationController.Connection = humanoid.AnimationPlayed:Connect(function(track)
                    if Config.NoAnimation then track:Stop() end
                end)
            end
        end
        library:MakeNotification({Name = "No Animation", Content = "✅ Enabled", Time = 3})
    else
        if AnimationController.Connection then AnimationController.Connection:Disconnect() AnimationController.Connection = nil end
        library:MakeNotification({Name = "No Animation", Content = "❌ Disabled", Time = 3})
    end
end

local FlyController = { BodyVelocity = nil, BodyGyro = nil, Connection = nil }
function FlyController:Enable()
    if self.Connection then return end
    local function setup()
        local char = Player.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        if self.BodyVelocity then self.BodyVelocity:Destroy() end
        if self.BodyGyro then self.BodyGyro:Destroy() end
        self.BodyVelocity = Instance.new("BodyVelocity"); self.BodyVelocity.Velocity = Vector3.zero
        self.BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4); self.BodyVelocity.P = 1000; self.BodyVelocity.Parent = root
        self.BodyGyro = Instance.new("BodyGyro"); self.BodyGyro.MaxTorque = Vector3.new(4e4,4e4,4e4)
        self.BodyGyro.P = 1000; self.BodyGyro.D = 50; self.BodyGyro.Parent = root
        self.Connection = RunService.Heartbeat:Connect(function()
            if not Config.FlyEnabled or not root then self:Disable() return end
            local cam = Workspace.CurrentCamera; if not cam then return end
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
    Player.CharacterAdded:Connect(function() if Config.FlyEnabled then task.wait(1) setup() end end)
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

local NoclipController = { Connection = nil }
function NoclipController:Enable()
    if self.Connection then return end
    self.Connection = RunService.Stepped:Connect(function()
        if not Config.NoclipEnabled then self:Disable() return end
        local char = Player.Character
        if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
    end)
end

function NoclipController:Disable()
    if self.Connection then self.Connection:Disconnect() self.Connection = nil end
    local char = Player.Character
    if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end end
end

local WalkOnWaterController = { Connection = nil }
function WalkOnWaterController:Enable()
    if self.Connection then return end
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Config.WalkOnWater then if self.Connection then self.Connection:Disconnect() self.Connection = nil end return end
        local char = Player.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local rayOrigin = hrp.Position; local rayDirection = Vector3.new(0, -50, 0)
        local raycastParams = RaycastParams.new(); raycastParams.FilterDescendantsInstances = {char}; raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        if raycastResult then
            local hitPart = raycastResult.Instance; local hitName = hitPart.Name:lower()
            if hitName:find("water") or hitName:find("sea") or hitName:find("ocean") or hitName:find("lake") then
                local waterHeight = hitPart.Position.Y + (hitPart.Size.Y / 2)
                hrp.CFrame = CFrame.new(hrp.Position.X, waterHeight + 2.5, hrp.Position.Z)
            end
        end
    end)
end

function WalkOnWaterController:Disable()
    if self.Connection then self.Connection:Disconnect() self.Connection = nil end
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
                part.Transparency = 0.5; part.Material = Enum.Material.Glass
            end
        end
    else
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("water") then
                part.Transparency = 0; part.Material = Enum.Material.Water
            end
        end
    end
end

local AntiLagOriginalSettings = {}
local function toggleAntiLag(state)
    Config.AntiLagEnabled = state
    if state then
        AntiLagOriginalSettings = {GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd, QualityLevel = settings().Rendering.QualityLevel}
        pcall(function()
            Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9; settings().Rendering.QualityLevel = 1
            if Terrain then Terrain.Decoration = false end
            for _, v in pairs(Workspace:GetDescendants()) do pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled = false
                elseif v:IsA("MeshPart") or v:IsA("Part") then v.Material = Enum.Material.Plastic; v.CastShadow = false end
            end) end
        end)
        library:MakeNotification({Name = "Anti Lag", Content = "✅ Enabled", Time = 3})
    else
        pcall(function()
            Lighting.GlobalShadows = AntiLagOriginalSettings.GlobalShadows or true
            Lighting.FogEnd = AntiLagOriginalSettings.FogEnd or 10000
            settings().Rendering.QualityLevel = AntiLagOriginalSettings.QualityLevel or 10
            if Terrain then Terrain.Decoration = true end
        end)
        library:MakeNotification({Name = "Anti Lag", Content = "❌ Disabled", Time = 3})
    end
end

local function SellAllFish()
    local success = false
    if Network.Functions.SellAll then
        local s, err = pcall(function() Network.Functions.SellAll:InvokeServer() end)
        success = s
    end
    if not success then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteFunction") and obj.Name:lower():find("sell") then
                local s, err = pcall(function() obj:InvokeServer() end)
                if s then success = true; break end
            end
        end
    end
    if success then
        Stats.TotalSold = Stats.TotalSold + 1
        library:MakeNotification({Name = "Auto Sell", Content = "Successfully sold all fish!", Time = 3})
        return true
    else
        library:MakeNotification({Name = "❌ Auto Sell", Content = "Failed to sell fish!", Time = 3})
        return false
    end
end

local function StartAutoSellLoop()
    task.spawn(function()
        if AutoSellActive then return end
        
        AutoSellActive = true
        library:MakeNotification({
            Name = "💰 Auto Sell", 
            Content = "Advanced auto sell started!", 
            Time = 3
        })
        
        local lastCheckTime = os.time()
        
        while Config.AutoSellEnabled and AutoSellActive do
            if Config.SellMode == "Delay" then
                local currentTime = os.time()
                local timeSinceLastSell = currentTime - Stats.LastSellTime
                
                if timeSinceLastSell >= Config.SellDelay then
                    SellAllFish()
                    task.wait(2) 
                end
                
                task.wait(5) 
                
            elseif Config.SellMode == "Count" then
                local currentCount, maxCapacity = getBackpackInfo()
                
                if currentCount >= Config.SellCount then
                    library:MakeNotification({
                        Name = "Backpack Full", 
                        Content = "Selling " .. currentCount .. " fish...", 
                        Time = 3
                    })
                    
                    SellAllFish()
                    task.wait(5)
                else
                    if currentCount > 0 and os.time() - lastCheckTime >= 10 then
                        lastCheckTime = os.time()
                        print("📊 Backpack: " .. currentCount .. "/" .. maxCapacity .. 
                              " (Target: " .. Config.SellCount .. ")")
                    end
                    
                    task.wait(2) 
                end
            else
                task.wait(5)
            end
        end
        
        AutoSellActive = false
        library:MakeNotification({
            Name = "💰 Auto Sell", 
            Content = "Auto sell stopped", 
            Time = 3
        })
    end)
end

local function StopAutoSellLoop()
    Config.AutoSellEnabled = false
    AutoSellActive = false
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

local PlayerTab = Window:MakeTab({Name = "Player Info", Icon = "rbxassetid://4483345998"})
PlayerTab:AddSection({Name = "Player Info"})
PlayerTab:AddParagraph("Display Name", Player.DisplayName)
PlayerTab:AddParagraph("Username", Player.Name)
PlayerTab:AddParagraph("UserID", tostring(Player.UserId))
local networkStatus = PlayerTab:AddLabel("Network: 🔄 Loading...")

local FishingTab = Window:MakeTab({Name = "Fishing", Icon = "rbxassetid://4483345998"})
FishingTab:AddSection({Name = "Fishing Features"})

FishingTab:AddToggle({
    Name = "No Animation",
    Default = false,
    Callback = function(v)
        Config.NoAnimation = v
        toggleNoAnimation(v)
    end
})

FishingTab:AddToggle({
    Name = "Auto Equip Rod",
    Default = Fish.FAutoEquip,  
    Callback = function(enabled)
        Fish.FAutoEquip = enabled
        if enabled then
            library:MakeNotification({
                Name = "Auto Equip", 
                Content = "Rod will auto-equip when fishing", 
                Time = 3
            })
        end
    end
})

FishingTab:AddTextbox({
    Name = "Delay Reel",
    Default = tostring(Fish.Reel),
    TextDisappear = false,
    PlaceholderText = "Delay reeling",
    Callback = function(v)
        local reelValue = tonumber(v)
        if reelValue and reelValue >= 0 then
            Fish.Reel = reelValue
            library:MakeNotification({
                Name = "Delay Reel", 
                Content = "Set to " .. reelValue .. " seconds", 
                Time = 2
            })
        end
    end
})

FishingTab:AddTextbox({
    Name = "Fishing Delay",
    Default = tostring(Fish.FishingDelay),
    TextDisappear = false,
    PlaceholderText = "Delay Fishing",
    Callback = function(v)
        local fishingDelay = tonumber(v)
        if fishingDelay and fishingDelay > 0 then
            Fish.FishingDelay = fishingDelay
            library:MakeNotification({
                Name = "Fishing Delay", 
                Content = "Set to " .. fishingDelay .. " seconds", 
                Time = 2
            })
        end
    end
})

FishingTab:AddToggle({
    Name = "Blatant Fishing Beta",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not Network.Loaded then
                library:MakeNotification({
                    Name = "Please Wait", 
                    Content = "Network still loading...", 
                    Time = 3
                })
                Config.BlatantMode = false
                return
            end
            
            Config.BlatantMode = true
            
            Stats.StartTime = os.time()
            Stats.FishCaught = 0
            Stats.TotalSold = 0
            
            StartBlatantLoop()
            
            library:MakeNotification({
                Name = "Blatant Fishing", 
                Content = "✅ Enabled!", 
                Time = 3
            })
        else
            Config.BlatantMode = false
            library:MakeNotification({
                Name = "Blatant Fishing", 
                Content = "❌ Disabled", 
                Time = 3
            })
        end
    end
})

FishingTab:AddButton({
    Name = "Recovery Fishing",
    Callback = function()
        pcall(function() 
            if Network.Functions.CancelFish then 
                Network.Functions.CancelFish:InvokeServer() 
            end 
        end)
        Player:SetAttribute("Loading", nil); task.wait(0.05); Player:SetAttribute("Loading", false)
        library:MakeNotification({Name = "Recovery", Content = "Fishing recovery successful!", Time = 3})
    end
})

FishingTab:AddSection({Name = "Auto Sell"})


FishingTab:AddDropdown({
    Name = "Sell Mode",
    Default = Config.SellMode,
    Options = {"Delay", "Count"},
    Callback = function(mode)
        Config.SellMode = mode
        Stats.SellMode = mode
        
        library:MakeNotification({
            Name = "Sell Mode", 
            Content = "Set to: " .. mode, 
            Time = 3
        })
        
        
        if Config.AutoSellEnabled then
            StopAutoSellLoop()
            task.wait(0.5)
            Config.AutoSellEnabled = true
            StartAutoSellLoop()
        end
    end
})


local sellValueInput = FishingTab:AddTextbox({
    Name = "Sell Value",
    Default = "5",
    TextDisappear = false,
    PlaceholderText = "Minutes for Delay | Count for Count mode",
    Callback = function(v)
        local value = tonumber(v)
        if value and value > 0 then
            if Config.SellMode == "Delay" then
                Config.SellDelay = value * 60  
                library:MakeNotification({
                    Name = "Sell Delay", 
                    Content = "Set to " .. value .. " minutes", 
                    Time = 3
                })
            else
                Config.SellCount = value
                library:MakeNotification({
                    Name = "Sell Count", 
                    Content = "Sell at " .. value .. " fish", 
                    Time = 3
                })
            end
        end
    end
})

task.spawn(function()
    while task.wait(1) do
        if Config.SellMode == "Delay" then
            sellValueInput:Set("Sell Value (Minutes)")
        else
            sellValueInput:Set("Sell Value (Count)")
        end
    end
end)

FishingTab:AddToggle({
    Name = "Advanced Auto Sell",
    Default = Config.AutoSellEnabled,
    Callback = function(enabled)
        Config.AutoSellEnabled = enabled
        
        if enabled then
            if not Network.Loaded then
                library:MakeNotification({
                    Name = "⚠️ Please Wait", 
                    Content = "Network not ready", 
                    Time = 3
                })
                Config.AutoSellEnabled = false
                return
            end
            
            if not Network.Functions.SellAll then
                library:MakeNotification({
                    Name = "❌ Error", 
                    Content = "Sell function not found", 
                    Time = 3
                })
                Config.AutoSellEnabled = false
                return
            end
            
            StartAutoSellLoop()
            library:MakeNotification({
                Name = "💰 Auto Sell", 
                Content = "auto sell started!", 
                Time = 3
            })
        else
            StopAutoSellLoop()
            library:MakeNotification({
                Name = "💰 Auto Sell", 
                Content = "auto sell stopped", 
                Time = 3
            })
        end
    end
})

FishingTab:AddButton({
    Name = "Sell All Fish",
    Callback = function()
        SellAllFish()
    end
})

-- Di FishingTab, tambahkan:
FishingTab:AddButton({
    Name = "🔍 Debug All Remotes",
    Callback = function()
        DebugAllRemotes()
        library:MakeNotification({
            Name = "Debug Complete",
            Content = "Check console for remote list!",
            Time = 5
        })
    end
})

FishingTab:AddButton({
    Name = "🎣 Test Single Cast",
    Callback = function()
        task.spawn(function()
            ExecuteFishing()
        end)
    end
})

-- Tambahkan di FishingTab setelah Debug button
FishingTab:AddButton({
    Name = "🔄 Switch Test Method",
    Callback = function()
        currentTestMethod = currentTestMethod + 1
        if currentTestMethod > 4 then currentTestMethod = 1 end
        
        local methodNames = {
            "Double fire", 
            "Triple fire with delay", 
            "Sequential fire", 
            "Burst fire"
        }
        
        library:MakeNotification({
            Name = "Test Method",
            Content = "Switched to: " .. methodNames[currentTestMethod],
            Time = 3
        })
    end
})

FishingTab:AddButton({
    Name = "⚡ Quick Fish Test",
    Callback = function()
        task.spawn(function()
            -- Simple test tanpa equip rod
            if ensureNetworkLoaded() then
                local chargeFunc = Net["RF/ChargeFishingRod"] or Network.Functions.ChargeRod
                local startFunc = Net["RF/RequestFishingMinigameStarted"] or Network.Functions.StartMini
                
                if chargeFunc and startFunc then
                    print("⚡ Quick test starting...")
                    chargeFunc:InvokeServer()
                    task.wait(0.3)
                    
                    local angle = -0.5 + (math.random() * 1.0)
                    startFunc:InvokeServer(angle, 0.55, os.clock())
                    task.wait(0.1)
                    
                    print("✅ Quick test completed")
                end
            end
        end)
    end
})


FishingTab:AddSection({Name = "Fishing Stats"})

local backpackInfoLabel = FishingTab:AddLabel("Backpack: Checking...")

local statsLabel = FishingTab:AddLabel("Fish Caught: 0 | Total Sold: 0") 

local CheatTab = Window:MakeTab({Name = "Tools", Icon = "rbxassetid://4483345998"})
CheatTab:AddSection({Name = "Movement"})

CheatTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(v)
        Config.FlyEnabled = v
        if v then FlyController:Enable() else FlyController:Disable() end
        library:MakeNotification({Name = "Fly", Content = v and "✅ Enabled" or "❌ Disabled", Time = 3})
    end
})

CheatTab:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(v)
        Config.SpeedEnabled = v
        updateSpeed()
        library:MakeNotification({Name = "Speed Hack", Content = v and "✅ Enabled" or "❌ Disabled", Time = 3})
    end
})

CheatTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v)
        Config.NoclipEnabled = v
        if v then NoclipController:Enable() else NoclipController:Disable() end
        library:MakeNotification({Name = "Noclip", Content = v and "✅ Enabled" or "❌ Disabled", Time = 3})
    end
})

CheatTab:AddToggle({
    Name = "Walk on Water",
    Default = false,
    Callback = function(v)
        Config.WalkOnWater = v
        if v then WalkOnWaterController:Enable() else WalkOnWaterController:Disable() end
        library:MakeNotification({Name = "Walk on Water", Content = v and "✅ Enabled" or "❌ Disabled", Time = 3})
    end
})

CheatTab:AddSection({Name = "Performance"})
CheatTab:AddToggle({
    Name = "Anti Lag",
    Default = false,
    Callback = function(v)
        toggleAntiLag(v)
    end
})

CheatTab:AddSection({Name = "Movement Settings"})
CheatTab:AddTextbox({
    Name = "Fly Speed",
    Default = tostring(Config.FlySpeed),
    TextDisappear = false,
    PlaceholderText = "Enter fly speed (1-500)",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then Config.FlySpeed = num; library:MakeNotification({Name = "Fly Speed", Content = "Set to " .. num, Time = 2}) end
    end
})

CheatTab:AddTextbox({
    Name = "Walk Speed",
    Default = tostring(Config.WalkSpeed),
    TextDisappear = false,
    PlaceholderText = "Enter walk speed (16-500)",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then Config.WalkSpeed = num; if Config.SpeedEnabled then updateSpeed() end; library:MakeNotification({Name = "Walk Speed", Content = "Set to " .. num, Time = 2}) end
    end
})

local VisualTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998"})
VisualTab:AddSection({Name = "Visual Effects"})

VisualTab:AddToggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(v)
        toggleFullBright(v)
        library:MakeNotification({Name = "Full Bright", Content = v and "✅ Enabled" or "❌ Disabled", Time = 3})
    end
})

VisualTab:AddToggle({
    Name = "X-Ray Water",
    Default = false,
    Callback = function(v)
        toggleXRayWater(v)
        library:MakeNotification({Name = "X-Ray Water", Content = v and "✅ Enabled" or "❌ Disabled", Time = 3})
    end
})

local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://4483345998"})
TeleportTab:AddSection({Name = "Map Teleport"})

local MapNames = {}
for mapName, _ in pairs(MapLocations) do table.insert(MapNames, mapName) end
table.sort(MapNames)
local SelectedMap = MapNames[1]

local mapDropdown = TeleportTab:AddDropdown({
    Name = "Select Map Location",
    Default = SelectedMap,
    Options = MapNames,
    Callback = function(v) SelectedMap = v end
})

TeleportTab:AddButton({
    Name = "Teleport to map",
    Callback = function()
        local cframe = MapLocations[SelectedMap]
        if cframe then
            local char = Player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(cframe)
                    library:MakeNotification({Name = "Teleport", Content = "Teleported to " .. SelectedMap, Time = 3})
                end
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


local ShopTab = Window:MakeTab({Name = "Shop", Icon = "rbxassetid://4483345998"})
ShopTab:AddSection({Name = "Auto Buy Cuaca"})

local eventDropdown = ShopTab:AddDropdown({
    Name = "Select Cuaca",
    Default = Config.SelectedEvent,
    Options = EventList,
    Callback = function(v)
        Config.SelectedEvent = v
        library:MakeNotification({
            Name = "Cuaca Selected",
            Content = "Selected: " .. v,
            Time = 2
        })
    end
})

ShopTab:AddButton({
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

ShopTab:AddParagraph("Auto Buy Info", "Will auto purchase selected weather events when they're not active")

ShopTab:AddSection({Name = "Utility"})
ShopTab:AddToggle({
    Name = "Anti AFK",
    Default = Config.AntiAFKEnabled,
    Callback = function(v)
        Config.AntiAFKEnabled = v
        if v then AntiAFKController:Enable() else AntiAFKController:Disable() end
        library:MakeNotification({Name = "Anti AFK", Content = v and "✅ Enabled" or "❌ Disabled", Time = 3})
    end
})

local AboutTab = Window:MakeTab({Name = "About", Icon = "rbxassetid://4483345998"})
AboutTab:AddSection({Name = "Script Information"})
AboutTab:AddParagraph("Mahiru Script V1")
AboutTab:AddParagraph("Developer", "LangitDev")
AboutTab:AddParagraph("GitHub", "github.com/LangitDeveloper")
AboutTab:AddParagraph("Discord", "discord.gg/mahiruscript")

AboutTab:AddButton({
    Name = "Discord Information",
    Callback = function()
        setclipboard("https://discord.gg/mahiruscript")
        library:MakeNotification({Name = "Copied", Content = "Discord Copied!", Time = 3})
    end
})

AboutTab:AddButton({
    Name = "🔄 Reset All Settings",
    Callback = function()
        Config.BlatantMode = false; StopBlatantLoop()
        if Config.NoAnimation then toggleNoAnimation(false) end
        if Config.FlyEnabled then Config.FlyEnabled = false; FlyController:Disable() end
        if Config.SpeedEnabled then Config.SpeedEnabled = false; updateSpeed() end
        if Config.NoclipEnabled then Config.NoclipEnabled = false; NoclipController:Disable() end
        if Config.WalkOnWater then Config.WalkOnWater = false; WalkOnWaterController:Disable() end
        if Config.AntiLagEnabled then toggleAntiLag(false) end
        if Config.FullBright then toggleFullBright(false) end
        if Config.XRayWater then toggleXRayWater(false) end
        library:MakeNotification({Name = "Reset", Content = "✅ All settings reset!", Time = 5})
    end
})

AboutTab:AddButton({
    Name = "❌ Destroy UI",
    Callback = function()
        Config.BlatantMode = false; StopBlatantLoop()
        if Config.NoAnimation then toggleNoAnimation(false) end
        if Config.FlyEnabled then FlyController:Disable() end
        if Config.SpeedEnabled then Config.SpeedEnabled = false; updateSpeed() end
        if Config.NoclipEnabled then NoclipController:Disable() end
        if Config.WalkOnWater then WalkOnWaterController:Disable() end
        if Config.AntiAFKEnabled then AntiAFKController:Disable() end
        if Config.AntiLagEnabled then toggleAntiLag(false) end
        library:Destroy()
    end
})

task.spawn(function()
    while task.wait(2) do
        if networkStatus then
            if Network.Loaded then
                networkStatus:Set("Network: ✅ Ready")
            else
                networkStatus:Set("Network: 🔄 Loading...")
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if statsLabel then
            statsLabel:Set("Fish Caught: " .. Stats.FishCaught .. " | Total Sold: " .. Stats.TotalSold)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if backpackInfoLabel and Config.SellMode == "Count" then
            local currentCount, maxCapacity = getBackpackInfo()
            if currentCount > 0 or maxCapacity > 0 then
                backpackInfoLabel:Set("Backpack: " .. currentCount .. "/" .. maxCapacity .. 
                                     " (Sell at: " .. Config.SellCount .. ")")
            else
                backpackInfoLabel:Set("Backpack: Not available")
            end
        elseif backpackInfoLabel then
            backpackInfoLabel:Set("Backpack: Delay mode active")
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Config.BlatantMode and Config.AutoSellEnabled then
            local currentCount, maxCapacity = getBackpackInfo()
            if currentCount >= maxCapacity * 0.9 then
                library:MakeNotification({
                    Name = "⚠️ Backpack Almost Full", 
                    Content = currentCount .. "/" .. maxCapacity .. " fish", 
                    Time = 2
                })
            end
        end
    end
end)


Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if Config.BlatantMode then
            Config.BlatantMode = false
            library:MakeNotification({Name = "Character Died", Content = "Blatant fishing stopped!", Time = 3})
        end
    end)
end)

Player.CharacterAdded:Connect(function()
    task.wait(1)
    updateSpeed()
end)

library:Init()
library:MakeNotification({Name = "Welcome to Mahiru Script!", Content = "By LangitDev!", Time = 5})

task.wait(10)
if not Network.Loaded then
    loadNetwork() 
end

print([[
Welcome To Mahiru Script
By LangitDev
]])