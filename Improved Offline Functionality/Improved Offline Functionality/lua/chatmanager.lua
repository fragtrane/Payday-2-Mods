dofile(ModPath .. "lua/setup.lua")

--System message in single player when chat is enabled
local orig_ChatManager_feed_system_message = ChatManager.feed_system_message
function ChatManager:feed_system_message(channel_id, message)
	if IOF._settings.iof_chat then
		self:_receive_message(channel_id, managers.localization:to_upper_text("menu_system_message"), message, tweak_data.system_chat_color)
		return
	end
	orig_ChatManager_feed_system_message(self, channel_id, message)
end
