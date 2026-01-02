local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local MaskUI = {}

local Theme = {
	Background = Color3.fromRGB(88, 26, 26),
	BackgroundDark = Color3.fromRGB(70, 20, 20),
	Sidebar = Color3.fromRGB(110, 35, 35),
	Accent = Color3.fromRGB(170, 60, 60),
	Text = Color3.fromRGB(235, 235, 235),
	SubText = Color3.fromRGB(180, 180, 180)
}

local function Tween(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

function MaskUI:CreateWindow(title)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "MaskUI"
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")

	local Main = Instance.new("Frame")
	Main.Size = UDim2.fromScale(0.45, 0.55)
	Main.Position = UDim2.fromScale(0.275, 0.225)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui
	Main.ClipsDescendants = true

	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundColor3 = Theme.BackgroundDark
	Header.BorderSizePixel = 0
	Header.Parent = Main

	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

	local Title = Instance.new("TextLabel")
	Title.Text = title or "Mask"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 14
	Title.TextColor3 = Theme.Text
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = Left
	Title.Size = UDim2.new(1, -130, 1, 0)
	Title.Position = UDim2.new(0, 12, 0, 0)
	Title.Parent = Header

	local function HeaderButton(txt, x)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(28, 28)
		b.Position = UDim2.new(1, x, 0, 6)
		b.Text = txt
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = Theme.Text
		b.BackgroundColor3 = Theme.Sidebar
		b.AutoButtonColor = false
		b.Parent = Header

		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

		b.MouseEnter:Connect(function()
			Tween(b, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent})
		end)

		b.MouseLeave:Connect(function()
			Tween(b, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Sidebar})
		end)

		return b
	end

	local Close = HeaderButton("X", -36)
	local Minimize = HeaderButton("-", -68)
	local Search = HeaderButton("🔍", -100)

	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 120, 1, -40)
	Sidebar.Position = UDim2.new(0, 0, 0, 40)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main

	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -120, 1, -40)
	Content.Position = UDim2.new(0, 120, 0, 40)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	local SearchBox = Instance.new("TextBox")
	SearchBox.PlaceholderText = "Search"
	SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextSize = 13
	SearchBox.TextColor3 = Theme.Text
	SearchBox.PlaceholderColor3 = Theme.SubText
	SearchBox.BackgroundColor3 = Theme.Sidebar
	SearchBox.Size = UDim2.new(0, 0, 0, 28)
	SearchBox.Position = UDim2.new(1, -104, 0, 6)
	SearchBox.TextTransparency = 1
	SearchBox.ClearTextOnFocus = false
	SearchBox.Parent = Header

	Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

	local open = false
	Search.MouseButton1Click:Connect(function()
		open = not open
		Tween(SearchBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			Size = open and UDim2.new(0, 160, 0, 28) or UDim2.new(0, 0, 0, 28),
			TextTransparency = open and 0 or 1
		})
	end)

	local minimized = false
	local fullSize = Main.Size

	Minimize.MouseButton1Click:Connect(function()
		minimized = not minimized
		Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
			Size = minimized and UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 40) or fullSize
		})
	end)

	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local dragging, startPos, dragStart
	Header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startPos = Main.Position
			dragStart = i.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragStart
			Main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return {
		Sidebar = Sidebar,
		Content = Content
	}
end

return MaskUI
