--========================================================--
--                  Fluent-Style UI Library
--                    Single-File Version
--========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--========================================================--
--                      Utility
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
    Background = Color3.fromRGB(18, 18, 20),
    Element = Color3.fromRGB(30, 30, 35),
    ElementAlt = Color3.fromRGB(26, 26, 30),
    Accent = Color3.fromRGB(140, 90, 255),
    AccentSoft = Color3.fromRGB(90, 60, 180),
    Text = Color3.fromRGB(235, 235, 240),
    SubText = Color3.fromRGB(165, 165, 175),
    Stroke = Color3.fromRGB(60, 60, 70),
    StrokeSoft = Color3.fromRGB(45, 45, 55),
    AcrylicTint = Color3.fromRGB(5, 5, 10),
    AcrylicTransparency = 0.2,
    Notification = Color3.fromRGB(24, 24, 30),
}

--========================================================--
--                      Classes
--========================================================--

local Fluent = {}
Fluent.__index = Fluent

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

--========================================================--
--                      Acrylic
--========================================================--

local function EnableBlur(size)
    local blur = Lighting:FindFirstChild("__FluentBlur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "__FluentBlur"
        blur.Parent = Lighting
    end
    blur.Size = size or 12
    return blur
end

local function DisableBlur()
    local blur = Lighting:FindFirstChild("__FluentBlur")
    if blur then blur:Destroy() end
end

--========================================================--
--                 Notification System
--========================================================--

local function CreateNotificationRoot(gui)
    local holder = Create("Frame", {
        Name = "NotificationHolder",
        Parent = gui,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        BackgroundTransparency = 1
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 8)
        })
    })
    return holder
end

local function CreateNotification(holder, info)
    info = info or {}
    local title = info.Title or "Notification"
    local content = info.Content or ""
    local duration = info.Duration or 4

    local frame = Create("Frame", {
        Parent = holder,
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = Theme.Notification,
        BackgroundTransparency = 1,
        ClipsDescendants = true
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", {
            Color = Theme.StrokeSoft,
            Thickness = 1,
            Transparency = 0.2
        }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        }),
        Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            Text = title
        }),
        Create("TextLabel", {
            Name = "Body",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 22),
            Size = UDim2.new(1, 0, 0, 32),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            TextWrapped = true,
            Text = content
        })
    })

    Tween(frame, { BackgroundTransparency = 0 }, 0.18)

    task.delay(duration, function()
        Tween(frame, { BackgroundTransparency = 1 }, 0.18)
        task.wait(0.2)
        if frame and frame.Parent then
            frame:Destroy()
        end
    end)
end

--========================================================--
--                  Window Creation
--========================================================--

function Fluent:CreateWindow(opts)
    opts = opts or {}

    local self = setmetatable({}, Window)

    self.Title = opts.Title or "Fluent UI"
    self.Acrylic = opts.Acrylic ~= false
    self.Size = opts.Size or UDim2.fromOffset(580, 390)
    self.MinHeight = 44

    -- ScreenGui
    local gui = Create("ScreenGui", {
        Name = "FluentUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = LocalPlayer:WaitForChild("PlayerGui")
    })

    self.Gui = gui
    self.NotificationHolder = CreateNotificationRoot(gui)

    if self.Acrylic then
        self.Blur = EnableBlur(14)
    end

    -- Main window frame
    local window = Create("Frame", {
        Name = "Window",
        Parent = gui,
        Size = self.Size,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color = Theme.Stroke,
            Thickness = 1,
            Transparency = 0.2
        })
    })
    self.Root = window

    -- Acrylic overlay inside window
    if self.Acrylic then
        Create("Frame", {
            Parent = window,
            BackgroundColor3 = Theme.AcrylicTint,
            BackgroundTransparency = Theme.AcrylicTransparency,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 0
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
    end

    -- Titlebar
    local titlebar = Create("Frame", {
        Name = "TitleBar",
        Parent = window,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.1
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = Theme.Stroke, Transparency = 0.4 }),
        Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -80, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            Text = self.Title
        })
    })
    self.TitleBar = titlebar

    -- Minimize button
    local minButton = Create("TextButton", {
        Parent = titlebar,
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, -64, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.ElementAlt,
        Text = "–",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 14,
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    -- Close button
    local closeButton = Create("TextButton", {
        Parent = titlebar,
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, -32, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.ElementAlt,
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 14,
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    -- Tabs holder
    local tabHolder = Create("Frame", {
        Name = "TabHolder",
        Parent = window,
        Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Theme.ElementAlt,
        BackgroundTransparency = 0.1
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color = Theme.StrokeSoft,
            Transparency = 0.3
        }),
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    })
    self.TabHolder = tabHolder

    -- Content holder
    local contentHolder = Create("Frame", {
        Name = "ContentHolder",
        Parent = window,
        Size = UDim2.new(1, -170, 1, -50),
        Position = UDim2.new(0, 160, 0, 44),
        BackgroundTransparency = 1
    })
    self.ContentHolder = contentHolder

    -- Active / tabs data
    self.Tabs = {}
    self.ActiveTab = nil
    self.Minimized = false

    -- Dragging
    local dragging = false
    local dragStart, startPos

    titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Minimize behavior
    minButton.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            Tween(window, { Size = UDim2.fromOffset(self.Size.X.Offset, self.MinHeight) }, 0.2)
        else
            Tween(window, { Size = self.Size }, 0.2)
        end
    end)

    -- Close behavior
    closeButton.MouseButton1Click:Connect(function()
        if self.Blur then
            DisableBlur()
        end
        gui:Destroy()
    end)

    -- Hover feedback for buttons
    local function buttonHover(btn)
        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundColor3 = Theme.AccentSoft }, 0.16)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundColor3 = Theme.ElementAlt }, 0.16)
        end)
        btn.MouseButton1Down:Connect(function()
            Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.08)
        end)
        btn.MouseButton1Up:Connect(function()
            Tween(btn, { BackgroundColor3 = Theme.AccentSoft }, 0.12)
        end)
    end

    buttonHover(minButton)
    buttonHover(closeButton)

    return self
end

--========================================================--
--                       Notify
--========================================================--

function Window:Notify(info)
    CreateNotification(self.NotificationHolder, info)
end

--========================================================--
--                       Tabs
--========================================================--

function Window:CreateTab(name)
    local selfWindow = self

    local tabButton = Create("TextButton", {
        Parent = selfWindow.TabHolder,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.ElementAlt,
        Text = "",
        AutoButtonColor = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", {
            Color = Theme.StrokeSoft,
            Transparency = 0.5
        }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.Text
        })
    })

    -- Tab page
    local page = Create("Frame", {
        Parent = selfWindow.ContentHolder,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
    })

    local tab = setmetatable({
        Window = selfWindow,
        Name = name,
        Button = tabButton,
        Page = page
    }, Tab)

    selfWindow.Tabs[name] = tab

    local function setActive()
        if selfWindow.ActiveTab then
            selfWindow.ActiveTab.Page.Visible = false
            Tween(selfWindow.ActiveTab.Button, { BackgroundColor3 = Theme.ElementAlt }, 0.18)
        end
        selfWindow.ActiveTab = tab
        page.Visible = true
        Tween(tabButton, { BackgroundColor3 = Theme.Element }, 0.18)
    end

    tabButton.MouseButton1Click:Connect(function()
        setActive()
    end)

    -- First tab becomes active
    if not selfWindow.ActiveTab then
        setActive()
    end

    return tab
end

--========================================================--
--                   Element: Button
--========================================================--

function Tab:AddButton(options)
    options = options or {}
    local text = options.Text or "Button"
    local callback = options.Callback

    local btn = Create("TextButton", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Text = ""
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.5 }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 10, 0, 0)
        })
    })

    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.ElementAlt }, 0.14)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.Element }, 0.14)
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.AccentSoft }, 0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.ElementAlt }, 0.12)
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then
            coroutine.wrap(callback)()
        end
    end)

    return btn
end

--========================================================--
--                   Element: Toggle
--========================================================--

function Tab:AddToggle(options)
    options = options or {}
    local text = options.Text or "Toggle"
    local default = options.Default == nil and false or options.Default
    local callback = options.Callback

    local frame = Create("Frame", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Element,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.5 }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    local switch = Create("Frame", {
        Parent = frame,
        Size = UDim2.fromOffset(34, 16),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.ElementAlt
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.5 })
    })

    local thumb = Create("Frame", {
        Parent = switch,
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.fromOffset(1, 1),
        BackgroundColor3 = Theme.Text
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local state = default

    local function setState(v, fire)
        state = v
        Tween(thumb, {
            Position = v and UDim2.fromOffset(19, 1) or UDim2.fromOffset(1, 1),
            BackgroundColor3 = v and Theme.Background or Theme.Text
        }, 0.16)

        Tween(switch, {
            BackgroundColor3 = v and Theme.Accent or Theme.ElementAlt
        }, 0.16)

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
        Set = function(_, v) setState(v, true) end,
        Get = function() return state end
    }
end

--========================================================--
--                   Element: Slider
--========================================================--

function Tab:AddSlider(options)
    options = options or {}
    local text = options.Text or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local rounding = options.Rounding or 1
    local callback = options.Callback

    local value = default

    local frame = Create("Frame", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.5 })
    })

    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 10, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Theme.Text,
        Text = ("%s: %s"):format(text, tostring(value))
    })

    local bar = Create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 1, -14),
        BackgroundColor3 = Theme.ElementAlt
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local fill = Create("Frame", {
        Parent = bar,
        Size = UDim2.new((value - min) / math.max((max - min), 1), 0, 1, 0),
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
        Set = function(_, v) setValue(v, true) end,
        Get = function() return value end
    }
end

--========================================================--
--                   Element: Input
--========================================================--

function Tab:AddInput(options)
    options = options or {}
    local placeholder = options.Placeholder or "Type here..."
    local default = options.Default or ""
    local text = options.Text or "Input"
    local callback = options.Callback

    local frame = Create("Frame", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.5 })
    })

    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.Text,
        Text = text
    })

    local box = Create("TextBox", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, -10, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.SubText,
        PlaceholderText = placeholder,
        Text = default
    })

    box.FocusLost:Connect(function(enterPressed)
        if callback then
            coroutine.wrap(callback)(box.Text, enterPressed)
        end
    end)

    return {
        Instance = frame,
        Set = function(_, v) box.Text = v end,
        Get = function() return box.Text end
    }
end

--========================================================--
--                   Element: Dropdown
--========================================================--

function Tab:AddDropdown(options)
    options = options or {}
    local text = options.Text or "Dropdown"
    local values = options.Values or {}
    local default = options.Default or values[1]
    local callback = options.Callback

    local current = default

    local frame = Create("Frame", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.5 })
    })

    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.Text,
        Text = text
    })

    local button = Create("TextButton", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, -10, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        Text = tostring(current)
    })

    local arrow = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.SubText,
        Text = "▾"
    })

    local listFrame = Create("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 0, 1, 2),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.ElementAlt,
        ClipsDescendants = true,
        ZIndex = 10
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.5 }),
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2)
        })
    })

    local optionButtons = {}
    local open = false

    local function rebuild()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, v in ipairs(values) do
            local optBtn = Create("TextButton", {
                Parent = listFrame,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = Theme.ElementAlt,
                Text = v,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.Text,
                AutoButtonColor = false
            })

            optBtn.MouseEnter:Connect(function()
                Tween(optBtn, { BackgroundColor3 = Theme.Element }, 0.12)
            end)
            optBtn.MouseLeave:Connect(function()
                Tween(optBtn, { BackgroundColor3 = Theme.ElementAlt }, 0.12)
            end)

            optBtn.MouseButton1Click:Connect(function()
                current = v
                button.Text = tostring(current)
                if callback then
                    coroutine.wrap(callback)(current)
                end
            end)

            table.insert(optionButtons, optBtn)
        end

        local count = #values
        local height = math.clamp(count * 24 + (count > 0 and 4 or 0), 0, 180)
        if open then
            Tween(listFrame, { Size = UDim2.new(1, 0, 0, height) }, 0.16)
        else
            listFrame.Size = UDim2.new(1, 0, 0, 0)
        end
    end

    local function setOpen(v)
        open = v
        arrow.Text = v and "▴" or "▾"
        local count = #values
        local height = math.clamp(count * 24 + (count > 0 and 4 or 0), 0, 180)
        Tween(listFrame, { Size = v and UDim2.new(1, 0, 0, height) or UDim2.new(1, 0, 0, 0) }, 0.16)
    end

    button.MouseButton1Click:Connect(function()
        setOpen(not open)
    end)

    rebuild()

    return {
        Instance = frame,
        Set = function(_, v)
            current = v
            button.Text = tostring(current)
            if callback then
                coroutine.wrap(callback)(current)
            end
        end,
        Get = function() return current end,
        SetValues = function(_, vals)
            values = vals or {}
            rebuild()
        end
    }
end

--========================================================--
--                   Element: Keybind
--========================================================--

function Tab:AddKeybind(options)
    options = options or {}
    local text = options.Text or "Keybind"
    local default = options.Default or Enum.KeyCode.F
    local callback = options.Callback

    local currentKey = default
    local listening = false

    local frame = Create("Frame", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Element
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = Theme.StrokeSoft, Transparency = 0.5 })
    })

    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.Text,
        Text = text
    })

    local button = Create("TextButton", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, -10, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        Text = currentKey.Name
    })

    button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "Press a key..."
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end

        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey = input.KeyCode
                listening = false
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
        Set = function(_, keycode)
            currentKey = keycode
            button.Text = currentKey.Name
        end,
        Get = function() return currentKey end
    }
end

--========================================================--
--                   Public API Wrapper
--========================================================--

local API = {}

function API:CreateWindow(opts)
    return Fluent:CreateWindow(opts)
end

return API
