local Library = {}
Library.__index = Library

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Theme = {
    Background = Color3.fromRGB(28, 28, 28),
    Topbar = Color3.fromRGB(22, 22, 22),
    Accent = Color3.fromRGB(90, 120, 255),
    Text = Color3.fromRGB(235, 235, 235),
    Button = Color3.fromRGB(40, 40, 40),
    ButtonHover = Color3.fromRGB(55, 55, 55),
    ToggleOn = Color3.fromRGB(90, 120, 255),
    ToggleOff = Color3.fromRGB(60, 60, 60),
    SliderBar = Color3.fromRGB(50, 50, 50),
    SliderFill = Color3.fromRGB(90, 120, 255),
    Dropdown = Color3.fromRGB(40, 40, 40),
    SearchBox = Color3.fromRGB(35, 35, 35),
    TopIcon = Color3.fromRGB(200, 200, 200)
}

local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Window
function Library:Window(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SmoothUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 550, 0, 360)
    Main.Position = UDim2.new(0.5, -275, 0.5, -180)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Visible = true
    Main.Parent = ScreenGui

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 32)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 150, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Theme.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 170, 0, 22)
    SearchBox.Position = UDim2.new(1, -240, 0.5, -11)
    SearchBox.BackgroundColor3 = Theme.SearchBox
    SearchBox.BorderSizePixel = 0
    SearchBox.ClearTextOnFocus = false
    SearchBox.PlaceholderText = "Search..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = Theme.Text
    SearchBox.TextSize = 14
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Parent = Topbar

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
    MinimizeButton.Position = UDim2.new(1, -64, 0.5, -12)
    MinimizeButton.BackgroundColor3 = Theme.Topbar
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Theme.TopIcon
    MinimizeButton.TextSize = 20
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = Topbar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -32, 0.5, -12)
    CloseButton.BackgroundColor3 = Theme.Topbar
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Theme.TopIcon
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Topbar

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.Position = UDim2.new(0, 0, 0, 32)
    TabBar.BackgroundColor3 = Theme.Background
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabBar

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, 0, 1, -62)
    Pages.Position = UDim2.new(0, 0, 0, 62)
    Pages.BackgroundColor3 = Theme.Background
    Pages.BorderSizePixel = 0
    Pages.Parent = Main

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 20)
    ToggleButton.Position = UDim2.new(0, 10, 1, -30)
    ToggleButton.BackgroundColor3 = Theme.Topbar
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "UI"
    ToggleButton.TextColor3 = Theme.Text
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = ScreenGui

    -- Dragging
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local WindowObj = {
        _screen = ScreenGui,
        _main = Main,
        _topbar = Topbar,
        _tabbar = TabBar,
        _pages = Pages,
        _search = SearchBox,
        _tabs = {},
        _currentTab = nil,
        _minimized = false,
        _visible = true,
        _allElements = {}
    }
    setmetatable(WindowObj, Library)

    -- Minimize
    MinimizeButton.MouseButton1Click:Connect(function()
        WindowObj._minimized = not WindowObj._minimized
        if WindowObj._minimized then
            tween(Pages, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
        else
            tween(Pages, {Size = UDim2.new(1, 0, 1, -62)}, 0.15)
        end
    end)

    -- Close (hide main, keep toggle button)
    local function setMainVisible(state)
        WindowObj._visible = state
        Main.Visible = state
    end

    CloseButton.MouseButton1Click:Connect(function()
        setMainVisible(false)
    end)

    -- UI toggle: RightShift + corner button
    ToggleButton.MouseButton1Click:Connect(function()
        setMainVisible(not WindowObj._visible)
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            setMainVisible(not WindowObj._visible)
        end
    end)

    -- Search (Rayfield-style filtering)
    local function applySearch()
        local query = string.lower(SearchBox.Text)
        for _, info in ipairs(WindowObj._allElements) do
            local matches = (query == "") or string.find(string.lower(info.Text), query, 1, true)
            if info.Object and info.Object.Parent then
                info.Object.Visible = matches and (not WindowObj._minimized)
            end
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

    WindowObj._applySearch = applySearch

    return WindowObj
end

-- Tab
function Library:Tab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 90, 1, 0)
    TabButton.BackgroundColor3 = Theme.Button
    TabButton.Text = name
    TabButton.TextColor3 = Theme.Text
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.Gotham
    TabButton.Parent = self._tabbar

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 4
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.Parent = self._pages

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 6)
    Layout.Parent = Page

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    local TabObj = {
        _window = self,
        _page = Page,
        _button = TabButton
    }
    setmetatable(TabObj, Library)

    table.insert(self._tabs, TabObj)

    local function selectTab()
        for _, t in ipairs(self._tabs) do
            t._page.Visible = false
            tween(t._button, {BackgroundColor3 = Theme.Button}, 0.1)
        end
        Page.Visible = true
        tween(TabButton, {BackgroundColor3 = Theme.ButtonHover}, 0.1)
        self._currentTab = TabObj
        if self._applySearch then
            self._applySearch()
        end
    end

    TabButton.MouseButton1Click:Connect(selectTab)

    if not self._currentTab then
        selectTab()
    end

    return TabObj
end

-- Helper: register element for search
local function registerElement(window, object, text)
    table.insert(window._allElements, {
        Object = object,
        Text = text or ""
    })
end

-- Button
function Library:Button(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Theme.Button
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Theme.Text
    Btn.TextSize = 16
    Btn.Font = Enum.Font.Gotham
    Btn.Parent = self._page

    Btn.MouseEnter:Connect(function()
        tween(Btn, {BackgroundColor3 = Theme.ButtonHover}, 0.1)
    end)
    Btn.MouseLeave:Connect(function()
        tween(Btn, {BackgroundColor3 = Theme.Button}, 0.1)
    end)

    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    registerElement(self._window, Btn, text)
    return Btn
end

-- Toggle
function Library:Toggle(text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Theme.Button
    Frame.BorderSizePixel = 0
    Frame.Parent = self._page

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 16
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("Frame")
    ToggleBtn.Size = UDim2.new(0, 32, 0, 18)
    ToggleBtn.Position = UDim2.new(1, -42, 0.5, -9)
    ToggleBtn.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame

    local state = default

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            tween(ToggleBtn, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}, 0.12)
            pcall(callback, state)
        end
    end)

    registerElement(self._window, Frame, text)
    return {
        Set = function(_, v)
            state = v
            ToggleBtn.BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff
            pcall(callback, v)
        end
    }
end

-- Slider
function Library:Slider(text, min, max, default, callback)
    default = math.clamp(default or min, min, max)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 52)
    Frame.BackgroundColor3 = Theme.Button
    Frame.BorderSizePixel = 0
    Frame.Parent = self._page

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = text .. " (" .. tostring(default) .. ")"
    Label.TextColor3 = Theme.Text
    Label.TextSize = 16
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 6)
    Bar.Position = UDim2.new(0, 10, 0, 32)
    Bar.BackgroundColor3 = Theme.SliderBar
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame

    local Fill = Instance.new("Frame")
    local pct = (default - min) / (max - min)
    Fill.Size = UDim2.new(pct, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.SliderFill
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local dragging = false

    local function update(input)
        local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        local val = math.floor(min + (max - min) * rel)
        Label.Text = text .. " (" .. tostring(val) .. ")"
        pcall(callback, val)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    registerElement(self._window, Frame, text)
    return Frame
end

-- Searchable Dropdown
function Library:Dropdown(text, list, callback)
    list = list or {}

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Theme.Button
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = self._page

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 16
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -24, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Theme.Text
    Arrow.TextSize = 16
    Arrow.Font = Enum.Font.Gotham
    Arrow.Parent = Frame

    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, -10, 0, 4)
    DropFrame.Position = UDim2.new(0, 5, 0, 36)
    DropFrame.BackgroundColor3 = Theme.Dropdown
    DropFrame.BorderSizePixel = 0
    DropFrame.Parent = Frame

    local Search = Instance.new("TextBox")
    Search.Size = UDim2.new(1, -10, 0, 20)
    Search.Position = UDim2.new(0, 5, 0, 4)
    Search.BackgroundColor3 = Theme.SearchBox
    Search.BorderSizePixel = 0
    Search.PlaceholderText = "Search..."
    Search.ClearTextOnFocus = false
    Search.Text = ""
    Search.TextColor3 = Theme.Text
    Search.TextSize = 14
    Search.Font = Enum.Font.Gotham
    Search.Parent = DropFrame

    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, -10, 0, 80)
    ListFrame.Position = UDim2.new(0, 5, 0, 28)
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListFrame.ScrollBarThickness = 4
    ListFrame.BackgroundTransparency = 1
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = DropFrame

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 2)
    Layout.Parent = ListFrame

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 4)
    end)

    local open = false
    local current = nil
    local items = {}

    local function rebuild()
        for _, b in ipairs(ListFrame:GetChildren()) do
            if b:IsA("TextButton") then b:Destroy() end
        end
        local query = string.lower(Search.Text)
        for _, v in ipairs(list) do
            local s = string.lower(tostring(v))
            if query == "" or string.find(s, query, 1, true) then
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 24)
                Btn.BackgroundColor3 = Theme.Button
                Btn.BorderSizePixel = 0
                Btn.Text = tostring(v)
                Btn.TextColor3 = Theme.Text
                Btn.TextSize = 14
                Btn.Font = Enum.Font.Gotham
                Btn.Parent = ListFrame

                Btn.MouseButton1Click:Connect(function()
                    current = v
                    Label.Text = text .. ": " .. tostring(v)
                    open = false
                    tween(Frame, {Size = UDim2.new(1, 0, 0, 36)}, 0.15)
                    tween(Arrow, {TextTransparency = 0}, 0.1)
                    pcall(callback, v)
                end)

                table.insert(items, Btn)
            end
        end
    end

    Search:GetPropertyChangedSignal("Text"):Connect(rebuild)
    rebuild()

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            if open then
                tween(Frame, {Size = UDim2.new(1, 0, 0, 36 + 110)}, 0.15)
            else
                tween(Frame, {Size = UDim2.new(1, 0, 0, 36)}, 0.15)
            end
        end
    end)

    registerElement(self._window, Frame, text)
    return {
        Set = function(_, v)
            current = v
            Label.Text = text .. ": " .. tostring(v)
            pcall(callback, v)
        end
    }
end

-- Textbox
function Library:Textbox(text, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Theme.Button
    Frame.BorderSizePixel = 0
    Frame.Parent = self._page

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 16
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0.6, -20, 0, 24)
    Box.Position = UDim2.new(0.4, 10, 0.5, -12)
    Box.BackgroundColor3 = Theme.SearchBox
    Box.BorderSizePixel = 0
    Box.PlaceholderText = placeholder or ""
    Box.ClearTextOnFocus = false
    Box.Text = ""
    Box.TextColor3 = Theme.Text
    Box.TextSize = 14
    Box.Font = Enum.Font.Gotham
    Box.Parent = Frame

    Box.FocusLost:Connect(function(enter)
        if enter then
            pcall(callback, Box.Text)
        end
    end)

    registerElement(self._window, Frame, text)
    return Box
end

return Library
