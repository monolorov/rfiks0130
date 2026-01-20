-- ============================================
-- UI Module
-- ============================================
local Shared = _G.NemesisShared
local Fatality = Shared.Fatality
local Notification = Shared.Notification
local player = Shared.Player

-- ============================================
-- Create Window
-- ============================================
local Window = Fatality.new({
	Name = "Nemesis",
	Expire = "never",
})

local Rage = Window:AddMenu({
	Name = "RAGE",
	Icon = "skull"
})

local Visual = Window:AddMenu({
	Name = "VISUAL",
	Icon = "eye"
})

local Misc = Window:AddMenu({
	Name = "MISC",
	Icon = "settings"
})

-- ============================================
-- RAGE MENU
-- ============================================
do
	local Weapon = Rage:AddSection({
		Position = 'left',
		Name = "WEAPON"
	})
	
	local Extra = Rage:AddSection({
		Position = 'center',
		Name = "EXTRA"
	})
	
	local General = Rage:AddSection({
		Position = 'right',
		Name = "GENERAL"
	})

	-- Weapon Section
	Shared.UI.HitchanceToggle = Weapon:AddToggle({
		Name = "Hitchance",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setHitchanceEnabled then
				Shared.Functions.setHitchanceEnabled(value)
			end
		end
	})

	Shared.UI.HitchanceSlider = Weapon:AddSlider({
		Name = "Hit-chance",
		Type = "%",
		Min = 0,
		Max = 100,
		Default = 100,
		Callback = function(value)
			if Shared.Functions.setHitchance then
				Shared.Functions.setHitchance(value)
			end
		end
	})

	Shared.UI.MinDamageToggle = Weapon:AddToggle({
		Name = "Min-damage",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setMinDamageEnabled then
				Shared.Functions.setMinDamageEnabled(value)
			end
		end
	})

	Shared.UI.MinDamageSlider = Weapon:AddSlider({
		Name = "Min-damage value",
		Type = " HP",
		Min = 0,
		Max = 216,
		Default = 0,
		Callback = function(value)
			if Shared.Functions.setMinDamageValue then
				Shared.Functions.setMinDamageValue(value)
			end
		end
	})

	Shared.UI.HitboxesDropdown = Weapon:AddDropdown({
		Name = "Hitboxes",
		Values = {"Head", "Body", "Arms", "Legs"},
		Default = "Head",
		Callback = function(value)
			if Shared.Functions.setHitpart then
				Shared.Functions.setHitpart(value)
			end
		end
	})

	-- Extra Section
	Shared.UI.NoSpreadToggle = Extra:AddToggle({
		Name = "No Spread (Airshot)",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setNoSpread then
				Shared.Functions.setNoSpread(value)
			end
		end
	})

	Shared.UI.AutoEquipToggle = Extra:AddToggle({
		Name = "Auto Equip SSG",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setAutoEquip then
				Shared.Functions.setAutoEquip(value)
			end
		end
	})

	Shared.UI.MaxDistanceSlider = Extra:AddSlider({
		Name = "Max Distance",
		Type = " studs",
		Min = 100,
		Max = 2000,
		Default = 1000,
		Callback = function(value)
			if Shared.Functions.setMaxDistance then
				Shared.Functions.setMaxDistance(value)
			end
		end
	})

	-- General Section
	Shared.UI.AimbotToggle = General:AddToggle({
		Name = "Aimbot",
		Risky = true,
		Default = false,
		Callback = function(value)
			if Shared.Functions.setRageEnabled then
				Shared.Functions.setRageEnabled(value)
			end
		end
	})

	Shared.UI.AutoShootToggle = General:AddToggle({
		Name = "Autoshoot",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setAutoShoot then
				Shared.Functions.setAutoShoot(value)
			end
		end
	})

	Shared.UI.PredictionToggle = General:AddToggle({
		Name = "Prediction",
		Default = true,
		Callback = function(value)
			if Shared.Functions.setPredictionEnabled then
				Shared.Functions.setPredictionEnabled(value)
			end
		end
	})

	Shared.UI.PredStrengthSlider = General:AddSlider({
		Name = "Prediction Strength",
		Type = "x",
		Min = 0,
		Max = 3,
		Default = 1.2,
		Round = 1,
		Callback = function(value)
			if Shared.Functions.setPredictionStrength then
				Shared.Functions.setPredictionStrength(value)
			end
		end
	})
end

-- ============================================
-- VISUAL MENU
-- ============================================
do
	-- LEFT COLUMN - Main Visuals
	local Main = Visual:AddSection({
		Name = "MAIN",
		Position = 'left'
	})

	Shared.UI.HitlogsToggle = Main:AddToggle({
		Name = "HitLogs",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setHitlogEnabled then
				Shared.Functions.setHitlogEnabled(value)
			end
		end
	})

	Shared.UI.KeybindListToggle = Main:AddToggle({
		Name = "Keybind List",
		Default = true,
		Callback = function(value)
			if Shared.Functions.setKeybindListVisible then
				Shared.Functions.setKeybindListVisible(value)
			end
		end
	})

	Shared.UI.BacktrackGhostToggle = Main:AddToggle({
		Name = "Backtrack Ghost",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setBacktrackGhostEnabled then
				Shared.Functions.setBacktrackGhostEnabled(value)
			end
		end
	})

	Shared.UI.BacktrackGhostColor = Main:AddColorPicker({
		Name = "Backtrack Color",
		Default = Color3.fromRGB(80, 160, 255),
		Callback = function(color)
			if Shared.Functions.setBacktrackGhostColor then
				Shared.Functions.setBacktrackGhostColor(color)
			end
		end
	})

	Shared.UI.BacktrackGhostDuration = Main:AddSlider({
		Name = "Ghost Duration",
		Min = 0.1,
		Max = 2.0,
		Default = 0.3,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setBacktrackGhostDuration then
				Shared.Functions.setBacktrackGhostDuration(value)
			end
		end
	})

	Shared.UI.IndicatorToggle = Main:AddToggle({
		Name = "Indicator",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setIndicatorEnabled then
				Shared.Functions.setIndicatorEnabled(value)
			end
		end
	})

	Shared.UI.OffscreenToggle = Main:AddToggle({
		Name = "Arrows",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setOffscreenEnabled then
				Shared.Functions.setOffscreenEnabled(value)
			end
		end
	})

	Shared.UI.OffscreenColor = Main:AddColorPicker({
		Name = "Arrow Color",
		Default = Color3.fromRGB(255, 80, 80),
		Callback = function(color)
			if Shared.Functions.setOffscreenColor then
				Shared.Functions.setOffscreenColor(color)
			end
		end
	})

	-- Wallbang Section
	local WallbangSec = Visual:AddSection({
		Name = "WALLBANG",
		Position = 'left'
	})

	Shared.UI.WallbangEnabled = WallbangSec:AddToggle({
		Name = "Wallbang Visual",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setWallbangEnabled then
				Shared.Functions.setWallbangEnabled(value)
			end
		end
	})

	Shared.UI.WallbangEntryColor = WallbangSec:AddColorPicker({
		Name = "Entry Color (Red)",
		Default = Color3.fromRGB(255, 50, 50),
		Callback = function(color)
			if Shared.Functions.setWallbangEntryColor then
				Shared.Functions.setWallbangEntryColor(color)
			end
		end
	})

	Shared.UI.WallbangExitColor = WallbangSec:AddColorPicker({
		Name = "Exit Color (Green)",
		Default = Color3.fromRGB(50, 255, 50),
		Callback = function(color)
			if Shared.Functions.setWallbangExitColor then
				Shared.Functions.setWallbangExitColor(color)
			end
		end
	})

	Shared.UI.WallbangMarkerSize = WallbangSec:AddSlider({
		Name = "Marker Size",
		Min = 0.2,
		Max = 2.0,
		Default = 0.5,
		Round = 1,
		Callback = function(value)
			if Shared.Functions.setWallbangMarkerSize then
				Shared.Functions.setWallbangMarkerSize(value)
			end
		end
	})

	Shared.UI.WallbangLifetime = WallbangSec:AddSlider({
		Name = "Marker Lifetime",
		Min = 1,
		Max = 10,
		Default = 3,
		Round = 0,
		Callback = function(value)
			if Shared.Functions.setWallbangLifetime then
				Shared.Functions.setWallbangLifetime(value)
			end
		end
	})

	-- CENTER COLUMN - Kill Effects
	local KillFX = Visual:AddSection({
		Name = "KILL EFFECTS",
		Position = "center"
	})

	Shared.UI.KillFXEnabled = KillFX:AddToggle({
		Name = "Kill Effect",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setKillFXEnabled then
				Shared.Functions.setKillFXEnabled(value)
			end
		end
	})

	Shared.UI.KillFXType = KillFX:AddDropdown({
		Name = "Effect Type",
		Values = {"ImpactFX", "CustomFX"},
		Default = "ImpactFX",
		Callback = function(value)
			if Shared.Functions.setKillFXType then
				Shared.Functions.setKillFXType(value)
			end
		end
	})

	Shared.UI.KillFXColor = KillFX:AddColorPicker({
		Name = "Particle Color",
		Default = Color3.fromRGB(80, 160, 255),
		Callback = function(color)
			if Shared.Functions.setKillFXColor then
				Shared.Functions.setKillFXColor(color)
			end
		end
	})

	Shared.UI.KillFXLightColor = KillFX:AddColorPicker({
		Name = "Light Color",
		Default = Color3.fromRGB(120, 180, 255),
		Callback = function(color)
			if Shared.Functions.setKillFXLightColor then
				Shared.Functions.setKillFXLightColor(color)
			end
		end
	})

	Shared.UI.KillFXDuration = KillFX:AddSlider({
		Name = "Effect Duration",
		Min = 0.05,
		Max = 1.5,
		Default = 0.25,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setKillFXDuration then
				Shared.Functions.setKillFXDuration(value)
			end
		end
	})

	Shared.UI.KillFXLightRange = KillFX:AddSlider({
		Name = "Light Range",
		Min = 5,
		Max = 40,
		Default = 15,
		Round = 0,
		Callback = function(value)
			if Shared.Functions.setKillFXLightRange then
				Shared.Functions.setKillFXLightRange(value)
			end
		end
	})

	Shared.UI.KillImageEnabled = KillFX:AddToggle({
		Name = "Kill 1.6 Effect",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setKillImageEnabled then
				Shared.Functions.setKillImageEnabled(value)
			end
		end
	})

	Shared.UI.KillImageColor = KillFX:AddColorPicker({
		Name = "Kill 1.6 Color",
		Default = Color3.fromRGB(80, 160, 255),
		Callback = function(color)
			if Shared.Functions.setKillImageColor then
				Shared.Functions.setKillImageColor(color)
			end
		end
	})

	Shared.UI.KillImageAlpha = KillFX:AddSlider({
		Name = "Kill 1.6 Opacity",
		Min = 0.1,
		Max = 1,
		Default = 0.45,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setKillImageAlpha then
				Shared.Functions.setKillImageAlpha(value)
			end
		end
	})

	Shared.UI.HitSoundToggle = KillFX:AddToggle({
		Name = "Hit Sound",
		Default = true,
		Callback = function(value)
			if Shared.Functions.setHitsoundEnabled then
				Shared.Functions.setHitsoundEnabled(value)
			end
		end
	})

	Shared.UI.HitSoundPreset = KillFX:AddDropdown({
		Name = "Hit Sound Type",
		Values = {
			"bell", "correct", "skeet", "orchestra", "bow", "uwu",
			"tf2", "b8", "basketball", "idk", "orb", "balltap",
			"softbell", "softhit", "soft", "bell2", "tank1",
			"rampage", "headshot", "tank2", "rust"
		},
		Default = "bell",
		Callback = function(value)
			if Shared.Functions.setHitsoundPreset then
				Shared.Functions.setHitsoundPreset(value)
			end
		end
	})

	Shared.UI.HitSoundVolume = KillFX:AddSlider({
		Name = "Hit Sound Volume",
		Min = 0,
		Max = 3,
		Default = 1,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setHitsoundVolume then
				Shared.Functions.setHitsoundVolume(value)
			end
		end
	})

	-- RIGHT COLUMN - World & Tracers
	local WorldSec = Visual:AddSection({
		Name = "WORLD",
		Position = 'right'
	})

	Shared.UI.CustomLighting = WorldSec:AddToggle({
		Name = "Custom Lighting",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setLightingEditEnabled then
				Shared.Functions.setLightingEditEnabled(value)
			end
		end
	})

	Shared.UI.WorldBrightness = WorldSec:AddSlider({
		Name = "Brightness",
		Min = 0,
		Max = 10,
		Default = 2,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setCustomBrightness then
				Shared.Functions.setCustomBrightness(value)
			end
		end
	})

	Shared.UI.WorldAmbient = WorldSec:AddColorPicker({
		Name = "Ambient",
		Default = Color3.fromRGB(128, 128, 128),
		Callback = function(color)
			if Shared.Functions.setCustomAmbient then
				Shared.Functions.setCustomAmbient(color)
			end
		end
	})

	Shared.UI.WorldOutdoorAmbient = WorldSec:AddColorPicker({
		Name = "OutdoorAmbient",
		Default = Color3.fromRGB(128, 128, 128),
		Callback = function(color)
			if Shared.Functions.setCustomOutdoorAmbient then
				Shared.Functions.setCustomOutdoorAmbient(color)
			end
		end
	})

	Shared.UI.TimePreset = WorldSec:AddDropdown({
		Name = "Time Preset",
		Values = {"Default", "Day", "Sunset", "Night"},
		Default = "Default",
		Callback = function(value)
			if Shared.Functions.setTimePreset then
				Shared.Functions.setTimePreset(value)
			end
		end
	})

	Shared.UI.ClockTime = WorldSec:AddSlider({
		Name = "ClockTime",
		Min = 0,
		Max = 24,
		Default = 14,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setCustomClockTime then
				Shared.Functions.setCustomClockTime(value)
			end
		end
	})

	Shared.UI.CustomTime = WorldSec:AddToggle({
		Name = "Custom Time",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setWorldTimeEnabled then
				Shared.Functions.setWorldTimeEnabled(value)
			end
		end
	})

	Shared.UI.SkyPreset = WorldSec:AddDropdown({
		Name = "Sky Preset",
		Values = {"Original", "Blue"},
		Default = "Original",
		Callback = function(value)
			if Shared.Functions.setCustomSkyPreset then
				Shared.Functions.setCustomSkyPreset(value)
			end
		end
	})

	Shared.UI.CustomSky = WorldSec:AddToggle({
		Name = "Custom Sky",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setCustomSkyEnabled then
				Shared.Functions.setCustomSkyEnabled(value)
			end
		end
	})

	-- Tracers Section
	local TracerSec = Visual:AddSection({
		Name = "TRACERS",
		Position = 'right'
	})

	Shared.UI.TracerEnabled = TracerSec:AddToggle({
		Name = "Enabled",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setTracerEnabled then
				Shared.Functions.setTracerEnabled(value)
			end
		end
	})

	Shared.UI.TracerColor = TracerSec:AddColorPicker({
		Name = "Tracer Color",
		Default = Color3.fromRGB(255, 100, 220),
		Callback = function(color)
			if Shared.Functions.setTracerColor then
				Shared.Functions.setTracerColor(color)
			end
		end
	})

	Shared.UI.TracerLifetime = TracerSec:AddSlider({
		Name = "Lifetime (sec)",
		Min = 0.15,
		Max = 2.5,
		Default = 0.45,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setTracerLifetime then
				Shared.Functions.setTracerLifetime(value)
			end
		end
	})

	Shared.UI.TracerWidth = TracerSec:AddSlider({
		Name = "Width Scale",
		Min = 0.02,
		Max = 0.25,
		Default = 0.12,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setTracerWidth then
				Shared.Functions.setTracerWidth(value)
			end
		end
	})
end

-- ============================================
-- MISC MENU
-- ============================================
do
	-- LEFT COLUMN - Post Processing
	local PostProcessing = Misc:AddSection({
		Name = "POST PROCESSING",
		Position = 'left'
	})

	-- Atmosphere
	Shared.UI.AtmoEnabled = PostProcessing:AddToggle({
		Name = "Atmosphere Enabled",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setAtmosphereEnabled then
				Shared.Functions.setAtmosphereEnabled(value)
			end
		end
	})

	Shared.UI.AtmoDensity = PostProcessing:AddSlider({
		Name = "Atmosphere Density",
		Min = 0,
		Max = 1,
		Default = 0.3,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setAtmosphereDensity then
				Shared.Functions.setAtmosphereDensity(value)
			end
		end
	})

	Shared.UI.AtmoOffset = PostProcessing:AddSlider({
		Name = "Atmosphere Offset",
		Min = 0,
		Max = 1,
		Default = 0.25,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setAtmosphereOffset then
				Shared.Functions.setAtmosphereOffset(value)
			end
		end
	})

	Shared.UI.AtmoColor = PostProcessing:AddColorPicker({
		Name = "Atmosphere Color",
		Default = Color3.fromRGB(200, 200, 200),
		Callback = function(color)
			if Shared.Functions.setAtmosphereColor then
				Shared.Functions.setAtmosphereColor(color)
			end
		end
	})

	Shared.UI.AtmoDecay = PostProcessing:AddColorPicker({
		Name = "Atmosphere Decay",
		Default = Color3.fromRGB(128, 128, 128),
		Callback = function(color)
			if Shared.Functions.setAtmosphereDecay then
				Shared.Functions.setAtmosphereDecay(color)
			end
		end
	})

	Shared.UI.AtmoGlare = PostProcessing:AddSlider({
		Name = "Atmosphere Glare",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setAtmosphereGlare then
				Shared.Functions.setAtmosphereGlare(value)
			end
		end
	})

	Shared.UI.AtmoHaze = PostProcessing:AddSlider({
		Name = "Atmosphere Haze",
		Min = 0,
		Max = 10,
		Default = 0.5,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setAtmosphereHaze then
				Shared.Functions.setAtmosphereHaze(value)
			end
		end
	})

	-- Bloom
	Shared.UI.BloomEnabled = PostProcessing:AddToggle({
		Name = "Bloom Enabled",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setBloomEnabled then
				Shared.Functions.setBloomEnabled(value)
			end
		end
	})

	Shared.UI.BloomIntensity = PostProcessing:AddSlider({
		Name = "Bloom Intensity",
		Min = 0,
		Max = 5,
		Default = 2,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setBloomIntensity then
				Shared.Functions.setBloomIntensity(value)
			end
		end
	})

	Shared.UI.BloomSize = PostProcessing:AddSlider({
		Name = "Bloom Size",
		Min = 0,
		Max = 100,
		Default = 56,
		Callback = function(value)
			if Shared.Functions.setBloomSize then
				Shared.Functions.setBloomSize(value)
			end
		end
	})

	Shared.UI.BloomThreshold = PostProcessing:AddSlider({
		Name = "Bloom Threshold",
		Min = 0,
		Max = 5,
		Default = 0.8,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setBloomThreshold then
				Shared.Functions.setBloomThreshold(value)
			end
		end
	})

	-- Color Correction
	Shared.UI.CCEnabled = PostProcessing:AddToggle({
		Name = "ColorCorrection Enabled",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setColorCorrectionEnabled then
				Shared.Functions.setColorCorrectionEnabled(value)
			end
		end
	})

	Shared.UI.CCBrightness = PostProcessing:AddSlider({
		Name = "Brightness",
		Min = -1,
		Max = 1,
		Default = 0,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setColorCorrectionBrightness then
				Shared.Functions.setColorCorrectionBrightness(value)
			end
		end
	})

	Shared.UI.CCContrast = PostProcessing:AddSlider({
		Name = "Contrast",
		Min = -1,
		Max = 1,
		Default = 0,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setColorCorrectionContrast then
				Shared.Functions.setColorCorrectionContrast(value)
			end
		end
	})

	Shared.UI.CCSaturation = PostProcessing:AddSlider({
		Name = "Saturation",
		Min = -1,
		Max = 1,
		Default = 0,
		Round = 2,
		Callback = function(value)
			if Shared.Functions.setColorCorrectionSaturation then
				Shared.Functions.setColorCorrectionSaturation(value)
			end
		end
	})

	Shared.UI.CCTint = PostProcessing:AddColorPicker({
		Name = "Tint Color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			if Shared.Functions.setColorCorrectionTint then
				Shared.Functions.setColorCorrectionTint(color)
			end
		end
	})

	-- CENTER COLUMN - Misc Features
	local MiscFeatures = Misc:AddSection({
		Name = "FEATURES",
		Position = 'center'
	})

	Shared.UI.FakeLagToggle = MiscFeatures:AddToggle({
		Name = "Fake Lag",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setFakeLagEnabled then
				Shared.Functions.setFakeLagEnabled(value)
			end
		end
	})

	Shared.UI.FakeLagAmount = MiscFeatures:AddSlider({
		Name = "Fake Lag Amount",
		Type = "ms",
		Min = 10,
		Max = 300,
		Default = 100,
		Callback = function(value)
			if Shared.Functions.setFakeLagAmount then
				Shared.Functions.setFakeLagAmount(value)
			end
		end
	})

	Shared.UI.FakeLagVariance = MiscFeatures:AddSlider({
		Name = "Fake Lag Variance",
		Type = "ms",
		Min = 0,
		Max = 100,
		Default = 20,
		Callback = function(value)
			if Shared.Functions.setFakeLagVariance then
				Shared.Functions.setFakeLagVariance(value)
			end
		end
	})

	Shared.UI.CrosshairToggle = MiscFeatures:AddToggle({
		Name = "Custom Crosshair",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setCrosshairEnabled then
				Shared.Functions.setCrosshairEnabled(value)
			end
		end
	})

	Shared.UI.CrosshairSize = MiscFeatures:AddSlider({
		Name = "Crosshair Size",
		Min = 5,
		Max = 30,
		Default = 10,
		Callback = function(value)
			if Shared.Functions.setCrosshairSize then
				Shared.Functions.setCrosshairSize(value)
			end
		end
	})

	Shared.UI.CrosshairGap = MiscFeatures:AddSlider({
		Name = "Crosshair Gap",
		Min = 0,
		Max = 20,
		Default = 5,
		Callback = function(value)
			if Shared.Functions.setCrosshairGap then
				Shared.Functions.setCrosshairGap(value)
			end
		end
	})

	Shared.UI.CrosshairColor = MiscFeatures:AddColorPicker({
		Name = "Crosshair Color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			if Shared.Functions.setCrosshairColor then
				Shared.Functions.setCrosshairColor(color)
			end
		end
	})

	Shared.UI.CrosshairDynamic = MiscFeatures:AddToggle({
		Name = "Dynamic Crosshair",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setCrosshairDynamic then
				Shared.Functions.setCrosshairDynamic(value)
			end
		end
	})

	Shared.UI.VelocityToggle = MiscFeatures:AddToggle({
		Name = "Velocity Display",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setVelocityEnabled then
				Shared.Functions.setVelocityEnabled(value)
			end
		end
	})

	Shared.UI.FOVToggle = MiscFeatures:AddToggle({
		Name = "Custom FOV",
		Default = false,
		Callback = function(value)
			if Shared.Functions.setFOVEnabled then
				Shared.Functions.setFOVEnabled(value)
			end
		end
	})

	Shared.UI.FOVSlider = MiscFeatures:AddSlider({
		Name = "FOV Value",
		Min = 30,
		Max = 120,
		Default = 70,
		Callback = function(value)
			if Shared.Functions.setCustomFOV then
				Shared.Functions.setCustomFOV(value)
			end
		end
	})

	-- RIGHT COLUMN - Config System
	local ConfigSection = Misc:AddSection({
		Name = "CONFIG",
		Position = "right"
	})

	ConfigSection:AddDropdown({
		Name = "Select Config",
		Values = {"default"},
		Default = "default",
		Callback = function(value)
			if Shared.Functions.selectConfig then
				Shared.Functions.selectConfig(value)
			end
		end
	})

	ConfigSection:AddButton({
		Name = "New Config (Auto)",
		Callback = function()
			if Shared.Functions.createNewConfig then
				Shared.Functions.createNewConfig()
			end
		end
	})

	ConfigSection:AddButton({
		Name = "Save Config",
		Callback = function()
			if Shared.Functions.saveCurrentConfig then
				Shared.Functions.saveCurrentConfig()
			end
		end
	})

	ConfigSection:AddButton({
		Name = "Load Config",
		Callback = function()
			if Shared.Functions.loadCurrentConfig then
				Shared.Functions.loadCurrentConfig()
			end
		end
	})

	ConfigSection:AddButton({
		Name = "Delete Config",
		Callback = function()
			if Shared.Functions.deleteCurrentConfig then
				Shared.Functions.deleteCurrentConfig()
			end
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
end

print("✅ UI Module Loaded")
