local Math = {}

-- Normalized Linear Quaternion Interpolation (NLERP)
-- Interpolates between two quaternions using linear blending and normalizes the result
function Math.nlerpQuat(aVec, aW, bVec, bW, t)
	if aVec:Dot(bVec) + aW * bW < 0 then
		bVec = -bVec
		bW = -bW
	end
	local v = aVec:Lerp(bVec, t)
	local w = aW + (bW - aW) * t
	local mag = math.sqrt(v:Dot(v) + w * w)
	if mag < 1e-8 then
		return Vector3.zero, 1
	end
	return v / mag, w / mag
end

-- Spherical Linear Quaternion Interpolation (SLERP)
-- Smooth interpolation along the shortest path on the quaternion sphere
function Math.slerpQuat(aVec, aW, bVec, bW, t)
	local dot = aVec:Dot(bVec) + aW * bW
	if dot < 0 then
		bVec = -bVec
		bW = -bW
		dot = -dot
	end
	dot = math.clamp(dot, -1, 1)
	local theta = math.acos(dot)
	if math.abs(theta) < 1e-5 then
		return Math.nlerpQuat(aVec, aW, bVec, bW, t)
	end
	local sinTheta = math.sin(theta)
	local scaleA = math.sin((1 - t) * theta) / sinTheta
	local scaleB = math.sin(t * theta) / sinTheta
	local outVec = aVec * scaleA + bVec * scaleB
	local outW = aW * scaleA + bW * scaleB
	return outVec, outW
end

-- Fade function for animation tracks
-- Returns alpha value based on fadeIn/fadeOut times
function Math.fade(time, length, fadeIn, fadeOut)
	if fadeIn > 0 and time < fadeIn then
		return math.clamp(time / fadeIn, 0, 1)
	end
	if fadeOut > 0 and time > length - fadeOut then
		return math.clamp((length - time) / fadeOut, 0, 1)
	end
	return 1
end

-- Multiply two quaternions (Hamilton product)
function Math.mulQuat(aVec, aW, bVec, bW)
	local x = aW * bVec.X + bW * aVec.X + aVec.Y * bVec.Z - aVec.Z * bVec.Y
	local y = aW * bVec.Y + bW * aVec.Y + aVec.Z * bVec.X - aVec.X * bVec.Z
	local z = aW * bVec.Z + bW * aVec.Z + aVec.X * bVec.Y - aVec.Y * bVec.X
	local w = aW * bW - aVec:Dot(bVec)
	return Vector3.new(x, y, z), w
end

-- Normalize a quaternion
function Math.normalizeQuat(qVec, qW)
	local mag = math.sqrt(qVec:Dot(qVec) + qW*qW)
	if mag < 1e-8 then
		return Vector3.zero, 1
	end
	return qVec / mag, qW / mag
end

return Math
