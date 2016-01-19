local path = minetest.get_modpath("basiccomputers")
local basic = assert(loadfile(path.."/luabasic/sandbox.lua"))(path.."/luabasic")
local vfs = assert(loadfile(path.."/vfs.lua"))()

basiccomputers = {}
basiccomputers.basic = basic
basiccomputers.vfs = vfs
basiccomputers.path = path
basiccomputers.running = {}

function basiccomputers.can_dig(pos, player)
	return true
end

function basiccomputers.can_inv(pos, player)
	return true
end

function basiccomputers.can_click(pos, player)
	return true
end

function basiccomputers.can_enter(pos, player)
	return true
end


dofile(path.."/upgrades.lua")
dofile(path.."/chat.lua")
dofile(path.."/owner.lua")
dofile(path.."/command.lua")
dofile(path.."/loader.lua")
dofile(path.."/disk_block.lua")
if technic then
	dofile(path.."/technic.lua")
end
if digiline then
	dofile(path.."/digiline.lua")
end
	
local id = 0
local function set_running(pos)
	for id, spos in pairs(basiccomputers.running) do
		if pos.x == spos.x and pos.y == spos.y and pos.z == spos.z then
			return
		end
	end
	basiccomputers.running[id] = {x=pos.x, y=pos.y, z=pos.z}
	id = id + 1
end

local function set_stop(pos)
	for id, spos in pairs(basiccomputers.running) do
		if pos.x == spos.x and pos.y == spos.y and pos.z == spos.z then
			basiccomputers.running[id] = nil
		end
	end
end
local off_formspec = "size[10,9]"..
	"button[7,2;3,3;start;Start]"..
	"list[current_player;main;0,5;8,4]"..
	"list[context;upgrades;8,0;2,2]"
local on_formspec = "size[10,9]"..
	"button[7,2;3,1;kill;Kill]"..
	"button[7,3;3,1;reboot;Reboot]"..
	"button[7,4;3,1;halt;Halt]"..
	"field[0,4;6,1;input;Input:;]"..
	"button[6,4;1,1;ok;OK]"..
	"list[current_player;main;0,5;8,4]"..
	"list[context;upgrades;8,0;2,2]"


local function punch_computer(pos, player)

end

local function computer_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if inv:is_empty("upgrades") then
		return basiccomputers.can_dig(pos, player)
	end
	return false
end



local function get_on_formspec(meta)
	local formspec = on_formspec
	formspec = basiccomputers.get_upgrade_inv(meta, formspec)
	return formspec
end

local function get_off_formspec(meta)
	local formspec = off_formspec
	formspec = basiccomputers.get_upgrade_inv(meta, formspec)
	return formspec
end


basic.funcs.ISREAD = function(self, args)
	local meta = minetest.get_meta(self.pos)
	local read = meta:get_string("input")
	if read and read ~= "" then
		return 1
	else
		return 0
	end
end

basic.funcs.READ = function(self, args)
	return self:read()
end

basic.cmds.STR = function(self, args)
	local str = args[1]
	if str then
		self.mem.str = str
	end
end

basic.funcs.STR = function(self, args)
	return 0, self.mem.str or ""
end

local function start_computer(pos, player, start)
	if basiccomputers.on_start then
		local exit = basiccomputers.on_start(pos, player, start)
		if exit then
			return
		end
	end
	local meta = minetest.get_meta(pos)
	if meta:get_int("running") == 1 then
		return
	end
	if not basiccomputers.get_power(meta, 500) then
		start = start or 0
		if start < 2 then
			minetest.after(2.0, function()
				start_computer(pos, player, start+1)
			end)
		end
		return
	end
	meta:set_int("running", 1)
	meta:set_string("formspec", get_on_formspec(meta))
	meta:set_string("infotext", "Computer: Running")
	meta:set_string("display", "")
	minetest.swap_node(pos, {name="basiccomputers:computer_running"})
end
basiccomputers.start_computer = start_computer

local function stop_computer(pos, player)
	if basiccomputers.on_stop then
		local exit = basiccomputers.on_stop(pos, player)
		if exit then
			return
		end
	end
		
	local meta = minetest.get_meta(pos)
	if meta:get_int("running") == 0 then
		return
	end
	meta:set_int("running", 0)
	meta:set_string("formspec", get_off_formspec(meta))
	meta:set_string("infotext", "Computer: Poweroff")
	meta:set_string("state", "{}")
	local inv = meta:get_inventory()
	local stack = inv:get_stack("disk", 1)
	stack = basiccomputers.disk_remove(stack)
	inv:set_stack("disk", 1, stack)
	set_stop(pos)
	minetest.swap_node(pos, {name="basiccomputers:computer"})
end
basiccomputers.stop_computer = stop_computer

local function update_formspec(meta)
	meta:set_string("formspec", get_on_formspec(meta)..
		"label[0,0;"..minetest.formspec_escape(meta:get_string("display")).."]"..
		"label["..math.random(0,100)..","..math.random(0,100)..";]")
end

local function reboot_computer(pos, player)
	local meta = minetest.get_meta(pos)
	meta:set_string("state", "{}")
	meta:set_string("display", "")
	local inv = meta:get_inventory()
	local stack = inv:get_stack("disk", 1)
	stack = basiccomputers.disk_remove(stack)
	inv:set_stack("disk", 1, stack)
	update_formspec(meta)
end

local can_dig = function(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty("upgrade") then
		return false
	end
	return basiccomputers.can_dig(pos, player)
end

local function computer_receive(pos, fields, player)
	if not basiccomputers.can_click(pos, player) then
		fields.halt=nil
		fields.kill=nil
		fields.reboot=nil
		fields.save=nil
	end
	if not basiccomputers.can_enter(pos, player) then
		fields.ok=nil
	end
	local meta = minetest.get_meta(pos)
	if fields.halt then
		stop_computer(pos, player)
	elseif fields.reboot then
		reboot_computer(pos, player)
	elseif fields.ok then
		meta:set_string("input", fields.input)
		update_formspec(meta)
	elseif fields.kill then
		local state = minetest.deserialize(meta:get_string("state"))
		if state.cli then
			state.cli.running=false
		end
		meta:set_string("state", minetest.serialize(state))
	elseif fields.save then
		local a = basic:new()
		a:from_table(minetest.deserialize(meta:get_string("state")))
		a.program = {}
		a.cli.str2prg(a, fields.edit)
		meta:set_string("state", minetest.serialize(a:to_table()))
		update_formspec(meta)
	end
end

local function computer_edit(bi, args)
	local pos = bi.pos
	local meta = minetest.get_meta(pos)
	local formspec = "size[10,9]"..
		"textarea[0,1;11,8;edit;Editor;"..minetest.formspec_escape(bi.cli.prg2str(bi)).."]"..
		"button[0,8;10,1;save;Save]"
	meta:set_string("formspec", formspec)
	bi.cli.running = false
end

basic.cmds.EDIT = computer_edit


local function computer_calc(pos)
	if basiccomputers.on_calc then
		local exit = basiccomputers.on_calc(pos)
		if exit then
			return
		end
	end
	local meta = minetest.get_meta(pos)
	if meta:get_int("running") == 0 then
		return
	end
	if not basiccomputers.get_power(meta, 100) then
		stop_computer(pos)
		return
	end
	set_running(pos)
	local state = minetest.deserialize(meta:get_string("state"))
	local a = basic:new()
	a:from_table(state)
	local term = {}
	function term.print(text)
		local ptext=""
		local max_line = 39
		local nl = text:find("\n")
		while nl do
			local seg = string.sub(text, 1, nl-1)
			while string.len(seg) > max_line do
				if ptext == "" then
					ptext=string.sub(seg, 1, max_line).."\n"
				else
					ptext=ptext..string.sub(seg, 1, max_line).."\n"
				end
				seg = string.sub(seg, max_line+1, -1)
			end
			ptext=ptext..seg.."\n"
			text = string.sub(text, nl+1, -1)
			nl = text:find("\n")
		end
		while string.len(text) > max_line do
			if ptext == "" then
				ptext=string.sub(text, 1, max_line).."\n"
			else
				ptext=ptext..string.sub(text, 1, max_line).."\n"
			end
			text = string.sub(text, max_line+1, -1)
		end
		ptext = ptext..text
		text = ptext
		ptext = nil
				
		local display = meta:get_string("display")
		display = display..text.."\n"
		local lines = 0
		for line in string.gmatch(display, "\n") do
			lines = lines +1
		end
		while lines > 8 do
			local start = display:find("\n")
			display = display:sub(start+1, -1)
			lines = lines - 1
		end
		meta:set_string("display", display)
		update_formspec(meta)

	end

	function term.read()
		local read = meta:get_string("input")
		if read and read ~= "" then
			meta:set_string("input", "")
			return read
		else
			return ""
		end
	end

	function term.clear()
		meta:set_string("display", "")
		meta:set_string("formspec", get_on_formspec(meta))
	end
	a:set_term(term)
	a.pos = pos

	if a.cli.running then
		a.cli.nextLine(a)
	else
		a.cli.readLine(a)
	end
	meta:set_string("state", minetest.serialize(a:to_table()))
end

minetest.register_node("basiccomputers:computer", {
	description = "Computer",
	tiles = { "default_wood.png" },
	groups = {choppy=2},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_string("state" , "{}")
		meta:set_string("infotext", "Computer: Poweroff")
		meta:set_string("formspec", get_off_formspec(meta))
		meta:set_int("running", 0)
		inv:set_size("upgrades", 4)
		inv:set_size("fuel", 1)
		inv:set_size("tape", 1)
		inv:set_size("disk", 1)
	end,
	on_punch = function(pos, node, player, pointed_thing)
		if basiccomputers.can_click(pos, player) then
			start_computer(pos, player)
		end
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if not basiccomputers.can_click(pos, sender) then
			return
		end
		if fields.start then
			start_computer(pos, sender)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if not basiccomputers.can_inv(pos, player) then
			return 0
		end
		if listname == "upgrades" then
			return basiccomputers.upgrade_put(pos, stack, player)
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if not basiccomputers.can_inv(pos, player) then
			return 0
		end
		if listname == "upgrades" then
			return basiccomputers.upgrade_take(pos, stack, player)
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_off_formspec(meta))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_off_formspec(meta))
	end,
	digiline = basiccomputers.digiline,
	can_dig = computer_dig
})

minetest.register_node("basiccomputers:computer_running", {
	tiles = { "default_wood.png" },
	groups = {choppy=2},
	drop="basiccomputers:computer",
	on_punch = function(pos, node, player, pointed_thing)
		punch_computer(pos, player)
	end,

	on_receive_fields = function(pos, fromname, fields, sender)
		computer_receive(pos,fields,sender)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if not basiccomputers.can_inv(pos, player) then
			return 0
		end
		if listname == "upgrades" then
			minetest.chat_send_player(player:get_player_name(), "You cannot add upgrade while computer is running!")
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if not basiccomputers.can_inv(pos, player) then
			return 0
		end
		if listname == "upgrades" then
			minetest.chat_send_player(player:get_player_name(), "You cannot remove upgrade while computer is running!")
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "disk" then
			stack = basiccomputers.disk_remove(stack)
			return stack
		end
	end,
	digiline = basiccomputers.digiline,
	can_dig = function(pos, player)
		return false
	end,
})

minetest.register_abm({
	nodenames = {"basiccomputers:computer_running"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, aoc, aocw)
		computer_calc(pos)
	end,
})

minetest.register_craftitem("basiccomputers:generator", {
	description = "Generator Upgrade",
	inventory_image = "default_wood.png"
})

minetest.register_craftitem("basiccomputers:tape_drive", {
	description = "Tape Drive",
	inventory_image = "default_wood.png"
})

minetest.register_craftitem("basiccomputers:tape", {
	description = "Tape",
	inventory_image = "default_stone.png",
	stack_max = 1,
})

minetest.register_craftitem("basiccomputers:floppy_drive", {
	description = "Floppy Drive",
	inventory_image = "default_wood.png",
})

minetest.register_craftitem("basiccomputers:floppy", {
	description = "Floppy",
	inventory_image = "default_stone.png",
	stack_max = 1,
})

minetest.register_privilege("basiccomputers_admin", "Admin for basiccomputers")
