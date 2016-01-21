local prev = "button[0,0;3,1;prev;Preview]"
local next = "button[6,0;3,1;next;Next]"
basiccomputers.books.book2 =
{
	"size[10,9]"..
		"label[0,1;"..[[ Generator Upgrade:
				Powers the Computers.
				Put fuel into fuel slot to power the computer.
				Has Functions:
				ENERGY():
					takes no parameter
					returns energy of current item as integer
				Crafts: ] ]]..
		basiccomputers.books.craft("generator", 3,4)..next,
	"size[10,9]"..
		"label[0,1;"..[[ Tape Upgrade:
				Saves and loads programs.
				Put tape into tape slot to save or load the program
				Commands:
				SAVE:
					takes no parameter and save program to tape
				LOAD:
					takes no parameter and loads program from tape
				Tapedrive: ] label[5,3;Tape:] ]]..
		basiccomputers.books.craft("tapedrive", 0,5)..
		basiccomputers.books.craft("tape", 5,5)..next..prev,
	"size[10,9]"..
		"label[0,1;".. [[ Floppy Upgrade:
				Saves and loads files.
				Put floppy into floppy slot to,
				save and load files.
				Commands:
					FOPEN <num>, <file>:
					num = file number,
					between 0 and 10
					file = the filename
					Opens the File.

					FCLOSE <num>
					Close the file.

					FWRITE <num>, <text>
					Writes text to file

					FPRINT <file>
					Prints the file. ] ]]..
		basiccomputers.books.craft("floppy_drive",5,2)..
		basiccomputers.books.craft("floppy",5,6)..next..prev,
	"size[10,9]"..
		"label[0,1;".. [[
					FLOAD <file>
					Loads file as program.

					FSAVE <file>
					Saves program as file

					CP <file>, <file>
					Copies file to file

					MV <file>, <file>
					Moves file to file

					LS
					Lists files

					RM <file>
					Deletes file
				Functions:
					FREAD(<num>)
					Reads file ] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[ The Owner Upgrades:
				Protects your computer.
				IF Owner Upgrade is in computer,
				only the player was put the upgrade into computer,
				can access inventory, destroy computer, clicks buttons
				Craft: ] ]]..
		basiccomputers.books.craft("owner", 3, 3)..prev..next,
}

basiccomputers.books.crafts.tape = {
	"default:stick", "default:paper", "default:stick",
	"", "","",
	"","","",
	"basiccomputers:tape"
}

basiccomputers.books.crafts.tapedrive = {
	"default:cobble", "", "default:cobble",
	"default:cobble", "default:torch", "default:cobble",
	"default:cobble", "default:cobble", "default:cobble",
	"basiccomputers:tape_drive"
}

basiccomputers.books.crafts.owner = {
	"", "default:sign_wall", "",
	"", "default:chest_locked", "",
	"","","",
	"basiccomputers:owner"
}
