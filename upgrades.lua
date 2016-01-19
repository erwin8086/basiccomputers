basic.funcs.ENERGY = function(self, arg)
	local meta = minetest.get_meta(self.pos)
	local energy = meta:get_int("energy")
	return energy or 0
end

function basiccomputers.is_power(meta)
	return basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:power"))
end

basic.cmds.WAIT = function(self, arg)
	local meta = minetest.get_meta(self.pos)
	local time = arg[1]
	if time and type(time)=="number" then
		meta:set_int("wait", time)
	end
end
basic.cmds.SLEEP = function(self, arg)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_power(meta) then
		local time = arg[1]
		if time and type(time)=="number" then
			meta:set_int("sleep", time)
		end
	else
		self:error("Requires Power Upgrade")
	end
end
basic.cmds.STANDBY = function(self, arg)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_power(meta) then
		local time = arg[1]
		if time and type(time)=="number" then
			meta:set_int("standby", time*60)
		end
	else
		self:error("Requires Power Upgrade")
	end
end

local function no_power(pos)
	meta:set_int("wait", 0)
	meta:set_int("sleep", 0)
	meta:set_int("standby", 0)
	basiccomputers.stop_computer(pos)
end

local old_on_calc = basiccomputers.on_calc
function basiccomputers.on_calc(pos)
	local meta = minetest.get_meta(pos)
	local wait = meta:get_int("wait") or 0
	if wait > 0 then
		if not basiccomputers.get_power(meta, 85) then
			no_power(pos)
			return true
		end
		meta:set_int("wait", wait-1)
		return true
	elseif basiccomputers.is_power(meta) then
		local sleep = meta:get_int("sleep") or 0
		local standby = meta:get_int("standby") or 0
		if sleep > 0 then
			if not basiccomputers.get_power(meta, 40) then
				no_power(pos)
				return true
			end
			meta:set_int("sleep", sleep-1)
			return true
		elseif standby > 0 then
			if not basiccomputers.get_power(meta, 7) then
				no_power(pos)
				return true
			end
			meta:set_int("standby", standby-1)
			return true
		end
	end

	if old_on_calc then
		return old_on_calc(pos)
	end
end

local old_start = basiccomputers.on_start
function basiccomputers.on_start(pos, player, start)
	local meta = minetest.get_meta(pos)
	meta:set_int("wait", 0)
	meta:set_int("sleep", 0)
	meta:set_int("standby", 0)
end

function basiccomputers.get_power(meta, power)
	if basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:generator")) then
		local energy = meta:get_int("energy")
		if not energy then
			return false
		end
		if not power then
			return false
		end
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

function basiccomputers.get_upgrade_inv(meta, formspec)
	if basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:generator")) then
		formspec = formspec..
			"label[8,6;Fuel:]"..
			"list[context;fuel;9,6;1,1]"
	end
	if basiccomputers.is_tape(meta) then
		formspec = formspec..
			"label[8,7;Tape:]"..
			"list[context;tape;9,7;1,1]"
	end
	if basiccomputers.is_floppy(meta) then
		formspec = formspec..
			"label[8,8;Floppy:]"..
			"list[context;disk;9,8;1,1]"
	end
	return formspec
end

function basiccomputers.is_upgrade(upgrade)
	if upgrade:get_name() == "basiccomputers:generator" then
		return true
	elseif upgrade:get_name() == "basiccomputers:tape_drive" then
		return true
	elseif upgrade:get_name() == "basiccomputers:floppy_drive" then
		return true
	elseif upgrade:get_name() == "basiccomputers:power" then
		return true
	else
		return false
	end
end

function basiccomputers.has_upgrade(meta, upgrade)
	local inv = meta:get_inventory()
	if inv:contains_item("upgrades", upgrade) then
		return true
	else
		return false
	end
end

function basiccomputers.is_tape(meta)
	return basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:tape_drive"))
end

function basiccomputers.is_floppy(meta)
	return basiccomputers.has_upgrade(meta, ItemStack("basiccomputers:floppy_drive"))
end

function basiccomputers.upgrade_put(pos, stack, player)
	if basiccomputers.is_upgrade(stack) then
		return stack:get_count()
	end
	return 0
end
function basiccomputers.upgrade_take(pos, stack, player)
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
	elseif stack:get_name() == "basiccomputers:floppy_drive" then
		if inv:is_empty("disk") then
			return stack:get_count()
		else
			return 0
		end
	else
		return stack:get_count()
	end
		
end

local basic = basiccomputers.basic
local vfs = basiccomputers.vfs

basic.cmds.SAVE = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_tape(meta) then
		local inv = meta:get_inventory()
		stack = inv:get_stack("tape",1)
		if stack:get_name() == "basiccomputers:tape" then
			local prg = self.cli.prg2str(self)
			stack:set_metadata(prg)
			inv:set_stack("tape",1,stack)
		else
			self:error("No Tape")
		end
	else
		self:error("No Tapedrive")
	end
end

basic.cmds.LOAD = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_tape(meta) then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("tape",1)
		if stack:get_name() == "basiccomputers:tape" then
			local prg = stack:get_metadata()
			if prg then
				self.program = {}
				self.cli.str2prg(self, prg)
			end
		else
			self:error("No Tape")
		end
	else
		self:error("No Tapedrive")
	end
end

local function load_vfs(stack)
	local v = vfs:new()
	local saved = minetest.deserialize(stack:get_metadata())
	v:from_table(saved)
	v:set_size(4096)
	return v
end
basiccomputers.load_vfs=load_vfs

local function save_vfs(stack, v)
	local save = v:to_table()
	stack:set_metadata(minetest.serialize(save))
	print(minetest.serialize(save))
	return stack
end
basiccomputers.save_vfs=save_vfs

function basiccomputers.disk_remove(stack)
	if stack:get_name() == "basiccomputers:floppy" then
		local vfs = load_vfs(stack)
		vfs:close_all()
		return save_vfs(stack, vfs)
	end
end



basic.cmds.FOPEN = function(self, args)
	local id = args[1]
	local name = args[2]
	if id and name and type(id) == "number" and type(name) == "string" then
		if id < 10 and id >= 0 then
			local meta = minetest.get_meta(self.pos)
			if basiccomputers.is_floppy(meta) then
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
			if basiccomputers.is_floppy(meta) then
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
			if basiccomputers.is_floppy(meta) then
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

basic.cmds.LS = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_floppy(meta) then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		if stack:get_name() == "basiccomputers:floppy" then
			local vfs = load_vfs(stack)
			local function print(text)
				self:print(text)
			end
			vfs:list(print)
		else
			self:error("No Floppy")
		end
	else
		self:error("No Floppydrive")
	end
end

basic.cmds.CP = function(self, args)
	local f1 = args[1]
	local f2 = args[2]
	if f1 and f2 and type(f1) == "string" and type(f2) == "string" then
		local meta = minetest.get_meta(self.pos)
		if basiccomputers.is_floppy(meta) then
			local inv = meta:get_inventory()
			local stack = inv:get_stack("disk", 1)
			if stack:get_name() == "basiccomputers:floppy" then
				local vfs = load_vfs(stack)
				vfs:cp(f1, f2)
				stack = save_vfs(stack, vfs)
				inv:set_stack("disk", 1, stack)
			else
				self:error("No Floppy")
			end
		else
			self:error("No Floppydrive")
		end
	else
		self:error("Inkorrect Parameter")
	end
end

basic.cmds.MV = function(self, args)
	local f1 = args[1]
	local f2 = args[2]
	if f1 and f2 and type(f1) == "string" and type(f2) == "string" then
		local meta = minetest.get_meta(self.pos)
		if basiccomputers.is_floppy(meta) then
			local inv = meta:get_inventory()
			local stack = inv:get_stack("disk", 1)
			if stack:get_name() == "basiccomputers:floppy" then
				local vfs = load_vfs(stack)
				vfs:mv(f1, f2)
				stack = save_vfs(stack, vfs)
				inv:set_stack("disk", 1, stack)
			else
				self:error("No Floppy")
			end
		else
			self:error("No Floppydrive")
		end
	else
		self:error("Inkorrect Parameter")
	end
end

basic.cmds.FCLOSE = function(self, args)
	local id = args[1]
	if id and type(id) == "number" then
		if id < 10 and id >= 0 then
			local meta = minetest.get_meta(self.pos)
			if basiccomputers.is_floppy(meta) then
				local inv = meta:get_inventory()
				local stack = inv:get_stack("disk", 1)
				if stack:get_name() == "basiccomputers:floppy" then
					local vfs = load_vfs(stack)
					vfs:close(id)
					stack = save_vfs(stack, vfs)
					inv:set_stack("disk", 1, stack)
				else
					self:error("No Floppy")
				end
			else
				self:error("No Floppydrive")
			end
		else
			self:error("Id must between 0 and 10")
		end
	else
		self:error("Inkorrect Parameter")
	end
end

basic.cmds.FPRINT = function(self, args)
	local fname = args[1]
	if fname and type(fname) == "string" then
		local meta = minetest.get_meta(self.pos)
		if basiccomputers.is_floppy(meta) then
			local inv = meta:get_inventory()
			local stack = inv:get_stack("disk", 1)
			if stack:get_name() == "basiccomputers:floppy" then
				local vfs = load_vfs(stack)
				local function print(text)
					self:print(text)
				end
				vfs:cat(fname, print)
			else
				self:error("No Floppy")
			end
		else
			self:error("No Floppydrive")
		end
	else
		self:error("Inkorrekt Paramter")
	end
end

function basic.funcs.FSTAT(self, args)
	local mode = args[1]
	if (not mode) or (not type(mode) == "string") then
		self:error("No Mode, modes:free, used, size, readonly, nowrite")
		return 0
	end
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_floppy(meta) then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		if stack:get_name() == "basiccomputers:floppy" then
			local vfs = load_vfs(stack)
			if mode == "free" then
				return vfs.size-vfs:get_size()
			elseif mode == "used" then
				return vfs:get_size()
			elseif mode == "size" then
				return vfs.size
			elseif mode == "readonly" then
				if vfs.readonly then
					return 1
				end
			elseif mode == "nowrite" then
				if vfs.nowrite then
					return 1
				end
			else
				self:error("Unkown Mode")
			end
		else
			self:error("No Floppy")
		end
	else
		self:error("No Floppydrive")
	end
	return 0
end

minetest.register_craft({
	recipe = {{"basiccomputers:floppy"}},
	output = "basiccomputers:floppy",
})

minetest.register_on_craft(function(stack, player, old_craft_grid, craft_inv)
	if stack:get_name() == "basiccomputers:floppy" then
		for _, old in ipairs(old_craft_grid) do
			if old and old:get_name() == "basiccomputers:floppy" then
				local vfs = load_vfs(old)
				if not vfs.readonly then
					vfs:set_readonly()
				else
					vfs:set_readwrite()
				end
				return save_vfs(stack, vfs)
			end
		end
	end
end)

basic.cmds.RM = function(self, args)
	local f = args[1]
	if f and type(f) == "string" then
		local meta = minetest.get_meta(self.pos)
		if basiccomputers.is_floppy(meta) then
			local inv = meta:get_inventory()
			local stack = inv:get_stack("disk", 1)
			if stack:get_name() == "basiccomputers:floppy" then
				local vfs = load_vfs(stack)
				vfs:rm(f)
				stack = save_vfs(stack, vfs)
				inv:set_stack("disk", 1, stack)
			else
				self:error("No Floppy")
			end
		else
			self:error("No Floppydrive")
		end
	else
		self:error("Inkorrect parameter")
	end
end

basic.cmds.FSAVE = function(self, args)
	local f = args[1]
	if f and type(f) == "string" then
		local meta = minetest.get_meta(self.pos)
		if basiccomputers.is_floppy(meta) then
			local inv = meta:get_inventory()
			local stack = inv:get_stack("disk", 1)
			if stack:get_name() == "basiccomputers:floppy" then
				local vfs = load_vfs(stack)
				vfs:save(f, self.cli.prg2str(self))
				stack = save_vfs(stack, vfs)
				inv:set_stack("disk", 1, stack)
			else
				self:error("No Floppy")
			end
		else
			self:error("No Floppydrive")
		end
	else
		self:error("Inkorrect parameter")
	end
end

basic.cmds.FLOAD = function(self, args)
	local f = args[1]
	if f and type(f) == "string" then
		local meta = minetest.get_meta(self.pos)
		if basiccomputers.is_floppy(meta) then
			local inv = meta:get_inventory()
			local stack = inv:get_stack("disk", 1)
			if stack:get_name() == "basiccomputers:floppy" then
				local vfs = load_vfs(stack)
				self.program = {}
				self.cli.str2prg(self, vfs:load(f))
			else
				self:error("No Floppy")
			end
		else
			self:error("No Floppydrive")
		end
	else
		self:error("Inkorrect parameter")
	end
end

-- Sets Disk as Example Disk
basic.cmds.FEXAMPLE = function(self, args)
	local meta = minetest.get_meta(self.pos)
	if basiccomputers.is_floppy(meta) then
		local inv = meta:get_inventory()
		local stack = inv:get_stack("disk", 1)
		if stack:get_name() == "basiccomputers:floppy" then
			local vfs = load_vfs(stack)
			vfs:set_readonly()
			vfs.nowrite = true
			stack = save_vfs(stack, vfs)
			local example = io.open(basiccomputers.path.."/example.img", "w")
			example:write(stack:get_metadata())
		else
			self:error("No Floppy")
		end
	else
		self:error("No Floppydrive")
	end
end

minetest.register_chatcommand("example_floppy", {
	params = "",
	description = "Gets a Floppy with example Programms",
	privs = {shout=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local inv = player:get_inventory()
			local stack = ItemStack("basiccomputers:floppy")
			local example = io.open(basiccomputers.path.."/example.img")
			stack:set_metadata(example:read("*all"))
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		end

end})

minetest.register_craftitem("basiccomputers:power", {
	description = "Power Upgrade",
	inventory_image = "default_wood.png",
})
