--[[
	The Loader Upgrade.
	Keeps computer forceloaded
]]

-- Force load block if upgrade is in computer
local old_upgrade_put = basiccomputers.upgrade_put
function basiccomputers.upgrade_put(pos, stack, player)
	if stack:get_name() == "basiccomputers:loader" then
		minetest.forceload_block(pos)
	end
	return old_upgrade_put(pos, stack, player)
end

-- Free force loaded block if upgrade removed
local old_upgrade_take = basiccomputers.upgrade_take
function basiccomputers.upgrade_take(pos, stack, player)
	if stack:get_name() == "basiccomputers:loader" then
		minetest.forceload_free_block(pos)
	end
	return old_upgrade_take(pos, stack, player)
end

-- Register the Upgrade
local old_is_upgrade = basiccomputers.is_upgrade
function basiccomputers.is_upgrade(upgrade)
	if upgrade:get_name() == "basiccomputers:loader" then
		return true
	end
	return old_is_upgrade(upgrade)
end

-- The Upgrade
minetest.register_craftitem("basiccomputers:loader", {
	description = "Loader Upgrade",
	inventory_image = "default_wood.png",
})
