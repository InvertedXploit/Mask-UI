--!strict

-- NeverwinUILib
-- UI library that recreates the NEVERWIN concept art

local NeverwinUILib = {}

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- CONFIG
local THEME = {
    Background = Color3.fromRGB(10, 10, 10),
    Window = Color3.fromRGB(16, 16, 16),
    Accent = Color3.fromRGB(132, 94, 255),
    AccentSoft = Color3.fromRGB(80, 60, 150),
    Sidebar = Color3.fromRGB(8, 8, 8),
    SidebarTransparent = 0.3,
    Section = Color3.fromRGB(18, 18, 18),
    Separator = Color3.fromRGB(40, 40, 40),
    TextPrimary = Color3.fromRGB(235, 235, 235),
    TextSecondary = Color3.fromRGB(150, 150, 150),
    ToggleOff = Color3.fromRGB(40, 40, 40),
    ToggleOn = Color3.fromRGB(132, 94, 255),
    SliderBar = Color3.fromRGB(35, 35, 35),
    SliderFill = Color3.fromRGB(132, 94, 255),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    CategoryHeader = Color3.fromRGB(120, 120, 120),
}

-- UTILS
local function create(instanceType: string, props: {[string]: any}?, children: {Instance}?): Instance
    local obj = Instance.new(instanceType)
    if props then
        for k,v in pairs(props) do
            (obj :: any)[k] = v
        end
    end
    if children then
        for _,child in ipairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

local function round(num: number, bracket: number)
    bracket = bracket or 1
    return math.floor(num / bracket + 0.5) * bracket
end

-- PUBLIC API: Create window

export type Window = {
    ScreenGui: ScreenGui,
    MainFrame: Frame,
    Sidebar: Frame,
    ContentContainer: Frame,
    Tabs: {[string]: Frame},
    SetActiveTab: (self: Window, tabName: string) -> (),
}

function NeverwinUILib:CreateWindow(config: {
    Title: string?,
    Username: string?,
    Size: UDim2?,
    Position: UDim2?,
    Parent: Instance?,
}): Window
    config = config or {}
    local title = config.Title or "NEVERWIN"
    local username = config.Username or (LocalPlayer and LocalPlayer.Name or "user")
    local size = config.Size or UDim2.fromOffset(800, 480)
    local guiParent = config.Parent or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui"))

    -- ROOT GUI
    local screenGui = create("ScreenGui", {
        Name = "NeverwinUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })

    -- MAIN WINDOW
    local mainFrame = create("Frame", {
        Name = "MainWindow",
        Size = size,
        Position = config.Position or UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = THEME.Window,
        BorderSizePixel = 0,
        Parent = screenGui,
    })

    local corner = create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = mainFrame,
    })

    local mainStroke = create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(50, 50, 50),
        Thickness = 1,
        Parent = mainFrame,
    })

    local mainPadding = create("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 2),
        Parent = mainFrame,
    })

    -- DRAGGING
    local dragging = false
    local dragStart, startPos

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function(changed)
                if changed == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
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

    -- TOP BAR
    local topBar = create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Parent = mainFrame,
    })

    local topCorner = create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = topBar,
    })

    local mask = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = topBar,
    })

    local titleLabel = create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 16,
        TextColor3 = THEME.TextPrimary,
        Parent = topBar,
    })

    local topSeparator = create("Frame", {
        BackgroundColor3 = THEME.Separator,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -4, 0, 1),
        Position = UDim2.new(0, 2, 1, -1),
        Parent = topBar,
    })

    -- MAIN CONTENT WRAPPER (below top bar)
    local contentFrame = create("Frame", {
        Name = "Content",
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        Parent = mainFrame,
    })

    local contentCorner = create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = contentFrame,
    })

    -- SIDEBAR
    local sidebar = create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = THEME.Sidebar,
        BackgroundTransparency = THEME.SidebarTransparent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 1, 0),
        Parent = contentFrame,
    })

    local sidebarPadding = create("UIPadding", {
        PaddingTop = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 8),
        Parent = sidebar,
    })

    local sidebarList = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar,
    })

    -- PROFILE (BOTTOM LEFT)
    local profileFrame = create("Frame", {
        Name = "Profile",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 12, 1, -12),
        Parent = sidebar,
    })

    local profileName = create("TextLabel", {
        Name = "UsernameLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = username,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 13,
        TextColor3 = THEME.TextSecondary,
        Parent = profileFrame,
    })

    -- TABS CONTAINER (MAIN AREA)
    local contentContainer = create("Frame", {
        Name = "ContentContainer",
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
        Parent = contentFrame,
    })

    local contentPadding = create("UIPadding", {
        PaddingTop = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
        Parent = contentContainer,
    })

    -- TAB STORAGE
    local tabs: {[string]: Frame} = {}
    local currentTab: string? = nil

    -- CATEGORY + TAB CREATION

    local function createCategory(headerText: string)
        local header = create("TextLabel", {
            Name = headerText .. "_Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Font = Enum.Font.GothamSemibold,
            Text = headerText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 13,
            TextColor3 = THEME.CategoryHeader,
            Parent = sidebar,
        })
        return header
    end

    local function createSidebarButton(tabName: string, labelText: string)
        local button = create("TextButton", {
            Name = tabName .. "_Button",
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Size = UDim2.new(1, -4, 0, 22),
            Font = Enum.Font.Gotham,
            Text = labelText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 13,
            TextColor3 = THEME.TextSecondary,
            Parent = sidebar,
        })

        local btnPadding = create("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            Parent = button,
        })

        local underline = create("Frame", {
            BackgroundColor3 = THEME.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 0, 1),
            Position = UDim2.new(0, 6, 1, -1),
            Parent = button,
        })

        local function setSelected(selected: boolean)
            if selected then
                button.TextColor3 = THEME.TextPrimary
                button.BackgroundTransparency = 0.7
                button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                underline:TweenSize(UDim2.new(0, 40, 0, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            else
                button.TextColor3 = THEME.TextSecondary
                button.BackgroundTransparency = 1
                underline:TweenSize(UDim2.new(0, 0, 0, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            end
        end

        return button, setSelected
    end

    local tabButtons: {[string]: (boolean) -> ()} = {}

    local function createTab(tabName: string)
        local tabFrame = create("Frame", {
            Name = tabName .. "_Tab",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = contentContainer,
        })
        return tabFrame
    end

    local function setActiveTab(tabName: string)
        if currentTab == tabName then return end
        for name, tab in pairs(tabs) do
            tab.Visible = (name == tabName)
        end
        for name, setter in pairs(tabButtons) do
            setter(name == tabName)
        end
        currentTab = tabName
    end

    -- EXPOSE TO WINDOW
    local window: Window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Sidebar = sidebar,
        ContentContainer = contentContainer,
        Tabs = tabs,
    } :: any

    function window:SetActiveTab(tabName: string)
        setActiveTab(tabName)
    end

    -- ADD DEFAULT STRUCTURE TO MATCH CONCEPT ART

    -- Combat category
    createCategory("Combat")
    do
        local btn, setter = createSidebarButton("Combat_Combat", "Combat")
        tabButtons["Combat_Combat"] = setter
        local tab = createTab("Combat_Combat")
        tabs["Combat_Combat"] = tab
        btn.MouseButton1Click:Connect(function()
            setActiveTab("Combat_Combat")
        end)
    end
    do
        local btn, setter = createSidebarButton("Combat_AntiAim", "Anti Aim")
        tabButtons["Combat_AntiAim"] = setter
        local tab = createTab("Combat_AntiAim")
        tabs["Combat_AntiAim"] = tab
        btn.MouseButton1Click:Connect(function()
            setActiveTab("Combat_AntiAim")
        end)
    end
    do
        local btn, setter = createSidebarButton("Combat_Legitbot", "Legitbot")
        tabButtons["Combat_Legitbot"] = setter
        local tab = createTab("Combat_Legitbot")
        tabs["Combat_Legitbot"] = tab
        btn.MouseButton1Click:Connect(function()
            setActiveTab("Combat_Legitbot")
        end)
    end

    -- Visuals category
    createCategory("Visuals")
    local visualTabs = {"Players", "Weapon", "World", "Local Player"}
    for _,name in ipairs(visualTabs) do
        local id = "Visuals_" .. name:gsub(" ", "")
        local btn, setter = createSidebarButton(id, name)
        tabButtons[id] = setter
        local tab = createTab(id)
        tabs[id] = tab
        btn.MouseButton1Click:Connect(function()
            setActiveTab(id)
        end)
    end

    -- Misc category
    createCategory("Miscellaneous")
    local miscTabs = {"Scripts", "Config"}
    for _,name in ipairs(miscTabs) do
        local id = "Misc_" .. name
        local btn, setter = createSidebarButton(id, name)
        tabButtons[id] = setter
        local tab = createTab(id)
        tabs[id] = tab
        btn.MouseButton1Click:Connect(function()
            setActiveTab(id)
        end)
    end

    -- CONTROLS (TOGGLES + SLIDERS) FOR THE MAIN COMBAT TAB

    local function createSection(parent: Instance, titleText: string, position: UDim2, size: UDim2)
        local sectionFrame = create("Frame", {
            Name = titleText .. "_Section",
            BackgroundColor3 = THEME.Section,
            BorderSizePixel = 0,
            Position = position,
            Size = size,
            Parent = parent,
        })

        local cornerSec = create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = sectionFrame,
        })

        local header = create("TextLabel", {
            Name = "Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -12, 0, 20),
            Position = UDim2.new(0, 8, 0, 6),
            Font = Enum.Font.GothamSemibold,
            Text = titleText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 14,
            TextColor3 = THEME.TextPrimary,
            Parent = sectionFrame,
        })

        local topLine = create("Frame", {
            BackgroundColor3 = THEME.Separator,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -16, 0, 1),
            Position = UDim2.new(0, 8, 0, 28),
            Parent = sectionFrame,
        })

        local sectionPadding = create("UIPadding", {
            PaddingTop = UDim.new(0, 34),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = sectionFrame,
        })

        local list = create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = sectionFrame,
        })

        return sectionFrame
    end

    local function createToggle(parent: Instance, labelText: string, default: boolean?, callback: ((boolean) -> ())?)
        default = if default == nil then false else default

        local item = create("Frame", {
            Name = labelText .. "_Toggle",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            Parent = parent,
        })

        local label = create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Font = Enum.Font.Gotham,
            Text = labelText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 13,
            TextColor3 = THEME.TextSecondary,
            Parent = item,
        })

        local button = create("TextButton", {
            Name = "ToggleButton",
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(0, 32, 0, 16),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            AutoButtonColor = false,
            Parent = item,
        })

        local track = create("Frame", {
            Name = "Track",
            BackgroundColor3 = THEME.ToggleOff,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = button,
        })

        local trackCorner = create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = track,
        })

        local knob = create("Frame", {
            Name = "Knob",
            BackgroundColor3 = Color3.fromRGB(230, 230, 230),
            BorderSizePixel = 0,
            Size = UDim2.new(0.5, -3, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            Parent = track,
        })

        local knobCorner = create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = knob,
        })

        local state = default :: boolean

        local function refresh(anim: boolean?)
            local targetColor = state and THEME.ToggleOn or THEME.ToggleOff
            local targetPos = state and UDim2.new(0.5, 1, 0, 2) or UDim2.new(0, 2, 0, 2)

            if anim then
                TweenService:Create(track, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = targetColor
                }):Play()
                TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = targetPos
                }):Play()
            else
                track.BackgroundColor3 = targetColor
                knob.Position = targetPos
            end
        end

        refresh(false)

        button.MouseButton1Click:Connect(function()
            state = not state
            refresh(true)
            if callback then
                callback(state)
            end
        end)

        return {
            Set = function(_, val: boolean)
                state = val
                refresh(false)
                if callback then
                    callback(state)
                end
            end,
            Get = function() return state end,
        }
    end

    local function createSlider(parent: Instance, labelText: string, minVal: number, maxVal: number, defaultVal: number, callback: ((number) -> ())?)
        local item = create("Frame", {
            Name = labelText .. "_Slider",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Parent = parent,
        })

        local topRow = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Parent = item,
        })

        local label = create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Enum.Font.Gotham,
            Text = labelText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 13,
            TextColor3 = THEME.TextSecondary,
            Parent = topRow,
        })

        local valueLabel = create("TextLabel", {
            Name = "ValueLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            Font = Enum.Font.Gotham,
            Text = tostring(defaultVal),
            TextXAlignment = Enum.TextXAlignment.Right,
            TextSize = 13,
            TextColor3 = THEME.TextPrimary,
            Parent = topRow,
        })

        local barBg = create("Frame", {
            Name = "BarBackground",
            BackgroundColor3 = THEME.SliderBar,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0, 20),
            Parent = item,
        })

        local barCorner = create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = barBg,
        })

        local fill = create("Frame", {
            Name = "Fill",
            BackgroundColor3 = THEME.SliderFill,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = barBg,
        })

        local fillCorner = create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = fill,
        })

        local knob = create("Frame", {
            Name = "Knob",
            BackgroundColor3 = THEME.SliderKnob,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 10, 0, 10),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Parent = barBg,
        })

        local knobCorner = create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = knob,
        })

        local draggingSlider = false
        local value = defaultVal

        local function setValue(newVal: number, fromInput: boolean?)
            newVal = math.clamp(newVal, minVal, maxVal)
            value = newVal
            local alpha = (newVal - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            valueLabel.Text = tostring(round(newVal, 1))

            if callback and not fromInput then
                callback(value)
            elseif callback and fromInput then
                callback(value)
            end
        end

        barBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
                local rel = (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
                setValue(minVal + (maxVal - minVal) * rel, true)
            end
        end)

        barBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)

        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
            end
        end)

        knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
                setValue(minVal + (maxVal - minVal) * rel, true)
            end
        end)

        setValue(defaultVal)

        return {
            Set = function(_, v: number)
                setValue(v)
            end,
            Get = function() return value end,
        }
    end

    -- BUILD DEFAULT "Combat > Combat" TAB CONTENT TO MATCH IMAGE

    do
        local tab = tabs["Combat_Combat"]
        if tab then
            -- Two sections side by side: Silent Aim (left), Fov Circle (right)

            local sectionWidth = (contentContainer.AbsoluteSize.X - 16) / 2
            -- we can't use AbsoluteSize immediately; instead use scale approximations
            -- left: 50% width, right: 50% width
            local silentAimSection = createSection(
                tab,
                "Silent Aim",
                UDim2.new(0, 0, 0, 0),
                UDim2.new(0.5, -8, 1, 0)
            )

            local fovSection = createSection(
                tab,
                "Fov Circle",
                UDim2.new(0.5, 8, 0, 0),
                UDim2.new(0.5, -8, 1, 0)
            )

            -- Silent Aim contents
            createToggle(silentAimSection, "Enable Silent Aim", true)
            createToggle(silentAimSection, "Visibility Check", false)
            createToggle(silentAimSection, "Distance Check", true)
            createSlider(silentAimSection, "Distance", 0, 5000, 1000)
            createSlider(silentAimSection, "FOV", 0, 360, 100)
            createSlider(silentAimSection, "Hit Chance", 0, 100, 100)

            -- Fov Circle contents
            createToggle(fovSection, "Enable", true)
            createToggle(fovSection, "Filled", true)
            createSlider(fovSection, "NumSides", 3, 200, 100)
            createSlider(fovSection, "Thickness", 1, 200, 100)
        end
    end

    -- INITIAL TAB
    setActiveTab("Combat_Combat")

    -- PARENT GUI
    screenGui.Parent = guiParent

    return window
end

return NeverwinUILib
