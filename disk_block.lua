local function is_disk(stack)
	if stack:get_name() == "basiccomputers:tape" then
		return true
	elseif stack:get_name() == "basiccomputers:floppy" then
		return true
	else
		return false
	end
end

local function has_disk(meta)
	local inv = meta:get_inventory()
	local stack = inv:get_stack("disk", 1)
	if stack:get_name() == "basiccomputers:tape" then
		return 1
	elseif stack:get_name() == "basiccomputers:floppy" then
		return 2
	else
		return 0
	end
end

local function get_formspec(meta)
	local formspec = "size[10,9]"..
		"list[current_player;main;0,5;8,4]"..
		"label[8,5;Disk]"..
		"list[context;disk;9,5;1,2]"..
		"label[8,6;Disk2:]"
	if has_disk(meta) > 0 then
		formspec = formspec..
			"button[0,0;3,1;disk;Disk]"..
			"button[3,0;3,1;data;Data]"
	end
	if has_disk(meta) == 0 then
		meta:set_int("tab", 0)
	end
	local tab = meta:get_int("tab")
	if tab == 1 then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		if has_disk(meta) == 1 then
			formspec=formspec..
				"textarea[0,1;10,3;text;Edit:;"..minetest.formspec_escape(stack:get_metadata()).."]"..
				"button[0,4;10,1;save;Save]"
		elseif has_disk(meta) == 2 then
			local list = ""
			local vfs = basiccomputers.load_vfs(stack)
			local file = meta:get_string("file")
			file = tonumber(file)
			local count = 0
			for name, _ in pairs(vfs.fs) do
				count = count + 1
				if count==file then
					file=name
				end
				if list == "" then
					list = list..minetest.formspec_escape(name)
				else
					list = list..","..minetest.formspec_escape(name)
				end
			end
			local cont
			if file and file ~= "" then
				cont = vfs:load(file)
			end
			cont = cont or ""
			print(file.."="..cont)
			formspec = formspec..
				"textlist[0,1;3,3;files;"..list..";;]"..
				"textarea[4,1;6,3;text;;"..minetest.formspec_escape(cont).."]"..
				"button[0,4;10,1;save;Save]"
		end
	elseif tab == 2 then

	end
	return formspec
end

local function receive_fields(pos, fields, player)
	local meta = minetest.get_meta(pos)
	if fields.data then
		meta:set_int("tab", 1)
	elseif fields.save then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		if has_disk(meta) == 1 then
			stack:set_metadata(fields.text)
		elseif has_disk(meta) == 2 then
			local vfs = basiccomputers.load_vfs(stack)
			local count=0
			local file = tonumber(meta:get_string("file"))
			for name, _ in pairs(vfs.fs) do
				count=count+1
				if count == file then
					file=name
					break
				end
			end
			if type(file) == "string" then
				vfs:save(file, fields.text)
			end
			stack = basiccomputers.save_vfs(stack, vfs)
		end
		inv:set_stack("disk", 1, stack)
	elseif fields.files then
		local res = fields.files
		local pre = string.sub(res, 1, 4)
		local file = string.sub(res, 5, -1)
		if pre == "DBL:" or pre == "CHG:" then
			meta:set_string("file", file)
		end
	end
	meta:set_string("formspec", get_formspec(meta))	
end

minetest.register_node("basiccomputers:disk_block", {
	description = "Disk Block",
	tiles = {"default_copper_block.png"},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_formspec(meta))
		meta:set_string("infotext", "Disk Block")
		meta:set_int("tab", 0)
		local inv = meta:get_inventory()
		inv:set_size("disk", 2)
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if inv:is_empty("disk") then
			return true
		else
			return false
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if is_disk(stack) then
			return stack:get_count()
		else
			return 0
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_formspec(meta))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_formspec(meta))
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		receive_fields(pos, fields, sender)
	end,
})
