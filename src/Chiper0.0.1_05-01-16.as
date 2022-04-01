#===================================================================================================================================================
#                      RISC-V Assembly Project
#
#                            Cipher Message
#  Tested on RIPES: v2.1.0-6-gac5e783
# ===================================================================================================================================================
.data
errStr: .string "Invalid myplaintext string!"    # Output for myplaintext string when is incorrect
errCyp: .string "Invalid mycypher string!"       # Output for mycypher string when is incorrect
buffPosition: .word 0                            # Store the position of each char for Decryption Occurrences
buffOccurString: .word 2000                      # Address where store the string of the Encryption Occurrences
sostK: .word   -1                                # Alphabetical shift for Caesar cipher (Decided by user)
blocKey: .string "OLE"                           # Key for Block cipher (Decided by user)
mycypher: .string "ABCD"                         # mycypher string where to indicate which encryption algorithms apply to myplaintext string (Decided by user)
myplaintext: .string "~ #$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\]^_ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~0123456"    # myplaintext is the string which is encrypt/decrypt (Decided by the user)


.text
main:
la s0, myplaintext   # Load head of myplaintext
la s1, mycypher      # Load head of mycypher


add a2, s0, zero     # a2 <- myplaintext
add a3, s1, zero     # a3 <- mycypher
jal plaiCypCheck      # Jump to the procedure that checks the fairness of myplaintext and mycypher

jal print_plaintext  # Jump to the procedure which prints the string myplaintext

add a0, s0, zero     # a0 <- myplaintext the string to be encrypted/decrypted
jal cipher           # Jump to the procedure for the encryption of the myplaintext string

jal decipher         # Jump to the procedure for the dencryption of the cyphertext

j endMain            # Jump to the ends of the progam


# =================================================
#              plaiCypCheck
#
# Note: Procedure that checks the validity of myplaintext
#       string and mycypher string
#
# =================================================
plaiCypCheck:
li t0, 0       # Loop Counter
li t4, 0       # Loop Counter
li t5, 100     # myplaintext limit number of characters allowed
li t6, 5       # mycypher limit number of characters allowed


# ========================================================
#                  cpyCheckLoop
# Note: Maximum string length is 5 characters.
#       Each character can only be one of 'A','B','C','D'.
#
# Paramethers:
#   a3 <- string mycypher                 t1 <- current character
#   a4 <- load character 'A'              t3 <- base address
#   a5 <- load character 'D'              t6 <- max string length (5)
#   t0 <- loop counter for cpyCheckLoop
#
# Possible result:
#   1. End of cpyCheckLoop with string mycypher which passes
#      all the tests
#   2. All tests fail, jump to cryCheckError procedure
# ========================================================
cpyCheckLoop:
li a4, 65                     # ASCII code for character 'A'
li a5, 68                     # ASCII code for character 'D'

add t3, t0, a3                # Pass through mycypher string
lb t1, 0(t3)                  # Current character to analyze

beq t1, zero, strCheckLoop    # Check if the string has been fully viewed, if is true jump to 'strCheckLoop'

# ========================================================
# Check if the character is not contained between A and D
# ========================================================
blt t1, a4, cryCheckError
bgt t1, a5, cryCheckError

addi t0, t0, 1               # Increment the counter
bgt t0, t6, cryCheckError    # Check if the string is more than 5, if is true jump to 'cryCheckError'
j cpyCheckLoop


# ==========================================================================
#                   strCheckLoop
# Note: Maximum string length is 100 characters.
#       Each character can be between 32 and 127 (ASCII code).
#
# Paramethers:
#   a2 <- string myplaintext              t2 <- base address
#   a4 <- load character 'Spc'            t4 <- loop counter for strCheckLoop
#   a5 <- load character 'Del'            t5 <- max string length (100)
#   t1 <- current character
#
# Possible result:
#    1. If mycypher is an empty string jump to cryCheckError,
#       without checking myplaintext
#    2. End of strCheckLoop with string myplaintext which passes
#       all the tests
#    3. All tests fail, jump to strCheckError procedure
# ==========================================================================
strCheckLoop:
beq t0, zero cryCheckError   # Check if mycypher is an empty string
li a4, 32                    # ASCII code for character 'Spc'
li a5, 127                   # ASCII code for character 'Del'

add t2, t4, a2               # Pass through myplaintext string
lb t1, 0(t2)                 # Current character to analyze

beq t1, zero, strCheckExit   # Check if the string has been fully viewed, if is true jump to strCheckExit

# ==========================================================================
# Check if the character is not contained between  'Spc' and 'Del'
# ==========================================================================
blt t1, a4, strCheckError    # Character less then 32
bgt t1, a5, strCheckError    # Character greater then 127

addi t4, t4, 1               # Increment the counter
bgt t4, t5, strCheckError    # Check if the string is more than 100, if is true jump to 'strCheckError'
j strCheckLoop

# ==========================================================================
# Check if myplaintext is an empty string, if is true jump to
# strCheckError otherwise return to the main in the expected position
# ==========================================================================
strCheckExit:
beq t4, zero, strCheckError
jr ra

# ==========================================================================
# Mycypher tests fail, print 'Invalid mycypher string!' and ends the program
# ==========================================================================
cryCheckError:
la  a0, errCyp
li a7, 4
ecall           # Print error message
j endMain       # Jump to end

# ====================================================================================
# Myplaintext tests fail, print 'Invalid myplaintext string!' and ends the program
# ====================================================================================
strCheckError:
la  a0, errStr
li a7, 4
ecall            # Print error message
j endMain        # Jump to end


# =====================================================================================
#                               cipher
#
#  Note: Procedure that iterates mycypher string to extrapolate the letter of the
#        algorithm to apply on the myplaintext string (afterwards on 'cyphertext')
#
#  Paramethers:
#    a1 <- length of mycypher string      t0 <- loop Counter
#    a3 <- mycypher string                t1 <- current counter
#    ra <- return address (for main)      t2 <- Base address (mycypher + index)
#
#  Return:
#    a1 <- length of mycypher string
#    t1 <- current counter used from algChoice
# =====================================================================================
cipher:
addi sp, sp, -4               # Adjust stack for 1 items
sw ra, 0(sp)                  # Save return address in the stack, will be used for return to the main

li t0, 0                      # Loop Counter

loopCipher:
add t2, t0, a3                # Pass through mycypher string
lb  t1, 0(t2)                 # Current character
beq t1, zero, endLoopCipher   # Check the end of mycypher string

# ===============================================================================================
# Jump to the procedure that decide which algorithm of cypher must be applied to cyphertext
# ===============================================================================================
jal algChoice

# ===================================================================
# Jump to the procedure that print the result of each encryption
# ===================================================================
jal printCipherDecipher

updateLoopCipher:
addi t0, t0, 1         # Increment the counter
j loopCipher

endLoopCipher:
lw  ra, 0(sp)          # Load return address
addi sp, sp, 4         # Restore stack

addi a1, t0, -1        # Number of character in mycypher
jr ra


# ====================================================================================
#                               decipher
#
#  Note: Procedure that iterates mycypher string in rever order to extrapolate the letter
#        of the algorithm to apply on the cyphertext to get myplaintext again.
#
#  Paramethers:
#    a1 <- length of mycypher string                t0 <- a1
#    a3 <- mycypher string                          t1 <- Current character
#    a5 <- flag that trigger the decry. alg.        t2 <- Base address
#    ra <- return address (for main)
#
#  Return:
#     t1 <- current counter used from algChoice
# ====================================================================================
decipher:
addi sp, sp, -4       # Adjust stack for 1 items
sw ra, 0(sp)          # Save return address in the stack, will be used for return to the main

add t0, a1, zero      # Number of character in mycypher (Loop Counter)
addi a5, zero, -1     # Flag that trigger the use of decryption algorithms

loopDecipher:
add t2, t0, a3        # Pass through mycypher string
lb  t1, 0(t2)         # Current character

beq t1, zero, endLoopDecipher     # End of mycypher string

# ===============================================================================================
# Jump to the procedure that decide which algorithm of cypher must be applied to cyphertext
# ===============================================================================================
jal algChoice

# =================================================================
# Jump to the procedure that print the result of each decryption
# =================================================================
jal printCipherDecipher

updateLoopDecipher:
addi t0, t0, -1      # Decrease the counter
j loopDecipher

endLoopDecipher:
lw  ra, 0(sp)        # Load return address
addi sp, sp, 4       # Restore stack

jr ra                # Jump to the main


# ====================================================================================
#                          algChoice
#  Note: Compare the character extracted from the cipher or decipher
#        procedures and select the specified encryption/decryption algorithm
#
#  Paramethers:
#      t1 <- curret mycypher character        t4 <- character B in ASCII
#      t3 <- character A in ASCII             t5 <- character C in ASCII
#
# ====================================================================================
algChoice:
li t3, 65  # A in ASCII
li t4, 66  # B in ACSII
li t5, 67  # C in ASCII

beq t1, t3, caesarCipherDecipher   # Caesar cipher is invoke if  one character of mycypher is equal A
beq t1, t4, blockCipherDecipher    # Block cipher is invoke if  one character of mycypher is equal B
beq t1, t5, encrDecrOccurrence     # Encryption Occurrences is invoke if  one character of mycypher is equal C
j dictionary                       # Dictionary is invoked otherwise, that is when the mycypher character is D





# ====================================================================================
#                               caesarCipherDecipher
#
#  Note: Inizializes the Caesar Algorithm...
#
#  Paramethers:
#      t1 <- Current index             a4 <- Alphabetical shift (sostK)
#      t3 <- flag checks               a5 <- flag triggers decryption
#      t6 <- value of 26 (alphabet characters)
#            use for modulus of sostk
#
# ====================================================================================
caesarCipherDecipher:
addi sp, sp, -8                # Adjust stack for 2 items
sw ra, 4(sp)                   # Return address
sw t0, 0(sp)                   # Loop counter of cipher/decipher procedure

li t1, 0                       # Current index
li t3, -1                      # flag checks <- if is a letter/if we are in the decryption
li t6, 26                      # t6 <- alphabet characters
lw a4, sostK                   # Alphabetical shift for Caesar algorithm


# ===================================================================================================================================
#                          moduleCipher/moduleNegCipher
#  Note: Used to apply  modulus to the alphabetic shift(sostK) limiting its value to the characters of the alphabet.
#        Since the modulus instruction is not present in Risc-V; the remainder(REM) is used here, in the case of positive Sostk.
#        If Sostk is negative, then two possible choices for the remainder occur. 'In mathematics, the remainder is positive,
#        but implementations in programming languages differ as in Risc-V '. To overcome this problem, the result of the remainder
#        is taken and then it is subtracted from the number of characters in the alphabet(26).
#        Which therefore is equivalent to the result you would have with the modulus.
#
# ===================================================================================================================================
moduleSostK:
rem a4, a4, t6                  # a4 <- sostK rem 26
blt a4, zero, negModuleSostK    # In case of sostK is negative
j coreCaesarAlgorithm

negModuleSostK:
add a4, t6, a4                  # a4 <- 26 - (sostK rem 26)
j coreCaesarAlgorithm


# ====================================================================================
#                               coreCaesarAlgorithm
#
#  Note: Iterates myplaintext/cyphertext string to extrapolate the character
#        where to apply the Caesar cipher/decipher. A jump and link of
#        'getCharOffset' is perform to get the offset, useful later.
#
#
#  Paramethers:
#      t1 <- loop counter              a6 <- current character
#      t2 <- base address              a0 <- myplaintext/cyphertext string
#
# ====================================================================================
coreCaesarAlgorithm:
add t2, t1, a0                               # Pass through myplaintext/cyphertext string
lb a6, 0(t2)                                 # Current character
beq a6, zero caesarCipDecipEnd               # End of myplaintext/cyphertext string (End the Caesar's algorithm)

jal getCharOffset                            # Returns the right offset to execute caesar operation
add t5, a6, zero                            # t5 take the value of the current character
# =========================================================================
#  Chack if the current character is a letter (a1 <- return -1 from
#  'getCharOffset' procedure if the current character isn't a letter)
# =========================================================================
beq a1, t3, caesarNextChar                   # Check if it isn't a letter
addi t4, a1, 0                               # t4 <- offset
beq a5, t3, decipherCaesarAlgorithm          # Check if the alogorithm to apply is the encryption or decryption,through a flag(a5)


# ====================================================================================
#                               cipherCaesarAlgorithm
#
#  Note: The cipher algorithm is the following
#           {[(l - o) + k] % 26} + o
#
#        Where:
#           l <- letter ASCII     o <- ASCII offset character
#           k <- sostk % 26
#  Result:
#     t0 <- store the result in t2(base address)
# ====================================================================================
cipherCaesarAlgorithm:
sub t0, t5, t4                                # t0 = letter - offset
add t0, t0, a4                                # t0 += sostK
rem t0, t0, t6                                # t0 rem (26)
add t0, t0, t4                                # t0 += offset

sb t0, 0(t2)                                  # Store the result in the specified location
j caesarNextChar


# ==============================================================================================
#                 decipherCaesarAlgorithm/negSostKDecipCaesarAlgorithm
#
#  Note: The decipher algorithm is the following
#               [(l - o) - k] + o
#
#         if (l - o - k) < 0 is the following
#               {[(l - o) - k] + 26*} + o
#         Where:
#           l <- letter ASCII      o <- ASCII offset character
#           k <- sostk % 26 / key
#  Result:
#      t0 <- store the result in t2(base address
#
#   *equivalent to use modulus of 26, since ((l - o) - k) is never less then -26 in this case
# ===============================================================================================
decipherCaesarAlgorithm:
sub t0, t5, t4                                 # t0 = letter - offset
sub t0, t0, a4                                 # t0 = t0 - a4(sostK)

blt t0, zero, negSostKDecipCaesarAlgorithm
add t0, t0, t4                                 # t0 += offset

sb t0, 0(t2)                                   # Store the result in the specified location
j caesarNextChar

# ========================================================
# formula used when -> (letter ASCII - offset - key) < 0
# ========================================================
negSostKDecipCaesarAlgorithm:
add t0, t6, t0                                 # t0 <- 26 - t0 /
add t0, t0, t4                                 # t0 += offset

sb t0, 0(t2)                                   # Store the result in the specified location
j caesarNextChar


caesarNextChar:
addi t1, t1, 1                                # Increment the counter for 'coreCaesarAlgorithm'
j coreCaesarAlgorithm


caesarCipDecipEnd:
lw t0, 0(sp)                                  # Load loop counter of cipher/decipher procedure
lw ra, 4(sp)                                  # Load return address, to return to cipher/decipher procedure
addi sp, sp, 8                                # Restore stack
jr ra





# ===================================================================================================
#                               blockCipherDecipher
#
#  Note: Inizializes the Block Algorithm...
#
#  Paramethers:
#      t0 <- loop counter of blocKey string                  a1 <- Key of the block algorithm (blocKey)
#      t1 <- loop counter of myplaintext/cyphertext string   a6 <- flag for decipher algorithm
#      t6 <- value for the calculation of modulus (96)
#
#
# ===================================================================================================
blockCipherDecipher:
addi sp, sp, -4                      # Adjust stack for 1 items
sw t0, 0(sp)                         # Loop counter of cipher/decipher procedure

la a1,  blocKey                      # Load head of Key for Block cipher/decipher
li a6, -1                            # Flag for decipher algorithm
li t0, 0                             # Loop counter of blocKey
li t1, 0                             # Loop counter of myplaintext/cyphertext
li t6, 96                            # Value for the calculation of modulus


# ===================================================================================================================
#                               coreBlockAlgorithm
#
#  Note: Iterates myplaintext/cyphertext string to extrapolate the character where to apply the Block cipher/decipher.
#        It is also calcultated [cod(char) - 32] and [cod(blocKey) - 32], parts of the formula in common to encryption
#        and decryption.
#
#  Paramethers:
#      a0 <- myplaintext/cyphertext string               a1 <- blocKey string
#      t1 <- loop counter myplaintext/cyphertext         t0 <- loop counter blocKey string
#      t2 <- base address           ''                   t3 <- base address        ''
#      t4 <- current character      ''                   t5 <- current character   ''
#
# ===================================================================================================================
coreBlockAlgorithm:
add t2, t1, a0                       # Pass through myplaintext/cyphertext string
lb t4, 0(t2)                         # Current character of plain/cypher string
beq t4, zero, blockCipDecEnd         # End of myplaintext/cyphertext string (End the Block chiper/decipher)
addi t4, t4, -32                     # t4 <- cod(char) - 32

add t3, t0, a1                       # Pass through blocKey string
lb t5, 0(t3)                         # Current character of blocKey string
beq t5, zero, blocKeyLoop            # Restart the loop of blocKey string when the string is finished


coreBlockKeyAlgorithm:
addi t5, t5, -32                      # t5 <- cod(blocKey) - 32
beq a5, a6, decipherBlockAlgorithm    # Check if the alogorithm to apply is the encryption or decryption,through a flag(a5)


# ====================================================================================
#                               cipherBlockAlgorithm
#
#  Note: The cipher algorithm is the following
#            {[(cod(b ij) – 32) + (cod(key j) – 32)] % 96} + 32
#
#  Result:
#     t4 <- store the result in t2(base address)
# ====================================================================================
cipherBlockAlgorithm:
add t4, t4, t5                        # t4 <- (cod(char) - 32) + (cod(key) - 32)
rem t4, t4, t6                        # t0 % modulus (96)
addi t4, t4, 32

sb t4, 0(t2)                          # Store the result in the specified location
j blockNextChar

# =============================================================================================
#                   decipherBlockAlgorithm/negModuloDecipBlockAlgorithm
#
#  Note: The cipher algorithm is the following
#            [(cod(b ij) – 32) - (cod(blocKey j) – 32)] + 32
#
#          if (cod(b ij) – 32) - (cod(blocKey j) – 32) < 0 is the following
#               {[(cod(b ij) – 32) - (cod(blocKey j) – 32)] + 96*} + 32
#       Where:
#          t4 <- (cod(char) - 32)  calculated in 'coreBlockAlgorithm'
#          t5 <- (cod(blocKey) - 32)   calculated in 'coreBlockAlgorithm'
#          t6 <- 96 for the modulus
#  Result:
#     t4 <- store the result in t2(base address)
#  *equivalent to use modulus of 96, since ((l - o) - k) is never less then -96 in this case
# =============================================================================================
decipherBlockAlgorithm:
sub t4, t4, t5                                  # t4 <- (cod(char) - 32) - (cod(blocKey) - 32)
blt t4, zero, negModuloDecipBlockAlgorithm
addi t4, t4, 32                                 # t4 += 32

sb t4, 0(t2)                                    # Store the result in the specified location
j blockNextChar

# ============================================================================
# formula used when -> ((cod(b ij) – 32) - (cod(blocKey j) – 32)) < 0
# ============================================================================
negModuloDecipBlockAlgorithm:
add t4, t6, t4                         # t4 <- 96 - t4 / equivalent to the modulus of 96 in this case
addi t4, t4, 32                        # t4 += 32

sb t4, 0(t2)                           # Store the result in the specified location
j blockNextChar

blockNextChar:
addi t0, t0, 1                         # Increment the counter for blocKey string (coreBlockAlg.)
addi t1, t1, 1                         # Increment the counter for myplaintext/cyphertext string (coreBloAlg)
j coreBlockAlgorithm

blocKeyLoop:
li t0, 0                               # Refresh the loop counter for blocKey string
add t3, t0, a1                         # Pass through blocKey string for the new cicle of the string
lb t5, 0(t3)                           # Only the first time, afterwards are used the 'coreBlockAlgorithm' for the iteration
j coreBlockKeyAlgorithm

blockCipDecEnd:
lw t0, 0(sp)                           # Load loop counter of cipher/decipher procedure
addi sp, sp, 4                         # Restore stack

jr ra






# ====================================================================================
#                               encrDecrOccurrence
#
#  Note: Inizializes the Occurrences Algorithm...
#
# Paramethers:
#  t1  <- Base address use in 'positionEncodInASCII' and 'charPositionEncode'
#  t2  <- Base address use in 'charPositionOccur'
#  t3  <- Base address use in 'charEncodeOccur'
#  t4  <- Base address use in 'couterStringOccur'
# ====================================================================================
encrDecrOccurrence:
addi sp, sp, -12                 # Adjust stack for 3 items
sw ra, 8(sp)                     # Return address for cipher/decipher procedure
sw a3, 4(sp)                     # a3 <- is use for mycypher string
sw t0, 0(sp)                     # Store loop counter of cipher/decipher procedure

li t0, -1                        # Flag for decipher algorithm
li t5, 0                         # Loop counter use in 'charPositionOccur'
li t6, 0                         # Loop counter use in 'charEncodeOccur'
li a4, 45                        # Dash separator
li a6, 32                        # Space separator
lw a1, buffOccurString           # a1 <- Address where store the string of the Encryption/Decryption Occurrences
la a3, buffPosition              # Load head of buffPosition

beq a5, t0, decrOccur            # Check if the alogorithm to apply is the encryption or decryption,through a flag(a5)
li t0, 0                         # Used for counts the length of myplaintext string

# ==============================================================
#                    couterStringOccur
#  Note: Counts the number of char of the myplaintext string
#
#  Return: t0 <- will be used in 'charEncodeOccur'
# ==============================================================
couterStringOccur:
add t2, t0, a0                   # Pass through myplaintext string
lb t4, 0(t2)                     # Current character of myplaintext string
beq t4, zero, encrOccur          # Begins the encryption just obtained the string length

addi t0, t0, 1                   # Counts length of myplaintext string
j couterStringOccur


# ===================================================================================================
#                                    encrOccur
#
#  Note: Inizializes the Encryption Occurrences...
#
# ===================================================================================================
encrOccur:
li t4, 0                          # Loop counter use in 'occurSeparDash'
li a7, 1                          # Flag to identify the first occurrence of each character except the first of 'myplaintext'

# ============================================================================================================
#                                     charEncodeOccur
#
#  Note: It occupies of pass through 'myplaintext' string to carry out of two checks.
#          1. Check that it have pass through the entire string, if so the Encryption Occurrences end.
#          2. Check that the current character has not already been previously encrypted, in case
#             it is present several times in the string.
#              - Check that the current character is actually present, since once encrypted a procedure
#                takes care of deleting the character from all its positions in the string. To avoid the
#                same character from being encrypted multiple times when it repeats in the string.
#
# ============================================================================================================
charEncodeOccur:
add t3, t6, a0                        # Pass through myplaintext string
lb a2, 0(t3)                          # a2 <- Current character
beq t6, t0, encrDecrOccurEnd          # Check if myplaintext string is ends, jump to 'encrDecrOccurEnd'
beq a2, zero, nextcharEncodeOccur     # Check that the current character has not already been encrypted


# ====================================================================================================
#                                     charPositionOccur
#
#  Note: Determines the positions where of character 'x', extracted with 'charEncodeOccur',
#        appears in 'myplaintext' string.
#        When it finds a match, it executes 'coreOccurAlgor' which encrypts the position of 'x'.
#        When 'coreOccurAlgor' is finished, 'charPositionOccur' resumes its search where it left off.
#
# ====================================================================================================
charPositionOccur:
add t2, t5, a0                        # Pass through myplaintext string
lb a5, 0(t2)                          # a5 <- Current character
beq t5, t0, nextcharEncodeOccur       # Check if myplaintext string is ends
beq a5, a2, coreOccurAlgor            # Search for all places where character 'x' appears in 'myplaintext' string

charPositionOccurLoop:
addi t5, t5, 1                        # Increment the counter for myplaintext string in 'charPositionOccur'
j charPositionOccur


nextcharEncodeOccur:
li a7, 0                              # Reset the flag to identify the first occurrence of each character, now to 0 because the fist char of 'myplaintext' has been encrypted
addi t6, t6, 1                        # Increment the loop counter used in 'charEncodeOccur'
addi t5, t6, 0                        # Set up loop counter used in 'charPositionOccur', scroll by t6 positions, already encrypted
j charEncodeOccur

# ====================================================================================================================
#                                    coreOccurAlgor
#
#  Note: Is responsible of the encryption operations. Store the result in a3 which represents the
#        address of the head of 'buffOccurString' through 4 steps.
#       1. The first character of the string is loaded via 'firstCharEncode', this step is performed
#          only the first time for each 'cipher'.
#       2. The following characters are handled by 'followSpaceCharEncode' as they must be preceded by a space.
#       3. 'occurSeparDash' follows the procedure that responsible for the separator character '-'.
#       4. The following steps are aimed at converting t5 into ASCII code (index used in 'charPositionOccur')
#          which represents the actual position of the occurrences. Coding required to be printed on screen.
#        - For occurrences with t5 >= 10 'positionEncodInASCII' and 'charPositionEncode' are used as t5 must be
#          decomposed into units in order to perform the ASCII conversion.
#        - For occurrences with t5 < 10 'singleDigitPositEncInASCII' is used as only one digit needs to be
#          converted to ASCII.
#
# ====================================================================================================================
coreOccurAlgor:
addi sp, sp, -12                       # Adjust stack for 3 items
sw t6, 8(sp)                           # Store loop counter use in 'charEncodeOccur'
sw t5, 4(sp)                           # Store loop counter use in 'charPositionOccur'
sw t0, 0(sp)                           # Store myplaintext length

li t2, 10                              # Use for purpose,flag of single digit position and used with REM instruction for multi-digits position
li t3, 3                               # Index counter used for 'buffPosition'
beq t5, zero, firstCharEncode          # Check if it is the first iteration of the encryption, t5 use in 'charPositionOccur'
beq a7, zero, followSpaceCharEncode    # Check if it is first occurrence of each character

# ========================================================================================================================
# Each position is preceded by the separator character '-' (to distinguish the elements of the sequence from positions)
# ========================================================================================================================
occurSeparDash:
add t6, t4, a1                         # Pass through buffOccurString
sb a4, 0(t6)                           # Add dash (45 ASCII)
addi t4, t4, 1                         # Increment couter position where to store the next char sequence to encrypt

addi t5, t5, 1                         # t5 <- occurrences position to convert in ASCII (t5+1 because start from 0)
blt t5, t2 singleDigitPositEncInASCII  # Check if Occurrences position is less then 10

# ==========================================================================================================
#  Occurrences position (t5) >= 10 is converted in ASCII. t5 which represents the position of the
#  occurrences is decomposed into single digit and store in 'buffPosition' (es. t5 = 10 -> buffPosition = 1-0).
# ==========================================================================================================
positionEncodInASCII:
rem t0, t5, t2                         # t5 'modulus' 10 to store in t0 the units (es. 12 REM 10 -> 2)
add t1, t3, a3                         # Pass through 'buffPosition' to store the occurrence position broken down into single digit
sb t0, 0(t1)                           # Store the single digit of the occurrence position in 'buffPosition'

addi t3, t3, -1                        # Decrement index to sroll the position where to store the next digit in 'buffPosition'
div t5, t5, t2                         # Division on t5 remove the first digit already store in 'buffPosition'.
beq t5, zero, charPositionEncode       # If t5 becomes 0 it means that the position value has already been fully decomposed in single digits
j positionEncodInASCII

# ================================================================================================
#  Load and convert the single digits store in 'buffPosition' to ASCII code and then store them into
#  'buffOccurString' so that they can be printed on the screen as a number. (es. cod(1), cod(2) -> 49, 50)
# ================================================================================================
charPositionEncode:
addi t3, t3, 1                         # Inecrement index to load the digit right of 'buffPosition' and convert in ASCII
add t1, t3, a3                         # Pass through 'buffPosition'
lb t0, 0(t1)                           # Load the single digit of the occurrence position
addi t0, t0, 48                        # Converted in ASCII encode
beq t0, zero, nextCharPositionOccur    # Check If 'buffPosition' is emty, search for next occurrence.

add t6, t4, a1                         # Pass through buffOccurString
sb t0, 0(t6)                           # Store the each encoded digit (position) in 'buffOccurString'

addi t4, t4, 1                         # Increment counter to iterate over the 'buffOccurString'
j charPositionEncode

# ===============================================================
#  Occurrences position (t5) < 10 is converted in ASCII.
# ===============================================================
singleDigitPositEncInASCII:
addi t0, t5, 48                        # Converted t5 in ASCII encode
add t6, t4, a1                         # Pass through buffOccurString
sb t0, 0(t6)                           # Store the position of each char

addi t4, t4, 1                         # Increment counter to iterate over the 'buffOccurString'
j nextCharPositionOccur

# ==============================================================================================
#  Executed for the first character of string to be encrypted. Store the character into
#  'buffOccurString' and increment t4 which is the counter to scroll a1 ('buffOccurString').
# ==============================================================================================
firstCharEncode:
add t6, t4, a1                         # Pass through buffOccurString
sb a5, 0(t6)                           # Store the first character in 'buffOccurString'
addi t4, t4, 1                         # Increment couter position where to store the next char sequence to encrypt
j occurSeparDash

# ==================================================================================================
#  Stores space followed by the occurrences of the character to be encrypted into 'buffOccurString'
#  and increment t4 which is the counter to scroll a1 ('buffOccurString'). Also increment a7, which
#  is used to identify the first occur. of each character, because the following operations require
#  only to store the position of the occurrences.
# ==================================================================================================
followSpaceCharEncode:
add t6, t4, a1                         # Pass through 'buffOccurString'
sb a6, 0(t6)                           # Add space (ASCII 32)
addi t4, t4, 1                         # Increment couter position

add t6, t4, a1                         # Pass through 'buffOccurString'
sb a5, 0(t6)                           # Store the Occurrences of the character
addi t4, t4, 1                         # Increment couter position
addi a7, a7, 1                         # Increment the flag to identify the first occur. of each char
j occurSeparDash

# ========================================================================================
#  Restore the index used in 'charEncodeOccur' and 'charPositionOccur'. Remove every occurrence
#  of each character store in 'myplaintext' string, to avoid duplication.
# ========================================================================================
nextCharPositionOccur:
lw t0, 0(sp)                           # Load length of 'myplaintext' string
lw t5, 4(sp)                           # Load loop counter use in 'charPositionOccur'
lw t6, 8(sp)                           # Load loop counter use in 'charEncodeOccur'
addi sp, sp, 12                        # Restore stack

add t2, t5, a0                         # Pass through 'myplaintext' string
sb zero, 0(t2)                         # Remove every occurrence of each character
addi t5, t5, 1                         # Increment the counter used in 'charPositionOccur' (research of character occurrence)
j charPositionOccur



# ====================================================================================
#                               decrOccur
#
#  Note: Inizializes the Decryption Occurrences...
#
# ====================================================================================
decrOccur:
addi sp, sp, -4                        # Adjust stack for 1 items
sw a5, 0(sp)                           # a5 (= -1) -> Flag that trigger the use of decryption algorithms

li t0, 0                               # Loop counter used in 'charDencodeOccur'
li a7, 10                              # Used in 'storePositionOccurCharOccurChar' for multiplication

# ============================================================================================================
#                                     charDencodeOccur
#
#  Note:  The character to be decrypted is extracted from a0,'cyphertext' string, and then store into 'buffOccurString',
#         in all the positions occupied by the character before encoding. (es. a-1-3...c-5 -> a_a_c__)
#         The  'cyphertext' string is cleaned up, from the character and from the next dash. (es. //1-3.. -> a_a____)
#         In the following steps, all characters of the encryption will be removed to be stored into decrypted 'buffOccurString'.
#
# ============================================================================================================
charDencodeOccur:
add t3, t0, a0                         # Pass through 'cyphertext' string
lb t1, 0(t3)                           # Current character of cyphertext string

li t5, 0                               # Use to identify first digit of occurrence position
addi t4, t0, 2                         # t4 <- loop couter used in 'decryptOccurAlgorithm' increased by 2 to avoid char and dash
sb zero, 0(t3)                         # Remove letter form a0
sb zero, 1(t3)                         # Remove dash form a0


# ====================================================================================================================================================================
#                                     decryptOccurAlgorithm
#
#  Note: Load the single digit that shape the position of the occurrence of the character.
#        To do the reverse conversion from ASCII to a usable index. Make 3 checks:
#         1. Check if the 'cyphertext' string has been fully crossing, ending the decryption algorithm.
#         2. Check if the loaded character is a Dash(-), if it is increment t4 (loop counter) via 'nextPositOccurDash' (es. ...8->-10, (-)->10).
#         3. Check if the loaded character is a Space( ), if so it means that all occurrences of the character have been decrypted (es. a-1-2->' 'b-3, ' '->b...)
#            It executes 'nextCharDecOccurSpace' which takes care of moving to the next character to be deciphered.
#        Convert from ASCII to position, Check if it is the first iteration of 'decryptOccurAlgorithm', if so, load the value of t2 in 'buffPosition' (a3)
#        and then remove the value from the 'cyphertext' character that identifies the position of the occurrence.
#        Otherwise the position is multi-digit >= 10 and 'storePositionOccurChar' is executed.
# ====================================================================================================================================================================
decryptOccurAlgorithm:
add t3, t4, a0                         # Pass through 'cyphertext' string
lb t2, 0(t3)                           # Load a single digit (es. ..->40, t2->4)
beq t2, zero, endDecrOccur             # Check if the 'cyphertext' string has been fully crossing
beq t2, a4, nextPositOccurDash         # Check if the loaded character is a Dash('-', ASCII 45)
beq t2, a6 nextCharDecOccurSpace       # Check if the loaded character is a Space(' ', ASCII 32)

addi t2, t2, -48                       # Converted ASCII in position (es. ASCII-cod(54)->(54-48)->6)
bne t5, zero, storePositionOccurChar   # Check if it is the first iteration of 'decryptOccurAlgorithm', used for multi-digits occurrences position

add t6, a3, zero                       # Pass through 'buffPosition'
sw t2, 0(t6)                           # Store the occurrences position of each character in 'buffPosition' (es. ...->1|00 -> a3=1)
sb zero, 0(t3)                         # Remove the occurrence position form 'cyphertext' string (a0 -> ..8-12, ../-12)
addi t5, t5, 1                         # Increment the index in case of multi-digits occurrences position
j nextPositDecrOccurAlg

# =================================================================================================================================
#   It deals with recomposing the occurrence position. Since it is saved in ASCII any code must be read converted and reassembled.
#   Calcultate the occurrence position >= 10 (multi-digits). The last digit store in 'buffPosition' is loaded in a5, multiplied
#   by 10 to move from units to decenes etc. Next digit save in t2 is added to a5, then store back to 'buffPosition'
#   (es. 123 ->cod(1),cod(2),cod(3)-> ASCII:49,50,51-> t2=49-48= 1 store in a3-> t2=50-48= 2-> load a5=1*10 = 10+t2= 12 store in a3
#      t2=51-48= 3-> load a5=12*10 = 120+t2= 123-> occurrence position converted)
# =================================================================================================================================
storePositionOccurChar:
lw a5, 0(a3)                           # Load in a5 an intermediate calculation of occurrence position (es. 1. a5<-a3=1 -> 2. a5<-a3=12)
mul a5, a5, a7                         # a5 *= 10(a7) (es. 1. a5=1*10=10 -> 2. a5=12*10=120)
add a5, a5, t2                         # a5 += t2     (es. 1. a5=10+t2(2)=12 -> 2. a5=120+t2(3)=123)

add t6, a3, zero
sw a5, 0(t6)                           # Store the occurrence position in 'buffPosition'  (1. a3<-a5=12)
sb zero, 0(t3)                         # Remove the occurrence position form 'cyphertext' string

nextPositDecrOccurAlg:
addi t4, t4, 1                         # Increment the counter used in 'decryptOccurAlgorithm'
j decryptOccurAlgorithm

# ========================================================================================================
#  It means that all occurrences of the character have been decrypted (es. a-1-2->' 'b-3, ' '->b-3)
# ========================================================================================================
nextCharDecOccurSpace:
jal storeDecrChar
addi t0, t4, 1                         # Set the counter used in 'charDencodeOccur' (es. ->a-1-2 b-3, ...->b-3 t0=5)
j charDencodeOccur

# ==================================================================================
# When there is a dash, the letter is saved in the position specified by a5 less 1
# ==================================================================================
nextPositOccurDash:
jal storeDecrChar
li t5, 0                               # Reset t5, use to identify first digit of occurrence position
addi t4, t4, 1                         # Increment the counter used in 'decryptOccurAlgorithm'
j decryptOccurAlgorithm

# =========================================================================================
#  Load the occurrence position, decrease by because array starts from 0.
#  Use a5 to calculate the position of the character to store on the 'cyphertext' string.
# =========================================================================================
storeDecrChar:
lw a5, 0(a3)                           # Load the occurrence position of the decrypted character (es. a5=3)
addi a5, a5 , -1                       # a5 -= 1 (array start from 0) (es. a5-1=2)
add a2, a5, a1                         # String to store the decryption with the exact location of the character (es. __a_)
sb t1, 0(a2)                           # Current character to store (es. 'a') in buffOccurString
sb zero, 0(t3)                         # Remove the position number form a0, 'cyphertext' string
jr ra


endDecrOccur:
jal storeDecrChar

lw a5, 0(sp)                           # Restore a5 to -1
addi sp, sp, 4                         # Restore stack
j encrDecrOccurEnd




# =================================================================================================================
#                                 encrDecrOccurEnd
#   In the Occurrences algorithm 'buffOccurString' is used to load all cryptography and decryption results starting
#   from address 2000 (section .text) .
#   It is concluded by transferring all the characters from a1 'buffOccurString', to the starting position a0,
#   'myplaintext'/'cyphertext'(section .data). This process is carried out to avoid overlapping with the application of more
#   than one occurrence algorithm ('CC') on the same string, since it is parsed in random order according to
#   the reference character, unlike other algorithms that have a sequential trend (character that is read is the
#   same one that is encrypted, in the same position).
#
# ================================================================================================================
encrDecrOccurEnd:                      # Each char is pass by value to a0 from a1
li t5, 0                               # Loop counter

encrDecrOccurEndByValue:
add t2, t5, a1                         # Pass through 'buffOccurString'
lb t1, 0(t2)                           # Load character from 'buffOccurString'
beq t1, zero restoreStakOccurEnd       # Check when it has been fully crossing

add t3, t5, a0                         # Pass through 'myplaintext'/'cyphertext' string
sb t1, 0(t3)                           # Store the character load from 'buffOccurString' in to the string

loopEndOccur:
addi t5, t5, 1                         # Increment loop counter
sb zero, 0(t2)                         # Remove all characters form 'buffOccurString' (a1)
j encrDecrOccurEndByValue


restoreStakOccurEnd:
lw t0, 0(sp)                           # Load loop counter of cipher/decipher procedure
lw a3, 4(sp)                           # Load mycypher string used in cipher/decipher
lw ra, 8(sp)                           # Load return address, to return to cipher/decipher procedure
addi sp, sp, 12                        # Return stack
jr  ra






# ===========================================================================================
#                                       dictionary
#  Note : If it is a letter apply formula letters:
#          'Z' - letter + 'a' / 'z' - letter + 'A'
#         If it is a number apply formula number: cod(57) - number
#         Otherwise it loads the same character.
#         Dictionary algorithm is used for both encryption and decryption with the same process.
# ===========================================================================================
dictionary:
addi sp, sp, -8                        # Adjust stack for 2 items
sw ra, 4(sp)                           # Store return address for cipher/decipher procedure
sw t0, 0(sp)                           # Store loop counter of cipher/decipher procedure

li t1, 0                               # Loop couter used in 'coreDictionaryAlgorithm'
li t3, -1                              # Flag for character that are NOT letters
li t4, 97                              # Flag for lowercase letter
li t6, 57                              # ASCII code for character '9' - 57
li a7, 48                              # ASCII code for character '0' - 48


coreDictionaryAlgorithm:
add t2, t1, a0                         # Pass through 'myplaintext'/'cyphertext' string
lb a6, 0(t2)                           # Current character
beq a6, zero, endDictionary            # Check if string has been fully crossed

jal getCharOffset                      # Executes a procedure that identifies the nature of the characters and returns the appropriate offset

add t5, a6, zero                       # t5 take the value of the current character
beq a1, t3, dictionaryIsNotALetter     # Check if a1= -1 it isn't a letter,
bge a1, t4 dictLowercaseAlgorithm      # Check that it is a lowercase letter, if it is > 122 in 'getCharOffset' would be set a1 to -1.

# ==========================================================
# 'z' - letter + 'A'
# 122 - letter + 65   (es. 122 - 'A/65' + 65 =  'z/122')
# ==========================================================
dictUpperCaseAlgorithm:
neg t5, t5
addi t5, t5, 122
add t5, t5, a1
j nextCharDictionary

# =================================================
# 'Z' - letter + 'a'
# 90  - letter + 97
# =================================================
dictLowercaseAlgorithm:
neg t5, t5
addi t5, t5, 90
add t5, t5, a1
j nextCharDictionary

# ===============================================================
#  Check if it's a number, otherwise it loads the same character
# ===============================================================
dictionaryIsNotALetter:
blt t5, a7 nextCharDictionary          # If t5 is less of 0(48), it isn't a number
bgt t5, t6 nextCharDictionary          # If t5 is greater of 9(57), it isn't a number

# ======================================================================
#  cod(57) - number
# (es. cod(4)->ASCII(52)->ASCII(52-48)=4->ASCII(57-4)->ASCII(53)=5)
# ======================================================================
addi t5, t5, -48                      # t5 -= 48
sub t5, t6, t5                        # t5 <- ASCII(57 - t5)
j nextCharDictionary

# =======================================================
# Store the result in 'myplaintext'/'cyphertext' string
# =======================================================
nextCharDictionary:
sb t5, 0(t2)
addi t1, t1, 1                        # Increment loop couter used in 'coreDictionaryAlgorithm'
j coreDictionaryAlgorithm

endDictionary:
lw t0, 0(sp)
lw ra, 4(sp)
addi sp, sp, 8

jr  ra



# =========================================================================================================
#                              getCharOffset
#
#  Note: Returns the right offset to execute operations in 'coreCaesarAlgorithm' and 'coreDictionaryAlgorithm'.
#        It deals with classifying the characters in three ways:
#        1. if it is a lowercase letter it is assigned offset 97, ASCII 'a'.
#        2. if it is a UPPERCASE letter it is assigned offset 65, ASCII 'A'.
#        3. if it is not a letter, a1 is set to -1 as flag.
#
#  Paramether:
#
#
#  Return: Possible results...
#            1. a1 = 97-(lowercase)     2. a1 = 65-(UPPERCASE)    3. a1 = -1-(NOT a letter)
#
# =========================================================================================================
getCharOffset:
addi sp, sp, -8                      # Adjust stack for 2 items
sw ra, 4(sp)                         # Return address for 'coreCaesarAlgorithm' or 'coreDictionaryAlgorithm'
sw t1, 0(sp)                         # Store current index use in 'coreCaesarAlgorithm'

jal isLowerCase

lw t1, 0(sp)
lw ra, 4(sp)
addi sp, sp, 8                       # Return stack

beq a1, zero, offsetCipherUpperCase  # Check if it is UPPERCASE (a1 = 0) of lowercase (a1 = 1)

offsetCipherLowerCase:
li a1, 97                            # Offset 97, ASCII 'a'
jr ra

offsetCipherUpperCase:
li a1, 65                            # Offset 65, ASCII 'A'
jr ra

# ======================================================================================
# Check If a6 is a lowercase letter a1 is set to 1
# ======================================================================================
isLowerCase:
li t0, 97                            # ASCII code for character 'a' - 97
li t1, 122                           # ASCII code for character 'z' - 122

blt a6, t0, isNotLowerCase           # Check that a6 < 97, it isn't lowercase letter
bgt a6, t1, isNotALetter             # Check that a6 > 122, it isn't a letter

li a1, 1                             # Used to execute 'offsetCipherLowerCase'
jr ra

# ======================================================================================
#  Check if ASCII character is not a letter between 91 and 96 or less of 65.
#  Otherwise a6 is a UPPERCASE letter and is set a1 to 0.
# ======================================================================================
isNotLowerCase:
li t0, 91                            # ASCII code for character '[' - 91
li t1, 65                            # ASCII code for character 'A' - 65

bge a6, t0, isNotALetter             # greater than 90(Z)
blt a6, t1, isNotALetter             # less than 65(A)

li a1, 0                             # Used to execute 'offsetCipherUpperCase'
jr ra

isNotALetter:
lw t1, 0(sp)
lw ra 4(sp)
addi sp, sp, 8

li a1, -1                            # It isn't a letter, set a1 = -1 as flag
jr ra





# =============================================================================
# Print 'myplaintext' string the first time in absolut and return to the main
# =============================================================================
print_plaintext:
add a0, a2, zero
li a7, 4
ecall

jr ra                       # Return to the main


# ============================================================================
# Print the outputs of each encryption and decryption separataed by 'newline'.
# Return to the chiper/decipher procedure
# ============================================================================
printCipherDecipher:
add a1, a0, zero            # use a1 to print the output because a0 is used by 'newline'

li a0, 10                   # 'newline' ASCII 10 code, used to differentiate the outputs
li a7, 11
ecall

add a0, a1, zero            # Print the output, 'myplaintext'/'cyphertext' string
li a7, 4
ecall

jr ra                       # Return to the chiper/decipher procedure

# =====================================
# ...end program
# =====================================
endMain:
