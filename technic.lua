--[[
	The technic extension for technic mod
]]
local old_get_power = basiccomputers.get_power
-- Gets power from battery
local function battery_power(meta, power)
	if basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:battery")) then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("fuel", 1)
		if technic.power_tools[stack:get_name()] then
			local src_meta = minetest.deserialize(stack:get_metadata())
			src_meta = src_meta or {}
			if not src_meta.charge then
				src_meta.charge = 0
			end
			local max_charge = technic.power_tools[stack:get_name()]
			if src_meta.charge >= power then
				src_meta.charge = src_meta.charge - power
				technic.set_RE_wear(stack, src_meta.charge, max_charge)
				stack:set_metadata(minetest.serialize(src_meta))
				inv:set_stack("fuel", 1, stack)
				return true
			end
		end
	end
	-- Gets power from the old way
	return old_get_power(meta, power)
end
-- Get power from lv network
function basiccomputers.get_power(meta, power)
	local demand = meta:get_int("LV_EU_demand")
	local input = meta:get_int("LV_EU_input")
	local timeout = meta:get_int("LV_EU_timeout")
	if not timeout then
		meta:set_int("LV_EU_timeout",0)
		timeout=0
	end
	if timeout <= 0 then
		return battery_power(meta, power)
	else
		meta:set_int("LV_EU_timeout", timeout-1)
		
	end
	if not input then
		meta:set_int("LV_EU_input", 0)
		input = 0
	end
	if not demand then
		meta:set_int("LV_EU_demand", 0)
		demand = 0
	end
	if demand == 0 then
		meta:set_int("LV_EU_demand", power)
	elseif input >= demand then
		meta:set_int("LV_EU_demand", power)
		return true
	else
		meta:set_int("LV_EU_demand", power)
	end
	return battery_power(meta, power)
end

-- No power when computer is stopped
local old_on_stop = basiccomputers.on_stop
function basiccomputers.on_stop(pos, player)
	local meta = minetest.get_meta(pos)
	meta:set_int("LV_EU_demand", 0)
	if old_on_stop then
		return old_on_stop(pos, player)
	end
end
-- Register computer as machine
technic.register_machine( "LV", "basiccomputers:computer", technic.receiver)
technic.register_machine( "LV", "basiccomputers:computer_running", technic.receiver)

-- Register the battery upgrade
local old_is_upgrade = basiccomputers.is_upgrade
function basiccomputers.is_upgrade(upgrade)
	if upgrade:get_name() == "basiccomputers:battery" then
		return true
	end
	return old_is_upgrade(upgrade)
end

local old_upgrade_put = basiccomputers.upgrade_put
-- Allow only battery or generator upgrade. not both.
function basiccomputers.upgrade_put(pos, stack, player)
	if stack:get_name() == "basiccomputers:battery" or stack:get_name() == "basiccomputers:generator" then
		local meta = minetest.get_meta(pos)
		if basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:generator")) or basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:battery")) then
			return 0
		end
	end
	return old_upgrade_put(pos, stack, player)
end

-- Allow battery upgrade only taked if no battery is in slot
local old_upgrade_take = basiccomputers.upgrade_take
function basiccomputers.upgrade_take(pos, stack, player)
	if stack:get_name() == "basiccomputers:battery" then
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return 0
		end
	end
	return old_upgrade_take(pos, stack, player)
end

-- The battery Upgrade
minetest.register_craftitem("basiccomputers:battery", {
	description = "Battery Upgrade",
	inventory_image = "default_wood.png",
})

-- The battery slot
local old_upgrade_inv = basiccomputers.get_upgrade_inv
function basiccomputers.get_upgrade_inv(meta, formspec)
	if basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:battery")) then
		formspec = formspec..
			"label[8,6;Battery:]"..
			"list[context;fuel;9,6;1,1]"
	end
	return old_upgrade_inv(meta, formspec)
end

-- The energy function works for battery upgrade
local old_energy = basic.funcs.ENERGY
function basic.funcs.ENERGY(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:battery")) then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("fuel", 1)
		local name = stack:get_name()
		if technic.power_tools[name] then
			local src = minetest.deserialize(stack:get_metadata())
			src = src or {}
			if src.charge then
				return src.charge
			end
		end
	end
	return old_energy(self, args)
end
