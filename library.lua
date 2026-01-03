--!strict
-- Mask / Neverwin-style UI Library
-- Single-module UI framework with categories, tabs, sections, and elements.

local Library = {}

-- services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- THEME / UTILS
---------------------------------------------------------------------

local THEME = {
    Background = Color3.fromRGB(12, 12, 16),
    BackgroundAlt = Color3.fromRGB(18, 18, 25),
    Sidebar = Color3.fromRGB(15, 15, 22),
    Border = Color3.fromRGB(45, 45, 65),
    Accent = Color3.fromRGB(145, 100, 255),
    AccentSoft = Color3.fromRGB(110, 80, 200),
    Text = Color3.fromRGB(225, 225, 240),
    TextDim = Color3.fromRGB(150, 150, 180),
    SectionHeader = Color3.fromRGB(200, 200, 230),
    Button = Color3.fromRGB(25, 25, 35),
    ButtonHover = Color3.fromRGB(35, 35, 50),
    ToggleOn = Color3.fromRGB(145, 100, 255),
    ToggleOff = Color3.fromRGB(30, 30, 40),
    SliderTrack = Color3.fromRGB(35, 35, 50),
    SliderFill = Color3.fromRGB(145, 100, 255),
    DropdownBackground = Color3.fromRGB(18, 18, 25),
}

local FONT = Enum.Font.Gotham

local function create(class: string, props: {[string]: any}, children: {Instance}?): Instance
    local inst = Instance.new(class)
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

local function makeStroke(parent: Instance)
    create("UIStroke", {
        Parent = parent,
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

local function tween(obj: Instance, props: {[string]: any}, t: number?)
    local info = TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

-- API:
-- local window = Library:CreateWindow("NEVERWIN")
function Library:CreateWindow(titleText: string)
    local screenGui = create("ScreenGui", {
        Name = "MaskUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    }, {})
    screenGui.Parent = PlayerGui

    local main = create("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        Size = UDim2.new(0, 800, 0, 480),
        Position = UDim2.new(0.5, -400, 0.5, -240),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
    }, {})
    makeCorner(main, 8)
    makeStroke(main)

    -- top bar
    local topBar = create("Frame", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.BackgroundAlt,
        BorderSizePixel = 0,
    }, {})
    makeCorner(topBar, 8)
    makeStroke(topBar)

    local title = create("TextLabel", {
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = FONT,
        Text = titleText or "NEVERWIN",
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = THEME.Text,
    }, {})

    -- sidebar
    local sidebar = create("Frame", {
        Parent = main,
        Position = UDim2.new(0, 0, 0, 34),
        Size = UDim2.new(0, 210, 1, -34),
        BackgroundColor3 = THEME.Sidebar,
        BorderSizePixel = 0,
    }, {})
    makeStroke(sidebar)

    local sidebarPadding = create("UIPadding", {
        Parent = sidebar,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 34),
    }, {})

    local sidebarLayout = create("UIListLayout", {
        Parent = sidebar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, {})

    -- username footer
    local userFooter = create("TextLabel", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        Text = LocalPlayer.Name,
        Font = FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = THEME.TextDim,
    }, {})
    userFooter.LayoutOrder = 9999

    -- main content area
    local content = create("Frame", {
        Parent = main,
        Position = UDim2.new(0, 210, 0, 34),
        Size = UDim2.new(1, -210, 1, -34),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, {})

    local Window = {}
    Window._Gui = screenGui
    Window._Main = main
    Window._Content = content
    Window._Sidebar = sidebar
    Window._Categories = {}
    Window._CurrentTabFrame = nil

    -- drag logic for top bar
    do
        local dragging = false
        local dragStart: Vector2?
        local startPos: UDim2?

        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)

        topBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    function Window:SetVisible(v: boolean)
        screenGui.Enabled = v
    end

    -- API:
    -- local cat = window:CreateCategory("Combat")
    function Window:CreateCategory(name: string)
        local header = create("TextLabel", {
            Parent = sidebar,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = FONT,
            Text = name,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = THEME.TextDim,
        }, {})
        header.LayoutOrder = #Window._Categories * 50 + 1

        local Category = {}
        Category._Window = Window
        Category._Header = header
        Category._Tabs = {}

        -- API:
        -- local tab = cat:CreateTab("Combat")
        function Category:CreateTab(tabName: string)
            local order = header.LayoutOrder + #Category._Tabs + 1

            local tabButton = create("TextButton", {
                Parent = sidebar,
                LayoutOrder = order,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = THEME.Button,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = tabName,
                Font = FONT,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = THEME.TextDim,
            }, {})
            makeCorner(tabButton, 3)
            makeStroke(tabButton)

            -- indent text slightly
            local pad = create("UIPadding", {
                Parent = tabButton,
                PaddingLeft = UDim.new(0, 8),
            }, {})

            local tabFrame = create("Frame", {
                Parent = content,
                BackgroundColor3 = THEME.Background,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false,
            }, {})

            local tabPadding = create("UIPadding", {
                Parent = tabFrame,
                PaddingTop = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12),
            }, {})

            local tabLayout = create("UIListLayout", {
                Parent = tabFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 10),
            }, {})

            local Tab = {}
            Tab._Category = Category
            Tab._Button = tabButton
            Tab._Frame = tabFrame
            Tab._Sections = {}

            table.insert(Category._Tabs, Tab)

            local function selectTab()
                if Window._CurrentTabFrame then
                    Window._CurrentTabFrame.Visible = false
                end
                Window._CurrentTabFrame = tabFrame
                tabFrame.Visible = true

                -- highlight state
                for _, cat in ipairs(Window._Categories) do
                    for _, otherTab in ipairs(cat._Tabs) do
                        local selected = (otherTab == Tab)
                        tween(otherTab._Button, {
                            BackgroundColor3 = selected and THEME.AccentSoft or THEME.Button,
                            TextColor3 = selected and THEME.Text or THEME.TextDim,
                        }, 0.12)
                    end
                end
            end

            tabButton.MouseButton1Click:Connect(selectTab)

            -- first created tab becomes default
            if not Window._CurrentTabFrame then
                selectTab()
            end

            -- sections (left and right column)
            -- API:
            -- local section = Tab:CreateSection("Silent Aim", "Left") -- or "Right"
            function Tab:CreateSection(sectionName: string, column: string?)
                local col = string.lower(column or "left")
                local isLeft = (col ~= "right")

                local sectionFrame = create("Frame", {
                    Parent = tabFrame,
                    BackgroundColor3 = THEME.BackgroundAlt,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.5, -5, 1, 0),
                }, {})
                makeCorner(sectionFrame, 6)
                makeStroke(sectionFrame)

                -- ensure layout orders cause left then right
                if isLeft then
                    sectionFrame.LayoutOrder = 1
                else
                    sectionFrame.LayoutOrder = 2
                end

                local sectionPadding = create("UIPadding", {
                    Parent = sectionFrame,
                    PaddingTop = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10),
                }, {})

                local sectionLayout = create("UIListLayout", {
                    Parent = sectionFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                }, {})

                local header = create("TextLabel", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = FONT,
                    Text = sectionName,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = THEME.SectionHeader,
                }, {})

                local Section = {}
                Section._Frame = sectionFrame

                ---------------------------------------------------------
                -- TOGGLE
                ---------------------------------------------------------
                function Section:Toggle(label: string, default: boolean, callback: (boolean) -> ())
                    local row = create("Frame", {
                        Parent = sectionFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 24),
                    }, {})

                    local text = create("TextLabel", {
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -40, 1, 0),
                        Font = FONT,
                        Text = label,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = THEME.Text,
                    }, {})

                    local toggle = create("TextButton", {
                        Parent = row,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0, 34, 0, 16),
                        BackgroundColor3 = default and THEME.ToggleOn or THEME.ToggleOff,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "",
                    }, {})
                    makeCorner(toggle, 3)
                    makeStroke(toggle)

                    local knob = create("Frame", {
                        Parent = toggle,
                        Size = UDim2.new(0, 14, 0, 12),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = default and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(240, 240, 255),
                        BorderSizePixel = 0,
                    }, {})
                    makeCorner(knob, 3)

                    local state = default or false
                    if callback then
                        task.spawn(callback, state)
                    end

                    local function setState(v: boolean)
                        state = v
                        tween(toggle, {
                            BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff,
                        })
                        tween(knob, {
                            Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                        })
                        if callback then
                            task.spawn(callback, state)
                        end
                    end

                    toggle.MouseButton1Click:Connect(function()
                        setState(not state)
                    end)

                    local ToggleObj = {}
                    function ToggleObj:Set(v: boolean)
                        setState(v)
                    end
                    function ToggleObj:Get()
                        return state
                    end

                    return ToggleObj
                end

                ---------------------------------------------------------
                -- SLIDER
                ---------------------------------------------------------
                function Section:Slider(label: string, min: number, max: number, default: number, callback: (number) -> ())
                    min = min or 0
                    max = max or 100
                    default = math.clamp(default or min, min, max)

                    local row = create("Frame", {
                        Parent = sectionFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 34),
                    }, {})

                    local topRow = create("Frame", {
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                    }, {})

                    local labelText = create("TextLabel", {
                        Parent = topRow,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.6, 0, 1, 0),
                        Font = FONT,
                        Text = label,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = THEME.Text,
                    }, {})

                    local valueText = create("TextLabel", {
                        Parent = topRow,
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0.4, 0, 1, 0),
                        Font = FONT,
                        Text = tostring(default),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextColor3 = THEME.TextDim,
                    }, {})

                    local track = create("Frame", {
                        Parent = row,
                        BackgroundColor3 = THEME.SliderTrack,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 20),
                        Size = UDim2.new(1, 0, 0, 10),
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
                        BackgroundColor3 = Color3.fromRGB(240, 240, 255),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 12, 0, 12),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                    }, {})
                    makeCorner(knob, 6)

                    local value = default
                    local dragging = false

                    local function updateVisual()
                        local alpha = (value - min) / (max - min)
                        alpha = math.clamp(alpha, 0, 1)
                        fill.Size = UDim2.new(alpha, 0, 1, 0)
                        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
                        valueText.Text = tostring(math.floor(value * 100) / 100)
                    end

                    local function setValue(v: number)
                        v = math.clamp(v, min, max)
                        value = v
                        updateVisual()
                        if callback then
                            task.spawn(callback, value)
                        end
                    end

                    local function positionToValue(pos: Vector2)
                        local rel = pos.X - track.AbsolutePosition.X
                        local ratio = rel / track.AbsoluteSize.X
                        ratio = math.clamp(ratio, 0, 1)
                        return min + (max - min) * ratio
                    end

                    track.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            setValue(positionToValue(input.Position))
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
                            setValue(positionToValue(input.Position))
                        end
                    end)

                    setValue(default)

                    local SliderObj = {}
                    function SliderObj:Set(v: number)
                        setValue(v)
                    end
                    function SliderObj:Get()
                        return value
                    end

                    return SliderObj
                end

                ---------------------------------------------------------
                -- INPUT
                ---------------------------------------------------------
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
                        Text = label,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = THEME.Text,
                    }, {})

                    local box = create("TextBox", {
                        Parent = row,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0.6, 0, 1, 0),
                        BackgroundColor3 = THEME.Button,
                        BorderSizePixel = 0,
                        Font = FONT,
                        TextSize = 14,
                        TextColor3 = THEME.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        PlaceholderText = placeholder or "",
                        Text = "",
                        ClearTextOnFocus = false,
                    }, {})
                    makeCorner(box, 4)
                    makeStroke(box)

                    box.FocusLost:Connect(function()
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

                ---------------------------------------------------------
                -- DROPDOWN
                ---------------------------------------------------------
                function Section:Dropdown(label: string, options: {string}, default: string?, callback: (string) -> ())
                    options = options or {}
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
                        Text = label,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = THEME.Text,
                    }, {})

                    local button = create("TextButton", {
                        Parent = row,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0.6, 0, 1, 0),
                        BackgroundColor3 = THEME.Button,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "",
                    }, {})
                    makeCorner(button, 4)
                    makeStroke(button)

                    local valueLabel = create("TextLabel", {
                        Parent = button,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(1, -24, 1, 0),
                        Font = FONT,
                        Text = current,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = THEME.Text,
                    }, {})

                    local arrow = create("TextLabel", {
                        Parent = button,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -6, 0.5, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        BackgroundTransparency = 1,
                        Font = FONT,
                        Text = "▼",
                        TextSize = 12,
                        TextColor3 = THEME.TextDim,
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
                    makeStroke(listFrame)

                    local listLayout = create("UIListLayout", {
                        Parent = listFrame,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 2),
                    }, {})
                    local listPadding = create("UIPadding", {
                        Parent = listFrame,
                        PaddingTop = UDim.new(0, 4),
                        PaddingBottom = UDim.new(0, 4),
                        PaddingLeft = UDim.new(0, 4),
                        PaddingRight = UDim.new(0, 4),
                    }, {})

                    local optionButtons = {}

                    local function refreshSize()
                        local total = 0
                        for _, btn in ipairs(optionButtons) do
                            total += btn.AbsoluteSize.Y + listLayout.Padding.Offset
                        end
                        listFrame.Size = UDim2.new(1, 0, 0, total + 8)
                    end

                    local function setCurrent(v: string)
                        current = v
                        valueLabel.Text = v
                        if callback then
                            task.spawn(callback, v)
                        end
                    end

                    for _, opt in ipairs(options) do
                        local btn = create("TextButton", {
                            Parent = listFrame,
                            BackgroundColor3 = THEME.Button,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 20),
                            AutoButtonColor = false,
                            Font = FONT,
                            TextSize = 13,
                            TextColor3 = THEME.Text,
                            Text = opt,
                        }, {})
                        makeCorner(btn, 3)

                        btn.MouseEnter:Connect(function()
                            tween(btn, {BackgroundColor3 = THEME.ButtonHover})
                        end)
                        btn.MouseLeave:Connect(function()
                            tween(btn, {BackgroundColor3 = THEME.Button})
                        end)
                        btn.MouseButton1Click:Connect(function()
                            setCurrent(opt)
                            listFrame.Visible = false
                        end)

                        table.insert(optionButtons, btn)
                    end
                    refreshSize()

                    button.MouseButton1Click:Connect(function()
                        listFrame.Visible = not listFrame.Visible
                    end)

                    if current ~= "" and callback then
                        task.spawn(callback, current)
                    end

                    local DropObj = {}
                    function DropObj:Set(v: string)
                        setCurrent(v)
                    end
                    function DropObj:Get()
                        return current
                    end

                    return DropObj
                end

                ---------------------------------------------------------
                -- BUTTON
                ---------------------------------------------------------
                function Section:Button(label: string, callback: () -> ())
                    local btn = create("TextButton", {
                        Parent = sectionFrame,
                        BackgroundColor3 = THEME.Button,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 26),
                        AutoButtonColor = false,
                        Font = FONT,
                        TextSize = 14,
                        TextColor3 = THEME.Text,
                        Text = label,
                    }, {})
                    makeCorner(btn, 4)
                    makeStroke(btn)

                    btn.MouseEnter:Connect(function()
                        tween(btn, {BackgroundColor3 = THEME.ButtonHover})
                    end)
                    btn.MouseLeave:Connect(function()
                        tween(btn, {BackgroundColor3 = THEME.Button})
                    end)
                    btn.MouseButton1Click:Connect(function()
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

        table.insert(Window._Categories, Category)
        return Category
    end

    return Window
end

return Library
