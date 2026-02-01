
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

local IsengV1_Enabled = false
local IsengV2_Enabled = false
local SelectedVictim = nil
local IsengV3_Enabled = false
local FrozenPlayers = {}

local WebhookConfig = {
    Enabled = false,
    URL = "",
    TierFilter = {},
    NameFilter = {},
    HideName = ""
}
local FishData = {}

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

local IdentityElements = {}
local OriginalIdentity = {}
local IsIdentityHidden = false

local IsAutoEvent = false
local SelectedEvent = nil
local FarmPosition = nil
local EventPart = nil

local IsAutoDeepSeaQuest = false
local IsAutoElementQuest = false

local IsAutoWeather = false
local SelectedWeathers = {}

local AutoFavoriteConfig = {
    Enabled = false,
    FishNames = {},
    Rarities = {},
    Variants = {}
}
local FavoriteStates = {}

local SelectedRod = nil
local SelectedBait = nil
local SelectedBoat = nil
local RodLookup = {}
local BaitLookup = {}
local BoatLookup = {}

local SelectedLocation = nil
local SelectedPlayer = nil
local PlayerList = {}


local function CreatePingFPSGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MahiruPingFPS"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 180, 0, 60)
    frame.Position = UDim2.new(0, 20, 0, 200)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -10, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "Mahiru"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(255, 170, 170)

    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(1, -20, 0, 1)
    line.Position = UDim2.new(0, 10, 0, 28)
    line.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    line.BorderSizePixel = 0

    local info = Instance.new("TextLabel", frame)
    info.Size = UDim2.new(1, -10, 0, 25)
    info.Position = UDim2.new(0, 10, 0, 32)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.GothamMedium
    info.TextSize = 14
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Text = "Ping: -- | FPS: --"
    
    local watermark = Instance.new("TextLabel", frame)
    watermark.Size = UDim2.new(0, 40, 0, 15)
    watermark.Position = UDim2.new(1, -45, 0, 5)
    watermark.BackgroundTransparency = 1
    watermark.Text = "LangitDev"
    watermark.Font = Enum.Font.GothamBold
    watermark.TextSize = 10
    watermark.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundTransparency = 0.8
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    closeBtn.Text = "-"
    closeBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.AutoButtonColor = false
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = not gui.Enabled
        closeBtn.Text = gui.Enabled and "X" or "▶"
    end)
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundTransparency = 0.5
    end)
    
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundTransparency = 0.8
    end)
    
    local fps = 0
    local frames = 0
    local lastTime = os.clock()

    local conn
    conn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = os.clock()

        if now - lastTime >= 0.5 then  
            fps = math.floor(frames / (now - lastTime))
            frames = 0
            lastTime = now

            local ping = math.floor(
                Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            )
            
            local color
            if ping < 100 and fps > 60 then
                color = Color3.fromRGB(100, 255, 100)  
                frame.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
            elseif ping < 200 and fps > 30 then
                color = Color3.fromRGB(255, 255, 100)  
                frame.BackgroundColor3 = Color3.fromRGB(50, 50, 30)
            else
                color = Color3.fromRGB(255, 100, 100) 
                frame.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
            end

            info.TextColor3 = color
            info.Text = string.format("Ping: %dms | FPS: %d", ping, fps)
            
            
            if ping < 100 then
                watermark.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif ping < 300 then
                watermark.TextColor3 = Color3.fromRGB(255, 255, 100)
            else
                watermark.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
    end)
    
    
    local hotkeyConnection
    hotkeyConnection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F4 then
            gui.Enabled = not gui.Enabled
            closeBtn.Text = gui.Enabled and "X" or "▶"
        end
    end)
    
    gui.Destroying:Once(function()
        if conn then 
            conn:Disconnect() 
            conn = nil
        end
        if hotkeyConnection then
            hotkeyConnection:Disconnect()
            hotkeyConnection = nil
        end
        print("PingFPS successfully")
    end)

    print("PingFPS created successfully!")
    return gui
end


function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.0fK", num / 1000)
    end
    return tostring(num)
end



function GetFishCount()
    local bagLabel = PlayerGui.Inventory.Main.Top.Options.Fish.Label.BagSize
    local text = bagLabel.Text or "0/???"
    local current = tonumber(text:match("(%d+)/")) or 0
    return current
end

function GetThumbnailUrl(assetId)
    local id = assetId:match("rbxassetid://(%d+)")
    if not id then return nil end
    
    local url = string.format("https://thumbnails.roblox.com/v1/assets?assetIds=%s&type=Asset&size=420x420&format=Png", id)
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    return success and response.data and response.data[1] and response.data[1].imageUrl
end

function SendWebhook(url, data)
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

function StartBlatantFishingV3()
    IsBlatantFishing = true
    Remotes.RF_AutoFishing:InvokeServer(true)
    
    task.spawn(function()
        while IsBlatantFishing do
                pcall(function()
                    Remotes.RF_Charge:InvokeServer(workspace:GetServerTimeNow())
                end)
                
                pcall(function()
                    Remotes.RF_Minigame:InvokeServer(-1, 0.999)
                end)
                
                task.wait(V3_CancelDelay)
                pcall(function()
                    Remotes.RE_Fishing:FireServer()
                end)
            
            task.wait(V3_CompleteDelay)
        end
    end)
end

function StartBlatantFishingV2()
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

function StartBlatantFishing()
    IsBlatantFishing = true
    Remotes.RF_AutoFishing:InvokeServer(true)
    
    task.spawn(function()
        while IsBlatantFishing do
            task.spawn(function()
                pcall(function()
                    Remotes.RF_Cancel:InvokeServer()
                end)
                
                pcall(function()
                    Remotes.RF_Charge:InvokeServer(workspace:GetServerTimeNow())
                end)
                
                pcall(function()
                    Remotes.RF_Minigame:InvokeServer(-1, 0.999)
                end)
                task.wait(BlatantBaitDelay)
                task.wait(BlatantFishingDelay)
                pcall(function()
                    Remotes.RE_Fishing:FireServer()
                end)
            end)
            
            task.wait(BlatantReelDelay)
        end
    end)
end

function StartAutoSell()
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

local Lighting = game:GetService("Lighting")

local function EnableFPSBooster()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Beam") then
            v.Enabled = false
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
end
local function DisableFPSBooster()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    Lighting.GlobalShadows = true
end


function SendFishWebhook(fishId, metadata)
    if not WebhookConfig.Enabled or not WebhookConfig.URL then return end
    
    local fishInfo = FishData[fishId]
    if not fishInfo then return end
    
    local tierName = fishInfo.Tier or "Unknown"
    local weight = metadata and metadata.Weight and string.format("%.2f Kg", metadata.Weight) or "N/A"
    local variant = metadata and metadata.VariantId and tostring(metadata.VariantId) or "None"
    local price = fishInfo.SellPrice and "$" .. FormatNumber(fishInfo.SellPrice) or "N/A"
    
    local embed = {
        username = "Mahiru Notification!",
        avatar_url = "https://i.imgur.com/ly3iUKn.jpeg",
        embeds = {{
            description = string.format("Congratulations **%s**! You just caught a **%s** fish!", 
                WebhookConfig.HideName ~= "" and WebhookConfig.HideName or LocalPlayer.Name, 
                tierName),
            color = 16738740,
            author = {name = "Mahiru Webhook | Fish Caught"},
            image = {url = GetThumbnailUrl(fishInfo.Icon) or "https://i.imgur.com/ly3iUKn.jpeg"},
            fields = {
                {name = "🎣 Fish Name", value = "```❯ " .. fishInfo.Name .. "```"},
                {name = "🌟 Tier", value = "```❯ " .. tierName .. "```"},
                {name = "⚖️ Weight", value = "```❯ " .. weight .. "```"},
                {name = "🌀 Mutation", value = "```❯ " .. variant .. "```"},
                {name = "💰 Sell Price", value = "```❯ " .. price .. "```"},
                {name = "🕒 Caught At", value = "```❯ " .. os.date("%Y-%m-%d %H:%M:%S") .. "```"}
            },
            footer = {text = "Powered By Mahiru", icon_url = "https://i.imgur.com/ly3iUKn.jpeg"},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }}
    }
    
    SendWebhook(WebhookConfig.URL, embed)
end

task.spawn(function()
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

task.spawn(function()
    repeat task.wait(1) until Remotes.RE_ObtainedNewFishNotification
    Remotes.RE_ObtainedNewFishNotification.OnClientEvent:Connect(function(fishId, metadata)
        if WebhookConfig.Enabled then
            SendFishWebhook(fishId, metadata)
        end
    end)
end)

local VirtualUserRef = cloneref(game:GetService("VirtualUser")) or game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUserRef:CaptureController()
    VirtualUserRef:ClickButton2(Vector2.new())
end)

local MahiruUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/LangitDeveloper/hh/main/mahiruui.lua"))()
local Window = MahiruUi:CreateWindow({
    Title = "Mahiru",
    Icon = "rbxassetid://78018573702743",
    Author = "LangitDev",
    Folder = "Mahiru",
    Size = UDim2.fromOffset(380, 260),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
})

local ConfigManager = Window.ConfigManager:CreateConfig("mahiruconfig")

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
        Window:Toggle()
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

Window:SetToggleKey(Enum.KeyCode.F3)
Window:IsResizable(true)

local InfoTab = Window:Tab({Title = "Info", Icon = "info"})
local PlayerTab = Window:Tab({Title = "Player", Icon = "users"})
local FishingTab = Window:Tab({Title = "Fishing", Icon = "rbxassetid://103247953194129"})
local AutomaticTab = Window:Tab({Title = "Automatic", Icon = "rbxassetid://12662718374"})
local WebhookTab = Window:Tab({Title = "Webhook", Icon = "rbxassetid://137601480983962"})
local QuestTab = Window:Tab({Title = "Quest", Icon = "rbxassetid://114127804740858"})
local UtilitiesTab = Window:Tab({Title = "Utilities", Icon = "box"})
local ShopTab = Window:Tab({Title = "Shop", Icon = "shopping-cart"})
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map"})

InfoTab:Paragraph({
    Title = "Mahiru Alert!",
    Desc = "Welcome To Script Mahiru, By LangitDev",
    Color = "Green",
    Image = "rbxassetid://12633176980",
    ImageSize = 30,
})

InfoTab:Button({
    Title = "Need Help?",
    Desc = "Click This To Copy Discord Link.\nJoin to <font color=\"#FF90E3\">Discord Mahiru</font>!",
    Callback = function()
        if setclipboard then
            setclipboard("discord.gg/mahiruscript")
            MahiruUi:Notify({
                Title = "Success",
                Content = "Discord link copied to clipboard!",
                Duration = 3,
                Icon = "laptop-minimal-check",
            })
        else
            MahiruUi:Notify({
                Title = "Error",
                Content = "Executor doesn't support clipboard!",
                Duration = 3,
                Icon = "circle-x",
            })
        end
    end,
})

InfoTab:Space()

local function RejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

local function ServerHop()
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
        MahiruUi:Notify({
            Title = "Error",
            Content = "No servers available or all are full",
            Duration = 2.5,
            Icon = "circle-x",
        })
    end
end

InfoTab:Button({
    Title = "Rejoin Server",
    Callback = RejoinServer
})

InfoTab:Button({
    Title = "Server Hop",
    Desc = "Join a new server",
    Callback = ServerHop
})

local InterfaceSection = PlayerTab:Section({Title = "User Interface"})
local ThemeToggle = InterfaceSection:Toggle({
    Title = "Change Theme",
    Desc = "Dark = OFF | Light = ON",
    Value = false,
    Callback = function(value)
        if value then
            MahiruUi:SetTheme("Light Theme")
        else
            MahiruUi:SetTheme("Dark Theme")
        end
    end,
})
ConfigManager:Register("themeToggle", ThemeToggle)

local PfpsSection = PlayerTab:Section({Title = "Tools Fps Booster"})

local StatsGui

local PerfopToggle = PfpoSection:Toggle({
    Title = "Enable Remote Logger",
    Default = false,
    Callback = function(v)
        RemoteLogger.Enabled = v
        LoggerGui.Enabled = v

        if not v then
            RemoteLogger.Logs = {}
            LogBox.Text = "Waiting..."
        end
    end
})
ConfigManager:Register("PerfopToggle", PerfopToggle)

local PerfomToggle = PfpsSection:Toggle({
    Title = "Show Ping & FPS",
    Default = false,
    Callback = function(state)
        if state then
            StatsGui = CreatePingFPSGui()
        else
            if StatsGui then
                StatsGui:Destroy()
                StatsGui = nil
            end
        end
    end
})
ConfigManager:Register("PerfomToggle", PerfomToggle)

local FPSBoostToggle = PfpsSection:Toggle({
    Title = "FPS Booster",
    Default = false,
    Callback = function(state)
        if state then
            EnableFPSBooster()
        else
            DisableFPSBooster()
        end
    end
})

ConfigManager:Register("FPSBoostToggle", FPSBoostToggle)


local MovementSection = PlayerTab:Section({Title = "Movement"})
local WalkSpeedSlider = MovementSection:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = {Min = 16, Max = 200, Default = 16},
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end,
})

local JumpPowerSlider = MovementSection:Slider({
    Title = "JumpPower",
    Step = 1,
    Value = {Min = 50, Max = 500, Default = 50},
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end,
})

MovementSection:Button({
    Title = "Reset Speed And Jump",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
            WalkSpeedSlider:Set(16)
            JumpPowerSlider:Set(50)
            MahiruUi:Notify({
                Title = "Success",
                Content = "Speed and jump reset successfully",
                Duration = 2.5,
                Icon = "laptop-minimal-check",
            })
        end
    end,
})

MovementSection:Divider()

local FlySpeedSlider = MovementSection:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = {Min = 1, Max = 10, Default = 1},
    Callback = function(value)
        FlySpeed = value
    end,
})

local FlyToggle = MovementSection:Toggle({
    Title = "Enable Fly",
    Value = false,
    Callback = function(value)
        if value then
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            local bodyVelocity = Instance.new("BodyVelocity")
            local bodyGyro = Instance.new("BodyGyro")
            
            bodyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
            bodyGyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
            bodyGyro.P = 90000
            
            bodyVelocity.Parent = humanoidRootPart
            bodyGyro.Parent = humanoidRootPart
            humanoid.PlatformStand = true
            
            local keys = {W = 0, A = 0, S = 0, D = 0, Space = 0, Shift = 0}
            
            local inputBegan = UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.W then keys.W = 1
                elseif input.KeyCode == Enum.KeyCode.A then keys.A = -1
                elseif input.KeyCode == Enum.KeyCode.S then keys.S = -1
                elseif input.KeyCode == Enum.KeyCode.D then keys.D = 1
                elseif input.KeyCode == Enum.KeyCode.Space then keys.Space = 1
                elseif input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift = -1
                end
            end)
            
            local inputEnded = UserInputService.InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.W then keys.W = 0
                elseif input.KeyCode == Enum.KeyCode.A then keys.A = 0
                elseif input.KeyCode == Enum.KeyCode.S then keys.S = 0
                elseif input.KeyCode == Enum.KeyCode.D then keys.D = 0
                elseif input.KeyCode == Enum.KeyCode.Space then keys.Space = 0
                elseif input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift = 0
                end
            end)
            
            task.spawn(function()
                while IsFlyEnabled do
                    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                    
                    local lookVector = workspace.CurrentCamera.CFrame.LookVector
                    local rightVector = workspace.CurrentCamera.CFrame.RightVector
                    
                    local moveDirection = (lookVector * (keys.W + keys.S)) + 
                                         (rightVector * (keys.A + keys.D)) +
                                         Vector3.new(0, keys.Space + keys.Shift, 0)
                    
                    if moveDirection.Magnitude > 0 then
                        bodyVelocity.Velocity = moveDirection.Unit * FlySpeed * 50
                    else
                        bodyVelocity.Velocity = Vector3.zero
                    end
                    
                    task.wait()
                end
                
                bodyVelocity:Destroy()
                bodyGyro:Destroy()
                humanoid.PlatformStand = false
                inputBegan:Disconnect()
                inputEnded:Disconnect()
            end)
            
            IsFlyEnabled = true
        else
            IsFlyEnabled = false
        end
    end,
})

local ModesSection = PlayerTab:Section({Title = "Modes"})

local NoAnimationToggle = ModesSection:Toggle({
    Title = "No Animations",
    Value = false,
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
                    
                    if not NoAnimationConnection then
                        NoAnimationConnection = animator.AnimationPlayed:Connect(function(track)
                            task.defer(function()
                                if IsNoAnimation then
                                    pcall(function() 
                                        track:Stop(0) 
                                        track:Destroy()
                                    end)
                                end
                            end)
                        end)
                    end
                end
            end
            
            MahiruUi:Notify({
                Title = "No Animation",
                Content = "Animations disabled",
                Duration = 2,
                Icon = "square-slash",
            })
        else
            if NoAnimationConnection then
                NoAnimationConnection:Disconnect()
                NoAnimationConnection = nil
            end
            
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
            
            MahiruUi:Notify({
                Title = "No Animation",
                Content = "Animations enabled",
                Duration = 2,
                Icon = "square-play",
            })
        end
    end,
})
ConfigManager:Register("noAnimationToggle", NoAnimationToggle)

ModesSection:Toggle({
    Title = "Hide Rod On Hand",
    Desc = "This feature makes rod invisible! and hides other player's rods too",
    Value = false,
    Callback = function(value)
        IsHideRod = value
        if value then
            task.spawn(function()
                while IsHideRod do
                    for _, character in ipairs(workspace.Characters:GetChildren()) do
                        local equippedTool = character:FindFirstChild("!!!EQUIPPED_TOOL!!!")
                        if equippedTool then
                            equippedTool:Destroy()
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

ModesSection:Divider()

local InfiniteJumpToggle = ModesSection:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(value)
        IsInfiniteJump = value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if IsInfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local NoClipToggle = ModesSection:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(value)
        IsNoClip = value
        if value then
            MahiruUi:Notify({
                Title = "Success",
                Content = "Noclip enabled",
                Duration = 2.5,
                Icon = "laptop-minimal-check",
            })
        end
    end,
})

RunService.Stepped:Connect(function()
    if IsNoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local WalkOnWaterToggle = ModesSection:Toggle({
    Title = "Walk On Water",
    Value = false,
    Callback = function(value)
        IsWalkOnWater = value
        if value then
            local waterPart = Instance.new("Part")
            waterPart.Name = "WW_Part"
            waterPart.Size = Vector3.new(20, 1, 20)
            waterPart.Transparency = 1
            waterPart.Anchored = true
            waterPart.CanCollide = true
            waterPart.Parent = workspace
            
            local connection = RunService.Heartbeat:Connect(function()
                if not IsWalkOnWater or not waterPart then return end
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
                if rootPart then
                    waterPart.CFrame = CFrame.new(rootPart.Position.X, -1.8, rootPart.Position.Z)
                end
            end)
        else
            local waterPart = workspace:FindFirstChild("WW_Part")
            if waterPart then waterPart:Destroy() end
        end
    end,
})

local MaxZoomToggle = ModesSection:Toggle({
    Title = "Max Zoom 1000",
    Desc = "Increase max camera distance",
    Value = false,
    Callback = function(value)
        if value then
            LocalPlayer.CameraMaxZoomDistance = 1000
            LocalPlayer.CameraMinZoomDistance = 0.5
            
            LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.3)
                LocalPlayer.CameraMaxZoomDistance = 1000
                LocalPlayer.CameraMinZoomDistance = 0.5
            end)
        else
            LocalPlayer.CameraMaxZoomDistance = 128
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end,
})

local BoostSection = PlayerTab:Section({Title = "Boost Player"})

local DisableVFXToggle = BoostSection:Toggle({
    Title = "Disable VFX",
    Value = false,
    Callback = function(value)
        IsDisableVFX = value
        if value then
            local success, vfxController = pcall(function()
                return require(ReplicatedStorage.Controllers.VFXController)
            end)
            
            if success and vfxController then
                for name, func in pairs(vfxController) do
                    if type(func) == "function" then
                        vfxController[name] = function() end
                    end
                end
            end
        end
    end,
})

local DisableCutsceneToggle = BoostSection:Toggle({
    Title = "Disable Cutscene",
    Value = false,
    Callback = function(value)
        IsDisableCutscene = value
        if value then
            if Remotes.RE_Cutscene then
                Remotes.RE_Cutscene.OnClientEvent:Connect(function() end)
            end
            if Remotes.RE_StopCutscene then
                Remotes.RE_StopCutscene.OnClientEvent:Connect(function() end)
            end
        end
    end,
})
ConfigManager:Register("cutsceneToggle", DisableCutsceneToggle)

local DisableFishNotificationToggle = BoostSection:Toggle({
    Title = "Disable Obtained Fish",
    Value = false,
    Callback = function(value)
        IsDisableFishNotification = value
        local notification = PlayerGui:FindFirstChild("Small Notification")
        if notification and notification:FindFirstChild("Display") then
            notification.Display.Visible = not value
        end
    end,
})
ConfigManager:Register("obtainedFishToggle", DisableFishNotificationToggle)

local RenderSection = PlayerTab:Section({Title = "Rendering"})

RenderSection:Toggle({
    Title = "Reduce Map",
    Desc = "Don't turn this on with Disable 3D Render",
    Value = false,
    Callback = function(value)
        if value then
            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.Material = Enum.Material.Plastic
                    descendant.CastShadow = false
                    descendant.Reflectance = 0
                elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                    descendant.Transparency = 1
                elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
                    descendant.Enabled = false
                elseif descendant:IsA("Highlight") then
                    descendant:Destroy()
                end
            end
            
            local lighting = game:GetService("Lighting")
            for _, effect in ipairs(lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false
                end
            end
            
            lighting.GlobalShadows = false
            lighting.FogStart = 9000000000
            lighting.FogEnd = 9000000000
        end
    end,
})

RenderSection:Toggle({
    Title = "Disable 3D Rendering",
    Value = false,
    Callback = function(value)
        RunService:Set3dRenderingEnabled(not value)
        MahiruUi:Notify({
            Title = value and "Disabled" or "Enabled",
            Content = value and "3D Render disabled" or "3D Render enabled",
            Duration = 2.5,
            Icon = value and "circle-x" or "laptop-minimal-check",
        })
    end,
})

local ESPToggle = RenderSection:Toggle({
    Title = "Player ESP",
    Value = false,
    Callback = function(value)
        ESPEnabled = value
        if value then
            task.spawn(function()
                while ESPEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local head = player.Character:FindFirstChild("Head")
                            if head then
                                if not ESPObjects[player] then
                                    local billboard = Instance.new("BillboardGui")
                                    billboard.Name = "ESP_" .. player.Name
                                    billboard.Size = UDim2.new(0, 200, 0, 40)
                                    billboard.AlwaysOnTop = true
                                    billboard.MaxDistance = 3000
                                    billboard.Adornee = head
                                    billboard.Parent = head
                                    
                                    local label = Instance.new("TextLabel")
                                    label.Name = "LBL"
                                    label.BackgroundTransparency = 1
                                    label.Size = UDim2.new(1, 0, 1, 0)
                                    label.Font = Enum.Font.SourceSansBold
                                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    label.TextStrokeTransparency = 0.3
                                    label.TextSize = 14
                                    label.Text = player.Name
                                    label.Parent = billboard
                                    
                                    ESPObjects[player] = billboard
                                end
                                
                             
                                local esp = ESPObjects[player]
                                if esp then
                                    local label = esp:FindFirstChild("LBL")
                                    if label then
                                        local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        
                                        if playerRoot and localRoot then
                                            label.Text = player.Name .. "\n(" .. math.floor((playerRoot.Position - localRoot.Position).Magnitude) .. " M)"
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
                
               
                for player, esp in pairs(ESPObjects) do
                    if esp then esp:Destroy() end
                end
                ESPObjects = {}
            end)
        end
    end,
})

local HideIdentSection = PlayerTab:Section({Title = "Identity"})

local function SetupIdentity()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local overhead = character:WaitForChild("HumanoidRootPart"):WaitForChild("Overhead")
    
    IdentityElements = {
        Title = overhead.TitleContainer:WaitForChild("Label"),
        Header = overhead.Content:WaitForChild("Header"),
        Level = overhead.LevelContainer:WaitForChild("Label"),
        Grad = overhead.TitleContainer.Label:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", overhead.TitleContainer.Label),
        Watermark = overhead:FindFirstChild("MahiruWatermark")
    }
    
    if not IdentityElements.Watermark then
        IdentityElements.Watermark = Instance.new("TextLabel")
        IdentityElements.Watermark.Name = "MahiruWatermark"
        IdentityElements.Watermark.Parent = overhead
        IdentityElements.Watermark.Text = "[Mahiru]"
        IdentityElements.Watermark.TextColor3 = Color3.fromRGB(255, 105, 180)
        IdentityElements.Watermark.TextScaled = true
        IdentityElements.Watermark.Font = Enum.Font.SourceSansBold
        IdentityElements.Watermark.BackgroundTransparency = 1
        IdentityElements.Watermark.Size = UDim2.new(1, 0, 0.25, 0)
        IdentityElements.Watermark.Visible = false
    end
    
    OriginalIdentity = {
        Title = IdentityElements.Title.Text,
        Header = IdentityElements.Header.Text,
        Level = IdentityElements.Level.Text,
        Grad = IdentityElements.Grad.Color,
        Rotation = IdentityElements.Grad.Rotation,
        WatermarkVisible = IdentityElements.Watermark.Visible
    }
end

local function HideIdentity()
    if not IdentityElements.Title then return end
    
    IdentityElements.Title.Text = "Mahiru"
    IdentityElements.Header.Text = OriginalIdentity.NewHeader or OriginalIdentity.Header
    IdentityElements.Level.Text = OriginalIdentity.NewLevel or OriginalIdentity.Level
    IdentityElements.Grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 85, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(136, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(136, 243, 255))
    })
    IdentityElements.Grad.Rotation = 0
    IdentityElements.Watermark.Visible = true
end

local function ShowIdentity()
    if not IdentityElements.Title then return end
    
    IdentityElements.Title.Text = OriginalIdentity.Title
    IdentityElements.Header.Text = OriginalIdentity.Header
    IdentityElements.Level.Text = OriginalIdentity.Level
    IdentityElements.Grad.Color = OriginalIdentity.Grad
    IdentityElements.Grad.Rotation = OriginalIdentity.Rotation
    IdentityElements.Watermark.Visible = false
end

local NameChangerInput = HideIdentSection:Input({
    Title = "Name Changer",
    Value = "",
    Placeholder = "Mahiru",
    Callback = function(value)
        OriginalIdentity.NewHeader = value
    end,
})
ConfigManager:Register("nameChangerInput", NameChangerInput)

local LevelChangerInput = HideIdentSection:Input({
    Title = "Level Changer",
    Value = "",
    Placeholder = "Lvl: ",
    Callback = function(value)
        OriginalIdentity.NewLevel = value
    end,
})
ConfigManager:Register("levelChangerInput", LevelChangerInput)

local IdentityToggle = HideIdentSection:Toggle({
    Title = "Start Hide Identity",
    Value = false,
    Callback = function(value)
        OriginalIdentity.ToggleState = value
        if value then
            HideIdentity()
            task.spawn(function()
                while OriginalIdentity.ToggleState do
                    HideIdentity()
                    task.wait(1)
                end
            end)
        else
            ShowIdentity()
        end
    end,
})
ConfigManager:Register("startIdentityToggle", IdentityToggle)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.1)
    SetupIdentity()
    if OriginalIdentity.ToggleState then
        HideIdentity()
    end
end)

HideIdentSection:Button({
    Title = "Reset Character In Place",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local position = rootPart.CFrame
        character:BreakJoints()
        
        LocalPlayer.CharacterAdded:Wait()
        task.wait(0.2)
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = position
        
        MahiruUi:Notify({
            Title = "Success",
            Content = "Character reset in same location!",
            Duration = 2.5,
            Icon = "laptop-minimal-check",
        })
    end,
})

SetupIdentity()

local FishingSection = FishingTab:Section({Title = "Auto Fishing"})

local LegitDelayInput = FishingSection:Input({
    Title = "Legit Delay",
    Desc = "Delay complete fishing!",
    Value = "",
    Placeholder = "Default: 0.2",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            LegitFishingDelay = num
        end
    end,
})
ConfigManager:Register("legitInput", LegitDelayInput)

local ShakeDelayInput = FishingSection:Input({
    Title = "Shake Delay",
    Value = "",
    Placeholder = "Default: 0.15",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            ShakeDelay = num
        end
    end,
})
ConfigManager:Register("shakeInput", ShakeDelayInput)

local LegitFishingToggle = FishingSection:Toggle({
    Title = "Legit Fishing",
    Value = false,
    Callback = function(value)
        if value then
            StartLegitFishing()
        else
            IsLegitFishing = false
            FishingController._autoLoop = false
        end
    end,
})
ConfigManager:Register("LegitFishingToggle", LegitFishingToggle)

local AutoShakeToggle = FishingSection:Toggle({
    Title = "Auto Shake",
    Desc = "Spam click during fishing (only legit)",
    Value = false,
    Callback = function(value)
        IsAutoShake = value
        local clickEffect = PlayerGui:FindFirstChild("!!! Click Effect")
        if clickEffect then
            clickEffect.Enabled = not value
        end
        
        if value then
            task.spawn(function()
                while IsAutoShake do
                    pcall(function()
                        FishingController:RequestFishingMinigameClick()
                    end)
                    task.wait(ShakeDelay)
                end
            end)
        end
    end,
})
ConfigManager:Register("autoShakeToggle", AutoShakeToggle)

FishingTab:Section({Title = "Instant Fishing"})

FishingTab:Paragraph({
    Title = "Instant Fishing Settings",
    Desc = "For instant fishing, you must first set the completion delay. The default is 0.1.",
    Color = "Green",
    Image = "rbxassetid://103247953194129",
    ImageSize = 30,
})

local InstantDelayInput = FishingTab:Input({
    Title = "Delay Complete",
    Value = "",
    Placeholder = "Default: 0.1",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            InstantFishingDelay = num
        end
    end,
})
ConfigManager:Register("instantDelayCompleteValue", InstantDelayInput)

local InstantFishingToggle = FishingTab:Toggle({
    Title = "Instant Fishing",
    Desc = "Auto instantly catch fish",
    Value = false,
    Callback = function(value)
        if value then
            StartInstantFishing()
        else
            IsInstantFishing = false
            Remotes.RF_AutoFishing:InvokeServer(false)
        end
    end,
})
ConfigManager:Register("instantToggle", InstantFishingToggle)

FishingTab:Toggle({
    Title = "Talon Fishing",
    Desc = "Auto In Game Fishing + Auto Shake",
    Value = false,
    Callback = function(value)
        IsAutoShake = value
        local clickEffect = PlayerGui:FindFirstChild("!!! Click Effect")
        Remotes.RF_AutoFishing:InvokeServer(value)
        
        if value then
            if clickEffect then
                clickEffect.Enabled = false
            end
            task.spawn(function()
                while IsAutoShake do
                    pcall(function()
                        FishingController:RequestFishingMinigameClick()
                    end)
                    task.wait(0.15)
                end
            end)
        elseif clickEffect then
            clickEffect.Enabled = true
        end
    end,
})

FishingTab:Section({Title = "Blatant V1"})

local BlatantReelInput = FishingTab:Input({
    Title = "Delay Reel",
    Desc = "Reel Timing (e.g. 1.9)",
    Value = "",
    Placeholder = "Default: 1.9",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            BlatantReelDelay = num
        end
    end,
})
ConfigManager:Register("blatantReelInput", BlatantReelInput)

local BlatantFishInput = FishingTab:Input({
    Title = "Delay Fishing",
    Desc = "Fishing Timing (e.g. 1.1)",
    Value = "",
    Placeholder = "Default: 1.1",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            BlatantFishingDelay = num
        end
    end,
})
ConfigManager:Register("blatantFishInput", BlatantFishInput)

local BlatantFishingToggle = FishingTab:Toggle({
    Title = "Blatant Fishing",
    Value = false,
    Callback = function(value)
        if value then
            StartBlatantFishing()
        else
            IsBlatantFishing = false
            Remotes.RF_AutoFishing:InvokeServer(false)
        end
    end,
})
ConfigManager:Register("blatantToggle", BlatantFishingToggle)

FishingTab:Button({
    Title = "Recovery Fishing",
    Callback = function()
        pcall(function()
            Remotes.RF_Cancel:InvokeServer()
        end)
    end,
})

FishingTab:Section({Title = "Blatant V2"})

local BlatantBaitInput = FishingTab:Input({
    Title = "Bait Delay",
    Desc = "Delay sebelum charge (e.g. 0.05 = ultra fast)",
    Value = "0.3",
    Placeholder = "0.3",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            BlatantBaitDelay = num
        end
    end,
})
ConfigManager:Register("blatantBaitInput", BlatantBaitInput)

local BlatantCastInput = FishingTab:Input({
    Title = "Cast Delay", 
    Desc = "Delay sebelum minigame (e.g. 0.1 = instant)",
    Value = "0.70",
    Placeholder = "0.70",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            BlatantCastDelay = num
        end
    end,
})
ConfigManager:Register("blatantCastInput", BlatantCastInput)

local BlatantFishingV2Toggle = FishingTab:Toggle({
    Title = "Blatant Fishing",
    Value = false,
    Callback = function(value)
        if value then
            StartBlatantFishingV2()
        else
            IsBlatantFishing = false
            Remotes.RF_AutoFishing:InvokeServer(false)
        end
    end,
})
ConfigManager:Register("blatantV2Toggle", BlatantFishingV2Toggle)

FishingTab:Section({Title = "Blatant V3"})

local BlatantcancelInput = FishingTab:Input({
    Title = "Cancel Delay",
    Desc = "Delay sebelum charge (e.g. 0.05 = ultra fast)",
    Value = "0.3",
    Placeholder = "0.3",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            V3_CancelDelay = num
        end
    end,
})
ConfigManager:Register("blatantcancelInput", BlatantBaitInput)

local BlatantCompleteInput = FishingTab:Input({
    Title = "Complete Delay", 
    Desc = "Delay sebelum minigame (e.g. 0.1 = instant)",
    Value = "0.70",
    Placeholder = "0.70",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            V3_CompleteDelay = num
        end
    end,
})
ConfigManager:Register("blatantCompleteInput", BlatantCastInput)

local BlatantFishingV3Toggle = FishingTab:Toggle({
    Title = "Blatant Fishing V3",
    Value = false,
    Callback = function(value)
        if value then
            StartBlatantFishingV3()
        else
            IsBlatantFishing = false
            Remotes.RF_AutoFishing:InvokeServer(false)
        end
    end,
})
ConfigManager:Register("blatantV3Toggle", BlatantFishingV3Toggle)

local SellSection = AutomaticTab:Section({Title = "Auto Sell"})

SellSection:Dropdown({
    Title = "Select Sell Mode",
    Values = {"Delay", "Count"},
    Value = "Delay",
    Callback = function(value)
        AutoSellMode = tostring(value or AutoSellMode)
    end,
})

SellSection:Input({
    Title = "Sell Value",
    Desc = "Delay = Minute | Count = Fish Count",
    Value = "60",
    Callback = function(value)
        local num = tonumber(value) or 1
        if AutoSellMode == "Delay" then
            AutoSellValue = num
        else
            AutoSellValue = num
        end
    end,
})

SellSection:Toggle({
    Title = "Auto Sell All",
    Value = false,
    Callback = function(value)
        if value then
            StartAutoSell()
        else
            IsAutoSell = false
        end
    end,
})

local WeatherSection = AutomaticTab:Section({Title = "Auto Buy Weather"})

local WeatherDropdown = WeatherSection:Dropdown({
    Title = "Select Weather",
    Desc = "",
    Values = {
        "Cloudy ($10,000)",
        "Wind ($10,000)",
        "Snow ($15,000)",
        "Storm ($35,000)",
        "Radiant ($50,000)",
        "Shark Hunt ($300,000)"
    },
    Multi = true,
    AllowNone = true,
    Callback = function(value)
        SelectedWeathers = {}
        if type(value) == "table" then
            for _, weather in ipairs(value) do
                local name = weather:match("^(.-) %(") or weather
                table.insert(SelectedWeathers, name)
            end
        end
    end,
})
ConfigManager:Register("weatherDropdown", WeatherDropdown)

local WeatherToggle = WeatherSection:Toggle({
    Title = "Auto Buy Weather",
    Value = false,
    Callback = function(value)
        IsAutoWeather = value
        if value then
            task.spawn(function()
                while IsAutoWeather do
                    if #SelectedWeathers > 0 then
                        local currentWeathers = {}
                        local weatherFolder = workspace:FindFirstChild("Weather")
                        if weatherFolder then
                            for _, weather in ipairs(weatherFolder:GetChildren()) do
                                table.insert(currentWeathers, string.lower(weather.Name))
                            end
                        end
                        
                        for _, weather in ipairs(SelectedWeathers) do
                            if not table.find(currentWeathers, string.lower(weather)) then
                                pcall(function()
                                    Remotes.RF_Weather:InvokeServer(weather)
                                end)
                                task.wait(0.1)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})
ConfigManager:Register("weatherToggle", WeatherToggle)

local EventSection = AutomaticTab:Section({Title = "Event Features"})

local function GetActiveEvents()
    local events = {}
    local eventsFrame = PlayerGui:FindFirstChild("Events")
    if eventsFrame and eventsFrame:FindFirstChild("Frame") then
        local eventsContainer = eventsFrame.Frame:FindFirstChild("Events")
        if eventsContainer then
            for _, event in ipairs(eventsContainer:GetChildren()) do
                local displayName = event:FindFirstChild("DisplayName")
                if displayName then
                    local name = displayName.Text or event.Name
                    if type(name) == "string" and name ~= "" then
                        table.insert(events, name:gsub("^Admin %- ", ""))
                    end
                end
            end
        end
    end
    return events
end

local function FindEventPart(eventName)
    if not eventName then return nil end
    
    if eventName == "Megalodon Hunt" then
        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRings then
            for _, ring in ipairs(menuRings:GetChildren()) do
                local megalodon = ring:FindFirstChild("Megalodon Hunt")
                if megalodon then
                    local part = megalodon:FindFirstChild("Megalodon Hunt")
                    if part and part:IsA("BasePart") then
                        return part
                    end
                end
            end
        end
        return nil
    end
    
    local searchFolders = {workspace:FindFirstChild("Props")}
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    if menuRings then
        for _, ring in ipairs(menuRings:GetChildren()) do
            if ring.Name:match("^Props") then
                table.insert(searchFolders, ring)
            end
        end
    end
    
    for _, folder in ipairs(searchFolders) do
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                for _, descendant in ipairs(model:GetDescendants()) do
                    if descendant:IsA("TextLabel") and descendant.Name == "DisplayName" then
                        local text = descendant.ContentText or descendant.Text or ""
                        if text:lower() == eventName:lower() then
                            local ancestor = descendant:FindFirstAncestorOfClass("Model")
                            local part = ancestor and (ancestor:FindFirstChild("Part") or model:FindFirstChild("Part"))
                            if part and part:IsA("BasePart") then
                                return part
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

local EventDropdown = EventSection:Dropdown({
    Title = "Select Event",
    Values = GetActiveEvents() or {},
    Callback = function(value)
        SelectedEvent = value
    end,
})

local EventToggle = EventSection:Toggle({
    Title = "Auto Event",
    Value = false,
    Callback = function(value)
        IsAutoEvent = value
        if value and SelectedEvent then
            FarmPosition = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart").CFrame
            EventPart = FindEventPart(SelectedEvent)
            
            task.spawn(function()
                while IsAutoEvent and SelectedEvent do
                    local eventPart = EventPart or FindEventPart(SelectedEvent)
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    
                    if eventPart and rootPart then
                        if (rootPart.Position - eventPart.Position).Magnitude > 40 then
                            local targetPosition = eventPart.CFrame + Vector3.new(0, 7, 0)
                            character:PivotTo(targetPosition)
                            task.wait(1)
                        end
                    else
                        if FarmPosition and character then
                            character:PivotTo(FarmPosition)
                        end
                    end
                    task.wait(0.2)
                end
                
                if FarmPosition and LocalPlayer.Character then
                    LocalPlayer.Character:PivotTo(FarmPosition)
                end
            end)
        else
            if FarmPosition and LocalPlayer.Character then
                LocalPlayer.Character:PivotTo(FarmPosition)
            end
        end
    end,
})

local FavoriteSection = AutomaticTab:Section({Title = "Favorite Features"})

local FishNames = {}
for _, fish in pairs(FishData) do
    table.insert(FishNames, fish.Name)
end
table.sort(FishNames)

local NameDropdown = FavoriteSection:Dropdown({
    Title = "Name",
    Desc = "Favorite By Name Fish (Recommended)",
    Values = #FishNames > 0 and FishNames or {"No Fish Found"},
    Multi = true,
    AllowNone = true,
    Callback = function(value)
        AutoFavoriteConfig.FishNames = {}
        if type(value) == "table" then
            for _, name in ipairs(value) do
                AutoFavoriteConfig.FishNames[name] = true
            end
        end
    end,
})

FavoriteSection:Button({
    Title = "Refresh Fish",
    Callback = function()
        NameDropdown:Refresh(FishNames)
    end,
})

FavoriteSection:Dropdown({
    Title = "Rarity",
    Desc = "Favorite By Rarity (Optional)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = true,
    AllowNone = true,
    Callback = function(value)
        AutoFavoriteConfig.Rarities = {}
        if type(value) == "table" then
            for _, rarity in ipairs(value) do
                AutoFavoriteConfig.Rarities[rarity] = true
            end
        end
    end,
})

FavoriteSection:Dropdown({
    Title = "Variant",
    Desc = "Favorite By Variant (Only works with Name)",
    Values = {"Galaxy", "Corrupt", "Gemstone", "Ghost", "Lightning", "Fairy Dust", "Gold", "Midnight", "Radioactive", "Stone", "Holographic", "Albino", "Bloodmoon", "Sandy", "Acidic", "Color Burn", "Festive", "Frozen"},
    Multi = true,
    AllowNone = true,
    Callback = function(value)
        if next(AutoFavoriteConfig.FishNames) ~= nil then
            AutoFavoriteConfig.Variants = {}
            if type(value) == "table" then
                for _, variant in ipairs(value) do
                    AutoFavoriteConfig.Variants[variant] = true
                end
            end
        else
            AutoFavoriteConfig.Variants = {}
            warn("Select Name first before Variant!")
        end
    end,
})

local AutoFavoriteToggle = FavoriteSection:Toggle({
    Title = "Auto Favorite",
    Value = false,
    Callback = function(value)
        AutoFavoriteConfig.Enabled = value
        if value then
            local inventory = PlayerData:GetExpect({"Inventory", "Items"}) or {}
            for _, item in ipairs(inventory) do
                local itemData = ItemUtility.GetItemDataFromItemType("Items", item.Id)
                if itemData and itemData.Data.Type == "Fish" then
                    local rarityName = itemData.Data.Tier
                    local fishName = itemData.Data.Name
                    local variant = item.Metadata and item.Metadata.VariantId or "None"
                    
                    local shouldFavorite = false
                    if next(AutoFavoriteConfig.Variants) ~= nil and next(AutoFavoriteConfig.FishNames) ~= nil then
                        shouldFavorite = AutoFavoriteConfig.FishNames[fishName] and AutoFavoriteConfig.Variants[variant]
                    else
                        shouldFavorite = AutoFavoriteConfig.FishNames[fishName] or AutoFavoriteConfig.Rarities[rarityName]
                    end
                    
                    if shouldFavorite and not (FavoriteStates[item.UUID] or item.Favorited) then
                        Remotes.RE_Favorite:FireServer(item.UUID)
                        FavoriteStates[item.UUID] = true
                    end
                end
            end
            
            PlayerData:OnChange({"Inventory", "Items"}, function(inventory)
                if AutoFavoriteConfig.Enabled then
                    for _, item in ipairs(inventory) do
                        local itemData = ItemUtility.GetItemDataFromItemType("Items", item.Id)
                        if itemData and itemData.Data.Type == "Fish" then
                            local rarityName = itemData.Data.Tier
                            local fishName = itemData.Data.Name
                            local variant = item.Metadata and item.Metadata.VariantId or "None"
                            
                            local shouldFavorite = false
                            if next(AutoFavoriteConfig.Variants) ~= nil and next(AutoFavoriteConfig.FishNames) ~= nil then
                                shouldFavorite = AutoFavoriteConfig.FishNames[fishName] and AutoFavoriteConfig.Variants[variant]
                            else
                                shouldFavorite = AutoFavoriteConfig.FishNames[fishName] or AutoFavoriteConfig.Rarities[rarityName]
                            end
                            
                            if shouldFavorite and not (FavoriteStates[item.UUID] or item.Favorited) then
                                Remotes.RE_Favorite:FireServer(item.UUID)
                                FavoriteStates[item.UUID] = true
                            end
                        end
                    end
                end
            end)
        end
    end,
})

FavoriteSection:Button({
    Title = "Unfavorite All",
    Callback = function()
        local inventory = PlayerData:GetExpect({"Inventory", "Items"}) or {}
        for _, item in ipairs(inventory) do
            if FavoriteStates[item.UUID] or item.Favorited then
                Remotes.RE_Favorite:FireServer(item.UUID)
                FavoriteStates[item.UUID] = false
            end
        end
    end,
})

local SPSection = AutomaticTab:Section({Title = "Save Position Features"})

SPSection:Paragraph({
    Title = "Guide Teleport",
    Desc = [[
<b><font color="rgb(0,162,255)">AUTO TELEPORT?</font></b>
Click <b><font color="rgb(0,162,255)">Save Position</font></b> to save your current position!

<b><font color="rgb(0,162,255)">HOW TO LOAD?</font></b>
This feature will auto-sync your last position when executed, so you will teleport automatically!

<b><font color="rgb(0,162,255)">HOW TO RESET?</font></b>
Click <b><font color="rgb(0,162,255)">Reset Position</font></b> to clear your saved position.
    ]],
})

local function SavePosition(position)
    if not isfolder("Mahiru") then
        makefolder("Mahiru")
    end
    if not isfolder("Mahiru/FishIt") then
        makefolder("Mahiru/FishIt")
    end
    writefile("Mahiru/FishIt/Position.json", HttpService:JSONEncode({position:GetComponents()}))
end

local function LoadPosition()
    if isfile("Mahiru/FishIt/Position.json") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("Mahiru/FishIt/Position.json"))
        end)
        if success and type(data) == "table" then
            return CFrame.new(unpack(data))
        end
    end
    return nil
end

local function TeleportToLastPosition()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local savedPosition = LoadPosition()
    
    if savedPosition then
        task.wait(2)
        rootPart.CFrame = savedPosition
        MahiruUi:Notify({
            Title = "Teleported to your last position...",
        })
    end
end

SPSection:Button({
    Title = "Save Position",
    Callback = function()
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            SavePosition(rootPart.CFrame)
            MahiruUi:Notify({
                Title = "Position saved successfully!",
            })
        end
    end,
})

SPSection:Button({
    Title = "Reset Position",
    Callback = function()
        if isfile("Mahiru/FishIt/Position.json") then
            delfile("Mahiru/FishIt/Position.json")
        end
        MahiruUi:Notify({
            Title = "Last position has been reset!",
        })
    end,
})

LocalPlayer.CharacterAdded:Connect(TeleportToLastPosition)
if LocalPlayer.Character then
    TeleportToLastPosition()
end

local EnchantSection = AutomaticTab:Section({Title = "Enchant Features"})

local EnchantStatus = EnchantSection:Paragraph({
    Title = "Enchant Status",
    Desc = "Current Rod : None\nCurrent Enchant : None\nEnchant Stones Left : 0",
})

local function GetEnchantInfo(stoneId)
    local rodName = "None"
    local enchantName = "None"
    local stoneCount = 0
    local stoneUUIDs = {}
    
    local equippedItems = PlayerData:Get("EquippedItems") or {}
    local fishingRods = PlayerData:Get({"Inventory", "Fishing Rods"}) or {}
    
    for slot, uuid in pairs(equippedItems) do
        for _, rod in ipairs(fishingRods) do
            if rod.UUID == uuid then
                local rodData = ItemUtility:GetItemData(rod.Id)
                if rodData then
                    rodName = rodData.Data.Name or rod.ItemName or "None"
                end
                
                if rod.Metadata and rod.Metadata.EnchantId then
                    local enchantData = ItemUtility:GetEnchantData(rod.Metadata.EnchantId)
                    if enchantData then
                        enchantName = enchantData.Data.Name or "Unknown"
                    end
                end
                break
            end
        end
    end
    
    local inventory = PlayerData:GetExpect({"Inventory", "Items"}) or {}
    for _, item in ipairs(inventory) do
        local itemData = ItemUtility:GetItemData(item.Id)
        if itemData and itemData.Data.Type == "Enchant Stones" and item.Id == stoneId then
            stoneCount = stoneCount + 1
            table.insert(stoneUUIDs, item.UUID)
        end
    end
    
    return rodName, enchantName, stoneCount, stoneUUIDs
end

EnchantSection:Button({
    Title = "Click Enchant",
    Callback = function()
        task.spawn(function()
            local rodName, enchantName, stoneCount, stoneUUIDs = GetEnchantInfo(10)
            
            if rodName == "None" or stoneCount <= 0 then
                EnchantStatus:SetDesc(string.format("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>", 
                    rodName, enchantName, stoneCount))
                return
            end
            
            local slot = nil
            local startTime = tick()
            
            while tick() - startTime < 5 do
                local equipped = PlayerData:Get("EquippedItems") or {}
                for s, uuid in pairs(equipped) do
                    if uuid == stoneUUIDs[1] then
                        slot = s
                        break
                    end
                end
                
                if not slot then
                    Remotes.RE_EquipItem:FireServer(stoneUUIDs[1], "Enchant Stones")
                    task.wait(0.3)
                else
                    break
                end
            end
            
            if not slot then return end
            
            Remotes.RE_Equip:FireServer(slot)
            task.wait(0.2)
            Remotes.RE_Altar:FireServer()
            task.wait(1.5)
            
            local newRodName, newEnchantName = GetEnchantInfo(10)
            EnchantStatus:SetDesc(string.format("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>", 
                rodName, newEnchantName, stoneCount - 1))
        end)
    end,
})

EnchantSection:Button({
    Title = "Teleport Enchant Altar",
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if rootPart and humanoid then
            rootPart.CFrame = CFrame.new(Vector3.new(3258, -1301, 1391))
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end,
})

EnchantSection:Divider()

EnchantSection:Button({
    Title = "Click Double Enchant",
    Desc = "Starting Double Enchanting",
    Callback = function()
        task.spawn(function()
            local rodName, enchantName, stoneCount, stoneUUIDs = GetEnchantInfo(246)
            
            if rodName == "None" or stoneCount <= 0 then
                EnchantStatus:SetDesc(string.format("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>", 
                    rodName, enchantName, stoneCount))
                return
            end
            
            local slot = nil
            local startTime = tick()
            
            while tick() - startTime < 5 do
                local equipped = PlayerData:Get("EquippedItems") or {}
                for s, uuid in pairs(equipped) do
                    if uuid == stoneUUIDs[1] then
                        slot = s
                        break
                    end
                end
                
                if not slot then
                    Remotes.RE_EquipItem:FireServer(stoneUUIDs[1], "Enchant Stones")
                    task.wait(0.3)
                else
                    break
                end
            end
            
            if not slot then return end
            
            Remotes.RE_Equip:FireServer(slot)
            task.wait(0.2)
            Remotes.RE_Altar2:FireServer()
            task.wait(1.5)
            
            local newRodName, newEnchantName = GetEnchantInfo(246)
            EnchantStatus:SetDesc(string.format("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>", 
                rodName, newEnchantName, stoneCount - 1))
        end)
    end,
})

EnchantSection:Button({
    Title = "Teleport Second Enchant Altar",
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if rootPart and humanoid then
            rootPart.CFrame = CFrame.new(Vector3.new(1480, 128, -593))
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end,
})

WebhookTab:Section({Title = "Webhook Fish Caught"})

local WebhookURLInput = WebhookTab:Input({
    Title = "Webhook URL",
    Value = "",
    Placeholder = "Input Here",
    Callback = function(value)
        WebhookConfig.URL = value
    end,
})
ConfigManager:Register("webhookURLInput", WebhookURLInput)

WebhookTab:Dropdown({
    Title = "Tier Filter",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Value = {"Mythic", "Secret"},
    Multi = true,
    AllowNone = true,
    Callback = function(value)
        WebhookConfig.TierFilter = value
    end,
})

local FishNameDropdown = WebhookTab:Dropdown({
    Title = "Name Filter",
    Values = #FishNames > 0 and FishNames or {"No Fish Found"},
    Multi = true,
    AllowNone = true,
    Callback = function(value)
        WebhookConfig.NameFilter = value
    end,
})

WebhookTab:Button({
    Title = "Refresh Fish",
    Callback = function()
        FishNameDropdown:Refresh(FishNames)
    end,
})

local WebhookNameInput = WebhookTab:Input({
    Title = "Hide Identity",
    Value = "",
    Placeholder = "Input Here",
    Callback = function(value)
        WebhookConfig.HideName = value
    end,
})
ConfigManager:Register("webhookNameInput", WebhookNameInput)

local WebhookToggle = WebhookTab:Toggle({
    Title = "Send Fish Webhook",
    Value = false,
    Callback = function(value)
        WebhookConfig.Enabled = value
    end,
})
ConfigManager:Register("webhookToggle", WebhookToggle)

WebhookTab:Divider()

WebhookTab:Button({
    Title = "Test Webhook Connection",
    Callback = function()
        if not WebhookConfig.URL or not WebhookConfig.URL:match("discord.com/api/webhooks") then
            warn("[Webhook Test] Invalid or missing webhook URL.")
            return
        end
        
        local testData = {
            content = nil,
            embeds = {{
                color = 44543,
                author = {name = "Webhook is connected :3"},
                image = {url = "https://i.imgur.com/xl9yLMN.gif"},
            }},
            username = "Mahiru Notification!",
            avatar_url = "https://i.imgur.com/ly3iUKn.jpeg",
            attachments = {},
        }
        
        task.spawn(function()
            local success, errorMsg = pcall(function()
                local requestFunc = syn and syn.request or http_request or http and http.request or fluxus and (fluxus.request or request)
                if requestFunc then
                    requestFunc({
                        Url = WebhookConfig.URL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode(testData)
                    })
                end
            end)
            
            if success then
                MahiruUi:Notify({
                    Title = "Success",
                    Content = "Webhook test sent successfully!",
                    Duration = 3,
                    Icon = "laptop-minimal-check",
                })
            else
                MahiruUi:Notify({
                    Title = "Error",
                    Content = "Failed to send webhook: " .. tostring(errorMsg),
                    Duration = 3,
                    Icon = "circle-x",
                })
            end
        end)
    end,
})

local SisyphusSection = QuestTab:Section({Title = "Sisyphus State Quest"})

local DeepSeaPanel = SisyphusSection:Paragraph({
    Title = "Deep Sea Panel",
    Desc = "Loading...",
})

local function GetQuestInfo(questName)
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    local questTracker = menuRings and menuRings:FindFirstChild(questName)
    if not questTracker then return "" end
    
    local board = questTracker:FindFirstChild("Board")
    local gui = board and board:FindFirstChild("Gui")
    local content = gui and gui:FindFirstChild("Content")
    if not content then return "" end
    
    local lines = {}
    local index = 1
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("TextLabel") and child.Name ~= "Header" then
            table.insert(lines, index .. ". " .. child.Text)
            index = index + 1
        end
    end
    
    return table.concat(lines, "\n")
end

local function TeleportTo(x, y, z, rotation)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local cframe = CFrame.new(x, y, z)
        if rotation then
            cframe = cframe * CFrame.Angles(0, math.rad(rotation), 0)
        end
        rootPart.CFrame = cframe
    end
end

SisyphusSection:Toggle({
    Title = "Auto Deep Sea Quest",
    Desc = "Automatically complete Deep Sea Quest!",
    Value = false,
    Callback = function(value)
        IsAutoDeepSeaQuest = value
        task.spawn(function()
            while IsAutoDeepSeaQuest do
                local questInfo = GetQuestInfo("Deep Sea Tracker"):lower()
                if questInfo ~= "" then
                    if string.find(questInfo, "100%%") then
                        TeleportTo(-3763, -135, -995, 180)
                    else
                        TeleportTo(-3599, -276, -1641)
                    end
                end
                task.wait(1)
            end
        end)
    end,
})

SisyphusSection:Button({
    Title = "Treasure Room",
    Callback = function()
        TeleportTo(-3601, -283, -1611)
    end,
})

SisyphusSection:Button({
    Title = "Sisyphus Statue",
    Callback = function()
        TeleportTo(-3698, -135, -1008)
    end,
})

local ElementSection = QuestTab:Section({Title = "Element Quest"})

local ElementPanel = ElementSection:Paragraph({
    Title = "Element Panel",
    Desc = "Loading...",
})

ElementSection:Toggle({
    Title = "Auto Element Quest",
    Desc = "Automatically teleport through Element Quest Stages!",
    Value = false,
    Callback = function(value)
        IsAutoElementQuest = value
        task.spawn(function()
            local completed = false
            while IsAutoElementQuest and not completed do
                local questInfo = GetQuestInfo("Element Tracker")
                local lines = {}
                for line in questInfo:gmatch("[^\n]+") do
                    table.insert(lines, line:lower())
                end
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and #lines >= 4 then
                    local line2 = lines[2]
                    local line4 = lines[4]
                    
                    if not string.find(line4, "100%%") then
                        TeleportTo(1484, 3, -336, 180)
                    elseif string.find(line4, "100%%") and not string.find(line2, "100%%") then
                        TeleportTo(1453, -22, -636)
                    elseif string.find(line2, "100%%") then
                        TeleportTo(1480, 128, -593)
                        completed = true
                        IsAutoElementQuest = false
                        ElementPanel:SetDesc("Element Quest Completed!")
                    end
                end
                task.wait(2)
            end
        end)
    end,
})

ElementSection:Button({
    Title = "Secret Temple",
    Callback = function()
        TeleportTo(1453, -22, -636)
    end,
})

ElementSection:Button({
    Title = "Underground Cellar",
    Callback = function()
        TeleportTo(2136, -91, -701)
    end,
})

ElementSection:Button({
    Title = "Transcended Stones",
    Callback = function()
        TeleportTo(1480, 128, -593)
    end,
})

task.spawn(function()
    while task.wait(2) do
        DeepSeaPanel:SetDesc(GetQuestInfo("Deep Sea Tracker"))
        ElementPanel:SetDesc(GetQuestInfo("Element Tracker"))
    end
end)

local ServerUtilitySection = UtilitiesTab:Section({Title = "Server Utility"})

local AntiStaffToggle = ServerUtilitySection:Toggle({
    Title = "Anti Staff",
    Desc = "Auto kick if staff/developer joins the server",
    Value = false,
    Callback = function(value)
        if value then
            task.spawn(function()
                while value do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local rank = player:GetRankInGroup(35102746)
                            local staffRanks = {
                                [2] = "OG",
                                [3] = "Tester",
                                [4] = "Moderator",
                                [75] = "Community Staff",
                                [79] = "Analytics",
                                [145] = "Divers / Artist",
                                [250] = "Devs",
                                [252] = "Partner",
                                [254] = "Talon",
                                [255] = "Wildes",
                                [55] = "Swimmer",
                                [30] = "Contrib",
                                [35] = "Contrib 2",
                                [100] = "Scuba",
                                [76] = "CC",
                            }
                            
                            if staffRanks[rank] then
                                LocalPlayer:Kick("Mahiru Detected Staff, Automatically Kicked!")
                                return
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})
ConfigManager:Register("antiStaffToggle", AntiStaffToggle)

local StreamerModeToggle = ServerUtilitySection:Toggle({
    Title = "Streamer Mode",
    Desc = "This will hide the location, character, and coins.",
    Value = false,
    Callback = function(value)
        local eventsFrame = PlayerGui.Events.Frame
        local originalValues = {
            CurrencyCounter = eventsFrame.CurrencyCounter.Counter.Text,
            Location = eventsFrame.Location.Label.Text
        }
        
        local originalTransparency = {}
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalTransparency[part] = part.Transparency
                end
            end
        end
        
        if value then
            eventsFrame.CurrencyCounter.Counter.Text = "SENSORED"
            eventsFrame.Location.Label.Text = "SENSORED"
            
            for part, transparency in pairs(originalTransparency) do
                part.Transparency = 1
            end
        else
            eventsFrame.CurrencyCounter.Counter.Text = originalValues.CurrencyCounter
            eventsFrame.Location.Label.Text = originalValues.Location
            
            for part, transparency in pairs(originalTransparency) do
                part.Transparency = transparency
            end
        end
    end,
})
ConfigManager:Register("streamerModeToggle", StreamerModeToggle)

UtilitiesTab:Divider()

local RadarToggle = UtilitiesTab:Toggle({
    Title = "Bypass Radar",
    Value = false,
    Callback = function(value)
        pcall(function()
            Remotes.RF_Radar:InvokeServer(value)
        end)
    end,
})
ConfigManager:Register("radarToggle", RadarToggle)

local DivingGearToggle = UtilitiesTab:Toggle({
    Title = "Bypass Diving Gear",
    Value = false,
    Callback = function(value)
        if not value then
            Remotes.RF_UnequipDiving:InvokeServer()
        else
            local data = Replion.Client:GetReplion("Data")
            if data then
                if data:Get("EquippedOxygenTankId") == DivingGearData.Data.Id then
                    Remotes.RF_UnequipDiving:InvokeServer()
                else
                    Remotes.RF_EquipDiving:InvokeServer(DivingGearData.Data.Id)
                end
            end
        end
    end,
})
ConfigManager:Register("divingGearToggle", DivingGearToggle)

local MerchantShopSection = ShopTab:Section({Title = "Merchant Shop"})

local MerchantPanel = MerchantShopSection:Paragraph({
    Title = "MERCHANT STOCK PANEL",
    Desc = "Loading...",
})

local function UpdateMerchantInfo()
    local items = {}
    for _, itemFrame in ipairs(MerchantUI.ItemsFrame:GetChildren()) do
        if itemFrame:IsA("ImageLabel") and itemFrame.Name ~= "Frame" then
            local frame = itemFrame:FindFirstChild("Frame")
            if frame and frame:FindFirstChild("ItemName") then
                local itemName = frame.ItemName.Text
                if not string.find(itemName, "Mystery") then
                    table.insert(items, "- " .. itemName)
                end
            end
        end
    end
    
    if #items == 0 then
        MerchantPanel:SetDesc("No items found\n" .. MerchantUI.RefreshMerchant.Text)
    else
        MerchantPanel:SetDesc(table.concat(items, "\n") .. "\n\n" .. MerchantUI.RefreshMerchant.Text)
    end
end

MerchantShopSection:Button({
    Title = "Open/Close Merchant",
    Callback = function()
        local merchant = PlayerGui:FindFirstChild("Merchant")
        if not merchant then return end
        
        if merchant:IsA("ScreenGui") then
            merchant.Enabled = not merchant.Enabled
        elseif merchant:IsA("Frame") then
            merchant.Visible = not merchant.Visible
        else
            local main = merchant:FindFirstChild("Main")
            if main and main:IsA("Frame") then
                main.Visible = not main.Visible
            end
        end
    end,
})

task.spawn(function()
    while task.wait(1) do
        pcall(UpdateMerchantInfo)
    end
end)

MerchantShopSection:Button({
    Title = "Teleport To Merchant",
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(-135.96412658691406, 3.143953323364258, 2766.11083984375)
        end
    end,
})

local RodSection = ShopTab:Section({Title = "Purchase Rod"})

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
for name, data in pairs(Rods) do
    table.insert(RodOptions, name)
end
table.sort(RodOptions)

local RodDropdown = RodSection:Dropdown({
    Title = "Select Rod",
    Values = RodOptions,
    Callback = function(value)
        SelectedRod = value
    end,
})

RodSection:Button({
    Title = "Purchase",
    Callback = function()
        if not SelectedRod then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Select Rod First!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        local rodData = Rods[SelectedRod]
        if not rodData then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Rod ID Not Found!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        pcall(function()
            Remotes.RF_PurchaseRod:InvokeServer(rodData.Id)
        end)
    end,
})

local BaitSection = ShopTab:Section({Title = "Purchase Bait"})

local Baits = {
    ["Starter Bait (0)"] = {Id = 1, Price = 0},
    ["Chroma Bait (290K)"] = {Id = 6, Price = 290000},
    ["Gold Bait (0)"] = {Id = 4, Price = 0},
    ["Hyper Bait (0)"] = {Id = 5, Price = 0},
    ["Luck Bait (1K)"] = {Id = 2, Price = 1000},
    ["Midnight Bait (3K)"] = {Id = 3, Price = 3000},
    ["Bag-O-Gold Bait (0)"] = {Id = 7, Price = 0},
    ["Beach Ball Bait (0)"] = {Id = 9, Price = 0},
    ["Topwater Bait (100)"] = {Id = 10, Price = 100},
    ["Anchor Bait (0)"] = {Id = 11, Price = 0},
    ["Ornament Bait (0)"] = {Id = 12, Price = 0},
    ["Jolly Bait (0)"] = {Id = 13, Price = 0},
    ["Frozen Bait (0)"] = {Id = 14, Price = 0},
    ["Dark Matter Bait (630K)"] = {Id = 8, Price = 630000},
    ["Nature Bait (83.5K)"] = {Id = 17, Price = 83500},
    ["Aether Bait (3.7M)"] = {Id = 16, Price = 3700000},
    ["Corrupt Bait (1.1M)"] = {Id = 15, Price = 1148484},
    ["Singularity Bait (0)"] = {Id = 18, Price = 0},
    ["Royal Bait (0)"] = {Id = 19, Price = 0},
    ["Floral Bait (4M)"] = {Id = 20, Price = 4000000},
    ["Radioactive Bait (0)"] = {Id = 21, Price = 0},
    ["Root Bait (0)"] = {Id = 22, Price = 0},
    ["Delayed Orb Bait (0)"] = {Id = 23, Price = 0},
    ["Pumpkin Bait (0)"] = {Id = 24, Price = 0},
    ["Purple Moon Bait (0)"] = {Id = 25, Price = 0},
    ["Corruption Crystal (0)"] = {Id = 27, Price = 0},
    ["Matrix Hologram (0)"] = {Id = 26, Price = 0},
    ["Binary Crystal (0)"] = {Id = 28, Price = 0},
    ["Wyvern Artifact (0)"] = {Id = 29, Price = 0},
}

local BaitOptions = {}
for name, data in pairs(Baits) do
    table.insert(BaitOptions, name)
end
table.sort(BaitOptions)

local BaitDropdown = BaitSection:Dropdown({
    Title = "Select Bait",
    Values = BaitOptions,
    Callback = function(value)
        SelectedBait = value
    end,
})

BaitSection:Button({
    Title = "Purchase",
    Callback = function()
        if not SelectedBait then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Select Bait First!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        local baitData = Baits[SelectedBait]
        if not baitData then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Bait ID Not Found!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        pcall(function()
            Remotes.RF_PurchaseBait:InvokeServer(baitData.Id)
        end)
    end,
})

local BoatSection = ShopTab:Section({Title = "Purchase Boat"})

local Boats = {
    ["Small Boat (300)"] = {Id = 1, Price = 300},
    ["Kayak (1.1K)"] = {Id = 2, Price = 1100},
    ["Jetski (7.5K)"] = {Id = 3, Price = 7500},
    ["Highfield Boat (25K)"] = {Id = 4, Price = 25000},
    ["Speed Boat (70K)"] = {Id = 5, Price = 70000},
    ["Fishing Boat (180K)"] = {Id = 6, Price = 180000},
    ["Mini Yacht (1.2M)"] = {Id = 14, Price = 1200000},
}

local BoatOptions = {}
for name, data in pairs(Boats) do
    table.insert(BoatOptions, name)
end

local BoatDropdown = BoatSection:Dropdown({
    Title = "Select Boat",
    Values = BoatOptions,
    Callback = function(value)
        SelectedBoat = value
    end,
})

BoatSection:Button({
    Title = "Purchase",
    Callback = function()
        if not SelectedBoat then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Select Boat First!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        local boatData = Boats[SelectedBoat]
        if not boatData then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Boat ID Not Found!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        pcall(function()
            Remotes.RF_PurchaseBoat:InvokeServer(boatData.Id)
        end)
    end,
})

local LocationSection = TeleportTab:Section({Title = "Location"})

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

local LocationDropdown = LocationSection:Dropdown({
    Title = "Choose Location",
    Values = Locations,
    Value = "Ancient Jungle",
    Callback = function(value)
        SelectedLocation = value
    end,
})
ConfigManager:Register("tpLocationDropdown", LocationDropdown)

LocationSection:Button({
    Title = "Teleport",
    Callback = function()
        if not SelectedLocation then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Select location first!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        local coordinates = LocationCoordinates[SelectedLocation]
        if not coordinates then return end
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(coordinates) + Vector3.new(0, 3, 0)
        end
    end,
})

local PlayerSection = TeleportTab:Section({Title = "Player"})

local function GetPlayerList()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(players, player.Name)
    end
    return players
end

local PlayerDropdown = PlayerSection:Dropdown({
    Title = "Select Player",
    Values = GetPlayerList(),
    Callback = function(value)
        SelectedPlayer = value
    end,
})

PlayerSection:Button({
    Title = "Refresh",
    Callback = function()
        PlayerDropdown:Refresh(GetPlayerList())
        MahiruUi:Notify({
            Title = "Success",
            Content = "Player list refreshed successfully",
            Duration = 2.5,
            Icon = "laptop-minimal-check",
        })
    end,
})

PlayerSection:Button({
    Title = "Go",
    Callback = function()
        if not SelectedPlayer then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Select player first!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        local targetPlayer = Players:FindFirstChild(SelectedPlayer)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            MahiruUi:Notify({
                Title = "Error",
                Content = "Invalid player!",
                Duration = 2.5,
                Icon = "circle-x",
            })
            return
        end
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end,
})

Window:OnDestroy(function()
    ConfigManager:Save()
    
    if LegitFishingToggle then LegitFishingToggle:Set(false) end
    if AutoShakeToggle then AutoShakeToggle:Set(false) end
    if InstantFishingToggle then InstantFishingToggle:Set(false) end
    if BlatantFishingToggle then BlatantFishingToggle:Set(false) end
    if WebhookToggle then WebhookToggle:Set(false) end
    if AntiStaffToggle then AntiStaffToggle:Set(false) end
    if RadarToggle then RadarToggle:Set(false) end
    if DivingGearToggle then DivingGearToggle:Set(false) end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
        WalkSpeedSlider:Set(16)
        JumpPowerSlider:Set(50)
    end
    
    IdentityToggle:Set(false)
    
    if IsNoClip then
        NoClipToggle:Set(false)
    end
    
    if AntiStaffToggle then
        AntiStaffToggle:Set(false)
    end
    
    if IsAutoEvent then
        EventToggle:Set(false)
        if FarmPosition and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(FarmPosition)
        end
    end
    
    LocalPlayer.CameraMaxZoomDistance = 128
    LocalPlayer.CameraMinZoomDistance = 0.5
 
    if IsDisableCutscene then
    end
    
    if IsDisableVFX then
    end
    
    if IsDisableFishNotification then
        local notification = PlayerGui:FindFirstChild("Small Notification")
        if notification and notification:FindFirstChild("Display") then
            notification.Display.Visible = true
        end
    end
    
    if ESPEnabled then
        ESPToggle:Set(false)
    end
    
    FlySpeed = 1
    FlySpeedSlider:Set(1)
    IsFlyEnabled = false
    
    if IsNoAnimation then
        NoAnimationToggle:Set(false)
    end
    
    if IsHideRod then
    end
    
    local toggleButton = game.CoreGui:FindFirstChild("ToggleUIButton")
    if toggleButton then
        toggleButton:Destroy()
    end
    
    print("Mahiru cleaned up successfully!")
end)

ConfigManager:Load()

print("Mahiru Loaded Successfully...")
print("Happy Fishing Brotherrrrr...")