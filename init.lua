local path = minetest.get_modpath("basiccomputers")
local basic = assert(loadfile(path.."/luabasic/sandbox.lua"))(path.."/luabasic")
local vfs = assert(loadfile(path.."/vfs.lua"))()

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

local function is_upgrade(upgrade)
	if upgrade:get_name() == "basiccomputers:generator" then
		return true
	elseif upgrade:get_name() == "basiccomputers:tape_drive" then
		return true
	elseif upgrade:get_name() == "basiccomputers:floppy_drive" then
		return true
	else
		return false
	end
end

local function has_upgrade(meta, upgrade)
	local inv = meta:get_inventory()
	if inv:contains_item("upgrades", upgrade) then
		return true
	else
		return false
	end
end

local function is_tape(meta)
	return has_upgrade(meta, ItemStack("basiccomputers:tape_drive"))
end

local function is_floppy(meta)
	return has_upgrade(meta, ItemStack("basiccomputers:floppy_drive"))
end

local function get_on_formspec(meta)
	local formspec = on_formspec
	if has_upgrade(meta, ItemStack("basiccomputers:generator")) then
		formspec = formspec..
			"label[8,6;Fuel:]"..
			"list[context;fuel;9,6;1,1]"
	end
	if is_tape(meta) then
		formspec = formspec..
			"label[8,7;Tape:]"..
			"list[context;tape;9,7;1,1]"
	end
	if is_floppy(meta) then
		formspec = formspec..
			"label[8,8;Floppy:]"..
			"list[context;disk;9,8;1,1]"
	end
	return formspec
end

local function get_off_formspec(meta)
	local formspec = off_formspec
	if has_upgrade(meta, ItemStack("basiccomputers:generator")) then
		formspec = formspec..
			"label[8,6;Fuel:]"..
			"list[context;fuel;9,6;1,1]"
	end
	if is_tape(meta) then
		formspec = formspec..
			"label[8,7;Tape:]"..
			"list[context;tape;9,7;1,1]"
	end
	if is_floppy(meta) then
		formspec = formspec..
			"label[8,8;Floppy:]"..
			"list[context;disk;9,8;1,1]"
	end
	return formspec
end

local function upgrade_put(pos, stack, player)
	if is_upgrade(stack) then
		return stack:get_count()
	end
	return 0
end
local function upgrade_take(pos, stack, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if stack:get_name() == "basiccomputers:generator" then
		if inv:is_empty("fuel") then
			return stack:get_count()
		else
			return 0
		end
	elseif stack:get_name() == "basiccomputers:tape_drive" then
		if inv:is_empty("tape") then
			return stack:get_count()
		else
			return 0
		end
	else
		return stack:get_count()
	end
		
end

local function get_power(meta, power)
	if has_upgrade(meta, ItemStack("basiccomputers:generator")) then
		local energy = meta:get_int("energy")
		if energy >= power then
			meta:set_int("energy", energy-power)			
			return true
		else
			local inv = meta:get_inventory()
			local fuel, afterfuel = minetest.get_craft_result({ method="fuel", with=1, items=inv:get_list("fuel")})
			if fuel.time > 0 then
				meta:set_int("energy", fuel.time*200-energy)
				local stack = inv:get_stack("fuel", 1)
				stack:take_item()
				inv:set_stack("fuel",1, stack)
				return true
			end
		end
	end
	return false
		
end

basic.funcs.ENERGY = function(self, arg)
	local meta = minetest.get_meta(self.pos)
	local energy = meta:get_int("energy")
	return energy or 0
end

local function start_computer(pos, player)
	local meta = minetest.get_meta(pos)
	if meta:get_int("running") == 1 then
		return
	end
	if not get_power(meta, 500) then
		return
	end
	meta:set_int("running", 1)
	meta:set_string("formspec", get_on_formspec(meta))
	meta:set_string("infotext", "Computer: Running")
	meta:set_string("display", "")
	minetest.swap_node(pos, {name="basiccomputers:computer_running"})
end

local function stop_computer(pos, player)
	local meta = minetest.get_meta(pos)
	if meta:get_int("running") == 0 then
		return
	end
	meta:set_int("running", 0)
	meta:set_string("formspec", get_off_formspec(meta))
	meta:set_string("infotext", "Computer: Poweroff")
	meta:set_string("state", "{}")
	minetest.swap_node(pos, {name="basiccomputers:computer"})
end

local function update_formspec(meta)
	meta:set_string("formspec", get_on_formspec(meta)..
		"label[0,0;"..minetest.formspec_escape(meta:get_string("display")).."]"..
		"label["..math.random(0,100)..","..math.random(0,100)..";]")
end

local function reboot_computer(pos, player)
	local meta = minetest.get_meta(pos)
	meta:set_string("state", "{}")
	meta:set_string("display", "")
	update_formspec(meta)
end

local function computer_receive(pos, fields, player)
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
	local meta = minetest.get_meta(pos)
	if meta:get_int("running") == 0 then
		return
	end
	if not get_power(meta, 100) then
		stop_computer(pos)
		return
	end
	local state = minetest.deserialize(meta:get_string("state"))
	local a = basic:new()
	a:from_table(state)
	local term = {}
	function term.print(text)
		text = string.sub(text, 1,35)
		local display = meta:get_string("display")
		display = display..text.."\n"
		local lines = 0
		for line in string.gmatch(display, "\n") do
			lines = lines +1
		end
		if lines > 8 then
			local start = display:find("\n")
			display = display:sub(start+1, -1)
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

basic.cmds.SAVE = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if is_tape(meta) then
		local inv = meta:get_inventory()
		stack = inv:get_stack("tape",1)
		if stack:get_name() == "basiccomputers:tape" then
			local prg = self.cli.prg2str(self)
			stack:set_metadata(prg)
			inv:set_stack("tape",1,stack)
		end
	end
end

basic.cmds.LOAD = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if is_tape(meta) then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("tape",1)
		if stack:get_name() == "basiccomputers:tape" then
			local prg = stack:get_metadata()
			if prg then
				self.cli.str2prg(self, prg)
			end
		end
	end
end

local function load_vfs(stack)
	local v = vfs:new()
	local saved = minetest.deserialize(stack:get_metadata())
	v:from_table(saved)
	v:set_size(4096)
	return v
end

local function save_vfs(stack, v)
	local save = v:to_table()
	stack:set_metadata(minetest.serialize(save))
	print(minetest.serialize(save))
	return stack
end

basic.cmds.FOPEN = function(self, args)
	local id = args[1]
	local name = args[2]
	if id and name and type(id) == "number" and type(name) == "string" then
		if id < 10 and id >= 0 then
			local meta = minetest.get_meta(self.pos)
			if is_floppy(meta) then
				local inv = meta:get_inventory()
				local stack = inv:get_stack("disk", 1)
				if stack:get_name() == "basiccomputers:floppy" then
					local vfs = load_vfs(stack)
					vfs:open(name, id)
					stack = save_vfs(stack, vfs)
					inv:set_stack("disk", 1, stack)
				else
					self:error("No Floppy")

				end
			else
				self:error("No Floppydrive")
			end
		else
			self:error("id must between 0 and 9")
		end
	else
		self:error("Inkorrect parameter")
	end
end

basic.cmds.FWRITE = function(self, args)
	local id = args[1]
	local text = args[2]
	if id and text and type(id) == "number" and type(text) == "string" then
		if id < 10 and id >= 0 then
			local meta = minetest.get_meta(self.pos)
			if is_floppy(meta) then
				local inv = meta:get_inventory()
				local stack = inv:get_stack("disk", 1)
				if stack:get_name() == "basiccomputers:floppy" then
					local vfs = load_vfs(stack)
					vfs:write(id,text)
					stack = save_vfs(stack, vfs)
					inv:set_stack("disk", 1, stack)
				else
					self:error("No Floppy")
				end
			else
				self:error("No Floppydrive")
			end
		else
			self:error("Id must between 0 and 9")
		end
	else
		self:error("Inkorrect Parameter")
	end
end

basic.funcs.FREAD = function(self, args)
	local id = args[1]
	if id and type(id) == "number" then
		if id < 10 and id >= 0 then
			local meta = minetest.get_meta(self.pos)
			if is_floppy(meta) then
				local inv = meta:get_inventory()
				local stack = inv:get_stack("disk", 1)
				if stack:get_name() == "basiccomputers:floppy" then
					local vfs = load_vfs(stack)
					local read = vfs:read(id)
					stack = save_vfs(stack, vfs)
					inv:set_stack("disk",1,stack)
					return 0, read
				else
					self:error("No Floppy")
				end
			else
				self:error("No Floppydrive")
			end
		else
			self:error("Id must between 0 and 9")
		end
	else
		self:error("Inkorrect Parameter")
	end
	return 0
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
		start_computer(pos, player)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.start then
			start_computer(pos, sender)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "upgrades" then
			return upgrade_put(pos, stack, player)
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "upgrades" then
			return upgrade_take(pos, stack, player)
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
})

minetest.register_node("basiccomputers:computer_running", {
	tiles = { "default_wood.png" },
	groups={choppy=2},
	drop="basiccomputers:computer",
	on_punch = function(pos, node, player, pointed_thing)
		punch_computer(pos, player)
	end,

	on_receive_fields = function(pos, fromname, fields, sender)
		computer_receive(pos,fields,sender)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "upgrades" then
			minetest.chat_send_player(player:get_player_name(), "You cannot add upgrade while computer is running!")
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "upgrades" then
			minetest.chat_send_player(player:get_player_name(), "You cannot remove upgrade while computer is running!")
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end
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
})
