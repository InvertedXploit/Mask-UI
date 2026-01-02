-------------------------
-- MASK UI LIBRARY (FULL FIXED)
-------------------------

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Library = {}
local TOGGLE_KEY = Enum.KeyCode.RightShift
local toggled = true

function Library:SetToggleKey(key)
	TOGGLE_KEY = key
end

pcall(function()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	if pg:FindFirstChild("MaskHub") then
		pg.MaskHub:Destroy()
	end
end)

-- THEME
local COLORS = {
	BG = Color3.fromRGB(18,18,18),
	TOP = Color3.fromRGB(26,26,26),
	TABS = Color3.fromRGB(22,22,22),
	ELEMENT = Color3.fromRGB(36,36,36),
	HOVER = Color3.fromRGB(46,46,46),
	ACCENT = Color3.fromRGB(235,235,235),
	MUTED = Color3.fromRGB(150,150,150),
	STROKE = Color3.fromRGB(60,60,60)
}

local CORNER = UDim.new(0,6)

local ICONS = {
	Search = "rbxassetid://6031154871"
}

local DEFAULT_SIZE = UDim2.fromOffset(640, 440)
local HEADER_HEIGHT = 46

local function Corner(x)
	local c = Instance.new("UICorner")
	c.CornerRadius = CORNER
	c.Parent = x
end

local function Drag(handle, frame)
	local dragging, startPos, dragStart
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function Notify(gui, title, text)
	local f = Instance.new("Frame", gui)
	f.Size = UDim2.fromOffset(300, 90)
	f.Position = UDim2.new(1, -20, 1, -20)
	f.AnchorPoint = Vector2.new(1,1)
	f.BackgroundColor3 = COLORS.ELEMENT
	f.BorderSizePixel = 0
	Corner(f)

	local s = Instance.new("UIStroke", f)
	s.Color = COLORS.STROKE

	local t = Instance.new("TextLabel", f)
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1,-20,0,32)
	t.Position = UDim2.fromOffset(10,4)
	t.TextXAlignment = Left
	t.Text = title
	t.Font = Enum.Font.GothamBold
	t.TextSize = 16
	t.TextColor3 = COLORS.ACCENT

	local d = Instance.new("TextLabel", f)
	d.BackgroundTransparency = 1
	d.Size = UDim2.new(1,-20,1,-36)
	d.Position = UDim2.fromOffset(10,32)
	d.TextWrapped = true
	d.TextXAlignment = Left
	d.Text = text
	d.Font = Enum.Font.Gotham
	d.TextSize = 14
	d.TextColor3 = COLORS.MUTED

	f.BackgroundTransparency = 1
	TweenService:Create(f, TweenInfo.new(.25), {BackgroundTransparency = 0}):Play()

	task.delay(3,function()
		TweenService:Create(f, TweenInfo.new(.25), {BackgroundTransparency = 1}):Play()
		task.wait(.3)
		f:Destroy()
	end)
end

function Library:CreateWindow(title)
	local Gui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
	Gui.Name = "MaskHub"
	Gui.ResetOnSpawn = false

	local Main = Instance.new("Frame", Gui)
	Main.Size = DEFAULT_SIZE
	Main.Position = UDim2.fromScale(0.5,0.5)
	Main.AnchorPoint = Vector2.new(0.5,0.5)
	Main.BackgroundColor3 = COLORS.BG
	Main.BorderSizePixel = 0
	Corner(Main)

	local Stroke = Instance.new("UIStroke", Main)
	Stroke.Color = COLORS.STROKE

	-- TOP BAR
	local Top = Instance.new("Frame", Main)
	Top.Size = UDim2.new(1,0,0,HEADER_HEIGHT)
	Top.BackgroundColor3 = COLORS.TOP
	Top.BorderSizePixel = 0
	Corner(Top)

	local Title = Instance.new("TextLabel", Top)
	Title.BackgroundTransparency = 1
	Title.Size = UDim2.new(1,-140,1,0)
	Title.Position = UDim2.fromOffset(14,0)
	Title.TextXAlignment = Left
	Title.Text = title
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextColor3 = COLORS.ACCENT

	local Close = Instance.new("TextButton", Top)
	Close.Size = UDim2.fromOffset(26,26)
	Close.Position = UDim2.new(1,-34,.5,-13)
	Close.Text = "×"
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 20
	Close.TextColor3 = COLORS.MUTED
	Close.BackgroundTransparency = 1

	local Min = Instance.new("TextButton", Top)
	Min.Size = UDim2.fromOffset(26,26)
	Min.Position = UDim2.new(1,-66,.5,-13)
	Min.Text = "–"
	Min.Font = Enum.Font.GothamBold
	Min.TextSize = 20
	Min.TextColor3 = COLORS.MUTED
	Min.BackgroundTransparency = 1

	local SearchBtn = Instance.new("ImageButton", Top)
	SearchBtn.Size = UDim2.fromOffset(20,20)
	SearchBtn.Position = UDim2.new(1,-98,.5,-10)
	SearchBtn.BackgroundTransparency = 1
	SearchBtn.Image = ICONS.Search
	SearchBtn.ImageColor3 = COLORS.MUTED

	Drag(Top, Main)

	-- TABS BAR
	local Tabs = Instance.new("Frame", Main)
	Tabs.Position = UDim2.fromOffset(0, HEADER_HEIGHT)
	Tabs.Size = UDim2.new(1,0,0,36)
	Tabs.BackgroundColor3 = COLORS.TABS
	Tabs.BorderSizePixel = 0

	local TabPad = Instance.new("UIPadding", Tabs)
	TabPad.PaddingLeft = UDim.new(0,12)

	local TabLayout = Instance.new("UIListLayout", Tabs)
	TabLayout.FillDirection = Horizontal
	TabLayout.Padding = UDim.new(0,8)

	local SearchBox = Instance.new("TextBox", Tabs)
	SearchBox.Visible = false
	SearchBox.Size = UDim2.new(1,-24,1,-8)
	SearchBox.Position = UDim2.fromOffset(12,4)
	SearchBox.BackgroundColor3 = COLORS.ELEMENT
	SearchBox.PlaceholderText = "Search..."
	SearchBox.Text = ""
	SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextSize = 14
	SearchBox.TextColor3 = COLORS.ACCENT
	Corner(SearchBox)

	-- PAGES
	local Pages = Instance.new("Frame", Main)
	Pages.Position = UDim2.fromOffset(0, HEADER_HEIGHT + 36)
	Pages.Size = UDim2.new(1,0,1,-(HEADER_HEIGHT + 36))
	Pages.BackgroundTransparency = 1

	local minimized = false
	Min.MouseButton1Click:Connect(function()
		minimized = not minimized
		Tabs.Visible = not minimized
		Pages.Visible = not minimized
		Main.Size = minimized and UDim2.new(DEFAULT_SIZE.X.Scale, DEFAULT_SIZE.X.Offset, 0, HEADER_HEIGHT)
			or DEFAULT_SIZE
	end)

	SearchBtn.MouseButton1Click:Connect(function()
		SearchBox.Visible = not SearchBox.Visible
		for _,v in Tabs:GetChildren() do
			if v:IsA("TextButton") then
				v.Visible = not SearchBox.Visible
			end
		end
	end)

	Close.MouseButton1Click:Connect(function()
		Gui:Destroy()
	end)

	UserInputService.InputBegan:Connect(function(i,gp)
		if not gp and i.KeyCode == TOGGLE_KEY then
			toggled = not toggled
			Gui.Enabled = toggled
		end
	end)

	local Window = {}

	function Window:CreateTab(name)
		local Btn = Instance.new("TextButton", Tabs)
		Btn.Size = UDim2.fromOffset(110,26)
		Btn.Text = name
		Btn.Font = Enum.Font.Gotham
		Btn.TextSize = 14
		Btn.TextColor3 = COLORS.ACCENT
		Btn.BackgroundColor3 = COLORS.ELEMENT
		Corner(Btn)

		local Scroll = Instance.new("ScrollingFrame", Pages)
		Scroll.Size = UDim2.fromScale(1,1)
		Scroll.ScrollBarThickness = 6
		Scroll.BackgroundTransparency = 1
		Scroll.Visible = false

		local Pad = Instance.new("UIPadding", Scroll)
		Pad.PaddingTop = UDim.new(0,14)
		Pad.PaddingLeft = UDim.new(0,14)
		Pad.PaddingRight = UDim.new(0,14)

		local Layout = Instance.new("UIListLayout", Scroll)
		Layout.Padding = UDim.new(0,12)

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 16)
		end)

		Btn.MouseButton1Click:Connect(function()
			for _,v in Pages:GetChildren() do
				if v:IsA("ScrollingFrame") then v.Visible = false end
			end
			Scroll.Visible = true
		end)

		if #Pages:GetChildren() == 1 then
			Scroll.Visible = true
		end

		local Tab = {}

		function Tab:CreateButton(text, cb)
			local b = Instance.new("TextButton", Scroll)
			b.Size = UDim2.new(1,0,0,38)
			b.Text = text
			b.Font = Enum.Font.Gotham
			b.TextSize = 14
			b.TextColor3 = COLORS.ACCENT
			b.BackgroundColor3 = COLORS.ELEMENT
			Corner(b)
			b.MouseButton1Click:Connect(function()
				if cb then cb(function(t,m) Notify(Gui,t,m) end) end
			end)
		end

		function Tab:CreateToggle(text, default, cb)
			local state = default
			local t = Instance.new("TextButton", Scroll)
			t.Size = UDim2.new(1,0,0,38)
			t.Text = text
			t.Font = Enum.Font.Gotham
			t.TextSize = 14
			t.TextColor3 = COLORS.ACCENT
			t.BackgroundColor3 = COLORS.ELEMENT
			Corner(t)
			t.MouseButton1Click:Connect(function()
				state = not state
				t.BackgroundColor3 = state and COLORS.HOVER or COLORS.ELEMENT
				if cb then cb(state) end
			end)
		end

		return Tab
	end

	return Window
end

return Library
