local prev = "button[0,0;3,1;prev;Preview]"
local next = "button[6,0;3,1;next;Next]"
basiccomputers.books.book3 = {
	"size[10,9]"..
		"label[0,1;"..[[ Basiccomputers and Mods:
				Basiccomputers can interact with the follow Mods:
				* technic
				* digiline
				The Support for these Mods,
				including Upgrades and Functions only avilable if
				these mods are loaded. ] ]]..next,
	"size[10,9]"..
		"label[0,1;"..[[ technic powering:
				Basiccomputers can powered via technic LV cables

				technic batterys:
				Basiccomputers can powered via battery (and the Crystals),
				when a battery upgrade is into Upgrade slot.
				Functions:
				ENERGY() - gets energy saved in battery
				Battery upgrades cannot combined with generator upgrades.
				Battery upgrades craft: ] ]]..
		basiccomputers.books.craft("battery", 3, 5)..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[ digiline connections:
				Basiccomputers can send and receive via digilines.
				These functions require the digiline Upgrade.
				Commands:
				DIGILINE chan, msg - Sends Digiline message
				Functions:
				DIGILINE(type)
				if type == "channel" returns last received channel
				if type == "message" returns last received message
				ISDIGILINE() - Return 1 if message is in buffer
				Craft:] ]]..
		basiccomputers.books.craft("digiline", 3, 5)..prev,
				

}

basiccomputers.books.crafts.battery = {
	"", "technic:battery", "",
	"", "default:wood", "",
	"", "", "",
	"basiccomputers:battery"
}

basiccomputers.books.crafts.digiline = {
	"", "digilines:wire_std_00000000", "",
	"", "default:wood", "",
	"","","",
	"basiccomputers:digiline"
}
