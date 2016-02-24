--[[
	The Command Upgrade.
	Execs chat commands.
]]

-- Register the Upgrade
local old_is_upgrade = basiccomputers.is_upgrade
function basiccomputers.is_upgrade(upgrade)
	if upgrade:get_name() == "basiccomputers:command" then
		return true
	end
	return old_is_upgrade(upgrade)
end

-- Sets players name for privs check.
local old_upgrade_put = basiccomputers.upgrade_put
function basiccomputers.upgrade_put(pos, stack, player)
	if stack:get_name() == "basiccomputers:command" then
		local meta = minetest.get_meta(pos)
		meta:set_string("command", player:get_player_name())
	end
	return old_upgrade_put(pos, stack, player)
end

-- Has computer the command upgrade
function basiccomputers.is_command(meta)
	return basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:command"))
end

-- Execs a chat command.
basic.cmds.COMMAND = function(self, args)
	local cmd = args[1]
	local para = args[2]
	local meta = minetest.get_meta(self.pos)
	if not basiccomputers.is_command(meta) then
		self:error("Requires Command Upgrade")
		return
	end
	local name = meta:get_string("command")
	if not para then
		para = ""
	end
	if cmd then
		local cmd_def = core.chatcommands[cmd]
		if not cmd_def then
			self:error("Unknown Command")
			return
		end
		local has_privs = core.check_player_privs(name, cmd_def.privs)
		if has_privs then
			local sucess, message = cmd_def.func(name, para)
			if message then
				self:print(message)
			end
		else
			self:error("You have not the required privilege on server")
		end
	else
		self:error("Inkorrekt Parameter")
	end
end

-- The Command Upgrade
minetest.register_craftitem("basiccomputers:command", {
	description = "Command Upgrade",
	inventory_image = "default_wood.png",
})
