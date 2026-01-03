--!strict
-- Neverwin-style UI Library
-- Place this as a ModuleScript, e.g. ReplicatedStorage.UI.NeverwinLib

local NeverwinLib = {}

-- // Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- CONSTANTS / STYLE
---------------------------------------------------------------------

local THEME = {
    Background = Color3.fromRGB(12, 12, 16),
    BackgroundAlt = Color3.fromRGB(18, 18, 25),
    Border = Color3.fromRGB(50, 50, 70),
    Accent = Color3.fromRGB(145, 100, 255),
    AccentSoft = Color3.fromRGB(110, 80, 200),
    Text = Color3.fromRGB(220, 220, 235),
    TextDim = Color3.fromRGB(150, 150, 170),
    SectionHeader = Color3.fromRGB(200, 200, 220),
    Button = Color3.fromRGB(25, 25, 35),
    ButtonHover = Color3.fromRGB(35, 35, 50),
    ToggleOn = Color3.fromRGB(145, 100, 255),
    ToggleOff = Color3.fromRGB(30, 30, 40),
    SliderTrack = Color3.fromRGB(35, 35, 50),
    SliderFill = Color3.fromRGB(145, 100, 255),
    DropdownBackground = Color3.fromRGB(18, 18, 25),
}

local FONT = Enum.Font.Gotham

---------------------------------------------------------------------
-- UTILS
---------------------------------------------------------------------

local function create(className: string, props: {[string]: any}, children: {Instance}?): Instance
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        (inst :: any)[k] = v
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

local function makeOutline(frame: Frame)
    create("UIStroke", {
        Parent = frame,
        Color = THEME.Border,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
    })
end

local function makeCorner(parent: Instance, radius: number?)
    create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 4),
    })
end

local function tweenProperty(obj: Instance, props: {[string]: any}, time_: number?)
    local TweenService = game:GetService("TweenService")
    local info = TweenInfo.new(time_ or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

---------------------------------------------------------------------
-- BASE WINDOW
---------------------------------------------------------------------

-- API: local window = NeverwinLib:CreateWindow("NEVERWIN", "ernanto")
function NeverwinLib:CreateWindow(titleText: string, userName: string)
    local screenGui = create("ScreenGui", {
        Name = "NeverwinUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    }, {})
    screenGui.Parent = PlayerGui

    local mainFrame = create("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        Size = UDim2.new(0, 750, 0, 450),
        Position = UDim2.new(0.5, -375, 0.5, -225),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
    }, {})
    makeOutline(mainFrame)
    makeCorner(mainFrame, 8)

    -- Top bar
    local topBar = create("Frame", {
        Name = "TopBar",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.BackgroundAlt,
        BorderSizePixel = 0,
    }, {})
    makeOutline(topBar)
    makeCorner(topBar, 8)

    local titleLabel = create("TextLabel", {
        Parent = topBar,
        Text = titleText or "NEVERWIN",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT,
        TextColor3 = THEME.Text,
        TextSize = 16,
    }, {})

    local userLabel = create("TextLabel", {
        Parent = topBar,
        Text = userName or LocalPlayer.Name,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = FONT,
        TextColor3 = THEME.TextDim,
        TextSize = 14,
    }, {})

    -- Left tab column
    local leftTabs = create("Frame", {
        Name = "LeftTabs",
        Parent = mainFrame,
        BackgroundColor3 = THEME.BackgroundAlt,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 34),
        Size = UDim2.new(0, 160, 1, -34),
    }, {})
    makeOutline(leftTabs)

    local leftLayout = create("UIListLayout", {
        Parent = leftTabs,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, {})
    create("UIPadding", {
        Parent = leftTabs,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, {})

    -- Right content area
    local rightContent = create("Frame", {
        Name = "RightContent",
        Parent = mainFrame,
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 160, 0, 34),
        Size = UDim2.new(1, -160, 1, -34),
        ClipsDescendants = true,
    }, {})

    -- Simple drag for window
    do
        local dragging = false
        local dragStart
        local startPos

        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)

        topBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -----------------------------------------------------------------
    -- TAB SYSTEM
    -----------------------------------------------------------------

    local Window = {}
    Window._Tabs = {}
    Window._CurrentTab = nil
    Window._ScreenGui = screenGui
    Window._MainFrame = mainFrame
    Window._RightContent = rightContent
    Window._LeftTabs = leftTabs

    function Window:SetVisible(visible: boolean)
        screenGui.Enabled = visible
    end

    -- API: local tab = window:CreateTab("Combat")
    function Window:CreateTab(name: string)
        local tabButton = create("TextButton", {
            Parent = leftTabs,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = THEME.Button,
            BorderSizePixel = 0,
            Text = name,
            Font = FONT,
            TextColor3 = THEME.TextDim,
            TextSize = 14,
            AutoButtonColor = false,
        }, {})
        makeCorner(tabButton, 4)
        makeOutline(tabButton)

        local tabFrame = create("Frame", {
            Name = name .. "_TabFrame",
            Parent = rightContent,
            BackgroundColor3 = THEME.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        }, {})
        create("UIPadding", {
            Parent = tabFrame,
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
        }, {})

        local tabLayout = create("UIListLayout", {
            Parent = tabFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
        }, {})

        local Tab = {}
        Tab._Name = name
        Tab._Button = tabButton
        Tab._Frame = tabFrame
        Tab._Window = Window

        table.insert(Window._Tabs, Tab)

        local function selectTab()
            for _, otherTab in ipairs(Window._Tabs) do
                local isSelected = (otherTab == Tab)
                otherTab._Frame.Visible = isSelected
                tweenProperty(otherTab._Button, {
                    BackgroundColor3 = isSelected and THEME.AccentSoft or THEME.Button,
                    TextColor3 = isSelected and THEME.Text or THEME.TextDim,
                })
            end
            Window._CurrentTab = Tab
        end

        tabButton.MouseButton1Click:Connect(selectTab)

        if not Window._CurrentTab then
            selectTab()
        end

        -- SECTION API
        -- API: local section = tab:CreateSection("Silent Aim")
        function Tab:CreateSection(sectionName: string)
            local sectionFrame = create("Frame", {
                Parent = tabFrame,
                BackgroundColor3 = THEME.BackgroundAlt,
                BorderSizePixel = 0,
                Size = UDim2.new(0.5, -6, 1, 0),
            }, {})
            makeCorner(sectionFrame, 6)
            makeOutline(sectionFrame)

            local sectionPadding = create("UIPadding", {
                Parent = sectionFrame,
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            }, {})
            local sectionLayout = create("UIListLayout", {
                Parent = sectionFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
            }, {})

            local header = create("TextLabel", {
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Font = FONT,
                TextColor3 = THEME.SectionHeader,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = sectionName,
            }, {})

            local Section = {}
            Section._Frame = sectionFrame

            -------------------------------------------------------------
            -- TOGGLE
            -------------------------------------------------------------
            -- API: section:Toggle("Enable Silent Aim", true, function(v) end)
            function Section:Toggle(label: string, default: boolean, callback: (boolean) -> ())
                local row = create("Frame", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                }, {})
                local labelText = create("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = FONT,
                    TextColor3 = THEME.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = label,
                }, {})

                local toggleButton = create("TextButton", {
                    Parent = row,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 32, 0, 16),
                    BackgroundColor3 = default and THEME.ToggleOn or THEME.ToggleOff,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                }, {})
                makeCorner(toggleButton, 3)
                makeOutline(toggleButton)

                local knob = create("Frame", {
                    Parent = toggleButton,
                    Size = UDim2.new(0, 14, 0, 12),
                    Position = default and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(240, 240, 255),
                    BorderSizePixel = 0,
                }, {})
                makeCorner(knob, 3)

                local state = default or false
                if callback then
                    task.spawn(callback, state)
                end

                local function setState(newState: boolean)
                    state = newState
                    tweenProperty(toggleButton, {
                        BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff,
                    })
                    tweenProperty(knob, {
                        Position = state and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    })
                    if callback then
                        task.spawn(callback, state)
                    end
                end

                toggleButton.MouseButton1Click:Connect(function()
                    setState(not state)
                end)

                local ToggleObj = {}
                function ToggleObj:Set(value: boolean)
                    setState(value)
                end

                return ToggleObj
            end

            -------------------------------------------------------------
            -- SLIDER
            -------------------------------------------------------------
            -- API: section:Slider("Distance", 0, 2000, 1000, function(v) end)
            function Section:Slider(label: string, minVal: number, maxVal: number, default: number, callback: (number) -> ())
                minVal = minVal or 0
                maxVal = maxVal or 100
                default = math.clamp(default or minVal, minVal, maxVal)

                local row = create("Frame", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                }, {})

                local top = create("Frame", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                }, {})
                local labelText = create("TextLabel", {
                    Parent = top,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = FONT,
                    TextColor3 = THEME.Text,
                    TextSize = 14,
                    Text = label,
                }, {})
                local valueText = create("TextLabel", {
                    Parent = top,
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Font = FONT,
                    TextColor3 = THEME.TextDim,
                    TextSize = 13,
                    Text = tostring(default),
                }, {})

                local track = create("Frame", {
                    Parent = row,
                    BackgroundColor3 = THEME.SliderTrack,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, 20),
                }, {})
                makeCorner(track, 4)

                local fill = create("Frame", {
                    Parent = track,
                    BackgroundColor3 = THEME.SliderFill,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 1, 0),
                }, {})
                makeCorner(fill, 4)

                local knob = create("Frame", {
                    Parent = track,
                    Size = UDim2.new(0, 12, 0, 12),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(240, 240, 255),
                    BorderSizePixel = 0,
                }, {})
                makeCorner(knob, 6)

                local dragging = false
                local value = default

                local function updateVisualFromValue()
                    local alpha = (value - minVal) / (maxVal - minVal)
                    alpha = math.clamp(alpha, 0, 1)
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    knob.Position = UDim2.new(alpha, 0, 0.5, 0)
                    valueText.Text = tostring(math.floor(value * 100) / 100)
                end

                local function setValue(newValue: number, fromInput: boolean?)
                    newValue = math.clamp(newValue, minVal, maxVal)
                    value = newValue
                    updateVisualFromValue()
                    if callback then
                        task.spawn(callback, value)
                    end
                end

                updateVisualFromValue()

                local function inputToValue(inputPos: Vector2)
                    local relX = inputPos.X - track.AbsolutePosition.X
                    local ratio = relX / track.AbsoluteSize.X
                    ratio = math.clamp(ratio, 0, 1)
                    local v = minVal + (maxVal - minVal) * ratio
                    return v
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        setValue(inputToValue(input.Position), true)
                    end
                end)
                knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        setValue(inputToValue(input.Position), true)
                    end
                end)

                local SliderObj = {}
                function SliderObj:Set(newValue: number)
                    setValue(newValue, false)
                end
                function SliderObj:Get()
                    return value
                end

                return SliderObj
            end

            -------------------------------------------------------------
            -- TEXT INPUT
            -------------------------------------------------------------
            -- API: section:Input("Config Name", "Default", function(text) end)
            function Section:Input(label: string, placeholder: string?, callback: (string) -> ())
                local row = create("Frame", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                }, {})

                local labelText = create("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Font = FONT,
                    TextColor3 = THEME.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = label,
                }, {})

                local box = create("TextBox", {
                    Parent = row,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = THEME.Button,
                    Text = placeholder or "",
                    PlaceholderText = placeholder or "",
                    Font = FONT,
                    TextSize = 14,
                    TextColor3 = THEME.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0,
                }, {})
                makeCorner(box, 4)
                makeOutline(box)

                box.FocusLost:Connect(function(enterPressed)
                    if callback then
                        task.spawn(callback, box.Text)
                    end
                end)

                local InputObj = {}
                function InputObj:Set(text: string)
                    box.Text = text
                    if callback then
                        task.spawn(callback, box.Text)
                    end
                end
                function InputObj:Get()
                    return box.Text
                end

                return InputObj
            end

            -------------------------------------------------------------
            -- DROPDOWN
            -------------------------------------------------------------
            -- API: section:Dropdown("Mode", {"A","B"}, "A", function(v) end)
            function Section:Dropdown(label: string, options: {string}, default: string?, callback: (string) -> ())
                local current = default or options[1] or ""

                local row = create("Frame", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                }, {})

                local labelText = create("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Font = FONT,
                    TextColor3 = THEME.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = label,
                }, {})

                local button = create("TextButton", {
                    Parent = row,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundColor3 = THEME.Button,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                }, {})
                makeCorner(button, 4)
                makeOutline(button)

                local valueLabel = create("TextLabel", {
                    Parent = button,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 6, 0, 0),
                    Font = FONT,
                    TextColor3 = THEME.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = current,
                }, {})

                local arrow = create("TextLabel", {
                    Parent = button,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    BackgroundTransparency = 1,
                    Font = FONT,
                    Text = "▼",
                    TextColor3 = THEME.TextDim,
                    TextSize = 12,
                }, {})

                local listFrame = create("Frame", {
                    Parent = button,
                    BackgroundColor3 = THEME.DropdownBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 4),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    ClipsDescendants = true,
                }, {})
                makeCorner(listFrame, 4)
                makeOutline(listFrame)

                local listLayout = create("UIListLayout", {
                    Parent = listFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                }, {})
                create("UIPadding", {
                    Parent = listFrame,
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                }, {})

                local optionButtons = {}

                local function refreshSize()
                    local totalHeight = 0
                    for _, opt in ipairs(optionButtons) do
                        totalHeight += opt.AbsoluteSize.Y + listLayout.Padding.Offset
                    end
                    listFrame.Size = UDim2.new(1, 0, 0, totalHeight + 8)
                end

                local function setCurrent(newVal: string)
                    current = newVal
                    valueLabel.Text = current
                    if callback then
                        task.spawn(callback, current)
                    end
                end

                for _, opt in ipairs(options) do
                    local optButton = create("TextButton", {
                        Parent = listFrame,
                        BackgroundColor3 = THEME.Button,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = FONT,
                        TextColor3 = THEME.Text,
                        TextSize = 13,
                        Text = opt,
                        AutoButtonColor = false,
                    }, {})
                    makeCorner(optButton, 3)

                    optButton.MouseEnter:Connect(function()
                        tweenProperty(optButton, {BackgroundColor3 = THEME.ButtonHover})
                    end)
                    optButton.MouseLeave:Connect(function()
                        tweenProperty(optButton, {BackgroundColor3 = THEME.Button})
                    end)

                    optButton.MouseButton1Click:Connect(function()
                        setCurrent(opt)
                        listFrame.Visible = false
                    end)

                    table.insert(optionButtons, optButton)
                end
                refreshSize()

                button.MouseButton1Click:Connect(function()
                    listFrame.Visible = not listFrame.Visible
                end)

                if current ~= "" and callback then
                    task.spawn(callback, current)
                end

                local DropdownObj = {}
                function DropdownObj:Set(value: string)
                    setCurrent(value)
                end
                function DropdownObj:Get()
                    return current
                end

                return DropdownObj
            end

            -------------------------------------------------------------
            -- BUTTON
            -------------------------------------------------------------
            -- API: section:Button("Save Config", function() end)
            function Section:Button(label: string, callback: () -> ())
                local button = create("TextButton", {
                    Parent = sectionFrame,
                    BackgroundColor3 = THEME.Button,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 26),
                    Text = label,
                    Font = FONT,
                    TextColor3 = THEME.Text,
                    TextSize = 14,
                    AutoButtonColor = false,
                }, {})
                makeCorner(button, 4)
                makeOutline(button)

                button.MouseEnter:Connect(function()
                    tweenProperty(button, {BackgroundColor3 = THEME.ButtonHover})
                end)
                button.MouseLeave:Connect(function()
                    tweenProperty(button, {BackgroundColor3 = THEME.Button})
                end)

                button.MouseButton1Click:Connect(function()
                    if callback then
                        task.spawn(callback)
                    end
                end)

                local ButtonObj = {}
                function ButtonObj:Fire()
                    if callback then
                        task.spawn(callback)
                    end
                end

                return ButtonObj
            end

            return Section
        end

        return Tab
    end

    return Window
end

return NeverwinLib
