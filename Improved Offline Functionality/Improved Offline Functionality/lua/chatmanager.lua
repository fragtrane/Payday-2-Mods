dofile(ModPath .. "lua/setup.lua")

--System message in single player when chat is enabled
Hooks:PostHook(ChatManager, "feed_system_message", "IOF_post_ChatManager_feed_system_message", function(self, channel_id, message)
	if Global.game_settings.single_player and IOF._settings.iof_chat then
		self:_receive_message(channel_id, managers.localization:to_upper_text("menu_system_message"), message, tweak_data.system_chat_color)
	end
end)
