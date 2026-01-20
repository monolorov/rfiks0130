local Shared = _G.NemesisShared
local Players = Shared.Services.Players
local TweenService = Shared.Services.TweenService
local UserInputService = Shared.Services.UserInputService
local RunService = Shared.Services.RunService
local ReplicatedStorage = Shared.Services.ReplicatedStorage
local Workspace = Shared.Services.Workspace
local SoundService = Shared.Services.SoundService
local Debris = Shared.Services.Debris
local player = Shared.Player
local guiParent = Shared.GuiParent

local InfEvent = ReplicatedStorage:WaitForChild("inf")
local HITSOUND_STORAGE = guiParent:WaitForChild("ScreenGui"):WaitForChild("storage")
local FX_ROOT = ReplicatedStorage:WaitForChild("FXTemplates")
local backtrackRemote = ReplicatedStorage:WaitForChild("btl")

-- ============================================
-- Wallbang System
-- ============================================
local WALLBANG_ENABLED = false
local WALLBANG_CONFIG = {
	EntryColor = Color3.fromRGB(255, 50, 50),
	ExitColor = Color3.fromRGB(50, 255, 50),
	MarkerSize = 0.5,
	Lifetime = 3
}

local function createWallbangMarker(pos, color)
	local part = Instance.new("Part")
	part.Name = "WallbangMarker"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.ForceField
	part.Color = color
	part.Size = Vector3.new(WALLBANG_CONFIG.MarkerSize, WALLBANG_CONFIG.MarkerSize, WALLBANG_CONFIG.MarkerSize)
	part.CFrame = CFrame.new(pos)
	part.Parent = Workspace

	part.Transparency = 0
	TweenService:Create(part, TweenInfo.new(0.3), {Transparency = 0}):Play()

	Debris:AddItem(part, WALLBANG_CONFIG.Lifetime)

	task.delay(WALLBANG_CONFIG.Lifetime - 0.5, function()
		if part.Parent then
			TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0,0,0)}):Play()
		end
	end)
end

-- ============================================
-- Offscreen Arrows
-- ============================================
local OFFSCREEN_ENABLED = false
local OFFSCREEN_COLOR = Color3.fromRGB(255, 80, 80)

local Camera = workspace.CurrentCamera
local OffscreenGui = Instance.new("ScreenGui")
OffscreenGui.Name = "NemesisOffscreen"
OffscreenGui.IgnoreGuiInset = true
OffscreenGui.ResetOnSpawn = false
OffscreenGui.Parent = guiParent

local arrows = {}

local function isEnemyForArrows(plr)
	if player.Team and plr.Team then
		return player.Team ~= plr.Team
	end
	return true
end

local function createArrow(plr)
	local img = Instance.new("ImageLabel")
	img.Name = plr.Name .. "_Arrow"
	img.Size = UDim2.fromOffset(26, 26)
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://121771059734689"
	img.Visible = false
	img.ImageTransparency = 0.3
	img.Parent = OffscreenGui
	arrows[plr] = img
end

local function removeArrow(plr)
	if arrows[plr] then
		arrows[plr]:Destroy()
		arrows[plr] = nil
	end
end

Players.PlayerAdded:Connect(function(plr)
	if isEnemyForArrows(plr) then
		createArrow(plr)
	end
end)
Players.PlayerRemoving:Connect(removeArrow)

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= player and isEnemyForArrows(p) then
		createArrow(p)
	end
end

RunService.RenderStepped:Connect(function()
	if not OFFSCREEN_ENABLED then
		for _, a in pairs(arrows) do
			a.Visible = false
		end
		return
	end

	local camCF = Camera.CFrame
	local camPos = camCF.Position
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X / 2, vp.Y / 2)

	for plr, arrow in pairs(arrows) do
		if not isEnemyForArrows(plr) then
			arrow.Visible = false
			continue
		end
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if not hrp or not hum or hum.Health <= 0 then
			arrow.Visible = false
			continue
		end

		local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

		if onScreen and screenPos.Z > 0 then
			if screenPos.X > 0 and screenPos.X < vp.X and screenPos.Y > 0 and screenPos.Y < vp.Y then
				arrow.Visible = false
				continue
			end
		end

		local toPlayer = (hrp.Position - camPos).Unit
		local camRight = camCF.RightVector
		local x = toPlayer:Dot(camRight)
		local z = toPlayer:Dot(camCF.LookVector)
		local angle = math.atan2(x, z)
		local rot = math.deg(angle)

		local maxRadius = math.min(650, math.min(vp.X, vp.Y) * 0.45)
		local pos = center + Vector2.new(
			math.sin(angle),
			-math.cos(angle)
		) * maxRadius

		arrow.Position = UDim2.fromOffset(pos.X, pos.Y)
		arrow.Rotation = rot + 180
		arrow.ImageColor3 = OFFSCREEN_COLOR
		arrow.Visible = true
	end
end)

local function refreshArrows()
	for plr, arrow in pairs(arrows) do
		if not isEnemyForArrows(plr) then
			arrow:Destroy()
			arrows[plr] = nil
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and isEnemyForArrows(plr) and not arrows[plr] then
			createArrow(plr)
		end
	end
end

player:GetPropertyChangedSignal("Team"):Connect(refreshArrows)

-- ============================================
-- Kill Effects
-- ============================================
local KILLFX_ENABLED = false
local KILLFX_TYPE = "ImpactFX"
local KILLFX_COLOR = Color3.fromRGB(80, 160, 255)
local KILLFX_LIGHT_COLOR = Color3.fromRGB(120, 180, 255)
local KILLFX_CUSTOM_DURATION = 0.25
local KILLFX_LIGHT_RANGE = 15
local KILLFX_LIGHT_BRIGHTNESS = 1

local KILLIMAGE_ENABLED = false
local KILLIMAGE_COLOR = Color3.fromRGB(80, 160, 255)
local KILLIMAGE_FADE_IN = 0.08
local KILLIMAGE_HOLD = 0.1
local KILLIMAGE_FADE_OUT = 0.6
local KILLIMAGE_MAX_ALPHA = 0.45

local function getFXTemplate(name)
	return FX_ROOT:FindFirstChild(name)
end

local function recolorParticles(root, color)
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			d.Color = ColorSequence.new(color)
		end
	end
end

local function playImpactFX(position)
	local template = getFXTemplate("ImpactFX")
	if not template then 
		warn("[KillFX] ImpactFX not found")
		return 
	end

	local fx = template:Clone()
	fx.Anchored = true
	fx.CanCollide = false
	fx.CanQuery = false
	fx.CanTouch = false
	fx.Transparency = 1
	fx.CFrame = CFrame.new(position)
	fx.Parent = Workspace

	recolorParticles(fx, KILLFX_COLOR)

	for _, d in ipairs(fx:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			d.Enabled = true
		end
	end

	task.delay(0.15, function()
		if fx and fx.Parent then
			for _, d in ipairs(fx:GetDescendants()) do
				if d:IsA("ParticleEmitter") then
					d.Enabled = false
				end
			end
		end
	end)

	Debris:AddItem(fx, 2)
end

local function playCustomFX(position)
	local template = getFXTemplate("CustomFX")
	if not template then 
		warn("[KillFX] CustomFX not found")
		return 
	end

	local fx = template:Clone()
	fx.Anchored = true
	fx.CanCollide = false
	fx.CanQuery = false
	fx.CanTouch = false
	fx.Transparency = 1
	fx.CFrame = CFrame.new(position)
	fx.Parent = Workspace

	recolorParticles(fx, KILLFX_COLOR)

	local light = fx:FindFirstChild("PointLight") or fx:FindFirstChildWhichIsA("PointLight", true)
	if light then
		light.Color = KILLFX_LIGHT_COLOR
		light.Range = 0
		light.Brightness = KILLFX_LIGHT_BRIGHTNESS
		light.Enabled = true

		local tIn = TweenService:Create(light, TweenInfo.new(KILLFX_CUSTOM_DURATION * 0.5, Enum.EasingStyle.Quad), {Range = KILLFX_LIGHT_RANGE})
		local tOut = TweenService:Create(light, TweenInfo.new(KILLFX_CUSTOM_DURATION * 0.5, Enum.EasingStyle.Quad), {Range = 0})

		tIn:Play()
		tIn.Completed:Once(function()
			tOut:Play()
		end)
	end

	for _, d in ipairs(fx:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			d.Enabled = true
		end
	end

	task.delay(KILLFX_CUSTOM_DURATION, function()
		if fx and fx.Parent then
			for _, d in ipairs(fx:GetDescendants()) do
				if d:IsA("ParticleEmitter") then
					d.Enabled = false
				end
			end
		end
	end)

	Debris:AddItem(fx, 2)
end

InfEvent.OnClientEvent:Connect(function(killedPlayerName)
	if not KILLFX_ENABLED then return end

	local killedPlayer = Players:FindFirstChild(killedPlayerName)
	if not killedPlayer then return end

	local char = killedPlayer.Character
	if not char then return end

	local head = char:FindFirstChild("Head")
	if not head then return end

	local pos = head.Position

	if KILLFX_TYPE == "ImpactFX" then
		playImpactFX(pos)
	elseif KILLFX_TYPE == "CustomFX" then
		playCustomFX(pos)
	end
end)

local function createKillImageGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "NemesisKillImage"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 9999
	gui.Parent = guiParent

	local img = Instance.new("ImageLabel")
	img.Name = "Effect"
	img.Size = UDim2.fromScale(1, 1)
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.BackgroundTransparency = 1
	img.Image = "http://www.roblox.com/asset/?id=3124804643"
	img.ImageTransparency = 1
	img.ScaleType = Enum.ScaleType.Stretch
	img.ZIndex = 999
	img.Parent = gui

	return img
end

local killImage = createKillImageGui()

local function playKillImage()
	if not KILLIMAGE_ENABLED then return end
	if not killImage then return end

	killImage.ImageColor3 = KILLIMAGE_COLOR
	killImage.ImageTransparency = 1

	local tIn = TweenService:Create(
		killImage,
		TweenInfo.new(KILLIMAGE_FADE_IN, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ImageTransparency = 1 - KILLIMAGE_MAX_ALPHA }
	)

	local tOut = TweenService:Create(
		killImage,
		TweenInfo.new(KILLIMAGE_FADE_OUT, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ ImageTransparency = 1 }
	)

	tIn:Play()
	tIn.Completed:Wait()
	task.wait(KILLIMAGE_HOLD)
	tOut:Play()
end

-- ============================================
-- Backtrack Ghost
-- ============================================
local BACKTRACK_GHOST_ENABLED = false
local BACKTRACK_GHOST_COLOR = Color3.fromRGB(80, 160, 255)
local BACKTRACK_GHOST_DURATION = 0.3

local ghostModel = nil
local ghostExpireAt = 0
local sourceCharacter = nil
local lastFakeLagState = nil
local ghostLastCFrames = {}
local GHOST_SMOOTH_SPEED = 45
local ghostParts = {}

local ghostsFolder = workspace:FindFirstChild("BacktrackGhosts") or Instance.new("Folder", workspace)
ghostsFolder.Name = "BacktrackGhosts"

local function isFakeLagEnabled()
	if _G.ConfigSystem and _G.ConfigSystem.settings then
		return _G.ConfigSystem.settings["FakeLag"] == true
	end
	return false
end

local function clearMyBacktrackGhost()
	if ghostModel then
		ghostModel:Destroy()
		ghostModel = nil
		table.clear(ghostLastCFrames)
	end
	sourceCharacter = nil
end

local function createMyBacktrackGhost()
	local srcChar = player.Character
	if not srcChar then return nil end

	local root = srcChar:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	srcChar.Archivable = true
	local ghost = srcChar:Clone()
	srcChar.Archivable = false

	if not ghost then return nil end

	ghost.Name = player.Name .. "_BacktrackGhost"

	for _, v in pairs(ghost:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Sound") 
			or v:IsA("BillboardGui") or v:IsA("Humanoid")
			or v:IsA("AlignPosition") or v:IsA("AlignOrientation") 
			or v:IsA("BodyMover") or v:IsA("BodyGyro") or v:IsA("BodyVelocity")
			or v:IsA("BodyPosition") or v:IsA("BodyForce") or v:IsA("VectorForce") 
			or v:IsA("LineForce") or v:IsA("Animator") then
			v:Destroy()
		end
	end

	for _, v in pairs(ghost:GetDescendants()) do
		if v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("WeldConstraint") 
			or v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint")
			or v:IsA("Constraint") or v:IsA("JointInstance") then
			v:Destroy()
		end
	end

	local hasParts = false
	for _, v in pairs(ghost:GetDescendants()) do
		if v:IsA("BasePart") then
			hasParts = true
			v.Anchored = true
			v.CanCollide = false
			v.CanTouch = false
			v.CanQuery = false
			v.Massless = true
			v.Material = Enum.Material.ForceField
			v.Transparency = 0.7
			v.Color = BACKTRACK_GHOST_COLOR
			v.CastShadow = false

			if v.Name == "Head" then
				local face = v:FindFirstChild("face")
				if face then face:Destroy() end
			end
		end
	end

	if not hasParts then
		ghost:Destroy()
		return nil
	end

	table.clear(ghostParts)

	for _, v in ipairs(ghost:GetDescendants()) do
		if v:IsA("BasePart") then
			table.insert(ghostParts, v)
		end
	end

	ghost.Parent = ghostsFolder
	return ghost
end

local function updateMyBacktrackGhostPose(targetCFrame, isFakelag)
	if not BACKTRACK_GHOST_ENABLED then return end

	local srcChar = player.Character
	if not srcChar then return end

	local humanoid = srcChar:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health <= 0 then
		clearMyBacktrackGhost()
		return
	end

	if (not ghostModel) or (sourceCharacter ~= srcChar) or (lastFakeLagState ~= isFakelag) or (not ghostModel.Parent) then
		clearMyBacktrackGhost()
		ghostModel = createMyBacktrackGhost()
		if ghostModel then
			sourceCharacter = srcChar
			lastFakeLagState = isFakelag
		else
			return
		end
	end

	local srcRoot = srcChar:FindFirstChild("HumanoidRootPart")
	if not srcRoot then return end

	local currentRootCFrame = srcRoot.CFrame
	local offset = targetCFrame * currentRootCFrame:Inverse()

	local dt = RunService.Heartbeat:Wait()
	local alpha = math.clamp(GHOST_SMOOTH_SPEED * dt, 0, 1)

	for _, ghostPart in ipairs(ghostParts) do
		local srcPart = srcChar:FindFirstChild(ghostPart.Name, true)
		if srcPart then
			local targetCF = offset * srcPart.CFrame
			local lastCF = ghostLastCFrames[ghostPart] or ghostPart.CFrame
			local newCF = lastCF:Lerp(targetCF, alpha)

			ghostPart.CFrame = newCF
			ghostLastCFrames[ghostPart] = newCF
		end
	end

	ghostExpireAt = tick() + BACKTRACK_GHOST_DURATION
end

RunService.Heartbeat:Connect(function()
	if ghostModel and tick() > ghostExpireAt then
		clearMyBacktrackGhost()
	end
end)

local lastSend = 0
RunService.Heartbeat:Connect(function()
	if BACKTRACK_GHOST_ENABLED and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local now = tick()
			if now - lastSend > 0.05 then
				lastSend = now
				backtrackRemote:FireServer(isFakeLagEnabled())
			end
		end
	end
end)

backtrackRemote.OnClientEvent:Connect(function(cframe, isFakelag, ping)
	if not BACKTRACK_GHOST_ENABLED then return end

	if not isFakelag and ping then
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local velocity = hrp.AssemblyLinearVelocity
				local pingOffset = velocity * (ping * 0.5)
				cframe = hrp.CFrame - pingOffset
			end
		end
	end

	updateMyBacktrackGhostPose(cframe, isFakelag)
end)

player.CharacterAdded:Connect(clearMyBacktrackGhost)
player.CharacterRemoving:Connect(clearMyBacktrackGhost)

-- ============================================
-- HitLog System
-- ============================================
local HITLOG_ENABLED = false
local hitlogContainer = nil
local HITSOUND_ENABLED = true
local HITSOUND_VOLUME = 1
local HITSOUND_PRESET = "bell"

local HITSOUND_MAP = {
	correct = "HitSfx13",
	skeet = "HitSfx",
	orchestra = "HitSfx2",
	bow = "HitSfx3",
	uwu = "HitSfx4",
	tf2 = "HitSfx5",
	b8 = "HitSfx6",
	basketball = "HitSfx7",
	idk = "HitSfx8",
	orb = "HitSfx9",
	balltap = "HitSfx10",
	softbell = "HitSfx11",
	softhit = "HitSfx12",
	soft = "HitSfx14",
	bell2 = "HitSfx15",
	tank1 = "HitSfx16",
	rampage = "HitSfx18",
	headshot = "HitSfx19",
	tank2 = "HitSfx20",
	rust = "HitSfx22"
}

local function playHitSound()
	if not HITSOUND_ENABLED then return end

	if HITSOUND_PRESET == "bell" then
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://7112391013"
		s.Volume = HITSOUND_VOLUME
		s.Parent = SoundService
		s:Play()
		Debris:AddItem(s, 3)
		return
	end

	if not HITSOUND_STORAGE then return end

	local assetName = HITSOUND_MAP[HITSOUND_PRESET]
	if not assetName then return end

	local src = HITSOUND_STORAGE:FindFirstChild(assetName)
	if not src then return end

	local sound
	if src:IsA("Sound") then
		sound = src:Clone()
	else
		sound = src:FindFirstChildWhichIsA("Sound", true)
		if sound then
			sound = sound:Clone()
		end
	end

	if not sound then return end

	sound.Volume = HITSOUND_VOLUME
	sound.Parent = SoundService
	sound:Play()

	Debris:AddItem(sound, math.max(sound.TimeLength + 0.3, 2))
end

local function createHitlogUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NemesisHitlogs"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = guiParent

	local container = Instance.new("Frame")
	container.Name = "HitlogList"
	container.Active = false
	container.Selectable = false
	container.Size = UDim2.new(0, 300, 0, 200)
	container.Position = UDim2.new(0.5, -150, 0.55, 20)
	container.AnchorPoint = Vector2.new(0, 0)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Parent = screenGui

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = container

	hitlogContainer = container

	return screenGui
end

local hitlogOrder = 0

local function showHitlog(hitType, info)
	if not HITLOG_ENABLED then return end
	if not hitlogContainer then return end

	hitlogOrder = hitlogOrder + 1
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Hitlog_" .. hitlogOrder
	textLabel.Active = false
	textLabel.Selectable = false
	textLabel.Size = UDim2.new(1, 0, 0, 12)
	textLabel.BackgroundTransparency = 1
	textLabel.TextTransparency = 1
	textLabel.TextColor3 = (hitType == "Hit") and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)
	textLabel.TextSize = 11
	textLabel.Font = Enum.Font.Code
	textLabel.TextStrokeTransparency = 1
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.LayoutOrder = hitlogOrder
	textLabel.Parent = hitlogContainer

	if hitType == "Hit" and info then
		textLabel.Text = string.format("HIT | %s | %d DMG | %d studs",
			tostring(info.bodyPart or "Body"),
			math.floor(tonumber(info.damage) or 0),
			math.floor(tonumber(info.distance) or 0))
	elseif hitType == "Miss" and info then
		local reason = info.reason or "unknown"
		if reason == "hitchance_failed" then
			textLabel.Text = string.format("MISS | %d%% (%d) | %d studs",
				tonumber(info.hitchance) or 0,
				tonumber(info.roll) or 0,
				tonumber(info.distance) or 0)
		else
			textLabel.Text = "MISS"
		end
	else
		textLabel.Text = hitType == "Hit" and "HIT" or "MISS"
	end

	local tweenInfoShow = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	TweenService:Create(textLabel, tweenInfoShow, {TextTransparency = 0, TextStrokeTransparency = 0.4}):Play()

	task.spawn(function()
		task.wait(2.5)
		if not textLabel or not textLabel.Parent then return end
		local tweenInfoHide = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		local hideTween = TweenService:Create(textLabel, tweenInfoHide, {TextTransparency = 1, TextStrokeTransparency = 1})
		hideTween:Play()
		hideTween.Completed:Connect(function()
			if textLabel and textLabel.Parent then
				textLabel:Destroy()
			end
		end)
	end)
end

createHitlogUI()

task.spawn(function()
	local htl = ReplicatedStorage:WaitForChild("htl", 10)
	if not htl then return end

	htl.OnClientEvent:Connect(function(hitType, info)
		if hitType == "Hit" then
			playHitSound()
		end

		if hitType == "Hit" and info then
			if KILLIMAGE_ENABLED then
				local dmg = info.damage or 0
				if dmg > 99 then
					playKillImage()
				end
			end
		end

		if HITLOG_ENABLED then
			showHitlog(hitType, info)
		end
	end)
end)

-- ============================================
-- Indicator System
-- ============================================
local INDICATOR_ENABLED = false

local CROUCH_ANIMATIONS = {
	[102226306945117] = true,
	[124458965304788] = true
}

local currentState = "STAND"
local indicatorGui = nil
local titleLabel = nil
local stateLabel = nil
local titleGlow = nil
local stateGlow = nil

local STATE_DATA = {
	AIR = {name = "in air", color = Color3.fromRGB(255, 180, 80)},
	STAND = {name = "standing", color = Color3.fromRGB(150, 255, 150)},
	WALK = {name = "moving", color = Color3.fromRGB(130, 200, 255)},
	CROUCH = {name = "ducking", color = Color3.fromRGB(255, 100, 100)}
}

local GRADIENT_COLORS = {
	Color3.fromRGB(255, 89, 89),
	Color3.fromRGB(196, 40, 28),
	Color3.fromRGB(255, 51, 36)
}

local function createIndicatorGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NemesisIndicator"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Enabled = false
	screenGui.Parent = guiParent

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "IndicatorFrame"
	mainFrame.Size = UDim2.new(0, 120, 0, 40)
	mainFrame.Position = UDim2.new(0.5, -60, 0.58, 0)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = screenGui

	titleGlow = Instance.new("ImageLabel")
	titleGlow.Name = "TitleGlow"
	titleGlow.Size = UDim2.new(0, 120, 0, 20)
	titleGlow.Position = UDim2.new(0.5, 0, 0, 0)
	titleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	titleGlow.BackgroundTransparency = 1
	titleGlow.Image = "rbxassetid://7498352732"
	titleGlow.ImageTransparency = 0.3
	titleGlow.ScaleType = Enum.ScaleType.Stretch
	titleGlow.ZIndex = 1
	titleGlow.Parent = mainFrame

	titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 14)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "NEMESIS"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextStrokeTransparency = 0.3
	titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.ZIndex = 2
	titleLabel.Parent = mainFrame

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, GRADIENT_COLORS[1]),
		ColorSequenceKeypoint.new(0.5, GRADIENT_COLORS[2]),
		ColorSequenceKeypoint.new(1, GRADIENT_COLORS[3])
	})
	gradient.Offset = Vector2.new(0, 0)
	gradient.Parent = titleLabel

	task.spawn(function()
		local offset = 0
		while titleLabel and titleLabel.Parent do
			if INDICATOR_ENABLED then
				offset = (offset + 0.01) % 2
				gradient.Offset = Vector2.new(offset - 1, 0)
			end
			task.wait(0.03)
		end
	end)

	local glowGradient = Instance.new("UIGradient")
	glowGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, GRADIENT_COLORS[1]),
		ColorSequenceKeypoint.new(0.5, GRADIENT_COLORS[2]),
		ColorSequenceKeypoint.new(1, GRADIENT_COLORS[3])
	})
	glowGradient.Offset = Vector2.new(0, 0)
	glowGradient.Parent = titleGlow

	task.spawn(function()
		local offset = 0
		while titleGlow and titleGlow.Parent do
			if INDICATOR_ENABLED then
				offset = (offset + 0.01) % 2
				glowGradient.Offset = Vector2.new(offset - 1, 0)
			end
			task.wait(0.03)
		end
	end)

	stateGlow = Instance.new("ImageLabel")
	stateGlow.Name = "StateGlow"
	stateGlow.Size = UDim2.new(0, 100, 0, 18)
	stateGlow.Position = UDim2.new(0.5, 0, 0, 22)
	stateGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	stateGlow.BackgroundTransparency = 1
	stateGlow.Image = "rbxassetid://7498352732"
	stateGlow.ImageTransparency = 0.4
	stateGlow.ScaleType = Enum.ScaleType.Stretch
	stateGlow.ZIndex = 1
	stateGlow.Parent = mainFrame

	stateLabel = Instance.new("TextLabel")
	stateLabel.Name = "State"
	stateLabel.Size = UDim2.new(1, 0, 0, 16)
	stateLabel.Position = UDim2.new(0, 0, 0, 17)
	stateLabel.BackgroundTransparency = 1
	stateLabel.Text = "standing"
	stateLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	stateLabel.TextSize = 12
	stateLabel.Font = Enum.Font.Code
	stateLabel.TextStrokeTransparency = 0.3
	stateLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	stateLabel.TextXAlignment = Enum.TextXAlignment.Center
	stateLabel.ZIndex = 2
	stateLabel.Parent = mainFrame

	indicatorGui = screenGui

	return screenGui
end

local function isCrouching(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return false end

	for _, track in pairs(animator:GetPlayingAnimationTracks()) do
		local animId = track.Animation and track.Animation.AnimationId
		if animId then
			local id = tonumber(animId:match("%d+"))
			if id and CROUCH_ANIMATIONS[id] then
				return true
			end
		end
	end
	return false
end

local function getPlayerState(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart then
		return "STAND"
	end

	if isCrouching(character) then
		return "CROUCH"
	end

	if humanoid.FloorMaterial == Enum.Material.Air then
		return "AIR"
	end

	local velocity = rootPart.AssemblyLinearVelocity
	local horizontalSpeed = math.sqrt(velocity.X^2 + velocity.Z^2)

	if horizontalSpeed > 0.5 then
		return "WALK"
	end

	return "STAND"
end

local function updateIndicator(newState)
	if newState == currentState then return end
	currentState = newState

	local data = STATE_DATA[newState] or STATE_DATA.STAND

	if stateLabel then
		stateLabel.Text = data.name

		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		TweenService:Create(stateLabel, tweenInfo, {TextColor3 = data.color}):Play()

		if stateGlow then
			TweenService:Create(stateGlow, tweenInfo, {ImageColor3 = data.color}):Play()
		end
	end
end

RunService.RenderStepped:Connect(function()
	if not INDICATOR_ENABLED then return end

	local character = player.Character
	if character then
		local state = getPlayerState(character)
		updateIndicator(state)
	end
end)

createIndicatorGUI()

-- ============================================
-- Tracer System
-- ============================================
local TRACER_ENABLED = false
local TRACER_COLOR = Color3.fromRGB(255, 100, 220)
local TRACER_LIFETIME = 0.45
local TRACER_WIDTH = 0.12

local tracerPool = {}
local MAX_TRACER_POOL = 12
local TRACER_TAIL = 2

local function createTracer(startPos, endPos)
	if not TRACER_ENABLED then return end

	local distance = (endPos - startPos).Magnitude
	if distance < 0.5 then return end

	if WALLBANG_ENABLED then
		local direction = (endPos - startPos)
		local dirUnit = direction.Unit

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local char = player.Character
		if char then
			params.FilterDescendantsInstances = {char}
		end

		local rayForward = Workspace:Raycast(startPos, dirUnit * distance, params)

		if rayForward then
			local rayBackward = Workspace:Raycast(endPos, -dirUnit * distance, params)

			if rayBackward then
				local penetrationDepth = (rayForward.Position - rayBackward.Position).Magnitude

				if penetrationDepth > 0.5 and penetrationDepth < (distance * 0.95) then
					task.spawn(function()
						createWallbangMarker(rayForward.Position, WALLBANG_CONFIG.EntryColor)
						createWallbangMarker(rayBackward.Position, WALLBANG_CONFIG.ExitColor)
					end)
				end
			end
		end
	end

	local tracerObj = table.remove(tracerPool)
	if not tracerObj then
		local folder = Instance.new("Folder")
		folder.Name = "tracer_fx"

		local mover = Instance.new("Part")
		mover.Name = "Mover"
		mover.Anchored = true
		mover.Transparency = 1
		mover.CanCollide = false
		mover.CanQuery = false
		mover.CanTouch = false
		mover.Size = Vector3.new(0.05, 0.05, 0.05)
		mover.Parent = folder

		local a0 = Instance.new("Attachment")
		a0.Name = "A0"
		a0.Parent = mover

		local a1 = Instance.new("Attachment")
		a1.Name = "A1"
		a1.Parent = mover

		local trail = Instance.new("Trail")
		trail.Name = "Trace"
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Enabled = false
		trail.FaceCamera = true
		trail.Brightness = 20
		trail.LightEmission = 1
		trail.LightInfluence = 0.95
		trail.TextureMode = Enum.TextureMode.Stretch
		trail.Texture = "rbxassetid://93746968407218"
		trail.TextureLength = 3
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0.00, 1.00),
			NumberSequenceKeypoint.new(0.125, 0.05),
			NumberSequenceKeypoint.new(0.89, 0.0562),
			NumberSequenceKeypoint.new(1.00, 1.00),
		})
		trail.Parent = mover

		tracerObj = { folder = folder, mover = mover, a0 = a0, a1 = a1, trail = trail }
	end

	local w = math.clamp(TRACER_WIDTH, 0.02, 0.25)

	tracerObj.trail.Color = ColorSequence.new(TRACER_COLOR)
	tracerObj.trail.Lifetime = TRACER_LIFETIME
	tracerObj.trail.WidthScale = NumberSequence.new(w)

	local dir = (endPos - startPos)
	local unit = dir.Unit

	tracerObj.folder.Parent = Workspace
	tracerObj.mover.CFrame = CFrame.lookAt(startPos, startPos + unit)
	tracerObj.a0.Position = Vector3.new(0, 0, 0)
	tracerObj.a1.Position = Vector3.new(0, 0, -TRACER_TAIL)
	tracerObj.trail.Enabled = true

	local flyTime = math.clamp(distance / 2200, 0.06, 0.22)
	local tween = TweenService:Create(tracerObj.mover, TweenInfo.new(flyTime, Enum.EasingStyle.Linear), {
		CFrame = CFrame.lookAt(endPos, endPos + unit)
	})
	tween:Play()

	tween.Completed:Once(function()
		task.delay(tracerObj.trail.Lifetime + 0.05, function()
			if not tracerObj or not tracerObj.folder then return end
			tracerObj.trail.Enabled = false
			tracerObj.folder.Parent = nil
			if #tracerPool < MAX_TRACER_POOL then
				table.insert(tracerPool, tracerObj)
			else
				tracerObj.folder:Destroy()
			end
		end)
	end)
end

-- ============================================
-- Export to Shared
-- ============================================
Shared.Settings.HITLOG_ENABLED = HITLOG_ENABLED
Shared.Settings.HITSOUND_ENABLED = HITSOUND_ENABLED
Shared.Settings.HITSOUND_PRESET = HITSOUND_PRESET
Shared.Settings.HITSOUND_VOLUME = HITSOUND_VOLUME
Shared.Settings.INDICATOR_ENABLED = INDICATOR_ENABLED
Shared.Settings.OFFSCREEN_ENABLED = OFFSCREEN_ENABLED
Shared.Settings.OFFSCREEN_COLOR = OFFSCREEN_COLOR
Shared.Settings.WALLBANG_ENABLED = WALLBANG_ENABLED
Shared.Settings.WALLBANG_ENTRY_COLOR = WALLBANG_CONFIG.EntryColor
Shared.Settings.WALLBANG_EXIT_COLOR = WALLBANG_CONFIG.ExitColor
Shared.Settings.WALLBANG_MARKER_SIZE = WALLBANG_CONFIG.MarkerSize
Shared.Settings.WALLBANG_LIFETIME = WALLBANG_CONFIG.Lifetime
Shared.Settings.KILLFX_ENABLED = KILLFX_ENABLED
Shared.Settings.KILLFX_TYPE = KILLFX_TYPE
Shared.Settings.KILLFX_COLOR = KILLFX_COLOR
Shared.Settings.KILLFX_LIGHT_COLOR = KILLFX_LIGHT_COLOR
Shared.Settings.KILLFX_CUSTOM_DURATION = KILLFX_CUSTOM_DURATION
Shared.Settings.KILLFX_LIGHT_RANGE = KILLFX_LIGHT_RANGE
Shared.Settings.KILLIMAGE_ENABLED = KILLIMAGE_ENABLED
Shared.Settings.KILLIMAGE_COLOR = KILLIMAGE_COLOR
Shared.Settings.KILLIMAGE_MAX_ALPHA = KILLIMAGE_MAX_ALPHA
Shared.Settings.BACKTRACK_GHOST_ENABLED = BACKTRACK_GHOST_ENABLED
Shared.Settings.BACKTRACK_GHOST_COLOR = BACKTRACK_GHOST_COLOR
Shared.Settings.BACKTRACK_GHOST_DURATION = BACKTRACK_GHOST_DURATION
Shared.Settings.TRACER_ENABLED = TRACER_ENABLED
Shared.Settings.TRACER_COLOR = TRACER_COLOR
Shared.Settings.TRACER_LIFETIME = TRACER_LIFETIME
Shared.Settings.TRACER_WIDTH = TRACER_WIDTH

Shared.Functions.createTracer = createTracer
Shared.Functions.setHitlogEnabled = function(v) HITLOG_ENABLED = v; if hitlogContainer then hitlogContainer.Visible = v end end
Shared.Functions.setHitsoundEnabled = function(v) HITSOUND_ENABLED = v end
Shared.Functions.setHitsoundPreset = function(v) HITSOUND_PRESET = v end
Shared.Functions.setHitsoundVolume = function(v) HITSOUND_VOLUME = v end
Shared.Functions.setIndicatorEnabled = function(v) INDICATOR_ENABLED = v; if indicatorGui then indicatorGui.Enabled = v end end
Shared.Functions.setOffscreenEnabled = function(v) OFFSCREEN_ENABLED = v end
Shared.Functions.setOffscreenColor = function(v) OFFSCREEN_COLOR = v end
Shared.Functions.setWallbangEnabled = function(v) WALLBANG_ENABLED = v end
Shared.Functions.setWallbangEntryColor = function(v) WALLBANG_CONFIG.EntryColor = v end
Shared.Functions.setWallbangExitColor = function(v) WALLBANG_CONFIG.ExitColor = v end
Shared.Functions.setWallbangMarkerSize = function(v) WALLBANG_CONFIG.MarkerSize = v end
Shared.Functions.setWallbangLifetime = function(v) WALLBANG_CONFIG.Lifetime = v end
Shared.Functions.setKillFXEnabled = function(v) KILLFX_ENABLED = v end
Shared.Functions.setKillFXType = function(v) KILLFX_TYPE = v end
Shared.Functions.setKillFXColor = function(v) KILLFX_COLOR = v end
Shared.Functions.setKillFXLightColor = function(v) KILLFX_LIGHT_COLOR = v end
Shared.Functions.setKillFXDuration = function(v) KILLFX_CUSTOM_DURATION = v end
Shared.Functions.setKillFXLightRange = function(v) KILLFX_LIGHT_RANGE = v end
Shared.Functions.setKillImageEnabled = function(v) KILLIMAGE_ENABLED = v end
Shared.Functions.setKillImageColor = function(v) KILLIMAGE_COLOR = v end
Shared.Functions.setKillImageAlpha = function(v) KILLIMAGE_MAX_ALPHA = v end
Shared.Functions.setBacktrackGhostEnabled = function(v) BACKTRACK_GHOST_ENABLED = v; if not v then clearMyBacktrackGhost() end end
Shared.Functions.setBacktrackGhostColor = function(v) BACKTRACK_GHOST_COLOR = v; if ghostModel then for _, p in ipairs(ghostParts) do p.Color = v end end end
Shared.Functions.setBacktrackGhostDuration = function(v) BACKTRACK_GHOST_DURATION = v end
Shared.Functions.setTracerEnabled = function(v) TRACER_ENABLED = v end
Shared.Functions.setTracerColor = function(v) TRACER_COLOR = v end
Shared.Functions.setTracerLifetime = function(v) TRACER_LIFETIME = v end
Shared.Functions.setTracerWidth = function(v) TRACER_WIDTH = v end

print("✅ Visuals Module Loaded")
