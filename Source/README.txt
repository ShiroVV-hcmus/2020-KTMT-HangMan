#Hangman

##Features


##Limitations
* Custom dictionaries must be exactly 50 words long.
  * To maintain speed and simplicity, instead of reading the custom dictionary twice, the game assumes a dictionary size of 50.
* Running on terminals that do not support the ISO/IEC 6429 standard (such as MARS' built-in console) may parse escape characters incorrectly, and could result in artifacts.
  * These artifacts will not affect gameplay.
  * Mars has a command-line mode, which allows the program to be run from your console.  Simply run `java -jar /path/to/Mars.jar ./main.asm` from a modern terminal emulator.
  * The University of Texas at Dallas provides open labs with MobaXTerm installed, which will run this program without issues.
* Program crashes if you simply press `ENTER` for your guess, instead of inserting a character.
  * This is an issue with syscall 12, for reading a character.  If no character is given, it crashes the program.

##How To Use
1. Launch the program from a modern terminal emulator, using the command `java -jar /path/to/Mars.jar ./main.asm`.
2. Choose your dictionary file.  For the default installation, this will either be `easy.txt` or `hard.txt`.  Both absolute and relative paths are supported.
3. Start guessing letters.  After each guess, you will be alerted as to whether or not your guess was correct, or if you have already guessed that character.
  * If your guess was correct, the word displayed beside the hangman will update with your new character(s).
  * If your guess was incorrect, another part of the hangman's body will appear.
4. If you guess all the letters correctly, you'll see that you won.  Otherwise, you will lose and the correct word will be displayed.
5. After the game, type `y` to play a new game, or `n` to quit.
