-------------------------
-- MASK UI LIBRARY PART 1
-------------------------

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Library = {}
local CORNER = UDim.new(0,12)
local TOGGLE_KEY = Enum.KeyCode.RightShift

local toggled = true

pcall(function()
    local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
    if pg:FindFirstChild("MaskHub") then
        pg.MaskHub:Destroy()
    end
end)

local function Corner(x)
    local c = Instance.new("UICorner")
    c.CornerRadius = CORNER
    c.Parent = x
end

local function Drag(Handle, Frame)
    local dragging = false
    local dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

local function Notify(Gui, Title, Text)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(280, 90)
    Frame.Position = UDim2.new(1, -20, 1, -20)
    Frame.AnchorPoint = Vector2.new(1,1)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    Frame.BackgroundTransparency = 1
    Frame.Parent = Gui
    Corner(Frame)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(80, 80, 80)
    Stroke.Parent = Frame

    local T = Instance.new("TextLabel")
    T.Size = UDim2.fromScale(1,0.4)
    T.BackgroundTransparency = 1
    T.Text = Title
    T.Font = Enum.Font.GothamBold
    T.TextSize = 16
    T.TextColor3 = Color3.fromRGB(255,255,255)
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Position = UDim2.fromOffset(10,0)
    T.Parent = Frame

    local D = Instance.new("TextLabel")
    D.Position = UDim2.fromOffset(10,36)
    D.Size = UDim2.fromScale(1,-36)
    D.BackgroundTransparency = 1
    D.Text = Text
    D.Font = Enum.Font.Gotham
    D.TextSize = 14
    D.TextWrapped = true
    D.TextColor3 = Color3.fromRGB(220,220,220)
    D.TextXAlignment = Enum.TextXAlignment.Left
    D.Parent = Frame

    TweenService:Create(Frame, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()

    task.delay(3, function()
        TweenService:Create(Frame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        Frame:Destroy()
    end)
end

function Library:CreateWindow(Title)
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "MaskHub"
    Gui.ResetOnSpawn = false
    Gui.Parent = Players.LocalPlayer.PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.fromOffset(500, 340)
    Main.Position = UDim2.fromScale(0.5,0.5)
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 0
    Main.Parent = Gui
    Corner(Main)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(80, 80, 80)
    Stroke.Thickness = 1
    Stroke.Parent = Main

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1,0,0,40)
    Top.Position = UDim2.new(0,0,0,0)
    Top.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Top.BorderSizePixel = 0
    Top.Parent = Main
    Corner(Top)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.fromScale(1,1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.fromOffset(10,0)
    TitleLabel.Text = Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLabel.Parent = Top

    local Min = Instance.new("TextButton")
    Min.Size = UDim2.fromOffset(24,24)
    Min.Position = UDim2.new(1,-60,0.5,-12)
    Min.Text = "–"
    Min.Font = Enum.Font.GothamBold
    Min.TextSize = 20
    Min.TextColor3 = Color3.fromRGB(200,200,200)
    Min.BackgroundTransparency = 1
    Min.BorderSizePixel = 0
    Min.Parent = Top

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.fromOffset(24,24)
    Close.Position = UDim2.new(1,-30,0.5,-12)
    Close.Text = "×"
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 20
    Close.TextColor3 = Color3.fromRGB(200,200,200)
    Close.BackgroundTransparency = 1
    Close.BorderSizePixel = 0
    Close.Parent = Top

    local BodyVisible = true
    Close.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)

    Min.MouseButton1Click:Connect(function()
        BodyVisible = not BodyVisible
        for _,v in pairs(Main:GetChildren()) do
            if v ~= Top then
                v.Visible = BodyVisible
            end
        end
    end)

    Drag(Top, Main)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == TOGGLE_KEY then
            toggled = not toggled
            Gui.Enabled = toggled
        end
    end)

    -- Tabs bar at top, under Top
    local Tabs = Instance.new("Frame")
    Tabs.Position = UDim2.new(0,0,0,40)
    Tabs.Size = UDim2.new(1,0,0,32)
    Tabs.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Tabs.BorderSizePixel = 0
    Tabs.Parent = Main

    local TabsCorner = Instance.new("UICorner")
    TabsCorner.CornerRadius = UDim.new(0,0)
    TabsCorner.Parent = Tabs

    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingLeft = UDim.new(0,8)
    TabPad.PaddingRight = UDim.new(0,8)
    TabPad.PaddingTop = UDim.new(0,4)
    TabPad.Parent = Tabs

    local TabList = Instance.new("UIListLayout", Tabs)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabList.VerticalAlignment = Enum.VerticalAlignment.Center
    TabList.Padding = UDim.new(0,8)

    -- Pages fill remaining area
    local Pages = Instance.new("Frame")
    Pages.Position = UDim2.new(0,0,0,72)
    Pages.Size = UDim2.new(1,0,1,-72)
    Pages.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Pages.BorderSizePixel = 0
    Pages.Parent = Main
    Corner(Pages)

    local Window = {}

    function Window:CreateTab(Name)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0,100,1,-8)
        Btn.Text = Name
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.TextColor3 = Color3.fromRGB(230,230,230)
        Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        Btn.BorderSizePixel = 0
        Btn.AutoButtonColor = true
        Btn.Parent = Tabs
        Corner(Btn)

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.fromScale(1,1)
        Scroll.CanvasSize = UDim2.new(0,0,0,0)
        Scroll.ScrollBarThickness = 6
        Scroll.ScrollBarImageColor3 = Color3.fromRGB(120,120,120)
        Scroll.BackgroundTransparency = 1
        Scroll.Visible = false
        Scroll.Parent = Pages

        local Pad = Instance.new("UIPadding")
        Pad.PaddingTop = UDim.new(0,12)
        Pad.PaddingLeft = UDim.new(0,12)
        Pad.PaddingRight = UDim.new(0,12)
        Pad.Parent = Scroll

        local Layout = Instance.new("UIListLayout", Scroll)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        Layout.Padding = UDim.new(0,12)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 12)
        end)

        Btn.MouseButton1Click:Connect(function()
            for _,v in pairs(Pages:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Scroll.Visible = true
        end)

        local Tab = {}

        function Tab:CreateButton(Text, Callback)
            local B = Instance.new("TextButton")
            B.Size = UDim2.fromOffset(320,34)
            B.Text = Text
            B.Font = Enum.Font.Gotham
            B.TextSize = 14
            B.TextColor3 = Color3.fromRGB(240,240,240)
            B.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            B.BorderSizePixel = 0
            B.TextXAlignment = Enum.TextXAlignment.Left
            B.AutoButtonColor = true
            B.Parent = Scroll
            Corner(B)

            local PadIn = Instance.new("UIPadding")
            PadIn.PaddingLeft = UDim.new(0,10)
            PadIn.Parent = B

            B.MouseButton1Click:Connect(function()
                if Callback then
                    Callback(function(t,m)
                        Notify(Gui,t,m)
                    end)
                end
            end)
        end
        function Tab:CreateToggle(Text, Default, Callback)
            local T = Instance.new("TextButton")
            T.Size = UDim2.fromOffset(320,34)
            T.Text = ""
            T.Font = Enum.Font.Gotham
            T.TextSize = 14
            T.TextColor3 = Color3.fromRGB(240,240,240)
            T.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            T.BorderSizePixel = 0
            T.TextXAlignment = Enum.TextXAlignment.Left
            T.AutoButtonColor = true
            T.Parent = Scroll
            Corner(T)

            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.fromScale(1,1)
            Label.Position = UDim2.fromOffset(10,0)
            Label.Text = Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.fromRGB(240,240,240)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = T

            local state = Default

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.fromOffset(20,20)
            Dot.Position = UDim2.new(1,-30,0.5,-10)
            Dot.BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
            Dot.BorderSizePixel = 0
            Dot.Parent = T
            Corner(Dot)

            T.MouseButton1Click:Connect(function()
                state = not state
                Dot.BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
                if Callback then Callback(state) end
            end)
        end

        function Tab:CreateInput(Text, Placeholder, Callback)
            local Box = Instance.new("Frame")
            Box.Size = UDim2.fromOffset(320,40)
            Box.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Box.BorderSizePixel = 0
            Box.Parent = Scroll
            Corner(Box)

            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.fromOffset(150,40)
            Label.Position = UDim2.fromOffset(10,0)
            Label.Text = Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.fromRGB(240,240,240)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Box

            local Input = Instance.new("TextBox")
            Input.Size = UDim2.fromOffset(150,26)
            Input.Position = UDim2.new(1,-160,0.5,-13)
            Input.BackgroundColor3 = Color3.fromRGB(35,35,35)
            Input.Text = ""
            Input.PlaceholderText = Placeholder
            Input.Font = Enum.Font.Gotham
            Input.TextSize = 14
            Input.TextColor3 = Color3.fromRGB(255,255,255)
            Input.BorderSizePixel = 0
            Input.ClearTextOnFocus = false
            Input.Parent = Box
            Corner(Input)

            Input.FocusLost:Connect(function(enterPressed)
                if Callback and enterPressed then
                    Callback(Input.Text)
                end
            end)
        end

        function Tab:CreateSlider(Text, Min, Max, Default, Callback)
            local S = Instance.new("Frame")
            S.Size = UDim2.fromOffset(320,50)
            S.BackgroundColor3 = Color3.fromRGB(50,50,50)
            S.BorderSizePixel = 0
            S.Parent = Scroll
            Corner(S)

            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.fromOffset(260,20)
            Label.Position = UDim2.fromOffset(10,5)
            Label.Text = Text .. ": " .. Default
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.fromRGB(240,240,240)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = S

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.fromOffset(300,6)
            Bar.Position = UDim2.fromOffset(10,32)
            Bar.BackgroundColor3 = Color3.fromRGB(35,35,35)
            Bar.BorderSizePixel = 0
            Bar.Parent = S
            Corner(Bar)

            local Fill = Instance.new("Frame")
            local startRel = (Default - Min) / (Max - Min)
            Fill.Size = UDim2.fromOffset(startRel * 300,6)
            Fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar
            Corner(Fill)

            local dragging = false

            local function setFromInput(input)
                local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / 300, 0, 1)
                local val = math.floor(Min + (Max - Min) * rel)
                Fill.Size = UDim2.fromOffset(rel * 300,6)
                Label.Text = Text .. ": " .. val
                if Callback then Callback(val) end
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    setFromInput(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    setFromInput(input)
                end
            end)
        end

        function Tab:CreateDropdown(Text, List, Callback)
            local D = Instance.new("Frame")
            D.Size = UDim2.fromOffset(320,34)
            D.BackgroundColor3 = Color3.fromRGB(50,50,50)
            D.BorderSizePixel = 0
            D.Parent = Scroll
            Corner(D)

            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1,-40,1,0)
            Label.Position = UDim2.fromOffset(10,0)
            Label.Text = Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.fromRGB(240,240,240)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = D

            local Arrow = Instance.new("TextLabel")
            Arrow.BackgroundTransparency = 1
            Arrow.Size = UDim2.fromOffset(20,34)
            Arrow.Position = UDim2.new(1,-30,0)
            Arrow.Text = "▼"
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 14
            Arrow.TextColor3 = Color3.fromRGB(240,240,240)
            Arrow.Parent = D

            local Open = false

            local ListFrame = Instance.new("Frame")
            ListFrame.Size = UDim2.fromOffset(320, #List * 28 + 8)
            ListFrame.Position = UDim2.fromOffset(0,34)
            ListFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
            ListFrame.BorderSizePixel = 0
            ListFrame.Visible = false
            ListFrame.Parent = D
            Corner(ListFrame)

            local LPad = Instance.new("UIPadding")
            LPad.PaddingTop = UDim.new(0,4)
            LPad.PaddingLeft = UDim.new(0,4)
            LPad.PaddingRight = UDim.new(0,4)
            LPad.Parent = ListFrame

            local LLayout = Instance.new("UIListLayout", ListFrame)
            LLayout.Padding = UDim.new(0,4)

            for _,v in ipairs(List) do
                local Opt = Instance.new("TextButton")
                Opt.Size = UDim2.fromOffset(312,24)
                Opt.Text = v
                Opt.Font = Enum.Font.Gotham
                Opt.TextSize = 14
                Opt.TextColor3 = Color3.fromRGB(240,240,240)
                Opt.BackgroundColor3 = Color3.fromRGB(55,55,55)
                Opt.BorderSizePixel = 0
                Opt.TextXAlignment = Enum.TextXAlignment.Left
                Opt.Parent = ListFrame
                Corner(Opt)

                local PadIn = Instance.new("UIPadding")
                PadIn.PaddingLeft = UDim.new(0,8)
                PadIn.Parent = Opt

                Opt.MouseButton1Click:Connect(function()
                    Label.Text = Text .. ": " .. v
                    ListFrame.Visible = false
                    Open = false
                    if Callback then Callback(v) end
                end)
            end

            D.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Open = not Open
                    ListFrame.Visible = Open
                end
            end)
        end

        if #Pages:GetChildren() == 1 then
            Scroll.Visible = true
        end

        return Tab
    end

    return Window
end

return Library
