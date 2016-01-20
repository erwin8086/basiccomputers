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
				For now whe use a Generator Upgrade, they craftet:]].."]"..
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
	"size[10,9]"..
		"label[0,1;".. [[ Now let us read from input use READ()
				READ() is a function, functions are used for
				get parameters of commands. Now let use type: EDIT
				Click ok to run the editor.
				Now type into editor:
				10 PRINT READ()
				20 GOTO 10

				Click save and then type RUN (and click ok).
				The programs has no output.
				Let us type HELLO (and click ok).
				The program outputs HELLO.
				The function READ returns the input or ""
				Now stop the program use kill. ] ]]..prev..next,
	"size[10,9]"..
		"label[0,1;".. [[ Now let us calc
				Type EDIT into computer and click ok.
				Type into editor:
				10 PRINT 5*5
				20 PRINT 5+5
				30 PRINT 5-1
				40 PRINT 5/2
				50 PRINT 5*(2+2)

				Click save and then type RUN (and click ok)
				The computer prints the result. ]].."]"..next..prev,
	"size[10,9]"..
		"label[0,1;".. [[ Now let us save integers for later
				Type EDIT into computer and click ok
				Type into editor:
				10 LET "A", 0
				20 PRINT A
				30 LET "A", A+1
				40 GOTO 20

				Click save and type RUN (and click ok)
				The computer counts from 0  upwards.

				The command LET saves the integer as variable,
				its read only the first char from variablename,
				then saves the number in parameter 2 into the variable,
				its works only with integers.
				Now click kill to end the program]].."]"..next..prev,
	"size[10,9]"..
		"label[0,1;".. [[ Now let us save strings as variable
				For save of strings a command and a function exist:
				STR and STR().
				STR saves the string and
				STR() gets the string.
				Now let us type EDIT (and click ok)
				Type into Editor:
				10 STR "HELLO"
				20 PRINT STR()

				Type RUN (and click ok).
				The program prints HELLO one times.
				The command STR accepts one parameter,
				this is the string saved.
				The function STR() accepts no parameter,
				it return the string saved by STR.] ]]..prev..next,
	"size[10,9]"..
		"label[0,1;".. [[ Now let us check conditions
				A new Command described: IF
				IF two one or four parameters.
				Type EDIT (and click ok)
				Type into editor:
				10 LET "A", 0
				20 PRINT A
				30 LET "A", A+1
				40 IF A, "<", 3, 20
				
				Type RUN (and click ok)
				The program prints numbers from 0 to 2.] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[IF parameters:
				IF with four parameters:
				first parameter a value to check
				secount parameter the mode
				third parameter the secount value
				fourth parameter the line to jump
				mode can be:
					"==" jumps if first value equals secound value
					"<>" jumps if first value not equals secound value
					">" jumps if first value greater than secound value
					"<" jumps if first value smaller than secound value
					">=" jumps if first value greater or equals to secound value
					"<=" jumps if first value smaller or equals to secound value
				In two parameter mode the parameter represents the follow:
					first parameter is the value
					secound parameter is the line to jump
				If first parameter greater zero it jumps] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[ There also loops: FOR and DO
				The FOR loop:
				example:
				10 FOR "A", 0,10
				20 PRINT A
				30 NEXT
				FOR takes three parameters:
				first the variable name
				secound the start value
				third the end value
				it counts the variable from start to end value
				on NEXT it runs the code between FOR and NEXT again and
				counts variable

				The DO loop:
				example:
				10 DO
				20 PRINT "HELLO"
				30 WHILE 1
				DO takes no parameters
				WHILE take one parameter if it is bigger then zero WHILE goes to DO] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[ The TEST() function:
				example:
				10 PRINT TEST(0, "==", 0)
				20 PRINT TEST(1,"==",0)
				30 PRINT TEST(0, ">", 1)
				
				It prints 1, 0, 0.
				TEST function checks condition similar to the IF function
				It returns 1 if true and 0 if false
				can used for IF and WHILE

				The RND() function:
				example
				10 PRINT RND()
				20 PRINT RND(10, 20)
				It prints two randmon numbers one between 0 and 100,
				and one between 10 and 20. It takes no or two paramters:
				first parameter min (default 0)
				secound parameter max (default 100)
				It returns a random number between min and max. ] ]]..prev..next,
	"size[10,9]"..
		"label[0,1;"..[[ Function CAT():
				Concatenate more values:
				example:
				10 PRINT CAT(0, "==", 0,"+", 1, "-", 1)
				CAT takes one ore more parameters.
				Its returns a string based on parameters

				Function TONUMBER():
				It creates a Number from String, example:
				10 PRINT TONUMBER("5")*5

				Command CLEAR:
				It clears the screen.] ]]..prev,
 


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
