--========================================================--
--                        MaskUI
--                  General-Purpose UI Library
--========================================================--

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--========================================================--
--                      Utilities
--========================================================--

local function Tween(obj, props, time, style, dir)
    if not obj then return end
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

--========================================================--
--                      Theme
--========================================================--

local Theme = {
    Background    = Color3.fromRGB(10, 10, 14),
    SidebarTint   = Color3.fromRGB(16, 16, 26),
    Element       = Color3.fromRGB(22, 22, 30),
    ElementAlt    = Color3.fromRGB(18, 18, 26),
    Accent        = Color3.fromRGB(140, 90, 255),
    AccentSoft    = Color3.fromRGB(105, 70, 210),
    Text          = Color3.fromRGB(235, 235, 240),
    SubText       = Color3.fromRGB(150, 150, 165),
    Stroke        = Color3.fromRGB(50, 50, 60),
    StrokeSoft    = Color3.fromRGB(40, 40, 50),
    Notification  = Color3.fromRGB(20, 20, 27),
}

--========================================================--
--                      Classes
--========================================================--

local Fluent = {}
local Window = {}
local Tab    = {}

Window.__index = Window
Tab.__index    = Tab

--========================================================--
--                  Notification System
--========================================================--

local function CreateNotificationRoot(gui)
    local holder = Create("Frame", {
        Name                   = "NotificationHolder",
        Parent                 = gui,
        AnchorPoint            = Vector2.new(1, 1),
        Position               = UDim2.new(1, -20, 1, -20),
        Size                   = UDim2.new(0, 300, 1, -40),
        BackgroundTransparency = 1
    }, {
        Create("UIListLayout", {
            SortOrder         = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding           = UDim.new(0, 8)
        })
    })
    return holder
end

local function CreateNotification(holder, info)
    info = info or {}
    local title    = info.Title or "Notification"
    local content  = info.Content or ""
    local duration = info.Duration or 4

    local frame = Create("Frame", {
        Parent                 = holder,
        Size                   = UDim2.new(1, 0, 0, 68),
        BackgroundColor3       = Theme.Notification,
        BackgroundTransparency = 1,
        ClipsDescendants       = true
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", {
            Color        = Theme.StrokeSoft,
            Thickness    = 1,
            Transparency = 0.2
        }),
        Create("UIPadding", {
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 10),
            PaddingTop    = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        }),
        Create("TextLabel", {
            Name                   = "Title",
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 18),
            TextXAlignment         = Enum.TextXAlignment.Left,
            Font                   = Enum.Font.GothamSemibold,
            TextSize               = 14,
            TextColor3             = Theme.Text,
            Text                   = title
        }),
        Create("TextLabel", {
            Name                   = "Body",
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 0, 0, 22),
            Size                   = UDim2.new(1, 0, 0, 32),
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextYAlignment         = Enum.TextYAlignment.Top,
            Font                   = Enum.Font.Gotham,
            TextSize               = 13,
            TextColor3             = Theme.SubText,
            TextWrapped            = true,
            Text                   = content
        })
    })

    Tween(frame, { BackgroundTransparency = 0 }, 0.18)

    task.delay(duration, function()
        if frame and frame.Parent then
            Tween(frame, { BackgroundTransparency = 1 }, 0.18)
            task.wait(0.2)
            if frame and frame.Parent then
                frame:Destroy()
            end
        end
    end)
end

--========================================================--
--                  Window Creation
--========================================================--

function Fluent:CreateWindow(opts)
    opts = opts or {}

    local self = setmetatable({}, Window)

    self.Title     = opts.Title or "Mask UI"
    self.Size      = opts.Size or UDim2.fromOffset(720, 430)
    self.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    self.MinHeight = 44

    local gui = Create("ScreenGui", {
        Name           = "MaskUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder   = 9999,
        Parent         = LocalPlayer:WaitForChild("PlayerGui")
    })

    self.Gui = gui
    self.NotificationHolder = CreateNotificationRoot(gui)

    local window = Create("Frame", {
        Name             = "Window",
        Parent           = gui,
        Size             = self.Size,
        Position         = UDim2.fromScale(0.5, 0.5),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color        = Theme.Stroke,
            Thickness    = 1,
            Transparency = 0.2
        })
    })
    self.Root = window

    -- Sidebar (transparent; only buttons visible)
    local sidebar = Create("Frame", {
        Name                   = "Sidebar",
        Parent                 = window,
        Size                   = UDim2.new(0, 190, 1, 0),
        Position               = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0
    })

    local sidebarInner = Create("Frame", {
        Parent                 = sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        Position               = UDim2.new(0, 0, 0, 0)
    })

    local sidebarScroll = Create("ScrollingFrame", {
        Parent                 = sidebarInner,
        Size                   = UDim2.new(1, 0, 1, -20),
        Position               = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        CanvasSize             = UDim2.fromScale(0, 0),
        ScrollBarThickness     = 2,
        ScrollBarImageColor3   = Color3.fromRGB(80, 80, 100),
        BorderSizePixel        = 0
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 4)
        }),
        Create("UIPadding", {
            PaddingLeft  = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    })

    sidebarScroll.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, sidebarScroll.UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    self.SidebarScroll = sidebarScroll

    -- Content holder (tab frame)
    local contentHolder = Create("Frame", {
        Name                   = "ContentHolder",
        Parent                 = window,
        Size                   = UDim2.new(1, -190, 1, 0),
        Position               = UDim2.new(0, 190, 0, 0),
        BackgroundColor3       = Theme.ElementAlt,
        BackgroundTransparency = 0.05,
        BorderSizePixel        = 0,
        ClipsDescendants       = true
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color        = Theme.StrokeSoft,
            Transparency = 0.45
        })
    })

    local contentInner = Create("Frame", {
        Parent                 = contentHolder,
        BackgroundColor3       = Theme.ElementAlt,
        BackgroundTransparency = 0.05,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        Position               = UDim2.new(0, 0, 0, 0)
    })

    self.ContentHolder = contentInner
    self.Sections      = {}
    self.Tabs          = {}
    self.ActiveTab     = nil
    self.Minimized     = false

    -- Dragging only from tab/content frame
    local dragging      = false
    local dragStart     = nil
    local startPosition = nil

    local function beginDrag(input)
        dragging      = true
        dragStart     = input.Position
        startPosition = window.Position
    end

    local function updateDrag(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        window.Position = UDim2.fromOffset(
            startPosition.X.Offset + delta.X,
            startPosition.Y.Offset + delta.Y
        )
    end

    local function endDrag()
        dragging      = false
        dragStart     = nil
        startPosition = nil
    end

    contentInner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            beginDrag(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            endDrag()
        end
    end)

    -- UI Toggle (global)
    local visible = true

    local function setVisible(v)
        visible    = v
        gui.Enabled = v
    end

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == self.ToggleKey then
            setVisible(not visible)
        end
    end)

    function self:SetToggleKey(keycode)
        self.ToggleKey = keycode
    end

    function self:Notify(info)
        CreateNotification(self.NotificationHolder, info)
    end

    return self
end

--========================================================--
--                 Section + Tab Creation
--========================================================--

function Window:CreateSection(sectionName)
    sectionName = sectionName or "Section"

    if self.Sections[sectionName] then
        return self.Sections[sectionName]
    end

    local header = Create("TextLabel", {
        Parent                 = self.SidebarScroll,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 18),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Font                   = Enum.Font.GothamSemibold,
        TextSize               = 12,
        TextColor3             = Theme.SubText,
        Text                   = sectionName:upper()
    })

    local spacing = Create("Frame", {
        Parent                 = self.SidebarScroll,
        Size                   = UDim2.new(1, 0, 0, 2),
        BackgroundTransparency = 1
    })

    local section = {
        Name   = sectionName,
        Header = header,
        Tabs   = {},
        Spacer = spacing
    }

    self.Sections[sectionName] = section
    return section
end

function Window:CreateTab(tabName, sectionName)
    tabName    = tabName    or "Tab"
    sectionName = sectionName or "Misc"

    local section = self:CreateSection(sectionName)

    local tabButton = Create("TextButton", {
        Parent                 = self.SidebarScroll,
        Size                   = UDim2.new(1, 0, 0, 24),
        BackgroundColor3       = Theme.SidebarTint,
        BackgroundTransparency = 0.4,
        AutoButtonColor        = false,
        Text                   = ""
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.6 }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size                   = UDim2.fromScale(1, 1),
            Text                   = tabName,
            Font                   = Enum.Font.Gotham,
            TextSize               = 13,
            TextColor3             = Theme.Text,
            TextXAlignment         = Enum.TextXAlignment.Left
        })
    })

    local page = Create("Frame", {
        Parent                 = self.ContentHolder,
        Size                   = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible                = false
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 8)
        }),
        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 12),
            PaddingLeft   = UDim.new(0, 12),
            PaddingRight  = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        })
    })

    -- Centered title at top of tab frame
    local titleLabel = Create("TextLabel", {
        Parent                 = page,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 28),
        Text                   = tabName,
        Font                   = Enum.Font.GothamSemibold,
        TextSize               = 17,
        TextColor3             = Theme.Text,
        TextXAlignment         = Enum.TextXAlignment.Center,
        TextYAlignment         = Enum.TextYAlignment.Top
    })

    -- Push elements down a bit below the title
    page.UIPadding.PaddingTop = UDim.new(0, 36)

    local tab = setmetatable({
        Window  = self,
        Section = section,
        Name    = tabName,
        Button  = tabButton,
        Page    = page,
        Title   = titleLabel
    }, Tab)

    table.insert(section.Tabs, tab)
    self.Tabs[tabName] = tab

    local function setActive()
        if self.ActiveTab then
            self.ActiveTab.Page.Visible = false
            Tween(self.ActiveTab.Button, {
                BackgroundColor3       = Theme.SidebarTint,
                BackgroundTransparency = 0.4
            }, 0.12)
        end
        self.ActiveTab = tab
        page.Visible   = true
        Tween(tabButton, {
            BackgroundColor3       = Theme.Element,
            BackgroundTransparency = 0
        }, 0.12)
    end

    tabButton.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tabButton, {
                BackgroundColor3       = Theme.SidebarTint,
                BackgroundTransparency = 0.2
            }, 0.1)
        end
    end)

    tabButton.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tabButton, {
                BackgroundColor3       = Theme.SidebarTint,
                BackgroundTransparency = 0.4
            }, 0.1)
        end
    end)

    tabButton.MouseButton1Click:Connect(function()
        setActive()
    end)

    if not self.ActiveTab then
        setActive()
    end

    return tab
end

--========================================================--
--                   Elements: Button
--========================================================--

function Tab:AddButton(options)
    options = options or {}
    local text     = options.Text or "Button"
    local callback = options.Callback

    local btn = Create("TextButton", {
        Parent           = self.Page,
        Size             = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor  = false,
        Text             = ""
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.55 }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size                   = UDim2.fromScale(1, 1),
            Text                   = text,
            Font                   = Enum.Font.Gotham,
            TextSize               = 14,
            TextColor3             = Theme.Text,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Position               = UDim2.new(0, 10, 0, 0)
        })
    })

    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.ElementAlt }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.Element }, 0.12)
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.AccentSoft }, 0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.ElementAlt }, 0.1)
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then
            coroutine.wrap(callback)()
        end
    end)

    return btn
end

--========================================================--
--                   Elements: Toggle
--========================================================--

function Tab:AddToggle(options)
    options = options or {}
    local text     = options.Text or "Toggle"
    local default  = options.Default == nil and false or options.Default
    local callback = options.Callback

    local frame = Create("Frame", {
        Parent           = self.Page,
        Size             = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.55 }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, -40, 1, 0),
            Position               = UDim2.new(0, 10, 0, 0),
            Text                   = text,
            Font                   = Enum.Font.Gotham,
            TextSize               = 14,
            TextColor3             = Theme.Text,
            TextXAlignment         = Enum.TextXAlignment.Left
        })
    })

    local switch = Create("Frame", {
        Parent           = frame,
        Size             = UDim2.fromOffset(34, 16),
        Position         = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.ElementAlt
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.55 })
    })

    local thumb = Create("Frame", {
        Parent           = switch,
        Size             = UDim2.fromOffset(14, 14),
        Position         = UDim2.fromOffset(1, 1),
        BackgroundColor3 = Theme.Text
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local state = default

    local function setState(v, fire)
        state = v
        Tween(thumb, {
            Position         = v and UDim2.fromOffset(19, 1) or UDim2.fromOffset(1, 1),
            BackgroundColor3 = v and Theme.Background or Theme.Text
        }, 0.14)

        Tween(switch, {
            BackgroundColor3 = v and Theme.Accent or Theme.ElementAlt
        }, 0.14)

        if fire and callback then
            coroutine.wrap(callback)(state)
        end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not state, true)
        end
    end)

    setState(default, false)

    return {
        Instance = frame,
        Set      = function(_, v) setState(v, true) end,
        Get      = function() return state end
    }
end

--========================================================--
--                   Elements: Slider
--========================================================--

function Tab:AddSlider(options)
    options = options or {}
    local text     = options.Text or "Slider"
    local min      = options.Min or 0
    local max      = options.Max or 100
    local default  = options.Default or min
    local rounding = options.Rounding or 1
    local callback = options.Callback

    local value = default

    local frame = Create("Frame", {
        Parent           = self.Page,
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.55 })
    })

    local label = Create("TextLabel", {
        Parent                 = frame,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.5, -10, 1, 0),
        Position               = UDim2.new(0, 10, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Font                   = Enum.Font.Gotham,
        TextSize               = 13,
        TextColor3             = Theme.Text,
        Text                   = ("%s: %s"):format(text, tostring(value))
    })

    local bar = Create("Frame", {
        Parent           = frame,
        Size             = UDim2.new(0.5, -20, 0, 6),
        Position         = UDim2.new(0.5, 10, 0.5, 0),
        BackgroundColor3 = Theme.ElementAlt
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local fill = Create("Frame", {
        Parent           = bar,
        Size             = UDim2.new((value - min) / math.max((max - min), 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local dragging = false

    local function setValue(newVal, fire)
        newVal = math.clamp(newVal, min, max)
        if rounding ~= 0 then
            newVal = math.floor(newVal / rounding + 0.5) * rounding
        end
        value = newVal
        local alpha = (value - min) / math.max((max - min), 1)
        Tween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, 0.08)
        label.Text = ("%s: %s"):format(text, tostring(value))
        if fire and callback then
            coroutine.wrap(callback)(value)
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relative = math.clamp(
                (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
                0, 1
            )
            local newVal = Lerp(min, max, relative)
            setValue(newVal, true)
        end
    end)

    setValue(default, false)

    return {
        Instance = frame,
        Set      = function(_, v) setValue(v, true) end,
        Get      = function() return value end
    }
end

--========================================================--
--                   Elements: Input
--========================================================--

function Tab:AddInput(options)
    options = options or {}
    local labelText   = options.Text or "Input"
    local placeholder = options.Placeholder or ""
    local default     = options.Default or ""
    local callback    = options.Callback

    local frame = Create("Frame", {
        Parent           = self.Page,
        Size             = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.55 })
    })

    Create("TextLabel", {
        Parent                 = frame,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.4, -10, 1, 0),
        Position               = UDim2.new(0, 10, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Font                   = Enum.Font.Gotham,
        TextSize               = 14,
        TextColor3             = Theme.Text,
        Text                   = labelText
    })

    local box = Create("TextBox", {
        Parent                 = frame,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.6, -10, 1, 0),
        Position               = UDim2.new(0.4, 0, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Font                   = Enum.Font.Gotham,
        TextSize               = 14,
        TextColor3             = Theme.Text,
        PlaceholderColor3      = Theme.SubText,
        PlaceholderText        = placeholder,
        Text                   = default
    })

    box.FocusLost:Connect(function(enterPressed)
        if callback then
            coroutine.wrap(callback)(box.Text, enterPressed)
        end
    end)

    return {
        Instance = frame,
        Set      = function(_, v) box.Text = v end,
        Get      = function() return box.Text end
    }
end

--========================================================--
--                   Elements: Dropdown
--========================================================--

function Tab:AddDropdown(options)
    options = options or {}
    local labelText = options.Text or "Dropdown"
    local values    = options.Values or {}
    local default   = options.Default or values[1]
    local callback  = options.Callback

    local current = default

    local frame = Create("Frame", {
        Parent           = self.Page,
        Size             = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.55 })
    })

    Create("TextLabel", {
        Parent                 = frame,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.4, -10, 1, 0),
        Position               = UDim2.new(0, 10, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Font                   = Enum.Font.Gotham,
        TextSize               = 14,
        TextColor3             = Theme.Text,
        Text                   = labelText
    })

    local button = Create("TextButton", {
        Parent                 = frame,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.6, -26, 1, 0),
        Position               = UDim2.new(0.4, 0, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Right,
        Font                   = Enum.Font.Gotham,
        TextSize               = 14,
        TextColor3             = Theme.Text,
        AutoButtonColor        = false,
        Text                   = tostring(current or "--")
    })

    local arrow = Create("TextLabel", {
        Parent                 = frame,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, 16, 1, 0),
        Position               = UDim2.new(1, -18, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Center,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 14,
        TextColor3             = Theme.SubText,
        Text                   = "▾"
    })

    local listFrame = Create("Frame", {
        Parent                 = frame,
        Position               = UDim2.new(0, 0, 1, 2),
        Size                   = UDim2.new(1, 0, 0, 0),
        BackgroundColor3       = Theme.ElementAlt,
        ClipsDescendants       = true,
        ZIndex                 = 10
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.55 }),
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 2)
        })
    })

    local optionButtons = {}
    local open          = false

    local function rebuild()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        optionButtons = {}

        for _, v in ipairs(values) do
            local optBtn = Create("TextButton", {
                Parent                 = listFrame,
                Size                   = UDim2.new(1, 0, 0, 22),
                BackgroundColor3       = Theme.ElementAlt,
                Text                   = v,
                Font                   = Enum.Font.Gotham,
                TextSize               = 13,
                TextColor3             = Theme.Text,
                AutoButtonColor        = false
            })

            optBtn.MouseEnter:Connect(function()
                Tween(optBtn, { BackgroundColor3 = Theme.Element }, 0.1)
            end)
            optBtn.MouseLeave:Connect(function()
                Tween(optBtn, { BackgroundColor3 = Theme.ElementAlt }, 0.1)
            end)

            optBtn.MouseButton1Click:Connect(function()
                current       = v
                button.Text   = tostring(current)
                open          = false
                arrow.Text    = "▾"
                Tween(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.16)
                if callback then
                    coroutine.wrap(callback)(current)
                end
            end)

            table.insert(optionButtons, optBtn)
        end

        local count  = #values
        local height = math.clamp(count * 22 + (count > 0 and 4 or 0), 0, 160)
        if open then
            Tween(listFrame, { Size = UDim2.new(1, 0, 0, height) }, 0.16)
        else
            listFrame.Size = UDim2.new(1, 0, 0, 0)
        end
    end

    local function setOpen(v)
        open       = v
        arrow.Text = v and "▴" or "▾"
        local count  = #values
        local height = math.clamp(count * 22 + (count > 0 and 4 or 0), 0, 160)
        Tween(listFrame, {
            Size = v and UDim2.new(1, 0, 0, height) or UDim2.new(1, 0, 0, 0)
        }, 0.16)
    end

    button.MouseButton1Click:Connect(function()
        setOpen(not open)
    end)

    rebuild()

    return {
        Instance  = frame,
        Set       = function(_, v)
            current     = v
            button.Text = tostring(current or "--")
            if callback then
                coroutine.wrap(callback)(current)
            end
        end,
        Get       = function() return current end,
        SetValues = function(_, vals)
            values = vals or {}
            rebuild()
        end
    }
end

--========================================================--
--                   Elements: Keybind
--========================================================--

function Tab:AddKeybind(options)
    options = options or {}
    local labelText = options.Text or "Keybind"
    local default   = options.Default or Enum.KeyCode.F
    local callback  = options.Callback

    local currentKey = default
    local listening  = false

    local frame = Create("Frame", {
        Parent           = self.Page,
        Size             = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.55 })
    })

    Create("TextLabel", {
        Parent                 = frame,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.4, -10, 1, 0),
        Position               = UDim2.new(0, 10, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Font                   = Enum.Font.Gotham,
        TextSize               = 14,
        TextColor3             = Theme.Text,
        Text                   = labelText
    })

    local button = Create("TextButton", {
        Parent                 = frame,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.6, -10, 1, 0),
        Position               = UDim2.new(0.4, 0, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Right,
        Font                   = Enum.Font.Gotham,
        TextSize               = 14,
        TextColor3             = Theme.Text,
        AutoButtonColor        = false,
        Text                   = currentKey.Name
    })

    button.MouseButton1Click:Connect(function()
        listening  = true
        button.Text = "Press a key..."
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end

        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey  = input.KeyCode
                listening   = false
                button.Text = currentKey.Name
                if callback then
                    coroutine.wrap(callback)(currentKey, "Changed")
                end
            end
        else
            if input.KeyCode == currentKey then
                if callback then
                    coroutine.wrap(callback)(currentKey, "Activated")
                end
            end
        end
    end)

    return {
        Instance = frame,
        Set      = function(_, keycode)
            currentKey  = keycode
            button.Text = currentKey.Name
        end,
        Get      = function() return currentKey end
    }
end

--========================================================--
--                     Public API
--========================================================--

local MaskUI = {}

function MaskUI:CreateWindow(opts)
    return Fluent:CreateWindow(opts)
end

return MaskUI
