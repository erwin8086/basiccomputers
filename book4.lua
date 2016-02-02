local prev = "button[0,0;3,1;prev;Preview]"
local next = "button[6,0;3,1;next;Next]"
basiccomputers.books.book4 = {
	"size[10,9]"..
		"label[0,1;"..[[ These book contains description
				of every command and function and
				min. one example of the function or command.
				The book has four capters:
				* Generic commands
				* Generic functions
				* Upgrade commands
				* Upgrade functions ] ]]..next,
	"size[10,9]"..
		"label[0,1;"..[[ * Generic commands:
				PRINT msg, ...
				Prints a message to screen.
				Examples: PRINT "HELLO", " ", "WORLD"
				          PRINT "1+5=", 1+5
				          PRINT "HELLO WORLD!"

				LET "var", val
				Assings a value to a variable
				Examples: LET "A", 10
				          LET "B", A+1

				CLEAR
				Clears the screen.
				Examples: CLEAR] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				LIST
				Lists the program.
				Example: LIST

				DELPRG
				Deletes the program.
				Example: DELPRG

				EXIT
				Do noting.

				RUN
				Runs the program.
				Example: RUN] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;".. [[
				END
				Stops running program.
				Example: 20 END.
				Can only used in program.
				To kill program use the Kill button.

				GOTO line
				Go to the line.
				Example: 20 GOTO 20
				Can only used in program.

				IF val, mode, val, line
				Goto line if condition is true.
				mode can be:
				"==", ">", ">=", "<", "<=", "<>"
				Example: IF A, "==", B, 30
				         IF 0, ">", 1, 30
				         IF 0, "<>", 1, 30] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				IF val, line
				Goto line if val > 0.
				Example: IF 1, 30
				         IF 0, 30] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				FOR "var", min, max
				Starts FOR loop.
				Can only used in program.
				Example: 10 FOR "A", 0, 10
				         10 FOR "B", 10, 15
				         10 FOR "C", A, A+5

				NEXT
				Close FOR loop and count var = var + 1.
				Can only used after FOR.
				Example: 20 NEXT
				         10 FOR "A", 0, 5: PRINT A:NEXT

				DO
				Starts DO...WHILE loop.
				Can only used in program.
				Example: 10 DO] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[

				WHILE val
				Close DO..WHILE loop.
				Can only used after DO.
				Go to DO if val > 0.
				Example: 20 WHILE 1
				         10 DO:PRINT "HELLO":WHILE 1] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				STR string
				Saves string as STR
				Example: STR "HELLO"

				EDIT
				Opens program editor.
				Example: EDIT

				WAIT sec
				Wait secounds and saves power.
				Example: WAIT 10] ]]..prev..next,
	"size[10,9]"..
		"label[0,1;"..[[ * Generic functions:
				STR()
				Return string saved with STR.
				Exmaple: PRINT STR()

				ISREAD()
				Checks if line can be read.
				Example: PRINT ISREAD()

				READ()
				Reads line.
				Example: PRINT READ()

				RND()
				Gets random number between 0 and 100
				Example: PRINT RND()

				RND(min, max)
				Gets random number between min and max
				Example: PRINT RND(5,10)] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				TEST(val, mode, val)
				Tests condition.
				mode can be: "==", "<>", "<", "<=", ">", ">="
				returns 1 if true and 0 if false.
				Example: PRINT TEST(0,"==", 0)
				         PRINT TEST(0, "<", 0)

				CAT(val, ...)
				Concatenates one ore more values.
				Returns always a string.
				Example: PRINT CAT("HELLO WORLD")
				         PRINT CAT("HELLO", " ", "WORLD")

				TONUMBER(string)
				Converts string to number.
				Return always a number.
				Example: PRINT TONUMBER("10")
				         PRINT TONUMBER("100")] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				LINE()
				Returns current line of program.
				Can only used in program
				Example: 10 PRINT LINE() ] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[ * Upgrade commands:
				* Floppy drive:
				FEXAMPLE
				Sets current disk as example disk.
				Disabled in release.
				Example: FEXAMPLE

				FLOAD file
				Loads file as program.
				Example: FLOAD "hello"

				FSAVE file
				Saves program as file.
				Example: FSAVE "hello"

				RM file
				Removes file.
				Example: RM "hello"] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				FPRINT file
				Prints file to screen.
				Example: FPRINT "hello"

				FCLOSE id
				Closes open file.
				Example: FCLOSE, 1] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				MV file, file
				Moves file to file.
				Example: MV "hello", "hello2"

				CP file, file
				Copy file to file.
				Example: CP "hello", "hello2"

				LS
				List files.
				Example: LS

				FWRITE id, text
				Write text to open file(id).
				Example: FWRITE 1, "hello"] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				FOPEN id, file
				Opens file as id.
				Example: FOPEN 1, "hello"

				* Tape drive:
				LOAD
				Loads program from tape.
				Example: LOAD

				SAVE
				Saves program to tape.
				Example: SAVE

				* Power Upgrade:
				SLEEP sec
				Sleeps for secounds.
				Example: SLEEP 10

				STANDBY min
				Standbys for minutes.
				Example: STANDBY 1] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				* Chat Upgrade:
				CHAT msg, ...
				Send message to Chat(within 10 blocks)
				Example: CHAT "HELLO WORLD"
				         CHAT "HELLO", " ", "WORLD"
				         CHAT "1+5=", 1+5

				* Command Upgrade:
				COMMAND cmd, param
				Execs chat command with parameter.
				Example: COMMAND "help", ""
				         COMMAND "time", "5500"

				* Digiline Upgrade:
				DIGILINE chan, msg
				Send message to channel.
				Example: DIGILINE "test", "HELLO WORLD"] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[ * Upgrade functions:
				* Generator Upgrade:
				ENERGY()
				Return energy of current burning item.
				Example: PRINT ENERGY()

				* Chat Upgrade:
				ISCHAT()
				Returns 1 if chat message in buffer else 0.
				Example: PRINT ISCHAT()

				GETCHAT()
				Return chat message in buffer.
				Example: PRINT GETCHAT()

				* Battery Upgrade:
				ENERGY()
				Return energy in battery.
				Example: PRINT ENERGY()] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				* Digiline Upgrade:
				ISDIGILINE()
				Return 1 if digiline message in buffer else 0
				Example: PRINT ISDIGILINE()

				DIGILINE(mode)
				if mode == "channel" returns channel of message
				if mode == "message" returns message
				Example: PRINT DIGILINE("channel")
				         PRINT DIGILINE("message")] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				* Floppy drive:
				FSTAT(mode)
				if mode == "free" returns free space.
				if mode == "used" returns used space.
				if mode == "size" returns size.
				if mode == "readonly" return 1 for readonly else 0
				if mode == "nowrite" return 1 for nowrite else 0
				Example: PRINT FSTAT("free")
				         PRINT FSTAT("used")
				         PRINT FSTAT("size")
				         PRINT FSTAT("readonly")
				         PRINT FSTAT("nowrite")] ]]..next..prev,
	"size[10,9]"..
		"label[0,1;"..[[
				FREAD(id)
				Read line from open file(id).
				Example: PRINT FREAD(1)] ]]..prev,
}
