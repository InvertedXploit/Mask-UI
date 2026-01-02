--// BLOCK UI LIBRARY | DARK GRAY | CLEAN | EXPANDABLE

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Library = {}
local CORNER = UDim.new(0,5)

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
        Frame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
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
    T.Parent = Frame

    local D = Instance.new("TextLabel")
    D.Position = UDim2.fromScale(0,0.4)
    D.Size = UDim2.fromScale(1,0.6)
    D.BackgroundTransparency = 1
    D.Text = Text
    D.Font = Enum.Font.Gotham
    D.TextSize = 14
    D.TextWrapped = true
    D.TextColor3 = Color3.fromRGB(220,220,220)
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
    Main.Size = UDim2.fromOffset(500, 320)
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
    Top.Size = UDim2.fromOffset(500, 38)
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
    Min.Size = UDim2.fromOffset(28,28)
    Min.Position = UDim2.new(1,-64,0.5,-14)
    Min.Text = "–"
    Min.Font = Enum.Font.GothamBold
    Min.TextSize = 18
    Min.TextColor3 = Color3.fromRGB(255,255,255)
    Min.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Min.BorderSizePixel = 0
    Min.Parent = Top
    Corner(Min)

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.fromOffset(28,28)
    Close.Position = UDim2.new(1,-32,0.5,-14)
    Close.Text = "X"
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.TextColor3 = Color3.fromRGB(255,255,255)
    Close.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Close.BorderSizePixel = 0
    Close.Parent = Top
    Corner(Close)

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

    local Tabs = Instance.new("Frame")
    Tabs.Position = UDim2.fromOffset(8,46)
    Tabs.Size = UDim2.fromOffset(115,260)
    Tabs.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Tabs.BorderSizePixel = 0
    Tabs.Parent = Main
    Corner(Tabs)

    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingTop = UDim.new(0,8)
    TabPad.PaddingLeft = UDim.new(0,8)
    TabPad.PaddingRight = UDim.new(0,8)
    TabPad.Parent = Tabs

    local TabList = Instance.new("UIListLayout", Tabs)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Padding = UDim.new(0,8)

    local Pages = Instance.new("Frame")
    Pages.Position = UDim2.fromOffset(130,46)
    Pages.Size = UDim2.fromOffset(360,260)
    Pages.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Pages.BorderSizePixel = 0
    Pages.Parent = Main
    Corner(Pages)

    local Window = {}

    function Window:CreateTab(Name)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.fromOffset(100,34)
        Btn.Text = Name
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.TextColor3 = Color3.fromRGB(230,230,230)
        Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Btn.BorderSizePixel = 0
        Btn.Parent = Tabs
        Corner(Btn)

        local Page = Instance.new("Frame")
        Page.Size = UDim2.fromScale(1,1)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = Pages

        local Pad = Instance.new("UIPadding")
        Pad.PaddingTop = UDim.new(0,12)
        Pad.PaddingLeft = UDim.new(0,12)
        Pad.Parent = Page

        local Layout = Instance.new("UIListLayout", Page)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.Padding = UDim.new(0,12)

        Btn.MouseButton1Click:Connect(function()
            for _,v in pairs(Pages:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            Page.Visible = true
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
            B.Parent = Page
            Corner(B)

            B.MouseButton1Click:Connect(function()
                if Callback then
                    Callback(function(t,m)
                        Notify(Gui,t,m)
                    end)
                end
            end)
        end

        if #Pages:GetChildren() == 1 then
            Page.Visible = true
        end

        return Tab
    end

    return Window
end

return Library
