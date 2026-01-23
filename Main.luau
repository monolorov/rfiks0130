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
-- Load modules!
-- ============================================
print("[NEMESIS] Loading Visuals module...")
local VisualsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/monolorov/rfiks0130/refs/heads/main/Visuals.luau"))()
print("[NEMESIS] Visuals loaded")

print("[NEMESIS] Loading ESP module...")
local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/monolorov/Nemesis/refs/heads/main/Esp.luau"))()
print("[NEMESIS] ESP loaded")

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

local WatermarkEnabled = true

local function setWatermarkEnabled(v)
	WatermarkEnabled = v
end
local startTime = tick()
local Stats = game:GetService("Stats")

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "NemesisWatermark"
WatermarkGui.ResetOnSpawn = false
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WatermarkGui.Parent = guiParent

local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.AnchorPoint = Vector2.new(1, 0)
WatermarkFrame.Position = UDim2.new(1, -10, 0, 50)
WatermarkFrame.Size = UDim2.new(0, 300, 0, 32)
WatermarkFrame.ZIndex = 10
WatermarkFrame.Active = true
WatermarkFrame.Parent = WatermarkGui

do
	local dragging = false
	local dragStart
	local startPos
	local dragInput
	local dragTween

	WatermarkFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = WatermarkFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	WatermarkFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			local target = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)

			if dragTween then
				dragTween:Cancel()
			end

			dragTween = TweenService:Create(
				WatermarkFrame,
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = target }
			)

			dragTween:Play()
		end
	end)
end

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = WatermarkFrame

local TextContainer = Instance.new("Frame")
TextContainer.BackgroundTransparency = 1
TextContainer.Position = UDim2.fromOffset(10, 0)
TextContainer.Size = UDim2.new(0, 0, 1, 0)
TextContainer.AutomaticSize = Enum.AutomaticSize.X
TextContainer.ZIndex = 11
TextContainer.Parent = WatermarkFrame

local NemesisLabel = Instance.new("TextLabel")
NemesisLabel.BackgroundTransparency = 1
NemesisLabel.Font = Enum.Font.GothamBold
NemesisLabel.Text = "NEMESIS"
NemesisLabel.TextSize = 14
NemesisLabel.TextColor3 = Color3.new(1, 1, 1)
NemesisLabel.TextXAlignment = Enum.TextXAlignment.Left
NemesisLabel.Size = UDim2.new(0, 80, 1, 0)
NemesisLabel.ZIndex = 12
NemesisLabel.Parent = TextContainer

local NemesisGradient = Instance.new("UIGradient")
NemesisGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(212, 49, 49)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 51, 51)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(194, 41, 41))
})
NemesisGradient.Parent = NemesisLabel

-- ============================================
-- Center branding (image + text)
-- ============================================

local CenterImage = Instance.new("ImageLabel")
CenterImage.BackgroundTransparency = 1
CenterImage.BorderSizePixel = 0
CenterImage.Position = UDim2.new(0.47, 0, 0.489, 0)
CenterImage.Size = UDim2.new(0.061, 0, 0.023, 0)
CenterImage.SizeConstraint = Enum.SizeConstraint.RelativeXY
CenterImage.Image = "rbxassetid://101484652640045"
CenterImage.ImageColor3 = Color3.fromRGB(255, 69, 72)
CenterImage.ImageTransparency = 0.51
CenterImage.ZIndex = 11
CenterImage.Parent = WatermarkGui


local CenterText = Instance.new("TextLabel")
CenterText.AnchorPoint = Vector2.new(0.5, 0.5)
CenterText.BackgroundTransparency = 1
CenterText.BorderSizePixel = 0
CenterText.Position = UDim2.new(0.5, 0, 0.5, 0)
CenterText.Size = UDim2.new(0.2, 0, 0.1, 0)
CenterText.Font = Enum.Font.ArialBold
CenterText.Text = "NEMESIS.lua"
CenterText.TextColor3 = Color3.fromRGB(255, 255, 255)
CenterText.TextSize = 14
CenterText.TextWrapped = true
CenterText.ZIndex = 12
CenterText.Parent = WatermarkGui

local ImageStroke = Instance.new("UIStroke")
ImageStroke.Thickness = 0.5
ImageStroke.Color = Color3.fromRGB(0, 0, 0)
ImageStroke.Transparency = 0
ImageStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ImageStroke.Parent = CenterImage


local CenterGradient = Instance.new("UIGradient")
CenterGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(161, 35, 37)),
	ColorSequenceKeypoint.new(0.20, Color3.fromRGB(179, 46, 49)),
	ColorSequenceKeypoint.new(0.38, Color3.fromRGB(167, 43, 45)),
	ColorSequenceKeypoint.new(0.56, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.72, Color3.fromRGB(180, 0, 3)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(139, 36, 38))
})
CenterGradient.Parent = CenterText

local InfoLabel = Instance.new("TextLabel")
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextSize = 13
InfoLabel.TextColor3 = Color3.new(1, 1, 1)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Size = UDim2.new(0, 200, 1, 0)
InfoLabel.ZIndex = 12
InfoLabel.Parent = TextContainer

local fpsCounter = 0
local fpsTick = tick()
local currentFPS = 0
local rotation = 0

local function formatTime(sec)
	return string.format(
		"%02d:%02d:%02d",
		math.floor(sec / 3600),
		math.floor(sec % 3600 / 60),
		math.floor(sec % 60)
	)
end

RunService.RenderStepped:Connect(function(dt)
	if not WatermarkEnabled then
		WatermarkFrame.Visible = false
		return
	end

	WatermarkFrame.Visible = true

	fpsCounter += 1
	if tick() - fpsTick >= 1 then
		currentFPS = fpsCounter
		fpsCounter = 0
		fpsTick = tick()
	end

	rotation = (rotation + dt * 30) % 360
	NemesisGradient.Rotation = rotation

-- Center gradient rotate
CenterGradient.Rotation = (CenterGradient.Rotation + dt * 60) % 360

-- Pulse effect
local pulse = 0.6 + math.sin(tick() * 1.5) * 0.1
CenterImage.ImageTransparency = math.clamp(pulse, 0.5, 0.75)

	local ping = 0
	pcall(function()
		local n = Stats.Network.ServerStatsItem
		local p = n and n:FindFirstChild("Data Ping")
		if p then
			ping = math.floor(p:GetValue())
		end
	end)

	InfoLabel.Text = string.format(
		"| %s | %s | %d FPS | %d ms",
		player.Name,
		formatTime(tick() - startTime),
		currentFPS,
		ping
	)

	local TS = game:GetService("TextService")
	local nSize = TS:GetTextSize(NemesisLabel.Text, NemesisLabel.TextSize, NemesisLabel.Font, Vector2.new(1000, 32))
	local iSize = TS:GetTextSize(InfoLabel.Text, InfoLabel.TextSize, InfoLabel.Font, Vector2.new(1000, 32))

	NemesisLabel.Size = UDim2.fromOffset(nSize.X, 32)
	InfoLabel.Position = UDim2.fromOffset(nSize.X + 8, 0)
	InfoLabel.Size = UDim2.fromOffset(iSize.X, 32)

local baseWidth = nSize.X + iSize.X + 28
local minWidth = 300

WatermarkFrame.Size = UDim2.fromOffset(
	math.max(baseWidth, minWidth),
	32
)
end)

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

local ESP = ESPModule.new({
	Player = player,
	GuiParent = guiParent,
	Services = {
		Players = Players,
		RunService = RunService,
		TweenService = TweenService
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

	local espSettings = ESP:GetSettings()
	for k, v in pairs(espSettings) do
		settings[k] = v
	end

	local worldSettings = World:Export()
	for k, v in pairs(worldSettings) do
		settings[k] = v
	end

	settings.WATERMARK_ENABLED = WatermarkEnabled
	return settings
end

local function applySettings(settings)
	if not settings then return end

	Rage:ApplySettings(settings)
	Visuals:ApplySettings(settings)
	World:Import(settings)

	if ESP then
		ESP:ApplySettings(settings)
	end

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

local vs = Visuals:GetSettings()

uiSet(UI.AtmoEnabled, vs.ATMOSPHERE_ENABLED)
uiSet(UI.AtmoDensity, vs.ATMOSPHERE_DENSITY)
uiSet(UI.AtmoOffset, vs.ATMOSPHERE_OFFSET)
uiSet(UI.AtmoGlare, vs.ATMOSPHERE_GLARE)
uiSet(UI.AtmoHaze, vs.ATMOSPHERE_HAZE)

uiSet(UI.BloomEnabled, vs.BLOOM_ENABLED)
uiSet(UI.BloomIntensity, vs.BLOOM_INTENSITY)
uiSet(UI.BloomSize, vs.BLOOM_SIZE)
uiSet(UI.BloomThreshold, vs.BLOOM_THRESHOLD)

uiSet(UI.CCEnabled, vs.COLORCORRECTION_ENABLED)
uiSet(UI.CCBrightness, vs.COLORCORRECTION_BRIGHTNESS)
uiSet(UI.CCContrast, vs.COLORCORRECTION_CONTRAST)
uiSet(UI.CCSaturation, vs.COLORCORRECTION_SATURATION)

	local esp = ESP:GetSettings()
	uiSet(UI.ESPEnabled, esp.ESP_ENABLED)
	uiSet(UI.SelfESP, esp.SELF_ESP)
	uiSet(UI.HealthESP, esp.HEALTH_ESP)
	uiSet(UI.DistanceESP, esp.DISTANCE_ESP)
	uiSet(UI.WeaponESP, esp.WEAPON_ESP)
	uiSet(UI.CornerBox, esp.CORNER_BOX)
	uiSet(UI.TracersESP, esp.TRACERS_ENABLED)
	uiSet(UI.SkeletonESP, esp.SKELETON_ENABLED)
	uiSet(UI.ChamsEnabled, esp.CHAMS_ENABLED)
	uiSet(UI.ChamsOutline, esp.CHAMS_OUTLINE)
	uiSet(UI.ChamsSolid, esp.CHAMS_SOLID)
	uiSet(UI.ChamsGlow, esp.CHAMS_GLOW)
	uiSet(UI.TeamCheck, esp.TEAM_CHECK)
	uiSet(UI.TeamHide, esp.TEAM_HIDE)


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
	Keybind = Enum.KeyCode.F3,
	Expire = "N/A",
})

local RageTab = Window:AddMenu({
	Name = "RAGE",
	Icon = "skull"
})

local ESPTab = Window:AddMenu({
	Name = "ESP",
	Icon = "target"
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

	--[[
	UI.NoSpreadToggle = Extra:AddToggle({
		Name = "No Spread (Airshot)",
		Callback = function(value)
			if APPLYING_CONFIG then return end
			Rage:SetNoSpread(value)
		end
	})
	]]

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
	Values = {"Original", "Blue", "Red", "Purple", "Gray", "Dark", "Green", "Pink", "Orange"},
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
			Visuals:SetAtmosphereEnabled(v)
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
			Visuals:SetAtmosphereDensity(v)
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
			Visuals:SetAtmosphereOffset(v)
		end
	})

	UI.AtmoColor = PostProcessing:AddColorPicker({
		Name = "Atmosphere Color",
		Default = Color3.fromRGB(200, 200, 200),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetAtmosphereColor(c)
		end
	})

	UI.AtmoDecay = PostProcessing:AddColorPicker({
		Name = "Atmosphere Decay",
		Default = Color3.fromRGB(128, 128, 128),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetAtmosphereDecay(c)
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
			Visuals:SetAtmosphereGlare(v)
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
			Visuals:SetAtmosphereHaze(v)
		end
	})

	UI.BloomEnabled = PostProcessing:AddToggle({
		Name = "Bloom Enabled",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetBloomEnabled(v)
		end
	})

	UI.BloomIntensity = PostProcessing:AddSlider({
		Name = "Bloom Intensity",
		Min = 0,
		Max = 5,
		Default = 2,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetBloomIntensity(v)
		end
	})

	UI.BloomSize = PostProcessing:AddSlider({
		Name = "Bloom Size",
		Min = 0,
		Max = 100,
		Default = 56,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetBloomSize(v)
		end
	})

	UI.BloomThreshold = PostProcessing:AddSlider({
		Name = "Bloom Threshold",
		Min = 0,
		Max = 5,
		Default = 0.8,
		Round = 2,
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetBloomThreshold(v)
		end
	})

	UI.CCEnabled = PostProcessing:AddToggle({
		Name = "ColorCorrection Enabled",
		Callback = function(v)
			if APPLYING_CONFIG then return end
			Visuals:SetColorCorrectionEnabled(v)
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
			Visuals:SetColorCorrectionBrightness(v)
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
			Visuals:SetColorCorrectionContrast(v)
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
			Visuals:SetColorCorrectionSaturation(v)
		end
	})

	UI.CCTint = PostProcessing:AddColorPicker({
		Name = "Tint Color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(c)
			if APPLYING_CONFIG then return end
			Visuals:SetColorCorrectionTint(c)
		end
	})

	do
		local Main = ESPTab:AddSection({
			Name = "MAIN",
			Position = "left"
		})

		UI.ESPEnabled = Main:AddToggle({
			Name = "Enable ESP",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetEnabled(v)
			end
		})

		UI.SelfESP = Main:AddToggle({
			Name = "Self ESP",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetSelfESP(v)
			end
		})

		local Box = ESPTab:AddSection({
			Name = "BOX",
			Position = "center"
		})

		UI.CornerBox = Box:AddToggle({
			Name = "Corner Box",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetCornerBox(v)
			end
		})

		UI.HealthESP = Box:AddToggle({
			Name = "Health",
			Default = true,
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetHealthESP(v)
			end
		})

		UI.DistanceESP = Box:AddToggle({
			Name = "Distance",
			Default = true,
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetDistanceESP(v)
			end
		})

		UI.WeaponESP = Box:AddToggle({
			Name = "Weapon",
			Default = true,
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetWeaponESP(v)
			end
		})

		local Chams = ESPTab:AddSection({
			Name = "CHAMS",
			Position = "right"
		})

		UI.ChamsEnabled = Chams:AddToggle({
			Name = "Enabled",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetChamsEnabled(v)
			end
		})

		UI.ChamsOutline = Chams:AddToggle({
			Name = "Outline",
			Default = true,
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetChamsOutline(v)
			end
		})

		UI.ChamsSolid = Chams:AddToggle({
			Name = "Solid",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetChamsSolid(v)
			end
		})

		UI.ChamsGlow = Chams:AddToggle({
			Name = "Glow",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetChamsGlow(v)
			end
		})

		local Extra = ESPTab:AddSection({
			Name = "EXTRA",
			Position = "left"
		})

		UI.TracersESP = Extra:AddToggle({
			Name = "Tracers",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetTracersEnabled(v)
			end
		})

		UI.SkeletonESP = Extra:AddToggle({
			Name = "Skeleton",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetSkeletonEnabled(v)
			end
		})

		UI.TeamCheck = Extra:AddToggle({
			Name = "Team Check",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetTeamCheck(v)
			end
		})

		UI.TeamHide = Extra:AddToggle({
			Name = "Team Hide",
			Callback = function(v)
				if APPLYING_CONFIG then return end
				ESP:SetTeamHide(v)
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
end

	print("Nemesis Loaded")
