dofile(ModPath .. "lua/setup.lua")

--Add extra profiles
--Number of profiles is fixed at total_profiles
--So if the number of profiles in the base game is changed, the added profiles will not be lost
function MultiProfileManager:_check_amount()
	local wanted_amount = fragProfiles._settings.total_profiles--Only this line changed
	if not self:current_profile() then
		self:save_current()
	end
	if wanted_amount < self:profile_count() then
		table.crop(self._global._profiles, wanted_amount)
		self._global._current_profile = math.min(self._global._current_profile, wanted_amount)
	elseif wanted_amount > self:profile_count() then
		local prev_current = self._global._current_profile
		self._global._current_profile = self:profile_count()
		while wanted_amount > self._global._current_profile do
			self._global._current_profile = self._global._current_profile + 1
			self:save_current()
		end
		self._global._current_profile = prev_current
	end
end
