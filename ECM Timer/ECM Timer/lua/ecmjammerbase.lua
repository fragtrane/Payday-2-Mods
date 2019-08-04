--LazyOzzy's ECM duration timer

local setup_original = ECMJammerBase.setup
local sync_setup_original = ECMJammerBase.sync_setup
local destroy_original = ECMJammerBase.destroy
local load_original = ECMJammerBase.load
local update_original = ECMJammerBase.update

function ECMJammerBase:_check_new_ecm()
	if not ECMJammerBase._max_ecm or ECMJammerBase._max_ecm:battery_life() < self:battery_life() then
		ECMJammerBase._max_ecm = self
	end
end

function ECMJammerBase:sync_setup(upgrade_lvl, ...)
	sync_setup_original(self, upgrade_lvl, ...)
	self:_check_new_ecm()
end

function ECMJammerBase:setup(battery_life_upgrade_lvl, ...)
	setup_original(self, battery_life_upgrade_lvl, ...)
	self:_check_new_ecm()
end

function ECMJammerBase:destroy(...)
	if ECMJammerBase._max_ecm == self then
		ECMJammerBase._max_ecm = nil
		managers.hud:update_ecm(0)
	end
	return destroy_original(self, ...)
end

function ECMJammerBase:load(...)
	load_original(self, ...)
	self:_check_new_ecm()
end

function ECMJammerBase:update(unit, t, ...)
	update_original(self, unit, t, ...)
	if ECMJammerBase._max_ecm == self then
		managers.hud:update_ecm(self:battery_life())
	end
end
