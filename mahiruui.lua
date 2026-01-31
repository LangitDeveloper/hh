-- WindUI - Complete UI Library v2.0
-- Full version with ALL features

local WindUI = {}

-- Cache system
WindUI.cache = {}

function WindUI.load(module)
    if not WindUI.cache[module] then
        WindUI.cache[module] = WindUI[module]()
    end
    return WindUI.cache[module]
end

--[[ MODULE A: Theme Fallbacks ]]--
function WindUI.a()
    return {
        White = Color3.new(1,1,1),
        Black = Color3.new(0,0,0),
        
        Dialog = "Accent",
        Background = "Accent",
        BackgroundTransparency = 0,
        Hover = "Text",
        
        WindowBackground = "Background",
        WindowShadow = "Black",
        
        WindowTopbarTitle = "Text",
        WindowTopbarAuthor = "Text",
        WindowTopbarIcon = "Icon",
        WindowTopbarButtonIcon = "Icon",
        
        TabBackground = "Hover",
        TabTitle = "Text",
        TabIcon = "Icon",
        
        ElementBackground = "Text",
        ElementTitle = "Text",
        ElementDesc = "Text",
        ElementIcon = "Icon",
        
        PopupBackground = "Background",
        PopupBackgroundTransparency = "BackgroundTransparency",
        PopupTitle = "Text",
        PopupContent = "Text",
        PopupIcon = "Icon",
        
        DialogBackground = "Background",
        DialogBackgroundTransparency = "BackgroundTransparency",
        DialogTitle = "Text",
        DialogContent = "Text",
        DialogIcon = "Icon",
        
        Toggle = "Button",
        Checkbox = "Button",
        CheckboxIcon = "White",
    }
end

--[[ MODULE B: Core Engine ]]--
function WindUI.b()
    local module = {}
    
    -- Services
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local LocalizationService = game:GetService("LocalizationService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local TextService = game:GetService("TextService")
    
    -- Icons System
    local iconsUrl = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
    local Icons = loadstring(
        game.HttpGetAsync and game:HttpGetAsync(iconsUrl) or HttpService:GetAsync(iconsUrl)
    )()
    Icons.SetIconsType("lucide")
    
    -- Configuration
    module.Config = {
        Font = "rbxassetid://12187365364",
        Localization = nil,
        CanDraggable = true,
        Theme = nil,
        Themes = nil,
        Icons = Icons,
        Signals = {},
        Objects = {},
        LocalizationObjects = {},
        FontObjects = {},
        Language = string.match(LocalizationService.SystemLocaleId, "^[a-z]+"),
        Request = http_request or (syn and syn.request) or request,
        
        DefaultProperties = {
            ScreenGui = {ResetOnSpawn = false, ZIndexBehavior = "Sibling"},
            Frame = {BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1)},
            TextLabel = {
                BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Text = "",
                RichText = true, TextColor3 = Color3.new(1,1,1), TextSize = 14,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular)
            },
            TextButton = {
                BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Text = "",
                AutoButtonColor = false, TextColor3 = Color3.new(1,1,1), TextSize = 14,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular)
            },
            TextBox = {
                BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0,
                ClearTextOnFocus = false, Text = "", TextColor3 = Color3.new(0,0,0), TextSize = 14,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular)
            },
            ImageLabel = {BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0},
            ImageButton = {BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, AutoButtonColor = false},
            UIListLayout = {SortOrder = "LayoutOrder"},
            UIPadding = {PaddingTop = UDim.new(0,0), PaddingBottom = UDim.new(0,0), PaddingLeft = UDim.new(0,0), PaddingRight = UDim.new(0,0)},
            UICorner = {CornerRadius = UDim.new(0,0)},
            ScrollingFrame = {BorderSizePixel = 0, BackgroundTransparency = 1, ScrollBarThickness = 0, ScrollBarImageTransparency = 1},
            VideoFrame = {BorderSizePixel = 0},
        },
        
        Colors = {
            Red = "#e53935", Orange = "#f57c00", Green = "#43a047", Blue = "#039be5",
            White = "#ffffff", Grey = "#484848", Purple = "#8a2be2", Pink = "#e91e63",
            Yellow = "#ffeb3b", Cyan = "#00bcd4",
        },
        
        ThemeFallbacks = WindUI.load('a'),
        
        Shapes = {
            Square = "rbxassetid://82909646051652",
            ["Square-Outline"] = "rbxassetid://72946211851948",
            Squircle = "rbxassetid://80999662900595",
            SquircleOutline = "rbxassetid://117788349049947",
            ["Squircle-Outline"] = "rbxassetid://117817408534198",
            ["Shadow-sm"] = "rbxassetid://84825982946844",
            ["Squircle-TL-TR"] = "rbxassetid://73569156276236",
            ["Squircle-BL-BR"] = "rbxassetid://93853842912264",
            ["Squircle-TL-TR-Outline"] = "rbxassetid://136702870075563",
            ["Squircle-BL-BR-Outline"] = "rbxassetid://75035847706564",
        }
    }
    
    local currentWindow
    
    function module.Init(window)
        currentWindow = window
    end
    
    function module.New(className, properties, children)
        local instance = Instance.new(className)
        
        if module.Config.DefaultProperties[className] then
            for property, value in pairs(module.Config.DefaultProperties[className]) do
                if instance[property] ~= nil then
                    instance[property] = value
                end
            end
        end
        
        if properties then
            for property, value in pairs(properties) do
                if property ~= "ThemeTag" and instance[property] ~= nil then
                    instance[property] = value
                end
            end
        end
        
        if children then
            for _, child in pairs(children) do
                if child then child.Parent = instance end
            end
        end
        
        if properties and properties.ThemeTag then
            module.AddThemeObject(instance, properties.ThemeTag)
        end
        
        if properties and properties.FontFace then
            module.AddFontObject(instance)
        end
        
        return instance
    end
    
    function module.Tween(object, duration, properties, easingStyle, easingDirection)
        easingStyle = easingStyle or Enum.EasingStyle.Quad
        easingDirection = easingDirection or Enum.EasingDirection.Out
        return TweenService:Create(object, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    end
    
    function module.NewRoundFrame(cornerRadius, shapeType, properties, children, isButton)
        local imageId = module.Config.Shapes[shapeType] or module.Config.Shapes.Squircle
        local isShadow = shapeType == "Shadow-sm"
        
        local frame = module.New(isButton and "ImageButton" or "ImageLabel", {
            Image = imageId,
            ScaleType = "Slice",
            SliceCenter = isShadow and Rect.new(512,512,512,512) or Rect.new(256,256,256,256),
            BackgroundTransparency = 1,
            ThemeTag = properties and properties.ThemeTag,
        }, children)
        
        if properties then
            for key, value in pairs(properties) do
                if key ~= "ThemeTag" and frame[key] ~= nil then
                    frame[key] = value
                end
            end
        end
        
        local function updateSliceScale(radius)
            local scale = isShadow and (radius/512) or (radius/256)
            frame.SliceScale = math.max(scale, 0.0001)
        end
        
        updateSliceScale(cornerRadius or 10)
        return frame
    end
    
    function module.AddSignal(connection, callback)
        local signal = connection:Connect(callback)
        table.insert(module.Config.Signals, signal)
        return signal
    end
    
    function module.DisconnectAll()
        for _, signal in ipairs(module.Config.Signals) do
            pcall(function() signal:Disconnect() end)
        end
        module.Config.Signals = {}
    end
    
    function module.SafeCallback(callback, ...)
        if not callback then return end
        local success, result = pcall(callback, ...)
        if not success and currentWindow and currentWindow.Debug then
            warn("[WindUI: DEBUG Mode] " .. tostring(result))
            if currentWindow.Notify then
                currentWindow:Notify({Title = "DEBUG Mode: Error", Content = result, Duration = 8})
            end
        end
        return success, result
    end
    
    function module.Icon(iconName, themed)
        return Icons.Icon(iconName, nil, themed ~= false)
    end
    
    function module.AddThemeObject(object, properties)
        module.Config.Objects[object] = {Object = object, Properties = properties}
        module.UpdateTheme(object, false)
    end
    
    function module.UpdateTheme(specificObject, instant)
        local function applyTheme(objData)
            for property, themeKey in pairs(objData.Properties or {}) do
                local value = module.GetThemeProperty(themeKey, module.Config.Theme)
                if value ~= nil then
                    if typeof(value) == "Color3" then
                        local gradient = objData.Object:FindFirstChild("WindUIGradient")
                        if gradient then gradient:Destroy() end
                        if not instant then
                            objData.Object[property] = value
                        else
                            module.Tween(objData.Object, 0.08, {[property] = value}):Play()
                        end
                    elseif typeof(value) == "table" and value.Color and value.Transparency then
                        objData.Object[property] = Color3.new(1,1,1)
                        local gradient = objData.Object:FindFirstChild("WindUIGradient") or module.New("UIGradient")
                        gradient.Name = "WindUIGradient"
                        gradient.Parent = objData.Object
                        gradient.Color = value.Color
                        gradient.Transparency = value.Transparency
                    elseif typeof(value) == "number" then
                        if not instant then
                            objData.Object[property] = value
                        else
                            module.Tween(objData.Object, 0.08, {[property] = value}):Play()
                        end
                    end
                end
            end
        end
        
        if specificObject then
            local objData = module.Config.Objects[specificObject]
            if objData then applyTheme(objData) end
        else
            for _, objData in pairs(module.Config.Objects) do
                applyTheme(objData)
            end
        end
    end
    
    function module.GetThemeProperty(property, theme)
        local function getValue(key, source)
            if not source then return nil end
            local value = source[key]
            if value == nil then return nil end
            
            if typeof(value) == "string" then
                if string.sub(value, 1, 1) == "#" then
                    return Color3.fromHex(value)
                elseif module.Config.ThemeFallbacks[value] then
                    return getValue(value, module.Config.ThemeFallbacks)
                end
            end
            
            if typeof(value) == "function" then
                return value()
            end
            
            return value
        end
        
        if theme then
            local value = getValue(property, theme)
            if value ~= nil then return value end
        end
        
        local fallback = module.Config.ThemeFallbacks[property]
        if fallback ~= nil then
            if typeof(fallback) == "string" and string.sub(fallback, 1, 1) ~= "#" then
                return module.GetThemeProperty(fallback, theme)
            else
                return getValue(property, {[property] = fallback})
            end
        end
        
        if module.Config.Themes and module.Config.Themes.Dark then
            local value = getValue(property, module.Config.Themes.Dark)
            if value ~= nil then return value end
        end
        
        return nil
    end
    
    function module.SetTheme(themeName)
        if module.Config.Themes then
            module.Config.Theme = module.Config.Themes[themeName] or module.Config.Themes.Dark
        end
        module.UpdateTheme(nil, true)
    end
    
    function module.AddFontObject(object)
        table.insert(module.Config.FontObjects, object)
        if module.Config.Font then
            module.UpdateFont(module.Config.Font)
        end
    end
    
    function module.UpdateFont(font)
        module.Config.Font = font
        for _, obj in pairs(module.Config.FontObjects) do
            if obj and obj.Parent then
                local currentFont = obj.FontFace or Font.new()
                obj.FontFace = Font.new(font, currentFont.Weight, currentFont.Style)
            end
        end
    end
    
    function module.Drag(frame, dragElements, callback)
        dragElements = dragElements or {frame}
        if typeof(dragElements) ~= "table" then dragElements = {dragElements} end
        
        local isDragging = false
        local dragInput, dragStart, startPos
        
        local function update(input)
            if not isDragging then return end
            local delta = input.Position - dragStart
            module.Tween(frame, 0.02, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
        
        for _, element in pairs(dragElements) do
            module.AddSignal(element.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
                    input.UserInputType == Enum.UserInputType.Touch) and module.Config.CanDraggable then
                    isDragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                    if callback then callback(true, element) end
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            isDragging = false
                            if callback then callback(false, nil) end
                        end
                    end)
                end
            end))
            
            module.AddSignal(element.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                                   input.UserInputType == Enum.UserInputType.Touch) then
                    dragInput = input
                    update(input)
                end
            end))
        end
        
        module.AddSignal(UserInputService.InputChanged:Connect(function(input)
            if isDragging and dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                                             input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end))
    end
    
    function module.Image(image, name, cornerRadius, folder, category, themed, colored, colorProperty)
        name = module.SanitizeFilename(name or "image")
        folder = folder or "Temp"
        category = category or "General"
        
        local container = module.New("Frame", {
            Size = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1,
        }, {
            module.New("ImageLabel", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                ScaleType = "Crop",
                ThemeTag = themed and {
                    ImageColor3 = colored and (colorProperty or "Icon") or nil
                } or nil,
            }, {
                module.New("UICorner", {CornerRadius = UDim.new(0, cornerRadius or 0)})
            })
        })
        
        if module.Icon(image) then
            container.ImageLabel:Destroy()
            local iconFrame = Icons.Image({
                Icon = image,
                Size = UDim2.new(1,0,1,0),
                Colors = {colored and (colorProperty or "Icon") or false, "Button"}
            }).IconFrame
            iconFrame.Parent = container
        elseif string.find(image, "http") then
            -- URL image loading
            warn("[WindUI] URL images require executor support")
        elseif image ~= "" then
            container.ImageLabel.Image = image
        else
            container.Visible = false
        end
        
        return container
    end
    
    function module.SanitizeFilename(filename)
        local clean = filename:match("([^/]+)$") or filename
        clean = clean:gsub("%.[^%.]+$", "")
        clean = clean:gsub("[^%w%-_]", "_")
        if #clean > 50 then clean = clean:sub(1,50) end
        return clean
    end
    
    function module.Gradient(colorStops, properties)
        properties = properties or {}
        local colorKeypoints, transparencyKeypoints = {}, {}
        
        for position, data in pairs(colorStops) do
            local time = tonumber(position)
            if time then
                time = math.clamp(time/100, 0, 1)
                table.insert(colorKeypoints, ColorSequenceKeypoint.new(time, data.Color))
                table.insert(transparencyKeypoints, NumberSequenceKeypoint.new(time, data.Transparency or 0))
            end
        end
        
        table.sort(colorKeypoints, function(a,b) return a.Time < b.Time end)
        table.sort(transparencyKeypoints, function(a,b) return a.Time < b.Time end)
        
        if #colorKeypoints < 2 then error("ColorSequence requires at least 2 keypoints") end
        
        local gradient = {
            Color = ColorSequence.new(colorKeypoints),
            Transparency = NumberSequence.new(transparencyKeypoints),
        }
        
        for key, value in pairs(properties) do
            gradient[key] = value
        end
        
        return gradient
    end
    
    return module
end

--[[ MODULE C: Localization ]]--
function WindUI.c()
    local module = {}
    
    function module.New(options, window)
        local localization = {
            Enabled = options.Enabled or false,
            Translations = options.Translations or {},
            Prefix = options.Prefix or "loc:",
            DefaultLanguage = options.DefaultLanguage or "en"
        }
        
        window.Localization = localization
        return localization
    end
    
    return module
end

--[[ MODULE D: Notifications ]]--
function WindUI.d()
    local module = {}
    local core = WindUI.load('b')
    
    module.Config = {
        Size = UDim2.new(0,300,1,-156),
        SizeLower = UDim2.new(0,300,1,-56),
        UICorner = 13,
        UIPadding = 14,
        NotificationIndex = 0,
        Notifications = {}
    }
    
    function module.Init(parent)
        local holder = core.New("Frame", {
            Position = UDim2.new(1,-29,0,56),
            AnchorPoint = Vector2.new(1,0),
            Size = module.Config.Size,
            Parent = parent,
            BackgroundTransparency = 1,
        }, {
            core.New("UIListLayout", {
                HorizontalAlignment = "Center",
                SortOrder = "LayoutOrder",
                VerticalAlignment = "Bottom",
                Padding = UDim.new(0,8),
            }),
            core.New("UIPadding", {PaddingBottom = UDim.new(0,29)})
        })
        
        return {
            Frame = holder,
            SetLower = function(self, lower)
                self.Lower = lower
                holder.Size = lower and module.Config.SizeLower or module.Config.Size
            end
        }
    end
    
    function module.New(options)
        local notification = {
            Title = options.Title or "Notification",
            Content = options.Content,
            Icon = options.Icon,
            IconThemed = options.IconThemed,
            Duration = options.Duration or 5,
            Buttons = options.Buttons or {},
            CanClose = options.CanClose ~= false,
            Closed = false,
        }
        
        module.Config.NotificationIndex = module.Config.NotificationIndex + 1
        module.Config.Notifications[module.Config.NotificationIndex] = notification
        
        local holder = module.Config.Holder.Frame
        
        -- Icon
        local iconFrame
        if notification.Icon then
            iconFrame = core.Image(
                notification.Icon,
                notification.Title .. ":" .. notification.Icon,
                0,
                options.Window or "Temp",
                "Notification",
                notification.IconThemed
            )
            iconFrame.Size = UDim2.new(0,26,0,26)
            iconFrame.Position = UDim2.new(0,module.Config.UIPadding,0,module.Config.UIPadding)
        end
        
        -- Close button
        local closeButton
        if notification.CanClose then
            closeButton = core.New("ImageButton", {
                Image = core.Icon("x")[1],
                ImageRectSize = core.Icon("x")[2].ImageRectSize,
                ImageRectOffset = core.Icon("x")[2].ImageRectPosition,
                BackgroundTransparency = 1,
                Size = UDim2.new(0,16,0,16),
                Position = UDim2.new(1,-module.Config.UIPadding,0,module.Config.UIPadding),
                AnchorPoint = Vector2.new(1,0),
                ThemeTag = {ImageColor3 = "Text"},
                ImageTransparency = 0.4,
            }, {
                core.New("TextButton", {
                    Size = UDim2.new(1,8,1,8),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new(0.5,0,0.5,0),
                    Text = "",
                })
            })
        end
        
        -- Timer bar
        local timerBar = core.New("Frame", {
            Size = UDim2.new(0,0,1,0),
            BackgroundTransparency = 0.95,
            ThemeTag = {BackgroundColor3 = "Text"},
        })
        
        -- Content
        local contentFrame = core.New("Frame", {
            Size = UDim2.new(1, notification.Icon and -28 - module.Config.UIPadding or 0, 1, 0),
            Position = UDim2.new(1,0,0,0),
            AnchorPoint = Vector2.new(1,0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {
            core.New("UIPadding", {
                PaddingTop = UDim.new(0,module.Config.UIPadding),
                PaddingLeft = UDim.new(0,module.Config.UIPadding),
                PaddingRight = UDim.new(0,module.Config.UIPadding),
                PaddingBottom = UDim.new(0,module.Config.UIPadding),
            }),
            core.New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1,-30-module.Config.UIPadding,0,0),
                TextWrapped = true,
                TextXAlignment = "Left",
                RichText = true,
                BackgroundTransparency = 1,
                TextSize = 16,
                ThemeTag = {TextColor3 = "Text"},
                Text = notification.Title,
                FontFace = Font.new(core.Config.Font, Enum.FontWeight.Medium)
            }),
            core.New("UIListLayout", {Padding = UDim.new(0,module.Config.UIPadding/3)})
        })
        
        if notification.Content then
            core.New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1,0,0,0),
                TextWrapped = true,
                TextXAlignment = "Left",
                RichText = true,
                BackgroundTransparency = 1,
                TextTransparency = 0.4,
                TextSize = 15,
                ThemeTag = {TextColor3 = "Text"},
                Text = notification.Content,
                FontFace = Font.new(core.Config.Font, Enum.FontWeight.Medium),
                Parent = contentFrame
            })
        end
        
        -- Main frame
        local mainFrame = core.NewRoundFrame(module.Config.UICorner, "Squircle", {
            Size = UDim2.new(1,0,0,0),
            Position = UDim2.new(2,0,1,0),
            AnchorPoint = Vector2.new(0,1),
            AutomaticSize = Enum.AutomaticSize.Y,
            ImageTransparency = 0.05,
            ThemeTag = {ImageColor3 = "Background"},
        }, {
            core.New("CanvasGroup", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
            }, {
                timerBar,
                core.New("UICorner", {CornerRadius = UDim.new(0,module.Config.UICorner)})
            }),
            contentFrame,
            iconFrame,
            closeButton,
        })
        
        -- Container
        local container = core.New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,0),
            Parent = holder
        }, {mainFrame})
        
        function notification:Close()
            if not self.Closed then
                self.Closed = true
                core.Tween(container, 0.45, {Size = UDim2.new(1,0,0,-8)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                core.Tween(mainFrame, 0.55, {Position = UDim2.new(2,0,1,0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                task.wait(0.45)
                container:Destroy()
            end
        end
        
        task.spawn(function()
            task.wait()
            core.Tween(container, 0.45, {
                Size = UDim2.new(1,0,0,mainFrame.AbsoluteSize.Y)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            core.Tween(mainFrame, 0.45, {
                Position = UDim2.new(0,0,1,0)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            if notification.Duration then
                core.Tween(timerBar, notification.Duration, {
                    Size = UDim2.new(1,0,1,0)
                }, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut):Play()
                task.wait(notification.Duration)
                notification:Close()
            end
        end)
        
        if closeButton then
            core.AddSignal(closeButton.TextButton.MouseButton1Click, notification.Close)
        end
        
        return notification
    end
    
    return module
end

--[[ MODULE E: Platoboost Key System ]]--
function WindUI.e()
    local module = {}
    
    -- SHA256 Implementation
    local function SHA256(msg)
        local function rrotate(x, n) return bit32.rrotate(x, n) end
        local function rshift(x, n) return bit32.rshift(x, n) end
        
        local k = {
            0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
            0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
            0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
            0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
            0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
            0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
            0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
            0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
            0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
            0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
            0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
        }
        
        local function preprocess(msg)
            local len = #msg * 8
            msg = msg .. string.char(0x80)
            while (#msg + 8) % 64 ~= 0 do
                msg = msg .. string.char(0)
            end
            for i = 1, 8 do
                msg = msg .. string.char(bit32.band(rshift(len, (8 - i) * 8), 0xFF))
            end
            return msg
        end
        
        msg = preprocess(msg)
        
        local h0, h1, h2, h3, h4, h5, h6, h7 = 
            0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
            0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
        
        for chunkStart = 1, #msg, 64 do
            local chunk = msg:sub(chunkStart, chunkStart + 63)
            local w = {}
            
            for i = 0, 15 do
                w[i] = string.byte(chunk, i * 4 + 1) * 0x1000000 +
                       string.byte(chunk, i * 4 + 2) * 0x10000 +
                       string.byte(chunk, i * 4 + 3) * 0x100 +
                       string.byte(chunk, i * 4 + 4)
            end
            
            for i = 16, 63 do
                local s0 = bit32.bxor(rrotate(w[i-15], 7), rrotate(w[i-15], 18), rshift(w[i-15], 3))
                local s1 = bit32.bxor(rrotate(w[i-2], 17), rrotate(w[i-2], 19), rshift(w[i-2], 10))
                w[i] = (w[i-16] + s0 + w[i-7] + s1) % 0x100000000
            end
            
            local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7
            
            for i = 0, 63 do
                local S1 = bit32.bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
                local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
                local temp1 = (h + S1 + ch + k[i+1] + w[i]) % 0x100000000
                local S0 = bit32.bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
                local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c))
                local temp2 = (S0 + maj) % 0x100000000
                
                h = g
                g = f
                f = e
                e = (d + temp1) % 0x100000000
                d = c
                c = b
                b = a
                a = (temp1 + temp2) % 0x100000000
            end
            
            h0 = (h0 + a) % 0x100000000
            h1 = (h1 + b) % 0x100000000
            h2 = (h2 + c) % 0x100000000
            h3 = (h3 + d) % 0x100000000
            h4 = (h4 + e) % 0x100000000
            h5 = (h5 + f) % 0x100000000
            h6 = (h6 + g) % 0x100000000
            h7 = (h7 + h) % 0x100000000
        end
        
        local function tohex(num)
            return string.format("%08x", num)
        end
        
        return tohex(h0) .. tohex(h1) .. tohex(h2) .. tohex(h3) ..
               tohex(h4) .. tohex(h5) .. tohex(h6) .. tohex(h7)
    end
    
    -- JSON Implementation
    local json = {}
    
    function json.encode(val)
        local type_val = type(val)
        
        if type_val == "string" then
            return '"' .. val:gsub('[%z\1-\31\\"]', function(c)
                return '\\' .. ({['\b']='b',['\f']='f',['\n']='n',['\r']='r',['\t']='t',['\\']='\\',['\"']='\"'})[c] or string.format("u%04x", c:byte())
            end) .. '"'
        elseif type_val == "number" then
            return tostring(val)
        elseif type_val == "boolean" then
            return val and "true" or "false"
        elseif type_val == "table" then
            local is_array = true
            local count = 0
            for k, v in pairs(val) do
                if type(k) ~= "number" or k ~= count + 1 then
                    is_array = false
                    break
                end
                count = count + 1
            end
            
            if is_array then
                local parts = {}
                for i = 1, count do
                    parts[i] = json.encode(val[i])
                end
                return "[" .. table.concat(parts, ",") .. "]"
            else
                local parts = {}
                for k, v in pairs(val) do
                    if type(k) == "string" then
                        table.insert(parts, json.encode(k) .. ":" .. json.encode(v))
                    end
                end
                return "{" .. table.concat(parts, ",") .. "}"
            end
        else
            return "null"
        end
    end
    
    function json.decode(str)
        local pos = 1
        
        local function skipWhite()
            while pos <= #str and str:sub(pos, pos):match("%s") do
                pos = pos + 1
            end
        end
        
        local function parseValue()
            skipWhite()
            local char = str:sub(pos, pos)
            
            if char == '"' then
                return parseString()
            elseif char:match("%d") or char == '-' then
                return parseNumber()
            elseif char == '{' then
                return parseObject()
            elseif char == '[' then
                return parseArray()
            elseif str:sub(pos, pos + 3) == "true" then
                pos = pos + 4
                return true
            elseif str:sub(pos, pos + 4) == "false" then
                pos = pos + 5
                return false
            elseif str:sub(pos, pos + 3) == "null" then
                pos = pos + 4
                return nil
            end
        end
        
        local function parseString()
            pos = pos + 1
            local result = ""
            
            while pos <= #str do
                local char = str:sub(pos, pos)
                
                if char == '"' then
                    pos = pos + 1
                    return result
                elseif char == '\\' then
                    pos = pos + 1
                    char = str:sub(pos, pos)
                    if char == 'b' then result = result .. "\b"
                    elseif char == 'f' then result = result .. "\f"
                    elseif char == 'n' then result = result .. "\n"
                    elseif char == 'r' then result = result .. "\r"
                    elseif char == 't' then result = result .. "\t"
                    elseif char == 'u' then
                        -- Simple unicode handling (simplified)
                        pos = pos + 4
                        result = result .. "?"
                    else
                        result = result .. char
                    end
                else
                    result = result .. char
                end
                pos = pos + 1
            end
        end
        
        local function parseNumber()
            local start = pos
            while pos <= #str and str:sub(pos, pos):match("[%d%.eE+-]") do
                pos = pos + 1
            end
            return tonumber(str:sub(start, pos - 1))
        end
        
        local function parseObject()
            pos = pos + 1
            local result = {}
            
            skipWhite()
            if str:sub(pos, pos) == '}' then
                pos = pos + 1
                return result
            end
            
            while true do
                skipWhite()
                local key = parseString()
                skipWhite()
                if str:sub(pos, pos) ~= ':' then error("Expected colon") end
                pos = pos + 1
                result[key] = parseValue()
                skipWhite()
                
                local char = str:sub(pos, pos)
                if char == '}' then
                    pos = pos + 1
                    return result
                elseif char == ',' then
                    pos = pos + 1
                else
                    error("Expected comma or closing brace")
                end
            end
        end
        
        local function parseArray()
            pos = pos + 1
            local result = {}
            local index = 1
            
            skipWhite()
            if str:sub(pos, pos) == ']' then
                pos = pos + 1
                return result
            end
            
            while true do
                result[index] = parseValue()
                index = index + 1
                skipWhite()
                
                local char = str:sub(pos, pos)
                if char == ']' then
                    pos = pos + 1
                    return result
                elseif char == ',' then
                    pos = pos + 1
                else
                    error("Expected comma or closing bracket")
                end
            end
        end
        
        return parseValue()
    end
    
    function module.New(serviceId, secret)
        local api = {}
        local baseUrl = "https://api.platoboost.app"
        
        local function getHWID()
            return gethwid and gethwid() or game:GetService("Players").LocalPlayer.UserId
        end
        
        local function getRequest()
            return http_request or (syn and syn.request) or request
        end
        
        function api:Verify(key)
            local hwid = getHWID()
            local requestFunc = getRequest()
            
            local response = requestFunc({
                Url = baseUrl .. "/public/whitelist/" .. serviceId .. "?identifier=" .. SHA256(tostring(hwid)) .. "&key=" .. key,
                Method = "GET"
            })
            
            if response.StatusCode == 200 then
                local data = json.decode(response.Body)
                if data.success then
                    if data.data.valid then
                        return true, ""
                    else
                        return false, "Key is invalid"
                    end
                else
                    return false, data.message
                end
            else
                return false, "Server error: " .. response.StatusCode
            end
        end
        
        function api:Copy()
            local hwid = getHWID()
            local requestFunc = getRequest()
            
            local response = requestFunc({
                Url = baseUrl .. "/public/start",
                Method = "POST",
                Body = json.encode({
                    service = serviceId,
                    identifier = SHA256(tostring(hwid))
                }),
                Headers = {
                    ["Content-Type"] = "application/json"
                }
            })
            
            if response.StatusCode == 200 then
                local data = json.decode(response.Body)
                if data.success then
                    setclipboard(data.data.url)
                    return true
                end
            end
            return false
        end
        
        function api:GetFlag(name)
            local requestFunc = getRequest()
            
            local response = requestFunc({
                Url = baseUrl .. "/public/flag/" .. serviceId .. "?name=" .. name,
                Method = "GET"
            })
            
            if response.StatusCode == 200 then
                local data = json.decode(response.Body)
                if data.success then
                    return data.data.value
                end
            end
            return nil
        end
        
        return api
    end
    
    return module
end

--[[ MODULE F: Panda Development Key System ]]--
function WindUI.f()
    local module = {}
    
    function module.New(serviceId)
        local api = {}
        local baseUrl = "https://pandadevelopment.net"
        
        local function getHWID()
            return gethwid and gethwid() or game:GetService("Players").LocalPlayer.UserId
        end
        
        function api:Verify(key)
            local hwid = getHWID()
            local requestFunc = http_request or (syn and syn.request) or request
            
            local response = requestFunc({
                Url = baseUrl .. "/v2_validation?key=" .. key .. "&service=" .. serviceId .. "&hwid=" .. hwid,
                Method = "GET",
                Headers = {["User-Agent"] = "Roblox/Exploit"}
            })
            
            if response.Success then
                local success, data = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(response.Body)
                end)
                
                if success and data then
                    if data.V2_Authentication == "success" then
                        return true, "Authenticated"
                    else
                        return false, data.Key_Information.Notes or "Authentication failed"
                    end
                else
                    return false, "JSON decode error"
                end
            else
                return false, "HTTP request failed: " .. response.StatusMessage
            end
        end
        
        function api:Copy()
            local hwid = getHWID()
            local url = baseUrl .. "/getkey?service=" .. serviceId .. "&hwid=" .. hwid
            setclipboard(url)
            return true
        end
        
        return api
    end
    
    return module
end

--[[ MODULE G: Luarmor Key System ]]--
function WindUI.g()
    local module = {}
    
    function module.New(scriptId, discordUrl)
        local api = {}
        local sdkUrl = "https://sdkapi-public.luarmor.net/library.lua"
        
        local sdk = loadstring(game:HttpGet(sdkUrl))()
        sdk.script_id = scriptId
        
        function api:Verify(key)
            local result = sdk.check_key(key)
            
            if result.code == "KEY_VALID" then
                return true, "Whitelisted!"
            elseif result.code == "KEY_HWID_LOCKED" then
                return false, "Key linked to different HWID"
            elseif result.code == "KEY_INCORRECT" then
                return false, "Key is wrong or deleted"
            else
                return false, "Key check failed: " .. result.message
            end
        end
        
        function api:Copy()
            setclipboard(tostring(discordUrl))
            return true
        end
        
        return api
    end
    
    return module
end

--[[ MODULE H: Key System Services ]]--
function WindUI.h()
    return {
        platoboost = {
            Name = "Platoboost",
            Icon = "rbxassetid://75920162824531",
            Args = {"ServiceId", "Secret"},
            New = WindUI.load('e').New
        },
        pandadevelopment = {
            Name = "Panda Development",
            Icon = "panda",
            Args = {"ServiceId"},
            New = WindUI.load('f').New
        },
        luarmor = {
            Name = "Luarmor",
            Icon = "rbxassetid://130918283130165",
            Args = {"ScriptId", "Discord"},
            New = WindUI.load('g').New
        },
    }
end

--[[ MODULE J: Button Component ]]--
function WindUI.j()
    local module = {}
    local core = WindUI.load('b')
    
    function module.New(text, icon, callback, variant, parent, popup, noShadow, cornerRadius)
        variant = variant or "Primary"
        cornerRadius = cornerRadius or 10
        
        local iconFrame
        if icon and icon ~= "" then
            iconFrame = core.New("ImageLabel", {
                Image = core.Icon(icon)[1],
                ImageRectSize = core.Icon(icon)[2].ImageRectSize,
                ImageRectOffset = core.Icon(icon)[2].ImageRectPosition,
                Size = UDim2.new(0,21,0,21),
                BackgroundTransparency = 1,
                ImageColor3 = variant == "White" and Color3.new(0,0,0) or nil,
                ImageTransparency = variant == "White" and 0.4 or 0,
                ThemeTag = {
                    ImageColor3 = variant ~= "White" and "Icon" or nil,
                }
            })
        end
        
        local button = core.New("TextButton", {
            Size = UDim2.new(0,0,1,0),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = parent,
            BackgroundTransparency = 1,
            Text = "",
        }, {
            -- Background
            core.NewRoundFrame(cornerRadius, "Squircle", {
                ThemeTag = {
                    ImageColor3 = variant ~= "White" and "Button" or nil,
                },
                ImageColor3 = variant == "White" and Color3.new(1,1,1) or nil,
                Size = UDim2.new(1,0,1,0),
                Name = "Squircle",
                ImageTransparency = variant == "Primary" and 0 or variant == "White" and 0 or 1
            }),
            
            -- Outline
            core.NewRoundFrame(cornerRadius, noShadow and "SquircleOutline2" or "SquircleOutline", {
                ThemeTag = {
                    ImageColor3 = variant ~= "White" and "Outline" or nil,
                },
                Size = UDim2.new(1,0,1,0),
                ImageColor3 = variant == "White" and Color3.new(0,0,0) or nil,
                ImageTransparency = variant == "Primary" and 0.95 or 0.85,
                Name = "SquircleOutline",
            }),
            
            -- Content frame
            core.NewRoundFrame(cornerRadius, "Squircle", {
                Size = UDim2.new(1,0,1,0),
                Name = "Frame",
                ThemeTag = {
                    ImageColor3 = variant ~= "White" and "Text" or nil
                },
                ImageColor3 = variant == "White" and Color3.new(0,0,0) or nil,
                ImageTransparency = 1
            }, {
                core.New("UIPadding", {
                    PaddingLeft = UDim.new(0,16),
                    PaddingRight = UDim.new(0,16),
                }),
                core.New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0,8),
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                }),
                iconFrame,
                core.New("TextLabel", {
                    BackgroundTransparency = 1,
                    FontFace = Font.new(core.Config.Font, Enum.FontWeight.SemiBold),
                    Text = text or "Button",
                    ThemeTag = {
                        TextColor3 = (variant ~= "Primary" and variant ~= "White") and "Text",
                    },
                    TextColor3 = variant == "Primary" and Color3.new(1,1,1) or 
                                 variant == "White" and Color3.new(0,0,0) or nil,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextSize = 18,
                })
            })
        })
        
        -- Hover effects
        core.AddSignal(button.MouseEnter, function()
            core.Tween(button.Frame, 0.047, {ImageTransparency = 0.95}):Play()
        end)
        
        core.AddSignal(button.MouseLeave, function()
            core.Tween(button.Frame, 0.047, {ImageTransparency = 1}):Play()
        end)
        
        -- Click handler
        core.AddSignal(button.MouseButton1Up, function()
            if popup then popup:Close()() end
            if callback then core.SafeCallback(callback) end
        end)
        
        return button
    end
    
    return module
end

--[[ MODULE K: Input Component ]]--
function WindUI.k()
    local module = {}
    local core = WindUI.load('b')
    
    function module.New(placeholder, icon, parent, inputType, callback, instantUpdate, cornerRadius, clearOnFocus)
        inputType = inputType or "Input"
        cornerRadius = cornerRadius or 10
        local isTextArea = inputType ~= "Input"
        
        local iconFrame
        if icon and icon ~= "" then
            iconFrame = core.New("ImageLabel", {
                Image = core.Icon(icon)[1],
                ImageRectSize = core.Icon(icon)[2].ImageRectSize,
                ImageRectOffset = core.Icon(icon)[2].ImageRectPosition,
                Size = UDim2.new(0,21,0,21),
                BackgroundTransparency = 1,
                ThemeTag = {
                    ImageColor3 = "Icon",
                }
            })
        end
        
        local textBox = core.New("TextBox", {
            BackgroundTransparency = 1,
            TextSize = 17,
            FontFace = Font.new(core.Config.Font, Enum.FontWeight.Regular),
            Size = UDim2.new(1, iconFrame and -29 or 0, 1, 0),
            PlaceholderText = placeholder,
            ClearTextOnFocus = clearOnFocus or false,
            ClipsDescendants = true,
            TextWrapped = isTextArea,
            MultiLine = isTextArea,
            TextXAlignment = "Left",
            TextYAlignment = isTextArea and "Top" or "Center",
            ThemeTag = {
                PlaceholderColor3 = "PlaceholderText",
                TextColor3 = "Text",
            },
        })
        
        local inputFrame = core.New("Frame", {
            Size = UDim2.new(1,0,0,isTextArea and 148 or 42),
            Parent = parent,
            BackgroundTransparency = 1
        }, {
            core.New("Frame", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
            }, {
                -- Background
                core.NewRoundFrame(cornerRadius, "Squircle", {
                    ThemeTag = {
                        ImageColor3 = "Accent",
                    },
                    Size = UDim2.new(1,0,1,0),
                    ImageTransparency = 0.97,
                }),
                
                -- Outline
                core.NewRoundFrame(cornerRadius, "SquircleOutline", {
                    ThemeTag = {
                        ImageColor3 = "Outline",
                    },
                    Size = UDim2.new(1,0,1,0),
                    ImageTransparency = 0.95,
                }),
                
                -- Content frame
                core.NewRoundFrame(cornerRadius, "Squircle", {
                    Size = UDim2.new(1,0,1,0),
                    Name = "Frame",
                    ImageColor3 = Color3.new(1,1,1),
                    ImageTransparency = 0.95
                }, {
                    core.New("UIPadding", {
                        PaddingTop = UDim.new(0,isTextArea and 12 or 0),
                        PaddingLeft = UDim.new(0,12),
                        PaddingRight = UDim.new(0,12),
                        PaddingBottom = UDim.new(0,isTextArea and 12 or 0),
                    }),
                    core.New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0,8),
                        VerticalAlignment = isTextArea and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    }),
                    iconFrame,
                    textBox,
                })
            })
        })
        
        if instantUpdate then
            core.AddSignal(textBox:GetPropertyChangedSignal("Text"), function()
                if callback then
                    core.SafeCallback(callback, textBox.Text)
                end
            end)
        else
            core.AddSignal(textBox.FocusLost, function()
                if callback then
                    core.SafeCallback(callback, textBox.Text)
                end
            end)
        end
        
        local methods = {
            Set = function(self, text)
                textBox.Text = text
            end,
            Get = function(self)
                return textBox.Text
            end,
            Clear = function(self)
                textBox.Text = ""
            end
        }
        
        return inputFrame, methods
    end
    
    return module
end

--[[ MODULE L: Syntax Highlighter ]]--
function WindUI.L()
    local module = {}
    
    local keywords = {
        lua = {
            "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if",
            "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"
        },
        roblox = {
            "game", "workspace", "script", "Instance", "Vector3", "Vector2", "CFrame", "UDim2", "UDim",
            "Color3", "BrickColor", "Enum", "math", "string", "table", "task", "wait", "spawn", "tick"
        },
        operators = {"+", "-", "*", "/", "%", "^", "#", "==", "~=", "<=", ">=", "<", ">", "=", "(", ")", "{", "}", "[", "]"}
    }
    
    local colors = {
        keyword = "#FF6B8B",     -- Pink
        roblox = "#4ECDC4",      -- Teal
        string = "#98CE00",      -- Lime
        number = "#FFD166",      -- Yellow
        comment = "#7A7A7A",     -- Gray
        operator = "#06D6A0",    -- Green
        default = "#FFFFFF"      -- White
    }
    
    function module.highlight(code)
        local tokens = {}
        local i = 1
        
        while i <= #code do
            local char = code:sub(i, i)
            
            -- Comments
            if code:sub(i, i+1) == "--" then
                local start = i
                while i <= #code and code:sub(i, i) ~= "\n" do
                    i = i + 1
                end
                table.insert(tokens, {
                    text = code:sub(start, i-1),
                    color = colors.comment
                })
            
            -- Strings
            elseif char == "\"" or char == "'" then
                local start = i
                i = i + 1
                while i <= #code and code:sub(i, i) ~= char do
                    if code:sub(i, i) == "\\" then
                        i = i + 1
                    end
                    i = i + 1
                end
                i = i + 1
                table.insert(tokens, {
                    text = code:sub(start, i-1),
                    color = colors.string
                })
            
            -- Numbers
            elseif char:match("%d") then
                local start = i
                while i <= #code and (code:sub(i, i):match("%d") or code:sub(i, i) == ".") do
                    i = i + 1
                end
                table.insert(tokens, {
                    text = code:sub(start, i-1),
                    color = colors.number
                })
            
            -- Identifiers and keywords
            elseif char:match("%a") then
                local start = i
                while i <= #code and code:sub(i, i):match("%w") do
                    i = i + 1
                end
                local word = code:sub(start, i-1)
                local color = colors.default
                
                -- Check if it's a Lua keyword
                for _, kw in ipairs(keywords.lua) do
                    if word == kw then
                        color = colors.keyword
                        break
                    end
                end
                
                -- Check if it's a Roblox keyword
                for _, rb in ipairs(keywords.roblox) do
                    if word == rb then
                        color = colors.roblox
                        break
                    end
                end
                
                table.insert(tokens, {
                    text = word,
                    color = color
                })
            
            -- Operators
            else
                local opFound = false
                for _, op in ipairs(keywords.operators) do
                    if code:sub(i, i+#op-1) == op then
                        table.insert(tokens, {
                            text = op,
                            color = colors.operator
                        })
                        i = i + #op - 1
                        opFound = true
                        break
                    end
                end
                
                if not opFound then
                    table.insert(tokens, {
                        text = char,
                        color = colors.default
                    })
                end
                i = i + 1
            end
        end
        
        -- Convert to RichText
        local richText = ""
        for _, token in ipairs(tokens) do
            richText = richText .. string.format('<font color="%s">%s</font>', 
                token.color, 
                token.text:gsub("<", "&lt;"):gsub(">", "&gt;"))
        end
        
        return richText
    end
    
    return module
end

--[[ MODULE M: Code Block Component ]]--
function WindUI.M()
    local module = {}
    local core = WindUI.load('b')
    local highlighter = WindUI.load('L')
    
    function module.New(code, title, parent, onCopy, scale, options)
        local codeBlock = {}
        local radius = 12
        local padding = 10
        
        local codeLabel = core.New("TextLabel", {
            Text = "",
            TextColor3 = Color3.fromHex("#CDD6F4"),
            TextTransparency = 0,
            TextSize = 14 * (scale or 1),
            TextWrapped = false,
            LineHeight = 1.15,
            RichText = true,
            TextXAlignment = "Left",
            Size = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
        }, {
            core.New("UIPadding", {
                PaddingTop = UDim.new(0,padding+3),
                PaddingLeft = UDim.new(0,padding+3),
                PaddingRight = UDim.new(0,padding+3),
                PaddingBottom = UDim.new(0,padding+3),
            })
        })
        codeLabel.Font = "Code"
        
        local scrollFrame = core.New("ScrollingFrame", {
            Size = UDim2.new(1,0,0,0),
            BackgroundTransparency = 1,
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            ScrollingDirection = Enum.ScrollingDirection.X,
            ElasticBehavior = Enum.ElasticBehavior.Never,
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarThickness = 0,
        }, {codeLabel})
        
        local copyButton = core.New("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0,30,0,30),
            Position = UDim2.new(1,-padding/2,0,padding/2),
            AnchorPoint = Vector2.new(1,0),
            Visible = onCopy and true or false,
        }, {
            core.NewRoundFrame(radius-4, "Squircle", {
                ImageColor3 = Color3.fromHex("#ffffff"),
                ImageTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.new(0.5,0,0.5,0),
                Name = "Button",
            }, {
                core.New("UIScale", {Scale = 1}),
                core.New("ImageLabel", {
                    Image = core.Icon("copy")[1],
                    ImageRectSize = core.Icon("copy")[2].ImageRectSize,
                    ImageRectOffset = core.Icon("copy")[2].ImageRectPosition,
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new(0.5,0,0.5,0),
                    Size = UDim2.new(0,12,0,12),
                    ImageColor3 = Color3.fromHex("#ffffff"),
                    ImageTransparency = 0.1,
                })
            })
        })
        
        core.AddSignal(copyButton.MouseEnter, function()
            core.Tween(copyButton.Button, 0.05, {ImageTransparency = 0.95}):Play()
            core.Tween(copyButton.Button.UIScale, 0.05, {Scale = 0.9}):Play()
        end)
        
        core.AddSignal(copyButton.InputEnded, function()
            core.Tween(copyButton.Button, 0.08, {ImageTransparency = 1}):Play()
            core.Tween(copyButton.Button.UIScale, 0.08, {Scale = 1}):Play()
        end)
        
        local mainFrame = core.NewRoundFrame(radius, "Squircle", {
            ImageColor3 = Color3.fromHex("#212121"),
            ImageTransparency = 0.035,
            Size = UDim2.new(1,0,0,20+(padding*2)),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = parent,
        }, {
            core.NewRoundFrame(radius, "SquircleOutline", {
                Size = UDim2.new(1,0,1,0),
                ImageColor3 = Color3.fromHex("#ffffff"),
                ImageTransparency = 0.955,
            }),
            
            core.New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                -- Title bar
                core.NewRoundFrame(radius, "Squircle-TL-TR", {
                    ImageColor3 = Color3.fromHex("#ffffff"),
                    ImageTransparency = 0.96,
                    Size = UDim2.new(1,0,0,20+(padding*2)),
                    Visible = title and true or false
                }, {
                    core.New("ImageLabel", {
                        Size = UDim2.new(0,18,0,18),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://132464694294269",
                        ImageColor3 = Color3.fromHex("#ffffff"),
                        ImageTransparency = 0.2,
                    }),
                    core.New("TextLabel", {
                        Text = title or "",
                        TextColor3 = Color3.fromHex("#ffffff"),
                        TextTransparency = 0.2,
                        TextSize = 16,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        FontFace = Font.new(core.Config.Font, Enum.FontWeight.Medium),
                        TextXAlignment = "Left",
                        BackgroundTransparency = 1,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Size = UDim2.new(1, copyButton and -20-(padding*2) or 0, 0, 0)
                    }),
                    core.New("UIPadding", {
                        PaddingLeft = UDim.new(0,padding+3),
                        PaddingRight = UDim.new(0,padding+3),
                    }),
                    core.New("UIListLayout", {
                        Padding = UDim.new(0,padding),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    })
                }),
                
                scrollFrame,
                
                core.New("UIListLayout", {
                    Padding = UDim.new(0,0),
                    FillDirection = Enum.FillDirection.Vertical,
                })
            }),
            
            copyButton,
        })
        
        codeBlock.Frame = mainFrame
        
        core.AddSignal(codeLabel:GetPropertyChangedSignal("TextBounds"), function()
            scrollFrame.Size = UDim2.new(1,0,0,(codeLabel.TextBounds.Y/(scale or 1))+((padding+3)*2))
        end)
        
        function codeBlock:Set(newCode)
            codeLabel.Text = highlighter.highlight(newCode)
        end
        
        function codeBlock:Destroy()
            mainFrame:Destroy()
            codeBlock = nil
        end
        
        codeBlock:Set(code or "")
        
        core.AddSignal(copyButton.MouseButton1Click, function()
            if onCopy then
                onCopy()
                local checkIcon = core.Icon("check")
                copyButton.Button.ImageLabel.Image = checkIcon[1]
                copyButton.Button.ImageLabel.ImageRectSize = checkIcon[2].ImageRectSize
                copyButton.Button.ImageLabel.ImageRectOffset = checkIcon[2].ImageRectPosition
                
                task.wait(1)
                local copyIcon = core.Icon("copy")
                copyButton.Button.ImageLabel.Image = copyIcon[1]
                copyButton.Button.ImageLabel.ImageRectSize = copyIcon[2].ImageRectSize
                copyButton.Button.ImageLabel.ImageRectOffset = copyIcon[2].ImageRectPosition
            end
        end)
        
        return codeBlock
    end
    
    return module
end

--[[ MODULE N: Code Element ]]--
function WindUI.N()
    local module = {}
    local core = WindUI.load('b')
    local codeBlock = WindUI.load('M')
    
    function module.New(options, window)
        local element = {
            __type = "Code",
            Title = options.Title,
            Code = options.Code,
            OnCopy = options.OnCopy,
        }
        
        local cb = codeBlock.New(
            element.Code,
            element.Title,
            options.Parent,
            function()
                if element.OnCopy then element.OnCopy() end
                setclipboard(element.Code)
            end,
            window.UIScale,
            element
        )
        
        function element:SetCode(newCode)
            cb:Set(newCode)
            element.Code = newCode
        end
        
        function element:Destroy()
            cb:Destroy()
            element = nil
        end
        
        element.Frame = cb.Frame
        
        return element
    end
    
    return module
end

--[[ MODULE O: Color Picker Component ]]--
function WindUI.O()
    local module = {}
    local core = WindUI.load('b')
    
    function module.New(defaultColor, parent, callback, showAlpha)
        local colorPicker = {}
        local currentColor = defaultColor or Color3.fromRGB(255, 0, 0)
        local currentAlpha = showAlpha and 1 or nil
        
        local function RGBtoHSV(color)
            local r, g, b = color.r, color.g, color.b
            local max = math.max(r, g, b)
            local min = math.min(r, g, b)
            local h, s, v = 0, 0, max
            
            local d = max - min
            if max > 0 then s = d / max end
            
            if max == min then
                h = 0
            else
                if max == r then
                    h = (g - b) / d
                    if g < b then h = h + 6 end
                elseif max == g then
                    h = (b - r) / d + 2
                elseif max == b then
                    h = (r - g) / d + 4
                end
                h = h / 6
            end
            
            return h, s, v
        end
        
        local function HSVtoRGB(h, s, v)
            local r, g, b
            
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)
            
            i = i % 6
            
            if i == 0 then r, g, b = v, t, p
            elseif i == 1 then r, g, b = q, v, p
            elseif i == 2 then r, g, b = p, v, t
            elseif i == 3 then r, g, b = p, q, v
            elseif i == 4 then r, g, b = t, p, v
            elseif i == 5 then r, g, b = v, p, q
            end
            
            return Color3.new(r, g, b)
        end
        
        local h, s, v = RGBtoHSV(currentColor)
        
        -- Preview
        local preview = core.New("Frame", {
            Size = UDim2.new(0,40,0,40),
            BackgroundColor3 = currentColor,
            ThemeTag = {BackgroundColor3 = "ElementBackground"},
        }, {
            core.New("UICorner", {CornerRadius = UDim.new(0,8)}),
            core.New("UIStroke", {
                Thickness = 1,
                ThemeTag = {Color = "Outline"},
                Transparency = 0.8,
            })
        })
        
        -- Hue slider
        local hueSlider = core.New("Frame", {
            Size = UDim2.new(1,0,0,20),
            BackgroundTransparency = 1,
        }, {
            core.New("ImageLabel", {
                Size = UDim2.new(1,0,1,0),
                Image = "rbxassetid://11587970386",
                ScaleType = Enum.ScaleType.Stretch,
                BackgroundTransparency = 1,
            }),
            core.New("Frame", {
                Size = UDim2.new(0,4,1,4),
                Position = UDim2.new(h,0,0.5,0),
                AnchorPoint = Vector2.new(0.5,0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
            }, {
                core.New("UICorner", {CornerRadius = UDim.new(1,0)})
            })
        })
        
        -- Saturation/Value picker
        local svPicker = core.New("Frame", {
            Size = UDim2.new(1,0,0,100),
            BackgroundColor3 = HSVtoRGB(h,1,1),
        }, {
            -- White to transparent gradient (horizontal)
            core.New("UIGradient", {
                Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)),
                Transparency = NumberSequence.new(0,1),
                Rotation = 0,
            }),
            -- Black to transparent gradient (vertical)
            core.New("UIGradient", {
                Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)),
                Transparency = NumberSequence.new(1,0),
                Rotation = 90,
            }),
            -- Selection circle
            core.New("Frame", {
                Size = UDim2.new(0,10,0,10),
                Position = UDim2.new(s,0,1-v,0),
                AnchorPoint = Vector2.new(0.5,0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 2,
                BorderColor3 = Color3.new(0,0,0),
            }, {
                core.New("UICorner", {CornerRadius = UDim.new(1,0)})
            })
        })
        
        -- Main frame
        local colorPickerFrame = core.New("Frame", {
            Size = UDim2.new(1,0,0,showAlpha and 320 or 300),
            BackgroundTransparency = 1,
            Parent = parent,
        }, {
            core.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0,10),
            }),
            
            -- Preview and hex row
            core.New("Frame", {
                Size = UDim2.new(1,0,0,40),
                BackgroundTransparency = 1,
            }, {
                core.New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0,10),
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),
                preview,
            }),
            
            svPicker,
            hueSlider,
            
            -- RGB inputs
            core.New("Frame", {
                Size = UDim2.new(1,0,0,80),
                BackgroundTransparency = 1,
            }, {
                core.New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0,5),
                }),
                
                -- R
                core.New("Frame", {
                    Size = UDim2.new(1,0,0,25),
                    BackgroundTransparency = 1,
                }, {
                    core.New("TextLabel", {
                        Text = "R:",
                        TextSize = 14,
                        FontFace = Font.new(core.Config.Font, Enum.FontWeight.Medium),
                        ThemeTag = {TextColor3 = "Text"},
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0,20,1,0),
                        TextXAlignment = "Left",
                    }),
                    core.New("TextBox", {
                        Text = tostring(math.floor(currentColor.r * 255)),
                        TextSize = 14,
                        FontFace = Font.new(core.Config.Font, Enum.FontWeight.Regular),
                        ThemeTag = {
                            TextColor3 = "Text",
                            BackgroundColor3 = "ElementBackground",
                        },
                        Size = UDim2.new(1,-25,1,0),
                        Position = UDim2.new(0,25,0,0),
                        BackgroundTransparency = 0.95,
                        TextXAlignment = "Center",
                    }, {
                        core.New("UICorner", {CornerRadius = UDim.new(0,4)})
                    })
                }),
            })
        })
        
        -- Update color function
        local function updateColor(newH, newS, newV, newAlpha)
            h = newH or h
            s = newS or s
            v = newV or v
            if showAlpha then
                currentAlpha = newAlpha or currentAlpha
            end
            
            local newColor = HSVtoRGB(h, s, v)
            currentColor = newColor
            
            -- Update preview
            preview.BackgroundColor3 = newColor
            
            -- Update SV picker background
            svPicker.BackgroundColor3 = HSVtoRGB(h,1,1)
            
            -- Update hue slider position
            hueSlider.Frame.Position = UDim2.new(h,0,0.5,0)
            
            -- Update SV picker position
            svPicker.Frame.Position = UDim2.new(s,0,1-v,0)
            
            -- Update RGB inputs
            if colorPickerFrame.Frame.Frame.Frame.TextBox then
                colorPickerFrame.Frame.Frame.Frame.TextBox.Text = tostring(math.floor(newColor.r * 255))
            end
            
            -- Callback
            if callback then
                if showAlpha then
                    core.SafeCallback(callback, newColor, currentAlpha)
                else
                    core.SafeCallback(callback, newColor)
                end
            end
        end
        
        -- Drag handlers
        local function createDragHandler(frame, updateFunc)
            local dragging = false
            
            core.AddSignal(frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end))
            
            core.AddSignal(game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end))
            
            core.AddSignal(game:GetService("RunService").RenderStepped:Connect(function()
                if dragging then
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    local frameAbsPos = frame.AbsolutePosition
                    local frameAbsSize = frame.AbsoluteSize
                    
                    local relativeX = (mouse.X - frameAbsPos.X) / frameAbsSize.X
                    local relativeY = (mouse.Y - frameAbsPos.Y) / frameAbsSize.Y
                    
                    relativeX = math.clamp(relativeX, 0, 1)
                    relativeY = math.clamp(relativeY, 0, 1)
                    
                    updateFunc(relativeX, relativeY)
                end
            end))
        end
        
        -- Hue slider drag
        createDragHandler(hueSlider, function(x, y)
            updateColor(x, s, v, currentAlpha)
        end)
        
        -- SV picker drag
        createDragHandler(svPicker, function(x, y)
            updateColor(h, x, 1 - y, currentAlpha)
        end)
        
        -- Methods
        function colorPicker:Set(color, alpha)
            local newH, newS, newV = RGBtoHSV(color)
            updateColor(newH, newS, newV, alpha)
        end
        
        function colorPicker:Get()
            if showAlpha then
                return currentColor, currentAlpha
            else
                return currentColor
            end
        end
        
        return colorPickerFrame, colorPicker
    end
    
    return module
end

--[[ MODULE Q: Acrylic Effect ]]--
function WindUI.q()
    local module = {}
    
    function module.init()
        local depthOfField = Instance.new("DepthOfFieldEffect")
        depthOfField.FarIntensity = 0
        depthOfField.InFocusRadius = 0.1
        depthOfField.NearIntensity = 1
        
        local originalEffects = {}
        
        function module.Enable()
            for _, effect in pairs(game:GetService("Lighting"):GetChildren()) do
                if effect:IsA("DepthOfFieldEffect") then
                    originalEffects[effect] = effect.Enabled
                    effect.Enabled = false
                end
            end
            depthOfField.Parent = game:GetService("Lighting")
        end
        
        function module.Disable()
            for effect, enabled in pairs(originalEffects) do
                effect.Enabled = enabled
            end
            depthOfField.Parent = nil
        end
        
        module.Enable()
    end
    
    return module
end

--[[ MODULE R: Dialog/Popup System ]]--
function WindUI.r()
    local module = {}
    local core = WindUI.load('b')
    local button = WindUI.load('j')
    
    function module.New(options, window)
        local dialog = {
            Title = options.Title or "Dialog",
            Content = options.Content,
            Icon = options.Icon,
            IconThemed = options.IconThemed,
            Buttons = options.Buttons or {},
            Thumbnail = options.Thumbnail,
        }
        
        -- Create overlay
        local overlay = core.New("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromHex("#000000"),
            ZIndex = 999,
            Parent = window.ScreenGui,
        })
        
        -- Main dialog frame
        local dialogFrame = core.NewRoundFrame(20, "Squircle", {
            Size = UDim2.new(0,400,0,0),
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ThemeTag = {
                ImageColor3 = "DialogBackground",
                ImageTransparency = "DialogBackgroundTransparency",
            },
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 1000,
            Parent = overlay,
        }, {
            core.New("UIPadding", {
                PaddingTop = UDim.new(0,20),
                PaddingLeft = UDim.new(0,20),
                PaddingRight = UDim.new(0,20),
                PaddingBottom = UDim.new(0,20),
            }),
            
            core.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0,15),
            }),
        })
        
        -- Icon and title
        local titleFrame = core.New("Frame", {
            Size = UDim2.new(1,0,0,0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {
            core.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0,12),
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
        })
        
        if dialog.Icon then
            local icon = core.Image(
                dialog.Icon,
                dialog.Title,
                0,
                window.Folder,
                "Dialog",
                dialog.IconThemed,
                true,
                "DialogIcon"
            )
            icon.Size = UDim2.new(0,24,0,24)
            icon.Parent = titleFrame
        end
        
        local titleLabel = core.New("TextLabel", {
            Text = dialog.Title,
            FontFace = Font.new(core.Config.Font, Enum.FontWeight.SemiBold),
            TextSize = 20,
            ThemeTag = {TextColor3 = "DialogTitle"},
            BackgroundTransparency = 1,
            Size = UDim2.new(1, dialog.Icon and -36 or 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextWrapped = true,
            TextXAlignment = "Left",
        })
        titleLabel.Parent = titleFrame
        
        titleFrame.Parent = dialogFrame
        
        -- Content
        if dialog.Content then
            local contentLabel = core.New("TextLabel", {
                Text = dialog.Content,
                FontFace = Font.new(core.Config.Font, Enum.FontWeight.Medium),
                TextSize = 16,
                ThemeTag = {TextColor3 = "DialogContent"},
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                TextWrapped = true,
                TextXAlignment = "Left",
                TextTransparency = 0.2,
            })
            contentLabel.Parent = dialogFrame
        end
        
        -- Buttons
        if #dialog.Buttons > 0 then
            local buttonFrame = core.New("Frame", {
                Size = UDim2.new(1,0,0,40),
                BackgroundTransparency = 1,
            }, {
                core.New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0,10),
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                })
            })
            
            for _, btn in ipairs(dialog.Buttons) do
                local buttonInstance = button.New(
                    btn.Title,
                    btn.Icon,
                    btn.Callback,
                    btn.Variant or "Primary",
                    buttonFrame
                )
            end
            
            buttonFrame.Parent = dialogFrame
        end
        
        -- Animation
        overlay.BackgroundTransparency = 1
        dialogFrame.ImageTransparency = 1
        
        core.Tween(overlay, 0.2, {BackgroundTransparency = 0.5}):Play()
        core.Tween(dialogFrame, 0.2, {
            ImageTransparency = 0,
            Size = UDim2.new(0,400,0,dialogFrame.AbsoluteSize.Y)
        }):Play()
        
        -- Close function
        function dialog:Close()
            core.Tween(overlay, 0.2, {BackgroundTransparency = 1}):Play()
            core.Tween(dialogFrame, 0.2, {
                ImageTransparency = 1,
                Size = UDim2.new(0,400,0,0)
            }):Play()
            
            task.wait(0.2)
            overlay:Destroy()
        end
        
        -- Close on overlay click
        core.AddSignal(overlay.MouseButton1Click, dialog.Close)
        
        return dialog
    end
    
    return module
end

--[[ MODULE S: Built-in Themes ]]--
function WindUI.s()
    return function(core)
        return {
            Dark = {
                Name = "Dark",
                Accent = Color3.fromHex("#18181b"),
                Dialog = Color3.fromHex("#161616"),
                Outline = Color3.fromHex("#FFFFFF"),
                Text = Color3.fromHex("#FFFFFF"),
                Placeholder = Color3.fromHex("#7a7a7a"),
                Background = Color3.fromHex("#101010"),
                Button = Color3.fromHex("#52525b"),
                Icon = Color3.fromHex("#a1a1aa"),
                Toggle = Color3.fromHex("#33C759"),
                Checkbox = Color3.fromHex("#0091ff"),
            },
            Light = {
                Name = "Light",
                Accent = Color3.fromHex("#FFFFFF"),
                Dialog = Color3.fromHex("#f4f4f5"),
                Outline = Color3.fromHex("#09090b"),
                Text = Color3.fromHex("#000000"),
                Placeholder = Color3.fromHex("#555555"),
                Background = Color3.fromHex("#e4e4e7"),
                Button = Color3.fromHex("#18181b"),
                Icon = Color3.fromHex("#52525b"),
            },
            Rose = {
                Name = "Rose",
                Accent = Color3.fromHex("#be185d"),
                Dialog = Color3.fromHex("#4c0519"),
                Outline = Color3.fromHex("#fecdd3"),
                Text = Color3.fromHex("#fdf2f8"),
                Placeholder = Color3.fromHex("#d67aa6"),
                Background = Color3.fromHex("#1f0308"),
                Button = Color3.fromHex("#e11d48"),
                Icon = Color3.fromHex("#fb7185"),
            },
            Plant = {
                Name = "Plant",
                Accent = Color3.fromHex("#166534"),
                Dialog = Color3.fromHex("#052e16"),
                Outline = Color3.fromHex("#bbf7d0"),
                Text = Color3.fromHex("#f0fdf4"),
                Placeholder = Color3.fromHex("#4fbf7a"),
                Background = Color3.fromHex("#0a1b0f"),
                Button = Color3.fromHex("#16a34a"),
                Icon = Color3.fromHex("#4ade80"),
            },
            Red = {
                Name = "Red",
                Accent = Color3.fromHex("#991b1b"),
                Dialog = Color3.fromHex("#450a0a"),
                Outline = Color3.fromHex("#fecaca"),
                Text = Color3.fromHex("#fef2f2"),
                Placeholder = Color3.fromHex("#d95353"),
                Background = Color3.fromHex("#1c0606"),
                Button = Color3.fromHex("#dc2626"),
                Icon = Color3.fromHex("#ef4444"),
            },
            Indigo = {
                Name = "Indigo",
                Accent = Color3.fromHex("#3730a3"),
                Dialog = Color3.fromHex("#1e1b4b"),
                Outline = Color3.fromHex("#c7d2fe"),
                Text = Color3.fromHex("#f1f5f9"),
                Placeholder = Color3.fromHex("#7078d9"),
                Background = Color3.fromHex("#0f0a2e"),
                Button = Color3.fromHex("#4f46e5"),
                Icon = Color3.fromHex("#6366f1"),
            },
            Sky = {
                Name = "Sky",
                Accent = Color3.fromHex("#0369a1"),
                Dialog = Color3.fromHex("#0c4a6e"),
                Outline = Color3.fromHex("#bae6fd"),
                Text = Color3.fromHex("#f0f9ff"),
                Placeholder = Color3.fromHex("#4fb6d9"),
                Background = Color3.fromHex("#041f2e"),
                Button = Color3.fromHex("#0284c7"),
                Icon = Color3.fromHex("#0ea5e9"),
            },
            Violet = {
                Name = "Violet",
                Accent = Color3.fromHex("#6d28d9"),
                Dialog = Color3.fromHex("#3c1361"),
                Outline = Color3.fromHex("#ddd6fe"),
                Text = Color3.fromHex("#faf5ff"),
                Placeholder = Color3.fromHex("#8f7ee0"),
                Background = Color3.fromHex("#1e0a3e"),
                Button = Color3.fromHex("#7c3aed"),
                Icon = Color3.fromHex("#8b5cf6"),
            },
            Amber = {
                Name = "Amber",
                Accent = Color3.fromHex("#b45309"),
                Dialog = Color3.fromHex("#451a03"),
                Outline = Color3.fromHex("#fde68a"),
                Text = Color3.fromHex("#fffbeb"),
                Placeholder = Color3.fromHex("#d1a326"),
                Background = Color3.fromHex("#1c1003"),
                Button = Color3.fromHex("#d97706"),
                Icon = Color3.fromHex("#f59e0b"),
            },
            Emerald = {
                Name = "Emerald",
                Accent = Color3.fromHex("#047857"),
                Dialog = Color3.fromHex("#022c22"),
                Outline = Color3.fromHex("#a7f3d0"),
                Text = Color3.fromHex("#ecfdf5"),
                Placeholder = Color3.fromHex("#3fbf8f"),
                Background = Color3.fromHex("#011411"),
                Button = Color3.fromHex("#059669"),
                Icon = Color3.fromHex("#10b981"),
            },
            Midnight = {
                Name = "Midnight",
                Accent = Color3.fromHex("#1e3a8a"),
                Dialog = Color3.fromHex("#0c1e42"),
                Outline = Color3.fromHex("#bfdbfe"),
                Text = Color3.fromHex("#dbeafe"),
                Placeholder = Color3.fromHex("#2f74d1"),
                Background = Color3.fromHex("#0a0f1e"),
                Button = Color3.fromHex("#2563eb"),
                Icon = Color3.fromHex("#3b82f6"),
            },
            Crimson = {
                Name = "Crimson",
                Accent = Color3.fromHex("#b91c1c"),
                Dialog = Color3.fromHex("#450a0a"),
                Outline = Color3.fromHex("#fca5a5"),
                Text = Color3.fromHex("#fef2f2"),
                Placeholder = Color3.fromHex("#6f757b"),
                Background = Color3.fromHex("#0c0404"),
                Button = Color3.fromHex("#991b1b"),
                Icon = Color3.fromHex("#dc2626"),
            },
            MonokaiPro = {
                Name = "Monokai Pro",
                Accent = Color3.fromHex("#fc9867"),
                Dialog = Color3.fromHex("#1e1e1e"),
                Outline = Color3.fromHex("#78dce8"),
                Text = Color3.fromHex("#fcfcfa"),
                Placeholder = Color3.fromHex("#6f6f6f"),
                Background = Color3.fromHex("#191622"),
                Button = Color3.fromHex("#ab9df2"),
                Icon = Color3.fromHex("#a9dc76"),
            },
            CottonCandy = {
                Name = "Cotton Candy",
                Accent = Color3.fromHex("#ec4899"),
                Dialog = Color3.fromHex("#2d1b3d"),
                Outline = Color3.fromHex("#f9a8d4"),
                Text = Color3.fromHex("#fdf2f8"),
                Placeholder = Color3.fromHex("#8a5fd3"),
                Background = Color3.fromHex("#1a0b2e"),
                Button = Color3.fromHex("#d946ef"),
                Icon = Color3.fromHex("#06b6d4"),
            },
            Rainbow = {
                Name = "Rainbow",
                Accent = core:Gradient({
                    ["0"] = {Color = Color3.fromHex("#00ff41"), Transparency = 0},
                    ["33"] = {Color = Color3.fromHex("#00ffff"), Transparency = 0},
                    ["66"] = {Color = Color3.fromHex("#0080ff"), Transparency = 0},
                    ["100"] = {Color = Color3.fromHex("#8000ff"), Transparency = 0},
                }, {Rotation = 45}),
                Dialog = core:Gradient({
                    ["0"] = {Color = Color3.fromHex("#ff0080"), Transparency = 0},
                    ["25"] = {Color = Color3.fromHex("#8000ff"), Transparency = 0},
                    ["50"] = {Color = Color3.fromHex("#0080ff"), Transparency = 0},
                    ["75"] = {Color = Color3.fromHex("#00ff80"), Transparency = 0},
                    ["100"] = {Color = Color3.fromHex("#ff8000"), Transparency = 0},
                }, {Rotation = 135}),
                Outline = Color3.fromHex("#ffffff"),
                Text = Color3.fromHex("#ffffff"),
                Placeholder = Color3.fromHex("#00ff80"),
                Background = core:Gradient({
                    ["0"] = {Color = Color3.fromHex("#ff0040"), Transparency = 0},
                    ["20"] = {Color = Color3.fromHex("#ff4000"), Transparency = 0},
                    ["40"] = {Color = Color3.fromHex("#ffff00"), Transparency = 0},
                    ["60"] = {Color = Color3.fromHex("#00ff40"), Transparency = 0},
                    ["80"] = {Color = Color3.fromHex("#0040ff"), Transparency = 0},
                    ["100"] = {Color = Color3.fromHex("#4000ff"), Transparency = 0},
                }, {Rotation = 90}),
                Button = core:Gradient({
                    ["0"] = {Color = Color3.fromHex("#ff0080"), Transparency = 0},
                    ["25"] = {Color = Color3.fromHex("#ff8000"), Transparency = 0},
                    ["50"] = {Color = Color3.fromHex("#ffff00"), Transparency = 0},
                    ["75"] = {Color = Color3.fromHex("#80ff00"), Transparency = 0},
                    ["100"] = {Color = Color3.fromHex("#00ffff"), Transparency = 0},
                }, {Rotation = 60}),
                Icon = Color3.fromHex("#ffffff"),
            },
        }
    end
end

--[[ MODULE T: Label Component ]]--
function WindUI.t()
    local module = {}
    local core = WindUI.load('b')
    
    function module.New(text, icon, parent, isPlaceholder, cornerRadius)
        cornerRadius = cornerRadius or 10
        
        local iconFrame
        if icon and icon ~= "" then
            iconFrame = core.New("ImageLabel", {
                Image = core.Icon(icon)[1],
                ImageRectSize = core.Icon(icon)[2].ImageRectSize,
                ImageRectOffset = core.Icon(icon)[2].ImageRectPosition,
                Size = UDim2.new(0,21,0,21),
                BackgroundTransparency = 1,
                ThemeTag = {
                    ImageColor3 = "Icon",
                }
            })
        end
        
        local textLabel = core.New("TextLabel", {
            BackgroundTransparency = 1,
            TextSize = 17,
            FontFace = Font.new(core.Config.Font, Enum.FontWeight.Regular),
            Size = UDim2.new(1, iconFrame and -29 or 0, 1, 0),
            TextXAlignment = "Left",
            ThemeTag = {
                TextColor3 = isPlaceholder and "Placeholder" or "Text",
            },
            Text = text,
        })
        
        local labelFrame = core.New("TextButton", {
            Size = UDim2.new(1,0,0,42),
            Parent = parent,
            BackgroundTransparency = 1,
            Text = "",
        }, {
            core.New("Frame", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
            }, {
                -- Background
                core.NewRoundFrame(cornerRadius, "Squircle", {
                    ThemeTag = {
                        ImageColor3 = "Accent",
                    },
                    Size = UDim2.new(1,0,1,0),
                    ImageTransparency = 0.97,
                }),
                
                -- Outline
                core.NewRoundFrame(cornerRadius, "SquircleOutline", {
                    ThemeTag = {
                        ImageColor3 = "Outline",
                    },
                    Size = UDim2.new(1,0,1,0),
                    ImageTransparency = 0.95,
                }),
                
                -- Content
                core.NewRoundFrame(cornerRadius, "Squircle", {
                    Size = UDim2.new(1,0,1,0),
                    Name = "Frame",
                    ImageColor3 = Color3.new(1,1,1),
                    ImageTransparency = 0.95
                }, {
                    core.New("UIPadding", {
                        PaddingLeft = UDim.new(0,12),
                        PaddingRight = UDim.new(0,12),
                    }),
                    core.New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0,8),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    }),
                    iconFrame,
                    textLabel,
                })
            })
        })
        
        local methods = {
            SetText = function(self, newText)
                textLabel.Text = newText
            end,
            GetText = function(self)
                return textLabel.Text
            end
        }
        
        return labelFrame, methods
    end
    
    return module
end

--[[ MODULE U: Scrollbar Component ]]--
function WindUI.u()
    local module = {}
    local core = WindUI.load('b')
    
    function module.New(scrollingFrame, parent, width)
        width = width or 10
        
        local scrollbar = core.New("Frame", {
            Size = UDim2.new(0,width,1,0),
            Position = UDim2.new(1,0,0,0),
            AnchorPoint = Vector2.new(1,0),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        
        local track = core.New("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 0.95,
            ThemeTag = {
                BackgroundColor3 = "Text",
            },
        }, {
            core.New("UICorner", {CornerRadius = UDim.new(1,0)})
        })
        track.Parent = scrollbar
        
        local thumb = core.New("Frame", {
            Size = UDim2.new(1,0,0,50),
            Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 0.9,
            ThemeTag = {
                BackgroundColor3 = "Text",
            },
        }, {
            core.New("UICorner", {CornerRadius = UDim.new(1,0)})
        })
        thumb.Parent = track
        
        local function updateScrollbar()
            local canvasSize = scrollingFrame.CanvasSize.Y.Offset
            local windowSize = scrollingFrame.AbsoluteWindowSize.Y
            
            if canvasSize <= windowSize then
                scrollbar.Visible = false
                return
            end
            
            scrollbar.Visible = true
            
            local thumbHeight = math.max((windowSize / canvasSize) * track.AbsoluteSize.Y, 20)
            thumb.Size = UDim2.new(1,0,0,thumbHeight)
            
            local scrollPercent = scrollingFrame.CanvasPosition.Y / (canvasSize - windowSize)
            local maxThumbPosition = track.AbsoluteSize.Y - thumbHeight
            
            thumb.Position = UDim2.new(0,0,0,scrollPercent * maxThumbPosition)
        end
        
        local isDragging = false
        local dragStart = nil
        local thumbStart = nil
        
        core.AddSignal(thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                dragStart = input.Position.Y
                thumbStart = thumb.Position.Y.Offset
            end
        end))
        
        core.AddSignal(game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end))
        
        core.AddSignal(game:GetService("RunService").RenderStepped:Connect(function()
            if isDragging then
                local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local delta = mouse.Y - dragStart
                
                local newThumbPosition = math.clamp(thumbStart + delta, 0, track.AbsoluteSize.Y - thumb.AbsoluteSize.Y)
                thumb.Position = UDim2.new(0,0,0,newThumbPosition)
                
                local scrollPercent = newThumbPosition / (track.AbsoluteSize.Y - thumb.AbsoluteSize.Y)
                local canvasSize = scrollingFrame.CanvasSize.Y.Offset
                local windowSize = scrollingFrame.AbsoluteWindowSize.Y
                
                local newScrollPosition = scrollPercent * (canvasSize - windowSize)
                scrollingFrame.CanvasPosition = Vector2.new(0, newScrollPosition)
            end
        end))
        
        core.AddSignal(track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local trackPos = track.AbsolutePosition.Y
                local clickPosition = mouse.Y - trackPos - (thumb.AbsoluteSize.Y / 2)
                
                local newThumbPosition = math.clamp(clickPosition, 0, track.AbsoluteSize.Y - thumb.AbsoluteSize.Y)
                thumb.Position = UDim2.new(0,0,0,newThumbPosition)
                
                local scrollPercent = newThumbPosition / (track.AbsoluteSize.Y - thumb.AbsoluteSize.Y)
                local canvasSize = scrollingFrame.CanvasSize.Y.Offset
                local windowSize = scrollingFrame.AbsoluteWindowSize.Y
                
                local newScrollPosition = scrollPercent * (canvasSize - windowSize)
                scrollingFrame.CanvasPosition = Vector2.new(0, newScrollPosition)
                
                isDragging = true
                dragStart = mouse.Y
                thumbStart = newThumbPosition
            end
        end))
        
        core.AddSignal(scrollingFrame:GetPropertyChangedSignal("CanvasSize"):Connect(updateScrollbar))
        core.AddSignal(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateScrollbar))
        core.AddSignal(scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateScrollbar))
        
        updateScrollbar()
        
        return scrollbar
    end
    
    return module
end

--[[ MODULE V: Tag Component ]]--
function WindUI.v()
    local module = {}
    local core = WindUI.load('b')
    
    function module.New(options, parent)
        local tag = {
            Title = options.Title or "Tag",
            Icon = options.Icon,
            Color = options.Color or Color3.fromHex("#315dff"),
            Radius = options.Radius or 999,
        }
        
        local iconFrame
        if tag.Icon then
            iconFrame = core.Image(
                tag.Icon,
                tag.Icon,
                0,
                options.Window and options.Window.Folder or "Temp",
                "Tag",
                false
            )
            iconFrame.Size = UDim2.new(0,16,0,16)
        end
        
        local textLabel = core.New("TextLabel", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = 14,
            FontFace = Font.new(core.Config.Font, Enum.FontWeight.SemiBold),
            Text = tag.Title,
            TextColor3 = Color3.new(1,1,1),
        })
        
        local tagFrame = core.NewRoundFrame(tag.Radius, "Squircle", {
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0,0,0,26),
            Parent = parent,
            ImageColor3 = tag.Color,
        }, {
            core.New("UIPadding", {
                PaddingLeft = UDim.new(0,10),
                PaddingRight = UDim.new(0,10),
            }),
            iconFrame,
            textLabel,
            core.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0,6)
            })
        })
        
        function tag:SetTitle(newTitle)
            tag.Title = newTitle
            textLabel.Text = newTitle
        end
        
        function tag:SetColor(newColor)
            tag.Color = newColor
            core.Tween(tagFrame, 0.2, {ImageColor3 = newColor}):Play()
        end
        
        return tagFrame, tag
    end
    
    return module
end

--[[ MODULE W: Config Manager ]]--
function WindUI.w()
    local module = {}
    
    module.Parser = {
        Colorpicker = {
            Save = function(element)
                return {
                    __type = "Colorpicker",
                    value = element.Default:ToHex(),
                    transparency = element.Transparency or nil,
                }
            end,
            Load = function(element, data)
                if element and element.Update then
                    element:Update(Color3.fromHex(data.value), data.transparency or nil)
                end
            end
        },
        Dropdown = {
            Save = function(element)
                return {
                    __type = "Dropdown",
                    value = element.Value,
                }
            end,
            Load = function(element, data)
                if element and element.Select then
                    element:Select(data.value)
                end
            end
        },
        Input = {
            Save = function(element)
                return {
                    __type = "Input",
                    value = element.Value,
                }
            end,
            Load = function(element, data)
                if element and element.Set then
                    element:Set(data.value)
                end
            end
        },
        Keybind = {
            Save = function(element)
                return {
                    __type = "Keybind",
                    value = element.Value,
                }
            end,
            Load = function(element, data)
                if element and element.Set then
                    element:Set(data.value)
                end
            end
        },
        Slider = {
            Save = function(element)
                return {
                    __type = "Slider",
                    value = element.Value.Default,
                }
            end,
            Load = function(element, data)
                if element and element.Set then
                    element:Set(tonumber(data.value))
                end
            end
        },
        Toggle = {
            Save = function(element)
                return {
                    __type = "Toggle",
                    value = element.Value,
                }
            end,
            Load = function(element, data)
                if element and element.Set then
                    element:Set(data.value)
                end
            end
        },
    }
    
    function module.Init(window)
        if not window.Folder then
            warn("[WindUI.ConfigManager] Window.Folder is not specified.")
            return false
        end
        
        module.Folder = window.Folder
        module.Path = "WindUI/" .. module.Folder .. "/config/"
        module.Configs = {}
        
        if not isfolder then
            warn("[WindUI.ConfigManager] File system functions not available.")
            return module
        end
        
        if not isfolder("WindUI") then
            makefolder("WindUI")
        end
        
        if not isfolder("WindUI/" .. module.Folder) then
            makefolder("WindUI/" .. module.Folder)
        end
        
        if not isfolder(module.Path) then
            makefolder(module.Path)
        end
        
        return module
    end
    
    function module:CreateConfig(name)
        local config = {
            Path = module.Path .. name .. ".json",
            Elements = {},
            CustomData = {},
            Version = 1.0
        }
        
        function config:Register(id, element)
            config.Elements[id] = element
        end
        
        function config:Set(key, value)
            config.CustomData[key] = value
        end
        
        function config:Get(key)
            return config.CustomData[key]
        end
        
        function config:Save()
            local data = {
                __version = config.Version,
                __elements = {},
                __custom = config.CustomData
            }
            
            for id, element in pairs(config.Elements) do
                if element.__type and module.Parser[element.__type] then
                    data.__elements[tostring(id)] = module.Parser[element.__type].Save(element)
                end
            end
            
            if writefile then
                writefile(config.Path, game:GetService("HttpService"):JSONEncode(data))
                return true
            end
            
            return false
        end
        
        function config:Load()
            if not isfile or not readfile then
                warn("[WindUI.ConfigManager] File system not available.")
                return false
            end
            
            if not isfile(config.Path) then
                return false
            end
            
            local success, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile(config.Path))
            end)
            
            if not success then
                return false
            end
            
            for id, elementData in pairs(data.__elements or {}) do
                local element = config.Elements[id]
                if element and elementData.__type and module.Parser[elementData.__type] then
                    module.Parser[elementData.__type].Load(element, elementData)
                end
            end
            
            config.CustomData = data.__custom or {}
            
            return config.CustomData
        end
        
        function config:Delete()
            if not delfile then return false end
            if not isfile(config.Path) then return false end
            
            local success = pcall(delfile, config.Path)
            return success
        end
        
        module.Configs[name] = config
        return config
    end
    
    function module:GetConfig(name)
        return module.Configs[name]
    end
    
    function module:AllConfigs()
        if not listfiles then return {} end
        
        local configs = {}
        if not isfolder(module.Path) then return configs end
        
        for _, file in pairs(listfiles(module.Path)) do
            local name = file:match("([^\\/]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
        
        return configs
    end
    
    return module
end

--[[ MODULE X: Open Button (Mobile) ]]--
function WindUI.x()
    local module = {}
    local core = WindUI.load('b')
    
    function module.New(options, window)
        local openButton = {}
        
        local button = core.New("TextButton", {
            Size = UDim2.new(0,0,0,44),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 0.25,
            BackgroundColor3 = Color3.new(0,0,0),
            Parent = window.ScreenGui,
            Position = options.Position or UDim2.new(0,20,0,20),
        }, {
            core.New("UICorner", {CornerRadius = UDim.new(1,0)}),
            core.New("UIStroke", {
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.new(1,1,1),
                Transparency = 0,
            }, {
                core.New("UIGradient", {
                    Color = ColorSequence.new(Color3.fromHex("#40c9ff"), Color3.fromHex("#e81cff"))
                })
            }),
            
            core.New("UIListLayout", {
                Padding = UDim.new(0,4),
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
            
            core.New("TextButton", {
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                Size = UDim2.new(0,0,0,36),
                BackgroundColor3 = Color3.new(1,1,1),
            }, {
                core.New("UICorner", {CornerRadius = UDim.new(1,-4)}),
                core.New("UIListLayout", {
                    Padding = UDim.new(0,options.UIPadding or 8),
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),
                
                options.Icon and core.Image(
                    options.Icon,
                    options.Title,
                    0,
                    window.Folder,
                    "OpenButton",
                    true,
                    options.IconThemed
                ) or nil,
                
                core.New("TextLabel", {
                    Text = options.Title or "Open",
                    TextSize = 14,
                    FontFace = Font.new(core.Config.Font, Enum.FontWeight.Medium),
                    ThemeTag = {TextColor3 = "Text"},
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.XY,
                }),
                
                core.New("UIPadding", {
                    PaddingLeft = UDim.new(0,11),
                    PaddingRight = UDim.new(0,11),
                }),
            }),
            
            core.New("UIPadding", {
                PaddingLeft = UDim.new(0,4),
                PaddingRight = UDim.new(0,4),
            })
        })
        
        openButton.Button = button
        
        function openButton:SetVisible(visible)
            button.Visible = visible
        end
        
        core.AddSignal(button.MouseButton1Click, function()
            window.MainFrame.Visible = not window.MainFrame.Visible
        end)
        
        return openButton
    end
    
    return module
end

--[[ MODULE Y: Tooltip Component ]]--
function WindUI.y()
    local module = {}
    local core = WindUI.load('b')
    
    function module.New(text, parent)
        local tooltip = {}
        local tooltipSize = 16
        
        local textLabel = core.New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.XY,
            TextWrapped = true,
            BackgroundTransparency = 1,
            FontFace = Font.new(core.Config.Font, Enum.FontWeight.Medium),
            Text = text,
            TextSize = 14,
            TextTransparency = 1,
            ThemeTag = {TextColor3 = "Text"}
        })
        
        local container = core.New("Frame", {
            AnchorPoint = Vector2.new(0.5,0),
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundTransparency = 1,
            Parent = parent,
            Visible = false,
        }, {
            core.New("UISizeConstraint", {
                MaxSize = Vector2.new(300, math.huge)
            }),
            
            core.NewRoundFrame(14, "Squircle", {
                AutomaticSize = Enum.AutomaticSize.XY,
                ThemeTag = {ImageColor3 = "Accent"},
                ImageTransparency = 1,
                Name = "Background",
            }, {
                core.New("Frame", {
                    ThemeTag = {BackgroundColor3 = "Text"},
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                }, {
                    core.New("UICorner", {CornerRadius = UDim.new(0,16)}),
                    core.New("UIListLayout", {
                        Padding = UDim.new(0,12),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center
                    }),
                    textLabel,
                    core.New("UIPadding", {
                        PaddingTop = UDim.new(0,12),
                        PaddingLeft = UDim.new(0,12),
                        PaddingRight = UDim.new(0,12),
                        PaddingBottom = UDim.new(0,12),
                    }),
                })
            }),
            
            core.New("UIScale", {Scale = 0.9}),
            core.New("UIListLayout", {
                Padding = UDim.new(0,0),
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),
        })
        
        tooltip.Container = container
        
        function tooltip:Show()
            container.Visible = true
            core.Tween(container.Background, 0.2, {ImageTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            core.Tween(textLabel, 0.2, {TextTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            core.Tween(container.UIScale, 0.18, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        end
        
        function tooltip:Hide()
            core.Tween(container.Background, 0.3, {ImageTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            core.Tween(textLabel, 0.3, {TextTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            core.Tween(container.UIScale, 0.35, {Scale = 0.9}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            task.wait(0.35)
            container.Visible = false
            container:Destroy()
        end
        
        return tooltip
    end
    
    return module
end

--[[ MAIN WINDOW CREATION FUNCTION ]]--
function WindUI:CreateWindow(options)
    options = options or {}
    
    local window = {
        Title = options.Title or "WindUI",
        Author = options.Author or "Footagesus",
        Icon = options.Icon,
        Theme = options.Theme or "Dark",
        Size = options.Size or UDim2.new(0, 500, 0, 400),
        Position = options.Position or UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5),
        Resizable = options.Resizable ~= false,
        Debug = options.Debug or false,
        Folder = options.Folder or "WindUI",
        UseAcrylic = options.UseAcrylic or false,
        CanDropdown = true,
        
        UICorner = options.UICorner or 20,
        UIPadding = options.UIPadding or 12,
        
        Elements = {},
        Tabs = {},
        CurrentTab = nil,
        Services = WindUI.load('h'),
    }
    
    local core = WindUI.load('b')
    local notifications = WindUI.load('d')
    local button = WindUI.load('j')
    local input = WindUI.load('k')
    local dialog = WindUI.load('r')
    local themes = WindUI.load('s')(core)
    
    core.Init(window)
    
    local screenGui = core.New("ScreenGui", {
        Name = "WindUI",
        Parent = options.Parent or game.Players.LocalPlayer:WaitForChild("PlayerGui"),
    })
    
    window.ScreenGui = screenGui
    
    local mainFrame = core.NewRoundFrame(window.UICorner, "Squircle", {
        Size = window.Size,
        Position = window.Position,
        AnchorPoint = window.AnchorPoint,
        ThemeTag = {
            ImageColor3 = "WindowBackground",
        },
    })
    mainFrame.Parent = screenGui
    
    window.MainFrame = mainFrame
    
    local topBar = core.New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    }, {
        window.Icon and core.Image(
            window.Icon,
            window.Title,
            window.UICorner - 8,
            window.Folder,
            "WindowIcon",
            true,
            false,
            "WindowTopbarIcon"
        ) or nil,
        
        core.New("Frame", {
            Size = UDim2.new(1, window.Icon and -44 or -24, 0, 0),
            Position = window.Icon and UDim2.new(0, 44, 0, 0) or UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {
            core.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 2),
            }),
            
            core.New("TextLabel", {
                Text = window.Title,
                FontFace = Font.new(core.Config.Font, Enum.FontWeight.Bold),
                TextSize = 20,
                TextXAlignment = "Left",
                ThemeTag = {
                    TextColor3 = "WindowTopbarTitle",
                },
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            }),
            
            window.Author and core.New("TextLabel", {
                Text = window.Author,
                FontFace = Font.new(core.Config.Font, Enum.FontWeight.Regular),
                TextSize = 14,
                TextXAlignment = "Left",
                TextTransparency = 0.4,
                ThemeTag = {
                    TextColor3 = "WindowTopbarAuthor",
                },
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            }) or nil,
        }),
        
        core.New("ImageButton", {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(1, -12, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            Image = core.Icon("x")[1],
            ImageRectSize = core.Icon("x")[2].ImageRectSize,
            ImageRectOffset = core.Icon("x")[2].ImageRectPosition,
            BackgroundTransparency = 1,
            ThemeTag = {
                ImageColor3 = "WindowTopbarButtonIcon",
            },
        }),
    })
    
    window.TopBar = topBar
    
    local contentFrame = core.New("Frame", {
        Size = UDim2.new(1, -24, 1, -74),
        Position = UDim2.new(0.5, 0, 0.5, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    })
    
    window.ContentFrame = contentFrame
    
    local tabContainer = core.New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = mainFrame,
    }, {
        core.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }),
    })
    
    window.TabContainer = tabContainer
    
    core.Drag(mainFrame, topBar)
    
    local closeButton = topBar:FindFirstChildOfClass("ImageButton")
    if closeButton then
        core.AddSignal(closeButton.MouseButton1Click, function()
            core.DisconnectAll()
            screenGui:Destroy()
            window = nil
        end)
    end
    
    local notificationHolder = notifications.Init(screenGui)
    window.Notifications = notificationHolder
    
    function window:Notify(options)
        options.Window = window
        return notifications.New(options)
    end
    
    function window:Dialog(options)
        options.Window = window
        return dialog.New(options, window)
    end
    
    function window:SetTheme(themeName)
        core.Config.Themes = themes
        core.SetTheme(themeName)
        window.Theme = themeName
    end
    
    function window:AddTab(name, icon)
        local tab = {
            Name = name,
            Icon = icon,
            Elements = {},
            Visible = false,
        }
        
        local tabButton = core.New("TextButton", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "",
            Parent = tabContainer,
        }, {
            core.NewRoundFrame(10, "Squircle", {
                Size = UDim2.new(1, 0, 1, 0),
                ThemeTag = {
                    ImageColor3 = "TabBackground",
                },
                ImageTransparency = 1,
            }, {
                core.New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 8),
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),
                
                icon and core.New("ImageLabel", {
                    Image = core.Icon(icon)[1],
                    ImageRectSize = core.Icon(icon)[2].ImageRectSize,
                    ImageRectOffset = core.Icon(icon)[2].ImageRectPosition,
                    Size = UDim2.new(0, 20, 0, 20),
                    BackgroundTransparency = 1,
                    ThemeTag = {
                        ImageColor3 = "TabIcon",
                    },
                    ImageTransparency = 0.5,
                }) or nil,
                
                core.New("TextLabel", {
                    Text = name,
                    FontFace = Font.new(core.Config.Font, Enum.FontWeight.Medium),
                    TextSize = 14,
                    ThemeTag = {
                        TextColor3 = "TabTitle",
                    },
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                    AutomaticSize = Enum.AutomaticSize.XY,
                }),
                
                core.New("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                }),
            })
        })
        
        tab.Button = tabButton
        
        function tab:Select()
            for _, otherTab in pairs(window.Tabs) do
                otherTab.Visible = false
                if otherTab.Button then
                    core.Tween(otherTab.Button.Squircle, 0.2, {
                        ImageTransparency = 1
                    }):Play()
                    core.Tween(otherTab.Button.Squircle.TextLabel, 0.2, {
                        TextTransparency = 0.5
                    }):Play()
                    if otherTab.Button.Squircle.ImageLabel then
                        core.Tween(otherTab.Button.Squircle.ImageLabel, 0.2, {
                            ImageTransparency = 0.5
                        }):Play()
                    end
                end
            end
            
            tab.Visible = true
            core.Tween(tabButton.Squircle, 0.2, {
                ImageTransparency = 0.95
            }):Play()
            core.Tween(tabButton.Squircle.TextLabel, 0.2, {
                TextTransparency = 0
            }):Play()
            if tabButton.Squircle.ImageLabel then
                core.Tween(tabButton.Squircle.ImageLabel, 0.2, {
                    ImageTransparency = 0
                }):Play()
            end
            
            for _, element in pairs(tab.Elements) do
                if element and element.Parent then
                    element.Parent = contentFrame
                end
            end
            
            window.CurrentTab = tab
        end
        
        core.AddSignal(tabButton.MouseButton1Click, tab.Select)
        
        table.insert(window.Tabs, tab)
        
        if #window.Tabs == 1 then
            tabContainer.Visible = true
            contentFrame.Size = UDim2.new(1, -24, 1, -114)
            contentFrame.Position = UDim2.new(0.5, 0, 0.5, 32)
            tab:Select()
        end
        
        return tab
    end
    
    function window:Button(options)
        options = options or {}
        local btn = button.New(
            options.Text or "Button 🚀",
            options.Icon,
            options.Callback,
            options.Variant or "Primary",
            contentFrame,
            nil,
            options.NoShadow,
            options.CornerRadius or 10
        )
        
        if window.CurrentTab then
            table.insert(window.CurrentTab.Elements, btn)
        else
            table.insert(window.Elements, btn)
        end
        
        return btn
    end
    
    function window:Input(options)
        options = options or {}
        local inputFrame, inputObj = input.New(
            options.Placeholder or "Enter text...",
            options.Icon,
            contentFrame,
            options.Type or "Input",
            options.Callback,
            options.InstantUpdate,
            options.CornerRadius or 10,
            options.ClearOnFocus
        )
        
        if window.CurrentTab then
            table.insert(window.CurrentTab.Elements, inputFrame)
        else
            table.insert(window.Elements, inputFrame)
        end
        
        return inputFrame, inputObj
    end
    
    function window:Destroy()
        core.DisconnectAll()
        if screenGui then
            screenGui:Destroy()
        end
        window = nil
    end
    
    if options.Theme then
        window:SetTheme(options.Theme)
    else
        core.Config.Themes = themes
        core.SetTheme(window.Theme)
    end
    
    return window
end

-- Export
return WindUI