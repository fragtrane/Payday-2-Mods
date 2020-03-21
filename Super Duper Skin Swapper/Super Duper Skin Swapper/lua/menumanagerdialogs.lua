--Don't show replace attachment/attachments locked in confirm dialog
function MenuManager:show_confirm_weapon_cosmetics(params)
	local l_local = managers.localization
	local dialog_data = {
		type = "weapon_stats",
		focus_button = 2,
		title = l_local:text("dialog_bm_weapon_modify_title"),
		text = l_local:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.weapon_name
		}) .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_" .. (params.item_has_cosmetic and "add" or "remove"), {
			cosmetic = params.name
		})
	}
	
	if params.item_has_cosmetic and params.crafted_has_cosmetic then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_weapon_cosmetics_replace", {
			cosmetic = params.crafted_name
		})
	end
	
	local yes_button = {
		text = managers.localization:text("dialog_apply"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	
	managers.system_menu:show(dialog_data)
end
