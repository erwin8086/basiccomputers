basiccomputers.books = {}
local reading = {}
local function open_book(player, book)
	if book then
		local name = player:get_player_name()
		reading[name] = {}
		reading[name].book = book
		reading[name].site = 1
		minetest.show_formspec(name, "basiccomputers:book", book[1])
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "basiccomputers:book" then
		local name = player:get_player_name()
		if fields.next then
			if reading[name].book[reading[name].site+1] then
				reading[name].site = reading[name].site + 1
				minetest.show_formspec(name, "basiccomputers:book", reading[name].book[reading[name].site])
			end
		elseif fields.prev then
			if reading[name].book[reading[name].site-1] then
				reading[name].site = reading[name].site - 1
				minetest.show_formspec(name, "basiccomputers:book", reading[name].book[reading[name].site])
			end
		elseif fields.example then
			local inv = player:get_inventory()
			local stack = ItemStack("basiccomputers:floppy")
			local example = io.open(basiccomputers.path.."/example.img")
			stack:set_metadata(example:read("*all"))
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		end

	end
end)

function basiccomputers.books.craft(name, x, y)
		return "list[detached:basiccomputers_crafts;"..name..";"..x..","..y..";3,3]"..
		"list[detached:basiccomputers_crafts;"..name..";"..(x+4)..","..(y+1)..";1,1;9]"..
		"image["..(x+3)..","..(y+1)..";1,1;gui_furnace_arrow_bg.png^[transformR270]"
end

basiccomputers.books.inv = minetest.create_detached_inventory("basiccomputers_crafts", {
	allow_move = function(inv, from_list, from_index, to_list, to_index, count, player) 
		return 0
	end,
	allow_put = function(inv, listname, index, stack, player) 
		return 0
	end,
	allow_take = function(inv, listname, index, stack, player) 
		return 0
	end,
})

basiccomputers.books.crafts = {}

dofile(basiccomputers.path.."/book1.lua")
dofile(basiccomputers.path.."/book2.lua")
dofile(basiccomputers.path.."/book3.lua")
dofile(basiccomputers.path.."/book4.lua")

for name, list in pairs(basiccomputers.books.crafts) do
	basiccomputers.books.inv:set_list(name, list)
end

minetest.register_craftitem("basiccomputers:book1", {
	description = "Basiccomputers Beginers Guide",
	inventory_image = "default_book.png",
	on_use = function(stack, user, pt)
		open_book(user, basiccomputers.books.book1)
	end,
})

minetest.register_craftitem("basiccomputers:book2", {
	description = "Basiccomputers Upgrade Guide",
	inventory_image = "default_book.png",
	on_use = function(stack, user, pt)
		open_book(user, basiccomputers.books.book2)
	end,
})

minetest.register_craftitem("basiccomputers:book3", {
	description = "Basiccomputers and Mods",
	inventory_image = "default_book.png",
	on_use = function(stack, user, pt)
		open_book(user, basiccomputers.books.book3)
	end,
})
minetest.register_craftitem("basiccomputers:book4", {
	description = "Basiccomputers: Commands and Functions",
	inventory_image = "default_book.png",
	on_use = function(stack, user, pt)
		open_book(user, basiccomputers.books.book4)
	end,
})
