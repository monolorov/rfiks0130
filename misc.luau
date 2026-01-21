local Lighting = game:GetService("Lighting")

local Shared = _G.NemesisShared or {}
_G.NemesisShared = Shared

Shared.Misc = Shared.Misc or {}
local Misc = Shared.Misc

local function cloneFirst(className)
	local inst = Lighting:FindFirstChildOfClass(className)
	if not inst then return nil end
	local c = inst:Clone()
	c.Name = "NemesisOriginal_" .. className
	return c
end

local ORIGINAL = {
	Atmosphere = cloneFirst("Atmosphere"),
	BloomEffect = cloneFirst("BloomEffect"),
	ColorCorrectionEffect = cloneFirst("ColorCorrectionEffect"),
}

local function wipe(className)
	for _, v in ipairs(Lighting:GetChildren()) do
		if v.ClassName == className then
			v:Destroy()
		end
	end
end

local function applyEffect(className, enabled, apply)
	if enabled then
		wipe(className)
		local fx = Instance.new(className)
		fx.Name = "Nemesis_" .. className
		fx.Parent = Lighting
		apply(fx)
	else
		wipe(className)
		local orig = ORIGINAL[className]
		if orig then
			orig:Clone().Parent = Lighting
		end
	end
end

Misc.State = {
	Atmosphere = {
		Enabled = false,
		Density = 0.3,
		Offset = 0.25,
		Color = Color3.fromRGB(200,200,200),
		Decay = Color3.fromRGB(128,128,128),
		Glare = 0.5,
		Haze = 0.5
	},
	Bloom = {
		Enabled = false,
		Intensity = 0.5,
		Size = 24,
		Threshold = 2
	},
	ColorCorrection = {
		Enabled = false,
		Brightness = 0,
		Contrast = 0,
		Saturation = 0,
		Tint = Color3.fromRGB(255,255,255)
	}
}

function Misc.ApplyAtmosphere()
	local s = Misc.State.Atmosphere
	applyEffect("Atmosphere", s.Enabled, function(a)
		a.Density = s.Density
		a.Offset = s.Offset
		a.Color = s.Color
		a.Decay = s.Decay
		a.Glare = s.Glare
		a.Haze = s.Haze
	end)
end

function Misc.ApplyBloom()
	local s = Misc.State.Bloom
	applyEffect("BloomEffect", s.Enabled, function(b)
		b.Enabled = true
		b.Intensity = s.Intensity
		b.Size = s.Size
		b.Threshold = s.Threshold
	end)
end

function Misc.ApplyColorCorrection()
	local s = Misc.State.ColorCorrection
	applyEffect("ColorCorrectionEffect", s.Enabled, function(c)
		c.Brightness = s.Brightness
		c.Contrast = s.Contrast
		c.Saturation = s.Saturation
		c.TintColor = s.Tint
	end)
end

function Misc.ApplyAll()
	Misc.ApplyAtmosphere()
	Misc.ApplyBloom()
	Misc.ApplyColorCorrection()
end

function Misc.GetConfig()
	local function c(c3)
		return {math.floor(c3.R*255), math.floor(c3.G*255), math.floor(c3.B*255)}
	end
	return {
		Atmosphere = {
			Enabled = Misc.State.Atmosphere.Enabled,
			Density = Misc.State.Atmosphere.Density,
			Offset = Misc.State.Atmosphere.Offset,
			Color = c(Misc.State.Atmosphere.Color),
			Decay = c(Misc.State.Atmosphere.Decay),
			Glare = Misc.State.Atmosphere.Glare,
			Haze = Misc.State.Atmosphere.Haze
		},
		Bloom = {
			Enabled = Misc.State.Bloom.Enabled,
			Intensity = Misc.State.Bloom.Intensity,
			Size = Misc.State.Bloom.Size,
			Threshold = Misc.State.Bloom.Threshold
		},
		ColorCorrection = {
			Enabled = Misc.State.ColorCorrection.Enabled,
			Brightness = Misc.State.ColorCorrection.Brightness,
			Contrast = Misc.State.ColorCorrection.Contrast,
			Saturation = Misc.State.ColorCorrection.Saturation,
			Tint = c(Misc.State.ColorCorrection.Tint)
		}
	}
end

function Misc.ApplyConfig(cfg)
	local function toColor(t)
		if type(t) == "table" then
			return Color3.fromRGB(t[1], t[2], t[3])
		end
	end

	if cfg.Atmosphere then
		local s = Misc.State.Atmosphere
		for k,v in pairs(cfg.Atmosphere) do
			if k == "Color" or k == "Decay" then
				s[k] = toColor(v)
			else
				s[k] = v
			end
		end
	end

	if cfg.Bloom then
		for k,v in pairs(cfg.Bloom) do
			Misc.State.Bloom[k] = v
		end
	end

	if cfg.ColorCorrection then
		local s = Misc.State.ColorCorrection
		for k,v in pairs(cfg.ColorCorrection) do
			if k == "Tint" then
				s.Tint = toColor(v)
			else
				s[k] = v
			end
		end
	end

	Misc.ApplyAll()
end

return Misc
