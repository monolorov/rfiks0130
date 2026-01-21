-- NEMESIS
local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/Monolorov/FatalInterface/main/src.luau"))()
local Notification = Fatality:CreateNotifier()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- ============================================
-- Load modules
-- ============================================
print("[NEMESIS] Loading Visuals module...")
local VisualsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/monolorov/rfiks0130/refs/heads/main/Visuals.luau"))()
print("[NEMESIS] Visuals loaded")

print("[NEMESIS] Loading World module...")
local WorldModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/monolorov/rfiks0130/refs/heads/main/World.luau"))()
print("[NEMESIS] World loaded")

print("[NEMESIS] Loading Rage module...")
local RageModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/monolorov/rfiks0130/refs/heads/main/Rage.luau"))()
print("[NEMESIS] Rage loaded")

-- ============================================
-- Loader
-- ============================================
Fatality:Loader({
	Name = "NEMESIS",
	Duration = 3
})
task.wait(3)
Notification:Notify({
	Title = "NEMESIS",
	Content = "Hello, "..player.DisplayName..' Welcome back!',
	Icon = "clipboard",
	Duration = 5
})

-- ============================================
-- WATERMARK SYSTEM
-- ============================================
local WatermarkEnabled = true
local startTime = tick()
local Stats = game:GetService("Stats")

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "NemesisWatermark"
WatermarkGui.ResetOnSpawn = false
WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.Parent = guiParent

local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "WatermarkFrame"
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
WatermarkFrame.BackgroundTransparency = 0
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.AnchorPoint = Vector2.new(1, 0)
WatermarkFrame.Position = UDim2.new(1, -10, 0, 50)
WatermarkFrame.Size = UDim2.new(0, 350, 0, 32)
WatermarkFrame.Parent = WatermarkGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = WatermarkFrame

local TextContainer = Instance.new("Frame")
TextContainer.Name = "TextContainer"
TextContainer.BackgroundTransparency = 1
TextContainer.Size = UDim2.new(1, -16, 1, 0)
TextContainer.Position = UDim2.new(0, 12, 0, 0)
TextContainer.ZIndex = 2
TextContainer.Parent = WatermarkFrame

local NemesisLabel = Instance.new("TextLabel")
NemesisLabel.Name = "NemesisText"
NemesisLabel.BackgroundTransparency = 1
NemesisLabel.Size = UDim2.new(0, 100, 1, 0)
NemesisLabel.Position = UDim2.new(0, 0, 0, 0)
NemesisLabel.Font = Enum.Font.GothamBold
NemesisLabel.Text = "NEMESIS"
NemesisLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NemesisLabel.TextSize = 14
NemesisLabel.TextXAlignment = Enum.TextXAlignment.Left
NemesisLabel.TextYAlignment = Enum.TextYAlignment.Center
NemesisLabel.TextStrokeTransparency = 1
NemesisLabel.ZIndex = 3
NemesisLabel.Parent = TextContainer

local NemesisGradient = Instance.new("UIGradient")
NemesisGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 46, 46)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(194, 21, 21)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 40, 40))
})
NemesisGradient.Rotation = 0
NemesisGradient.Parent = NemesisLabel

local NemesisGlow = Instance.new("ImageLabel")
NemesisGlow.Name = "GlowEffect"
NemesisGlow.BackgroundTransparency = 1
NemesisGlow.Image = "rbxassetid://11509756389"
NemesisGlow.ImageColor3 = Color3.fromRGB(255, 46, 46)
NemesisGlow.ImageTransparency = 0.3
NemesisGlow.ScaleType = Enum.ScaleType.Fit
NemesisGlow.Size = UDim2.new(0, 100, 1, 0)
NemesisGlow.Position = UDim2.new(0, 0, 0, 0)
NemesisGlow.ZIndex = 2
NemesisGlow.Parent = TextContainer

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoText"
InfoLabel.BackgroundTransparency = 1
InfoLabel.Size = UDim2.new(1, -110, 1, 0)
InfoLabel.Position = UDim2.new(0, 110, 0, 0)
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.TextSize = 13
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Center
InfoLabel.TextStrokeTransparency = 1
InfoLabel.ZIndex = 3
InfoLabel.Parent = TextContainer

local gradientRotation = 0
local rotationSpeed = 30

local fpsCounter = 0
local fpsUpdateTime = tick()
local currentFPS = 60

local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local watermarkConnection
local function updateWatermark(dt)
	if not WatermarkEnabled then
		WatermarkFrame.Visible = false
		return
	end
	
	WatermarkFrame.Visible = true
	
	-- Update FPS counter
	fpsCounter = fpsCounter + 1
	local currentTime = tick()
	if currentTime - fpsUpdateTime >= 1 then
		currentFPS = fpsCounter
		fpsCounter = 0
		fpsUpdateTime = currentTime
	end
	
	-- Animate gradient rotation
	gradientRotation = gradientRotation + (rotationSpeed * (dt or 0.016))
	if gradientRotation >= 360 then
		gradientRotation = gradientRotation - 360
	end
	NemesisGradient.Rotation = gradientRotation
	
	-- Sync glow color with gradient rotation
	local currentAngle = math.rad(gradientRotation)
	local blend = (math.sin(currentAngle * 2) * 0.5 + 0.5)
	local r = 255 - (255 - 158) * blend
	local g = 46 - (46 - 21) * blend
	local b = 46 - (46 - 40) * blend
	NemesisGlow.ImageColor3 = Color3.fromRGB(r, g, b)
	
	-- Update info
	local elapsedTime = tick() - startTime
	
	-- Get ping (ms)
	local ping = 0
	pcall(function()
		local networkStats = Stats.Network.ServerStatsItem
		if networkStats then
			local dataPing = networkStats:FindFirstChild("Data Ping")
			if dataPing then
				ping = math.floor(dataPing:GetValue())
			end
		end
	end)
	
	-- Build info text
	local infoText = string.format(
		"  |  %s  |  %s  |  %d FPS  |  %d ms",
		player.Name,
		formatTime(elapsedTime),
		currentFPS,
		ping
	)
	
	InfoLabel.Text = infoText
	
	-- Auto-resize frame to fit text
	local textService = game:GetService("TextService")
	local nemesisSize = textService:GetTextSize(
		NemesisLabel.Text,
		NemesisLabel.TextSize,
		NemesisLabel.Font,
		Vector2.new(math.huge, NemesisLabel.AbsoluteSize.Y)
	)
	
	local infoSize = textService:GetTextSize(
		InfoLabel.Text,
		InfoLabel.TextSize,
		InfoLabel.Font,
		Vector2.new(math.huge, InfoLabel.AbsoluteSize.Y)
	)
	
	local totalWidth = nemesisSize.X + infoSize.X + 24
	WatermarkFrame.Size = UDim2.new(0, totalWidth, 0, 32)
	
	-- Update NEMESIS label and glow size
	NemesisLabel.Size = UDim2.new(0, nemesisSize.X, 1, 0)
	NemesisGlow.Size = UDim2.new(0, nemesisSize.X, 1, 0)
	
	-- Update info position
	InfoLabel.Size = UDim2.new(0, infoSize.X, 1, 0)
	InfoLabel.Position = UDim2.new(0, nemesisSize.X + 10, 0, 0)
end

-- Start watermark update loop
watermarkConnection = RunService.RenderStepped:Connect(function(dt)
	updateWatermark(dt)
end)

-- Function to toggle watermark
local function setWatermarkEnabled(enabled)
	WatermarkEnabled = enabled
	if enabled then
		WatermarkFrame.Visible = true
	else
		WatermarkFrame.Visible = false
	end
end

-- Initial update
updateWatermark(0.016)

-- ============================================
-- Variables and Flags
-- ============================================
local flags = ReplicatedStorage:FindFirstChild("QuantumMovementFlags")
if not flags then
	flags = Instance.new("Folder")
	flags.Name = "QuantumMovementFlags"
	flags.Parent = ReplicatedStorage
end

local function getString(name, default)
	local v = flags:FindFirstChild(name)
	if not v then
		v = Instance.new("StringValue")
		v.Name = name
		v.Value = default or ""
		v.Parent = flags
	end
	return v
end

local MENU_BIND = getString("MenuBind", "Insert")

-- ============================================
-- CONFIG SYSTEM
-- ============================================
local CONFIG_FOLDER = "NEMESIS"
local CONFIG_EXTENSION = ".json"

local function hasFileSystem()
	return type(writefile) == "function"
		and type(readfile) == "function"
		and type(isfile) == "function"	
		and type(makefolder) == "function"
		and type(isfolder) == "function"
		and type(listfiles) == "function"
		and type(delfile) == "function"
end

local function ensureConfigFolder()
	if not hasFileSystem() then return false end
	if not isfolder(CONFIG_FOLDER) then
		makefolder(CONFIG_FOLDER)
	end
	return true
end

local function getConfigList()
	if not hasFileSystem() then return {"No configs"} end
	ensureConfigFolder()

	local configs = {}
	local base = CONFIG_FOLDER
	local ok, files = pcall(function()
		return listfiles(base)
	end)
	if not ok or type(files) ~= "table" then
		ok, files = pcall(function()
			return listfiles(base .. "/")
		end)
	end

	if ok and type(files) == "table" then
		for _, file in ipairs(files) do
			local name = tostring(file):match("([^/\\]+)$")
			if name and name:sub(-5) == ".json" then
				table.insert(configs, name:sub(1, #name - 5))
			end
		end
	end

	table.sort(configs)
	if #configs == 0 then
		configs[1] = "No configs"
	end
	return configs
end

-- ============================================
-- Initialize Modules
-- ============================================
local Visuals = VisualsModule.new({
	Player = player,
	GuiParent = guiParent,
	Services = {
		Players = Players,
		TweenService = TweenService,
		RunService = RunService,
		ReplicatedStorage = ReplicatedStorage,
		Workspace = Workspace,
		Lighting = Lighting,
		Debris = game:GetService("Debris"),
		SoundService = game:GetService("SoundService")
	},
	Notification = Notification
})

local Rage = RageModule.new({
	Player = player,
	Services = {
		Players = Players,
		RunService = RunService,
		Workspace = Workspace,
		ReplicatedStorage = ReplicatedStorage
	},
	Notification = Notification,
	Visuals = Visuals -- Pass visuals for tracer creation
})

local World = WorldModule.new()

-- ============================================
-- CONFIG FUNCTIONS
-- ============================================
local currentConfigName = "default"

local function getAllSettings()
	local settings = {}

	local rageSettings = Rage:GetSettings()
	for k, v in pairs(rageSettings) do
		settings[k] = v
	end

	local visualSettings = Visuals:GetSettings()
	for k, v in pairs(visualSettings) do
		settings[k] = v
	end

	local worldSettings = World:Export()
	for k, v in pairs(worldSettings) do
		settings[k] = v
	end

	-- Add watermark setting
	settings.WATERMARK_ENABLED = WatermarkEnabled

	return settings
end

local function applySettings(settings)
	if not settings then return end

	Rage:ApplySettings(settings)
	Visuals:ApplySettings(settings)
	World:Import(settings)
	
	-- Apply watermark setting
	if settings.WATERMARK_ENABLED ~= nil then
		setWatermarkEnabled(settings.WATERMARK_ENABLED)
	end
end

local function saveConfig(configName)
	if not ensureConfigFolder() then
		Notification:Notify({
			Title = "Config Error",
			Content = "File system not available",
			Icon = "alert-triangle",
			Duration = 3
		})
		return false
	end

	local settings = getAllSettings()
	local json = HttpService:JSONEncode(settings)
	local path = CONFIG_FOLDER .. "/" .. configName .. CONFIG_EXTENSION

	local success, err = pcall(function()
		writefile(path, json)
	end)

	if success then
		Notification:Notify({
			Title = "Config Saved",
			Content = "Saved: " .. configName,
			Icon = "check",
			Duration = 3
		})
		return true
	else
		Notification:Notify({
			Title = "Config Error",
			Content = "Failed to save",
			Icon = "alert-triangle",
			Duration = 3
		})
		return false
	end
end

local APPLYING_CONFIG = false
local UI = {}

local function uiSet(el, v)
	if el == nil or v == nil then return end
	pcall(function()
		if el.SetValue then
			el:SetValue(v)
		elseif el.SetData then
			el:SetData(v)
		end
	end)
end

local function syncUIFromVars()
	if not UI or not UI.AimbotToggle then
		APPLYING_CONFIG = false
		return
	end
	APPLYING_CONFIG = true
	
	-- Sync Rage UI
	local rageSettings = Rage:GetSettings()
	uiSet(UI.HitchanceToggle, rageSettings.RAGE_HITCHANCE_ENABLED)
	uiSet(UI.HitchanceSlider, rageSettings.RAGE_HITCHANCE)
	uiSet(UI.MinDamageToggle, rageSettings.MIN_DAMAGE_ENABLED)
	uiSet(UI.MinDamageSlider, rageSettings.MIN_DAMAGE_VALUE)
	uiSet(UI.HitboxesDropdown, rageSettings.RAGE_HITPART)
	uiSet(UI.NoSpreadToggle, rageSettings.RAGE_NOSPREAD)
	uiSet(UI.AutoEquipToggle, rageSettings.AUTO_EQUIP_SSG)
	uiSet(UI.MaxDistanceSlider, rageSettings.MAX_DISTANCE)
	uiSet(UI.AimbotToggle, rageSettings.RAGE_ENABLED)
	uiSet(UI.AutoShootToggle, rageSettings.RAGE_AUTOSHOOT)
	uiSet(UI.PredictionToggle, rageSettings.PREDICTION_ENABLED)
	uiSet(UI.PredStrengthSlider, rageSettings.PREDICTION_STRENGTH)

	local ws = World:Export()

	uiSet(UI.CustomLighting, ws.LIGHTING_EDIT_ENABLED)
	uiSet(UI.WorldBrightness, ws.CUSTOM_BRIGHTNESS)
	uiSet(UI.TimePreset, ws.TIME_PRESET)
	uiSet(UI.ClockTime, ws.CUSTOM_CLOCKTIME)
	uiSet(UI.CustomTime, ws.WORLD_TIME_ENABLED)
	uiSet(UI.SkyPreset, ws.CUSTOM_SKY_PRESET)
	uiSet(UI.CustomSky, ws.CUSTOM_SKY_ENABLED)
	
	-- Sync Visuals UI
	local visualSettings = Visuals:GetSettings()
	uiSet(UI.HitlogsToggle, visualSettings.HITLOG_ENABLED)
	uiSet(UI.HitSoundToggle, visualSettings.HITSOUND_ENABLED)
	uiSet(UI.HitSoundPreset, visualSettings.HITSOUND_PRESET)
	uiSet(UI.HitSoundVolume, visualSettings.HITSOUND_VOLUME)
	uiSet(UI.KeybindListToggle, visualSettings.KEYBIND_LIST_VISIBLE)
	uiSet(UI.TracerEnabled, visualSettings.TRACER_ENABLED)
	uiSet(UI.WallbangEnabled, visualSettings.WALLBANG_ENABLED)
	uiSet(UI.TracerLifetime, visualSettings.TRACER_LIFETIME)
	uiSet(UI.OffscreenToggle, visualSettings.OFFSCREEN_ENABLED)
	uiSet(UI.TracerWidth, visualSettings.TRACER_WIDTH)
	uiSet(UI.KillFXEnabled, visualSettings.KILLFX_ENABLED)
	uiSet(UI.KillFXType, visualSettings.KILLFX_TYPE)
	uiSet(UI.BacktrackGhostToggle, visualSettings.BACKTRACK_GHOST_ENABLED)
	uiSet(UI.BacktrackGhostDuration, visualSettings.BACKTRACK_GHOST_DURATION)
	
	-- Sync Watermark
	uiSet(UI.WatermarkToggle, WatermarkEnabled)
	
	APPLYING_CONFIG = false
	Visuals:UpdateKeybindDisplay()
end

local function loadConfig(configName)
	if not hasFileSystem() then
		Notification:Notify({
			Title = "Config Error",
			Content = "File system not available",
			Icon = "alert-triangle",
			Duration = 3
		})
		return false
	end
	local path = CONFIG_FOLDER .. "/" .. configName .. CONFIG_EXTENSION
	if not isfile(path) then
		Notification:Notify({
			Title = "Config Error",
			Content = "Config not found: " .. configName,
			Icon = "alert-triangle",
			Duration = 3
		})
		return false
	end
	local success, result = pcall(function()
		local json = readfile(path)
		return HttpService:JSONDecode(json)
	end)
	if success and result then
		applySettings(result)
		syncUIFromVars()
		Notification:Notify({
			Title = "Config Loaded",
			Content = "Loaded: " .. configName,
			Icon = "check",
			Duration = 3
		})
		return true
	else
		Notification:Notify({
			Title = "Config Error",
			Content = "Failed to load",
			Icon = "alert-triangle",
			Duration = 3
		})
		return false
	end
end

local function deleteConfig(configName)
	if not hasFileSystem() then return false end
	local path = CONFIG_FOLDER .. "/" .. configName .. CONFIG_EXTENSION
	if isfile(path) then
		delfile(path)
		Notification:Notify({
			Title = "Config Deleted",
			Content = "Deleted: " .. configName,
			Icon = "trash",
			Duration = 3
		})
		return true
	end
	return false
end

-- ============================================
-- Fatality Window Setup
-- ============================================
local Window = Fatality.new({
	Name = "NEMESIS",
	Expire = "N/A",
})

local RageTab = Window:AddMenu({
	Name = "RAGE",
	Icon = "skull"
})

local VisualTab = Window:AddMenu({
	Name = "VISUAL",
	Icon = "eye"
})

local MiscTab = Window:AddMenu({
	Name = "MISC",
	Icon = "settings"
})

-- ============================================
-- Rage Menu
-- ============================================
do
	local Weapon = RageTab:AddSection({
		Position = 'left',
		Name = "WEAPON"
	})
	local Extra = RageTab:AddSection({
		Position = 'center',
		Name = "EXTRA"
	})
	local General = RageTab:AddSection({
		Position = 'right',
		Name = "GENERAL"
	})
	
	UI.HitchanceToggle = Weapon:AddToggle({
		Name = "Hitchance",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetHitchanceEnabled(value)
		end
	})
	
	UI.HitchanceSlider = Weapon:AddSlider({
		Name = "Hit-chance",
		Type = "%",
		Min = 0,
		Max = 100,
		Default = 100,
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetHitchance(value)
		end
	})
	
	UI.MinDamageToggle = Weapon:AddToggle({
		Name = "Min-damage",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetMinDamageEnabled(value)
		end
	})
	
	UI.MinDamageSlider = Weapon:AddSlider({
		Name = "Min-damage value",
		Type = " HP",
		Min = 0,
		Max = 216,
		Default = 0,
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetMinDamageValue(value)
		end
	})
	
	UI.HitboxesDropdown = Weapon:AddDropdown({
		Name = "Hitboxes",
		Values = {"Head", "Body", "Arms", "Legs"},
		Default = "Head",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetHitpart(value)
		end
	})
	
	UI.NoSpreadToggle = Extra:AddToggle({
		Name = "No Spread (Airshot)",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetNoSpread(value)
		end
	})
	
	UI.AutoEquipToggle = Extra:AddToggle({
		Name = "Auto Equip SSG",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetAutoEquipSSG(value)
		end
	})
	
	UI.MaxDistanceSlider = Extra:AddSlider({
		Name = "Max Distance",
		Type = " studs",
		Min = 100,
		Max = 2000,
		Default = 1000,
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetMaxDistance(value)
		end
	})
	
	UI.AimbotToggle = General:AddToggle({
		Name = "Aimbot",
		Risky = true,
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetEnabled(value)
		end
	})
	
	UI.AutoShootToggle = General:AddToggle({
		Name = "Autoshoot",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetAutoShoot(value)
		end
	})
	
	UI.PredictionToggle = General:AddToggle({
		Name = "Prediction",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetPredictionEnabled(value)
		end
	})
	
	UI.PredStrengthSlider = General:AddSlider({
		Name = "Prediction Strength",
		Type = "x",
		Min = 0,
		Max = 3,
		Default = 1.2,
		Round = 1,
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetPredictionStrength(value)
		end
	})
	
	General:AddButton({
		Name = "Test Notification",
		Callback = function()
			Notification:Notify({
				Title = "Test",
				Content = "Nemesis is working!",
				Duration = 3,
				Icon = "check"
			})
		end
	})
end

-- ============================================
-- Visual Menu
-- ============================================
do
	local Main = VisualTab:AddSection({
		Name = "MAIN",
		Position = 'left'
	})

	UI.WatermarkToggle = Main:AddToggle({
		Name = "Watermark",
		Default = true,
		Callback = function(value)
			if APPLYING_CONFIG then return end
			setWatermarkEnabled(value)
		end
	})

	UI.HitlogsToggle = Main:AddToggle({
		Name = "HitLogs",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Visuals:SetHitlogEnabled(value)
		end
	})

	UI.KeybindListToggle = Main:AddToggle({
		Name = "Keybind List",
		Default = true,
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Visuals:SetKeybindListVisible(value)
		end
	})

	UI.BacktrackGhostToggle = Main:AddToggle({
		Name = "Backtrack Ghost",
		Default = false,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetBacktrackGhostEnabled(v)
		end
	})

	UI.BacktrackGhostColor = Main:AddColorPicker({
		Name = "Backtrack Color",
		Default = Color3.fromRGB(80, 160, 255),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetBacktrackGhostColor(c)
		end
	})

	UI.BacktrackGhostDuration = Main:AddSlider({
		Name = "Ghost Duration",
		Min = 0.1,
		Max = 2.0,
		Default = 0.3,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetBacktrackGhostDuration(v)
		end
	})

	UI.OffscreenToggle = Main:AddToggle({
		Name = "Arrows",
		Default = false,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetOffscreenEnabled(v)
		end
	})

	UI.OffscreenColor = Main:AddColorPicker({
		Name = "Arrow Color",
		Default = Color3.fromRGB(255, 80, 80),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetOffscreenColor(c)
		end
	})

	local WorldSec = VisualTab:AddSection({
		Name = "WORLD",
		Position = "right"
	})

	UI.CustomLighting = WorldSec:AddToggle({
		Name = "Custom Lighting",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			World:SetLightingEnabled(v)
		end
	})

	UI.WorldBrightness = WorldSec:AddSlider({
		Name = "Brightness",
		Min = 0,
		Max = 10,
		Default = Lighting.Brightness,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			World:SetBrightness(v)
		end
	})

	UI.WorldAmbient = WorldSec:AddColorPicker({
		Name = "Ambient",
		Default = Lighting.Ambient,
		Callback = function(c)
			if APPLYING_CONFIG then return end
			World:SetAmbient(c)
		end
	})

	UI.WorldOutdoorAmbient = WorldSec:AddColorPicker({
		Name = "OutdoorAmbient",
		Default = Lighting.OutdoorAmbient,
		Callback = function(c)
			if APPLYING_CONFIG then return end
			World:SetOutdoorAmbient(c)
		end
	})

	UI.TimePreset = WorldSec:AddDropdown({
		Name = "Time Preset",
		Values = {"Default", "Day", "Sunset", "Night"},
		Default = "Default",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			World:SetTimePreset(v)
		end
	})

	UI.ClockTime = WorldSec:AddSlider({
		Name = "ClockTime",
		Min = 0,
		Max = 24,
		Default = Lighting.ClockTime,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			World:SetClockTime(v)
		end
	})

	UI.CustomTime = WorldSec:AddToggle({
		Name = "Custom Time",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			World:SetTimeEnabled(v)
		end
	})

	UI.SkyPreset = WorldSec:AddDropdown({
		Name = "Sky Preset",
		Values = {"Original", "Blue"},
		Default = "Original",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			World:SetSkyPreset(v)
		end
	})

	UI.CustomSky = WorldSec:AddToggle({
		Name = "Custom Sky",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			World:SetSkyEnabled(v)
		end
	})

	local KillFX = VisualTab:AddSection({
		Name = "KILL EFFECTS",
		Position = "center"
	})

	UI.KillFXEnabled = KillFX:AddToggle({
		Name = "Kill Effect",
		Default = false,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetKillFXEnabled(v)
		end
	})

	UI.KillFXType = KillFX:AddDropdown({
		Name = "Effect Type",
		Values = {"ImpactFX", "CustomFX"},
		Default = "ImpactFX",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetKillFXType(v)
		end
	})

	UI.KillFXColor = KillFX:AddColorPicker({
		Name = "Particle Color",
		Default = Color3.fromRGB(80, 160, 255),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetKillFXColor(c)
		end
	})

	UI.KillFXLightColor = KillFX:AddColorPicker({
		Name = "Light Color",
		Default = Color3.fromRGB(120, 180, 255),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetKillFXLightColor(c)
		end
	})

	UI.KillFXDuration = KillFX:AddSlider({
		Name = "Effect Duration",
		Min = 0.05,
		Max = 1.5,
		Default = 0.25,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetKillFXDuration(v)
		end
	})

	UI.KillFXLightRange = KillFX:AddSlider({
		Name = "Light Range",
		Min = 5,
		Max = 40,
		Default = 15,
		Round = 0,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetKillFXLightRange(v)
		end
	})

	UI.HitSoundToggle = KillFX:AddToggle({
		Name = "Hit Sound",
		Default = true,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetHitSoundEnabled(v)
		end
	})

	UI.HitSoundPreset = KillFX:AddDropdown({
		Name = "Hit Sound Type",
		Values = {
			"bell", "correct", "skeet", "orchestra", "bow", "uwu", "tf2", "b8",
			"basketball", "idk", "orb", "balltap", "softbell", "softhit", "soft",
			"bell2", "tank1", "rampage", "headshot", "tank2", "rust"
		},
		Default = "bell",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetHitSoundPreset(v)
		end
	})

	UI.HitSoundVolume = KillFX:AddSlider({
		Name = "Hit Sound Volume",
		Min = 0,
		Max = 3,
		Default = 1,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetHitSoundVolume(v)
		end
	})

	local TracerSec = VisualTab:AddSection({
		Name = "TRACERS",
		Position = 'right'
	})

	UI.TracerEnabled = TracerSec:AddToggle({
		Name = "Enabled",
		Default = false,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetTracerEnabled(v)
		end
	})

	UI.TracerColor = TracerSec:AddColorPicker({
		Name = "Tracer Color",
		Default = Color3.fromRGB(255, 100, 220),
		Callback = function(color)
			if APPLYING_CONFIG then return end
			Visuals:SetTracerColor(color)
		end
	})

	UI.TracerLifetime = TracerSec:AddSlider({
		Name = "Lifetime (sec)",
		Min = 0.15,
		Max = 2.5,
		Default = 0.45,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetTracerLifetime(v)
		end
	})

	UI.TracerWidth = TracerSec:AddSlider({
		Name = "Width Scale",
		Min = 0.02,
		Max = 0.25,
		Default = 0.12,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetTracerWidth(v)
		end
	})

	local WallbangSec = VisualTab:AddSection({
		Name = "WALLBANG",
		Position = 'left'
	})

	UI.WallbangEnabled = WallbangSec:AddToggle({
		Name = "Wallbang Visual",
		Default = false,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetWallbangEnabled(v)
		end
	})

	UI.WallbangEntryColor = WallbangSec:AddColorPicker({
		Name = "Entry Color (Red)",
		Default = Color3.fromRGB(255, 50, 50),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetWallbangEntryColor(c)
		end
	})

	UI.WallbangExitColor = WallbangSec:AddColorPicker({
		Name = "Exit Color (Green)",
		Default = Color3.fromRGB(50, 255, 50),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetWallbangExitColor(c)
		end
	})
end

-- ============================================
-- Misc Menu (POST PROCESSING)
-- ============================================
do
	local PostProcessing = MiscTab:AddSection({
		Name = "POST PROCESSING",
		Position = 'left'
	})

	UI.AtmoEnabled = PostProcessing:AddToggle({
		Name = "Atmosphere Enabled",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			-- TODO: Add Atmosphere support to Visuals module
			warn("[NEMESIS] Atmosphere not yet implemented in Visuals module")
		end
	})

	UI.AtmoDensity = PostProcessing:AddSlider({
		Name = "Atmosphere Density",
		Min = 0,
		Max = 1,
		Default = 0.3,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Atmosphere not yet implemented")
		end
	})

	UI.AtmoOffset = PostProcessing:AddSlider({
		Name = "Atmosphere Offset",
		Min = 0,
		Max = 1,
		Default = 0.25,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Atmosphere not yet implemented")
		end
	})

	UI.AtmoColor = PostProcessing:AddColorPicker({
		Name = "Atmosphere Color",
		Default = Color3.fromRGB(200, 200, 200),
		Callback = function(color)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Atmosphere not yet implemented")
		end
	})

	UI.AtmoDecay = PostProcessing:AddColorPicker({
		Name = "Atmosphere Decay",
		Default = Color3.fromRGB(128, 128, 128),
		Callback = function(color)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Atmosphere not yet implemented")
		end
	})

	UI.AtmoGlare = PostProcessing:AddSlider({
		Name = "Atmosphere Glare",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Atmosphere not yet implemented")
		end
	})

	UI.AtmoHaze = PostProcessing:AddSlider({
		Name = "Atmosphere Haze",
		Min = 0,
		Max = 10,
		Default = 0.5,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Atmosphere not yet implemented")
		end
	})

	UI.BloomEnabled = PostProcessing:AddToggle({
		Name = "Bloom Enabled",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Bloom not yet implemented")
		end
	})

	UI.BloomIntensity = PostProcessing:AddSlider({
		Name = "Bloom Intensity",
		Min = 0,
		Max = 5,
		Default = 0.5,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Bloom not yet implemented")
		end
	})

	UI.BloomSize = PostProcessing:AddSlider({
		Name = "Bloom Size",
		Min = 0,
		Max = 100,
		Default = 24,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Bloom not yet implemented")
		end
	})

	UI.BloomThreshold = PostProcessing:AddSlider({
		Name = "Bloom Threshold",
		Min = 0,
		Max = 5,
		Default = 2,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] Bloom not yet implemented")
		end
	})

	UI.CCEnabled = PostProcessing:AddToggle({
		Name = "ColorCorrection Enabled",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] ColorCorrection not yet implemented")
		end
	})

	UI.CCBrightness = PostProcessing:AddSlider({
		Name = "Brightness",
		Min = -1,
		Max = 1,
		Default = 0,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] ColorCorrection not yet implemented")
		end
	})

	UI.CCContrast = PostProcessing:AddSlider({
		Name = "Contrast",
		Min = -1,
		Max = 1,
		Default = 0,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] ColorCorrection not yet implemented")
		end
	})

	UI.CCSaturation = PostProcessing:AddSlider({
		Name = "Saturation",
		Min = -1,
		Max = 1,
		Default = 0,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] ColorCorrection not yet implemented")
		end
	})

	UI.CCTint = PostProcessing:AddColorPicker({
		Name = "Tint Color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			if APPLYING_CONFIG then return end
			warn("[NEMESIS] ColorCorrection not yet implemented")
		end
	})
end

-- ============================================
-- Config Section
-- ============================================
local ConfigSection = MiscTab:AddSection({
	Name = "CONFIG",
	Position = "center"
})

local function sanitizeName(s)
	s = tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")
	s = s:gsub("[^%w%-%_]", "_")
	if s == "" then s = "default" end
	return s
end

local function pickDefaultConfig(list)
	for i = 1, #list do
		if list[i] ~= "No configs" then
			return list[i]
		end
	end
	return "default"
end

local function genNewConfigName()
	return sanitizeName("cfg_" .. tostring(os.time()))
end

local list = getConfigList()
currentConfigName = sanitizeName(currentConfigName or pickDefaultConfig(list))

ConfigSection:AddDropdown({
	Name = "Select Config",
	Values = list,
	Default = currentConfigName,
	Callback = function(value)
		if value and value ~= "No configs" then
			currentConfigName = sanitizeName(value)
			Notification:Notify({
				Title = "Config",
				Content = "Selected: " .. currentConfigName,
				Icon = "check",
				Duration = 2
			})
		end
	end
})

ConfigSection:AddButton({
	Name = "New Config (Auto)",
	Callback = function()
		currentConfigName = genNewConfigName()
		Notification:Notify({
			Title = "Config",
			Content = "New name: " .. currentConfigName .. " (save it)",
			Icon = "info",
			Duration = 3
		})
	end
})

ConfigSection:AddButton({
	Name = "Save Config",
	Callback = function()
		currentConfigName = sanitizeName(currentConfigName)
		saveConfig(currentConfigName)
	end
})

ConfigSection:AddButton({
	Name = "Load Config",
	Callback = function()
		currentConfigName = sanitizeName(currentConfigName)
		loadConfig(currentConfigName)
	end
})

ConfigSection:AddButton({
	Name = "Delete Config",
	Callback = function()
		currentConfigName = sanitizeName(currentConfigName)
		deleteConfig(currentConfigName)
	end
})

ConfigSection:AddButton({
	Name = "Refresh List",
	Callback = function()
		Notification:Notify({
			Title = "Configs",
			Content = "Re-open menu to refresh list",
			Icon = "refresh-cw",
			Duration = 3
		})
	end
})

-- ============================================
-- Start Modules
-- ============================================
Rage:Start()
Visuals:Start()

syncUIFromVars()
print("Nemesis Loaded")
