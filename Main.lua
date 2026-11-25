local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Target Coordinates
local TARGET_POS = Vector3.new(-344.2, 15.7, 113.8)

-- Feature States
local noclipEnabled = false
local bypassJumpEnabled = false
local antiLagEnabled = false
local menuOpen = true

-- Chill Theme Palette
local THEME = {
	Bg = Color3.fromRGB(22, 24, 33),
	Card = Color3.fromRGB(30, 33, 46),
	Accent = Color3.fromRGB(138, 180, 248),     -- Soft pastel blue
	Active = Color3.fromRGB(129, 201, 149),     -- Soft sage green
	TextMain = Color3.fromRGB(238, 240, 248),
	TextMuted = Color3.fromRGB(154, 160, 180),
	Stroke = Color3.fromRGB(52, 57, 78)
}

local OPEN_SIZE = UDim2.new(0, 260, 0, 295)

-- ScreenGui Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ResusXscriptGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Helper: Smooth Tween
local function tween(obj, props, duration)
	local info = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

-- Helper: Custom Mobile-Friendly Dragging
local function makeDraggable(dragHandle, targetFrame)
	local dragging, dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Floating Open/Close Toggle Pill (Always accessible on mobile)
local togglePill = Instance.new("TextButton")
togglePill.Name = "TogglePill"
togglePill.Size = UDim2.new(0, 115, 0, 36)
togglePill.Position = UDim2.new(0, 16, 0, 16)
togglePill.BackgroundColor3 = THEME.Bg
togglePill.TextColor3 = THEME.Accent
togglePill.Font = Enum.Font.GothamBold
togglePill.TextSize = 13
togglePill.Text = "Close Menu"
togglePill.AutoButtonColor = false
togglePill.Parent = screenGui

local pillCorner = Instance.new("UICorner")
pillCorner.CornerRadius = UDim.new(1, 0)
pillCorner.Parent = togglePill

local pillStroke = Instance.new("UIStroke")
pillStroke.Color = THEME.Stroke
pillStroke.Thickness = 1.5
pillStroke.Parent = togglePill

makeDraggable(togglePill, togglePill)

-- Main Menu Container
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = OPEN_SIZE
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -147)
mainFrame.BackgroundColor3 = THEME.Bg
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEME.Stroke
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Header Bar (Drag Area)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = THEME.Card
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

-- Cover bottom rounded corners of header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 12)
headerFix.Position = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = THEME.Card
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ResusXscript"
titleLabel.TextColor3 = THEME.Accent
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Minimize "X" Button inside Header
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
closeBtn.BackgroundColor3 = THEME.Bg
closeBtn.Text = "×"
closeBtn.TextColor3 = THEME.TextMuted
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

makeDraggable(header, mainFrame)

-- Content Container
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -58)
content.Position = UDim2.new(0, 12, 0, 52)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = content

-- Helper: Create Chill Action/Toggle Button
local function createButton(text, subtext, isToggle)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 50)
	btn.BackgroundColor3 = THEME.Card
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Stroke
	stroke.Thickness = 1
	stroke.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -70, 0, 22)
	lbl.Position = UDim2.new(0, 14, 0, 6)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = THEME.TextMain
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -70, 0, 16)
	sub.Position = UDim2.new(0, 14, 0, 27)
	sub.BackgroundTransparency = 1
	sub.Text = subtext
	sub.TextColor3 = THEME.TextMuted
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 11
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Parent = btn

	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 44, 0, 24)
	pill.Position = UDim2.new(1, -56, 0.5, -12)
	pill.BackgroundColor3 = isToggle and Color3.fromRGB(48, 52, 70) or THEME.Accent
	pill.Parent = btn

	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(1, 0)
	pCorner.Parent = pill

	local knob
	if isToggle then
		knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 18, 0, 18)
		knob.Position = UDim2.new(0, 3, 0.5, -9)
		knob.BackgroundColor3 = THEME.TextMain
		knob.Parent = pill

		local kCorner = Instance.new("UICorner")
		kCorner.CornerRadius = UDim.new(1, 0)
		kCorner.Parent = knob
	else
		local goText = Instance.new("TextLabel")
		goText.Size = UDim2.new(1, 0, 1, 0)
		goText.BackgroundTransparency = 1
		goText.Text = "TP"
		goText.TextColor3 = THEME.Bg
		goText.Font = Enum.Font.GothamBold
		goText.TextSize = 12
		goText.Parent = pill
	end

	return btn, pill, knob, sub
end

-- Anti-Lag Helper (Smooths workspace visual load on the client)
local savedMaterials = {}
local savedEffects = {}

local function applyAntiLag(enabled)
	if enabled then
		Lighting.GlobalShadows = false
		Lighting.EnvironmentSpecularScale = 0
		Lighting.EnvironmentDiffuseScale = 0

		for _, effect in ipairs(Lighting:GetChildren()) do
			if effect:IsA("PostEffect") and effect.Enabled then
				savedEffects[effect] = true
				effect.Enabled = false
			end
		end

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				if not savedMaterials[obj] then
					savedMaterials[obj] = {
						Material = obj.Material,
						CastShadow = obj.CastShadow
					}
				end
				obj.CastShadow = false
				if obj.Material ~= Enum.Material.Neon then
					obj.Material = Enum.Material.SmoothPlastic
				end
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 1
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				obj.Enabled = false
			end
		end
	else
		Lighting.GlobalShadows = true
		Lighting.EnvironmentSpecularScale = 1
		Lighting.EnvironmentDiffuseScale = 1

		for effect in pairs(savedEffects) do
			if effect and effect.Parent then
				effect.Enabled = true
			end
		end
		table.clear(savedEffects)

		for obj, data in pairs(savedMaterials) do
			if obj and obj.Parent then
				obj.Material = data.Material
				obj.CastShadow = data.CastShadow
			end
		end
		table.clear(savedMaterials)

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 0
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				obj.Enabled = true
			end
		end
	end
end

-- Protection Helper (Runs alongside Bypass Jump)
local healthConn = nil
local function setJumpProtection(enabled)
	if healthConn then
		healthConn:Disconnect()
		healthConn = nil
	end

	if enabled then
		local function bindCharacter(char)
			if not char then return end
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
			if humanoid then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				humanoid.Health = humanoid.MaxHealth
				healthConn = humanoid.HealthChanged:Connect(function()
					if bypassJumpEnabled and humanoid.Health < humanoid.MaxHealth then
						humanoid.Health = humanoid.MaxHealth
					end
				end)
			end
		end

		bindCharacter(player.Character)
	else
		local char = player.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
		end
	end
end

player.CharacterAdded:Connect(function(char)
	if bypassJumpEnabled then
		setJumpProtection(true)
	end
end)

-- 1. BYPASS FLASH Button
local tpBtn, tpPill, _, tpSub = createButton("BYPASS FLASH", "Quick warp to target zone", false)

tpBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(TARGET_POS)
		tpSub.Text = "Warped!"
		tween(tpPill, { BackgroundColor3 = THEME.Active }, 0.2)
		task.wait(1)
		tpSub.Text = "Quick warp to target zone"
		tween(tpPill, { BackgroundColor3 = THEME.Accent }, 0.2)
	end
end)

-- 2. Noclip Toggle
local noclipBtn, noclipPill, noclipKnob = createButton("Noclip", "Walk through walls", true)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	if noclipEnabled then
		tween(noclipPill, { BackgroundColor3 = THEME.Active }, 0.2)
		tween(noclipKnob, { Position = UDim2.new(1, -21, 0.5, -9) }, 0.2)
	else
		tween(noclipPill, { BackgroundColor3 = Color3.fromRGB(48, 52, 70) }, 0.2)
		tween(noclipKnob, { Position = UDim2.new(0, 3, 0.5, -9) }, 0.2)
		local char = player.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end)

-- 3. Bypass Jump Toggle (Executes Infinite Jump + Protection)
local bypassJumpBtn, bypassJumpPill, bypassJumpKnob = createButton("Bypass Jump", "Air jump & fall safety", true)

bypassJumpBtn.MouseButton1Click:Connect(function()
	bypassJumpEnabled = not bypassJumpEnabled
	if bypassJumpEnabled then
		tween(bypassJumpPill, { BackgroundColor3 = THEME.Active }, 0.2)
		tween(bypassJumpKnob, { Position = UDim2.new(1, -21, 0.5, -9) }, 0.2)
	else
		tween(bypassJumpPill, { BackgroundColor3 = Color3.fromRGB(48, 52, 70) }, 0.2)
		tween(bypassJumpKnob, { Position = UDim2.new(0, 3, 0.5, -9) }, 0.2)
	end
	setJumpProtection(bypassJumpEnabled)
end)

-- 4. Anti-Lag Toggle
local antiLagBtn, antiLagPill, antiLagKnob, antiLagSub = createButton("Anti-Lag", "Boost mobile FPS & visuals", true)

antiLagBtn.MouseButton1Click:Connect(function()
	antiLagEnabled = not antiLagEnabled
	if antiLagEnabled then
		antiLagSub.Text = "Boosted (tap to restore)"
		tween(antiLagPill, { BackgroundColor3 = THEME.Active }, 0.2)
		tween(antiLagKnob, { Position = UDim2.new(1, -21, 0.5, -9) }, 0.2)
	else
		antiLagSub.Text = "Boost mobile FPS & visuals"
		tween(antiLagPill, { BackgroundColor3 = Color3.fromRGB(48, 52, 70) }, 0.2)
		tween(antiLagKnob, { Position = UDim2.new(0, 3, 0.5, -9) }, 0.2)
	end
	applyAntiLag(antiLagEnabled)
end)

-- Open / Close Smooth Animation Logic
local function setMenuState(isOpen)
	menuOpen = isOpen
	if menuOpen then
		mainFrame.Visible = true
		togglePill.Text = "Close Menu"
		tween(mainFrame, { Size = OPEN_SIZE, BackgroundTransparency = 0 }, 0.3)
	else
		togglePill.Text = "ResusXscript"
		local t = tween(mainFrame, { Size = UDim2.new(0, 260, 0, 0), BackgroundTransparency = 1 }, 0.25)
		t.Completed:Connect(function()
			if not menuOpen then
				mainFrame.Visible = false
			end
		end)
	end
end

togglePill.MouseButton1Click:Connect(function()
	setMenuState(not menuOpen)
end)

closeBtn.MouseButton1Click:Connect(function()
	setMenuState(false)
end)

-- Noclip & Bypass Jump Loop
RunService.Stepped:Connect(function()
	local char = player.Character
	if not char then return end

	if noclipEnabled then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end

	if bypassJumpEnabled then
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health < humanoid.MaxHealth then
			humanoid.Health = humanoid.MaxHealth
		end
	end
end)

-- Infinite Jump Handler (Works on both Mobile Jump Button and Spacebar)
UserInputService.JumpRequest:Connect(function()
	if bypassJumpEnabled and player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)
