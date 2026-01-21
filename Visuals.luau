-- VISUALS MODULE
local VisualsModule = {}
VisualsModule.__index = VisualsModule

function VisualsModule.new(config)
	local self = setmetatable({}, VisualsModule)
	
	-- Services
	self.player = config.Player
	self.guiParent = config.GuiParent
	self.Players = config.Services.Players
	self.TweenService = config.Services.TweenService
	self.RunService = config.Services.RunService
	self.ReplicatedStorage = config.Services.ReplicatedStorage
	self.Workspace = config.Services.Workspace
	self.Lighting = config.Services.Lighting
	self.Debris = config.Services.Debris
	self.SoundService = config.Services.SoundService
	self.Notification = config.Notification
	
	-- Settings
	self.HITLOG_ENABLED = false
	self.HITSOUND_ENABLED = true
	self.HITSOUND_VOLUME = 1
	self.HITSOUND_PRESET = "bell"
	self.KEYBIND_LIST_VISIBLE = true
	
	self.TRACER_ENABLED = false
	self.TRACER_COLOR = Color3.fromRGB(255, 100, 220)
	self.TRACER_LIFETIME = 0.45
	self.TRACER_WIDTH = 0.12
	
	self.WALLBANG_ENABLED = false
	self.WALLBANG_ENTRY_COLOR = Color3.fromRGB(255, 50, 50)
	self.WALLBANG_EXIT_COLOR = Color3.fromRGB(50, 255, 50)
	self.WALLBANG_MARKER_SIZE = Vector3.new(0.5, 0.5, 0.5)
	self.WALLBANG_LIFETIME = 3
	
	self.KILLFX_ENABLED = false
	self.KILLFX_TYPE = "ImpactFX"
	self.KILLFX_COLOR = Color3.fromRGB(80, 160, 255)
	self.KILLFX_LIGHT_COLOR = Color3.fromRGB(120, 180, 255)
	self.KILLFX_CUSTOM_DURATION = 0.25
	self.KILLFX_LIGHT_RANGE = 15
	self.KILLFX_LIGHT_BRIGHTNESS = 1
	
	self.OFFSCREEN_ENABLED = false
	self.OFFSCREEN_COLOR = Color3.fromRGB(255, 80, 80)
	
	self.BACKTRACK_GHOST_ENABLED = false
	self.BACKTRACK_GHOST_COLOR = Color3.fromRGB(80, 160, 255)
	self.BACKTRACK_GHOST_DURATION = 0.3
	
	self.KILLIMAGE_ENABLED = false
	self.KILLIMAGE_COLOR = Color3.fromRGB(80, 160, 255)
	self.KILLIMAGE_MAX_ALPHA = 0.45
	
	-- Internal state
	self.tracerPool = {}
	self.MAX_TRACER_POOL = 12
	self.arrows = {}
	self.hitlogContainer = nil
	self.KeybindUI = {}
	self.ghostModel = nil
	self.ghostExpireAt = 0
	self.sourceCharacter = nil
	self.ghostParts = {}
	
	self:Initialize()
	
	return self
end

function VisualsModule:Initialize()
	self.Camera = self.Workspace.CurrentCamera
	self.FX_ROOT = self.ReplicatedStorage:WaitForChild("FXTemplates")
	self.HITSOUND_STORAGE = self.guiParent:WaitForChild("ScreenGui"):WaitForChild("storage")
	
	self:CreateHitlogUI()
	self:CreateKeybindUI()
	self:CreateOffscreenArrows()
	self:CreateKillImageGUI()
	self:SetupBacktrackGhost()
	self:SetupKillFXListener()
end

-- ============================================
-- HITLOG SYSTEM
-- ============================================
function VisualsModule:CreateHitlogUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NemesisHitlogs"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = self.guiParent

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

	self.hitlogContainer = container
	self.hitlogOrder = 0
end

function VisualsModule:ShowHitlog(hitType, info)
	if not self.HITLOG_ENABLED then return end
	if not self.hitlogContainer then return end

	self.hitlogOrder = self.hitlogOrder + 1
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Hitlog_" .. self.hitlogOrder
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
	textLabel.LayoutOrder = self.hitlogOrder
	textLabel.Parent = self.hitlogContainer

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
	self.TweenService:Create(textLabel, tweenInfoShow, {TextTransparency = 0, TextStrokeTransparency = 0.4}):Play()

	task.spawn(function()
		task.wait(2.5)
		if not textLabel or not textLabel.Parent then return end
		local tweenInfoHide = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		local hideTween = self.TweenService:Create(textLabel, tweenInfoHide, {TextTransparency = 1, TextStrokeTransparency = 1})
		hideTween:Play()
		hideTween.Completed:Connect(function()
			if textLabel and textLabel.Parent then
				textLabel:Destroy()
			end
		end)
	end)
end

-- ============================================
-- HITSOUND SYSTEM
-- ============================================
function VisualsModule:PlayHitSound()
	if not self.HITSOUND_ENABLED then return end

	local HITSOUND_MAP = {
		correct = "HitSfx13", skeet = "HitSfx", orchestra = "HitSfx2", bow = "HitSfx3",
		uwu = "HitSfx4", tf2 = "HitSfx5", b8 = "HitSfx6", basketball = "HitSfx7",
		idk = "HitSfx8", orb = "HitSfx9", balltap = "HitSfx10", softbell = "HitSfx11",
		softhit = "HitSfx12", soft = "HitSfx14", bell2 = "HitSfx15", tank1 = "HitSfx16",
		rampage = "HitSfx18", headshot = "HitSfx19", tank2 = "HitSfx20", rust = "HitSfx22"
	}

	if self.HITSOUND_PRESET == "bell" then
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://7112391013"
		s.Volume = self.HITSOUND_VOLUME
		s.Parent = self.SoundService
		s:Play()
		self.Debris:AddItem(s, 3)
		return
	end

	if not self.HITSOUND_STORAGE then return end

	local assetName = HITSOUND_MAP[self.HITSOUND_PRESET]
	if not assetName then return end

	local src = self.HITSOUND_STORAGE:FindFirstChild(assetName)
	if not src then return end

	local sound
	if src:IsA("Sound") then
		sound = src:Clone()
	else
		sound = src:FindFirstChildWhichIsA("Sound", true)
		if sound then sound = sound:Clone() end
	end

	if not sound then return end

	sound.Volume = self.HITSOUND_VOLUME
	sound.Parent = self.SoundService
	sound:Play()
	self.Debris:AddItem(sound, math.max(sound.TimeLength + 0.3, 2))
end

-- ============================================
-- KEYBIND UI SYSTEM
-- ============================================
function VisualsModule:CreateKeybindUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NemesisKeybinds"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = self.guiParent

	local container = Instance.new("Frame")
	container.Name = "KeybindContainer"
	container.Size = UDim2.new(0, 220, 0, 0)
	container.Position = UDim2.new(1, -240, 0.5, -150)
	container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	container.BackgroundTransparency = 0.15
	container.BorderSizePixel = 0
	container.ClipsDescendants = true
	container.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = container

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 32)
	titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	titleBar.BackgroundTransparency = 0.3
	titleBar.BorderSizePixel = 0
	titleBar.Parent = container

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -16, 1, 0)
	titleLabel.Position = UDim2.new(0, 12, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "keybinds"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Parent = titleBar

	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "Content"
	contentContainer.Size = UDim2.new(1, 0, 1, -32)
	contentContainer.Position = UDim2.new(0, 0, 0, 32)
	contentContainer.BackgroundTransparency = 1
	contentContainer.BorderSizePixel = 0
	contentContainer.ClipsDescendants = true
	contentContainer.Parent = container

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = contentContainer

	self.KeybindUI.Container = container
	self.KeybindUI.ContentContainer = contentContainer
	self.KeybindUI.ActiveBinds = {}
	self.KeybindUI.Visible = true
end

function VisualsModule:UpdateKeybindDisplay()
	if not self.KeybindUI.ContentContainer then return end

	for _, child in ipairs(self.KeybindUI.ContentContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("^Bind_") then
			child:Destroy()
		end
	end

	local activeCount = 0
	for name, data in pairs(self.KeybindUI.ActiveBinds) do
		if data.enabled then
			activeCount = activeCount + 1
		end
	end

	local totalHeight = 32 + 16 + (activeCount * 28)
	if activeCount == 0 then totalHeight = 32 end

	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	self.TweenService:Create(self.KeybindUI.Container, tweenInfo, {Size = UDim2.new(0, 220, 0, totalHeight)}):Play()

	if self.KeybindUI.Container then
		self.KeybindUI.Container.Visible = self.KeybindUI.Visible and (activeCount > 0)
	end
end

-- ============================================
-- OFFSCREEN ARROWS
-- ============================================
function VisualsModule:CreateOffscreenArrows()
	local OffscreenGui = Instance.new("ScreenGui")
	OffscreenGui.Name = "NemesisOffscreen"
	OffscreenGui.IgnoreGuiInset = true
	OffscreenGui.ResetOnSpawn = false
	OffscreenGui.Parent = self.guiParent

	self.OffscreenGui = OffscreenGui
	
	local function isEnemy(plr)
		if self.player.Team and plr.Team then
			return self.player.Team ~= plr.Team
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
		self.arrows[plr] = img
	end

	local function removeArrow(plr)
		if self.arrows[plr] then
			self.arrows[plr]:Destroy()
			self.arrows[plr] = nil
		end
	end

	self.Players.PlayerAdded:Connect(function(plr)
		if isEnemy(plr) then
			createArrow(plr)
		end
	end)
	
	self.Players.PlayerRemoving:Connect(removeArrow)

	for _, p in ipairs(self.Players:GetPlayers()) do
		if p ~= self.player and isEnemy(p) then
			createArrow(p)
		end
	end

	self.RunService.RenderStepped:Connect(function()
		if not self.OFFSCREEN_ENABLED then
			for _, a in pairs(self.arrows) do
				a.Visible = false
			end
			return
		end

		local camCF = self.Camera.CFrame
		local camPos = camCF.Position
		local vp = self.Camera.ViewportSize
		local center = Vector2.new(vp.X / 2, vp.Y / 2)

		for plr, arrow in pairs(self.arrows) do
			if not isEnemy(plr) then
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

			local screenPos, onScreen = self.Camera:WorldToViewportPoint(hrp.Position)

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
			local pos = center + Vector2.new(math.sin(angle), -math.cos(angle)) * maxRadius

			arrow.Position = UDim2.fromOffset(pos.X, pos.Y)
			arrow.Rotation = rot + 180
			arrow.ImageColor3 = self.OFFSCREEN_COLOR
			arrow.Visible = true
		end
	end)
end

-- ============================================
-- TRACER SYSTEM
-- ============================================
function VisualsModule:CreateTracer(startPos, endPos)
	if not self.TRACER_ENABLED then return end

	local distance = (endPos - startPos).Magnitude
	if distance < 0.5 then return end

	-- Wallbang check
	if self.WALLBANG_ENABLED then
		local direction = (endPos - startPos)
		local dirUnit = direction.Unit

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local char = self.player.Character
		if char then
			params.FilterDescendantsInstances = {char}
		end

		local rayForward = self.Workspace:Raycast(startPos, dirUnit * distance, params)
		if rayForward then
			local rayBackward = self.Workspace:Raycast(endPos, -dirUnit * distance, params)
			if rayBackward then
				local penetrationDepth = (rayForward.Position - rayBackward.Position).Magnitude
				if penetrationDepth > 0.5 and penetrationDepth < (distance * 0.95) then
					task.spawn(function()
						self:CreateWallbangMarker(rayForward.Position, self.WALLBANG_ENTRY_COLOR)
						self:CreateWallbangMarker(rayBackward.Position, self.WALLBANG_EXIT_COLOR)
					end)
				end
			end
		end
	end

	local tracerObj = table.remove(self.tracerPool)
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
		trail.Parent = mover

		tracerObj = { folder = folder, mover = mover, a0 = a0, a1 = a1, trail = trail }
	end

	tracerObj.trail.Color = ColorSequence.new(self.TRACER_COLOR)
	tracerObj.trail.Lifetime = self.TRACER_LIFETIME
	tracerObj.trail.WidthScale = NumberSequence.new(math.clamp(self.TRACER_WIDTH, 0.02, 0.25))

	local dir = (endPos - startPos)
	local unit = dir.Unit

	tracerObj.folder.Parent = self.Workspace
	tracerObj.mover.CFrame = CFrame.lookAt(startPos, startPos + unit)
	tracerObj.a0.Position = Vector3.new(0, 0, 0)
	tracerObj.a1.Position = Vector3.new(0, 0, -2)
	tracerObj.trail.Enabled = true

	local flyTime = math.clamp(distance / 2200, 0.06, 0.22)
	local tween = self.TweenService:Create(tracerObj.mover, TweenInfo.new(flyTime, Enum.EasingStyle.Linear), {
		CFrame = CFrame.lookAt(endPos, endPos + unit)
	})
	tween:Play()

	tween.Completed:Once(function()
		task.delay(tracerObj.trail.Lifetime + 0.05, function()
			if not tracerObj or not tracerObj.folder then return end
			tracerObj.trail.Enabled = false
			tracerObj.folder.Parent = nil
			if #self.tracerPool < self.MAX_TRACER_POOL then
				table.insert(self.tracerPool, tracerObj)
			else
				tracerObj.folder:Destroy()
			end
		end)
	end)
end

-- ============================================
-- WALLBANG MARKERS
-- ============================================
function VisualsModule:CreateWallbangMarker(pos, color)
	local part = Instance.new("Part")
	part.Name = "WallbangMarker"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.ForceField
	part.Color = color
	part.Size = self.WALLBANG_MARKER_SIZE
	part.CFrame = CFrame.new(pos)
	part.Parent = self.Workspace

	part.Transparency = 0
	local tIn = self.TweenService:Create(part, TweenInfo.new(0.3), {Transparency = 0})
	tIn:Play()

	self.Debris:AddItem(part, self.WALLBANG_LIFETIME)

	task.delay(self.WALLBANG_LIFETIME - 0.5, function()
		if part.Parent then
			self.TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0,0,0)}):Play()
		end
	end)
end

-- ============================================
-- KILL FX SYSTEM
-- ============================================
function VisualsModule:CreateKillImageGUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "NemesisKillImage"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 9999
	gui.Parent = self.guiParent

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

	self.killImage = img
end

function VisualsModule:PlayKillImage()
	if not self.KILLIMAGE_ENABLED then return end
	if not self.killImage then return end

	self.killImage.ImageColor3 = self.KILLIMAGE_COLOR
	self.killImage.ImageTransparency = 1

	local tIn = self.TweenService:Create(
		self.killImage,
		TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ImageTransparency = 1 - self.KILLIMAGE_MAX_ALPHA }
	)

	local tOut = self.TweenService:Create(
		self.killImage,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ ImageTransparency = 1 }
	)

	tIn:Play()
	tIn.Completed:Wait()
	task.wait(0.1)
	tOut:Play()
end

function VisualsModule:SetupKillFXListener()
	local InfEvent = self.ReplicatedStorage:WaitForChild("inf", 10)
	if not InfEvent then return end

	InfEvent.OnClientEvent:Connect(function(killedPlayerName)
		if not self.KILLFX_ENABLED then return end

		local killedPlayer = self.Players:FindFirstChild(killedPlayerName)
		if not killedPlayer then return end

		local char = killedPlayer.Character
		if not char then return end

		local head = char:FindFirstChild("Head")
		if not head then return end

		local pos = head.Position

		if self.KILLFX_TYPE == "ImpactFX" then
			self:PlayImpactFX(pos)
		elseif self.KILLFX_TYPE == "CustomFX" then
			self:PlayCustomFX(pos)
		end
	end)

	task.spawn(function()
		local htl = self.ReplicatedStorage:WaitForChild("htl", 10)
		if not htl then return end

		htl.OnClientEvent:Connect(function(hitType, info)
			if hitType == "Hit" then
				self:PlayHitSound()

				if self.KILLIMAGE_ENABLED and info then
					local dmg = info.damage or 0
					if dmg > 99 then
						self:PlayKillImage()
					end
				end
			end

			if self.HITLOG_ENABLED then
				self:ShowHitlog(hitType, info)
			end
		end)
	end)
end

function VisualsModule:PlayImpactFX(position)
	local template = self.FX_ROOT:FindFirstChild("ImpactFX")
	if not template then return end

	local fx = template:Clone()
	fx.Anchored = true
	fx.CanCollide = false
	fx.CanQuery = false
	fx.CanTouch = false
	fx.Transparency = 1
	fx.CFrame = CFrame.new(position)
	fx.Parent = self.Workspace

	for _, d in ipairs(fx:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			d.Color = ColorSequence.new(self.KILLFX_COLOR)
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

	self.Debris:AddItem(fx, 2)
end

function VisualsModule:PlayCustomFX(position)
	local template = self.FX_ROOT:FindFirstChild("CustomFX")
	if not template then return end

	local fx = template:Clone()
	fx.Anchored = true
	fx.CanCollide = false
	fx.CanQuery = false
	fx.CanTouch = false
	fx.Transparency = 1
	fx.CFrame = CFrame.new(position)
	fx.Parent = self.Workspace

	for _, d in ipairs(fx:GetDescendants()) do
		if d:IsA("ParticleEmitter") then
			d.Color = ColorSequence.new(self.KILLFX_COLOR)
			d.Enabled = true
		end
	end

	local light = fx:FindFirstChild("PointLight") or fx:FindFirstChildWhichIsA("PointLight", true)
	if light then
		light.Color = self.KILLFX_LIGHT_COLOR
		light.Range = 0
		light.Brightness = self.KILLFX_LIGHT_BRIGHTNESS
		light.Enabled = true

		local tIn = self.TweenService:Create(light, TweenInfo.new(self.KILLFX_CUSTOM_DURATION * 0.5, Enum.EasingStyle.Quad), {Range = self.KILLFX_LIGHT_RANGE})
		local tOut = self.TweenService:Create(light, TweenInfo.new(self.KILLFX_CUSTOM_DURATION * 0.5, Enum.EasingStyle.Quad), {Range = 0})

		tIn:Play()
		tIn.Completed:Once(function()
			tOut:Play()
		end)
	end

	task.delay(self.KILLFX_CUSTOM_DURATION, function()
		if fx and fx.Parent then
			for _, d in ipairs(fx:GetDescendants()) do
				if d:IsA("ParticleEmitter") then
					d.Enabled = false
				end
			end
		end
	end)

	self.Debris:AddItem(fx, 2)
end

-- ============================================
-- BACKTRACK GHOST
-- ============================================
function VisualsModule:SetupBacktrackGhost()
	local backtrackRemote = self.ReplicatedStorage:WaitForChild("btl")
	local lastSend = 0

	self.RunService.Heartbeat:Connect(function()
		if self.BACKTRACK_GHOST_ENABLED and self.player.Character then
			local hrp = self.player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local now = tick()
				if now - lastSend > 0.05 then
					lastSend = now
					backtrackRemote:FireServer(false)
				end
			end
		end
	end)

	backtrackRemote.OnClientEvent:Connect(function(cframe, isFakelag, ping)
		if not self.BACKTRACK_GHOST_ENABLED then return end
		self:UpdateBacktrackGhostPose(cframe, isFakelag)
	end)

	self.player.CharacterAdded:Connect(function()
		self:ClearBacktrackGhost()
	end)

	self.player.CharacterRemoving:Connect(function()
		self:ClearBacktrackGhost()
	end)

	self.RunService.Heartbeat:Connect(function()
		if self.ghostModel and tick() > self.ghostExpireAt then
			self:ClearBacktrackGhost()
		end
	end)
end

function VisualsModule:ClearBacktrackGhost()
	if self.ghostModel then
		self.ghostModel:Destroy()
		self.ghostModel = nil
		table.clear(self.ghostParts)
	end
	self.sourceCharacter = nil
end

function VisualsModule:UpdateBacktrackGhostPose(targetCFrame, isFakelag)
	if not self.BACKTRACK_GHOST_ENABLED then return end

	local srcChar = self.player.Character
	if not srcChar then return end

	local humanoid = srcChar:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health <= 0 then
		self:ClearBacktrackGhost()
		return
	end

	if not self.ghostModel or self.sourceCharacter ~= srcChar then
		self:ClearBacktrackGhost()
		self.ghostModel = self:CreateBacktrackGhost()
		if self.ghostModel then
			self.sourceCharacter = srcChar
		else
			return
		end
	end

	local srcRoot = srcChar:FindFirstChild("HumanoidRootPart")
	if not srcRoot then return end

	local currentRootCFrame = srcRoot.CFrame
	local offset = targetCFrame * currentRootCFrame:Inverse()

	for _, ghostPart in ipairs(self.ghostParts) do
		local srcPart = srcChar:FindFirstChild(ghostPart.Name, true)
		if srcPart then
			ghostPart.CFrame = offset * srcPart.CFrame
		end
	end

	self.ghostExpireAt = tick() + self.BACKTRACK_GHOST_DURATION
end

function VisualsModule:CreateBacktrackGhost()
	local srcChar = self.player.Character
	if not srcChar then return nil end

	local root = srcChar:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	srcChar.Archivable = true
	local ghost = srcChar:Clone()
	srcChar.Archivable = false

	if not ghost then return nil end

	ghost.Name = self.player.Name .. "_BacktrackGhost"

	for _, v in pairs(ghost:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Sound") 
			or v:IsA("BillboardGui") or v:IsA("Humanoid")
			or v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("Constraint") then
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
			v.Color = self.BACKTRACK_GHOST_COLOR
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

	table.clear(self.ghostParts)
	for _, v in ipairs(ghost:GetDescendants()) do
		if v:IsA("BasePart") then
			table.insert(self.ghostParts, v)
		end
	end

	local ghostsFolder = self.Workspace:FindFirstChild("BacktrackGhosts") or Instance.new("Folder", self.Workspace)
	ghostsFolder.Name = "BacktrackGhosts"
	ghost.Parent = ghostsFolder
	
	return ghost
end

-- ============================================
-- SETTERS
-- ============================================
function VisualsModule:SetHitlogEnabled(value)
	self.HITLOG_ENABLED = value
	if self.hitlogContainer then
		self.hitlogContainer.Visible = value
	end
end

function VisualsModule:SetHitSoundEnabled(value)
	self.HITSOUND_ENABLED = value
end

function VisualsModule:SetHitSoundPreset(value)
	self.HITSOUND_PRESET = value
end

function VisualsModule:SetHitSoundVolume(value)
	self.HITSOUND_VOLUME = value
end

function VisualsModule:SetKeybindListVisible(value)
	self.KeybindUI.Visible = value
	if self.KeybindUI.Container then
		self.KeybindUI.Container.Visible = value
	end
end

function VisualsModule:SetTracerEnabled(value)
	self.TRACER_ENABLED = value
end

function VisualsModule:SetTracerColor(value)
	self.TRACER_COLOR = value
end

function VisualsModule:SetTracerLifetime(value)
	self.TRACER_LIFETIME = value
end

function VisualsModule:SetTracerWidth(value)
	self.TRACER_WIDTH = value
end

function VisualsModule:SetWallbangEnabled(value)
	self.WALLBANG_ENABLED = value
end

function VisualsModule:SetWallbangEntryColor(value)
	self.WALLBANG_ENTRY_COLOR = value
end

function VisualsModule:SetWallbangExitColor(value)
	self.WALLBANG_EXIT_COLOR = value
end

function VisualsModule:SetKillFXEnabled(value)
	self.KILLFX_ENABLED = value
end

function VisualsModule:SetKillFXType(value)
	self.KILLFX_TYPE = value
end

function VisualsModule:SetKillFXColor(value)
	self.KILLFX_COLOR = value
end

function VisualsModule:SetKillFXLightColor(value)
	self.KILLFX_LIGHT_COLOR = value
end

function VisualsModule:SetKillFXDuration(value)
	self.KILLFX_CUSTOM_DURATION = value
end

function VisualsModule:SetKillFXLightRange(value)
	self.KILLFX_LIGHT_RANGE = value
end

function VisualsModule:SetOffscreenEnabled(value)
	self.OFFSCREEN_ENABLED = value
end

function VisualsModule:SetOffscreenColor(value)
	self.OFFSCREEN_COLOR = value
end

function VisualsModule:SetBacktrackGhostEnabled(value)
	self.BACKTRACK_GHOST_ENABLED = value
	if not value then
		self:ClearBacktrackGhost()
	end
end

function VisualsModule:SetBacktrackGhostColor(value)
	self.BACKTRACK_GHOST_COLOR = value
	if self.ghostModel then
		for _, p in ipairs(self.ghostParts) do
			p.Color = value
		end
	end
end

function VisualsModule:SetBacktrackGhostDuration(value)
	self.BACKTRACK_GHOST_DURATION = value
end

-- ============================================
-- CONFIG FUNCTIONS
-- ============================================
function VisualsModule:GetSettings()
	local function colorToTable(c)
		return {math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)}
	end

	return {
		HITLOG_ENABLED = self.HITLOG_ENABLED,
		HITSOUND_ENABLED = self.HITSOUND_ENABLED,
		HITSOUND_PRESET = self.HITSOUND_PRESET,
		HITSOUND_VOLUME = self.HITSOUND_VOLUME,
		KEYBIND_LIST_VISIBLE = self.KeybindUI.Visible,
		TRACER_ENABLED = self.TRACER_ENABLED,
		TRACER_COLOR = colorToTable(self.TRACER_COLOR),
		TRACER_LIFETIME = self.TRACER_LIFETIME,
		TRACER_WIDTH = self.TRACER_WIDTH,
		WALLBANG_ENABLED = self.WALLBANG_ENABLED,
		WALLBANG_ENTRY_COLOR = colorToTable(self.WALLBANG_ENTRY_COLOR),
		WALLBANG_EXIT_COLOR = colorToTable(self.WALLBANG_EXIT_COLOR),
		KILLFX_ENABLED = self.KILLFX_ENABLED,
		KILLFX_TYPE = self.KILLFX_TYPE,
		KILLFX_COLOR = colorToTable(self.KILLFX_COLOR),
		KILLFX_LIGHT_COLOR = colorToTable(self.KILLFX_LIGHT_COLOR),
		KILLFX_CUSTOM_DURATION = self.KILLFX_CUSTOM_DURATION,
		KILLFX_LIGHT_RANGE = self.KILLFX_LIGHT_RANGE,
		OFFSCREEN_ENABLED = self.OFFSCREEN_ENABLED,
		OFFSCREEN_COLOR = colorToTable(self.OFFSCREEN_COLOR),
		BACKTRACK_GHOST_ENABLED = self.BACKTRACK_GHOST_ENABLED,
		BACKTRACK_GHOST_COLOR = colorToTable(self.BACKTRACK_GHOST_COLOR),
		BACKTRACK_GHOST_DURATION = self.BACKTRACK_GHOST_DURATION,
		KILLIMAGE_ENABLED = self.KILLIMAGE_ENABLED,
		KILLIMAGE_COLOR = colorToTable(self.KILLIMAGE_COLOR),
		KILLIMAGE_MAX_ALPHA = self.KILLIMAGE_MAX_ALPHA,
	}
end

function VisualsModule:ApplySettings(settings)
	if not settings then return end

	local function toColor3(arr)
		if type(arr) == "table" and #arr >= 3 then
			return Color3.fromRGB(arr[1], arr[2], arr[3])
		end
		return nil
	end

	if settings.HITLOG_ENABLED ~= nil then self:SetHitlogEnabled(settings.HITLOG_ENABLED) end
	if settings.HITSOUND_ENABLED ~= nil then self:SetHitSoundEnabled(settings.HITSOUND_ENABLED) end
	if settings.HITSOUND_PRESET ~= nil then self:SetHitSoundPreset(settings.HITSOUND_PRESET) end
	if settings.HITSOUND_VOLUME ~= nil then self:SetHitSoundVolume(settings.HITSOUND_VOLUME) end
	if settings.KEYBIND_LIST_VISIBLE ~= nil then self:SetKeybindListVisible(settings.KEYBIND_LIST_VISIBLE) end
	if settings.TRACER_ENABLED ~= nil then self:SetTracerEnabled(settings.TRACER_ENABLED) end
	if settings.TRACER_COLOR then self:SetTracerColor(toColor3(settings.TRACER_COLOR) or self.TRACER_COLOR) end
	if settings.TRACER_LIFETIME ~= nil then self:SetTracerLifetime(settings.TRACER_LIFETIME) end
	if settings.TRACER_WIDTH ~= nil then self:SetTracerWidth(settings.TRACER_WIDTH) end
	if settings.WALLBANG_ENABLED ~= nil then self:SetWallbangEnabled(settings.WALLBANG_ENABLED) end
	if settings.WALLBANG_ENTRY_COLOR then self:SetWallbangEntryColor(toColor3(settings.WALLBANG_ENTRY_COLOR) or self.WALLBANG_ENTRY_COLOR) end
	if settings.WALLBANG_EXIT_COLOR then self:SetWallbangExitColor(toColor3(settings.WALLBANG_EXIT_COLOR) or self.WALLBANG_EXIT_COLOR) end
	if settings.KILLFX_ENABLED ~= nil then self:SetKillFXEnabled(settings.KILLFX_ENABLED) end
	if settings.KILLFX_TYPE ~= nil then self:SetKillFXType(settings.KILLFX_TYPE) end
	if settings.KILLFX_COLOR then self:SetKillFXColor(toColor3(settings.KILLFX_COLOR) or self.KILLFX_COLOR) end
	if settings.KILLFX_LIGHT_COLOR then self:SetKillFXLightColor(toColor3(settings.KILLFX_LIGHT_COLOR) or self.KILLFX_LIGHT_COLOR) end
	if settings.KILLFX_CUSTOM_DURATION ~= nil then self:SetKillFXDuration(settings.KILLFX_CUSTOM_DURATION) end
	if settings.KILLFX_LIGHT_RANGE ~= nil then self:SetKillFXLightRange(settings.KILLFX_LIGHT_RANGE) end
	if settings.OFFSCREEN_ENABLED ~= nil then self:SetOffscreenEnabled(settings.OFFSCREEN_ENABLED) end
	if settings.OFFSCREEN_COLOR then self:SetOffscreenColor(toColor3(settings.OFFSCREEN_COLOR) or self.OFFSCREEN_COLOR) end
	if settings.BACKTRACK_GHOST_ENABLED ~= nil then self:SetBacktrackGhostEnabled(settings.BACKTRACK_GHOST_ENABLED) end
	if settings.BACKTRACK_GHOST_COLOR then self:SetBacktrackGhostColor(toColor3(settings.BACKTRACK_GHOST_COLOR) or self.BACKTRACK_GHOST_COLOR) end
	if settings.BACKTRACK_GHOST_DURATION ~= nil then self:SetBacktrackGhostDuration(settings.BACKTRACK_GHOST_DURATION) end
	if settings.KILLIMAGE_ENABLED ~= nil then self.KILLIMAGE_ENABLED = settings.KILLIMAGE_ENABLED end
	if settings.KILLIMAGE_COLOR then self.KILLIMAGE_COLOR = toColor3(settings.KILLIMAGE_COLOR) or self.KILLIMAGE_COLOR end
	if settings.KILLIMAGE_MAX_ALPHA ~= nil then self.KILLIMAGE_MAX_ALPHA = settings.KILLIMAGE_MAX_ALPHA end
end

function VisualsModule:Start()
	-- Module is ready
end

return VisualsModule
