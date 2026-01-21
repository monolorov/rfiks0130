local Lighting = game:GetService("Lighting")

local World = {}
World.__index = World

function World.new()
	local self = setmetatable({}, World)

	self.ORIGINAL_LIGHTING = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ClockTime = Lighting.ClockTime
	}

	self.LIGHTING_EDIT_ENABLED = false
	self.CUSTOM_BRIGHTNESS = Lighting.Brightness
	self.CUSTOM_AMBIENT = Lighting.Ambient
	self.CUSTOM_OUTDOOR_AMBIENT = Lighting.OutdoorAmbient

	self.WORLD_TIME_ENABLED = false
	self.CUSTOM_CLOCKTIME = Lighting.ClockTime
	self.TIME_PRESET = "Default"
	self.TIME_PRESETS = {
		Default = nil,
		Day = 14,
		Sunset = 18.5,
		Night = 0
	}

	self.CUSTOM_SKY_ENABLED = false
	self.CUSTOM_SKY_PRESET = "Original"

	self.SKY_PRESETS = {
		Original = {
			SkyboxBk = "rbxassetid://148345460",
			SkyboxDn = "rbxassetid://148345469",
			SkyboxFt = "rbxassetid://148345455",
			SkyboxLf = "rbxassetid://148345446",
			SkyboxRt = "rbxassetid://148345440",
			SkyboxUp = "rbxassetid://148345466",
			SunTextureId = "rbxassetid://1345009717",
			MoonTextureId = "rbxasset://sky/moon.jpg",
			StarCount = 3000
		},
		Blue = {
			SkyboxBk = "rbxassetid://124106120273678",
			SkyboxDn = "rbxassetid://72406028001064",
			SkyboxFt = "rbxassetid://139238600782726",
			SkyboxLf = "rbxassetid://139363840022859",
			SkyboxRt = "rbxassetid://122628916393316",
			SkyboxUp = "rbxassetid://104354476381566",
			SunTextureId = "",
			MoonTextureId = "",
			StarCount = 3000
		}
	}

	local s = Lighting:FindFirstChildOfClass("Sky")
	if s then
		self.ORIGINAL_SKY = s:Clone()
	end

	return self
end

function World:applyLighting()
	if self.LIGHTING_EDIT_ENABLED then
		Lighting.Brightness = self.CUSTOM_BRIGHTNESS
		Lighting.Ambient = self.CUSTOM_AMBIENT
		Lighting.OutdoorAmbient = self.CUSTOM_OUTDOOR_AMBIENT
	else
		Lighting.Brightness = self.ORIGINAL_LIGHTING.Brightness
		Lighting.Ambient = self.ORIGINAL_LIGHTING.Ambient
		Lighting.OutdoorAmbient = self.ORIGINAL_LIGHTING.OutdoorAmbient
	end
end

function World:applyTime()
	if self.WORLD_TIME_ENABLED then
		local preset = self.TIME_PRESETS[self.TIME_PRESET]
		if preset ~= nil then
			Lighting.ClockTime = preset
		else
			Lighting.ClockTime = self.CUSTOM_CLOCKTIME
		end
	else
		Lighting.ClockTime = self.ORIGINAL_LIGHTING.ClockTime
	end
end

function World:wipeSky()
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Sky") then
			v:Destroy()
		end
	end
end

function World:buildSky(name)
	local data = self.SKY_PRESETS[name]
	if not data then return end

	local sky = Instance.new("Sky")
	for k, v in pairs(data) do
		sky[k] = v
	end
	sky.Name = "NemesisSky"
	sky.Parent = Lighting
end

function World:applySky()
	self:wipeSky()
	if self.CUSTOM_SKY_ENABLED then
		self:buildSky(self.CUSTOM_SKY_PRESET)
	else
		if self.ORIGINAL_SKY then
			self.ORIGINAL_SKY:Clone().Parent = Lighting
		end
	end
end

function World:SetLightingEnabled(v)
	self.LIGHTING_EDIT_ENABLED = v
	self:applyLighting()
end

function World:SetBrightness(v)
	self.CUSTOM_BRIGHTNESS = v
	self:applyLighting()
end

function World:SetAmbient(v)
	self.CUSTOM_AMBIENT = v
	self:applyLighting()
end

function World:SetOutdoorAmbient(v)
	self.CUSTOM_OUTDOOR_AMBIENT = v
	self:applyLighting()
end

function World:SetTimeEnabled(v)
	self.WORLD_TIME_ENABLED = v
	self:applyTime()
end

function World:SetClockTime(v)
	self.CUSTOM_CLOCKTIME = v
	self:applyTime()
end

function World:SetTimePreset(v)
	self.TIME_PRESET = v
	self:applyTime()
end

function World:SetSkyEnabled(v)
	self.CUSTOM_SKY_ENABLED = v
	self:applySky()
end

function World:SetSkyPreset(v)
	self.CUSTOM_SKY_PRESET = v
	self:applySky()
end

function World:Export()
	return {
		LIGHTING_EDIT_ENABLED = self.LIGHTING_EDIT_ENABLED,
		CUSTOM_BRIGHTNESS = self.CUSTOM_BRIGHTNESS,
		CUSTOM_AMBIENT = {self.CUSTOM_AMBIENT.R * 255, self.CUSTOM_AMBIENT.G * 255, self.CUSTOM_AMBIENT.B * 255},
		CUSTOM_OUTDOOR_AMBIENT = {self.CUSTOM_OUTDOOR_AMBIENT.R * 255, self.CUSTOM_OUTDOOR_AMBIENT.G * 255, self.CUSTOM_OUTDOOR_AMBIENT.B * 255},
		WORLD_TIME_ENABLED = self.WORLD_TIME_ENABLED,
		CUSTOM_CLOCKTIME = self.CUSTOM_CLOCKTIME,
		TIME_PRESET = self.TIME_PRESET,
		CUSTOM_SKY_ENABLED = self.CUSTOM_SKY_ENABLED,
		CUSTOM_SKY_PRESET = self.CUSTOM_SKY_PRESET
	}
end

function World:Import(t)
	local function c(a)
		return Color3.fromRGB(a[1], a[2], a[3])
	end

	if t.LIGHTING_EDIT_ENABLED ~= nil then self.LIGHTING_EDIT_ENABLED = t.LIGHTING_EDIT_ENABLED end
	if t.CUSTOM_BRIGHTNESS then self.CUSTOM_BRIGHTNESS = t.CUSTOM_BRIGHTNESS end
	if t.CUSTOM_AMBIENT then self.CUSTOM_AMBIENT = c(t.CUSTOM_AMBIENT) end
	if t.CUSTOM_OUTDOOR_AMBIENT then self.CUSTOM_OUTDOOR_AMBIENT = c(t.CUSTOM_OUTDOOR_AMBIENT) end
	if t.WORLD_TIME_ENABLED ~= nil then self.WORLD_TIME_ENABLED = t.WORLD_TIME_ENABLED end
	if t.CUSTOM_CLOCKTIME then self.CUSTOM_CLOCKTIME = t.CUSTOM_CLOCKTIME end
	if t.TIME_PRESET then self.TIME_PRESET = t.TIME_PRESET end
	if t.CUSTOM_SKY_ENABLED ~= nil then self.CUSTOM_SKY_ENABLED = t.CUSTOM_SKY_ENABLED end
	if t.CUSTOM_SKY_PRESET then self.CUSTOM_SKY_PRESET = t.CUSTOM_SKY_PRESET end

	self:applyLighting()
	self:applyTime()
	self:applySky()
end

return World
