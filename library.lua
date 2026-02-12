local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local TWEEN_SPEED = 0.15
local UPDATE_RATE = 1/60
local lastUpdate = 0

local Theme = {
    Background = Color3.fromRGB(20, 15, 30),
    Secondary = Color3.fromRGB(30, 20, 45),
    Accent = Color3.fromRGB(120, 80, 200),
    AccentHover = Color3.fromRGB(140, 100, 220),
    Text = Color3.fromRGB(240, 240, 250),
    TextDim = Color3.fromRGB(160, 150, 180),
    Border = Color3.fromRGB(60, 40, 90),
    Success = Color3.fromRGB(100, 200, 120),
    Warning = Color3.fromRGB(220, 180, 80),
}

local function createTween(object, properties, duration)
    duration = duration or TWEEN_SPEED
    return TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad), properties)
end

local function createElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            element[prop] = value
        end
    end
    if properties.Parent then
        element.Parent = properties.Parent
    end
    return element
end

function Library:Init()
    local screenGui = createElement("ScreenGui", {
        Name = "HashUI_" .. tostring(math.random(1000, 9999)),
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    
    self.dragConnections = {}
    self.ScreenGui = screenGui
    
    return self
end

function Library:Window(config)
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil
    
    local mainFrame = createElement("Frame", {
        Name = "MainWindow",
        Parent = self.ScreenGui,
        Size = config.Size or UDim2.new(0, 700, 0, 500),
        Position = UDim2.new(0.5, -350, 0.5, -250),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
    })
    
    local corner = createElement("UICorner", {
        Parent = mainFrame,
        CornerRadius = UDim.new(0, 8),
    })
    
    local border = createElement("UIStroke", {
        Parent = mainFrame,
        Color = Theme.Border,
        Thickness = 1,
        Transparency = 0.5,
    })
    
    local titleBar = createElement("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
    })
    
    createElement("UICorner", {
        Parent = titleBar,
        CornerRadius = UDim.new(0, 8),
    })
    
    local titleLabel = createElement("TextLabel", {
        Parent = titleBar,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "Hash UI",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local closeButton = createElement("TextButton", {
        Parent = titleBar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BackgroundColor3 = Theme.Accent,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
    })
    
    createElement("UICorner", {
        Parent = closeButton,
        CornerRadius = UDim.new(0, 6),
    })
    
    closeButton.MouseButton1Click:Connect(function()
        createTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(TWEEN_SPEED)
        mainFrame.Visible = false
    end)
    
    closeButton.MouseEnter:Connect(function()
        createTween(closeButton, {BackgroundColor3 = Theme.AccentHover}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        createTween(closeButton, {BackgroundColor3 = Theme.Accent}):Play()
    end)
    
    local tabContainer = createElement("Frame", {
        Name = "TabContainer",
        Parent = mainFrame,
        Size = UDim2.new(0, 140, 1, -50),
        Position = UDim2.new(0, 5, 0, 45),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
    })
    
    createElement("UICorner", {
        Parent = tabContainer,
        CornerRadius = UDim.new(0, 6),
    })
    
    local tabList = createElement("UIListLayout", {
        Parent = tabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
    })
    
    createElement("UIPadding", {
        Parent = tabContainer,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })
    
    local contentFrame = createElement("Frame", {
        Name = "ContentFrame",
        Parent = mainFrame,
        Size = UDim2.new(1, -155, 1, -50),
        Position = UDim2.new(0, 150, 0, 45),
        BackgroundTransparency = 1,
    })
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragStart then
            local mouse = UserInputService:GetMouseLocation()
            local delta = mouse - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    function window:Tab(config)
        local tab = {}
        tab.Sections = {}
        
        local tabButton = createElement("TextButton", {
            Parent = tabContainer,
            Size = UDim2.new(1, -16, 0, 35),
            BackgroundColor3 = Theme.Background,
            Text = config.Title or "Tab",
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            BorderSizePixel = 0,
        })
        
        createElement("UICorner", {
            Parent = tabButton,
            CornerRadius = UDim.new(0, 6),
        })
        
        local tabContent = createElement("ScrollingFrame", {
            Name = "TabContent",
            Parent = contentFrame,
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        })
        
        local contentList = createElement("UIListLayout", {
            Parent = tabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
        })
        
        createElement("UIPadding", {
            Parent = tabContent,
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
        })
        
        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(window.Tabs) do
                t.Content.Visible = false
                createTween(t.Button, {
                    BackgroundColor3 = Theme.Background,
                    TextColor3 = Theme.TextDim
                }):Play()
            end

            tabContent.Visible = true
            createTween(tabButton, {
                BackgroundColor3 = Theme.Accent,
                TextColor3 = Theme.Text
            }):Play()
            
            window.CurrentTab = tab
        end)

        tabButton.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                createTween(tabButton, {BackgroundColor3 = Theme.Secondary}):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                createTween(tabButton, {BackgroundColor3 = Theme.Background}):Play()
            end
        end)
        
        tab.Button = tabButton
        tab.Content = tabContent
        table.insert(window.Tabs, tab)
        
        if #window.Tabs == 1 then
            tabButton.MouseButton1Click:Fire()
        end
        
        function tab:Section(config)
            local section = {}
            
            local sectionFrame = createElement("Frame", {
                Parent = tabContent,
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            
            createElement("UICorner", {
                Parent = sectionFrame,
                CornerRadius = UDim.new(0, 6),
            })
            
            local sectionTitle = createElement("TextLabel", {
                Parent = sectionFrame,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = config.Title or "Section",
                TextColor3 = Theme.Text,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local sectionContent = createElement("Frame", {
                Parent = sectionFrame,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 35),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            
            local contentLayout = createElement("UIListLayout", {
                Parent = sectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            })
            
            createElement("UIPadding", {
                Parent = sectionContent,
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            })
            
            function section:Checkbox(config, callback)
                local checkboxFrame = createElement("Frame", {
                    Parent = sectionContent,
                    Size = UDim2.new(1, -20, 0, 30),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                })
                
                createElement("UICorner", {
                    Parent = checkboxFrame,
                    CornerRadius = UDim.new(0, 5),
                })
                
                local checkboxLabel = createElement("TextLabel", {
                    Parent = checkboxFrame,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = config.Title or "Checkbox",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local checked = config.Default or false
                
                local checkboxButton = createElement("TextButton", {
                    Parent = checkboxFrame,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -25, 0.5, -10),
                    BackgroundColor3 = checked and Theme.Accent or Theme.Secondary,
                    Text = "",
                    BorderSizePixel = 0,
                })
                
                createElement("UICorner", {
                    Parent = checkboxButton,
                    CornerRadius = UDim.new(0, 4),
                })
                
                local checkmark = createElement("TextLabel", {
                    Parent = checkboxButton,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "✓",
                    TextColor3 = Theme.Text,
                    TextSize = 16,
                    Font = Enum.Font.GothamBold,
                    Visible = checked,
                })
                
                checkboxButton.MouseButton1Click:Connect(function()
                    checked = not checked
                    checkmark.Visible = checked
                    createTween(checkboxButton, {
                        BackgroundColor3 = checked and Theme.Accent or Theme.Secondary
                    }):Play()
                    
                    if callback then
                        task.spawn(callback, checked)
                    end
                end)
                
                return checkboxButton
            end
            
            function section:Slider(config, callback)
                local sliderFrame = createElement("Frame", {
                    Parent = sectionContent,
                    Size = UDim2.new(1, -20, 0, 50),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                })
                
                createElement("UICorner", {
                    Parent = sliderFrame,
                    CornerRadius = UDim.new(0, 5),
                })
                
                local sliderLabel = createElement("TextLabel", {
                    Parent = sliderFrame,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = config.Title or "Slider",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local valueLabel = createElement("TextLabel", {
                    Parent = sliderFrame,
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -60, 0, 5),
                    BackgroundTransparency = 1,
                    Text = tostring(config.Default or config.Min),
                    TextColor3 = Theme.Accent,
                    TextSize = 13,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                
                local sliderBar = createElement("Frame", {
                    Parent = sliderFrame,
                    Size = UDim2.new(1, -20, 0, 6),
                    Position = UDim2.new(0, 10, 1, -16),
                    BackgroundColor3 = Theme.Secondary,
                    BorderSizePixel = 0,
                })
                
                createElement("UICorner", {
                    Parent = sliderBar,
                    CornerRadius = UDim.new(1, 0),
                })
                
                local sliderFill = createElement("Frame", {
                    Parent = sliderBar,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                })
                
                createElement("UICorner", {
                    Parent = sliderFill,
                    CornerRadius = UDim.new(1, 0),
                })
                
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local value = default
                
                local function updateSlider(val)
                    value = math.clamp(val, min, max)
                    local percent = (value - min) / (max - min)
                    createTween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1):Play()
                    valueLabel.Text = tostring(math.floor(value)) .. (config.Suffix or "")
                    
                    if callback then
                        task.spawn(callback, math.floor(value))
                    end
                end
                
                updateSlider(default)
                
                local dragging = false
                
                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                sliderBar.InputChanged:Connect(function(input)
                    if dragging then
                        local mouse = UserInputService:GetMouseLocation()
                        local barPos = sliderBar.AbsolutePosition.X
                        local barSize = sliderBar.AbsoluteSize.X
                        local percent = math.clamp((mouse.X - barPos) / barSize, 0, 1)
                        updateSlider(min + (percent * (max - min)))
                    end
                end)
                
                return sliderFrame
            end
            
            function section:Keybind(config, onPress, onChange)
                local keybindFrame = createElement("Frame", {
                    Parent = sectionContent,
                    Size = UDim2.new(1, -20, 0, 30),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                })
                
                createElement("UICorner", {
                    Parent = keybindFrame,
                    CornerRadius = UDim.new(0, 5),
                })
                
                local keybindLabel = createElement("TextLabel", {
                    Parent = keybindFrame,
                    Size = UDim2.new(1, -80, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = config.Title or "Keybind",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local currentKey = config.Key
                local binding = false
                
                local keybindButton = createElement("TextButton", {
                    Parent = keybindFrame,
                    Size = UDim2.new(0, 60, 0, 22),
                    Position = UDim2.new(1, -65, 0.5, -11),
                    BackgroundColor3 = Theme.Accent,
                    Text = currentKey and currentKey.Name or "None",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                })
                
                createElement("UICorner", {
                    Parent = keybindButton,
                    CornerRadius = UDim.new(0, 4),
                })
                
                keybindButton.MouseButton1Click:Connect(function()
                    binding = true
                    keybindButton.Text = "..."
                    createTween(keybindButton, {BackgroundColor3 = Theme.AccentHover}):Play()
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if binding then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            binding = false
                            currentKey = input.KeyCode
                            keybindButton.Text = input.KeyCode.Name
                            createTween(keybindButton, {BackgroundColor3 = Theme.Accent}):Play()
                            
                            if onChange then
                                task.spawn(onChange, input.KeyCode)
                            end
                        end
                    elseif not gameProcessed and currentKey and input.KeyCode == currentKey then
                        if onPress then
                            task.spawn(onPress)
                        end
                    end
                end)
                
                return keybindFrame
            end
            
            function section:Label(config)
                local labelFrame = createElement("TextLabel", {
                    Parent = sectionContent,
                    Size = UDim2.new(1, -20, 0, 25),
                    BackgroundTransparency = 1,
                    Text = config.Title or "Label",
                    TextColor3 = Theme.TextDim,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                return labelFrame
            end
            
            return section
        end
        
        return tab
    end
    
    return window
end

_G.UI = Library:Init()
return Library
