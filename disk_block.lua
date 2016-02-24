--[[
	The disk block.
	For Operations with disk.
]]

-- Is the stack a disk
local function is_disk(stack)
	if stack:get_name() == "basiccomputers:tape" then
		return true
	elseif stack:get_name() == "basiccomputers:floppy" then
		return true
	else
		return false
	end
end

-- Get type of the disk
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

-- Gets the formspec for disk block
local function get_formspec(meta)
	local input = meta:get_int("input")
	-- User input form
	if input and input > 0 then
		-- Base formspec
		local formspec = "size[10,9]"..
			"button[0,5;10,1;ok;OK]"
		-- Text input
		if input < 10 then
			formspec = formspec..
				"field[0,4;10,1;text;Input Filename:;]"
		-- File list
		elseif input == 10 then
			local list = ""
			local inv = meta:get_inventory()
			local stack = inv:get_stack("disk", 2)
			local vfs = basiccomputers.load_vfs(stack)
			for name, _ in pairs(vfs.fs) do
				if list=="" then
					list=minetest.formspec_escape(name)
				else
					list=list..","..minetest.formspec_escape(name)
				end
			end
			formspec = formspec..
				"textlist[0,0;10,5;files;"..list.."]"
		end
		
		return formspec
	end
	-- Normal view
	-- Base elements
	local formspec = "size[10,9]"..
		"list[current_player;main;0,5;8,4]"..
		"label[8,5;Disk]"..
		"list[context;disk;9,5;1,2]"..
		"label[8,6;Disk2:]"
	-- Admin button
	local admin = meta:get_int("admin")
	if admin and admin == 1 then
		formspec = formspec..
			"button[8,7;2,1;admin; Unset admin]"
	else
		formspec = formspec..
			"button[8,7;2,1;admin;Set admin]"
	end
	-- Base taps for all disk types
	if has_disk(meta) > 0 then
		formspec = formspec..
			"button[0,0;3,1;disk;Disk]"..
			"button[3,0;3,1;data;Data]"
	end
	-- Only for floppy
	if has_disk(meta) == 2 then
		formspec = formspec..
			"button[6,0;3,1;tabfiles;Files]"
	end
	-- No tab is open if no disk is in device
	if has_disk(meta) == 0 then
		meta:set_int("tab", 0)
	end
	local tab = meta:get_int("tab")
	-- The data tab
	if tab == 1 then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		-- For tape
		if has_disk(meta) == 1 then
			formspec=formspec..
				"textarea[0,1;10,3;text;Edit:;"..minetest.formspec_escape(stack:get_metadata()).."]"..
				"button[0,4;10,1;save;Save]"
		-- For floppy
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
			formspec = formspec..
				"textlist[0,1;3,3;files;"..list..";"..meta:get_int("file")..";]"..
				"textarea[4,1;6,3;text;;"..minetest.formspec_escape(cont).."]"..
				"button[0,4;10,1;save;Save]"
		end
	-- The disk tab
	elseif tab == 2 then
		-- For tape
		if has_disk(meta) == 1 then
			formspec = formspec..
				"button[0,1;3,1;dcopy;Diskcopy]"..
				"button[3,1;3,1;format;Format]"
		-- For floppy
		else
			local inv = meta:get_inventory()
			local stack = inv:get_stack("disk", 1)
			local vfs = basiccomputers.load_vfs(stack)
			local readonly = "false"
			if vfs.readonly then
				readonly = "true"
			end
			local nowrite = "false"
			if vfs.nowrite then
				nowrite = "true"
			end
			formspec = formspec..
				"label[0,1;Size: "..vfs.size.."\nFree: "..vfs.size-vfs:get_size().." Used: "..vfs:get_size().."]"..
				"label[0,2;Readonly: "..readonly.."\n".."Nowrite: "..nowrite.."]"..
				"button[3,1;3,1;dcopy;Diskcopy]"..
				"button[3,2;3,1;format;Format]"..
				"button[0,3;3,1;readonly;RO:"..readonly.."]"..
				"button[3,3;3,1;nowrite;NW:"..nowrite.."]"
		end
	-- The files tab only for floppy
	elseif tab == 3 then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		local vfs = basiccomputers.load_vfs(stack)
		local files = ""
		for name, _ in pairs(vfs.fs) do
			if files == "" then
				files=minetest.formspec_escape(name)
			else
				files=files..","..minetest.formspec_escape(name)
			end
		end
		formspec = formspec..
			"textlist[0,1;3,4;files;"..files..";"..meta:get_int("file")..";]"..
			"button[3,1;3,1;new;New]"..
			"button[6,1;3,1;rm;Delete]"..
			"button[3,2;3,1;mv;Move]"..
			"button[6,2;3,1;cp;Copy]"..
			"button[3,3;3,1;tdisk;To Disk2]"..
			"button[6,3;3,1;fdisk;From Disk2]"..
			"button[3,4;3,1;ttape;To Tape]"..
			"button[6,4;3,1;ftape;From Tape]"
	end
	return formspec
end

-- Check actions for disk
local function receive_fields(pos, fields, player)
	local meta = minetest.get_meta(pos)
	-- Tab buttons:
	if fields.data then
		meta:set_int("tab", 1)
	elseif fields.disk then
		meta:set_int("tab", 2)
	elseif fields.tabfiles then
		meta:set_int("tab", 3)
	-- New file
	elseif fields.new then
		meta:set_int("input", 1)
	-- To Disk
	elseif fields.tdisk then
		local inv = meta:get_inventory()
		local dest = inv:get_stack("disk", 2)
		if not dest:get_name() == "basiccomputers:floppy" then
			return
		end
		local src = inv:get_stack("disk", 1)
		local svfs = basiccomputers.load_vfs(src)
		local dvfs = basiccomputers.load_vfs(dest)
		local count = 0
		local file = tonumber(meta:get_string("file"))
		for name, _ in pairs(svfs.fs) do
			count = count + 1
			if count == file then
				file=name
				break
			end
		end
		dvfs:save(file, svfs:load(file))
		dest = basiccomputers.save_vfs(dest, dvfs)
		inv:set_stack("disk", 2, dest)
	-- From disk
	elseif fields.fdisk then
		meta:set_int("input", 10)
	-- From tape
	elseif fields.ftape then
		meta:set_int("input", 2)
	-- To Tape
	elseif fields.ttape then
		local inv = meta:get_inventory()
		local dest = inv:get_stack("disk", 2)
		local src = inv:get_stack("disk", 1)
		local svfs = basiccomputers.load_vfs(src)
		local count = 0
		local file = tonumber(meta:get_string("file"))
		for name, _ in pairs(svfs.fs) do
			count = count + 1
			if count == file then
				file=name
				break
			end
		end
		if dest:get_name() == "basiccomputers:tape" then
			if svfs:load(file) then
				dest:set_metadata(svfs:load(file))
			end
			inv:set_stack("disk", 2, dest)
		elseif meta:get_int("admin") == 1 then
			dest = ItemStack("basiccomputers:tape")
			if svfs:load(file) then
				dest:set_metadata(svfs:load(file))
			end
			inv:set_stack("disk", 2, dest)
		end
	-- Copy file
	elseif fields.cp then
		meta:set_int("input", 3)
	-- Rename file
	elseif fields.mv then
		meta:set_int("input", 4)
	-- Remove file
	elseif fields.rm then
		local file = tonumber(meta:get_string("file"))
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		local vfs = basiccomputers.load_vfs(stack)
		local count=0
		for name, _ in pairs(vfs.fs) do
			count = count + 1
			if count == file then
				file=name
				break
			end
		end
		vfs:rm(file)
		stack = basiccomputers.save_vfs(stack, vfs)
		inv:set_stack("disk", 1, stack)
	-- Ok button in input view
	elseif fields.ok then
		local inv = meta:get_inventory()
		local src = inv:get_stack("disk", 1)
		local dest = inv:get_stack("disk", 2)
		local svfs = basiccomputers.load_vfs(src)
		local text = fields.text
		local dvfs
		if dest:get_name() == "basiccomputers:floppy" then
			dvfs = basiccomputers.load_vfs(dest)
		end
		local file = tonumber(meta:get_string("file"))
		local count = 0
		for name, _ in pairs(svfs.fs) do
			count = count + 1
			if count == file then
				file=name
				break
			end
		end
		local mode = meta:get_int("input")
		-- New file
		if mode == 1 then
			if text then
				svfs:save(text, "NEW")
			end
		-- From Tape
		elseif mode == 2 then
			if text and dest:get_name() == "basiccomputers:tape" then
				svfs:save(text, dest:get_metadata())
			end
		-- Copy File
		elseif mode == 3 then
			if text then
				svfs:cp(file, text)
			end
		elseif mode == 4 then
			if text then
				svfs:mv(file, text)
			end
		-- From disk2
		elseif mode == 10 then
			if dvfs then
				local file = tonumber(meta:get_string("file"))
				local count = 0
				for name, _ in pairs(dvfs.fs) do
					count = count + 1
					if count == file then
						file = name
						break
					end
				end
				svfs:save(file, dvfs:load(file))
			end
		end
		src = basiccomputers.save_vfs(src, svfs)
		if dvfs then
			dest = basiccomputers.save_vfs(dest, dvfs)
		end
		inv:set_stack("disk", 1, src)
		inv:set_stack("disk", 2, dest)
		meta:set_int("input", 0)
	-- Save on data tab
	elseif fields.save then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		-- Tape
		if has_disk(meta) == 1 then
			stack:set_metadata(fields.text)
		-- Floppy
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
	-- Copy disk
	elseif fields.dcopy then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		local dest = inv:get_stack("disk", 2)
		if has_disk(meta) == 1 then
			if dest:get_name() == "basiccomputers:tape" then
				dest:set_metadata(stack:get_metadata())
			else
				if meta:get_int("admin") == 1 then
					dest = ItemStack("basiccomputers:tape")
					dest:set_metadata(stack:get_metadata())
				else
					minetest.chat_send_player(player:get_player_name(), "Error no Tape in dest slot")
				end
			end
		else
			local vfs = basiccomputers.load_vfs(stack)
			vfs.readonly = nil
			vfs.nowrite = nil
			if dest:get_name() == "basiccomputers:floppy" then
				local dvfs = basiccomputers.load_vfs(dest)
				if not dvfs.readonly and not dvfs.nowrite then
					dest = basiccomputers.save_vfs(dest, vfs)
				else
					minetest.chat_send_player(player:get_player_name(), "Error disk write-protected")
				end
			else
				if meta:get_int("admin") == 1 then
					dest = ItemStack("basiccomputers:floppy")
					dest = basiccomputers.save_vfs(dest, vfs)
				else
					minetest.chat_send_player(player:get_player_name(), "Error no floppy in dest slot")
				end
			end
		end
		inv:set_stack("disk", 2, dest)
	-- Format disk or tape
	elseif fields.format then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		if has_disk(meta) == 1 then
			stack:set_metadata("")
		else
			local vfs = basiccomputers.load_vfs(stack)
			if not vfs.nowrite and not vfs.readonly then
				stack:set_metadata("")
			end
		end
		inv:set_stack("disk", 1, stack)
	-- Set or reset readonly
	elseif fields.readonly then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		local vfs = basiccomputers.load_vfs(stack)
		if vfs.readonly then
			vfs:set_readwrite()
		else
			vfs:set_readonly()
		end
		stack = basiccomputers.save_vfs(stack, vfs)
		inv:set_stack("disk", 1, stack)
	-- Set or reset(if admin) nowrite
	elseif fields.nowrite then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		local vfs = basiccomputers.load_vfs(stack)
		if vfs.nowrite then
			if meta:get_int("admin") == 1 then
				vfs.nowrite = false
			else
				minetest.chat_send_player(player:get_player_name(), "Error only player with basiccomputers_admin privilege can unset nowrite")
			end
		else
			vfs.nowrite = true
		end
		stack = basiccomputers.save_vfs(stack, vfs)
		inv:set_stack("disk", 1, stack)
	-- Set or reset admin. If player has priv.
	elseif fields.admin then
		if minetest.get_player_privs(player:get_player_name()).basiccomputers_admin then
			if meta:get_int("admin") == 1 then
				meta:set_int("admin", 0)
			else
				meta:set_int("admin", 1)
			end
		else
			minetest.chat_send_player(player:get_player_name(), "Error you have not the basiccomputers_admin privilege")
		end
	-- Set file open in data tab		
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


-- The disk block
minetest.register_node("basiccomputers:disk_block", {
	description = "Disk Block",
	tiles = {"default_copper_block.png"},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_formspec(meta))
		meta:set_string("infotext", "Disk Block")
		meta:set_int("tab", 0)
		meta:set_int("file", 0)
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
