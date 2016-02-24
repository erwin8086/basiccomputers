minetest.register_craft({
	output = "basiccomputers:computer",
	recipe = {
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "default:torch", "default:cobble"},
		{"default:cobble", "default:glass", "default:cobble"}
	}
})

minetest.register_craft({
	output = "basiccomputers:generator",
	recipe = {
		{"default:cobble", "default:coal_lump", "default:cobble"},
		{"default:cobble", "default:torch", "default:cobble"},
		{"default:cobble", "default:furnace", "default:cobble"}
	}
})

minetest.register_craft({
	output = "basiccomputers:floppy_drive",
	recipe = {
		{"default:stone", "", "default:stone"},
		{"default:stone", "default:copper_ingot", "default:stone"},
		{"default:stone", "default:stone", "default:stone"}
	}
})

minetest.register_craft({
	output = "basiccomputers:floppy",
	recipe = {
		{"default:coal_lump"},
		{"default:paper"}
	}
})

minetest.register_craft({
	output = "basiccomputers:tape_drive",
	recipe = {
		{"default:cobble", "", "default:cobble"},
		{"default:cobble", "default:torch", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"}
	}
})

minetest.register_craft({
	output = "basiccomputers:tape",
	recipe = {
		{"group:stick", "default:paper", "group:stick"}
	}
})

minetest.register_craft({
	output = "basiccomputers:owner",
	recipe = {
		{"default:sign_wall"},
		{"default:chest_locked"}
	}
})

minetest.register_craft({
	output = "basiccomputers:chat",
	recipe = {
		{"default:sign_wall"},
		{"default:paper"}
	}
})

minetest.register_craft({
	output = "basiccomputers:command",
	recipe = {
		{"basiccomputers:chat"},
		{"default:mese_crystal"}
	}
})

minetest.register_craft({
	output = "basiccomputers:loader",
	recipe = {
		{"default:wood", ""},
		{"default:wood", ""},
		{"default:mese_crystal", "default:wood"}
	}
})

minetest.register_craft({
	output = "basiccomputers:disk_block",
	recipe = {
		{"default:wood", "basiccomputers:floppy", "default:wood"},
		{"default:wood", "basiccomputers:floppy_drive", "default:wood"},
		{"default:wood", "default:wood", "default:wood"}
	}
})

minetest.register_craft({
	output = "basiccomputers:book1",
	recipe = {
		{"basiccomputers:computer"},
		{"default:book"}
	}
})

minetest.register_craft({
	output = "basiccomputers:book2",
	recipe = {
		{"basiccomputers:book1"}
	}
})

minetest.register_craft({
	output = "basiccomputers:book3",
	recipe = {
		{"basiccomputers:book2"}
	}
})

minetest.register_craft({
	output = "basiccomputers:book4",
	recipe = {
		{"basiccomputers:book3"}
	}
})

minetest.register_craft({
	output = "basiccomputers:book1",
	recipe = {
		{"basiccomputers:book4"}
	}
})



if technic then
	minetest.register_craft({
		output = "basiccomputers:battery",
		recipe = {
			{"technic:battery"},
			{"default:wood"}
		}
	})
end

if digiline then
	minetest.register_craft({
		output = "basiccomputers:digiline",
		recipe = {
			{"digilines:wire_std_00000000"},
			{"default:wood"}
		}
	})
end
