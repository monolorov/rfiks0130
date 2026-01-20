local Shared = _G.NemesisShared
local S = Shared.Settings
local RunService = Shared.Services.RunService
local Camera = workspace.CurrentCamera
local player = Shared.Player
local guiParent = Shared.GuiParent

local arrows = {}
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.Parent = guiParent

local function enemy(p)
	if player.Team and p.Team then
		return player.Team ~= p.Team
	end
	return true
end

local function makeArrow(p)
	local i = Instance.new("ImageLabel")
	i.Size = UDim2.fromOffset(26,26)
	i.AnchorPoint = Vector2.new(0.5,0.5)
	i.BackgroundTransparency = 1
	i.Image = "rbxassetid://121771059734689"
	i.Visible = false
	i.Parent = gui
	arrows[p] = i
end

for _,p in ipairs(game.Players:GetPlayers()) do
	if p ~= player and enemy(p) then
		makeArrow(p)
	end
end

RunService.RenderStepped:Connect(function()
	if not S.OFFSCREEN_ENABLED then
		for _,a in pairs(arrows) do a.Visible = false end
		return
	end

	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X/2, vp.Y/2)

	for plr,a in pairs(arrows) do
		local c = plr.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if not hrp then a.Visible=false continue end

		local pos,ons = Camera:WorldToViewportPoint(hrp.Position)
		if ons then a.Visible=false continue end

		local dir = (hrp.Position - Camera.CFrame.Position).Unit
		local angle = math.atan2(dir:Dot(Camera.CFrame.RightVector), dir:Dot(Camera.CFrame.LookVector))
		local r = 650

		local p = center + Vector2.new(math.sin(angle), -math.cos(angle)) * r
		a.Position = UDim2.fromOffset(p.X,p.Y)
		a.Rotation = math.deg(angle)+180
		a.Visible = true
	end
end)

print("VISUALS LOADED")
