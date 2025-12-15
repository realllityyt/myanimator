-- MyAnimator: Modular Animation System for Roblox
-- Author: realllityy
-- Version: 1.0.0

-- ==================================================================
-- OVERVIEW
-- MyAnimator is a modular animation system for Roblox that provides:
-- - Animation playback with keyframes
-- - Crossfading, additive layers, and snapping
-- - Event triggering per-animation and per-limb
-- - Quaternion math for rotations
-- - API to control rigs and retrieve limb CFrames
-- ==================================================================

-- FOLDER STRUCTURE
-- ReplicatedStorage/MyAnimator/
-- MyAnimator/
-- ├── Animation.lua
-- ├── Blend.lua
-- ├── Math.lua
-- ├── Rig.lua
-- ├── Solver.lua
-- ├── Animator.lua
-- Suggestion: place MyAnimator in ReplicatedStorage [Or go Bald]
-- ==================================================================

-- MODULES

-- Animation.lua
-- -------------
-- Convert a KeyframeSequence into internal animation data
-- local Animation = require(ReplicatedStorage.MyAnimator.Animation)
-- local walkAnim = Animation.fromKeyframeSequence(walkKF)
-- Supports pose collection per limb, easing, and events

-- Blend.lua
-- ---------
-- Create and manipulate animation tracks
-- local Blend = require(ReplicatedStorage.MyAnimator.Blend)
-- local track = Blend.track(walkAnim, { alpha = 0, weight = 1, priority = 1 })
-- local fadeData = Blend.crossfade(walkAnim, runAnim, 0.5, 1)
-- local snapData = Blend.snap(walkAnim, 1)
-- local additive = Blend.additive(walkAnim, 0.5, 1)

-- Math.lua
-- --------
-- Quaternion math and fading utilities
-- local Math = require(ReplicatedStorage.MyAnimator.Math)
-- local qv, qw = Math.nlerpQuat(vecA, wA, vecB, wB, t)
-- local newVec, newW = Math.mulQuat(vecA, wA, vecB, wB)
-- local factor = Math.fade(time, length, fadeIn, fadeOut)

-- Rig.lua
-- -------
-- Create a rig from character Motor6Ds
-- local Rig = require(ReplicatedStorage.MyAnimator.Rig)
-- local rig = Rig.create(character:GetDescendants())
-- Contains limbs, transforms, and output CFrames

-- Solver.lua
-- ----------
-- Apply tracks to rig transforms
-- local Solver = require(ReplicatedStorage.MyAnimator.Solver)
-- Solver.solve(rig, tracks, rootCFrame)

-- Animator.lua
-- ------------
-- High-level API for animation playback and updating
-- local Animator = require(ReplicatedStorage.MyAnimator.Animator)
-- local animator = Animator.new(character:GetDescendants())
-- animator:play(walkAnim, { alpha = 0, weight = 1, priority = 1 })
-- animator:crossfade(walkAnim, runAnim, 0.5)
-- animator:snap(runAnim, 1)
-- game:GetService("RunService").RenderStepped:Connect(function(dt)
--     animator:update(character.PrimaryPart.CFrame)
-- end)
-- local rootCFrame = animator:getLimbCFrame("root")
-- local allCFrames = animator:getAllCFrames()

-- ==================================================================
-- EXAMPLE USAGE
-- ==================================================================
-- local Animator = require(ReplicatedStorage.MyAnimator.Animator)
-- local Animation = require(ReplicatedStorage.MyAnimator.Animation)
-- local animator = Animator.new(character:GetDescendants())
-- local walkAnim = Animation.fromKeyframeSequence(walkKF)
-- local runAnim = Animation.fromKeyframeSequence(runKF)
-- animator:play(walkAnim, { weight = 1, priority = 1 })
-- animator:crossfade(walkAnim, runAnim, 0.5)
-- game:GetService("RunService").RenderStepped:Connect(function(dt)
--     animator:update(character.PrimaryPart.CFrame)
-- end)

-- ==================================================================
-- NOTES
-- ==================================================================
-- Modules can be required individually
-- Uses [Vector3, W] quaternion format
-- Missing poses are interpolated automatically
-- Event callbacks work per-animation and per-limb

-- ==================================================================
-- RECOMMENDED USAGE
-- ==================================================================
-- Create one Animator per rig
-- Convert KeyframeSequences with Animation.fromKeyframeSequence
-- Control playback with :play, :crossfade, :snap
-- Update each frame using RenderStepped or Heartbeat
-- Use getLimbCFrame(name) for limb positions or IK
