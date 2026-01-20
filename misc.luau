-- ============================================
-- Misc Module
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ============================================
-- Shared Module Reference
-- ============================================
local Shared = _G.NemesisShared or {}
if not _G.NemesisShared then
	_G.NemesisShared = Shared
end

Shared.Settings = Shared.Settings or {}
Shared.Functions = Shared.Functions or {}

-- ============================================
-- FakeLag System
-- ============================================
local FAKELAG_ENABLED = false
local FAKELAG_AMOUNT = 100 -- ms
local FAKELAG_VARIANCE = 20 -- ms

local fakeLagRemote = ReplicatedStorage:WaitForChild("fll")
local lastFakeLagSend = 0

local function applyFakeLag()
	if not FAKELAG_ENABLED then return end
	
	local char = player.Character
	if not char then return end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local now = tick()
	local variance = math.random(-FAKELAG_VARIANCE, FAKELAG_VARIANCE)
	local delay = (FAKELAG_AMOUNT + variance) / 1000
	
	if now - lastFakeLagSend >= delay then
		lastFakeLagSend = now
		
		pcall(function()
			fakeLagRemote:FireServer(hrp.CFrame, true)
		end)
	end
end

RunService.Heartbeat:Connect(function()
	if FAKELAG_ENABLED then
		applyFakeLag()
	end
end)

-- ============================================
-- Custom Crosshair System
-- ============================================
local CROSSHAIR_ENABLED = false
local CROSSHAIR_SIZE = 10
local CROSSHAIR_THICKNESS = 2
local CROSSHAIR_GAP = 5
local CROSSHAIR_COLOR = Color3.fromRGB(255, 255, 255)
local CROSSHAIR_TRANSPARENCY = 0
local CROSSHAIR_OUTLINE = true
local CROSSHAIR_OUTLINE_COLOR = Color3.fromRGB(0, 0, 0)
local CROSSHAIR_DYNAMIC = false
local CROSSHAIR_DYNAMIC_SCALE = 1.5

local crosshairGui = nil
local crosshairLines = {}

local function createCrosshair()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NemesisCrosshair"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999
	screenGui.Enabled = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	local center = Instance.new("Frame")
	center.Name = "Center"
	center.Size = UDim2.fromOffset(1, 1)
	center.Position = UDim2.fromScale(0.5, 0.5)
	center.AnchorPoint = Vector2.new(0.5, 0.5)
	center.BackgroundTransparency = 1
	center.BorderSizePixel = 0
	center.Parent = screenGui
	
	-- Top line
	local top = Instance.new("Frame")
	top.Name = "Top"
	top.Size = UDim2.fromOffset(CROSSHAIR_THICKNESS, CROSSHAIR_SIZE)
	top.Position = UDim2.new(0.5, 0, 0.5, -(CROSSHAIR_GAP + CROSSHAIR_SIZE))
	top.AnchorPoint = Vector2.new(0.5, 0)
	top.BackgroundColor3 = CROSSHAIR_COLOR
	top.BackgroundTransparency = CROSSHAIR_TRANSPARENCY
	top.BorderSizePixel = 0
	top.ZIndex = 10
	top.Parent = center
	
	if CROSSHAIR_OUTLINE then
		local outline = Instance.new("UIStroke")
		outline.Color = CROSSHAIR_OUTLINE_COLOR
		outline.Thickness = 1
		outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outline.Parent = top
	end
	
	-- Bottom line
	local bottom = Instance.new("Frame")
	bottom.Name = "Bottom"
	bottom.Size = UDim2.fromOffset(CROSSHAIR_THICKNESS, CROSSHAIR_SIZE)
	bottom.Position = UDim2.new(0.5, 0, 0.5, CROSSHAIR_GAP)
	bottom.AnchorPoint = Vector2.new(0.5, 0)
	bottom.BackgroundColor3 = CROSSHAIR_COLOR
	bottom.BackgroundTransparency = CROSSHAIR_TRANSPARENCY
	bottom.BorderSizePixel = 0
	bottom.ZIndex = 10
	bottom.Parent = center
	
	if CROSSHAIR_OUTLINE then
		local outline = Instance.new("UIStroke")
		outline.Color = CROSSHAIR_OUTLINE_COLOR
		outline.Thickness = 1
		outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outline.Parent = bottom
	end
	
	-- Left line
	local left = Instance.new("Frame")
	left.Name = "Left"
	left.Size = UDim2.fromOffset(CROSSHAIR_SIZE, CROSSHAIR_THICKNESS)
	left.Position = UDim2.new(0.5, -(CROSSHAIR_GAP + CROSSHAIR_SIZE), 0.5, 0)
	left.AnchorPoint = Vector2.new(0, 0.5)
	left.BackgroundColor3 = CROSSHAIR_COLOR
	left.BackgroundTransparency = CROSSHAIR_TRANSPARENCY
	left.BorderSizePixel = 0
	left.ZIndex = 10
	left.Parent = center
	
	if CROSSHAIR_OUTLINE then
		local outline = Instance.new("UIStroke")
		outline.Color = CROSSHAIR_OUTLINE_COLOR
		outline.Thickness = 1
		outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outline.Parent = left
	end
	
	-- Right line
	local right = Instance.new("Frame")
	right.Name = "Right"
	right.Size = UDim2.fromOffset(CROSSHAIR_SIZE, CROSSHAIR_THICKNESS)
	right.Position = UDim2.new(0.5, CROSSHAIR_GAP, 0.5, 0)
	right.AnchorPoint = Vector2.new(0, 0.5)
	right.BackgroundColor3 = CROSSHAIR_COLOR
	right.BackgroundTransparency = CROSSHAIR_TRANSPARENCY
	right.BorderSizePixel = 0
	right.ZIndex = 10
	right.Parent = center
	
	if CROSSHAIR_OUTLINE then
		local outline = Instance.new("UIStroke")
		outline.Color = CROSSHAIR_OUTLINE_COLOR
		outline.Thickness = 1
		outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outline.Parent = right
	end
	
	crosshairLines = {top, bottom, left, right}
	crosshairGui = screenGui
	
	return screenGui
end

local function updateCrosshairVisuals()
	if not crosshairLines or #crosshairLines == 0 then return end
	
	for _, line in ipairs(crosshairLines) do
		line.BackgroundColor3 = CROSSHAIR_COLOR
		line.BackgroundTransparency = CROSSHAIR_TRANSPARENCY
		
		local outline = line:FindFirstChildOfClass("UIStroke")
		if CROSSHAIR_OUTLINE then
			if not outline then
				outline = Instance.new("UIStroke")
				outline.Color = CROSSHAIR_OUTLINE_COLOR
				outline.Thickness = 1
				outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				outline.Parent = line
			else
				outline.Color = CROSSHAIR_OUTLINE_COLOR
			end
		else
			if outline then
				outline:Destroy()
			end
		end
	end
	
	if crosshairLines[1] and crosshairLines[2] then -- Top, Bottom
		crosshairLines[1].Size = UDim2.fromOffset(CROSSHAIR_THICKNESS, CROSSHAIR_SIZE)
		crosshairLines[1].Position = UDim2.new(0.5, 0, 0.5, -(CROSSHAIR_GAP + CROSSHAIR_SIZE))
		
		crosshairLines[2].Size = UDim2.fromOffset(CROSSHAIR_THICKNESS, CROSSHAIR_SIZE)
		crosshairLines[2].Position = UDim2.new(0.5, 0, 0.5, CROSSHAIR_GAP)
	end
	
	if crosshairLines[3] and crosshairLines[4] then -- Left, Right
		crosshairLines[3].Size = UDim2.fromOffset(CROSSHAIR_SIZE, CROSSHAIR_THICKNESS)
		crosshairLines[3].Position = UDim2.new(0.5, -(CROSSHAIR_GAP + CROSSHAIR_SIZE), 0.5, 0)
		
		crosshairLines[4].Size = UDim2.fromOffset(CROSSHAIR_SIZE, CROSSHAIR_THICKNESS)
		crosshairLines[4].Position = UDim2.new(0.5, CROSSHAIR_GAP, 0.5, 0)
	end
end

local function updateDynamicCrosshair()
	if not CROSSHAIR_ENABLED or not CROSSHAIR_DYNAMIC then return end
	if not crosshairLines or #crosshairLines == 0 then return end
	
	local char = player.Character
	if not char then return end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local velocity = hrp.AssemblyLinearVelocity
	local speed = Vector2.new(velocity.X, velocity.Z).Magnitude
	
	local scale = 1 + (speed / 50) * CROSSHAIR_DYNAMIC_SCALE
	scale = math.clamp(scale, 1, 3)
	
	local dynamicGap = CROSSHAIR_GAP * scale
	local dynamicSize = CROSSHAIR_SIZE * scale
	
	if crosshairLines[1] and crosshairLines[2] then
		crosshairLines[1].Size = UDim2.fromOffset(CROSSHAIR_THICKNESS, dynamicSize)
		crosshairLines[1].Position = UDim2.new(0.5, 0, 0.5, -(dynamicGap + dynamicSize))
		
		crosshairLines[2].Size = UDim2.fromOffset(CROSSHAIR_THICKNESS, dynamicSize)
		crosshairLines[2].Position = UDim2.new(0.5, 0, 0.5, dynamicGap)
	end
	
	if crosshairLines[3] and crosshairLines[4] then
		crosshairLines[3].Size = UDim2.fromOffset(dynamicSize, CROSSHAIR_THICKNESS)
		crosshairLines[3].Position = UDim2.new(0.5, -(dynamicGap + dynamicSize), 0.5, 0)
		
		crosshairLines[4].Size = UDim2.fromOffset(dynamicSize, CROSSHAIR_THICKNESS)
		crosshairLines[4].Position = UDim2.new(0.5, dynamicGap, 0.5, 0)
	end
end

createCrosshair()

RunService.RenderStepped:Connect(function()
	if CROSSHAIR_DYNAMIC then
		updateDynamicCrosshair()
	end
end)

-- ============================================
-- Velocity Display
-- ============================================
local VELOCITY_ENABLED = false
local velocityLabel = nil

local function createVelocityDisplay()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NemesisVelocity"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.Enabled = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	local label = Instance.new("TextLabel")
	label.Name = "VelocityLabel"
	label.Size = UDim2.fromOffset(120, 30)
	label.Position = UDim2.new(0.5, -60, 0.65, 0)
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.BackgroundTransparency = 1
	label.Text = "0 u/s"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 16
	label.Font = Enum.Font.Code
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Parent = screenGui
	
	velocityLabel = label
	return screenGui
end

createVelocityDisplay()

RunService.RenderStepped:Connect(function()
	if not VELOCITY_ENABLED or not velocityLabel then return end
	
	local char = player.Character
	if not char then return end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local velocity = hrp.AssemblyLinearVelocity
	local speed = math.floor(Vector2.new(velocity.X, velocity.Z).Magnitude)
	
	velocityLabel.Text = speed .. " u/s"
end)

-- ============================================
-- FOV Changer
-- ============================================
local FOV_ENABLED = false
local CUSTOM_FOV = 70

local camera = workspace.CurrentCamera

local function updateFOV()
	if FOV_ENABLED then
		camera.FieldOfView = CUSTOM_FOV
	else
		camera.FieldOfView = 70
	end
end

RunService.RenderStepped:Connect(function()
	if FOV_ENABLED then
		updateFOV()
	end
end)

-- ============================================
-- Export to Shared
-- ============================================
Shared.Settings.FAKELAG_ENABLED = FAKELAG_ENABLED
Shared.Settings.FAKELAG_AMOUNT = FAKELAG_AMOUNT
Shared.Settings.FAKELAG_VARIANCE = FAKELAG_VARIANCE
Shared.Settings.CROSSHAIR_ENABLED = CROSSHAIR_ENABLED
Shared.Settings.CROSSHAIR_SIZE = CROSSHAIR_SIZE
Shared.Settings.CROSSHAIR_THICKNESS = CROSSHAIR_THICKNESS
Shared.Settings.CROSSHAIR_GAP = CROSSHAIR_GAP
Shared.Settings.CROSSHAIR_COLOR = CROSSHAIR_COLOR
Shared.Settings.CROSSHAIR_TRANSPARENCY = CROSSHAIR_TRANSPARENCY
Shared.Settings.CROSSHAIR_OUTLINE = CROSSHAIR_OUTLINE
Shared.Settings.CROSSHAIR_OUTLINE_COLOR = CROSSHAIR_OUTLINE_COLOR
Shared.Settings.CROSSHAIR_DYNAMIC = CROSSHAIR_DYNAMIC
Shared.Settings.CROSSHAIR_DYNAMIC_SCALE = CROSSHAIR_DYNAMIC_SCALE
Shared.Settings.VELOCITY_ENABLED = VELOCITY_ENABLED
Shared.Settings.FOV_ENABLED = FOV_ENABLED
Shared.Settings.CUSTOM_FOV = CUSTOM_FOV

Shared.Functions.setFakeLagEnabled = function(v) FAKELAG_ENABLED = v; if _G.ConfigSystem then _G.ConfigSystem.settings["FakeLag"] = v end end
Shared.Functions.setFakeLagAmount = function(v) FAKELAG_AMOUNT = v end
Shared.Functions.setFakeLagVariance = function(v) FAKELAG_VARIANCE = v end
Shared.Functions.setCrosshairEnabled = function(v) CROSSHAIR_ENABLED = v; if crosshairGui then crosshairGui.Enabled = v end end
Shared.Functions.setCrosshairSize = function(v) CROSSHAIR_SIZE = v; updateCrosshairVisuals() end
Shared.Functions.setCrosshairThickness = function(v) CROSSHAIR_THICKNESS = v; updateCrosshairVisuals() end
Shared.Functions.setCrosshairGap = function(v) CROSSHAIR_GAP = v; updateCrosshairVisuals() end
Shared.Functions.setCrosshairColor = function(v) CROSSHAIR_COLOR = v; updateCrosshairVisuals() end
Shared.Functions.setCrosshairTransparency = function(v) CROSSHAIR_TRANSPARENCY = v; updateCrosshairVisuals() end
Shared.Functions.setCrosshairOutline = function(v) CROSSHAIR_OUTLINE = v; updateCrosshairVisuals() end
Shared.Functions.setCrosshairOutlineColor = function(v) CROSSHAIR_OUTLINE_COLOR = v; updateCrosshairVisuals() end
Shared.Functions.setCrosshairDynamic = function(v) CROSSHAIR_DYNAMIC = v end
Shared.Functions.setCrosshairDynamicScale = function(v) CROSSHAIR_DYNAMIC_SCALE = v end
Shared.Functions.setVelocityEnabled = function(v) VELOCITY_ENABLED = v; if velocityLabel and velocityLabel.Parent then velocityLabel.Parent.Enabled = v end end
Shared.Functions.setFOVEnabled = function(v) FOV_ENABLED = v; updateFOV() end
Shared.Functions.setCustomFOV = function(v) CUSTOM_FOV = v; updateFOV() end

print("✅ Misc Module Loaded")
