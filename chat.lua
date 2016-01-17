local basic = basiccomputers.basic

local old_is_upgrade = basiccomputers.is_upgrade
function basiccomputers.is_upgrade(upgrade)
	if upgrade:get_name() == "basiccomputers:chat" then
		return true
	else
		return old_is_upgrade(upgrade)
	end
end

function basiccomputers.is_chat(meta)
	return basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:chat"))
end

minetest.register_craftitem("basiccomputers:chat", {
	description = "Chat Upgrade",
	inventory_image = "default_wood.png",
})

basic.cmds.CHAT = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_chat(meta) then
		local msg = "Computer: "
		for _, txt in ipairs(args) do
			msg=msg..txt
		end
		for _, player in ipairs(minetest.get_connected_players()) do
			if vector.distance(self.pos, player:getpos()) < 10 then
				minetest.chat_send_player(player:get_player_name(), msg)
			end	
		end
	else
		self:error("No Chat Module")
	end
end

basic.funcs.GETCHAT = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_chat(meta) then
		local msg = meta:get_string("chat")
		meta:set_string("chat", "")
		return msg or ""
	end
	return ""
end

basic.funcs.ISCHAT = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_chat(meta) then
		local msg = meta:get_string("chat")
		if msg and msg ~= "" then
			return 1
		end
	end
	return 0
end

minetest.register_on_chat_message(function(name, message)
	for id, pos in pairs(basiccomputers.running) do
		print(pos.x..","..pos.y..","..pos.z)
		local meta = minetest.get_meta(pos)
		if meta then
			if basiccomputers.is_chat(meta) then
				meta:set_string("chat", message)
			end
		end
	end
end)
