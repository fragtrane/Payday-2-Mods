--Fix alignment of sights

function PlayerTweakData:_init_beer()
	self.stances.beer = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.66726, 32.1883, -2.86906)
	local pivot_shoulder_rotation = Rotation(4.44732e-05, 0.000568556, 0.000264643)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.beer.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.beer.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.beer.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.beer.standard.vel_overshot.yaw_neg = 10
	self.stances.beer.standard.vel_overshot.yaw_pos = -10
	self.stances.beer.standard.vel_overshot.pitch_neg = -13
	self.stances.beer.standard.vel_overshot.pitch_pos = 13
	--ADS based on 5/7 AP values
	local pivot_shoulder_translation = Vector3(8.44788, 38.6251, -5.22182)
	local pivot_shoulder_rotation = Rotation(0.100018, -0.688258, 0.629664)
	local pivot_head_translation = Vector3(0, 29, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	--Offset translation
	self.stances.beer.steelsight.shoulders.translation = Vector3(0, 10, -1) + pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.beer.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.beer.steelsight.FOV = self.stances.beer.standard.FOV
	self.stances.beer.steelsight.zoom_fov = false
	self.stances.beer.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.beer.steelsight.vel_overshot.yaw_neg = 1
	self.stances.beer.steelsight.vel_overshot.yaw_pos = -1
	self.stances.beer.steelsight.vel_overshot.pitch_neg = -5
	self.stances.beer.steelsight.vel_overshot.pitch_pos = 5
	--Revert for crouch
	local pivot_shoulder_translation = Vector3(8.66726, 32.1883, -2.86906)
	local pivot_shoulder_rotation = Rotation(4.44732e-05, 0.000568556, 0.000264643)
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.beer.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.beer.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.beer.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_czech()
	self.stances.czech = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.66723, 30.1231, -3.12016)
	local pivot_shoulder_rotation = Rotation(3.37549e-05, 0.000953238, -0.000301382)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.czech.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.czech.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.czech.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.czech.standard.vel_overshot.yaw_neg = 10
	self.stances.czech.standard.vel_overshot.yaw_pos = -10
	self.stances.czech.standard.vel_overshot.pitch_neg = -13
	self.stances.czech.standard.vel_overshot.pitch_pos = 13
	--ADS based on 5/7 AP values
	local pivot_shoulder_translation = Vector3(8.44788, 38.6251, -5.22182)
	local pivot_shoulder_rotation = Rotation(0.100018, -0.688258, 0.629664)
	local pivot_head_translation = Vector3(0, 29, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	--Offset translation
	self.stances.czech.steelsight.shoulders.translation = Vector3(-0.06, 10, -0.9) + pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.czech.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.czech.steelsight.FOV = self.stances.czech.standard.FOV
	self.stances.czech.steelsight.zoom_fov = false
	self.stances.czech.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.czech.steelsight.vel_overshot.yaw_neg = 1
	self.stances.czech.steelsight.vel_overshot.yaw_pos = -1
	self.stances.czech.steelsight.vel_overshot.pitch_neg = -5
	self.stances.czech.steelsight.vel_overshot.pitch_pos = 5
	--Revert for crouch
	local pivot_shoulder_translation = Vector3(8.66723, 30.1231, -3.12016)
	local pivot_shoulder_rotation = Rotation(3.37549e-05, 0.000953238, -0.000301382)
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.czech.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.czech.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.czech.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end
