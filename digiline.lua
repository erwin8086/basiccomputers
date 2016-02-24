--[[
	Digiline Upgrade for mod digilines.
]]

-- Register the Upgrade
local old_is_upgrade = basiccomputers.is_upgrade
function basiccomputers.is_upgrade(upgrade)
	if upgrade:get_name() == "basiccomputers:digiline" then
		return true
	end
	return old_is_upgrade(upgrade)
end

-- On digiline receive
local function on_receive(pos, node, channel, msg)
	local meta = minetest.get_meta(pos)
	meta:set_string("digi_channel", channel)
	meta:set_string("digi_msg", msg)
end
local basic = basiccomputers.basic

-- Send to digiline
function basic.cmds.DIGILINE(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:digiline")) then
		local channel = args[1]
		local msg = args[2]
		if channel and msg and type(channel) == "string" then
			digiline:receptor_send(self.pos, digiline.rules.default, channel, msg)
		else
			self:error("Inkorrekt Parameter")
		end
	else
		self:error("Require Digiline Upgrade")
	end
end

-- Get from digiline
function basic.funcs.DIGILINE(self, args)
	local mode = args[1]
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:digiline")) then
		if mode == "channel" then
			local chan = meta:get_string("digi_channel")
			meta:set_string("digi_channel", "")
			return 0, chan
		elseif mode == "message" then
			local msg = meta:get_string("digi_msg")
			meta:set_string("digi_msg", "")
			return 0, msg
		else
			self:error("Inkorrekt mode")
		end
	else
		self:error("Require Digiline Upgrade")
	end
	return 0
end

-- Is message in buffer
function basic.funcs.ISDIGILINE(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.has_upgrade(meta, "basiccomputers:digiline") then
		local chan = meta:get_string("digi_channel")
		if chan and chan ~= "" then
			return 1
		end
	else
		self:error("Require Digiline Upgrade")
	end
	return 0
end

-- The digiline Options for the computer
basiccomputers.digiline =
{
	receptor = {},
	effector = {
		action = on_receive
	},

}

-- The digiline Upgrade
minetest.register_craftitem("basiccomputers:digiline", {
	description = "Digiline Upgrade",
	inventory_image = "default_wood.png"
})
