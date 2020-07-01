.data
# File
promptFilename:	.asciiz "Enter the location of the dictionary file. (easy.txt or hard.txt)\n"
badFilename:	.asciiz "File does not exist. Try again.\n"
fileName:	.asciiz ""	# Name of dictionary file
inputSize:	.word	1024	# Maximum length of input filename
fileBuffer:	.space	1024	# Reserve 1024 bytes for the file buffer

#File Out
strFileOut:	.space	1000
fileOut:	.asciiz "nguoichoi.txt"

theWord:	.space	24	# the word
msg: 		.asciiz "Key: " #test
theGuessedWord:	.space	24	# the guessed word

point:		.word	0	# the score

pointSize:	.word 	0	# the size of score

pointString:	.space	3	# the string of score

userName:	.space 10	# your Name



# Pictures
hangMan: 	.asciiz "_______\n|   |  \\|\n        |\n        |\n        |  ",
			"\n        |\n        |\n        |\n       ---\n",
			"_______\n|   |  \\|\n    O   |\n        |\n        |  ",
			"\n        |\n        |\n        |\n       ---\n",
			"_______\n|   |  \\|\n    O   |\n    |   |\n        |  ",
			#"\n        |\n        |\n        |\n       ---\n",
			#"_______\n|   |  \\|\n    O   |\n    |   |\n    |   |  ",
			"\n        |\n        |\n        |\n       ---\n",
			"_______\n|   |  \\|\n    O   |\n   \\|   |\n    |   |  ",
			"\n        |\n        |\n        |\n       ---\n",
			"_______\n|   |  \\|\n    O   |\n   \\|/  |\n    |   |  ",
			"\n        |\n        |\n        |\n       ---\n",
			"_______\n|   |  \\|\n    O   |\n   \\|/  |\n    |   |  ",
			"\n   /    |\n        |\n        |\n       ---\n",
			"_______\n|   |  \\|\n    O   |\n   \\|/  |\n    |   |  ",
			"\n   / \\  |\n        |\n        |\n       ---\n",

clearScreen:	.asciiz ""	
clearToBegin:	.asciiz ""	

# Strings
Welcome:	.asciiz "Welcome to Hangman! "
someThing: 	.asciiz "\n-----------------------------------\n"
inputName: 	.asciiz "Your name: "

Green:		.asciiz	"\n"	
Red:		.asciiz	"\n"	
Blue:		.asciiz	"\n"	
Purple:		.asciiz	"\n"	
Default:	.asciiz	"\n"	
Yes:		.asciiz "\nYes!\n"
No:		.asciiz "\nNo!\n"
already:	.asciiz "\nYou already guessed that letter.\n"


Guess:		.asciiz "Guess a letter: "
invalidInput:	.asciiz "Invalid input: Only alphabetical characters are valid.\n"

rightWord:	.asciiz "The correct word was: "
NewLine:	.asciiz "\n"

lose:		.asciiz "You Lose!\n"
win:		.asciiz "You Win!"

playAgain:	.asciiz "\nWould you like to play again? (y/n)\n"

Goodbye:	.asciiz "Goodbye!"

AllGuesses:	.asciiz	"Previously guessed: "

Guessed:	.space	26	# Guessed letters

GuessSoFar:	.space	26 	#s _ s t e _ d

Score:		.asciiz "\nYour score: "

plan1:		.asciiz "\nPress 1 to guess the letter"

plan2:		.asciiz "\nAnything else to guess the Word"

Choice:		.asciiz "\nYour choice: "

scanGuessWord:	.asciiz "Your guess word: "

###############################################################################
# Begin program
.text
	.globl main
main:

	# Input the usser name
	li 	$v0, 4
	la 	$a0, inputName
	syscall
	
	li	$v0, 8
	la 	$a0, userName
	li	$a1, 11
	syscall

	# Print the welcome
	li	$v0, 4
	la	$a0, Welcome
	syscall
	li 	$v0, 4
	la 	$a0, userName
	syscall	
	li 	$v0, 4
	la 	$a0, someThing
	syscall

	# Open file
	jal 	_openFile



# Play the game
_playGame:
	jal	_randomGenerator
	la	$a0, Guessed		# Zero out the Guessed array, in case it's a new turn
	#jal	_nukeSpace		
	la	$a0, GuessSoFar
	#jal	_nukeSpace		
	li 	$s0, 0			# $s0 will hold the number of turns taken.
	li	$s6, 0			# $s6 will hold the number of correct guesses.

	li	$t0, 0x21		# Set '!' as t0
	la	$t1, Guessed		# Load Guessed into t1
	sb	$t0, 0($t1)		# Store '!' in Guessed

	# Display the empty gallows and blank spaces
	#jal	_clearTerm		# Clear the terminal
	la	$a1, theWord
	la	$a0, Guessed
	la	$a3, GuessSoFar
	jal	_generateWordToDisplay	# Will return all blanks
	jal	_drawMan			# Draw the empty gallows
	
	# Play the game
	jal 	_runGame



# File did not exist
_incorrectInput:
	li 	$v0, 4			# 4 is function code for printing a string
	la 	$a0, badFilename	# Load string into a0
	syscall 			# Print the message

#-------[ File Access Subroutines ]----------------------------------------------
#	Get the filename of the dictionary from the user
#	Read that file into the file buffer

_openFile:
_openFile.getFileName:				# Get file path from user
	# Display prompt
	li 	$v0, 4			# 4 is function code for printing a string
	la 	$a0, promptFilename	# Load string into a0
	syscall				# Print the prompt

	# Get user input
	li 	$v0, 8			# 8 is function code for reading a string
	la 	$a0, fileName		# Load fileName into a0
	lw 	$a1, inputSize		# Load contents of inputSize into a1
	syscall				# Input now stored in fileName

# Remove the newline character from the user's input
_openFile.sanitizeFileName:			# Fix the input
	li 	$t0, 0			# Loop counter
	lw 	$t1, inputSize		# Loop end
_openFile.clean:
	beq 	$t0, $t1, _openFRead
	lb 	$t3, fileName($t0)
	bne 	$t3, 0x0a, _openFile.t0Increment	# We are not at newline
	sb 	$zero, fileName($t0)	# Null-terminate fileName
	j	_openFRead
_openFile.t0Increment:
	addi 	$t0, $t0, 1
	j 	_openFile.clean

# Open file for reading
_openFRead:
	li 	$v0, 13			# 13 is function code for opening a file
	la 	$a0, fileName		# FileName is the name of the file
	li 	$a1, 0			# Open for reading (flags are 0: read, 1: write)
	li 	$a2, 0			# Ignore the mode
	syscall				# File descriptor returned in v0
	move 	$a0, $v0		# Store the file descriptor in a0

# Make sure the file opened correctly
_openFRead.checkFileValidity:
	li 	$t0, -1				# Set t0 = -1
	beq 	$a0, $t0, _incorrectInput	# If descriptor = -1, then get new input

# Read the entire file into the fileBuffer
_openFRead.readFile:				# Read from the file itself
	li	$v0, 14			# 14 is the function code for reading a file
	la	$a1, fileBuffer		# Read into fileBuffer
	li	$a2, 1024		# Read no more than 1024 bytes
	syscall

# Close the dictionary file
_openFRead.closeFile:				# Because we're good people
	li	$v0, 16
	syscall

# Return to caller
jr 	$ra

#-------[ Word Randomization ]---------------------------------------------------
#	Get a random word
#	We know there are exactly 50 words.

_randomGenerator:

	li	$v0, 30		# 30 is the function code for getting epoch time
	syscall			# Low-order 32-bits are in $a0.  High-order are in $a1

	li	$v0, 40		# 40 is the function code for setting the random seed
	move	$a1, $a0	# Put the part of the time that actually changes every second in $a0
	li	$a0, 0		# Random generator 0
	syscall			# Random generator is now randomly seeded

	li	$v0, 42		# 42 is the function code for
	li	$a1, 50		# Our random number will be 0<=num<50
	li	$a0, 0		# 0 is my favorite random number generator
	syscall			# We now have a random number in $a0

_getRandomWord:

	la	$t1, fileBuffer		# First character of our fileBuffer
	li	$t0, 0			# Counter begins with 0
	la	$t2, theWord		# The Word
	li	$s5, 0			# Initialize the number of characters in the word
_getRandomWord.Loop:
	lb	$t3, 0($t1)		# Load the fileBuffer's character
	addi	$t1, $t1, 1		# Next character
	beq     $t3, 0x0a, _getRandomWord.randomNext	# We are at newline
	beq	$t0, $a0, _getRandomWord.rAddLetter	# Add the letter to the word
	j	_getRandomWord.Loop

_getRandomWord.randomNext:
	beq     $t0, $a0, _getRandomWord.finalizeWord	# Null-terminate the word
	addi	$t0, $t0, 1		# Increment our counter
	j _getRandomWord.Loop

_getRandomWord.rAddLetter:
	sb	$t3, 0($t2)		# Put the letter into the word
	addi	$t2, $t2, 1		# Next letter of the word
	addi	$s5, $s5, 1		# Get the number of characters
	j	_getRandomWord.Loop

_getRandomWord.finalizeWord:
	li	$t3, 0x00
	sb	$t3, 0($t2)		# Null-terminate theWord

	jr	$ra

#	End getRandomWord
#---------------------------------------------------------------------------------------------------

#-------[ Main Game Logic ]-------------------------------------------------------------------------
_runGame:	
	#########################TEST######################################
	li 	$v0, 4
	la 	$a0, msg #Key: 
	syscall	

	li 	$v0, 4
	la 	$a0, theWord
	syscall

	li 	$v0, 4
	la 	$a0, NewLine
	syscall
	###############################################################
	li	$v0, 4
	la	$a0, plan1
	syscall
	
	li	$v0, 4
	la	$a0, plan2
	syscall

	li	$v0, 4
	la	$a0, Choice
	syscall

	li	$v0, 5
	syscall
	
	bne	$v0, 1, _guessTheWord

	jal 	_promptChar 		# Ask for a character
	move 	$a2, $v0		# Copy the input character to a2
	#jal	_clearTerm
	la 	$a1, theWord 		# We need to replace theWord with the proper word
	la 	$a0, Guessed
	jal 	_updateGuess 		# Make sure we have not previously guessed this
	jal	_showPreviousGuesses	# "Previously guessed: r, s, t, l, n, e

	bne 	$v0, $0, _runGame.alreadyGuessed # Continue as if it was a correct answer
	la 	$a3, GuessSoFar

	jal 	_generateWordToDisplay 		# Will return _ _ _ A _ B _ C
	jal 	_strContains 		# test for correctness
	
	beq 	$v0, $0, _runGame.doesNotContain

	# So it was a correct guess
	li 	$v0, 11 			# Print a character
	li 	$a0, 0x1b  			# ASCII escape
	syscall

	li	$v0, 4
	la	$a0, Green			# ANSI escape code for green
	syscall

	la	$a0, Yes
	syscall
	j	_runGame.wordDoesContain

_runGame.alreadyGuessed:
	la	$a0, already			# "You have already guessed the letter"
	li	$v0, 4
	syscall

_runGame.wordDoesContain: 				#correct
	jal 	_drawMan
	beq	$s5, $s6, _youWin		# Correct guesses == Letters in word
	jal	_rightSound
	j 	_runGame

_runGame.doesNotContain: 				#Incorrect guess
	li 	$v0, 11 			# Print a character
	li 	$a0, 0x1b  			# ASCII escape
	syscall

	li	$v0, 4
	la	$a0, Red			# ANSI escape code for green
	syscall

	la	$a0, No
	syscall

	addiu 	$s0, $s0, 1  			#Increment incorrect guesses
	
	
	jal 	_drawMan
	beq 	$s0, 7, _youLose
	jal	_wrongSound

	j 	_runGame

_showPreviousGuesses:
	addi 	$sp, $sp, -12		# Allocate
	sw 	$ra, 0($sp)		# Store old ra
	sw 	$a0, 4($sp)		# Store old a0
	sw 	$v0, 8($sp)		# Store old s0

	move	$t0, $a0
	li	$v0, 4				# 4 is the function code to print a string
	la	$a0, AllGuesses			# "Previously Guessed: "
	syscall
		
	la	$t0, Guessed			# Get guessed characters
	li	$v0, 11				# 11 is the function code to print a character

	lb	$a0, 1($t0)			# Our first byte is the exclamation point, so start at 1
	beq	$a0, 0, _showGuesses.End	# We've hit the end

	syscall
_showGuesses.Loop:

	addi	$t0, $t0, 1

	lb	$a0, 1($t0)
	beq	$a0, 0, _showGuesses.End	# We've hit the end
	move	$t1, $a0

	li	$a0, 0x2c		# Print a comma
	syscall

	li	$a0, 0x20		# Print a space
	syscall

	move	$a0, $t1
	syscall
	j	_showGuesses.Loop

_showGuesses.End:
	lw	$ra, 0($sp)		# Load old ra
	lw 	$a0, 4($sp)		# Load old a0
	lw 	$v0, 8($sp)		# Load old s0
	addi 	$sp, $sp, 12		# Deallocate

	jr	$ra



_drawMan:					# Expects $s0 to hold the number of turns taken.
	li 	$t1, 93 			# Each hangman guy is exactly 93 characters long
	mul 	$t0, $s0, $t1 			# Multiply it by the current number of moved used
	li 	$v0, 4 				# Print a string
	la 	$a0, hangMan 			# top half of the hangman picture
	addu 	$a0, $a0, $t0 			# plus our offset for the number of moves taken
	syscall
	addi 	$t2, $a0, 50 			# Calculate the bottom half of our hangman picture, save it in temp.
	
	la 	$a0, GuessSoFar 		# Print the current status of the word
	syscall

	move 	$a0, $t2 			# Get back the bottom half of our hangman picture from temp
	syscall
	jr 	$ra

_youWin:
	
	jal _countLetter

	li	$v0, 4
	la	$a0, win
	syscall

	
	
	jal	_drawMan

	la	$a0, win
	syscall

	

	jal	_drawMan

	la	$a0, win
	syscall
	
	

	jal	_drawMan

	la	$a0, win
	syscall
	
	

	jal	_drawMan

	la	$a0, win
	syscall

	jal 	_winSound
	j	_Exit



_youLose:
	li	$v0, 4				# 4 is the function code for print string
	la	$a0, lose			# "You Lose!\n"
	syscall

	li 	$v0, 11 			# Print a character
	li 	$a0, 0x1b  			# ASCII escape
	syscall

	li	$v0, 4				# 4 is the function code for printing a string
	la	$a0, Default			# ANSI escape code for reset
	syscall

	la	$a0, rightWord			# "The correct words was"
	syscall

	la	$a0, theWord			# The proper word
	syscall

	jal	_loseSound
	
_Exit:
	
	li 	$v0, 11 			# Print a character
	li 	$a0, 0x1b  			# ASCII escape
	syscall

	li	$v0, 4				# 4 is the function code for printing a string
	la	$a0, Default			# ANSI escape code for reset
	syscall

	la	$a0, playAgain			# Would you like to play again?
	syscall

	li	$v0, 12				# 12 is the function code for read character
	syscall

	beq	$v0, 0x79, _playGame		# Lowercase Y, start from generating a random number
	beq	$v0, 0x59, _playGame		# Capital Y

	li	$v0, 4
	la	$a0, Score
	syscall
	
	li	$v0, 1
	lw	$a0, point
	syscall

	li	$v0, 4
	la	$a0, NewLine
	syscall
	
	jal	_readFileOut

	jal	_convertScoreToString

	jal	_writeToFile

	li	$v0, 4
	la	$a0, NewLine
	syscall
	
	li	$v0, 4				# 4 is the function code for print a string
	la	$a0, Goodbye			# Say goodbye
	syscall
	
	#jal writeFile

	li	$v0, 10				# 10 is the function code for terminate
	syscall

#	end Main Game Logic
#---------------------------------------------------------------------------------------------------

#-------[ User Interaction ]------------------------------------------------------------------------
#	Prompt Character
_promptChar:
	addi 	$sp, $sp, -12		# Allocate
	sw 	$ra, 0($sp)		# Store old ra
	sw 	$a0, 4($sp)		# Store old a0
	sw 	$s0, 8($sp)		# Store old s0
	
	li 	$v0, 11 			# Print a character
	li 	$a0, 0x1b  			# ASCII escape
	syscall

	li	$v0, 4			# 4 is the function code for printing a string
	la	$a0, Default		# ANSI escape code for reset
	syscall

	la	$a0, Guess 		# Guess a character
	syscall

	li 	$v0, 12			# 12 is the function code for reading a character
	syscall				# v0 contains a character
	
	bge	$v0, 0x61, _promptChar.returnPrompt # We're probably lowercase
	addi	$v0, $v0, 0x20		# Convert to lowercase

_promptChar.returnPrompt:	
	blt	$v0, 0x61, _invalidChar	# Less than 'a'
	bgt	$v0, 0x7a, _invalidChar	# Greater than 'a'
	lw	$ra, 0($sp)		# Load old ra
	lw 	$a0, 4($sp)		# Load old a0
	lw 	$s0, 8($sp)		# Load old s0
	addi 	$sp, $sp, 12		# Deallocate
	jr 	$ra			# Return

_invalidChar:
	li	$v0, 4			# 4 is the function code for printing a string
	la	$a0, invalidInput	# "Invalid, something something alphabet"
	syscall

	j	_promptChar
	
#	end Prompt Character
#--------------------------------------------------------------------------------

#-------[ String Handling ]------------------------------------------------------
#	check to see if a string contains a given character

_strContains:
	addi 	$sp, $sp, -4	# Allocate 4 bytes
	sw 	$a1, 0($sp)	# Store old a0
	li 	$v0, 0		# Set $v0 to 0 or false

_strContains.Loop:
	lb 	$t0, 0($a1)			# Load character in from string
	beq 	$t0, $0, _strContains.LoopBreak	# Stop loop if end of string is reached
	addi 	$a1, $a1, 1			# Increment string address to continue scanning
	beq 	$t0, $a2, charFound		# Branch if character matches
	j 	_strContains.Loop			# Jump to top of loop
	
charFound:
	addi	$s6, $s6, 1	# Increment the number of correct guesses
	li 	$v0, 1		# If character found return value = 1
	j	_strContains.Loop

_strContains.LoopBreak:
	lw 	$a1, 0($sp)	# Load old a0
	addi 	$sp, $sp, 4	# Deallocate

	# Return to caller
	jr 	$ra		# Return

#	end String Handling
#--------------------------------------------------------------------------------

#-------[ Guess Logic ]----------------------------------------------------------
# Guessed letter

_updateGuess:
	addi 	$sp, $sp, -8			# Allocate 4 bytes
	sw 	$a1, 0($sp)			# Store old a0
	sw 	$a0, 4($sp)			# Store old a1
	li 	$v0, 0 				# Whether or not it was found

_updateGuess.Loop:
	lb $t0, 0($a0)				# Load character from string
	beq $t0, $0, _updateGuess.LoopBreak	# Stop loop if its the end on string
	bne $t0, $a2, charNotInWord		# Branch if character doens match
	li $v0, 1

charNotInWord:
	addi $a0, $a0, 1			# Increment guessed buffer
	#addi $a2, $a2, 1			# Increment string position
	j _updateGuess.Loop
	
_updateGuess.LoopBreak:
	sb $a2, 0($a0)				# Store passed character in position
	lw $a0, 4($sp)				# Load old a1
	lw $a1, 0($sp)				# Load old a0
	addi $sp, $sp, 8			# Deallocate
	jr $ra					# Return
	
# String Reformating ------------------------------------------------------------
#	Generate the word to display with underscores

_generateWordToDisplay:
	addi 	$sp, $sp, -12		# Allocate 4 bytes
	sw 	$a0, 0($sp)		# Store old a0
	sw 	$a1, 4($sp)		# Store old a1
	sw 	$a3, 8($sp)
	li 	$v0, 0 			# Whether or not it was found
	move 	$t1, $a0
	li 	$t3, 0x5F		# Load underscore character

_generateWordToDisplay.Loop:
	lb 	$t2, 0($a1)				# Fully correct word
	lb 	$t0, 0($a0) 				# Every guessed letter
	beq 	$t0, $0, _generateWordToDisplay.EOW 	# Stop loop if its the end on string
	beq 	$t0, $t2, addLetter 			# If one of our guesses is correct
_generateWordToDisplay.LoopContinue:
	sb 	$t3, 0($a3)
	addi 	$a0, $a0, 1

	j 	_generateWordToDisplay.Loop

addLetter:
	move 	$t3, $t2
	j 	_generateWordToDisplay.LoopContinue

_generateWordToDisplay.EOW:
	addi 	$a3, $a3, 1 	# Go to the next location in our word to display
	
	li	$t4, 0x20
	sb	$t4, 0($a3)
	addi	$a3, $a3, 1
	
	move 	$a0, $t1 	# Go to the beginning of our guessed letters
	addi 	$a1, $a1, 1 	# Go to the next letter in our fully correct word
	lb 	$t5, 0($a1)
	li 	$t3, 0x5F	# Load underscore character
	beq	$t5, $0 _generateWordToDisplay.END
	j 	_generateWordToDisplay.Loop

_generateWordToDisplay.END:
	lw 	$a3, 8($sp)
	lw 	$a1, 4($sp)	#load old a1
	lw 	$a0, 0($sp)	#load old a0
	addi 	$sp, $sp, 12	#deallocate
	jr 	$ra		#return

# Sound Subroutines -------------------------------------------------------------
_rightSound:
	li	$a2, 0		# instrument ID
	li	$a3, 127	# volume
	li	$v0, 33

	li	$a0, 55
	li	$a1, 100
	syscall

	li	$v0, 32
	li	$a0, 65
	syscall

	li	$a2, 0		# instrument ID
	li	$a3, 127	# volume
	li	$v0, 33

	li	$a0, 60
	li	$a1, 100
	syscall

	jr $ra

_wrongSound:
	li	$a2, 0		# instrument ID
	li	$a3, 127	# volume
	li	$v0, 33

	li	$a0, 60
	li	$a1, 100
	syscall

	li	$v0, 32
	li	$a0, 65
	syscall

	li	$a2, 0		# instrument ID
	li	$a3, 127	# volume
	li	$v0, 33

	li	$a0, 55
	li	$a1, 100
	syscall

	jr $ra

_winSound:
	li	$a2, 0		# instrument ID
	li	$a3, 127	# volume
	li	$v0, 33

	li	$a0, 69
	li	$a1, 100
	syscall

	li	$a0, 75
	li	$a1, 100
	syscall

	li	$a0, 89
	li	$a1, 100
	syscall

	li	$a0, 78
	li	$a1, 250
	syscall

	li	$a0, 85
	li	$a1, 100
	syscall

	li	$a0, 90
	li	$a1, 250
	syscall

	li	$a0, 85
	li	$a1, 250
	syscall

	li	$a0, 90
	li	$a1, 250
	syscall

	li	$a0, 94
	li	$a1, 500
	syscall

	jr $ra

_loseSound:
	li	$a2, 0		# instrument ID
	li	$a3, 127	# volume
	li	$v0, 33

	li	$a0, 55
	li	$a1, 500
	syscall

	li	$a0, 54
	li	$a1, 500
	syscall

	li	$a0, 51
	li	$a1, 500
	syscall

	li	$a0, 50
	li	$a1, 1500
	syscall

	jr	$ra

# Coungting letter -------------------------------------------------------------

_countLetter:

	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)


	lw	$t0, point				#Load the score
	la	$s0, theWord				#Load the string

_countLetter.Loop:

	lb	$t1, ($s0)
	beq	$t1, $0, _countLetter.End		#Stop loop if its the end of string
	addi	$t0, $t0, 1				#Increase the score
	addi	$s0, $s0, 1				#Go to the next letter

	j _countLetter.Loop


_countLetter.End:

	sw	$t0, point

	lw	$ra, 0($sp)
	lw	$s0, 4($sp)

	addi 	$sp, $sp, 8
	
	jr	$ra




# Guess the word ----------------------------------------------------------------

_guessTheWord:
	
	li	$v0, 4	
	la	$a0, scanGuessWord
	syscall
	

	li	$v0, 8
	la	$a0, theGuessedWord
	li	$a1, 24
	syscall

	la	$s0, theWord
	la	$s1, theGuessedWord

_guessTheWord.Loop:

	lb	$t0, ($s0)
	lb	$t1, ($s1)
	
	beq	$t1, '\n', _guessTheWord.Right

	bne	$t0, $t1, _youLose

	addi	$s0, $s0, 1
	addi	$s1, $s1, 1

	j _guessTheWord.Loop



_guessTheWord.Right:
	
	jal _countLetter

	li	$v0, 4
	la	$a0, win
	syscall

	jal 	_winSound
	j	_Exit 

#-------Read output file-------------------------------------------------
_readFileOut:
	
	addi	$sp, $sp, -28
	sw	$ra, ($sp)
	sw	$s2, 4($sp)
	sw	$s3, 8($sp)
	sw	$a0, 12($sp)
	sw	$a1, 16($sp)
	sw	$a2, 20($sp)
	sw	$v0, 24($sp)

	la 	$s2, fileOut		# The location of the output file
	la 	$s3, strFileOut		# To store the old string in file Output

	
	li 	$v0, 13			# 13 is function code for opening a file
	move 	$a0, $s2		# FileName is the name of the file
	li 	$a1, 0			# Open for reading (flags are 0: read, 1: write)
	syscall				# File descriptor returned in v0
	
	move 	$s0, $v0		# Store the file descriptor in a0

	li	$v0, 14			# 14 is function code for reading a file
	move	$a0, $s0		# a1 is the register for store the read-string
	move	$a1, $s3	
	li	$a2, 1000		# The maximun letters we can read from the output file is 1000
	syscall

	li	$v0, 16			# Cloes the output file
	move	$a0, $s0
	syscall		

	lw	$ra, ($sp)
	lw 	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$a0, 12($sp)
	lw	$a1, 16($sp)
	lw	$a2, 20($sp)
	lw	$v0, 24($sp)

	addi	$sp, $sp, 28
	jr	$ra


#------Convert your score from integer to string------------------------------------------------
_convertScoreToString:

	addi	$sp, $sp, -36
	sw 	$ra, ($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$t0, 20($sp)
	sw	$t1, 24($sp)
	sw	$t2, 28($sp)
	sw	$a1, 32($sp)

	

	li	$s1, 10
	li	$s2, 100
	lw	$s0, point

	slt	$t0, $s0, $s1
	beq	$t0, 1, _convertScoreToString.10

	slt 	$t0, $s0, $s2
	beq 	$t0, 1, _convertScoreToString.100

_convertScoreToString.10:
	
	li	$t1, 1
	sw	$t1, pointSize
	j	_convertScoreToString.Convert10


_convertScoreToString.100:

	li	$t1, 2
	sw	$t1, pointSize
	j	_convertScoreToString.Convert100

_convertScoreToString.Convert10:

	la	$a1, pointString
	j	_convertScoreToString.Convert

_convertScoreToString.Convert100:

	la	$a1, pointString
	addi	$a1, $a1, 1
	j	_convertScoreToString.Convert


_convertScoreToString.Convert:

	beq	$t1, 0, _convertScoreToString.End
	div	$s0, $s1
	mflo	$s0 
	mfhi	$t2
	addi	$t2, $t2, 48
	sb	$t2,($a1)
	addi	$t1, $t1, -1
	addi	$a1, $a1, -1
	j	_convertScoreToString.Convert

_convertScoreToString.End:
	
	lw 	$ra, ($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$t0, 20($sp)
	lw	$t1, 24($sp)
	lw	$t2, 28($sp)
	lw	$a1, 32($sp)

	addi	$sp, $sp, 36
	jr	$ra


# ------- Write your name and your score to output file-------------------------------------
_writeToFile:


	addi	$sp, $sp, 28
	sw	$ra, ($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$t0, 20($sp)
	sw	$t1, 24($sp)

	la	$a3, strFileOut			# Load the address of the old string in output file 
	

_writeToFile.LastLetter:

	lb	$t0, ($a3)
	beq	$t0, '\0', _writeToFile.YourName
	addi	$a3, $a3, 1
	j _writeToFile.LastLetter

_writeToFile.YourName:

	la	$s1, userName

_writeToFile.YourName.Loop:

	lb	$t1, ($s1)
	beq	$t1,'\n',_writeToFile.WriteStar
	sb	$t1, ($a3)
	addi	$s1, $s1, 1
	addi	$a3, $a3, 1
	j	_writeToFile.YourName.Loop

_writeToFile.WriteStar:

	li	$t1, '*'
	sb	$t1, ($a3)
	addi	$a3, $a3, 1

_writeToFile.WriteScore:

	la	$s1, pointString

_writeToFile.WriteScore.Loop:

	lb	$t1, ($s1)
	beq	$t1, '\0', _writeToFile.WriteSpace
	sb	$t1, ($a3)
	addi	$s1, $s1, 1
	addi	$a3, $a3, 1
	j	_writeToFile.WriteScore.Loop

_writeToFile.WriteSpace:

	li	$t1, ' '
	sb	$t1, ($a3)
	addi	$a3, $a3, 1

	sb	$0, ($a3)
	addi	$a3, $a3, 1
	move	$t2, $a3

	li	$v0, 4
	la	$a0, strFileOut
	syscall

	li	$v0, 13
	la	$a0, fileOut
	li	$a1, 1
	li 	$a2, 0
	syscall
	move	$a0, $v0

	li	$v0, 15
	la	$a1, strFileOut
	li	$a2, 1000
	syscall

	li	$v0, 16
	syscall

	
	lw	$ra, ($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$t0, 20($sp)
	lw	$t1, 24($sp)

	addi	$sp, $sp, 28
	jr	$ra





	
#--------------------------------------------------------------------------------

#-------[ EOF ]------------------------------------------------------------------


