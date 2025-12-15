-- ReplicatedStorage/MyAnimator/Animation.lua

local Animation = {}
Animation.__index = Animation

-- Utility: CFrame → quaternion
local function cframeToQuat(cf: CFrame)
	if not cf then
		return Vector3.zero, 1
	end

	local x, y, z,
	r00, r01, r02,
	r10, r11, r12,
	r20, r21, r22 = cf:GetComponents()

	local trace = r00 + r11 + r22
	local qw, qx, qy, qz

	if trace > 0 then
		local s = math.sqrt(trace + 1) * 2
		qw = 0.25 * s
		qx = (r21 - r12) / s
		qy = (r02 - r20) / s
		qz = (r10 - r01) / s
	elseif r00 > r11 and r00 > r22 then
		local s = math.sqrt(1 + r00 - r11 - r22) * 2
		qw = (r21 - r12) / s
		qx = 0.25 * s
		qy = (r01 + r10) / s
		qz = (r02 + r20) / s
	elseif r11 > r22 then
		local s = math.sqrt(1 + r11 - r00 - r22) * 2
		qw = (r02 - r20) / s
		qx = (r01 + r10) / s
		qy = 0.25 * s
		qz = (r12 + r21) / s
	else
		local s = math.sqrt(1 + r22 - r00 - r11) * 2
		qw = (r10 - r01) / s
		qx = (r02 + r20) / s
		qy = (r12 + r21) / s
		qz = 0.25 * s
	end

	return Vector3.new(qx, qy, qz), qw
end

-- Default linear easing
local function linear(t)
	return t
end

-- Build animation from Roblox KeyframeSequence
function Animation.fromKeyframeSequence(sequence: KeyframeSequence)
	assert(sequence:IsA("KeyframeSequence"), "Expected KeyframeSequence")

	local self = setmetatable({}, Animation)

	self.length = 0
	self.keyframeTimes = {}
	self.poses = {}
	self.holes = {}
	self.events = {}

	-- Sort keyframes by time
	local keyframes = sequence:GetKeyframes()
	table.sort(keyframes, function(a, b)
		return a.Time < b.Time
	end)

	-- Collect unique limb names
	local limbIndex = {}
	local limbCount = 0

	for _, keyframe in ipairs(keyframes) do
		for _, pose in ipairs(keyframe:GetDescendants()) do
			if pose:IsA("Pose") and not limbIndex[pose.Name] then
				limbCount += 1
				limbIndex[pose.Name] = limbCount
			end
		end
	end

	-- Process keyframes
	for k, keyframe in ipairs(keyframes) do
		local time = keyframe.Time
		self.keyframeTimes[k] = time
		self.length = math.max(self.length, time)

		local framePoses = {}
		self.poses[k] = framePoses

		for _, pose in ipairs(keyframe:GetDescendants()) do
			if pose:IsA("Pose") and pose.CFrame then
				local index = limbIndex[pose.Name]
				local cf = pose.CFrame
				local pos = cf.Position
				local qv, qw = cframeToQuat(cf)

				-- Safely handle easing function
				local easing
				if pcall(function() return pose.EasingFunction end) and pose.EasingFunction then
					easing = pose.EasingFunction
				else
					easing = linear
				end

				framePoses[index] = {
					position = pos,
					quatVec = qv,
					quatW = qw,
					easing = easing,
				}
			end
		end
	end

	-- Build hole table for missing poses
	for limb = 1, limbCount do
		self.holes[limb] = {}
		local lastValid = nil

		for k = 1, #self.keyframeTimes do
			if self.poses[k][limb] then
				lastValid = k
			end
			self.holes[limb][k] = {lastValid or k, lastValid or k}
		end

		local nextValid = nil
		for k = #self.keyframeTimes, 1, -1 do
			if self.poses[k][limb] then
				nextValid = k
			end
			self.holes[limb][k][2] = nextValid or k
		end
	end

	return self
end

-- Add an animation event
function Animation:addEvent(time, name, limb, data)
	self.events[#self.events + 1] = {
		time = math.clamp(time, 0, self.length),
		name = name,
		limb = limb,
		data = data,
	}
end

-- Sort events by time
function Animation:sortEvents()
	table.sort(self.events, function(a, b)
		return a.time < b.time
	end)
end

return Animation
