-- RAGE MODULE
local RageModule = {}
RageModule.__index = RageModule

function RageModule.new(config)
	local self = setmetatable({}, RageModule)
	
	-- Services
	self.player = config.Player
	self.Players = config.Services.Players
	self.RunService = config.Services.RunService
	self.Workspace = config.Services.Workspace
	self.ReplicatedStorage = config.Services.ReplicatedStorage
	self.Notification = config.Notification
	self.Visuals = config.Visuals
	
	-- Settings
	self.RAGE_ENABLED = false
	self.RAGE_HITPART = "Head"
	self.RAGE_HITCHANCE = 100
	self.RAGE_HITCHANCE_ENABLED = false
	self.RAGE_AUTOSHOOT = false
	self.RAGE_NOSPREAD = false
	self.AIRSHOT_ACTIVE = false
	self.AUTO_EQUIP_SSG = false
	self.MAX_DISTANCE = 1000
	
	self.PREDICTION_ENABLED = true
	self.PREDICTION_STRENGTH = 1.2
	self.BULLET_SPEED = 800
	
	self.MIN_DAMAGE_ENABLED = false
	self.MIN_DAMAGE_VALUE = 0
	self.BASE_DAMAGE = 54
	
	-- Internal state
	self.lastShot = 0
	self.FIRE_RATE = 0.1
	self.FIRE_RATE_AWP = 1.2
	self.ping = 0
	self.lastPingUpdate = 0
	self.PING_UPDATE_RATE = 1
	self.activePlayers = {}
	self.lastPlayerListUpdate = 0
	self.PLAYER_LIST_UPDATE_RATE = 0.5
	self.autoEquippedOnce = false
	
	self.BODY_PART_MULTIPLIERS = {
		["Head"] = 4.0,
		["UpperTorso"] = 1.0,
		["LowerTorso"] = 1.0,
		["Torso"] = 1.0,
		["HumanoidRootPart"] = 1.0,
		["LeftUpperArm"] = 0.75,
		["LeftLowerArm"] = 0.75,
		["LeftHand"] = 0.75,
		["RightUpperArm"] = 0.75,
		["RightLowerArm"] = 0.75,
		["RightHand"] = 0.75,
		["LeftUpperLeg"] = 0.6,
		["LeftLowerLeg"] = 0.6,
		["LeftFoot"] = 0.6,
		["RightUpperLeg"] = 0.6,
		["RightLowerLeg"] = 0.6,
		["RightFoot"] = 0.6,
		["Left Leg"] = 0.6,
		["Right Leg"] = 0.6,
	}
	
	self.MIN_DAMAGE_PRIORITY = {
		{name = "Legs", parts = {"LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "Left Leg", "Right Leg"}, multiplier = 0.6},
		{name = "Arms", parts = {"LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand", "Left Arm", "Right Arm"}, multiplier = 0.75},
		{name = "Body", parts = {"UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart"}, multiplier = 1.0},
		{name = "Head", parts = {"Head"}, multiplier = 4.0},
	}
	
	return self
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
function RageModule:IsAlive()
	local char = self.player.Character
	if not char then return false end
	local hum = char:FindFirstChild("Humanoid")
	return hum and hum.Health > 0
end

function RageModule:IsEnemy(target)
	if self.player.Team and target.Team then
		return self.player.Team ~= target.Team
	end
	return true
end

function RageModule:IsInAir()
	local char = self.player.Character
	if not char then return true end

	local hum = char:FindFirstChild("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return true end

	if hum.FloorMaterial == Enum.Material.Air then
		return true
	end

	if math.abs(hrp.AssemblyLinearVelocity.Y) > 2 then
		return true
	end

	return false
end

function RageModule:GetGun()
	local char = self.player.Character
	if not char then return nil end

	for _, item in pairs(char:GetChildren()) do
		if item:IsA("Tool") then
			local remotes = item:FindFirstChild("Remotes")
			if remotes then
				local fireShot = remotes:FindFirstChild("FireShot")
				if fireShot then
					return {type = "AWP", fireShot = fireShot, fireRate = self.FIRE_RATE_AWP}
				end

				local castRay = remotes:FindFirstChild("CastRay")
				local hole = item:FindFirstChild("Hole")
				if castRay and hole then
					return {type = "CastRay", castRay = castRay, hole = hole, fireRate = self.FIRE_RATE}
				end
			end
		end
	end

	return nil
end

function RageModule:CalculatePotentialDamage(partName, distance)
	local multiplier = self.BODY_PART_MULTIPLIERS[partName] or 0.5
	local damage = self.BASE_DAMAGE * multiplier
	if distance > 300 then
		damage = damage * 0.3
	elseif distance > 200 then
		damage = damage * 0.5
	elseif distance > 100 then
		damage = damage * 0.8
	end
	return math.floor(damage)
end

function RageModule:GetTargetPart(char, distance)
	if self.AIRSHOT_ACTIVE then
		return char:FindFirstChild("Head")
	end
	
	if self.MIN_DAMAGE_ENABLED then
		for _, priorityGroup in ipairs(self.MIN_DAMAGE_PRIORITY) do
			for _, partName in ipairs(priorityGroup.parts) do
				local part = char:FindFirstChild(partName)
				if part then
					local damage = self:CalculatePotentialDamage(partName, distance)
					if damage >= self.MIN_DAMAGE_VALUE then
						return part
					end
				end
			end
		end
		return nil
	end

	if self.RAGE_HITPART == "Head" then
		return char:FindFirstChild("Head")
	end
	if self.RAGE_HITPART == "Body" then
		return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
	end
	if self.RAGE_HITPART == "Arms" then
		return char:FindFirstChild("RightUpperArm") or char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Right Arm") or char:FindFirstChild("Left Arm")
	end
	if self.RAGE_HITPART == "Legs" then
		return char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Right Leg") or char:FindFirstChild("Left Leg")
	end
	return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

function RageModule:IsPartVisible(targetPart, targetChar)
	if not targetPart or not targetPart.Parent then return false end
	if not self:IsAlive() then return false end

	local myChar = self.player.Character
	if not myChar then return false end
	local myHead = myChar:FindFirstChild("Head")
	if not myHead then return false end

	local origin = myHead.Position
	local targetPos = targetPart.Position
	local dir = targetPos - origin
	local dist = dir.Magnitude

	if dist < 0.1 then return true end
	if dist > self.MAX_DISTANCE then return false end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude    
	params.FilterDescendantsInstances = {myChar}
	params.IgnoreWater = true

	local unit = dir.Unit
	local curOrigin = origin

	for _ = 1, 6 do
		local res = self.Workspace:Raycast(curOrigin, targetPos - curOrigin, params)

		if not res then return true end

		local hit = res.Instance

		if hit and hit:IsDescendantOf(targetChar) then
			return true
		end

		if hit then
			local name = hit.Name:lower()
			local isHamik = name:find("hamik") or name:find("paletka")
			local isSoft = hit.Transparency > 0.3 or hit.CanCollide == false or hit.CanQuery == false

			if isHamik or isSoft then
				curOrigin = res.Position + unit * 0.2
				continue
			end
		end

		return false
	end

	return false
end

function RageModule:PredictPosition(part, rootPart)
	if not self.PREDICTION_ENABLED or not rootPart then return part.Position end

	local velocity = rootPart.AssemblyLinearVelocity or rootPart.Velocity or Vector3.new()
	if velocity.Magnitude < 2 then return part.Position end

	local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
	local distance = (part.Position - self.Workspace.CurrentCamera.CFrame.Position).Magnitude
	local travelTime = distance / self.BULLET_SPEED
	local pingTime = self.ping / 2
	local dynamicTime = math.clamp(pingTime + travelTime, 0.05, 0.22)

	local predictedPos = part.Position + (horizontalVelocity * dynamicTime * self.PREDICTION_STRENGTH)

	return predictedPos
end

function RageModule:UpdateActivePlayersList()
	table.clear(self.activePlayers)
	for _, targetPlayer in ipairs(self.Players:GetPlayers()) do
		if targetPlayer ~= self.player and self:IsEnemy(targetPlayer) then
			local targetChar = targetPlayer.Character
			if targetChar then
				local hum = targetChar:FindFirstChild("Humanoid")
				local rootPart = targetChar:FindFirstChild("HumanoidRootPart")
				if hum and hum.Health > 0 and rootPart then
					table.insert(self.activePlayers, {
						player = targetPlayer,
						character = targetChar,
						humanoid = hum,
						rootPart = rootPart
					})
				end
			end
		end
	end
end

function RageModule:FindTarget()
	if not self:IsAlive() then return nil end

	local char = self.player.Character
	local myHead = char and char:FindFirstChild("Head")
	if not myHead then return nil end

	local now = tick()
	if now - self.lastPlayerListUpdate >= self.PLAYER_LIST_UPDATE_RATE then
		self.lastPlayerListUpdate = now
		self:UpdateActivePlayersList()
	end

	local bestTarget
	local bestDist = self.MAX_DISTANCE

	for _, data in ipairs(self.activePlayers) do
		if not data.humanoid or data.humanoid.Health <= 0 then continue end
		if not data.rootPart or not data.rootPart.Parent then continue end

		local dist = (data.rootPart.Position - myHead.Position).Magnitude
		if dist > bestDist then continue end

		local part = self:GetTargetPart(data.character, dist)
		if not part then continue end

		if not self:IsPartVisible(part, data.character) then
			continue
		end

		bestDist = dist
		bestTarget = {
			player = data.player,
			character = data.character,
			targetPart = part,
			rootPart = data.rootPart,
			distance = dist
		}
	end

	return bestTarget
end

function RageModule:EquipSSGOnce()
	if not self.AUTO_EQUIP_SSG then return end
	if self.autoEquippedOnce then return end

	local char = self.player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local currentTool = char:FindFirstChildOfClass("Tool")
	if currentTool and currentTool.Name == "SSG-08" then
		self.autoEquippedOnce = true
		return
	end

	local backpack = self.player:FindFirstChildOfClass("Backpack")
	if not backpack then return end

	local tool = backpack:FindFirstChild("SSG-08")
	if tool and tool:IsA("Tool") then
		hum:EquipTool(tool)
		self.autoEquippedOnce = true
		self.Notification:Notify({
			Title = "Auto Equip",
			Content = "Equipped SSG-08",
			Duration = 2,
			Icon = "check"
		})
	end
end

-- ============================================
-- MAIN LOOP
-- ============================================
function RageModule:Start()
	self.player.CharacterAdded:Connect(function()
		self.autoEquippedOnce = false
	end)

	self.RunService.Heartbeat:Connect(function()
		self:EquipSSGOnce()

		if not self.RAGE_ENABLED then return end
		if not self:IsAlive() then return end

		local inAir = self:IsInAir()
		self.AIRSHOT_ACTIVE = self.RAGE_NOSPREAD and inAir

		if self.RAGE_AUTOSHOOT and inAir and not self.RAGE_NOSPREAD then
			return
		end

		local gun = self:GetGun()
		if not gun then return end

		if not self.RAGE_AUTOSHOOT then
			return
		end

		local currentTime = tick()
		if currentTime - self.lastShot < gun.fireRate then return end

		if currentTime - self.lastPingUpdate >= self.PING_UPDATE_RATE then
			self.lastPingUpdate = currentTime
			self.ping = self.player:GetNetworkPing()
		end

		local target = self:FindTarget()
		if not target then return end

		if self.RAGE_HITCHANCE_ENABLED and not self.AIRSHOT_ACTIVE then
			local roll = math.random(1, 100)
			if roll > self.RAGE_HITCHANCE then
				return
			end
		end

		local char = self.player.Character
		local head = char and char:FindFirstChild("Head")
		if not head then return end

		local targetPos = self.PREDICTION_ENABLED
			and self:PredictPosition(target.targetPart, target.rootPart)
			or target.targetPart.Position

		if gun.type == "AWP" then
			local origin = head.Position
			local dirVec = targetPos - origin
			if dirVec.Magnitude < 0.01 then return end

			local direction = dirVec.Unit
			local ok = pcall(function()
				gun.fireShot:FireServer(origin, direction, target.targetPart)
			end)

			if ok then
				self.lastShot = currentTime
				task.defer(function()
					self.Visuals:CreateTracer(origin, targetPos)
				end)
			end

		elseif gun.type == "CastRay" then
			if not gun.hole or not gun.hole.Parent then return end

			local origin = gun.hole.Position
			local dirVec = targetPos - origin
			if dirVec.Magnitude < 0.01 then return end

			local direction = dirVec.Unit
			local ray = Ray.new(origin, direction * 1000)
