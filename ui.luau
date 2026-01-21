local Shared = _G.NemesisShared
local Fatality = Shared.Fatality
local Notification = Shared.Notification

Shared.UI = {}

local Window = Fatality.new({
	Name = "Nemesis",
	Expire = "never",
})

local Rage = Window:AddMenu({ Name = "RAGE", Icon = "skull" })
local Visual = Window:AddMenu({ Name = "VISUAL", Icon = "eye" })
local Misc = Window:AddMenu({ Name = "MISC", Icon = "settings" })

-- =======================
-- RAGE
-- =======================
do
	local Weapon = Rage:AddSection({ Name = "WEAPON", Position = "left" })
	local Extra  = Rage:AddSection({ Name = "EXTRA", Position = "center" })
	local General = Rage:AddSection({ Name = "GENERAL", Position = "right" })

	Shared.UI.HitchanceToggle = Weapon:AddToggle({
		Name = "Hitchance",
		Callback = function(v)
			Shared.Functions.setHitchanceEnabled(v)
		end
	})

	Shared.UI.HitchanceSlider = Weapon:AddSlider({
		Name = "Hit-chance",
		Type = "%",
		Min = 0, Max = 100, Default = 100,
		Callback = function(v)
			Shared.Functions.setHitchance(v)
		end
	})

	Shared.UI.MinDamageToggle = Weapon:AddToggle({
		Name = "Min-damage",
		Callback = function(v)
			Shared.Functions.setMinDamageEnabled(v)
		end
	})

	Shared.UI.MinDamageSlider = Weapon:AddSlider({
		Name = "Min-damage value",
		Type = " HP",
		Min = 0, Max = 216, Default = 0,
		Callback = function(v)
			Shared.Functions.setMinDamageValue(v)
		end
	})

	Shared.UI.HitboxesDropdown = Weapon:AddDropdown({
		Name = "Hitboxes",
		Values = {"Head","Body","Arms","Legs"},
		Default = "Head",
		Callback = function(v)
			Shared.Functions.setHitpart(v)
		end
	})

	Shared.UI.NoSpreadToggle = Extra:AddToggle({
		Name = "No Spread (Airshot)",
		Callback = function(v)
			Shared.Functions.setNoSpread(v)
		end
	})

	Shared.UI.AutoEquipToggle = Extra:AddToggle({
		Name = "Auto Equip SSG",
		Callback = function(v)
			Shared.Functions.setAutoEquip(v)
		end
	})

	Shared.UI.MaxDistanceSlider = Extra:AddSlider({
		Name = "Max Distance",
		Type = " studs",
		Min = 100, Max = 2000, Default = 1000,
		Callback = function(v)
			Shared.Functions.setMaxDistance(v)
		end
	})

	Shared.UI.AimbotToggle = General:AddToggle({
		Name = "Aimbot",
		Risky = true,
		Callback = function(v)
			Shared.Functions.setRageEnabled(v)
		end
	})

	Shared.UI.AutoShootToggle = General:AddToggle({
		Name = "Autoshoot",
		Callback = function(v)
			Shared.Functions.setAutoShoot(v)
		end
	})

	Shared.UI.PredictionToggle = General:AddToggle({
		Name = "Prediction",
		Callback = function(v)
			Shared.Functions.setPredictionEnabled(v)
		end
	})

	Shared.UI.PredStrengthSlider = General:AddSlider({
		Name = "Prediction Strength",
		Type = "x",
		Min = 0, Max = 3, Default = 1.2, Round = 1,
		Callback = function(v)
			Shared.Functions.setPredictionStrength(v)
		end
	})
end

-- =======================
-- VISUAL
-- =======================
do
	local Main = Visual:AddSection({ Name = "MAIN", Position = "left" })

	Shared.UI.HitlogsToggle = Main:AddToggle({
		Name = "HitLogs",
		Callback = function(v)
			Shared.Functions.setHitlogEnabled(v)
		end
	})

	Shared.UI.BacktrackGhostToggle = Main:AddToggle({
		Name = "Backtrack Ghost",
		Callback = function(v)
			Shared.Functions.setBacktrackGhostEnabled(v)
		end
	})

	Shared.UI.BacktrackGhostColor = Main:AddColorPicker({
		Name = "Backtrack Color",
		Default = Color3.fromRGB(80,160,255),
		Callback = function(c)
			Shared.Functions.setBacktrackGhostColor(c)
		end
	})

	Shared.UI.BacktrackGhostDuration = Main:AddSlider({
		Name = "Ghost Duration",
		Min = 0.1, Max = 2, Default = 0.3, Round = 2,
		Callback = function(v)
			Shared.Functions.setBacktrackGhostDuration(v)
		end
	})

	Shared.UI.OffscreenToggle = Main:AddToggle({
		Name = "Arrows",
		Callback = function(v)
			Shared.Functions.setOffscreenEnabled(v)
		end
	})

	Shared.UI.OffscreenColor = Main:AddColorPicker({
		Name = "Arrow Color",
		Default = Color3.fromRGB(255,80,80),
		Callback = function(c)
			Shared.Functions.setOffscreenColor(c)
		end
	})

	local KillFX = Visual:AddSection({ Name = "KILL EFFECTS", Position = "center" })

	Shared.UI.KillFXEnabled = KillFX:AddToggle({
		Name = "Kill Effect",
		Callback = function(v)
			Shared.Functions.setKillFXEnabled(v)
		end
	})

	Shared.UI.KillFXType = KillFX:AddDropdown({
		Name = "Effect Type",
		Values = {"ImpactFX","CustomFX"},
		Default = "ImpactFX",
		Callback = function(v)
			Shared.Functions.setKillFXType(v)
		end
	})

	Shared.UI.KillFXColor = KillFX:AddColorPicker({
		Name = "Particle Color",
		Default = Color3.fromRGB(80,160,255),
		Callback = function(c)
			Shared.Functions.setKillFXColor(c)
		end
	})

	Shared.UI.KillFXLightColor = KillFX:AddColorPicker({
		Name = "Light Color",
		Default = Color3.fromRGB(120,180,255),
		Callback = function(c)
			Shared.Functions.setKillFXLightColor(c)
		end
	})

	Shared.UI.KillFXDuration = KillFX:AddSlider({
		Name = "Effect Duration",
		Min = 0.05, Max = 1.5, Default = 0.25, Round = 2,
		Callback = function(v)
			Shared.Functions.setKillFXDuration(v)
		end
	})

	Shared.UI.KillFXLightRange = KillFX:AddSlider({
		Name = "Light Range",
		Min = 5, Max = 40, Default = 15,
		Callback = function(v)
			Shared.Functions.setKillFXLightRange(v)
		end
	})

	Shared.UI.KillImageEnabled = KillFX:AddToggle({
		Name = "Kill 1.6 Effect",
		Callback = function(v)
			Shared.Functions.setKillImageEnabled(v)
		end
	})

	Shared.UI.KillImageColor = KillFX:AddColorPicker({
		Name = "Kill 1.6 Color",
		Default = Color3.fromRGB(80,160,255),
		Callback = function(c)
			Shared.Functions.setKillImageColor(c)
		end
	})

	Shared.UI.KillImageAlpha = KillFX:AddSlider({
		Name = "Kill 1.6 Opacity",
		Min = 0.1, Max = 1, Default = 0.45, Round = 2,
		Callback = function(v)
			Shared.Functions.setKillImageAlpha(v)
		end
	})
end

-- =======================
-- MISC
-- =======================
do
	local Post = Misc:AddSection({ Name = "POST PROCESSING", Position = "left" })

	Shared.UI.AtmoEnabled = Post:AddToggle({
		Name = "Atmosphere Enabled",
		Callback = function(v)
			Shared.Functions.setAtmosphereEnabled(v)
		end
	})

	Shared.UI.AtmoDensity = Post:AddSlider({
		Name = "Atmosphere Density",
		Min = 0, Max = 1, Default = 0.3, Round = 2,
		Callback = function(v)
			Shared.Functions.setAtmosphereDensity(v)
		end
	})

	Shared.UI.AtmoOffset = Post:AddSlider({
		Name = "Atmosphere Offset",
		Min = 0, Max = 1, Default = 0.25, Round = 2,
		Callback = function(v)
			Shared.Functions.setAtmosphereOffset(v)
		end
	})

	Shared.UI.AtmoColor = Post:AddColorPicker({
		Name = "Atmosphere Color",
		Default = Color3.fromRGB(200,200,200),
		Callback = function(c)
			Shared.Functions.setAtmosphereColor(c)
		end
	})

	Shared.UI.AtmoDecay = Post:AddColorPicker({
		Name = "Atmosphere Decay",
		Default = Color3.fromRGB(128,128,128),
		Callback = function(c)
			Shared.Functions.setAtmosphereDecay(c)
		end
	})

	Shared.UI.AtmoGlare = Post:AddSlider({
		Name = "Atmosphere Glare",
		Min = 0, Max = 1, Default = 0.5, Round = 2,
		Callback = function(v)
			Shared.Functions.setAtmosphereGlare(v)
		end
	})

	Shared.UI.AtmoHaze = Post:AddSlider({
		Name = "Atmosphere Haze",
		Min = 0, Max = 10, Default = 0.5, Round = 2,
		Callback = function(v)
			Shared.Functions.setAtmosphereHaze(v)
		end
	})

	local Config = Misc:AddSection({ Name = "CONFIG", Position = "center" })

	Config:AddDropdown({
		Name = "Select Config",
		Values = {"default"},
		Default = "default",
		Callback = function(v)
			Shared.Functions.selectConfig(v)
		end
	})

	Config:AddButton({ Name = "Save Config", Callback = Shared.Functions.saveCurrentConfig })
	Config:AddButton({ Name = "Load Config", Callback = Shared.Functions.loadCurrentConfig })
	Config:AddButton({ Name = "Delete Config", Callback = Shared.Functions.deleteCurrentConfig })
end

print("✅ UI Module Loaded (1:1 original compatible)")
