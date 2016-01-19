basiccomputers.books = {}
local reading = {}
local function open_book(player, book)
	local name = player:get_player_name()
	reading[name] = {}
	reading[name].book = book
	reading[name].site = 1
	minetest.show_formspec(name, "basiccomputers:book", book[1])
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "basiccomputers:book" then
		local name = player:get_player_name()
		if fields.next then
			reading[name].site = reading[name].site + 1
			minetest.show_formspec(name, "basiccomputers:book", reading[name].book[reading[name].site])
		elseif fields.prev then
			reading[name].site = reading[name].site - 1
			minetest.show_formspec(name, "basiccomputers:book", reading[name].book[reading[name].site])
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


for name, list in pairs(basiccomputers.books.crafts) do
	basiccomputers.books.inv:set_list(name, list)
end

minetest.register_craftitem("basiccomputers:book1", {
	description = "Basiccomputers Beginers Guide",
	inventory_image = "default_wood.png",
	on_use = function(stack, user, pt)
		open_book(user, basiccomputers.books.book1)
	end,
})
