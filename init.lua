local path = minetest.get_modpath("basiccomputers")
local basic = assert(loadfile(path.."/luabasic/sandbox.lua"))(path.."/luabasic")

local off_formspec = "size[10,9]"..
	"button[7,2;3,3;start;Start]"..
	"list[current_player;main;0,5;8,4]"
local on_formspec = "size[10,9]"..
	"button[7,2;3,1;kill;Kill]"..
	"button[7,3;3,1;reboot;Reboot]"..
	"button[7,4;3,1;halt;Halt]"..
	"field[0,4;6,1;input;Input:;]"..
	"button[6,4;1,1;ok;OK]"..
	"list[current_player;main;0,5;8,4]"

local function punch_computer(pos, player)

end


local function start_computer(pos, player)
	local meta = minetest.get_meta(pos)
	if meta:get_int("running") == 1 then
		return
	end
	meta:set_int("running", 1)
	meta:set_string("formspec", on_formspec)
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
	meta:set_string("formspec", off_formspec)
	meta:set_string("infotext", "Computer: Poweroff")
	meta:set_string("state", "{}")
	minetest.swap_node(pos, {name="basiccomputers:computer"})
end

local function update_formspec(meta)
	meta:set_string("formspec", on_formspec..
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
		meta:set_string("formspec", on_formspec)
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
		meta:set_string("formspec", off_formspec)
		meta:set_int("running", 0)
	end,
	on_punch = function(pos, node, player, pointed_thing)
		start_computer(pos, player)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.start then
			start_computer(pos, sender)
		end
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
})

minetest.register_abm({
	nodenames = {"basiccomputers:computer_running"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, aoc, aocw)
		computer_calc(pos)
	end,
})
