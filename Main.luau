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
-- Load modules (с правильными именами!)
-- ============================================
print("[NEMESIS] Loading Visuals module...")
local VisualsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/monolorov/Nemesis/refs/heads/main/Visuals.luau"))()
print("[NEMESIS] ✓ Visuals loaded")

print("[NEMESIS] Loading Rage module...")
local RageModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/monolorov/Nemesis/refs/heads/main/Rage.luau"))()
print("[NEMESIS] ✓ Rage loaded")

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

-- ============================================
-- CONFIG FUNCTIONS
-- ============================================
local currentConfigName = "default"

local function getAllSettings()
	local settings = {}
	
	-- Get Rage settings
	local rageSettings = Rage:GetSettings()
	for k, v in pairs(rageSettings) do
		settings[k] = v
	end
	
	-- Get Visuals settings
	local visualSettings = Visuals:GetSettings()
	for k, v in pairs(visualSettings) do
		settings[k] = v
	end
	
	return settings
end

local function applySettings(settings)
	if not settings then return end
	
	-- Apply to Rage
	Rage:ApplySettings(settings)
	
	-- Apply to Visuals
	Visuals:ApplySettings(settings)
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
	Name = "Nemesis",
	Expire = "never",
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
print("✅ Nemesis Loaded")
