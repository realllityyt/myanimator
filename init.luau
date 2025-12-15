-- Minimal Usage Example
-- Place this in a LocalScript or Script

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MyAnimator = require(ReplicatedStorage.MyAnimator)

-- Example: get a character (LocalPlayer or NPC)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- 1. Create rig from character's Motor6Ds
local rig = MyAnimator.createRig(character:GetDescendants())

-- 2. Load KeyframeSequence into internal animation
local walkKF = ReplicatedStorage.Animations:WaitForChild("Walk") -- Example KeyframeSequence
local walkAnim = MyAnimator.loadKeyframeSequence(walkKF)

-- 3. Create a track for playback
local track = MyAnimator.Blend.track(walkAnim, { alpha = 0, weight = 1, priority = 1 })

-- 4. Update animation each frame
RunService.RenderStepped:Connect(function(dt)
	-- Solve animation tracks and apply to rig
	local output = MyAnimator.solve(rig, { [walkAnim] = track }, character.PrimaryPart.CFrame)

	-- Example: apply output to parts (simplified)
	for limbName, cframe in pairs(output) do
		local part = character:FindFirstChild(limbName)
		if part then
			part.CFrame = cframe
		end
	end
end)
