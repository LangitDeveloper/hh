local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui,
    Camera = workspace.CurrentCamera,
    GuiService = game:GetService("GuiService"),
    CoreGui = game:GetService("CoreGui"),
}

local Global = _G
local SynHttp = syn

if SynHttp then
    SynHttp = syn.request
    if not SynHttp then
        ::label_54::
        SynHttp = http
        if SynHttp then
            SynHttp = http.request
            if not SynHttp then
                ::label_61::
                SynHttp = http_request
                if not SynHttp then
                    SynHttp = fluxus
                    if SynHttp then
                        SynHttp = fluxus.request or request
                    else
                        goto label_71
                    end
                end
            end
        else
            goto label_61
        end
    end
else
    goto label_54
end

Global.httpRequest = SynHttp

if not _G.httpRequest then
    return
end

local LocalPlayer = Services.Players.LocalPlayer
Services.PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
end


if not LocalPlayer.Character or not LocalPlayer.Character:WaitForChild("HumanoidRootPart") then
    local HRP = LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
end

local PositionFilePath = "ChloeX_FishIt_Position.json"

function SavePosition(cframe)
    local data = {cframe:GetComponents()}
    local success, err = safeWriteFile(PositionFilePath, Services.HttpService:JSONEncode(data))
    if success then
        chloex("Position saved successfully!")
    else
        chloex("Failed to save position: " .. tostring(err))
    end
end

function LoadPosition()
    local success, content = safeReadFile(PositionFilePath)
    if success then
        local data = Services.HttpService:JSONDecode(content)
        return CFrame.new(unpack(data))
    end
    return nil
end
local MerchantUI = {
    MerchantRoot = Services.PlayerGui:WaitForChild("Merchant"):WaitForChild("Main"):WaitForChild("Background"),
    ItemsFrame = Services.PlayerGui:WaitForChild("Merchant"):WaitForChild("Main"):WaitForChild("Background"):WaitForChild("Items"):WaitForChild("ScrollingFrame"),
    RefreshMerchant = Services.PlayerGui:WaitForChild("Merchant"):WaitForChild("Main"):WaitForChild("Background"):WaitForChild("RefreshLabel"),
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
    REFishDone = GameModules.Net["RE/CatchFishCompleted"],
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

local Settings = {
    autoInstant = false,
    selectedEvents = {},
    autoWeather = false,
    autoSellEnabled = false,
    autoFavEnabled = false,
    autoEventActive = false,
    canFish = true,
    savedCFrame = nil,
    sellMode = "Delay",
    sellDelay = 60,
    inputSellCount = 50,
    selectedName = {},
    selectedRarity = {},
    selectedVariant = {},
    rodDataList = {},
    rodDisplayNames = {},
    baitDataList = {},
    baitDisplayNames = {},
    selectedRodId = nil,
    selectedBaitId = nil,
    rods = {},
    baits = {},
    weathers = {},
    lcc = 0,
    player = LocalPlayer,
    stats = LocalPlayer:WaitForChild("leaderstats"),
    caught = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Caught"),
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(),
    vim = Services.VirtualInputManager,
    cam = Services.Camera,
    offs = {
        ["Worm Hunt"] = 25,
    },
    curCF = nil,
    origCF = nil,
    flt = false,
    con = nil,
    Instant = false,
    CancelWaitTime = 3,
    ResetTimer = 0.5,
    hasTriggeredBug = false,
    lastFishTime = 0,
    fishConnected = false,
    lastCancelTime = 0,
    hasFishingEffect = false,
}

local TradeSettings = {
    selectedPlayer = nil,
    selectedItem = nil,
    tradeAmount = 1,
    targetCoins = 0,
    trading = false,
    awaiting = false,
    lastResult = nil,
    successCount = 0,
    failCount = 0,
    totalToTrade = 0,
    sentCoins = 0,
    successCoins = 0,
    failCoins = 0,
    totalReceived = 0,
}

TradeSettings.currentGrouped = {}
TradeSettings.TotemActive = false
Settings.trade = TradeSettings

Settings.ignore = {
    Cloudy = true,
    Day = true,
    ["Increased Luck"] = true,
    Mutated = true,
    Night = true,
    Snow = true,
    ["Sparkling Cove"] = true,
    Storm = true,
    Wind = true,
    UIListLayout = true,
    ["Admin - Shocked"] = true,
    ["Admin - Super Mutated"] = true,
    Radiant = true,
}

Settings.notifConnections = {}
Settings.defaultHandlers = {}
Settings.disabledCons = {}
Settings.CEvent = true

_G.Celestial = _G.Celestial or {}
_G.Celestial.DetectorCount = _G.Celestial.DetectorCount or 0
_G.Celestial.InstantCount = _G.Celestial.InstantCount or 0

function getFishCount()
    local success, bagText = pcall(function()
        return Settings.player.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("Top"):WaitForChild("Options"):WaitForChild("Fish"):WaitForChild("Label"):WaitForChild("BagSize").Text or "0/???"
    end)
    
    if success and bagText then
        local currentCount = bagText:match("(%d+)/")
        return tonumber(currentCount) or 0
    end
    return 0
end

function clickCenter()
    local viewportSize = Settings.cam.ViewportSize
    Settings.vim:SendMouseButtonEvent(viewportSize.X / 2, viewportSize.Y / 2, 0, true, nil, 0)
    Settings.vim:SendMouseButtonEvent(viewportSize.X / 2, viewportSize.Y / 2, 0, false, nil, 0)
end

function toSet(inputTable)
    local result = {}
    if type(inputTable) == "table" then
        for _, value in ipairs(inputTable) do
            result[value] = true
        end
        for key, value in pairs(inputTable) do
            if value then
                result[key] = true
            end
        end
    end
    return result
end

function _cleanName(nameString)
    if type(nameString) ~= "string" then
        return tostring(nameString)
    end
    return nameString:match("^(.-) %(") or nameString
end

local FishNames = {}
for _, item in ipairs(DataStorage.Items:GetChildren()) do
    if item:IsA("ModuleScript") then
        local success, moduleData = pcall(require, item)
        if success and moduleData.Data and moduleData.Data.Type == "Fish" then
            table.insert(FishNames, moduleData.Data.Name)
        end
    end
end

table.sort(FishNames)

_G.TierFish = {
    [1] = " ",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret",
}

_G.WebhookRarities = _G.WebhookRarities or {}
_G.WebhookNames = _G.WebhookNames or {}

_G.Variant = {
    "Galaxy",
    "Corrupt",
    "Gemstone",
    "Ghost",
    "Lightning",
    "Fairy Dust",
    "Gold",
    "Midnight",
    "Radioactive",
    "Stone",
    "Holographic",
    "Albino",
    "Bloodmoon",
    "Sandy",
    "Acidic",
    "Color Burn",
    "Festive",
    "Frozen"
}

function toSet(inputTable)
    local result = {}
    if type(inputTable) == "table" then
        for _, value in ipairs(inputTable) do
            result[value] = true
        end
        for key, value in pairs(inputTable) do
            if value then
                result[key] = true
            end
        end
    end
    return result
end

local FavoriteCache = {}
Network.Events.REFavChg.OnClientEvent:Connect(function(itemId, isFavorited)
    FavoriteCache[itemId] = isFavorited
end)

function checkAndFavorite(item)
    if not Settings.autoFavEnabled then
        return
    end
    
    local itemData = GameModules.ItemUtility.GetItemDataFromItemType("Items", item.Id)
    if not itemData or itemData.Data.Type ~= "Fish" then
        return
    end
    
    local rarity = _G.TierFish[itemData.Data.Tier]
    local fishName = itemData.Data.Name
    local variant = item.Metadata and item.Metadata.VariantId or "None"
    
    local nameSelected = Settings.selectedName[fishName]
    local raritySelected = Settings.selectedRarity[rarity]
    local variantSelected = Settings.selectedVariant[variant]
    
    local isCurrentlyFavorited = FavoriteCache[item.UUID]
    if isCurrentlyFavorited == nil then
        isCurrentlyFavorited = item.Favorited
    end
    
    local shouldFavorite = false
    
    if next(Settings.selectedVariant) ~= nil and next(Settings.selectedName) ~= nil then
        shouldFavorite = nameSelected and variantSelected
    else
        shouldFavorite = nameSelected or raritySelected
    end
    
    if shouldFavorite and not isCurrentlyFavorited then
        Network.Events.REFav:FireServer(item.UUID)
        FavoriteCache[item.UUID] = true
    end
end

function scanInventory()
    if not Settings.autoFavEnabled then
        return
    end
    
    for _, item in ipairs(DataStorage.Data:GetExpect({"Inventory", "Items"})) do
        checkAndFavorite(item)
    end
end

-- Load rods data
for _, rodScript in ipairs(Services.ReplicatedStorage.Items:GetChildren()) do
    if rodScript:IsA("ModuleScript") and rodScript.Name:match("Rod") then
        local success, rodData = pcall(require, rodScript)
        if success and typeof(rodData) == "table" and rodData.Data then
            local rodName = rodData.Data.Name or "Unknown"
            local rodId = rodData.Data.Id or "Unknown"
            local rodPrice = rodData.Price or 0
            local cleanName = rodName:gsub("^!!!%s*", "")
            local displayName = cleanName .. " ($" .. rodPrice .. ")"
            
            local rodInfo = {
                Name = cleanName,
                Id = rodId,
                Price = rodPrice,
                Display = displayName,
            }
            
            Settings.rods[rodId] = rodInfo
            Settings.rods[cleanName] = rodInfo
            table.insert(Settings.rodDisplayNames, displayName)
        end
    end
end

-- Load baits data
local BaitsFolder = Services.ReplicatedStorage:WaitForChild("Baits")
for _, baitScript in ipairs(BaitsFolder:GetChildren()) do
    if baitScript:IsA("ModuleScript") then
        local success, baitData = pcall(require, baitScript)
        if success and typeof(baitData) == "table" and baitData.Data then
            local baitName = baitData.Data.Name or "Unknown"
            local baitId = baitData.Data.Id or "Unknown"
            local baitPrice = baitData.Price or 0
            local displayName = baitName .. " ($" .. baitPrice .. ")"
            
            local baitInfo = {
                Name = baitName,
                Id = baitId,
                Price = baitPrice,
                Display = displayName,
            }
            
            Settings.baits[baitId] = baitInfo
            Settings.baits[baitName] = baitInfo
            table.insert(Settings.baitDisplayNames, displayName)
        end
    end
end

function _cleanName(nameString)
    if type(nameString) ~= "string" then
        return tostring(nameString)
    end
    return nameString:match("^(.-) %(") or nameString
end

function SavePosition(cframe)
    writefile(PositionFilePath, Services.HttpService:JSONEncode({cframe:GetComponents()}))
end

function LoadPosition()
    if isfile(PositionFilePath) then
        local success, data = pcall(function()
            return Services.HttpService:JSONDecode(readfile(PositionFilePath))
        end)
        if success and typeof(data) == "table" then
            return CFrame.new(unpack(data))
        end
    end
    return nil
end

function TeleportLastPos(character)
    task.spawn(function()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local savedPosition = LoadPosition()
        if savedPosition then
            task.wait(2)
            humanoidRootPart.CFrame = savedPosition
            chloex("Teleported to your last position...")
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(TeleportLastPos)
if LocalPlayer.Character then
    TeleportLastPos(LocalPlayer.Character)
end

local function findPlayerPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
end

local function setupWalkOnWater(character, part, enabled)
    if Settings.flt and Settings.con then
        Settings.con:Disconnect()
    end
    
    Settings.flt = enabled or false
    
    if enabled then
        local waterPart = workspace:FindFirstChild("WW_Part") or Instance.new("Part")
        waterPart.Name = "WW_Part"
        waterPart.Size = Vector3.new(15, 1, 15)
        waterPart.Anchored = true
        waterPart.CanCollide = false
        waterPart.Transparency = 1
        waterPart.Material = Enum.Material.SmoothPlastic
        waterPart.Parent = workspace
        
        local waterHeight = -1.8
        
        Settings.con = Services.RunService.Heartbeat:Connect(function()
            if not character or not part or not waterPart then
                return
            end
            waterPart.Position = Vector3.new(part.Position.X, waterHeight, part.Position.Z)
            waterPart.CanCollide = waterHeight < part.Position.Y
        end)
    else
        local waterPart = workspace:FindFirstChild("WW_Part")
        if waterPart then
            waterPart:Destroy()
        end
    end
end

function getAvailableEvents()
    local events = {}
    local eventsGui = Settings.player.PlayerGui:WaitForChild("Events")
    local eventsFrame = eventsGui and eventsGui:FindFirstChild("Frame")
    local eventsContainer = eventsFrame and eventsFrame:FindFirstChild("Events")
    
    if eventsContainer then
        for _, eventFrame in ipairs(eventsContainer:GetChildren()) do
            if eventFrame:IsA("Frame") then
                local displayName = eventFrame:FindFirstChild("DisplayName") and (eventFrame.DisplayName.Text or eventFrame.Name)
                if typeof(displayName) == "string" and displayName ~= "" and not Settings.ignore[displayName] then
                    table.insert(events, displayName:gsub("^Admin %- ", ""))
                end
            end
        end
    end
    
    return events
end

local function findEventObject(eventName)
    if not eventName then
        return
    end
    
    if eventName == "Megalodon Hunt" then
        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRings then
            for _, ring in ipairs(menuRings:GetChildren()) do
                local megalodonEvent = ring:FindFirstChild("Megalodon Hunt")
                local megalodonPart = megalodonEvent and megalodonEvent:FindFirstChild("Megalodon Hunt")
                if megalodonPart and megalodonPart:IsA("BasePart") then
                    return megalodonPart
                end
            end
        end
        return
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
        for _, model in ipairs(folder:GetChildren()) do
            for _, descendant in ipairs(model:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Name == "DisplayName" then
                    local displayText = descendant.ContentText
                    if displayText == "" then
                        displayText = descendant.ContentText or descendant.Text
                    end
                    
                    if displayText and displayText:lower() == eventName:lower() then
                        local parentModel = descendant:FindFirstAncestorOfClass("Model")
                        local eventPart = parentModel and (parentModel:FindFirstChild("Part") or model:FindFirstChild("Part"))
                        if eventPart and eventPart:IsA("BasePart") then
                            return eventPart
                        end
                    end
                end
            end
        end
    end
end

local function updateStatus(status)
    if Settings.lastState ~= status then
        chloex(status)
        Settings.lastState = status
    end
end

function Settings.loop()
    while Settings.autoEventActive do
        local eventPart = nil
        local eventName = nil
        
        -- Check priority event first
        if Settings.priorityEvent then
            local priorityPart = findEventObject(Settings.priorityEvent)
            if priorityPart then
                eventName = Settings.priorityEvent
                eventPart = priorityPart
            end
        end
        
        -- Check selected events
        if not eventPart and #Settings.selectedEvents > 0 then
            for _, selectedEvent in ipairs(Settings.selectedEvents) do
                local foundPart = findEventObject(selectedEvent)
                if foundPart then
                    eventName = selectedEvent
                    eventPart = foundPart
                    break
                end
            end
        end
        
        local playerPart = findPlayerPart(Settings.player.Character)
        
        if eventPart and playerPart then
            if not Settings.origCF then
                Settings.origCF = playerPart.CFrame
            end
            
            if (playerPart.Position - eventPart.Position).Magnitude > 40 then
                Settings.curCF = eventPart.CFrame + Vector3.new(0, (Settings.offs[eventName] or 7), 0)
                Settings.player.Character:PivotTo(Settings.curCF)
                setupWalkOnWater(Settings.player.Character, playerPart, true)
                task.wait(1)
                updateStatus("Event! " .. eventName)
            end
        elseif not eventPart and Settings.curCF and playerPart then
            setupWalkOnWater(Settings.player.Character, nil, false)
            
            if Settings.origCF then
                Settings.player.Character:PivotTo(Settings.origCF)
                updateStatus("Event end → Back")
                Settings.origCF = nil
            end
            
            Settings.curCF = nil
        elseif not Settings.curCF then
            updateStatus("Idle")
        end
        
        task.wait(0.2)
    end
    
    setupWalkOnWater(Settings.player.Character, nil, false)
    
    if Settings.origCF and Settings.player.Character then
        Settings.player.Character:PivotTo(Settings.origCF)
        updateStatus("Auto Event off")
    end
    
    Settings.curCF = nil
    Settings.origCF = nil
end

Settings.player.CharacterAdded:Connect(function(character)
    if Settings.autoEventActive then
        task.spawn(function()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.3)
            
            if humanoidRootPart then
                if Settings.curCF then
                    character:PivotTo(Settings.curCF)
                    setupWalkOnWater(character, humanoidRootPart, true)
                    task.wait(0.5)
                    chloex("Respawn → Back")
                elseif Settings.origCF then
                    character:PivotTo(Settings.origCF)
                    setupWalkOnWater(character, humanoidRootPart, true)
                    chloex("Back to farm")
                end
            end
        end)
    end
end)

local function getOtherPlayers()
    local players = {}
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    return players
end

local TeleportLocations = {
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
    ["Stingray Shores"] = Vector3.new(44.41, 28.83, 3048.93),
    ["Tropical Grove"] = Vector3.new(-2018.91, 9.04, 3750.59),
    ["Ice Sea"] = Vector3.new(2164, 7, 3269),
    ["Tropical Grove Cave 1"] = Vector3.new(-2151, 3, 3671),
    ["Tropical Grove Cave 2"] = Vector3.new(-2018, 5, 3756),
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
    ["Classic Event"] = Vector3.new(1173, 4, 2839),
    ["Classic Event River"] = Vector3.new(1439, 46, 2779),
    ["Iron Cavern Right"] = Vector3.new(-8792, -585, 223),
    ["Iron Cavern Left"] = Vector3.new(-8795, -585, 89),
    ["Iron Cafe"] = Vector3.new(-8642, -548, 162),
}

local locationNames = {}
for locationName in pairs(TeleportLocations) do
    table.insert(locationNames, locationName)
end

table.sort(locationNames, function(a, b)
    return a:lower() < b:lower()
end)

function disableNotifications()
    local notificationEvents = {
        GameModules.Net["RE/ObtainedNewFishNotification"],
        GameModules.Net["RE/TextNotification"],
        GameModules.Net["RE/ClaimNotification"]
    }
    
    for _, event in ipairs(notificationEvents) do
        for _, connection in ipairs(getconnections(event.OnClientEvent)) do
            connection:Disconnect()
            table.insert(Settings.notifConnections, connection)
        end
    end
end

local function restoreNotifications()
    Settings.notifConnections = {}
end

-- Load external library
local LibraryUrl = "https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"
local Library = loadstring(game:HttpGet(LibraryUrl))()

-- Create main window
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

-- Create tabs
local Tabs = {}
Tabs.Info = MainWindow:AddTab({Name = "Info", Icon = "player"})
Tabs.Main = MainWindow:AddTab({Name = "Fishing", Icon = "rbxassetid://97167558235554"})
Tabs.Auto = MainWindow:AddTab({Name = "Automatically", Icon = "next"})
Tabs.Trade = MainWindow:AddTab({Name = "Trading", Icon = "rbxassetid://114581487428395"})
Tabs.Farm = MainWindow:AddTab({Name = "Menu", Icon = "rbxassetid://140165584241571"})
Tabs.Quest = MainWindow:AddTab({Name = "Quest", Icon = "scroll"})
Tabs.Tele = MainWindow:AddTab({Name = "Teleport", Icon = "rbxassetid://18648122722"})
Tabs.Webhook = MainWindow:AddTab({Name = "Webhook", Icon = "rbxassetid://137601480983962"})
Tabs.Misc = MainWindow:AddTab({Name = "Misc", Icon = "rbxassetid://6034509993"})

-- Load external script
-- Diperlukan:
local function chloex(message)
    print("[Chloe X] " .. tostring(message))
    if Library and Library.Notify then
        Library:Notify(message)
    end
end

local function loadExternalScript(url)
    local success, result = pcall(function()
        local response = game:HttpGet(url, true)
        if response then
            local func, errorMsg = loadstring(response)
            if func then
                return func()
            else
                error("Failed to compile: " .. tostring(errorMsg))
            end
        end
        return nil
    end)
    
    if not success then
        warn("[Chloe X] Failed to load external script: " .. tostring(result))
    end
    
    return success, result
end

-- Fishing Support Section
local Fish1 = Tabs.Main:AddSection("Fishing Support")

Fish1:AddToggle({
    Title = "Show Fishing Panel",
    Default = false,
    Callback = function(enabled)
        if enabled then
            local player = game:GetService("Players").LocalPlayer
            
            if game.CoreGui:FindFirstChild("ChloeX_FishingPanel") then
                game.CoreGui:FindFirstChild("ChloeX_FishingPanel"):Destroy()
            end
            
            local fishingPanelGui = Instance.new("ScreenGui")
            fishingPanelGui.Name = "ChloeX_FishingPanel"
            fishingPanelGui.IgnoreGuiInset = true
            fishingPanelGui.ResetOnSpawn = false
            fishingPanelGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            fishingPanelGui.Parent = game.CoreGui
            
            local mainFrame = Instance.new("Frame", fishingPanelGui)
            mainFrame.Size = UDim2.new(0, 400, 0, 210)
            mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
            mainFrame.BorderSizePixel = 0
            mainFrame.BackgroundTransparency = 0.05
            mainFrame.Active = true
            mainFrame.Draggable = true
            
            local frameStroke = Instance.new("UIStroke", mainFrame)
            frameStroke.Thickness = 2
            frameStroke.Color = Color3.fromRGB(80, 150, 255)
            frameStroke.Transparency = 0.35
            
            Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
            
            local iconLabel = Instance.new("ImageLabel", mainFrame)
            iconLabel.Size = UDim2.new(0, 28, 0, 28)
            iconLabel.Position = UDim2.new(0, 10, 0, 6)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Image = "rbxassetid://100076212630732"
            iconLabel.ScaleType = Enum.ScaleType.Fit
            
            local titleLabel = Instance.new("TextLabel", mainFrame)
            titleLabel.Size = UDim2.new(1, -40, 0, 36)
            titleLabel.Position = UDim2.new(0, 45, 0, 5)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = "CHLOEX PANEL FISHING"
            titleLabel.TextSize = 22
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local titleGradient = Instance.new("UIGradient", titleLabel)
            titleGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 220, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 120, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 220, 255))
            })
            titleGradient.Rotation = 45
            
            local inventoryLabel = Instance.new("TextLabel", mainFrame)
            inventoryLabel.Position = UDim2.new(0, 15, 0, 55)
            inventoryLabel.Size = UDim2.new(1, -30, 0, 22)
            inventoryLabel.Font = Enum.Font.GothamBold
            inventoryLabel.TextSize = 18
            inventoryLabel.BackgroundTransparency = 1
            inventoryLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
            inventoryLabel.Text = "INVENTORY COUNT:"
            
            local fishCountLabel = Instance.new("TextLabel", mainFrame)
            fishCountLabel.Position = UDim2.new(0, 15, 0, 75)
            fishCountLabel.Size = UDim2.new(1, -30, 0, 22)
            fishCountLabel.Font = Enum.Font.Gotham
            fishCountLabel.TextSize = 18
            fishCountLabel.BackgroundTransparency = 1
            fishCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            fishCountLabel.Text = "Fish: 0/0"
            
            local totalCaughtLabel = Instance.new("TextLabel", mainFrame)
            totalCaughtLabel.Position = UDim2.new(0, 15, 0, 105)
            totalCaughtLabel.Size = UDim2.new(1, -30, 0, 22)
            totalCaughtLabel.Font = Enum.Font.GothamBold
            totalCaughtLabel.TextSize = 18
            totalCaughtLabel.BackgroundTransparency = 1
            totalCaughtLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
            totalCaughtLabel.Text = "TOTAL FISH CAUGHT:"
            
            local caughtValueLabel = Instance.new("TextLabel", mainFrame)
            caughtValueLabel.Position = UDim2.new(0, 15, 0, 125)
            caughtValueLabel.Size = UDim2.new(1, -30, 0, 22)
            caughtValueLabel.Font = Enum.Font.Gotham
            caughtValueLabel.TextSize = 18
            caughtValueLabel.BackgroundTransparency = 1
            caughtValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            caughtValueLabel.Text = "Value: 0"
            
            local statusLabel = Instance.new("TextLabel", mainFrame)
            statusLabel.Position = UDim2.new(0.5, 0, 0, 165)
            statusLabel.AnchorPoint = Vector2.new(0.5, 0)
            statusLabel.Size = UDim2.new(0.8, 0, 0, 30)
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextSize = 22
            statusLabel.Text = "FISHING NORMAL"
            statusLabel.BackgroundTransparency = 1
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            
            local lastFishCount = player.leaderstats.Caught.Value
            local lastUpdateTime = tick()
            local isStuck = false
            
            Settings.fishingPanelRunning = true
            
            task.spawn(function()
                while Settings.fishingPanelRunning do
                    task.wait(1)
                    
                    local bagText = ""
                    pcall(function()
                        bagText = player.PlayerGui.Inventory.Main.Top.Options.Fish.Label.BagSize.Text
                    end)
                    
                    local currentCaught = player.leaderstats.Caught.Value
                    fishCountLabel.Text = "Fish: " .. (bagText or "0/0")
                    caughtValueLabel.Text = "Value: " .. tostring(currentCaught)
                    
                    if lastFishCount < currentCaught then
                        lastFishCount = currentCaught
                        lastUpdateTime = tick()
                        if isStuck then
                            isStuck = false
                            statusLabel.Text = "FISHING NORMAL"
                            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                        end
                    end
                    
                    if not isStuck and tick() - lastUpdateTime >= 10 then
                        isStuck = true
                        statusLabel.Text = "FISHING STUCK"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
                    end
                end
            end)
        else
            Settings.fishingPanelRunning = false
            local existingPanel = game.CoreGui:FindFirstChild("ChloeX_FishingPanel")
            if existingPanel then
                existingPanel:Destroy()
            end
        end
    end,
})

Fish1:AddToggle({
    Title = "Auto Equip Rod",
    Content = "Automatically equip your fishing rod",
    Default = false,
    Callback = function(enabled)
        Settings.autoEquipRod = enabled
        
        local function isRodEquipped()
            local equippedId = DataStorage.Data:Get("EquippedId")
            if not equippedId then
                return false
            end
            
            local equippedItem = GameModules.PlayerStatsUtility:GetItemFromInventory(DataStorage.Data, function(item)
                return item.UUID == equippedId
            end)
            
            if not equippedItem then
                return false
            end
            
            local itemData = GameModules.ItemUtility:GetItemData(equippedItem.Id)
            return itemData and itemData.Data.Type == "Fishing Rods"
        end
        
        local function equipRod()
            if not isRodEquipped() then
                Network.Events.REEquip:FireServer(1)
            end
        end
        
        task.spawn(function()
            while Settings.autoEquipRod do
                equipRod()
                task.wait(1)
            end
        end)
    end,
})

Fish1:AddToggle({
    Title = "No Fishing Animations",
    Default = false,
    Callback = function(enabled)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local animator = character:WaitForChild("Humanoid"):FindFirstChildOfClass("Animator")
        
        if not animator then
            return
        end
        
        if enabled then
            Settings.stopAnimHookEnabled = true
            
            for _, animationTrack in ipairs(animator:GetPlayingAnimationTracks()) do
                animationTrack:Stop(0)
            end
            
            Settings.stopAnimConn = animator.AnimationPlayed:Connect(function(animationTrack)
                if Settings.stopAnimHookEnabled then
                    task.defer(function()
                        pcall(function()
                            animationTrack:Stop(0)
                        end)
                    end)
                end
            end)
        else
            Settings.stopAnimHookEnabled = false
            if Settings.stopAnimConn then
                Settings.stopAnimConn:Disconnect()
                Settings.stopAnimConn = nil
            end
        end
    end,
})

local walkOnWaterEnabled = false
local waterPart = nil
local waterConnection = nil
local waterHeight = -1.8

Fish1:AddToggle({
    Title = "Walk on Water",
    Default = false,
    Callback = function(enabled)
        walkOnWaterEnabled = enabled
        local humanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        
        if enabled then
            waterPart = Instance.new("Part")
            waterPart.Name = "WW_Part"
            waterPart.Size = Vector3.new(15, 1, 15)
            waterPart.Anchored = true
            waterPart.CanCollide = false
            waterPart.Transparency = 1
            waterPart.Material = Enum.Material.SmoothPlastic
            waterPart.Parent = workspace
            
            waterConnection = Services.RunService.Heartbeat:Connect(function()
                if not walkOnWaterEnabled or not waterPart or not humanoidRootPart then
                    return
                end
                waterPart.Position = Vector3.new(humanoidRootPart.Position.X, waterHeight, humanoidRootPart.Position.Z)
                waterPart.CanCollide = waterHeight < humanoidRootPart.Position.Y
            end)
        else
            if waterConnection then
                waterConnection:Disconnect()
                waterConnection = nil
            end
            if waterPart then
                waterPart:Destroy()
                waterPart = nil
            end
        end
    end,
})

Fish1:AddToggle({
    Title = "Freeze Player",
    Content = "Freeze only if rod is equipped",
    Default = false,
    Callback = function(enabled)
        Settings.frozen = enabled
        
        local function isRodEquipped()
            local equippedId = DataStorage.Data:Get("EquippedId")
            if not equippedId then
                return false
            end
            
            local equippedItem = GameModules.PlayerStatsUtility:GetItemFromInventory(DataStorage.Data, function(item)
                return item.UUID == equippedId
            end)
            
            if not equippedItem then
                return false
            end
            
            local itemData = GameModules.ItemUtility:GetItemData(equippedItem.Id)
            return itemData and itemData.Data.Type == "Fishing Rods"
        end
        
        local function equipRodIfNeeded()
            if not isRodEquipped() then
                Network.Events.REEquip:FireServer(1)
                task.wait(0.5)
            end
        end
        
        local function setAnchored(character, anchored)
            if not character then
                return
            end
            
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = anchored
                end
            end
        end
        
        local function updateFreezeState(character)
            if Settings.frozen then
                equipRodIfNeeded()
                if isRodEquipped() then
                    setAnchored(character, true)
                end
            else
                setAnchored(character, false)
            end
        end
        
        updateFreezeState(Settings.player.Character)
        Settings.player.CharacterAdded:Connect(function(character)
            task.wait(1)
            updateFreezeState(character)
        end)
    end,
})

-- Fishing Features Section
local FishingSection = Tabs.Main:AddSection("Fishing Features")
local Fish = FishingSection

local DetectorParagraph = Fish:AddParagraph({
    Title = "Detector Stuck",
    Content = "Status = Idle\nTime = 0.0s\nBag = 0"
})

Fish:AddSlider({
    Title = "Wait (s)",
    Default = 15,
    Min = 10,
    Max = 25,
    Rounding = 0,
    Callback = function(value)
        Settings.stuckThreshold = value
    end,
})

Fish:AddToggle({
    Title = "Start Detector",
    Default = false,
    Callback = function(enabled)
        Settings.supportEnabled = enabled
        
        if enabled then
            Settings.char = Settings.player.Character or Settings.player.CharacterAdded:Wait()
            Settings.savedCFrame = Settings.char:WaitForChild("HumanoidRootPart").CFrame
            _G.Celestial.DetectorCount = getFishCount()
            Settings.fishingTimer = 0
            
            task.spawn(function()
                local lastCheckTime = tick()
                
                while Settings.supportEnabled do
                    task.wait(0.2)
                    
                    local success, fishCount = pcall(getFishCount)
                    if not success or not fishCount then
                        DetectorParagraph:SetContent("<font color='rgb(255,69,0)'>Status = Error Reading Count</font>\nTime = 0.0s\nBag = 0")
                        Settings.fishingTimer = 0
                    else
                        local currentTime = tick()
                        lastCheckTime = currentTime
                        Settings.fishingTimer = Settings.fishingTimer + currentTime - lastCheckTime
                        
                        if not Settings.char or not Settings.char.Parent then
                            Settings.char = Settings.player.Character or Settings.player.CharacterAdded:Wait()
                        end
                        
                        if fishCount ~= _G.Celestial.DetectorCount then
                            _G.Celestial.DetectorCount = fishCount
                            Settings.fishingTimer = 0
                        end
                        
                        if (Settings.stuckThreshold or 10) <= Settings.fishingTimer then
                            DetectorParagraph:SetContent("<font color='rgb(255,69,0)'>Status = Reset!</font>\nTime = 0.0s\nBag = " .. fishCount)
                            
                            local humanoidRootPart = Settings.char:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                Settings.savedCFrame = humanoidRootPart.CFrame
                            end
                            
                            Settings.player.Character:BreakJoints()
                            Settings.char = Settings.player.CharacterAdded:Wait()
                            task.wait(0.3)
                            Settings.char:WaitForChild("HumanoidRootPart").CFrame = Settings.savedCFrame
                            _G.Celestial.DetectorCount = getFishCount()
                            Settings.fishingTimer = 0
                        else
                            DetectorParagraph:SetContent(string.format("<font color='rgb(0,255,127)'>Status = Running</font>\nTime = %.1fs\nBag = %d", Settings.fishingTimer, fishCount))
                        end
                    end
                end
                
                DetectorParagraph:SetContent("<font color='rgb(200,200,200)'>Status = Detector Offline</font>\nTime = 0.0s\nBag = 0")
            end)
        else
            DetectorParagraph:SetContent("<font color='rgb(200,200,200)'>Status = Detector Offline</font>\nTime = 0.0s\nBag = 0")
        end
    end,
})

Fish:AddInput({
    Title = "Legit Delay",
    Content = "Delay complete fishing!",
    Value = tostring(_G.Delay),
    Callback = function(input)
        local delayValue = tonumber(input)
        if delayValue and delayValue > 0 then
            _G.Delay = delayValue
            SaveConfig()
            
            task.spawn(function()
                print("Started")
                while true do
                    if GameModules.FishingController then
                        local fishingController = GameModules.FishingController
                        if fishingController._autoLoop then
                            if fishingController:GetCurrentGUID() then
                                print("Waiting", _G.Delay)
                                task.wait(_G.Delay)
                                
                                while true do
                                    local success, errorMsg = pcall(function()
                                        Network.Events.REFishDone:FireServer()
                                    end)
                                    
                                    if success then
                                        print("Successfully")
                                    else
                                        warn("Failed to Fire", errorMsg)
                                    end
                                    
                                    task.wait(0.05)
                                    
                                    if fishingController:GetCurrentGUID() and fishingController._autoLoop then
                                        goto label_50
                                    else
                                        break
                                    end
                                end
                                
                                print("loop ended")
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        else
            warn("Invalid fishing delay input")
        end
    end,
})

local shakeDelay = 0
Fish:AddInput({
    Title = "Shake Delay",
    Value = tostring(shakeDelay),
    Callback = function(input)
        local delayValue = tonumber(input)
        if delayValue and delayValue >= 0 then
            shakeDelay = delayValue
        end
    end,
})

local mouseReleaseCallback = nil
local oldRegister = GameModules.InputControl.RegisterMouseReleased

GameModules.InputControl.RegisterMouseReleased = function(inputObject, inputState, callback)
    mouseReleaseCallback = callback
    return oldRegister(inputObject, inputState, callback)
end

local function castWithBarRelease()
    local playerGui = Services.PlayerGui
    local camera = Services.Camera
    local centerPosition = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    pcall(function()
        Network.Functions.Cancel:InvokeServer()
    end)
    
    pcall(function()
        GameModules.FishingController:RequestChargeFishingRod(centerPosition, false)
    end)
    
    local chargeBar = playerGui:WaitForChild("Charge"):WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")
    
    repeat
        task.wait()
    until chargeBar.Size.Y.Scale > 0
    
    local startTime = tick()
    while chargeBar:IsDescendantOf(playerGui) do
        local barScale = chargeBar.Size.Y.Scale
        if barScale < 0.93 then
            task.wait()
            local elapsedTime = tick() - startTime
            if elapsedTime > 2 then
                break
            end
        else
            break
        end
    end
    
    if mouseReleaseCallback then
        pcall(mouseReleaseCallback)
    end
end

local userId = tostring(LocalPlayer.UserId)
local CosmeticFolder = workspace:WaitForChild("CosmeticFolder")

Fish:AddToggle({
    Title = "Legit Fishing",
    Default = false,
    Callback = function(enabled)
        GameModules.FishingController._autoLoop = enabled
        
        if enabled then
            task.spawn(function()
                while GameModules.FishingController._autoLoop do
                    local cosmeticItem = CosmeticFolder:FindFirstChild(userId)
                    if not cosmeticItem then
                        castWithBarRelease()
                        task.wait(0.2)
                    end
                    
                    while CosmeticFolder:FindFirstChild(userId) and GameModules.FishingController._autoLoop do
                        task.wait(0.2)
                    end
                    
                    task.wait(0.2)
                end
            end)
        end
    end,
})

Fish:AddToggle({
    Title = "Auto Shake",
    Content = "Spam click during fishing (only legit)",
    Default = false,
    Callback = function(enabled)
        GameModules._autoShake = enabled
        local clickEffect = Services.PlayerGui:FindFirstChild("!!! Click Effect")
        
        if enabled then
            if clickEffect then
                clickEffect.Enabled = false
            end
            
            task.spawn(function()
                while GameModules._autoShake do
                    pcall(function()
                        GameModules.FishingController:RequestFishingMinigameClick()
                    end)
                    task.wait(shakeDelay)
                end
            end)
        elseif clickEffect then
            clickEffect.Enabled = true
        end
    end,
})

-- Instant Features Section
local InstantSection = Tabs.Main:AddSection("Instant Features")
local Fish0 = InstantSection

Fish0:AddInput({
    Title = "Delay Complete",
    Value = tostring(_G.DelayComplete),
    Callback = function(input)
        local delayValue = tonumber(input)
        if delayValue and delayValue >= 0 then
            _G.DelayComplete = delayValue
            SaveConfig()
        end
    end,
})

Fish0:AddToggle({
    Title = "Instant Fishing",
    Content = "Auto instantly catch fish",
    Default = false,
    Callback = function(enabled)
        Settings.autoInstant = enabled
        
        if enabled then
            _G.Celestial.InstantCount = getFishCount()
            
            task.spawn(function()
                while Settings.autoInstant do
                    if Settings.canFish then
                        Settings.canFish = false
                        
                        local success, result1, result2 = pcall(function()
                            return Network.Functions.ChargeRod:InvokeServer(workspace:GetServerTimeNow())
                        end)
                        
                        if success and typeof(result2) == "number" then
                            local minigameValue = -1
                            local completionValue = 0.999
                            
                            task.wait(0.3)
                            
                            pcall(function()
                                Network.Functions.StartMini:InvokeServer(minigameValue, completionValue, result2)
                            end)
                            
                            local startTime = tick()
                            while true do
                                task.wait()
                                if _G.FishMiniData then
                                    if _G.FishMiniData.LastShift then
                                        break
                                    end
                                end
                                
                                if tick() - startTime > 1 then
                                    break
                                end
                            end
                            
                            task.wait(_G.DelayComplete)
                            
                            pcall(function()
                                Network.Events.REFishDone:FireServer()
                            end)
                            
                            local currentCount = getFishCount()
                            local waitTime = tick()
                            
                            while true do
                                task.wait()
                                if currentCount >= getFishCount() then
                                    if tick() - waitTime > 1 then
                                        break
                                    end
                                else
                                    break
                                end
                            end
                        end
                        
                        pcall(function()
                            Network.Functions.Cancel:InvokeServer()
                        end)
                        
                        Settings.canFish = true
                    end
                    task.wait()
                end
            end)
        end
    end,
})

-- Mini Event Connection
local MiniEvent = Network.Events.FishingMinigameChanged
if MiniEvent then
    if _G._MiniEventConn then
        _G._MiniEventConn:Disconnect()
    end
    _G._MiniEventConn = MiniEvent.OnClientEvent:Connect(function(sender, data)
        if sender and data then
            _G.FishMiniData = data
        end
    end)
end


-- Blatant Features Section
local BlatantSection = Tabs.Main:AddSection("Blatant Features")
local Fish2 = BlatantSection

local function Fastest()
    task.spawn(function()
        pcall(function()
            Network.Functions.Cancel:InvokeServer()
        end)
        
        local serverTime = workspace:GetServerTimeNow()
        
        pcall(function()
            Network.Functions.ChargeRod:InvokeServer(serverTime)
        end)
        
        pcall(function()
            Network.Functions.StartMini:InvokeServer(-1, 0.999)
        end)
        
        task.wait(_G.FishingDelay)
        
        pcall(function()
            Network.Events.REFishDone:FireServer()
        end)
    end)
end

Fish2:AddInput({
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

Fish2:AddInput({
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

Fish2:AddToggle({
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

Fish2:AddButton({
    Title = "Recovery Fishing",
    Callback = function()
        task.spawn(function()
            pcall(function()
                Network.Functions.Cancel:InvokeServer()
            end)
            
            local player = game:GetService("Players").LocalPlayer
            player:SetAttribute("Loading", nil)
            task.wait(0.05)
            player:SetAttribute("Loading", false)
            chloex("Recovery Successfully!")
        end)
    end,
})

-- Selling Features Section
local SellingSection = Tabs.Main:AddSection("Selling Features")

SellingSection:AddDropdown({
    Options = {"Delay", "Count"},
    Default = "Delay",
    Title = "Select Sell Mode",
    Callback = function(mode)
        Settings.sellMode = mode
        SaveConfig()
    end,
})

SellingSection:AddInput({
    Default = "1",
    Title = "Set Value",
    Content = "Delay = Minutes | Count = Backpack Count",
    Placeholder = "Input Here",
    Callback = function(input)
        local value = tonumber(input) or 1
        
        if Settings.sellMode == "Delay" then
            Settings.sellDelay = value * 60
        else
            Settings.inputSellCount = value
        end
        
        SaveConfig()
    end,
})

SellingSection:AddToggle({
    Title = "Start Selling",
    Default = false,
    Callback = function(enabled)
        Settings.autoSellEnabled = enabled
        
        if enabled then
            task.spawn(function()
                local sellAllFunction = GameModules.Net["RF/SellAllItems"]
                
                while Settings.autoSellEnabled do
                    local inventoryGui = LocalPlayer:WaitForChild("PlayerGui")
                    local bagSizeLabel = inventoryGui:WaitForChild("Inventory").Main.Top.Options.Fish.Label:FindFirstChild("BagSize")
                    
                    local currentCount = 0
                    local maxCapacity = 0
                    
                    if bagSizeLabel and bagSizeLabel:IsA("TextLabel") then
                        local currentText, maxText = (bagSizeLabel.Text or ""):match("(%d+)%s*/%s*(%d+)")
                        currentCount = tonumber(currentText) or 0
                        maxCapacity = tonumber(maxText) or 0
                    end
                    
                    if Settings.sellMode == "Delay" then
                        task.wait(Settings.sellDelay)
                        sellAllFunction:InvokeServer()
                    elseif Settings.sellMode == "Count" then
                        local targetCount = tonumber(Settings.inputSellCount) or maxCapacity
                        if currentCount >= targetCount then
                            sellAllFunction:InvokeServer()
                        end
                        task.wait()
                    end
                end
            end)
        end
    end,
})

-- Auto Sell Enchant Stone Subsection
SellingSection:AddSubSection("Auto Sell Enchant Stone")

local EnchantStoneID = 10
local TargetLeft = 0
local AutoSellRunning = false

local EnchantStonePanel = SellingSection:AddParagraph({
    Title = "Enchant Stone Left Status",
    Content = "Counting...",
})

SellingSection:AddInput({
    Title = "Target Left",
    Default = "0",
    Callback = function(input)
        local targetNumber = tonumber(input)
        if targetNumber and targetNumber >= 0 then
            TargetLeft = targetNumber
        end
    end,
})

SellingSection:AddToggle({
    Title = "Start Sell Enchant Stone",
    Default = false,
    Callback = function(enabled)
        AutoSellRunning = enabled
        
        if not AutoSellRunning then
            return
        end
        
        task.spawn(function()
            while AutoSellRunning do
                local inventory = DataStorage.Data:GetExpect({"Inventory", "Items"})
                local count = 0
                local targetUUID = nil
                
                for _, item in ipairs(inventory) do
                    if item.Id == EnchantStoneID then
                        count = count + 1
                        if not targetUUID then
                            targetUUID = item.UUID
                        end
                    end
                end
                
                EnchantStonePanel:SetContent("Enchant Stone : " .. count)
                
                if count <= TargetLeft then
                    AutoSellRunning = false
                    break
                end
                
                if not targetUUID then
                    AutoSellRunning = false
                    break
                end
                
                task.defer(function()
                    Network.Functions.SellItem:InvokeServer(targetUUID)
                end)
                
                task.wait(0.1)
            end
        end)
    end,
})

task.spawn(function()
    while task.wait(1) do
        local inventory = DataStorage.Data:GetExpect({"Inventory", "Items"})
        local count = 0
        
        for _, item in ipairs(inventory) do
            if item.Id == EnchantStoneID then
                count = count + 1
            end
        end
        
        EnchantStonePanel:SetContent("Enchant Stone : " .. count)
    end
end)

-- Favorite Features Section
local FavoriteSection = Tabs.Main:AddSection("Favorite Features")

FavoriteSection:AddDropdown({
    Options = #FishNames > 0 and FishNames or {"No Fish Found"},
    Content = "Favorite By Name Fish (Recommended)",
    Multi = true,
    Title = "Name",
    Callback = function(selected)
        Settings.selectedName = toSet(selected)
    end,
})

FavoriteSection:AddDropdown({
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Content = "Favorite By Rarity (Optional)",
    Multi = true,
    Title = "Rarity",
    Callback = function(selected)
        Settings.selectedRarity = toSet(selected)
    end,
})

FavoriteSection:AddDropdown({
    Options = _G.Variant,
    Content = "Favorite By Variant (Only works with Name)",
    Multi = true,
    Title = "Variant",
    Callback = function(selected)
        if next(Settings.selectedName) ~= nil then
            Settings.selectedVariant = toSet(selected)
        else
            Settings.selectedVariant = {}
            warn("Pilih Name dulu sebelum memilih Variant.")
        end
    end,
})

FavoriteSection:AddToggle({
    Title = "Auto Favorite",
    Default = false,
    Callback = function(enabled)
        Settings.autoFavEnabled = enabled
        
        if enabled then
            scanInventory()
            DataStorage.Data:OnChange({"Inventory", "Items"}, scanInventory)
        end
    end,
})

FavoriteSection:AddButton({
    Title = "Unfavorite Fish",
    Callback = function()
        for _, item in ipairs(DataStorage.Data:GetExpect({"Inventory", "Items"})) do
            local isFavorited = FavoriteCache[item.UUID]
            if isFavorited == nil then
                isFavorited = item.Favorited
            end
            
            if isFavorited then
                Network.Events.REFav:FireServer(item.UUID)
                FavoriteCache[item.UUID] = false
            end
        end
    end,
})

-- Shop Features Section (Auto Tab)
local ShopSection = Tabs.Auto:AddSection("Shop Features")

local ShopParagraph = ShopSection:AddParagraph({
    Title = "MERCHANT STOCK PANEL",
    Content = "Loading...",
})

ShopSection:AddButton({
    Title = "Open/Close Merchant",
    Callback = function()
        local merchantGui = Services.PlayerGui:FindFirstChild("Merchant")
        if merchantGui then
            merchantGui.Enabled = not merchantGui.Enabled
        end
    end,
})

function UPX()
    local itemsList = {}
    
    for _, itemFrame in ipairs(MerchantUI.ItemsFrame:GetChildren()) do
        if itemFrame:IsA("ImageLabel") and itemFrame.Name ~= "Frame" then
            local innerFrame = itemFrame:FindFirstChild("Frame")
            if innerFrame and innerFrame:FindFirstChild("ItemName") then
                local itemName = innerFrame.ItemName.Text
                if not string.find(itemName, "Mystery") then
                    table.insert(itemsList, "- " .. itemName)
                end
            end
        end
    end
    
    if #itemsList == 0 then
        ShopParagraph:SetContent("No items found\n" .. MerchantUI.RefreshMerchant.Text)
    else
        ShopParagraph:SetContent(table.concat(itemsList, "\n") .. "\n\n" .. MerchantUI.RefreshMerchant.Text)
    end
end

task.spawn(function()
    while task.wait(1) do
        pcall(UPX)
    end
end)

-- Buy Rod Subsection
ShopSection:AddSubSection("Buy Rod")

ShopSection:AddDropdown({
    Title = "Select Rod",
    Options = Settings.rodDisplayNames,
    Callback = function(selected)
        if not selected then
            return
        end
        
        local rodInfo = Settings.rods[_cleanName(selected)]
        if rodInfo then
            Settings.selectedRodId = rodInfo.Id
        end
    end,
})

ShopSection:AddButton({
    Title = "Buy Selected Rod",
    Callback = function()
        if not Settings.selectedRodId then
            return
        end
        
        local rodInfo = Settings.rods[Settings.selectedRodId] or Settings.rods[_cleanName(Settings.selectedRodId)]
        if not rodInfo then
            return
        end
        
        pcall(function()
            Network.Functions.BuyRod:InvokeServer(rodInfo.Id)
        end)
    end,
})

-- Buy Baits Subsection
ShopSection:AddSubSection("Buy Baits")

ShopSection:AddDropdown({
    Title = "Select Bait",
    Options = Settings.baitDisplayNames,
    Callback = function(selected)
        if not selected then
            return
        end
        
        local baitInfo = Settings.baits[_cleanName(selected)]
        if baitInfo then
            Settings.selectedBaitId = baitInfo.Id
        end
    end,
})

ShopSection:AddButton({
    Title = "Buy Selected Bait",
    Callback = function()
        if not Settings.selectedBaitId then
            return
        end
        
        local baitInfo = Settings.baits[Settings.selectedBaitId] or Settings.baits[_cleanName(Settings.selectedBaitId)]
        if not baitInfo then
            return
        end
        
        pcall(function()
            Network.Functions.BuyBait:InvokeServer(baitInfo.Id)
        end)
    end,
})

-- Buy Weather Subsection
ShopSection:AddSubSection("Buy Weather")

local WeatherOptions = {
    "Cloudy ($10000)",
    "Wind ($10000)",
    "Snow ($15000)",
    "Storm ($35000)",
    "Radiant ($50000)",
    "Shark Hunt ($300000)"
}

local WeatherDropdown = ShopSection:AddDropdown({
    Title = "Select Weather",
    Multi = true,
    Options = WeatherOptions,
    Callback = function(selected)
        Settings.selectedEvents = {}
        
        if type(selected) == "table" then
            for _, weatherOption in ipairs(selected) do
                table.insert(Settings.selectedEvents, weatherOption:match("^(.-) %(") or weatherOption)
            end
        end
        
        SaveConfig()
    end,
})

ShopSection:AddToggle({
    Title = "Auto Buy Weather",
    Default = false,
    Callback = function(enabled)
        Settings.autoBuyWeather = enabled
        
        if not Network.Functions.BuyWeather then
            return
        end
        
        if enabled then
            task.spawn(function()
                while Settings.autoBuyWeather do
                    local selectedWeathers = WeatherDropdown.Value or WeatherDropdown.Selected or {}
                    local weatherList = {}
                    
                    if type(selectedWeathers) == "table" then
                        for _, weatherOption in ipairs(selectedWeathers) do
                            table.insert(weatherList, weatherOption:match("^(.-) %(") or weatherOption)
                        end
                    elseif type(selectedWeathers) == "string" then
                        table.insert(weatherList, selectedWeathers:match("^(.-) %(") or selectedWeathers)
                    end
                    
                    if #weatherList > 0 then
                        local activeWeathers = {}
                        local weatherFolder = workspace:FindFirstChild("Weather")
                        
                        if weatherFolder then
                            for _, weather in ipairs(weatherFolder:GetChildren()) do
                                table.insert(activeWeathers, string.lower(weather.Name))
                            end
                        end
                        
                        for _, weatherName in ipairs(weatherList) do
                            if not table.find(activeWeathers, string.lower(weatherName)) then
                                pcall(function()
                                    Network.Functions.BuyWeather:InvokeServer(weatherName)
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

-- Save Position Features Section
local SavePositionSection = Tabs.Auto:AddSection("Save position Features")

SavePositionSection:AddParagraph({
    Title = "Guide Teleport",
    Content = [[
<b><font color="rgb(0,162,255)">AUTO TELEPORT?</font></b>
Click <b><font color="rgb(0,162,255)">Save Position</font></b> to save your current position!

<b><font color="rgb(0,162,255)">HOW TO LOAD?</font></b>
This feature will auto-sync your last position when executed, so you will teleport automatically!

<b><font color="rgb(0,162,255)">HOW TO RESET?</font></b>
Click <b><font color="rgb(0,162,255)">Reset Position</font></b> to clear your saved position.
    ]],
})

SavePositionSection:AddButton({
    Title = "Save Position",
    Callback = function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart then
            SavePosition(humanoidRootPart.CFrame)
            chloex("Position saved successfully!")
        end
    end,
    SubTitle = "Reset Position",
    SubCallback = function()
        if isfile(PositionFilePath) then
            delfile(PositionFilePath)
        end
        chloex("Last position has been reset.")
    end,
})

-- Enchant Features Section
local EnchantSection = Tabs.Auto:AddSection("Enchant Features")

local function GetEnchantInfo(enchantStoneId)
    local equippedRodName = "None"
    local currentEnchant = "None"
    local stoneCount = 0
    local stoneUUIDs = {}
    
    local equippedItems = DataStorage.Data:Get("EquippedItems") or {}
    local fishingRods = DataStorage.Data:Get({"Inventory", "Fishing Rods"}) or {}
    
    for slotName, itemUUID in pairs(equippedItems) do
        for _, rodItem in ipairs(fishingRods) do
            if rodItem.UUID == itemUUID then
                local rodData = GameModules.ItemUtility:GetItemData(rodItem.Id)
                if rodData then
                    equippedRodName = rodData.Data.Name or rodItem.ItemName or "None"
                end
                
                if rodItem.Metadata and rodItem.Metadata.EnchantId then
                    local enchantData = GameModules.ItemUtility:GetEnchantData(rodItem.Metadata.EnchantId)
                    if enchantData then
                        currentEnchant = enchantData.Data.Name or "None"
                    end
                end
            end
        end
    end
    
    for _, item in pairs(DataStorage.Data:GetExpect({"Inventory", "Items"})) do
        local itemData = GameModules.ItemUtility:GetItemData(item.Id)
        if itemData and itemData.Data.Type == "Enchant Stones" and item.Id == enchantStoneId then
            stoneCount = stoneCount + 1
            table.insert(stoneUUIDs, item.UUID)
        end
    end
    
    return equippedRodName, currentEnchant, stoneCount, stoneUUIDs
end

local EnchantStatusPanel = EnchantSection:AddParagraph({
    Title = "Enchant Status",
    Content = "Current Rod : None\nCurrent Enchant : None\nEnchant Stones Left : 0",
})

EnchantSection:AddButton({
    Title = "Click Enchant",
    Callback = function()
        task.spawn(function()
            local rodName, currentEnchant, stoneCount, stoneUUIDs = GetEnchantInfo(10)
            
            if rodName == "None" or stoneCount <= 0 then
                EnchantStatusPanel:SetContent(("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>"):format(rodName, currentEnchant, stoneCount))
                return
            end
            
            local slotName = nil
            local startTime = tick()
            
            while tick() - startTime < 5 do
                for slot, uuid in pairs(DataStorage.Data:Get("EquippedItems") or {}) do
                    if uuid == stoneUUIDs[1] then
                        slotName = slot
                    end
                end
                
                if not slotName then
                    Network.Events.REEquipItem:FireServer(stoneUUIDs[1], "Enchant Stones")
                    task.wait(0.3)
                else
                    break
                end
            end
            
            if not slotName then
                return
            end
            
            Network.Events.REEquip:FireServer(slotName)
            task.wait(0.2)
            Network.Events.REAltar:FireServer()
            task.wait(1.5)
            
            local _, newEnchant = GetEnchantInfo(10)
            EnchantStatusPanel:SetContent(("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>"):format(rodName, newEnchant, stoneCount - 1))
        end)
    end,
})

EnchantSection:AddButton({
    Title = "Teleport Enchant Altar",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoidRootPart and humanoid then
            humanoidRootPart.CFrame = CFrame.new(Vector3.new(3258, -1301, 1391))
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end,
})

EnchantSection:AddDivider()

EnchantSection:AddButton({
    Title = "Click Double Enchant",
    Content = "Starting Double Enchanting",
    Callback = function()
        task.spawn(function()
            local rodName, currentEnchant, stoneCount, stoneUUIDs = GetEnchantInfo(246)
            
            if rodName == "None" or stoneCount <= 0 then
                EnchantStatusPanel:SetContent(("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>"):format(rodName, currentEnchant, stoneCount))
                return
            end
            
            local slotName = nil
            local startTime = tick()
            
            while tick() - startTime < 5 do
                for slot, uuid in pairs(DataStorage.Data:Get("EquippedItems") or {}) do
                    if uuid == stoneUUIDs[1] then
                        slotName = slot
                    end
                end
                
                if not slotName then
                    Network.Events.REEquipItem:FireServer(stoneUUIDs[1], "Enchant Stones")
                    task.wait(0.3)
                else
                    break
                end
            end
            
            if not slotName then
                return
            end
            
            Network.Events.REEquip:FireServer(slotName)
            task.wait(0.2)
            Network.Events.REAltar2:FireServer()
            task.wait(1.5)
            
            local _, newEnchant = GetEnchantInfo(246)
            EnchantStatusPanel:SetContent(("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>"):format(rodName, newEnchant, stoneCount - 1))
        end)
    end,
})

EnchantSection:AddButton({
    Title = "Teleport Second Enchant Altar",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoidRootPart and humanoid then
            humanoidRootPart.CFrame = CFrame.new(Vector3.new(1480, 128, -593))
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end,
})

-- Totem Features Section
local TotemSection = Tabs.Auto:AddSection("Totem Features")

local TotemPanel = TotemSection:AddParagraph({
    Title = "Panel Activated Totem",
    Content = "Scanning Totems...",
})

local HeaderPanel = TotemSection:AddParagraph({
    Title = "Auto Totem Status",
    Content = "Idle.",
})

function GetTT()
    local playerPosition = Settings.char and Settings.char:FindFirstChild("HumanoidRootPart") and Settings.char.HumanoidRootPart.Position or Vector3.zero
    local totemsList = {}
    
    for _, totemModel in pairs(workspace.Totems:GetChildren()) do
        if totemModel:IsA("Model") then
            local handle = totemModel:FindFirstChild("Handle")
            local overhead = handle and handle:FindFirstChild("Overhead")
            local content = overhead and overhead:FindFirstChild("Content")
            local header = content and content:FindFirstChild("Header")
            local timerLabel = content and content:FindFirstChild("TimerLabel")
            
            local distance = (playerPosition - totemModel:GetPivot().Position).Magnitude
            local timeLeft = timerLabel and timerLabel.Text or "??"
            local totemName = header and header.Text or "??"
            
            table.insert(totemsList, {
                Name = totemName,
                Distance = distance,
                TimeLeft = timeLeft,
            })
        end
    end
    
    return totemsList
end

function UpdTT()
    local totems = GetTT()
    if #totems == 0 then
        TotemPanel:SetContent("No active totems detected.")
        return
    end
    
    local displayText = {}
    for _, totem in ipairs(totems) do
        table.insert(displayText, string.format("%s • %.1f studs • %s", totem.Name, totem.Distance, totem.TimeLeft))
    end
    
    TotemPanel:SetContent(table.concat(displayText, "\n"))
end

task.spawn(function()
    while task.wait(1) do
        pcall(UpdTT)
    end
end)

function GetTTUUID(totemName)
    if not DataStorage.Data then
        DataStorage.Data = GameModules.Replion.Client:WaitReplion("Data")
        if not DataStorage.Data then
            return nil
        end
    end
    
    if not Totems then
        Totems = require(Services.ReplicatedStorage:WaitForChild("Totems"))
        if not Totems then
            return nil
        end
    end
    
    for _, totemItem in ipairs(DataStorage.Data:GetExpect({"Inventory", "Totems"}) or {}) do
        local foundTotemName = "Unknown Totem"
        if typeof(Totems) == "table" then
            for _, totemData in pairs(Totems) do
                if totemData.Data and totemData.Data.Id == totemItem.Id then
                    foundTotemName = totemData.Data.Name
                    break
                end
            end
        end
        
        if foundTotemName == totemName then
            return totemItem.UUID, foundTotemName
        end
    end
    
    return nil
end

local function showRealTotemPanel()
    -- Cari GUI totem yang asli
    local totemGui = Services.PlayerGui:FindFirstChild("Totems")
    if totemGui then
        totemGui.Enabled = true
    end
    
    local coreTotem = Services.CoreGui:FindFirstChild("Totems")
    if coreTotem then
        coreTotem.Enabled = true
    end
end


local function spawnTotem(totemUUID)
    if not totemUUID then
        return
    end
    
    local success, errorMsg = pcall(function()
        Network.Events.Totem:FireServer(totemUUID)
    end)
    
    if not success then
        warn("[Chloe X] Totem spawn failed:", tostring(errorMsg))
    end
end

TotemSection:AddButton({
    Title = "Teleport To Nearest Totem",
    Callback = function()
        local humanoidRootPart = Settings.char and Settings.char:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return
        end
        
        local totems = GetTT()
        if #totems == 0 then
            return
        end
        
        table.sort(totems, function(a, b)
            return a.Distance < b.Distance
        end)
        
        local nearestTotem = totems[1]
        
        for _, totemModel in pairs(workspace.Totems:GetChildren()) do
            if totemModel:IsA("Model") then
                local totemPosition = totemModel:GetPivot().Position
                if math.abs((totemPosition - humanoidRootPart.Position).Magnitude - nearestTotem.Distance) < 1 then
                    humanoidRootPart.CFrame = CFrame.new(totemPosition + Vector3.new(0, 3, 0))
                    break
                end
            end
        end
    end,
})

-- Load totems data
local TotemsFolder = Services.ReplicatedStorage:WaitForChild("Totems")
Settings.Totems = Settings.Totems or {}
Settings.TotemDisplayName = Settings.TotemDisplayName or {}

for _, totemScript in ipairs(TotemsFolder:GetChildren()) do
    if totemScript:IsA("ModuleScript") then
        local success, totemData = pcall(require, totemScript)
        if success and typeof(totemData) == "table" and totemData.Data then
            local totemName = totemData.Data.Name or "Unknown"
            local totemId = totemData.Data.Id or "Unknown"
            local totemInfo = {
                Name = totemName,
                Id = totemId,
            }
            
            Settings.Totems[totemId] = totemInfo
            Settings.Totems[totemName] = totemInfo
            table.insert(Settings.TotemDisplayName, totemName)
        end
    end
end

local selectedTotem = nil
local TotemDropdown = TotemSection:AddDropdown({
    Title = "Select Totem to Auto Place",
    Options = Settings.TotemDisplayName or {"No Totems Found"},
    Default = Settings.TotemDisplayName and Settings.TotemDisplayName[1] or "No Totems Found",
    Callback = function(selected)
        selectedTotem = selected
    end,
})

TotemSection:AddToggle({
    Title = "Auto Place Totem (Beta)",
    Content = "Place Totem every 60 minutes automatically.",
    Default = false,
    Callback = function(enabled)
        TradeSettings.TotemActive = enabled
        
        if enabled then
            if not selectedTotem then
                HeaderPanel:SetContent("Please select a Totem first.")
                TradeSettings.TotemActive = false
                return
            end
            
            local totemUUID, totemName = GetTTUUID(selectedTotem)
            if not totemUUID then
                HeaderPanel:SetContent("You don't own any Totem.")
                TradeSettings.TotemActive = false
                return
            end
            
            HeaderPanel:SetContent(("Auto Totem Enabled [%s] • Waiting 60m loop..."):format(selectedTotem))
            
            task.spawn(function()
                local loopCount = 0
                while true do
                    if not TradeSettings.TotemActive then
                        HeaderPanel:SetContent("Auto Totem Disabled.")
                        return
                    end
                    
                    spawnTotem(totemUUID)
                    
                    if loopCount < 3 then
                        HeaderPanel:SetContent(("Totem Used [%s] • Next in 60m"):format(selectedTotem))
                        loopCount = loopCount + 1
                    elseif loopCount == 3 then
                        loopCount = loopCount + 1
                        task.wait(1)
                        HeaderPanel:SetContent("Reverting to Real Totem Panel...")
                        task.wait(0.5)
                        showRealTotemPanel()
                    end
                    
                    for i = 3600, 1, -1 do
                        if not TradeSettings.TotemActive then
                            break
                        else
                            task.wait(1)
                        end
                    end
                    
                    local newUUID, newName = GetTTUUID(selectedTotem)
                    if not newUUID then
                        HeaderPanel:SetContent("Totem not found in inventory anymore.")
                        TradeSettings.TotemActive = false
                        break
                    end
                    
                    totemUUID = newUUID
                end
            end)
        else
            HeaderPanel:SetContent("Auto Totem Disabled.")
            showRealTotemPanel()
        end
    end,
})

-- Potions Features Section
local PotionSection = Tabs.Auto:AddSection("Potions Features")

local PotionsFolder = Services.ReplicatedStorage:WaitForChild("Potions")
Settings.Potions = Settings.Potions or {}
Settings.PotionDisplayName = Settings.PotionDisplayName or {}

for _, potionScript in ipairs(PotionsFolder:GetChildren()) do
    if potionScript:IsA("ModuleScript") then
        local success, potionData = pcall(require, potionScript)
        if success and typeof(potionData) == "table" and potionData.Data then
            local potionName = potionData.Data.Name or "Unknown"
            local potionId = potionData.Data.Id or "Unknown"
            
            if not string.find(string.lower(potionName), "totem") then
                local potionInfo = {
                    Name = potionName,
                    Id = potionId,
                }
                
                Settings.Potions[potionId] = potionInfo
                Settings.Potions[potionName] = potionInfo
                table.insert(Settings.PotionDisplayName, potionName)
            end
        end
    end
end

local selectedPotions = {}

PotionSection:AddDropdown({
    Title = "Select Potions",
    Multi = true,
    Options = Settings.PotionDisplayName,
    Callback = function(selected)
        selectedPotions = selected
    end,
})

PotionSection:AddToggle({
    Title = "Auto Use Potions",
    Default = false,
    Callback = function(enabled)
        _G.AutoUsePotions = enabled
        
        task.spawn(function()
            while _G.AutoUsePotions do
                task.wait(1)
                local potionsInventory = DataStorage.Data:GetExpect({"Inventory", "Potions"}) or {}
                
                for _, potionName in ipairs(selectedPotions) do
                    local potionInfo = Settings.Potions[potionName]
                    if potionInfo then
                        for _, potionItem in ipairs(potionsInventory) do
                            if potionItem.Id == potionInfo.Id then
                                pcall(function()
                                    GameModules.Net["RF/ConsumePotion"]:InvokeServer(potionItem.UUID, 1)
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end,
})

-- Event Features Section
local EventSection = Tabs.Auto:AddSection("Event Features")

EventSection:AddDropdown({
    Options = getAvailableEvents() or {},
    Multi = false,
    Title = "Priority Event",
    Callback = function(selected)
        Settings.priorityEvent = selected
    end,
})

EventSection:AddDropdown({
    Options = getAvailableEvents() or {},
    Multi = true,
    Title = "Select Event",
    Callback = function(selected)
        Settings.selectedEvents = {}
        for _, eventName in pairs(selected) do
            table.insert(Settings.selectedEvents, eventName)
        end
        
        Settings.curCF = nil
        if Settings.autoEventActive and (#Settings.selectedEvents > 0 or Settings.priorityEvent) then
            task.spawn(Settings.loop)
        end
    end,
})

EventSection:AddToggle({
    Title = "Auto Event",
    Default = false,
    Callback = function(enabled)
        Settings.autoEventActive = enabled
        
        if enabled and (#Settings.selectedEvents > 0 or Settings.priorityEvent) then
            Settings.origCF = Settings.origCF or findPlayerPart(LocalPlayer.Character).CFrame
            task.spawn(Settings.loop)
        else
            if Settings.origCF then
                LocalPlayer.Character:PivotTo(Settings.origCF)
                chloex("Auto Event Off")
            end
            Settings.curCF = nil
            Settings.origCF = nil
        end
    end,
})

local TradingFishSection = Tabs.Trade:AddSection("Trading Fish Features")

-- Trading Coin Features Section
local TradingCoinSection = Tabs.Trade:AddSection("Trading Coin Features")

local FishTradeMonitor = TradingFishSection:AddParagraph({
    Title = "Panel Name Trading",
    Content = "\r\nPlayer : ???\r\nItem   : ???\r\nAmount : 0\r\nStatus : Idle\r\nSuccess: 0 / 0\r\n",
})

local CoinTradeMonitor = TradingCoinSection:AddParagraph({
    Title = "Panel Coin Trading",
    Content = "\r\nPlayer   : ???\r\nTarget   : 0\r\nProgress : 0 / 0\r\nStatus   : Idle\r\nResult   : Success : 0 | Received : 0\r\n",
})

local ParagraphUpdateQueue = {}

function _G.safeSetContent(paragraph, content)
    if not paragraph then
        return
    end
    ParagraphUpdateQueue[paragraph] = content
end

Services.RunService.Heartbeat:Connect(function()
    for paragraph, content in pairs(ParagraphUpdateQueue) do
        paragraph:SetContent(content)
        ParagraphUpdateQueue[paragraph] = nil
    end
end)

function UpdateFishTradeStatus(status)
    local tradeInfo = Settings.trade
    local statusColor = "200,200,200"
    
    if status and status:lower():find("send") then
        statusColor = "51,153,255"
    elseif status and status:lower():find("complete") then
        statusColor = "0,204,102"
    elseif status and status:lower():find("time") then
        statusColor = "255,69,0"
    end
    
    local content = string.format(
        "\r\n<font color='rgb(173,216,230)'>Player : %s</font>\r\n<font color='rgb(173,216,230)'>Item   : %s</font>\r\n<font color='rgb(173,216,230)'>Amount : %d</font>\r\n<font color='rgb(%s)'>Status : %s</font>\r\n<font color='rgb(173,216,230)'>Success: %d / %d</font>\r\n",
        tradeInfo.selectedPlayer or "???",
        tradeInfo.selectedItem or "???",
        tradeInfo.tradeAmount or 0,
        statusColor,
        status or "Idle",
        tradeInfo.successCount or 0,
        tradeInfo.totalToTrade or 0
    )
    
    _G.safeSetContent(FishTradeMonitor, content)
end

function UpdateCoinTradeStatus(status)
    local tradeInfo = Settings.trade
    local statusColor = "200,200,200"
    
    if status and status:lower():find("send") then
        statusColor = "51,153,255"
    elseif status and status:lower():find("progress") then
        statusColor = "255,215,0"
    elseif status and status:lower():find("complete") then
        statusColor = "0,204,102"
    elseif status and status:lower():find("time") then
        statusColor = "255,69,0"
    end
    
    local content = string.format(
        "\r\n<font color='rgb(173,216,230)'>Player   : %s</font>\r\n<font color='rgb(173,216,230)'>Target   : %d</font>\r\n<font color='rgb(173,216,230)'>Progress : %d / %d</font>\r\n<font color='rgb(%s)'>Status   : %s</font>\r\n<font color='rgb(173,216,230)'>Result   : Success : %d | Received : %d</font>\r\n",
        tradeInfo.selectedPlayer or "???",
        tradeInfo.targetCoins or 0,
        tradeInfo.successCoins or 0,
        tradeInfo.targetCoins or 0,
        statusColor,
        status or "Idle",
        tradeInfo.successCoins or 0,
        tradeInfo.totalReceived or 0
    )
    
    _G.safeSetContent(CoinTradeMonitor, content)
end

function CheckItemInInventory(itemUUID)
    for _, item in ipairs(DataStorage.Data:GetExpect({"Inventory", "Items"})) do
        if item.UUID == itemUUID then
            return true
        end
    end
    return false
end

function SendTradeRequest(playerName, itemUUID, itemName, coinAmount)
    local tradeInfo = Settings.trade
    tradeInfo.lastResult = nil
    tradeInfo.awaiting = true
    
    local success = false
    local targetPlayer = Services.Players:FindFirstChild(playerName)
    
    if not targetPlayer then
        tradeInfo.trading = false
        UpdateFishTradeStatus("<font color='#ff3333'>Player not found</font>")
        UpdateCoinTradeStatus("<font color='#ff3333'>Player not found</font>")
        return false
    end
    
    if itemName then
        UpdateFishTradeStatus("Sending")
        chloex("Sending " .. itemName)
    else
        UpdateCoinTradeStatus("Sending")
        chloex("Sending fish for coins")
    end
    
    if not pcall(function()
        Network.Functions.Trade:InvokeServer(targetPlayer.UserId, itemUUID)
    end) then
        return false
    end
    
    local startTime = tick()
    while tradeInfo.trading and not success do
        local itemRemoved = not CheckItemInInventory(itemUUID)
        
        if itemRemoved then
            success = true
            if itemName then
                tradeInfo.successCount = tradeInfo.successCount + 1
                UpdateFishTradeStatus("Completed")
            else
                tradeInfo.successCoins = tradeInfo.successCoins + (coinAmount or 0)
                tradeInfo.totalReceived = tradeInfo.successCoins
                UpdateCoinTradeStatus("Progress")
            end
        else
            if tick() - startTime > 10 then
                return false
            end
        end
        
        task.wait(0.2)
    end
    
    return success
end

function RetryTrade(playerName, itemUUID, itemName, coinAmount)
    local tradeInfo = Settings.trade
    local retryCount = 0
    
    while retryCount < 3 and tradeInfo.trading do
        if SendTradeRequest(playerName, itemUUID, itemName, coinAmount) then
            task.wait(2.5)
            return true
        end
        retryCount = retryCount + 1
        task.wait(1)
    end
    
    return false
end

function startTradeByName()
    local tradeInfo = Settings.trade
    
    if tradeInfo.trading then
        return
    end
    
    if not tradeInfo.selectedPlayer or not tradeInfo.selectedItem then
        return chloex("Select player & item first!")
    end
    
    tradeInfo.trading = true
    tradeInfo.successCount = 0
    chloex("Starting trade with " .. tradeInfo.selectedPlayer)
    
    local selectedGroup = tradeInfo.currentGrouped[tradeInfo.selectedItem]
    if not selectedGroup then
        tradeInfo.trading = false
        UpdateFishTradeStatus("<font color='#ff3333'>Item not found</font>")
        return chloex("Item not found")
    end
    
    tradeInfo.totalToTrade = math.min(tradeInfo.tradeAmount, #selectedGroup.uuids)
    local currentIndex = 1
    
    while tradeInfo.trading do
        if tradeInfo.successCount < tradeInfo.totalToTrade then
            RetryTrade(tradeInfo.selectedPlayer, selectedGroup.uuids[currentIndex], tradeInfo.selectedItem)
            currentIndex = currentIndex + 1
            
            if currentIndex > #selectedGroup.uuids then
                currentIndex = 1
            end
            
            task.wait(2)
        else
            break
        end
    end
    
    tradeInfo.trading = false
    UpdateFishTradeStatus("<font color='#66ccff'>All trades finished</font>")
    chloex("All trades finished")
end

function chooseFishesByRange(fishList, targetCoins)
    table.sort(fishList, function(a, b)
        return b.Price < a.Price
    end)
    
    local selectedFishes = {}
    local totalValue = 0
    
    for _, fish in ipairs(fishList) do
        if totalValue + fish.Price <= targetCoins then
            table.insert(selectedFishes, fish)
            totalValue = totalValue + fish.Price
        end
        
        if totalValue >= targetCoins then
            break
        end
    end
    
    if totalValue < targetCoins and #fishList > 0 then
        table.insert(selectedFishes, fishList[#fishList])
    end
    
    return selectedFishes, totalValue
end

function startTradeByCoin()
    local tradeInfo = Settings.trade
    
    if tradeInfo.trading then
        return
    end
    
    if not tradeInfo.selectedPlayer or tradeInfo.targetCoins <= 0 then
        return chloex("⚠ Select player & coin target first!")
    end
    
    tradeInfo.trading = true
    tradeInfo.totalReceived = 0
    tradeInfo.successCoins = 0
    tradeInfo.sentCoins = 0
    
    UpdateCoinTradeStatus("<font color='#ffaa00'>Starting...</font>")
    chloex("Starting coin trade with " .. tradeInfo.selectedPlayer)
    
    local playerModifiers = GameModules.PlayerStatsUtility:GetPlayerModifiers(Services.Players.LocalPlayer)
    local fishList = {}
    
    for _, item in ipairs(DataStorage.Data:GetExpect({"Inventory", "Items"})) do
        if not item.Favorited then
            local itemData = GameModules.ItemUtility:GetItemData(item.Id)
            if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                local basePrice = GameModules.VendorUtility:GetSellPrice(item) or itemData.SellPrice or 0
                local coinMultiplier = playerModifiers and playerModifiers.CoinMultiplier or 1
                local finalPrice = math.ceil(basePrice * coinMultiplier)
                
                if finalPrice > 0 then
                    table.insert(fishList, {
                        UUID = item.UUID,
                        Name = itemData.Data.Name or "Unknown",
                        Price = finalPrice,
                    })
                end
            end
        end
    end
    
    if #fishList == 0 then
        tradeInfo.trading = false
        UpdateCoinTradeStatus("<font color='#ff3333'>No fishes found</font>")
        chloex("⚠ No fishes found in inventory")
        return
    end
    
    local selectedFishes, totalCoins = chooseFishesByRange(fishList, tradeInfo.targetCoins)
    if #selectedFishes == 0 then
        tradeInfo.trading = false
        UpdateCoinTradeStatus("<font color='#ff3333'>No valid fishes for target</font>")
        return
    end
    
    tradeInfo.totalToTrade = #selectedFishes
    tradeInfo.targetCoins = totalCoins
    
    if not Services.Players:FindFirstChild(tradeInfo.selectedPlayer) then
        tradeInfo.trading = false
        UpdateCoinTradeStatus("<font color='#ff3333'>Player not found</font>")
        return
    end
    
    for _, fish in ipairs(selectedFishes) do
        if not tradeInfo.trading then
            break
        end
        
        tradeInfo.sentCoins = tradeInfo.sentCoins + fish.Price
        UpdateCoinTradeStatus(string.format("<font color='#ffaa00'>Progress : %d / %d</font>", tradeInfo.sentCoins, tradeInfo.targetCoins))
        
        RetryTrade(tradeInfo.selectedPlayer, fish.UUID, nil, fish.Price)
        tradeInfo.successCoins = tradeInfo.sentCoins
        task.wait(2)
    end
    
    tradeInfo.trading = false
    UpdateCoinTradeStatus(string.format("<font color='#66ccff'>Coin trade finished (Target: %d, Received: %d)</font>", tradeInfo.targetCoins, tradeInfo.successCoins))
    chloex(string.format("Coin trade finished (Target: %d, Received: %d)", tradeInfo.targetCoins, tradeInfo.successCoins))
end

function getGroupedByType(itemType)
    local inventory = DataStorage.Data:GetExpect({"Inventory", "Items"})
    local groupedItems = {}
    local displayList = {}
    
    for _, item in ipairs(inventory) do
        local itemData = GameModules.ItemUtility.GetItemDataFromItemType("Items", item.Id)
        if itemData and itemData.Data.Type == itemType and not item.Favorited then
            local itemName = itemData.Data.Name
            local group = groupedItems[itemName]
            
            if not group then
                group = {count = 0, uuids = {}}
                groupedItems[itemName] = group
            end
            
            groupedItems[itemName].count = groupedItems[itemName].count + (item.Quantity or 1)
            table.insert(groupedItems[itemName].uuids, item.UUID)
        end
    end
    
    for itemName, group in pairs(groupedItems) do
        table.insert(displayList, ("%s x%d"):format(itemName, group.count))
    end
    
    return groupedItems, displayList
end

local ItemDropdown = TradingFishSection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Item",
    Callback = function(selected)
        local tradeInfo = Settings.trade
        local itemName = selected and selected:match("^(.-) x") or selected
        tradeInfo.selectedItem = itemName
        UpdateFishTradeStatus()
    end,
})

TradingFishSection:AddButton({
    Title = "Refresh Fish",
    Callback = function()
        local groupedItems, displayList = getGroupedByType("Fish")
        Settings.trade.currentGrouped = groupedItems
        ItemDropdown:SetValues(displayList or {})
    end,
    SubTitle = "Refresh Stone",
    SubCallback = function()
        local groupedItems, displayList = getGroupedByType("Enchant Stones")
        Settings.trade.currentGrouped = groupedItems
        ItemDropdown:SetValues(displayList or {})
    end,
})

TradingFishSection:AddInput({
    Title = "Amount to Trade",
    Default = "1",
    Callback = function(input)
        Settings.trade.tradeAmount = tonumber(input) or 1
        UpdateFishTradeStatus()
    end,
})

local PlayerDropdown = TradingFishSection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Player",
    Callback = function(selected)
        Settings.trade.selectedPlayer = selected
        UpdateFishTradeStatus()
    end,
})

TradingFishSection:AddButton({
    Title = "Refresh Player",
    Callback = function()
        local players = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Settings.player then
                table.insert(players, player.Name)
            end
        end
        PlayerDropdown:SetValues(players or {})
    end,
})

TradingFishSection:AddToggle({
    Title = "Start By Name",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(startTradeByName)
        else
            Settings.trade.trading = false
            UpdateFishTradeStatus()
        end
    end,
})

-- Trading Coin Section Controls
local CoinPlayerDropdown = TradingCoinSection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Player",
    Callback = function(selected)
        Settings.trade.selectedPlayer = selected
        UpdateCoinTradeStatus()
    end,
})

TradingCoinSection:AddButton({
    Title = "Refresh Player",
    Callback = function()
        local players = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Settings.player then
                table.insert(players, player.Name)
            end
        end
        CoinPlayerDropdown:SetValues(players or {})
    end,
})

TradingCoinSection:AddInput({
    Title = "Target Coin",
    Default = "0",
    Callback = function(input)
        Settings.trade.targetCoins = tonumber(input) or 0
        UpdateCoinTradeStatus()
    end,
})

TradingCoinSection:AddToggle({
    Title = "Start By Coin",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(startTradeByCoin)
        else
            Settings.trade.trading = false
        end
    end,
})

-- Trading Rarity Features Section
local TradingRaritySection = Tabs.Trade:AddSection("Trading Rarity Features")

local RarityTradeMonitor = TradingRaritySection:AddParagraph({
    Title = "Panel Rarity Trading",
    Content = "\r\nPlayer  : ???\r\nRarity  : ???\r\nCount   : 0\r\nStatus  : Idle\r\nSuccess : 0 / 0\r\n",
})

function UpdateRarityTradeStatus(status)
    local tradeInfo = Settings.trade
    local statusColor = "200,200,200"
    
    if status and status:lower():find("send") then
        statusColor = "51,153,255"
    elseif status and status:lower():find("complete") then
        statusColor = "0,204,102"
    elseif status and status:lower():find("time") then
        statusColor = "255,69,0"
    end
    
    local content = string.format(
        "\r\n<font color='rgb(173,216,230)'>Player  : %s</font>\r\n<font color='rgb(173,216,230)'>Rarity  : %s</font>\r\n<font color='rgb(173,216,230)'>Count   : %d</font>\r\n<font color='rgb(%s)'>Status  : %s</font>\r\n<font color='rgb(173,216,230)'>Success : %d / %d</font>\r\n",
        tradeInfo.selectedPlayer or "???",
        tradeInfo.selectedRarity or "???",
        tradeInfo.totalToTrade or 0,
        statusColor,
        status or "Idle",
        tradeInfo.successCount or 0,
        tradeInfo.totalToTrade or 0
    )
    
    _G.safeSetContent(RarityTradeMonitor, content)
end

TradingRaritySection:AddDropdown({
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = false,
    Title = "Select Rarity",
    Callback = function(selected)
        Settings.trade.selectedRarity = selected
        UpdateRarityTradeStatus("Selected rarity: " .. (selected or "???"))
    end,
})

local RarityPlayerDropdown = TradingRaritySection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Player",
    Callback = function(selected)
        Settings.trade.selectedPlayer = selected
        UpdateRarityTradeStatus()
    end,
})

TradingRaritySection:AddButton({
    Title = "Refresh Player",
    Callback = function()
        local players = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Settings.player then
                table.insert(players, player.Name)
            end
        end
        RarityPlayerDropdown:SetValues(players or {})
    end,
})

TradingRaritySection:AddInput({
    Title = "Amount to Trade",
    Default = "1",
    Callback = function(input)
        Settings.trade.rarityAmount = tonumber(input) or 1
        UpdateRarityTradeStatus("Set amount: " .. tostring(Settings.trade.rarityAmount))
    end,
})

function startTradeByRarity()
    local tradeInfo = Settings.trade
    
    if tradeInfo.trading then
        return
    end
    
    if not tradeInfo.selectedPlayer or not tradeInfo.selectedRarity then
        return chloex("⚠ Select player & rarity first!")
    end
    
    tradeInfo.trading = true
    tradeInfo.successCount = 0
    chloex("Starting rarity trade (" .. tradeInfo.selectedRarity .. ") with " .. tradeInfo.selectedPlayer)
    
    UpdateRarityTradeStatus("<font color='#ffaa00'>Scanning " .. tradeInfo.selectedRarity .. " fishes...</font>")
    
    local rarityFishList = {}
    for _, item in ipairs(DataStorage.Data:GetExpect({"Inventory", "Items"})) do
        if not item.Favorited then
            local itemData = GameModules.ItemUtility.GetItemDataFromItemType("Items", item.Id)
            if itemData and itemData.Data.Type == "Fish" and _G.TierFish[itemData.Data.Tier] == tradeInfo.selectedRarity then
                table.insert(rarityFishList, {
                    UUID = item.UUID,
                    Name = itemData.Data.Name,
                })
            end
        end
    end
    
    if #rarityFishList == 0 then
        tradeInfo.trading = false
        UpdateRarityTradeStatus("<font color='#ff3333'>No " .. tradeInfo.selectedRarity .. " fishes found</font>")
        return chloex("No " .. tradeInfo.selectedRarity .. " fishes found")
    end
    
    tradeInfo.totalToTrade = math.min(#rarityFishList, tradeInfo.rarityAmount or #rarityFishList)
    UpdateRarityTradeStatus(string.format("Sending %d %s fishes...", tradeInfo.totalToTrade, tradeInfo.selectedRarity))
    
    local currentIndex = 1
    while tradeInfo.trading do
        if currentIndex <= tradeInfo.totalToTrade then
            local fishItem = rarityFishList[currentIndex]
            local success = RetryTrade(tradeInfo.selectedPlayer, fishItem.UUID, fishItem.Name)
            
            if success then
                tradeInfo.successCount = tradeInfo.successCount + 1
                UpdateRarityTradeStatus(string.format("Progress: %d / %d (%s)", tradeInfo.successCount, tradeInfo.totalToTrade, tradeInfo.selectedRarity))
            end
            
            currentIndex = currentIndex + 1
            task.wait(2.5)
        else
            break
        end
    end
    
    tradeInfo.trading = false
    UpdateRarityTradeStatus("<font color='#66ccff'>Rarity trade finished</font>")
    chloex("Rarity trade finished (" .. tradeInfo.selectedRarity .. ")")
end

TradingRaritySection:AddToggle({
    Title = "Start By Rarity",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(startTradeByRarity)
        else
            Settings.trade.trading = false
            UpdateRarityTradeStatus("Idle")
        end
    end,
})

-- Auto Accept Trade Section
local AutoAcceptSection = Tabs.Trade:AddSection("Auto Accept Features")

AutoAcceptSection:AddToggle({
    Title = "Auto Accept Trade",
    Default = _G.AutoAccept,
    Callback = function(enabled)
        _G.AutoAccept = enabled
    end,
})

task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoAccept then
            pcall(function()
                local promptGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Prompt")
                if promptGui and promptGui:FindFirstChild("Blackout") then
                    local blackoutFrame = promptGui.Blackout
                    if blackoutFrame:FindFirstChild("Options") then
                        local yesButton = blackoutFrame.Options:FindFirstChild("Yes")
                        if yesButton then
                            local virtualInput = game:GetService("VirtualInputManager")
                            local buttonPosition = yesButton.AbsolutePosition
                            local buttonSize = yesButton.AbsoluteSize
                            local clickX = buttonPosition.X + buttonSize.X / 2
                            local clickY = buttonPosition.Y + buttonSize.Y / 2 + 50
                            
                            virtualInput:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                            task.wait(0.03)
                            virtualInput:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- Threshold Features Section (Farm Tab)
local ThresholdSection = Tabs.Farm:AddSection("Threshold Features")

local ThresholdParagraph = ThresholdSection:AddParagraph({
    Title = "Farm Threshold Panel",
    Content = "\r\nCurrent : 0\r\nTarget : 0\r\nProgress : 0%\r\n",
})

local ThresholdTotalBase = 0
local ThresholdBase = 0
local ThresholdTarget = 0
local ThresholdPos2 = ""
local ThresholdPos1 = ""

ThresholdSection:AddInput({
    Title = "Position 1",
    Callback = function(input)
        ThresholdPos1 = input == "" and "" or input
    end,
})

ThresholdSection:AddInput({
    Title = "Position 2",
    Callback = function(input)
        ThresholdPos2 = input == "" and "" or input
    end,
})

ThresholdSection:AddButton({
    Title = "Copy Current Position",
    Callback = function()
        local player = Services.Players.LocalPlayer
        local humanoidRootPart = (player.Character or player.CharacterAdded:Wait()):FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local positionString = string.format("%.1f, %.1f, %.1f", humanoidRootPart.Position.X, humanoidRootPart.Position.Y, humanoidRootPart.Position.Z)
            if setclipboard then
                setclipboard(positionString)
            end
            chloex("Successfully copied your position to clipboard!")
        end
    end,
})

ThresholdSection:AddInput({
    Title = "Target Fish Caught",
    Callback = function(input)
        ThresholdTarget = tonumber(input) or 0
    end,
})

ThresholdSection:AddToggle({
    Title = "Enable Threshold Farm",
    Default = false,
    Callback = function(enabled)
        _G.ThresholdFarm = enabled
        if enabled then
            ThresholdBase = (DataStorage.Data:Get({"Statistics"}) or {}).FishCaught or 0
            ThresholdTotalBase = ThresholdBase
        end
    end,
})

-- Coin Features Section
local CoinSection = Tabs.Farm:AddSection("Coin Features")

local CoinParagraph = CoinSection:AddParagraph({
    Title = "Coin Farm Panel",
    Content = "\r\nCurrent : 0\r\nTarget : 0\r\nProgress : 0%\r\n",
})

local CoinBase = 0
local CoinTarget = 0
local CoinSpotOptions = {
    ["Kohana Volcano"] = Vector3.new(-552, 19, 183),
    ["Tropical Grove"] = Vector3.new(-2084, 3, 3700),
}

CoinSection:AddDropdown({
    Title = "Coin Location",
    Options = {"Kohana Volcano", "Tropical Grove"},
    Multi = false,
    Callback = function(selected)
        SelectedCoinSpot = CoinSpotOptions[selected]
    end,
})

CoinSection:AddInput({
    Title = "Target Coin",
    Placeholder = "Enter coin target...",
    Callback = function(input)
        local targetValue = tonumber(input)
        if targetValue then
            CoinTarget = targetValue
        end
    end,
})

CoinSection:AddToggle({
    Title = "Enable Coin Farm",
    Default = false,
    Callback = function(enabled)
        _G.CoinFarm = enabled
        if enabled then
            repeat task.wait() until DataStorage.Data
            CoinBase = DataStorage.Data:Get({"Coins"}) or 0
        end
    end,
})

-- Enchant Stone Features Section
local EnchantFarmSection = Tabs.Farm:AddSection("Enchant Stone Features")

local EnchantFarmPanel = EnchantFarmSection:AddParagraph({
    Title = "Enchant Stone Farm Panel",
    Content = "\r\nCurrent : 0\r\nTarget : 0\r\nProgress : 0%\r\n",
})

local EnchantBase = 0
local EnchantTarget = 0
local EnchantSpotOptions = {
    ["Tropical Grove"] = Vector3.new(-2084, 3, 3700),
    ["Esoteric Depths"] = Vector3.new(3272, -1302, 1404),
}

EnchantFarmSection:AddDropdown({
    Title = "Enchant Stone Location",
    Options = {"Tropical Grove", "Esoteric Depths"},
    Multi = false,
    Callback = function(selected)
        SelectedEnchantSpot = EnchantSpotOptions[selected]
    end,
})

EnchantFarmSection:AddInput({
    Title = "Target Enchant Stone",
    Placeholder = "Enter enchant stone target...",
    Callback = function(input)
        local targetValue = tonumber(input)
        if targetValue then
            EnchantTarget = targetValue
        end
    end,
})

EnchantFarmSection:AddToggle({
    Title = "Enable Enchant Farm",
    Default = false,
    Callback = function(enabled)
        _G.EnchantFarm = enabled
        if enabled then
            local inventory = DataStorage.Data:Get({"Inventory", "Items"}) or {}
            local stoneCount = 0
            for _, item in ipairs(inventory) do
                if item.Id == 10 then
                    stoneCount = stoneCount + (item.Amount or 1)
                end
            end
            EnchantBase = stoneCount
        end
    end,
})

task.spawn(function()
    local isTeleporting = false
    local savedPosition = nil
    local lastFishCount = 0
    
    while task.wait(1) do
        if DataStorage.Data then
            local character = Services.Players.LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and not savedPosition then
                savedPosition = humanoidRootPart.CFrame
            end
            
            -- Threshold Farm Logic
            if _G.ThresholdFarm then
                local fishCaught = (DataStorage.Data:Get({"Statistics"}) or {}).FishCaught or 0
                if lastFishCount == 0 then
                    lastFishCount = ThresholdBase
                end
                
                local progress = fishCaught - ThresholdBase
                local progressPercent = 0
                if ThresholdTarget > 0 then
                    progressPercent = math.min(progress / ThresholdTarget * 100, 100) or 0
                end
                
                ThresholdParagraph:SetContent(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", progress, ThresholdTarget, progressPercent))
                
                if humanoidRootPart and ThresholdPos1 ~= "" and ThresholdPos2 ~= "" and not isTeleporting then
                    isTeleporting = true
                    
                    task.spawn(function()
                        local pos1 = Vector3.new(unpack(string.split(ThresholdPos1, ",")))
                        local pos2 = Vector3.new(unpack(string.split(ThresholdPos2, ",")))
                        local targetCount = fishCaught + ThresholdTarget
                        
                        while _G.ThresholdFarm do
                            -- Teleport to position 1
                            while true do
                                task.wait(1)
                                local currentStats = DataStorage.Data:Get({"Statistics"}) or {}
                                local currentFish = currentStats.FishCaught or 0
                                fishCaught = currentFish
                                
                                if targetCount > currentFish and _G.ThresholdFarm then
                                    -- Continue fishing
                                else
                                    break
                                end
                            end
                            
                            if not _G.ThresholdFarm then break end
                            
                            -- Teleport to position 2
                            humanoidRootPart.CFrame = CFrame.new(pos2 + Vector3.new(0, 3, 0))
                            ThresholdBase = fishCaught
                            targetCount = fishCaught + ThresholdTarget
                            
                            while true do
                                task.wait(1)
                                local currentStats = DataStorage.Data:Get({"Statistics"}) or {}
                                local currentFish = currentStats.FishCaught or 0
                                fishCaught = currentFish
                                
                                if targetCount > currentFish then
                                    if not _G.ThresholdFarm then
                                        break
                                    end
                                else
                                    break
                                end
                            end
                            
                            if _G.ThresholdFarm then
                                humanoidRootPart.CFrame = CFrame.new(pos1 + Vector3.new(0, 3, 0))
                                ThresholdBase = fishCaught
                                targetCount = fishCaught + ThresholdTarget
                            else
                                break
                            end
                        end
                        
                        isTeleporting = false
                    end)
                end
            end
            
            -- Coin Farm Logic
            if _G.CoinFarm then
                local currentCoins = (DataStorage.Data:Get({"Coins"}) or 0) - CoinBase
                local coinProgressPercent = 0
                if CoinTarget > 0 then
                    coinProgressPercent = math.min(currentCoins / CoinTarget * 100, 100) or 0
                end
                
                CoinParagraph:SetContent(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", currentCoins, CoinTarget, coinProgressPercent))
                
                if SelectedCoinSpot and humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(SelectedCoinSpot + Vector3.new(0, 3, 0))
                end
            end
            
            -- Enchant Farm Logic
            if _G.EnchantFarm then
                local inventory = DataStorage.Data:Get({"Inventory", "Items"}) or {}
                local stoneCount = 0
                for _, item in ipairs(inventory) do
                    if item.Id == 10 then
                        stoneCount = stoneCount + (item.Amount or 1)
                    end
                end
                
                local currentStones = stoneCount - EnchantBase
                local enchantProgressPercent = 0
                if EnchantTarget > 0 then
                    enchantProgressPercent = math.min(currentStones / EnchantTarget * 100, 100) or 0
                end
                
                EnchantFarmPanel:SetContent(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", currentStones, EnchantTarget, enchantProgressPercent))
                
                if SelectedEnchantSpot and humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(SelectedEnchantSpot + Vector3.new(0, 3, 0))
                end
            end
        else
            task.wait(1)
        end
    end
end)

-- Event Features Section
local EventFarmSection = Tabs.Farm:AddSection("Event Features")

local countdownParagraph = EventFarmSection:AddParagraph({
    Title = "Ancient Lochness Monster Countdown",
    Content = "<font color='#ff4d4d'><b>waiting for ... for joined event!</b></font>",
})

Settings.FarmPosition = Settings.FarmPosition or nil
Settings.autoCountdownUpdate = false

EventFarmSection:AddToggle({
    Title = "Auto Admin Event",
    Default = false,
    Callback = function(enabled)
        local player = Services.Players.LocalPlayer
        Settings.autoCountdownUpdate = enabled
        
        local function findCountdownLabel()
            local success, label = pcall(function()
                return workspace["!!! MENU RINGS"]["Event Tracker"].Main.Gui.Content.Items.Countdown.Label
            end)
            return success and label or nil
        end
        
        local function teleportToEvent(character)
            character.CFrame = CFrame.new(Vector3.new(6063, -586, 4715))
        end
        
        local function returnToFarm(character)
            if Settings.FarmPosition then
                character.CFrame = Settings.FarmPosition
                countdownParagraph:SetContent("<font color='#00ff99'><b>✅ Returned to saved farm position!</b></font>")
            else
                countdownParagraph:SetContent("<font color='#ff4d4d'><b>❌ No saved farm position found!</b></font>")
            end
        end
        
        if enabled then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
            
            if humanoidRootPart then
                Settings.FarmPosition = humanoidRootPart.CFrame
                countdownParagraph:SetContent("<font color='#00ff99'><b>Farm position saved!</b></font>")
            end
            
            local countdownLabel = findCountdownLabel()
            if not countdownLabel then
                countdownParagraph:SetContent("<font color='#ff4d4d'><b>Label not found!</b></font>")
                return
            end
            
            task.spawn(function()
                local eventStarted = false
                while Settings.autoCountdownUpdate do
                    task.wait(1)
                    
                    local timerText = ""
                    pcall(function()
                        timerText = countdownLabel.Text or ""
                    end)
                    
                    if timerText == "" then
                        countdownParagraph:SetContent("<font color='#ff4d4d'><b>Waiting for countdown...</b></font>")
                    else
                        countdownParagraph:SetContent(string.format("<font color='#4de3ff'><b>Timer: %s</b></font>", timerText))
                        
                        local currentCharacter = player.Character or player.CharacterAdded:Wait()
                        local currentHRP = currentCharacter:WaitForChild("HumanoidRootPart", 5)
                        
                        if not currentHRP then
                            countdownParagraph:SetContent("<font color='#ff4d4d'><b>⚠️ HRP not found, retrying...</b></font>")
                        else
                            local hours, minutes, seconds = timerText:match("(%d+)H%s*(%d+)M%s*(%d+)S")
                            hours = tonumber(hours)
                            minutes = tonumber(minutes)
                            seconds = tonumber(seconds)
                            
                            if hours == 3 and minutes == 59 and seconds == 59 and not eventStarted then
                                countdownParagraph:SetContent("<font color='#00ff99'><b>Event started! Teleporting...</b></font>")
                                teleportToEvent(currentHRP)
                                eventStarted = true
                            elseif hours == 3 and minutes == 49 and seconds == 59 and eventStarted then
                                countdownParagraph:SetContent("<font color='#ffaa00'><b>Event ended! Returning...</b></font>")
                                returnToFarm(currentHRP)
                                eventStarted = false
                            end
                        end
                    end
                    
                    if not countdownLabel or not countdownLabel.Parent then
                        countdownLabel = findCountdownLabel()
                        if not countdownLabel then
                            countdownParagraph:SetContent("<font color='#ff4d4d'><b>Label lost. Reconnecting...</b></font>")
                            task.wait(2)
                            countdownLabel = findCountdownLabel()
                        end
                    end
                end
            end)
        else
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
            
            if humanoidRootPart then
                returnToFarm(humanoidRootPart)
            end
            
            countdownParagraph:SetContent("<font color='#ff4d4d'><b>Auto Admin Event disabled.</b></font>")
        end
    end,
})

local KaitunSection = Tabs.Farm:AddSection("Semi Kaitun [BETA]")
local Panel = KaitunSection

local RS = game:GetService("ReplicatedStorage")
local ItemsFolder = RS:WaitForChild("Items")
local BaitsFolder = RS:WaitForChild("Baits")
local SellAllEvent = GameModules.Net["RF/SellAllItems"]

_G.SelectedFarmLocation = "Kohana Volcano"
_G.DeepSeaDone = _G.DeepSeaDone or false
_G.ArtifactDone = _G.ArtifactDone or false
_G.LastArtifactTP = _G.LastArtifactTP or 0

function getItemNameFromFolder(folder, itemId, itemType)
    for _, moduleScript in ipairs(folder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, moduleData = pcall(require, moduleScript)
            if success and moduleData and moduleData.Data then
                local itemData = moduleData.Data
                if itemData.Id == itemId and (not itemType or itemData.Type == itemType) then
                    if moduleData.IsSkin then
                        return nil
                    end
                    return itemData.Name
                end
            end
        end
    end
    return nil
end

local Locations = {
    ["Kohana Volcano"] = Vector3.new(-552, 19, 183),
    ["Tropical Grove"] = Vector3.new(-2084, 3, 3700),
    ["Esoteric Deep"] = CFrame.new(3269, -1302, 1406) * CFrame.Angles(0, math.rad(-180), 0),
    DeepSea_Start = CFrame.new(-3633, -279, -1603) * CFrame.Angles(0, math.rad(-45), 0),
    DeepSea_2 = CFrame.new(-3735, -135, -1011) * CFrame.Angles(0, math.rad(180), 0),
    ["Arrow Artifact"] = CFrame.new(875, 3, -368) * CFrame.Angles(0, math.rad(90), 0),
    ["Crescent Artifact"] = CFrame.new(1403, 3, 123) * CFrame.Angles(0, math.rad(180), 0),
    ["Hourglass Diamond Artifact"] = CFrame.new(1487, 3, -842) * CFrame.Angles(0, math.rad(180), 0),
    ["Diamond Artifact"] = CFrame.new(1844, 3, -287) * CFrame.Angles(0, math.rad(-90), 0),
    Element_Stage1 = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0),
    Element_Stage2 = CFrame.new(1453, -22, -636),
    Element_Final = CFrame.new(1480, 128, -593),
}

local artifactOrder = {
    "Arrow Artifact",
    "Crescent Artifact",
    "Hourglass Diamond Artifact",
    "Diamond Artifact"
}

function TeleportToLocation(position)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        if typeof(position) == "Vector3" then
            humanoidRootPart.CFrame = CFrame.new(position)
        else
            humanoidRootPart.CFrame = position
        end
    end
end

function hasRod(rodName)
    local inventory = DataStorage.Data:Get({"Inventory"}) or {}
    local fishingRods = inventory["Fishing Rods"] or {}
    
    for _, rodItem in ipairs(fishingRods) do
        if getItemNameFromFolder(ItemsFolder, rodItem.Id, "Fishing Rods") == rodName then
            return true
        end
    end
    return false
end

function hasBait(baitName)
    local inventory = DataStorage.Data:Get({"Inventory"}) or {}
    local baits = inventory.Baits or {}
    
    for _, baitItem in ipairs(baits) do
        if getItemNameFromFolder(BaitsFolder, baitItem.Id) == baitName then
            return true
        end
    end
    return false
end

function hasArtifactWorld(artifactName)
    local jungleInteractions = workspace:FindFirstChild("JUNGLE INTERACTIONS")
    if not jungleInteractions then
        return false
    end
    
    local artifactType = artifactName:lower():gsub(" artifact", "")
    for _, descendant in ipairs(jungleInteractions:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == "TempleLever" then
            local leverType = tostring(descendant:GetAttribute("Type") or ""):lower()
            if leverType:find(artifactType) then
                local rootPart = descendant:FindFirstChild("RootPart")
                local proximityPrompt = rootPart and rootPart:FindFirstChildWhichIsA("ProximityPrompt")
                return proximityPrompt == nil
            end
        end
    end
    return false
end

function readTracker(trackerName)
    local tracker = workspace["!!! MENU RINGS"]:FindFirstChild(trackerName)
    if not tracker then
        return ""
    end
    
    local content = tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui") and tracker.Board.Gui:FindFirstChild("Content")
    if not content then
        return ""
    end
    
    local lines = {}
    local lineNumber = 1
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("TextLabel") and child.Name ~= "Header" then
            table.insert(lines, lineNumber .. ". " .. child.Text)
            lineNumber = lineNumber + 1
        end
    end
    return table.concat(lines, "\n")
end

function hasArtifactInv(artifactName)
    local artifactIDs = {
        ["Arrow Artifact"] = 265,
        ["Crescent Artifact"] = 266,
        ["Diamond Artifact"] = 267,
        ["Hourglass Diamond Artifact"] = 271,
    }
    
    local inventory = (DataStorage.Data:Get({"Inventory"}) or {}).Items or {}
    local artifactId = artifactIDs[artifactName]
    
    if not artifactId then
        return false
    end
    
    for _, item in ipairs(inventory) do
        if item.Id == artifactId then
            return true
        end
    end
    return false
end

function getLeverStatus()
    local jungleInteractions = workspace:FindFirstChild("JUNGLE INTERACTIONS")
    if not jungleInteractions then
        return {}
    end
    
    local leverStatus = {}
    local leverNumber = 1
    
    for _, descendant in ipairs(jungleInteractions:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == "TempleLever" then
            local rootPart = descendant:FindFirstChild("RootPart")
            local proximityPrompt = rootPart and rootPart:FindFirstChildWhichIsA("ProximityPrompt")
            local leverType = descendant:GetAttribute("Type") or "Lever" .. leverNumber
            leverStatus[leverType] = proximityPrompt == nil
            leverNumber = leverNumber + 1
        end
    end
    
    return leverStatus
end

function formatLeverStatus(artifactName, isActive)
    local shortName = ""
    if artifactName == "Hourglass Diamond Artifact" then
        shortName = "Hourglass Diamond"
    elseif artifactName == "Arrow Artifact" then
        shortName = "Arrow"
    elseif artifactName == "Crescent Artifact" then
        shortName = "Crescent"
    else
        shortName = "Diamond"
    end
    
    local color = isActive and "0,255,0" or "255,0,0"
    local statusText = isActive and "ACTIVE" or "DISABLE"
    
    return string.format("%s : <b><font color=\"rgb(%s)\">%s</font></b>", shortName, color, statusText)
end

function triggerLever(artifactName)
    local jungleInteractions = workspace:FindFirstChild("JUNGLE INTERACTIONS")
    if not jungleInteractions then
        return
    end
    
    local leverPrefix = string.match(artifactName, "^(%w+)")
    for _, leverModel in ipairs(jungleInteractions:GetDescendants()) do
        if leverModel:IsA("Model") and leverModel.Name == "TempleLever" then
            local leverType = leverModel:GetAttribute("Type")
            local rootPart = leverModel:FindFirstChild("RootPart")
            local proximityPrompt = rootPart and rootPart:FindFirstChildWhichIsA("ProximityPrompt")
            
            if leverType and string.find(leverType:lower(), leverPrefix:lower()) and proximityPrompt then
                print("[AUTO] Triggering lever:", leverType)
                pcall(function()
                    fireproximityprompt(proximityPrompt)
                end)
                break
            end
        end
    end
end

Panel:AddDropdown({
    Title = "Farming Location",
    Options = {"Kohana Volcano", "Tropical Grove"},
    Default = "Kohana Volcano",
    Callback = function(selected)
        _G.SelectedFarmLocation = selected
    end,
})

Panel:AddToggle({
    Title = "Start Kaitun",
    Default = false,
    Callback = function(enabled)
        _G.KaitunPanel = enabled
        
        if enabled then
            if Services.CoreGui:FindFirstChild("ChloeX_KaitunPanel") then
                Services.CoreGui:FindFirstChild("ChloeX_KaitunPanel"):Destroy()
            end
            
            local kaitunGui = Instance.new("ScreenGui")
            kaitunGui.Name = "ChloeX_KaitunPanel"
            kaitunGui.IgnoreGuiInset = true
            kaitunGui.ResetOnSpawn = false
            kaitunGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            kaitunGui.Parent = Services.CoreGui
            
            local mainCard = Instance.new("Frame", kaitunGui)
            mainCard.Size = UDim2.new(0, 500, 0, 250)
            mainCard.AnchorPoint = Vector2.new(0.5, 0.5)
            mainCard.Position = UDim2.new(0.5, 0, 0.5, 0)
            mainCard.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
            mainCard.BorderSizePixel = 0
            mainCard.Active = true
            mainCard.Draggable = true
            
            local titleLabel = Instance.new("TextLabel", mainCard)
            titleLabel.Size = UDim2.new(1, -20, 0, 36)
            titleLabel.Position = UDim2.new(0, 10, 0, 8)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = "CHLOEX KAITUN PANEL"
            titleLabel.TextSize = 22
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Center
            
            local titleGradient = Instance.new("UIGradient", titleLabel)
            titleGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 90, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
            })
            titleGradient.Rotation = 0
            
            local cardStroke = Instance.new("UIStroke", mainCard)
            cardStroke.Thickness = 2
            cardStroke.Color = Color3.fromRGB(80, 150, 255)
            cardStroke.Transparency = 0.35
            
            Instance.new("UICorner", mainCard).CornerRadius = UDim.new(0, 14)
            
            local userInputService = game:GetService("UserInputService")
            local tweenService = game:GetService("TweenService")
            local isDragging = false
            local isResizing = false
            local dragStartPosition = nil
            local dragStartOffset = nil
            local resizeStartSize = nil
            
            local resizeHandle = Instance.new("ImageButton")
            resizeHandle.Name = "ResizeHandle"
            resizeHandle.Parent = mainCard
            resizeHandle.Size = UDim2.new(0, 24, 0, 24)
            resizeHandle.AnchorPoint = Vector2.new(1, 1)
            resizeHandle.Position = UDim2.new(1, -6, 1, -6)
            resizeHandle.Image = "rbxassetid://6153965696"
            resizeHandle.BackgroundTransparency = 1
            resizeHandle.ZIndex = 10
            resizeHandle.Active = true
            
            local function isMouseButton(input)
                return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
            end
            
            local function setupInputConnection(input, mode)
                local connection
                connection = userInputService.InputChanged:Connect(function(inputChanged)
                    if inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch then
                        if mode == "drag" and isDragging then
                            local delta = inputChanged.Position - dragStartPosition
                            mainCard.Position = UDim2.new(
                                dragStartOffset.X.Scale,
                                dragStartOffset.X.Offset + delta.X,
                                dragStartOffset.Y.Scale,
                                dragStartOffset.Y.Offset + delta.Y
                            )
                        elseif mode == "resize" and isResizing then
                            local delta = inputChanged.Position - dragStartPosition
                            tweenService:Create(mainCard, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                                Size = UDim2.new(
                                    0, math.clamp(resizeStartSize.X.Offset + delta.X, 350, 700),
                                    0, math.clamp(resizeStartSize.Y.Offset + delta.Y, 250, 900)
                                ),
                            }):Play()
                        else
                            connection:Disconnect()
                        end
                    end
                end)
            end
            
            mainCard.InputBegan:Connect(function(input)
                if isMouseButton(input) and not isResizing then
                    isDragging = true
                    dragStartPosition = input.Position
                    dragStartOffset = mainCard.Position
                    setupInputConnection(input, "drag")
                end
            end)
            
            mainCard.InputEnded:Connect(function(input)
                if isMouseButton(input) then
                    isDragging = false
                end
            end)
            
            resizeHandle.InputBegan:Connect(function(input)
                if isMouseButton(input) then
                    isResizing = true
                    resizeStartSize = mainCard.Size
                    dragStartPosition = input.Position
                    setupInputConnection(input, "resize")
                end
            end)
            
            resizeHandle.InputEnded:Connect(function(input)
                if isMouseButton(input) then
                    isResizing = false
                end
            end)
            
            local scrollingFrame = Instance.new("ScrollingFrame", mainCard)
            scrollingFrame.Position = UDim2.new(0, 0, 0, 50)
            scrollingFrame.Size = UDim2.new(1, 0, 1, -60)
            scrollingFrame.BackgroundTransparency = 1
            scrollingFrame.ScrollBarThickness = 0
            scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
            
            local listLayout = Instance.new("UIListLayout", scrollingFrame)
            listLayout.Padding = UDim.new(0, 10)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local function createPanelSection(title, height)
                local titleLabel = Instance.new("TextLabel", scrollingFrame)
                titleLabel.Size = UDim2.new(1, -30, 0, 25)
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextSize = 18
                titleLabel.BackgroundTransparency = 1
                titleLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
                titleLabel.Text = title
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local containerFrame = Instance.new("Frame", scrollingFrame)
                containerFrame.Size = UDim2.new(1, -30, 0, height or 80)
                containerFrame.BackgroundTransparency = 1
                
                local contentLabel = Instance.new("TextLabel", containerFrame)
                contentLabel.Size = UDim2.new(1, 0, 1, 0)
                contentLabel.Font = Enum.Font.Gotham
                contentLabel.TextSize = 16
                contentLabel.BackgroundTransparency = 1
                contentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                contentLabel.TextXAlignment = Enum.TextXAlignment.Left
                contentLabel.TextYAlignment = Enum.TextYAlignment.Top
                contentLabel.TextWrapped = true
                contentLabel.Text = "Loading..."
                contentLabel.RichText = true
                
                return contentLabel
            end
            
            local rodsPanel = createPanelSection("OWNED RODS", 50)
            local baitsPanel = createPanelSection("OWNED BAITS", 50)
            local progressPanel = createPanelSection("FARMING PROGRESS", 40)
            local coinsPanel = createPanelSection("COINS", 30)
            local deepSeaPanel = createPanelSection("DEEP SEA QUEST", 120)
            local artifactPanel = createPanelSection("ARTIFACT QUEST", 120)
            local elementPanel = createPanelSection("ELEMENT QUEST", 120)
            local statusPanel = createPanelSection("FLOW STATUS", 50)
            
            task.spawn(function()
                while _G.KaitunPanel do
                    pcall(function()
                        SellAllEvent:InvokeServer()
                    end)
                    task.wait(180)
                end
            end)
            
            task.spawn(function()
                while true do
                    if _G.KaitunPanel then
                        task.wait(1)
                        
                        if not DataStorage.Data then
                            task.wait(1)
                        else
                            local coins = DataStorage.Data:Get({"Coins"}) or 0
                            coinsPanel.Text = "$" .. tostring(coins)
                            
                            local inventory = DataStorage.Data:Get({"Inventory"}) or {}
                            local ownedRods = {}
                            local ownedBaits = {}
                            
                            for _, rodItem in ipairs(inventory["Fishing Rods"] or {}) do
                                local rodName = getItemNameFromFolder(ItemsFolder, rodItem.Id, "Fishing Rods")
                                if rodName then
                                    table.insert(ownedRods, rodName)
                                end
                            end
                            
                            for _, baitItem in ipairs(inventory.Baits or {}) do
                                local baitName = getItemNameFromFolder(BaitsFolder, baitItem.Id)
                                if baitName then
                                    table.insert(ownedBaits, baitName)
                                end
                            end
                            
                            rodsPanel.Text = #ownedRods > 0 and table.concat(ownedRods, ", ") or "No rods found."
                            baitsPanel.Text = #ownedBaits > 0 and table.concat(ownedBaits, ", ") or "No baits found."
                            
                            deepSeaPanel.Text = readTracker("Deep Sea Tracker")
                            elementPanel.Text = readTracker("Element Tracker")
                            
                            local artifactStatus = {}
                            for _, artifact in ipairs(artifactOrder) do
                                table.insert(artifactStatus, formatLeverStatus(artifact, hasArtifactWorld(artifact)))
                            end
                            artifactPanel.Text = table.concat(artifactStatus, "\n")
                            
                            if not hasRod("Midnight Rod") then
                                statusPanel.Text = "Status: Buying Midnight Rod"
                                if coins >= 53001 then
                                    task.spawn(function()
                                        pcall(function()
                                            Network.Functions.BuyRod:InvokeServer(80)
                                        end)
                                        task.wait(2)
                                        pcall(function()
                                            Network.Functions.BuyBait:InvokeServer(3)
                                        end)
                                    end)
                                else
                                    progressPanel.Text = "Farming coins... (" .. coins .. "/53000)"
                                    statusPanel.Text = "Status: Farming"
                                    TeleportToLocation(Locations[_G.SelectedFarmLocation or "Kohana Volcano"])
                                end
                            else
                                if hasRod("Midnight Rod") and not hasRod("Astral Rod") and coins >= 1000001 then
                                    statusPanel.Text = "Status: Buying Astral Rod"
                                    task.spawn(function()
                                        pcall(function()
                                            Network.Functions.BuyRod:InvokeServer(5)
                                        end)
                                        task.wait(2)
                                        pcall(function()
                                            Network.Functions.BuyBait:InvokeServer(15)
                                        end)
                                    end)
                                end
                                
                                if hasRod("Astral Rod") and not hasBait("Floral Bait") and coins >= 4000001 then
                                    statusPanel.Text = "Status: Buying Floral Bait"
                                    task.spawn(function()
                                        pcall(function()
                                            Network.Functions.BuyBait:InvokeServer(20)
                                        end)
                                    end)
                                end
                                
                                if hasRod("Midnight Rod") and not _G.DeepSeaDone then
                                    statusPanel.Text = "Status: Deep Sea Quest"
                                    local currentPosition = nil
                                    _G.DeepSeaDone = false
                                    
                                    while true do
                                        if not _G.KaitunPanel then break end
                                        if _G.DeepSeaDone then break end
                                        
                                        deepSeaPanel.Text = readTracker("Deep Sea Tracker")
                                        local trackerText = deepSeaPanel.Text:lower()
                                        
                                        local hasTreasureRoom = string.find(trackerText, "treasure room %- 100%%")
                                        local hasSecretFish = string.find(trackerText, "catch 1 secret fish at sisyphus statue %- 100%%")
                                        local hasMythicFish = string.find(trackerText, "catch 3 mythic fish at sisyphus statue %- 100%%")
                                        local hasEarnCoins = string.find(trackerText, "earn 1m coins %- 100%%")
                                        
                                        if hasTreasureRoom and hasSecretFish and hasMythicFish and hasEarnCoins then
                                            _G.DeepSeaDone = true
                                        end
                                        
                                        if not hasTreasureRoom and currentPosition ~= "DeepSea_Start" then
                                            TeleportToLocation(Locations.DeepSea_Start)
                                            currentPosition = "DeepSea_Start"
                                        elseif hasTreasureRoom and (not hasSecretFish or not hasMythicFish) and currentPosition ~= "DeepSea_2" then
                                            TeleportToLocation(Locations.DeepSea_2)
                                            currentPosition = "DeepSea_2"
                                        end
                                        
                                        task.wait(1)
                                    end
                                end
                                
                                if _G.DeepSeaDone and not _G.ArtifactDone then
                                    statusPanel.Text = "Status: Artifact Quest"
                                    _G.ArtifactDone = false
                                    
                                    task.spawn(function()
                                        while _G.KaitunPanel do
                                            if not _G.ArtifactDone then
                                                for _, artifact in ipairs(artifactOrder) do
                                                    if not hasArtifactWorld(artifact) then
                                                        statusPanel.Text = "Status: Collecting " .. artifact
                                                        TeleportToLocation(Locations[artifact])
                                                        
                                                        while true do
                                                            task.wait(2)
                                                            if not hasArtifactInv(artifact) then
                                                                if not hasArtifactWorld(artifact) then
                                                                    if not _G.KaitunPanel then
                                                                        break
                                                                    end
                                                                else
                                                                    break
                                                                end
                                                            else
                                                                break
                                                            end
                                                        end
                                                        
                                                        if hasArtifactInv(artifact) or hasArtifactWorld(artifact) then
                                                            statusPanel.Text = "Status: Triggering " .. artifact
                                                            triggerLever(artifact)
                                                            
                                                            local startTime = tick()
                                                            while true do
                                                                task.wait(1)
                                                                if not hasArtifactWorld(artifact) then
                                                                    if tick() - startTime <= 10 then
                                                                        if not _G.KaitunPanel then
                                                                            break
                                                                        end
                                                                    else
                                                                        break
                                                                    end
                                                                else
                                                                    break
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                                
                                                if hasArtifactWorld("Arrow Artifact") and 
                                                   hasArtifactWorld("Crescent Artifact") and 
                                                   hasArtifactWorld("Hourglass Diamond Artifact") and 
                                                   hasArtifactWorld("Diamond Artifact") then
                                                    _G.ArtifactDone = true
                                                    statusPanel.Text = "Status: Artifact Quest Complete ✅"
                                                end
                                                
                                                task.wait(3)
                                            else
                                                break
                                            end
                                        end
                                    end)
                                end
                                
                                if not _G.ElementDone then
                                    statusPanel.Text = "Status: Element Quest"
                                    _G.ElementDone = false
                                    local currentElementPosition = nil
                                    
                                    while true do
                                        if not _G.KaitunPanel then break end
                                        if _G.ElementDone then break end
                                        
                                        elementPanel.Text = readTracker("Element Tracker")
                                        local trackerText = elementPanel.Text:lower()
                                        
                                        local hasTempleFish = string.find(trackerText, "catch 1 secret fish at sacred temple %- 100%%")
                                        local hasJungleFish = string.find(trackerText, "catch 1 secret fish at ancient jungle %- 100%%")
                                        local hasTranscendedStones = string.find(trackerText, "create 3 transcended stones %- 100%%")
                                        
                                        if hasTempleFish and hasJungleFish and hasTranscendedStones then
                                            _G.ElementDone = true
                                            statusPanel.Text = "Status: Element Quest Complete ✅"
                                        else
                                            if not hasTranscendedStones and currentElementPosition ~= "Element_Stage1" then
                                                TeleportToLocation(Locations.Element_Stage1)
                                                currentElementPosition = "Element_Stage1"
                                            elseif hasTranscendedStones and not hasTempleFish and currentElementPosition ~= "Element_Stage2" then
                                                TeleportToLocation(Locations.Element_Stage2)
                                                currentElementPosition = "Element_Stage2"
                                            elseif hasTranscendedStones and hasTempleFish and not hasJungleFish and currentElementPosition ~= "Element_Final" then
                                                TeleportToLocation(Locations.Element_Final)
                                                currentElementPosition = "Element_Final"
                                            end
                                        end
                                        
                                        task.wait(1)
                                    end
                                end
                            end
                        end
                    else
                        return
                    end
                end
            end)
        else
            _G.KaitunPanel = false
            local existingPanel = Services.CoreGui:FindFirstChild("ChloeX_KaitunPanel")
            if existingPanel then
                existingPanel:Destroy()
            end
        end
    end,
})

Panel:AddToggle({
    Title = "Hide Kaitun Panel",
    Default = false,
    Callback = function(enabled)
        local kaitunPanel = Services.CoreGui:FindFirstChild("ChloeX_KaitunPanel")
        if kaitunPanel then
            local mainCard = kaitunPanel:FindFirstChild("MainCard") or kaitunPanel:FindFirstChildWhichIsA("Frame")
            if mainCard then
                mainCard.Visible = not enabled
            end
        end
    end,
})

local RodPriority = {
    "Element Rod",
    "Ghostfin Rod",
    "Bambo Rod",
    "Angler Rod",
    "Ares Rod",
    "Hazmat Rod",
    "Astral Rod",
    "Midnight Rod"
}

function equipBestRod()
    if not DataStorage.Data then
        return
    end
    
    local inventory = DataStorage.Data:Get({"Inventory"}) or {}
    local fishingRods = inventory["Fishing Rods"] or {}
    local equippedRod = (DataStorage.Data:Get({"EquippedItems"}) or {})["Fishing Rods"]
    
    local bestPriority = math.huge
    local bestRodName = nil
    local bestRodUUID = nil
    
    for _, rodItem in ipairs(fishingRods) do
        local rodName = getItemNameFromFolder(ItemsFolder, rodItem.Id, "Fishing Rods")
        if rodName and rodItem.UUID then
            for priorityIndex, priorityRod in ipairs(RodPriority) do
                if string.find(rodName, priorityRod) and priorityIndex < bestPriority then
                    bestPriority = priorityIndex
                    bestRodName = rodName
                    bestRodUUID = rodItem.UUID
                end
            end
        end
    end
    
    if not bestRodUUID or equippedRod == bestRodUUID then
        return
    end
    
    print("[AUTO EQUIP] Equipping best rod:", bestRodName)
    pcall(function()
        Network.Functions.Cancel:InvokeServer()
        task.wait(0.3)
        Network.Events.REEquipItem:FireServer(bestRodUUID, "Fishing Rods")
    end)
end

Panel:AddToggle({
    Title = "Auto Equip Best Rod",
    Default = false,
    Callback = function(enabled)
        _G.AutoEquipBestRod = enabled
        
        if not enabled then
            return
        end
        
        if not DataStorage.Data then
            return
        end
        
        local inventory = DataStorage.Data:Get({"Inventory"}) or {}
        local fishingRods = inventory["Fishing Rods"] or {}
        local equippedRod = (DataStorage.Data:Get({"EquippedItems"}) or {})["Fishing Rods"]
        
        local bestPriority = math.huge
        local bestRodName = nil
        local bestRodUUID = nil
        
        for _, rodItem in ipairs(fishingRods) do
            local rodName = getItemNameFromFolder(ItemsFolder, rodItem.Id, "Fishing Rods")
            if rodName and rodItem.UUID then
                for priorityIndex, priorityRod in ipairs(RodPriority) do
                    if string.find(rodName, priorityRod) and priorityIndex < bestPriority then
                        bestPriority = priorityIndex
                        bestRodName = rodName
                        bestRodUUID = rodItem.UUID
                    end
                end
            end
        end
        
        if bestRodUUID and equippedRod ~= bestRodUUID then
            print("[AUTO EQUIP] Equipping best rod:", bestRodName)
            pcall(function()
                Network.Functions.Cancel:InvokeServer()
                task.wait(0.3)
                Network.Events.REEquipItem:FireServer(bestRodUUID, "Fishing Rods")
                task.wait(0.3)
                Network.Events.REEquip:FireServer(1)
            end)
        else
            print("[AUTO EQUIP] Already using best rod or none found.")
        end
    end,
})

-- Artifact Lever Location Section (Quest Tab)
local ArtifactSection = Tabs.Quest:AddSection("Artifact Lever Location")

local jungleInteractions = workspace:WaitForChild("JUNGLE INTERACTIONS")
local checkInterval = 1
local isArtifactProgressEnabled = false
local currentArtifactTarget = nil
local activeColor = "0,255,0"
local inactiveColor = "255,0,0"

_G.artifactPositions = {
    ["Arrow Artifact"] = CFrame.new(875, 3, -368) * CFrame.Angles(0, math.rad(90), 0),
    ["Crescent Artifact"] = CFrame.new(1403, 3, 123) * CFrame.Angles(0, math.rad(180), 0),
    ["Hourglass Diamond Artifact"] = CFrame.new(1487, 3, -842) * CFrame.Angles(0, math.rad(180), 0),
    ["Diamond Artifact"] = CFrame.new(1844, 3, -287) * CFrame.Angles(0, math.rad(-90), 0),
}

local artifactOrderList = {
    "Arrow Artifact",
    "Crescent Artifact",
    "Hourglass Diamond Artifact",
    "Diamond Artifact"
}

local function getCurrentLeverStatus()
    local status = {}
    for _, descendant in ipairs(jungleInteractions:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == "TempleLever" then
            local leverType = descendant:GetAttribute("Type")
            local rootPart = descendant:FindFirstChild("RootPart")
            local isActive = rootPart and not rootPart:FindFirstChildWhichIsA("ProximityPrompt")
            status[leverType] = isActive
        end
    end
    return status
end

local function updateArtifactPanel(leverStatus)
    local artifactStatus = {}
    for _, artifact in ipairs(artifactOrderList) do
        local isActive = leverStatus[artifact] or false
        local shortName = ""
        
        if artifact == "Hourglass Diamond Artifact" then
            shortName = "Hourglass Diamond"
        elseif artifact == "Arrow Artifact" then
            shortName = "Arrow"
        elseif artifact == "Crescent Artifact" then
            shortName = "Crescent"
        else
            shortName = "Diamond"
        end
        
        local color = isActive and activeColor or inactiveColor
        local statusText = isActive and "ACTIVE" or "DISABLE"
        
        table.insert(artifactStatus, string.format("%s : <b><font color=\"rgb(%s)\">%s</font></b>", shortName, color, statusText))
    end
    
    ArtifactPanel:SetContent(table.concat(artifactStatus, "\n"))
end

local function activateLever(leverName)
    for _, descendant in ipairs(jungleInteractions:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == "TempleLever" and descendant:GetAttribute("Type") == leverName then
            local rootPart = descendant:FindFirstChild("RootPart")
            local proximityPrompt = rootPart and rootPart:FindFirstChildWhichIsA("ProximityPrompt")
            if proximityPrompt then
                fireproximityprompt(proximityPrompt)
                break
            else
                break
            end
        end
    end
end

local ArtifactPanel = ArtifactSection:AddParagraph({
    Title = "Panel Progress Artifact",
    Content = "\r\nArrow : <b><font color=\"rgb(255,0,0)\">DISABLE</font></b>\r\nCrescent : <b><font color=\"rgb(255,0,0)\">DISABLE</font></b>\r\nHourglass Diamond : <b><font color=\"rgb(255,0,0)\">DISABLE</font></b>\r\nDiamond : <b><font color=\"rgb(255,0,0)\">DISABLE</font></b>\r\n",
})

Network.Events.REFishGot.OnClientEvent:Connect(function(sender, fishData)
    if not isArtifactProgressEnabled or not currentArtifactTarget then
        return
    end
    
    local artifactPrefix = string.split(currentArtifactTarget, " ")[1]
    if artifactPrefix and string.find(fishData or "", artifactPrefix, 1, true) then
        task.wait(0)
        activateLever(currentArtifactTarget)
        currentArtifactTarget = nil
    end
end)

ArtifactSection:AddToggle({
    Title = "Artifact Progress",
    Default = false,
    Callback = function(enabled)
        isArtifactProgressEnabled = enabled
        
        if enabled then
            task.spawn(function()
                while isArtifactProgressEnabled do
                    local leverStatus = getCurrentLeverStatus()
                    local allActive = true
                    
                    for _, status in pairs(leverStatus) do
                        if not status then
                            allActive = false
                            break
                        end
                    end
                    
                    updateArtifactPanel(leverStatus)
                    
                    if allActive then
                        isArtifactProgressEnabled = false
                        break
                    else
                        for _, artifact in ipairs(artifactOrderList) do
                            if not leverStatus[artifact] then
                                currentArtifactTarget = artifact
                                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                                
                                if humanoidRootPart and _G.artifactPositions[artifact] then
                                    humanoidRootPart.CFrame = _G.artifactPositions[artifact]
                                end
                                
                                while currentArtifactTarget and isArtifactProgressEnabled do
                                    task.wait(checkInterval)
                                end
                                
                                if not isArtifactProgressEnabled then
                                    goto label_64
                                end
                            end
                        end
                        task.wait(checkInterval)
                    end
                end
            end)
        end
    end,
})

task.spawn(function()
    while task.wait(checkInterval) do
        updateArtifactPanel(getCurrentLeverStatus())
    end
end)

ArtifactSection:AddButton({
    Title = "Arrow",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = _G.artifactPositions["Arrow Artifact"]
        end
    end,
    SubTitle = "Hourglass Diamond",
    SubCallback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = _G.artifactPositions["Hourglass Diamond Artifact"]
        end
    end,
})

ArtifactSection:AddButton({
    Title = "Crescent",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = _G.artifactPositions["Crescent Artifact"]
        end
    end,
    SubTitle = "Diamond",
    SubCallback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = _G.artifactPositions["Diamond Artifact"]
        end
    end,
})

-- Sisyphus Statue Quest Section
local SisyphusSection = Tabs.Quest:AddSection("Sisyphus Statue Quest")

local DeepSeaPanel = SisyphusSection:AddParagraph({
    Title = "Deep Sea Panel",
    Content = "",
})

SisyphusSection:AddDivider()

SisyphusSection:AddToggle({
    Title = "Auto Deep Sea Quest",
    Content = "Automatically complete Deep Sea Quest!",
    Default = false,
    Callback = function(enabled)
        Settings.autoDeepSea = enabled
        
        task.spawn(function()
            while Settings.autoDeepSea do
                local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
                local deepSeaTracker = menuRings and menuRings:FindFirstChild("Deep Sea Tracker")
                
                if deepSeaTracker then
                    local content = deepSeaTracker:FindFirstChild("Board") and deepSeaTracker.Board:FindFirstChild("Gui") and deepSeaTracker.Board.Gui:FindFirstChild("Content")
                    
                    if content then
                        local firstLabel = nil
                        for _, child in ipairs(content:GetChildren()) do
                            if child:IsA("TextLabel") and child.Name ~= "Header" then
                                firstLabel = child
                                break
                            end
                        end
                        
                        if firstLabel then
                            local labelText = string.lower(firstLabel.Text)
                            local humanoidRootPart = Settings.player.Character and Settings.player.Character:FindFirstChild("HumanoidRootPart")
                            
                            if humanoidRootPart then
                                if string.find(labelText, "100%%") then
                                    humanoidRootPart.CFrame = CFrame.new(-3763, -135, -995) * CFrame.Angles(0, math.rad(180), 0)
                                else
                                    humanoidRootPart.CFrame = CFrame.new(-3599, -276, -1641)
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end,
})

SisyphusSection:AddButton({
    Title = "Treasure Room",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(-3601, -283, -1611)
        end
    end,
    SubTitle = "Sisyphus Statue",
    SubCallback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(-3698, -135, -1008)
        end
    end,
})

-- Element Quest Section
local ElementSection = Tabs.Quest:AddSection("Element Quest")

local ElementPanel = ElementSection:AddParagraph({
    Title = "Element Panel",
    Content = "",
})

ElementSection:AddDivider()

ElementSection:AddToggle({
    Title = "Auto Element Quest",
    Content = "Automatically teleport through Element quest stages.",
    Default = false,
    Callback = function(enabled)
        Settings.autoElement = enabled
        
        task.spawn(function()
            while Settings.autoElement do
                local humanoidRootPart = Settings.player.Character and Settings.player.Character:FindFirstChild("HumanoidRootPart")
                local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
                local elementTracker = menuRings and menuRings:FindFirstChild("Element Tracker")
                
                if humanoidRootPart and elementTracker then
                    local board = elementTracker:FindFirstChild("Board")
                    local gui = board and board:FindFirstChild("Gui")
                    local content = gui and gui:FindFirstChild("Content")
                    
                    if content then
                        local lines = {}
                        for _, child in ipairs(content:GetChildren()) do
                            if child:IsA("TextLabel") and child.Name ~= "Header" then
                                table.insert(lines, string.lower(child.Text))
                            end
                        end
                        
                        if #lines >= 4 then
                            local templeFish = lines[2]
                            local jungleFish = lines[4]
                            
                            if not string.find(jungleFish, "100%%") then
                                local position = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0)
                                humanoidRootPart.CFrame = position
                                goto continue_loop
                            elseif string.find(jungleFish, "100%%") and not string.find(templeFish, "100%%") then
                                local position = CFrame.new(1453, -22, -636)
                                humanoidRootPart.CFrame = position
                                goto continue_loop
                            elseif string.find(templeFish, "100%%") then
                                local position = CFrame.new(1480, 128, -593)
                                humanoidRootPart.CFrame = position
                                Settings.autoElement = false
                                ElementPanel:SetContent("Element Quest Completed!")
                                break
                            end
                        end
                    end
                end
                
                ::continue_loop::
                task.wait(1)
            end
        end)
    end,
})

ElementSection:AddButton({
    Title = "Secred Temple",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(1453, -22, -636)
        end
    end,
    SubTitle = "Underground Cellar",
    SubCallback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(2136, -91, -701)
        end
    end,
})

ElementSection:AddButton({
    Title = "Transcended Stones",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(1480, 128, -593)
        end
    end,
})

function getTrackerContent(trackerName)
    local tracker = workspace["!!! MENU RINGS"]:FindFirstChild(trackerName)
    if not tracker then
        return ""
    end
    
    local content = tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui") and tracker.Board.Gui:FindFirstChild("Content")
    if not content then
        return ""
    end
    
    local lines = {}
    local lineNumber = 1
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("TextLabel") and child.Name ~= "Header" then
            table.insert(lines, lineNumber .. ". " .. child.Text)
            lineNumber = lineNumber + 1
        end
    end
    return table.concat(lines, "\n")
end

task.spawn(function()
    while task.wait(2) do
        ElementPanel:SetContent(getTrackerContent("Element Tracker"))
        DeepSeaPanel:SetContent(getTrackerContent("Deep Sea Tracker"))
    end
end)

-- Auto Progress Quest Features Section
local QuestProgressSection = Tabs.Quest:AddSection("Auto Progress Quest Features")

local QuestProgressPanel = QuestProgressSection:AddParagraph({
    Title = "Progress Quest Panel",
    Content = "Waiting for start...",
})

QuestProgressSection:AddToggle({
    Title = "Auto Teleport Quest",
    Default = false,
    Callback = function(enabled)
        Settings.autoQuestFlow = enabled
        
        task.spawn(function()
            local deepSeaCompleted = false
            local artifactCompleted = false
            local elementCompleted = false
            local completedStages = {
                Deep = false,
                Lever = false,
                Element = false,
            }
            
            local function updateProgressContent(content)
                if QuestProgressPanel and QuestProgressPanel.SetContent then
                    QuestProgressPanel:SetContent(content)
                end
            end
            
            while Settings.autoQuestFlow and (not deepSeaCompleted or not artifactCompleted or not elementCompleted) do
                -- Deep Sea Quest
                if not deepSeaCompleted then
                    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
                    local deepSeaTracker = menuRings and menuRings:FindFirstChild("Deep Sea Tracker")
                    local content = deepSeaTracker and deepSeaTracker:FindFirstChild("Board") and deepSeaTracker.Board:FindFirstChild("Gui") and deepSeaTracker.Board.Gui:FindFirstChild("Content")
                    
                    local allComplete = true
                    local completedCount = 0
                    local totalCount = 0
                    
                    if content then
                        for _, child in ipairs(content:GetChildren()) do
                            if child:IsA("TextLabel") and child.Name ~= "Header" then
                                totalCount = totalCount + 1
                                if string.find(child.Text, "100%%") then
                                    completedCount = completedCount + 1
                                else
                                    allComplete = false
                                end
                            end
                        end
                    end
                    
                    local progressPercent = totalCount > 0 and math.floor(completedCount / totalCount * 100) or 0
                    updateProgressContent(string.format("Doing objective on Deep Sea Quest...\nProgress now %d%%.", progressPercent))
                    
                    if not allComplete and not completedStages.Deep then
                        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            humanoidRootPart.CFrame = CFrame.new(-3599, -276, -1641)
                            completedStages.Deep = true
                        end
                    elseif allComplete then
                        deepSeaCompleted = true
                        updateProgressContent("Deep Sea Quest Completed!\nProceeding to Artifact Lever...")
                    end
                    
                    task.wait(1)
                end
                
                -- Artifact Lever Quest
                if deepSeaCompleted and not artifactCompleted then
                    if Settings.autoQuestFlow then
                        local leverStatus = getCurrentLeverStatus()
                        local allLeversActive = true
                        
                        for _, isActive in pairs(leverStatus) do
                            if not isActive then
                                allLeversActive = false
                                break
                            end
                        end
                        
                        if not allLeversActive and not completedStages.Lever then
                            local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart and _G.artifactPositions["Arrow Artifact"] then
                                humanoidRootPart.CFrame = _G.artifactPositions["Arrow Artifact"]
                                completedStages.Lever = true
                            end
                            updateProgressContent("Doing objective on Artifact Lever...\nProgress now 75%.")
                        elseif allLeversActive then
                            artifactCompleted = true
                            updateProgressContent("Artifact Lever Completed!\nProceeding to Element Quest...")
                        end
                        task.wait(1)
                    end
                end
                
                -- Element Quest
                if deepSeaCompleted and artifactCompleted and not elementCompleted then
                    if Settings.autoQuestFlow then
                        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
                        local elementTracker = menuRings and menuRings:FindFirstChild("Element Tracker")
                        local content = elementTracker and elementTracker:FindFirstChild("Board") and elementTracker.Board:FindFirstChild("Gui") and elementTracker.Board.Gui:FindFirstChild("Content")
                        
                        if content then
                            local lines = {}
                            for _, child in ipairs(content:GetChildren()) do
                                if child:IsA("TextLabel") and child.Name ~= "Header" then
                                    table.insert(lines, child.Text)
                                end
                            end
                            
                            local templeFish = lines[2] and string.lower(lines[2]) or ""
                            local jungleFish = lines[4] and string.lower(lines[4]) or ""
                            local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if not string.find(templeFish, "100%%") or not string.find(jungleFish, "100%%") then
                                if not completedStages.Element and humanoidRootPart then
                                    humanoidRootPart.CFrame = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0)
                                    completedStages.Element = true
                                end
                                
                                if not string.find(jungleFish, "100%%") then
                                    updateProgressContent("Doing objective on Element Quest...\nProgress now 50%.")
                                elseif string.find(jungleFish, "100%%") and not string.find(templeFish, "100%%") then
                                    humanoidRootPart.CFrame = CFrame.new(1453, -22, -636)
                                    updateProgressContent("Doing objective on Element Quest...\nProgress now 75%.")
                                end
                            else
                                elementCompleted = true
                                updateProgressContent("All Quest Completed Successfully! :3")
                                Settings.autoQuestFlow = false
                            end
                        end
                        task.wait(1)
                    end
                end
            end
        end)
    end,
})

-- Crystalline Passage Features Section
local CrystallineSection = Tabs.Quest:AddSection("Crystalline Pessage Features")

local ruinInteractions = workspace:FindFirstChild("RUIN INTERACTIONS")
local rarityTypes = {"Rare", "Epic", "Legendary", "Mythic"}
local FishTargetIDs = {
    Rare = 284,
    Epic = 270,
    Legendary = 283,
    Mythic = 263,
}

local PressurePlatePanel = CrystallineSection:AddParagraph({
    Title = "Panel Ancient Ruin",
    Content = "Checking...",
})

task.spawn(function()
    while task.wait(1) do
        if ruinInteractions then
            local pressurePlates = ruinInteractions:FindFirstChild("PressurePlates")
            if pressurePlates then
                local rarePrompt = pressurePlates:FindFirstChild("Rare") and pressurePlates.Rare.Part:FindFirstChild("ProximityPrompt")
                local epicPrompt = pressurePlates:FindFirstChild("Epic") and pressurePlates.Epic.Part:FindFirstChild("ProximityPrompt")
                local legendaryPrompt = pressurePlates:FindFirstChild("Legendary") and pressurePlates.Legendary.Part:FindFirstChild("ProximityPrompt")
                local mythicPrompt = pressurePlates:FindFirstChild("Mythic") and pressurePlates.Mythic.Part:FindFirstChild("ProximityPrompt")
                
                local rareStatus = rarePrompt and "<b>Active</b>" or "<b>Disable</b>"
                local epicStatus = epicPrompt and "<b>Active</b>" or "<b>Disable</b>"
                local legendaryStatus = legendaryPrompt and "<b>Active</b>" or "<b>Disable</b>"
                local mythicStatus = mythicPrompt and "<b>Active</b>" or "<b>Disable</b>"
                
                PressurePlatePanel:SetContent(string.format("Rare : %s\nEpic : %s\nLegendary : %s\nMythic : %s", 
                    rareStatus, epicStatus, legendaryStatus, mythicStatus))
            else
                PressurePlatePanel:SetContent("<font color='rgb(255,69,0)'>PressurePlates folder not found!</font>")
            end
        else
            PressurePlatePanel:SetContent("<font color='rgb(255,69,0)'>PressurePlates folder not found!</font>")
        end
    end
end)

CrystallineSection:AddToggle({
    Title = "Auto Ancient Ruin",
    Default = false,
    Callback = function(enabled)
        Settings.triggerRuin = enabled
        
        task.spawn(function()
            while Settings.triggerRuin do
                local inventory = DataStorage.Data:GetExpect({"Inventory", "Items"})
                
                if ruinInteractions and ruinInteractions:FindFirstChild("PressurePlates") then
                    local pressurePlates = ruinInteractions.PressurePlates
                    
                    for _, rarity in ipairs(rarityTypes) do
                        local targetFishId = FishTargetIDs[rarity]
                        local hasFish = false
                        
                        for _, item in ipairs(inventory) do
                            if item.Id == targetFishId then
                                hasFish = true
                                break
                            end
                        end
                        
                        if hasFish then
                            local rarityPlate = pressurePlates:FindFirstChild(rarity)
                            local platePart = rarityPlate and rarityPlate:FindFirstChild("Part")
                            local proximityPrompt = platePart and platePart:FindFirstChild("ProximityPrompt")
                            
                            if proximityPrompt then
                                fireproximityprompt(proximityPrompt)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end,
})

-- Classic Event Features [BETA] Section
local ClassicEventSection = Tabs.Quest:AddSection("Classic Event Features [BETA]")

local RequiredFish = {
    "Builderman Guppy",
    "Brighteyes Guppy",
    "Shedletsky Guppy",
    "Guest Guppy"
}

local ClassicFishIDs = {
    ["Builderman Guppy"] = 434,
    ["Brighteyes Guppy"] = 435,
    ["Shedletsky Guppy"] = 415,
    ["Guest Guppy"] = 422,
}
local ClassicEventSection = Tabs.Quest:AddSection("Classic Event Features [BETA]")

local ClassicFishRootTargets = {
    ["Brighteyes Guppy"] = CFrame.new(-8865.5, -580.75, 174.225006, -0.00000011920929, 0, -1, 0, 1, 0, 1, 0, -0.00000011920929),
    ["Builderman Guppy"] = CFrame.new(-8771, -580.75, 174),
    ["Shedletsky Guppy"] = CFrame.new(-8729, -580.75, 174),
    ["Guest Guppy"] = CFrame.new(-8689, -580.75, 174),
}

local function getRequiredFishNames()
    local fishNames = {}
    for _, fishName in ipairs(RequiredFish) do
        table.insert(fishNames, fishName)
    end
    return fishNames
end

ClassicEventSection:AddDropdown({
    Title = "Select Fish to Catch",
    Options = getRequiredFishNames(),
    Multi = false,
    Callback = function(selected)
        Settings.selectedClassicFish = selected
    end,
})

ClassicEventSection:AddToggle({
    Title = "Auto Catch Classic Fish",
    Default = false,
    Callback = function(enabled)
        Settings.autoCatchClassic = enabled
        
        if enabled then
            task.spawn(function()
                while Settings.autoCatchClassic do
                    local selectedFish = Settings.selectedClassicFish
                    if not selectedFish then
                        task.wait(1)
                        goto continue
                    end
                    
                    local fishId = ClassicFishIDs[selectedFish]
                    if not fishId then
                        task.wait(1)
                        goto continue
                    end
                    
                    -- Check if already has the fish
                    local hasFish = false
                    local inventory = DataStorage.Data:GetExpect({"Inventory", "Items"}) or {}
                    for _, item in ipairs(inventory) do
                        if item.Id == fishId then
                            hasFish = true
                            break
                        end
                    end
                    
                    if not hasFish then
                        local teleportPosition = ClassicFishRootTargets[selectedFish]
                        if teleportPosition then
                            local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
                            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                humanoidRootPart.CFrame = teleportPosition
                            end
                        end
                    else
                        Settings.autoCatchClassic = false
                        chloex("Already have " .. selectedFish)
                        break
                    end
                    
                    ::continue::
                    task.wait(5)
                end
            end)
        end
    end,
})

ClassicEventSection:AddButton({
    Title = "Teleport to Classic Event",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(1173, 4, 2839)
        end
    end,
})

-- Teleport Section
local TeleportSection = Tabs.Tele:AddSection("Teleport Locations")

TeleportSection:AddDropdown({
    Title = "Select Location",
    Options = locationNames,
    Multi = false,
    Callback = function(selected)
        Settings.selectedTeleportLocation = selected
    end,
})

TeleportSection:AddButton({
    Title = "Teleport",
    Callback = function()
        local selectedLocation = Settings.selectedTeleportLocation
        if selectedLocation and TeleportLocations[selectedLocation] then
            local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(TeleportLocations[selectedLocation])
                chloex("Teleported to " .. selectedLocation)
            end
        end
    end,
})

TeleportSection:AddButton({
    Title = "Copy Current Position",
    Callback = function()
        local character = Settings.player.Character or Settings.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local positionString = string.format("%.1f, %.1f, %.1f", 
                humanoidRootPart.Position.X, 
                humanoidRootPart.Position.Y, 
                humanoidRootPart.Position.Z)
            
            if setclipboard then
                setclipboard(positionString)
                chloex("Position copied to clipboard!")
            end
        end
    end,
})

-- Webhook Section
local WebhookSection = Tabs.Webhook:AddSection("Webhook Settings")

WebhookSection:AddInput({
    Title = "Webhook URL",
    Placeholder = "Enter your Discord webhook URL",
    Callback = function(input)
        _G.WebhookURL = input
        SaveConfig()
    end,
})

WebhookSection:AddToggle({
    Title = "Enable Webhook Notifications",
    Default = false,
    Callback = function(enabled)
        _G.WebhookEnabled = enabled
        SaveConfig()
    end,
})

WebhookSection:AddDropdown({
    Title = "Select Rarities to Notify",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = true,
    Callback = function(selected)
        _G.WebhookRarities = toSet(selected)
        SaveConfig()
    end,
})

WebhookSection:AddDropdown({
    Title = "Select Fish Names to Notify",
    Options = FishNames,
    Multi = true,
    Callback = function(selected)
        _G.WebhookNames = toSet(selected)
        SaveConfig()
    end,
})

local function sendWebhookNotification(fishName, rarity, variant, size, value)
    if not _G.WebhookEnabled or not _G.WebhookURL or _G.WebhookURL == "" then
        return
    end
    
    local shouldNotify = false
    
    -- Check if rarity should be notified
    if _G.WebhookRarities and next(_G.WebhookRarities) then
        if _G.WebhookRarities[rarity] then
            shouldNotify = true
        end
    end
    
    -- Check if fish name should be notified
    if _G.WebhookNames and next(_G.WebhookNames) then
        if _G.WebhookNames[fishName] then
            shouldNotify = true
        end
    end
    
    if not shouldNotify then
        return
    end
    
    local embed = {
        title = "🎣 New Fish Caught!",
        description = string.format("**%s**\nRarity: %s\nVariant: %s\nSize: %.2f\nValue: $%d", 
            fishName, rarity, variant or "Normal", size or 0, value or 0),
        color = 0x00FF00,
        timestamp = DateTime.now():ToIsoDate(),
        footer = {
            text = "Chloe X FishIt",
            icon_url = "https://i.imgur.com/4M34hi2.png"
        }
    }
    
    local data = {
        embeds = {embed}
    }
    
    pcall(function()
        local jsonData = Services.HttpService:JSONEncode(data)
        syn.request({
            Url = _G.WebhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)
end

-- Connect webhook to fishing event
Network.Events.REFishGot.OnClientEvent:Connect(function(sender, fishData)
    if fishData and fishData.Id then
        local itemData = GameModules.ItemUtility.GetItemDataFromItemType("Items", fishData.Id)
        if itemData and itemData.Data then
            local fishName = itemData.Data.Name or "Unknown"
            local rarity = _G.TierFish[itemData.Data.Tier] or "Unknown"
            local variant = fishData.Metadata and fishData.Metadata.VariantId or "Normal"
            local size = fishData.Size or 0
            local value = fishData.Value or 0
            
            sendWebhookNotification(fishName, rarity, variant, size, value)
        end
    end
end)

-- Misc Section
local MiscSection = Tabs.Misc:AddSection("Miscellaneous Features")

MiscSection:AddButton({
    Title = "Save Configuration",
    Callback = function()
        SaveConfig()
        chloex("Configuration saved!")
    end,
})

MiscSection:AddButton({
    Title = "Load Configuration",
    Callback = function()
        LoadConfig()
        chloex("Configuration loaded!")
    end,
})

MiscSection:AddButton({
    Title = "Reset Configuration",
    Callback = function()
        _G.Delay = 1
        _G.DelayComplete = 0.5
        _G.Reel = 1.9
        _G.FishingDelay = 1.1
        _G.FBlatant = false
        _G.AutoAccept = false
        _G.WebhookURL = ""
        _G.WebhookEnabled = false
        _G.WebhookRarities = {}
        _G.WebhookNames = {}
        
        SaveConfig()
        chloex("Configuration reset to defaults!")
    end,
})

MiscSection:AddToggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(enabled)
        if enabled then
            local virtualInputManager = game:GetService("VirtualInputManager")
            Settings.antiAFKConnection = Services.RunService.Heartbeat:Connect(function()
                virtualInputManager:SendKeyEvent(true, "W", false, game)
                virtualInputManager:SendKeyEvent(false, "W", false, game)
            end)
        else
            if Settings.antiAFKConnection then
                Settings.antiAFKConnection:Disconnect()
                Settings.antiAFKConnection = nil
            end
        end
    end,
})

MiscSection:AddToggle({
    Title = "Hide GUI",
    Default = false,
    Callback = function(enabled)
        if MainWindow then
            MainWindow.Enabled = not enabled
        end
    end,
})

MiscSection:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        local teleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local jobId = game.JobId
        
        teleportService:Teleport(placeId, LocalPlayer)
    end,
})

MiscSection:AddButton({
    Title = "Server Hop",
    Callback = function()
        local httpService = game:GetService("HttpService")
        local teleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        
        local servers = {}
        local success, response = pcall(function()
            return httpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)
        
        if success and response.data then
            for _, server in ipairs(response.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
            
            if #servers > 0 then
                local randomServer = servers[math.random(1, #servers)]
                teleportService:TeleportToPlaceInstance(placeId, randomServer.id, LocalPlayer)
            else
                chloex("No available servers found!")
            end
        end
    end,
})

-- Configuration Functions
function SaveConfig()
    local config = {
        Delay = _G.Delay,
        DelayComplete = _G.DelayComplete,
        Reel = _G.Reel,
        FishingDelay = _G.FishingDelay,
        FBlatant = _G.FBlatant,
        AutoAccept = _G.AutoAccept,
        WebhookURL = _G.WebhookURL or "",
        WebhookEnabled = _G.WebhookEnabled or false,
        WebhookRarities = _G.WebhookRarities or {},
        WebhookNames = _G.WebhookNames or {},
    }
    
    local success, err = safeWriteFile("ChloeX_Config.json", Services.HttpService:JSONEncode(config))
    if success then
        print("[CONFIG] Saved successfully")
    else
        print("[CONFIG] Save failed, using memory:", err)
        _G.ChloeX_Config_Memory = config
    end
end

function LoadConfig()
    local success, content = safeReadFile("ChloeX_Config.json")
    if success then
        local config = Services.HttpService:JSONDecode(content)
        _G.Delay = config.Delay or 1
        _G.DelayComplete = config.DelayComplete or 0.5
        _G.Reel = config.Reel or 1.9
        _G.FishingDelay = config.FishingDelay or 1.1
        _G.FBlatant = config.FBlatant or false
        _G.AutoAccept = config.AutoAccept or false
        _G.WebhookURL = config.WebhookURL or ""
        _G.WebhookEnabled = config.WebhookEnabled or false
        _G.WebhookRarities = config.WebhookRarities or {}
        _G.WebhookNames = config.WebhookNames or {}
        print("[CONFIG] Loaded from file")
    elseif _G.ChloeX_Config_Memory then
        local config = _G.ChloeX_Config_Memory
        _G.Delay = config.Delay or 1
        _G.DelayComplete = config.DelayComplete or 0.5
        _G.Reel = config.Reel or 1.9
        _G.FishingDelay = config.FishingDelay or 1.1
        _G.FBlatant = config.FBlatant or false
        _G.AutoAccept = config.AutoAccept or false
        _G.WebhookURL = config.WebhookURL or ""
        _G.WebhookEnabled = config.WebhookEnabled or false
        _G.WebhookRarities = config.WebhookRarities or {}
        _G.WebhookNames = config.WebhookNames or {}
        print("[CONFIG] Loaded from memory")
    else
        print("[CONFIG] No config found, using defaults")
    end
end


-- Auto-load configuration on start
task.spawn(function()
    task.wait(2)
    LoadConfig()
end)

-- Initialize UI Updates
task.spawn(function()
    while task.wait(1) do
        -- Update coins display
        if DataStorage.Data then
            local coins = DataStorage.Data:Get({"Coins"}) or 0
            if Tabs.Info then
                -- Update info tab if it exists
            end
        end
    end
end)

-- Notify user that script is loaded
task.wait(2)
chloex("Chloe X FishIt v1.0.8 - Fixed Version Loaded! 🎣")
print("==========================================")
print("CHLOE X FISHIT - READY")
print("Fixed Issues:")
print("1. ✓ chloex() function added")
print("2. ✓ Global variables initialized")
print("3. ✓ Safe file operations")
print("4. ✓ Config functions fixed")
print("5. ✓ MiniEvent handling fixed")
print("==========================================")

return Settings