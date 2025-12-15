local Rig = {}
Rig.__index = Rig

function Rig.create(motor6Ds)
	local self = setmetatable({}, Rig)
	self.limbs = {}
	self.transforms = {}
	self.output = {}

	for i, motor in ipairs(motor6Ds) do
		local parentName = "root"
		if motor.Part0 and motor.Part0.Name then
			parentName = motor.Part0.Name
		end

		self.limbs[i] = {
			name = motor.Name or ("Limb_" .. i),
			parent = parentName,
			c0 = motor.C0 or CFrame.identity,
			c1 = motor.C1 or CFrame.identity,
		}

		self.transforms[i] = {
			position = Vector3.zero,
			quatVec = Vector3.zero,
			quatW = 1,
			priority = -1,
		}
	end

	self.output["root"] = CFrame.identity
	return self
end

return Rig
