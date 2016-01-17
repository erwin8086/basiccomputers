local old_is_upgrade = basiccomputers.is_upgrade
function basiccomputers.is_upgrade(upgrade)
	if upgrade:get_name() == "basiccomputers:owner" then
		return true
	end
	return old_is_upgrade(upgrade)
end

function basiccomputers.is_owner(meta)
	return basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:owner"))
end

local old_upgrade_put = basiccomputers.upgrade_put
function basiccomputers.upgrade_put(pos, stack, player)
	if stack:get_name() == "basiccomputers:owner" then
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", player:get_player_name())
	end
	return old_upgrade_put(pos, stack, player)
end

local old_can_dig = basiccomputers.can_dig
basiccomputers.can_dig = function(pos, player)
	local meta = minetest.get_meta(pos)
	if basiccomputers.is_owner(meta) then
		if meta:get_string("owner") == player:get_player_name() then
			return old_can_dig(pos, player)
		else
			return false
		end
	end
	return old_can_dig(pos, player)
end

local old_can_inv = basiccomputers.can_inv
basiccomputers.can_inv = function(pos, player)
	local meta = minetest.get_meta(pos)
	if basiccomputers.is_owner(meta) then
		if meta:get_string("owner") == player:get_player_name() then
			return old_can_inv(pos, player)
		else
			return false
		end
	end
	return old_can_inv(pos, player)
end
local old_can_click = basiccomputers.can_click
basiccomputers.can_click = function(pos, player)
	local meta = minetest.get_meta(pos)
	if basiccomputers.is_owner(meta) then
		if meta:get_string("owner") == player:get_player_name() then
			return old_can_click(pos, player)
		else
			return false
		end
	end
	return old_can_click(pos, player)
end

minetest.register_craftitem("basiccomputers:owner", {
	description = "Owner Upgrade",
	inventory_image = "default_wood.png",
})
