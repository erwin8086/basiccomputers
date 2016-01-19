local prev = "button[0,0;3,1;prev;Preview]"
local next = "button[6,0;3,1;next;Next]"
basiccomputers.books.book1 = {
	"size[10,9]"..
		"label[0,1;"..[[ Computer Beginers Guide
			Computers are Blocks thats Programmable in BASIC
			Computers needs power to work
			While Computer is running it uses power(100eu/t)
			Computers are craftet: ]].."]"..
		basiccomputers.books.craft("computer", 3, 3)..next..
		"label[0,6;"..[[ Computers can placed.
			Computers has 4 slots.
			This are The Upgrade slots
			Put Upgrades into it to extend Computer
			Upgrades described in book2 ]].."]",
	"size[10,9]"..
		"label[0,1;".. [[ Computers only works with power
				Power can supplied with an Generator Upgrade(default),
				an Battery Upgrade(technic) and an LV cable connected(min 500eu peak)
				For now whe use a Generator Upgrade they craftet:]].."]"..
		basiccomputers.books.craft("generator", 3, 3)..next..prev..
		"label[0,6;"..[[ Put this Upgrade into an Upgrade slot in Computer
				and add Fuel in the new slot,
				then click start to start the Computer]].."]",
	"size[10,9]"..
		"label[0,1;".. [[ Now whe ready to type our first program
				Type into Computer: EDIT
				then click OK: your Computer switch to Edit mode
				Now Enter:
				10 PRINT "HELLO"
				20 GOTO 10

				And Click Save. Your program is now in computer
				Type into Computer: RUN. And click OK
				then the program runs and print out HELLO
				Click the Kill button to end the program ]].."]"..prev..next,
	"size[10,9]label[0,1;"..[[
				Now let us analyse the program:
				10 PRINT "HELLO"
				10 are the linenumber:
				The Computer runs the lower number first
				PRINT are the command:
				It outputs text to the screen
				"HELLO" are the parameter:
				A command can have paramters,
				The parameter can from type integer and string.
				integers are numbers without decimals
				strings are character sequences
				Now Line two:
				20 are the linenumber
				GOTO are the command
				10 are the parameter
				GOTO switches the line: in our case to 10
				Now type into Computer: LIST (And click OK)
				The Computer lists the programm ]].."]"..next..prev,
	"size[10, 9]"..
		"label[0,1;".. [[ Computers can have disks:
				Two types of disk availible: Tapes and Floppies
				Tapes are described in book2
				Now whe wold use Floppies.
				Let us craft a Floppydrive: ]].."]"..
		basiccomputers.books.craft("floppy_drive", 5, 2)..
		"label[0,5;And a Floppy:]"..
		basiccomputers.books.craft("floppy", 3, 6)..prev..next,
	"size[10,9]"..
		"label[0,1;".. [[ Now put the Floppydrive into Computer
				Note that the Computer must be stoped with the Halt button
				With the Floppydrive whe cold save and load programs from floppy
				Put the crafted floppy into floppy slot
				You cold use FSAVE "name" to save your program
				and FLOAD "name" to load your program.
				Last but not least there is a example floppy
				with demo programs click button to get floppy:]
		button[3,5;5,1;example;Get Example Disk] ]]..next..prev,

}
basiccomputers.books.crafts.computer = {
	"default:cobble", "default:cobble", "default:cobble",
	"default:cobble", "default:torch", "default:cobble",
	"default:cobble", "default:glass", "default:cobble",
	"basiccomputers:computer" }
basiccomputers.books.crafts.generator = {
	"default:cobble", "default:coal_lump", "default:cobble",
	"default:cobble", "default:torch", "default:cobble",
	"default:cobble", "default:furnace", "default:cobble",
	"basiccomputers:generator"
}
basiccomputers.books.crafts.floppy = {
	"", "default:coal_lump", "",
	"", "default:paper", "", 
	"", "", "",
	"basiccomputers:floppy"
}

basiccomputers.books.crafts.floppy_drive = {
	"default:stone", "", "default:stone",
	"default:stone", "default:copper_ingot", "default:stone",
	"default:stone", "default:stone", "default:stone",
	"basiccomputers:floppy_drive" }
