*-----------------------------------------------------------
* Title        :  68k Dissasembler
* Written by   :  Group B2
* Date         :  04/20/2018
* Description  :  Simple dissasembler for 68k machine code
*-----------------------------------------------------------

* A2 is used to store current pointer for loading data
* A3 is used to store end of memory to read
* A4 is used to store the message of the instruction to be printed (0 for raw data)
* D6 is used to store addressing mode/data of instruction (0 for N/A)
    * NOTE: D6 is used as word data where the most significant byte represents the destination mode/data
    * And the least significant byte is used as the source mode/data
* D7 is used to store the counter of how many lines have been printed since last prompting the user to continue

* Text messages
* Minimum starting address
MINADDR DS.L    1
* Maximum starting address
MAXADDR DS.L    1

OPENM   DC.B    'HELLO!',0
STAB    DC.B    '    ',0
SPACE   DC.B    ' ',0
COMMA   DC.B    ',',0
SLASH   DC.B    '/',0
CONTM   DC.B    'Press Enter to Continue',0
MORE    DC.B    'Do you want to load another program? (y or n)',0
MINV    DC.B    'Invalid response',0
BYEM    DC.B    'Goodbye!',0
PROMPTS DC.B    'Please enter a starting address between 0x',0
PROMPTE DC.B    'Please enter an ending address between 0x',0
ANDM    DC.B    ' and 0x',0

* Addressing mode strings
DN      DC.B    'D',0
AN      DC.B    'A',0
ANP1    DC.B    '(A',0
ANP2    DC.B    ')+',0
ANM1    DC.B    '-(A',0
ANM2    DC.B    ')',0
HEXA    DC.B    '$',0
HEXD    DC.B    '#$',0

* Buffer for taking input (up to 80 chars for Trap #2)
BUFF    DC.B    '00000000000000000000000000000000000000000000000000000000000000000000000000000000',0

MRAW   DC.B    'RAW DATA: 0x',0

* List of all possible instructions for printing
MNOP    DC.B    'NOP       ',0
MMOVEB  DC.B    'MOVE.B    ',0
MMOVEW  DC.B    'MOVE.W    ',0
MMOVEL  DC.B    'MOVE.L    ',0
MMOVEAW DC.B    'MOVEA.W   ',0
MMOVEAL DC.B    'MOVEA.L   ',0
MMOVEQ  DC.B    'MOVEQ     ',0
MMOVEMW DC.B    'MOVEM.W   ',0
MMOVEML DC.B    'MOVEM.L   ',0
MADDB   DC.B    'ADD.B     ',0
MADDW   DC.B    'ADD.W     ',0
MADDL   DC.B    'ADD.L     ',0
MADDAW  DC.B    'ADDA.W    ',0
MADDAL  DC.B    'ADDA.L    ',0
MSUBAW  DC.B    'SUBA.W    ',0
MSUBAL  DC.B    'SUBA.L    ',0
MADDIB  DC.B    'ADDI.B    ',0
MADDIW  DC.B    'ADDI.W    ',0
MADDIL  DC.B    'ADDI.L    ',0
MADDQB  DC.B    'ADDQ.B    ',0
MADDQW  DC.B    'ADDQ.W    ',0
MADDQL  DC.B    'ADDQ.L    ',0
MSUBB   DC.B    'SUB.B     ',0
MSUBW   DC.B    'SUB.W     ',0
MSUBL   DC.B    'SUB.L     ',0
MSUBIB  DC.B    'SUBI.B    ',0
MSUBIW  DC.B    'SUBI.W    ',0
MSUBIL  DC.B    'SUBI.L    ',0
MRTS    DC.B    'RTS       ',0
MMULSW  DC.B    'MULS.W    ',0
MMULUW  DC.B    'MULU.W    ',0
MDIVUW  DC.B    'DIVU.W    ',0
MLEA    DC.B    'LEA       ',0
MCLRB   DC.B    'CLR.B     ',0
MCLRW   DC.B    'CLR.W     ',0
MCLRL   DC.B    'CLR.L     ',0
MANDB   DC.B    'AND.B     ',0
MANDW   DC.B    'AND.W     ',0
MANDL   DC.B    'AND.L     ',0
MORB    DC.B    'OR.B      ',0
MORW    DC.B    'OR.W      ',0
MORL    DC.B    'OR.L      ',0
MLSL    DC.B    'LSL       ',0
MLSLB   DC.B    'LSL.B     ',0
MLSLW   DC.B    'LSL.W     ',0
MLSLL   DC.B    'LSL.L     ',0
MLSR    DC.B    'LSR       ',0
MLSRB   DC.B    'LSR.B     ',0
MLSRW   DC.B    'LSR.W     ',0
MLSRL   DC.B    'LSR.L     ',0
MASR    DC.B    'ASR       ',0
MASRB   DC.B    'ASR.B     ',0
MASRW   DC.B    'ASR.W     ',0
MASRL   DC.B    'ASR.L     ',0
MASL    DC.B    'ASL       ',0
MASLB   DC.B    'ASL.B     ',0
MASLW   DC.B    'ASL.W     ',0
MASLL   DC.B    'ASL.L     ',0
MROR    DC.B    'ROR       ',0
MROL    DC.B    'ROL       ',0
MROLB   DC.B    'ROL.B     ',0
MROLW   DC.B    'ROL.W     ',0
MROLL   DC.B    'ROL.L     ',0
MRORB   DC.B    'ROR.B     ',0
MRORW   DC.B    'ROR.W     ',0
MRORL   DC.B    'ROR.L     ',0
MCMPB   DC.B    'CMP.B     ',0
MCMPW   DC.B    'CMP.W     ',0
MCMPL   DC.B    'CMP.L     ',0
MBCC    DC.B    'BCC       ',0
MBGT    DC.B    'BGT       ',0
MBLE    DC.B    'BLE       ',0
MJSR    DC.B    'JSR       ',0

        ORG     $600

openingMessage
        * Print opening message before starting the program
        LEA     OPENM,A1
        MOVE.B  #13,D0
        TRAP    #15
        LEA     SPACE,A1
        MOVE.B  #13,D0
        TRAP    #15
        TRAP    #15
        BRA     start

start
        * Ensure All register we will use are initialized to 0 first
        MOVE.L  #0,D1
        MOVE.L  #0,D2
        MOVE.L  #0,D3
        MOVE.L  #0,D4
        MOVE.L  #0,D5
        MOVE.L  #0,D6
        MOVE.L  #0,D7
        MOVEA.L #0,A1
        MOVEA.L #0,A2
        MOVEA.L #0,A3
        MOVEA.L #0,A4
        MOVEA.L #0,A5
        MOVEA.L #0,A6
        MOVEA.L #$2F00,SP

        BRA     askForAddress

askForAddress
        * Set min and max start
        MOVE.L  #$3000,MINADDR
        MOVE.L  #$FF000,MAXADDR
        BRA     bStart

bStart
        * Ask for start address
        LEA     PROMPTS,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  MINADDR,D2
        BRA     bContinue

bEnd
        * Ask for end address
        LEA     PROMPTE,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  A2,D2
        CMPI.L  #$FFFF,D2
        BGT     bEndLong
        BRA     bContinue

bEndLong
        MOVE.W  A2,D2
        LSR.L   #8,D2
        LSR.L   #8,D2
        JSR     printHexWord
        MOVE.L  A2,D2
        BRA     bContinue

bContinue
        * Print rest of prompt
        JSR     printHexWord
        LEA     ANDM,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  MAXADDR,D2
        JSR     printHexLong
        * Print a new line to seperate input from next line
        LEA     SPACE,A1
        MOVE.B  #13,D0
        TRAP    #15
        BRA     loadUserString

loadUserString
        * Load user string into buffer
        LEA     BUFF,A1
        MOVE.B  #2,D0
        TRAP    #15
        BRA     checkUserHex

invalidHex
        * Print error for invalid input
        LEA     MINV,A1
        MOVE.B  #13,D0
        TRAP    #15
        * If A2 isn't set, we still need to get starting address from user
        CMPA.L  #0,A2
        BEQ     bStart
        * Else we only need ending address from user
        BRA     bEnd

checkUserHex
        * If buffer size is 0, it's invalid
        CMPI.B  #0,D1
        BEQ     invalidHex
        * If first character of buffer is '0', trim it
        CMPI.B  #$30,(A1)
        BEQ     trimZero
        * Ensure trimmed input is less than 8 characters
        CMPI.B  #8,D1
        BGT     invalidHex
        * Else decode hex (clear D4 first)
        MOVE.L  #0,D4
        BRA     decodeHex

trimZero
        * Adjust Buffer Size
        SUBI.B  #1,D1
        * Move buffer forward
        ADDA.L  #1,A1
        BRA     checkUserHex

decodeHex
        * If buffer is empty, finish the decode sequence
        CMPI.B  #0,D1
        BEQ     finishDecode
        * Rotating D4 to make space for next Byte
        ROL.L   #4,D4
        * D3 holds  next byte to convert
        MOVE.B  (A1)+,D3
        * Subtract from buffer size since it moved
        SUBI.B  #1,D1
        * invalid input if < 30
        CMPI.B  #$30,D3
        BLT     invalidHex
        * number if 30 - 39
        CMPI.B  #$39,D3
        BLE     stNum
        * invalid if 3A - 40
        CMPI.B  #$40,D3
        BLE     invalidHex
        * capital letter if 41-46
        CMPI.B  #$46,D3
        BLE     stCap
        * invalid if 47 - 60
        CMPI.B  #$60,D3
        BLE     invalidHex
        * lowercase if 61-66
        CMPI.B  #$66,D3
        BLE     stLow
        * invalid if anything else
        BRA     invalidHex

stNum
        SUBI.B  #$30,D3
        OR.B    D3,D4
        BRA     decodeHex

stCap
        SUBI.B  #$37,D3
        OR.B    D3,D4
        BRA     decodeHex

stLow
        SUBI.B  #$57,D3
        OR.B    D3,D4
        BRA     decodeHex

finishDecode
        * Don't allow hex smaller than MINADDR
        CMP.L   MINADDR,D4
        BLT     invalidHex
        * Don't allow hex larger than MAXADDR
        CMP.L   MAXADDR,D4
        BGT     invalidHex
        * If start isn't loaded yet, load result to start
        CMPA.L  #0,A2
        BEQ     loadToStart
        * Else load result to end
        BRA     loadToEnd

loadToStart
        MOVEA.L D4,A2
        BRA     bEnd

loadToEnd
        * Make sure end is after start user's start
        CMPA.L  D4,A2
        BGT     invalidHex
        MOVEA.L D4,A3
        BRA     readLoop

* Reads through the data sections between A2 and A3
* A0 is moved as the current pointer
readLoop
        CMPA.L  A2,A3
        * If done reading, go to ending
        BLE     ending
        * Else clear D6,A4 and continue
        MOVEA.L #0,A4
        MOVE.L  #0,D6
        BRA     evaluate

evaluate
        * Load current instruction to D3
        MOVE.B  (A2),D3
        * Shift to isolate first 4 bits
        LSR.B   #4,D3
        CMPI.B  #%0000,D3
        BEQ     res0000
        CMPI.B  #%0001,D3
        BEQ     res0001
        CMPI.B  #%0010,D3
        BEQ     res0010
        CMPI.B  #%0011,D3
        BEQ     res0011
        CMPI.B  #%0100,D3
        BEQ     res0100
        CMPI.B  #%0101,D3
        BEQ     res0101
        CMPI.B  #%0110,D3
        BEQ     res0110
        CMPI.B  #%0111,D3
        BEQ     res0111
        CMPI.B  #%1000,D3
        BEQ     res1000
        CMPI.B  #%1001,D3
        BEQ     res1001
        CMPI.B  #%1011,D3
        BEQ     res1011
        CMPI.B  #%1100,D3
        BEQ     res1100
        CMPI.B  #%1101,D3
        BEQ     res1101
        CMPI.B  #%1110,D3
        BEQ     res1110
        * Else not a valid command
        BRA     loadRaw

print
        * Don't print more than 20 lines before asking user to continue
        CMPI.B  #20,D7
        BGE     askToContinue
        * Print the current PC
        MOVE.L  A2,D2
        JSR     printHexLong
        * Print spacing
        LEA     STAB,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Check if need to print raw data or instruction
        CMPA.L  #0,A4
        BEQ     printRaw
        BRA     printInstruction

printRaw
        * Print raw data indicator
        LEA     MRAW,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Print the raw data and move current pointer
        MOVE.W  (A2)+,D2
        JSR     printHexWord
        BRA     printEnd

printInstruction
        * Print the instruction
        MOVEA.L A4,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move the current pointer ahead of printed instruction
        ADDA.L  #2,A2
        * Check if MOVEM (special case for printing)
        LEA     MMOVEMW,A5
        CMPA.L  A5,A4
        BEQ     printMovem
        LEA     MMOVEML,A5
        CMPA.L  A5,A4
        BEQ     printMovem
        BRA     printAddressing

printAddressing
        * If no addressing modes/registers, done printing instruction (i.e. NOP)
        MOVE.W  #0,D5
        MOVE.B  D6,D5
        CMPI.B  #0,D5
        BEQ     printEnd
        * Branch for different addressing modes
        CMPI.W  #$20,D5
        BLT     printDn
        CMPI.W  #$30,D5
        BLT     printAn
        CMPI.W  #$40,D5
        BLT     printAtAn
        CMPI.W  #$50,D5
        BLT     printAnplus
        CMPI.W  #$60,D5
        BLT     printAnminus
        CMPI.W  #$70,D5
        BLT     printAddrw
        CMPI.W  #$80,D5
        BLT     printAddrl
        CMPI.W  #$90,D5
        BLT     printDatab
        CMPI.W  #$A0,D5
        BLT     printDataw
        CMPI.W  #$B0,D5
        BLT     printDatal
        CMPI.W  #$C0,D5
        BLT     printQuickData
        BRA     printBranching

printDn
        * Isolate first 4 bits (register number)
        LSL.B   #4,D6
        LSR.B   #4,D6
        * Print DN
        LEA     DN,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        BRA     printAddressingEnd

printAn
        * Isolate first 4 bits (register number)
        LSL.B   #4,D6
        LSR.B   #4,D6
        * Print AN
        LEA     AN,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        BRA     printAddressingEnd

printAtAn
        * Isolate first 4 bits (register number)
        LSL.B   #4,D6
        LSR.B   #4,D6
        * Print '(A'
        LEA     ANP1,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        * Print ')'
        LEA     ANM2,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     printAddressingEnd

printAnplus
        * Isolate first 4 bits (register number)
        LSL.B   #4,D6
        LSR.B   #4,D6
        * Print '(A'
        LEA     ANP1,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        * Print ')+'
        LEA     ANP2,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     printAddressingEnd

printAnminus
        * Isolate first 4 bits (register number)
        LSL.B   #4,D6
        LSR.B   #4,D6
        * Print '-(A'
        LEA     ANM1,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        * Print ')'
        LEA     ANM2,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     printAddressingEnd

printAddrw
        * Print '$'
        LEA     HEXA,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Print word address and move current pointer
        MOVE.W  (A2)+,D2
        JSR     printHexWord
        BRA     printAddressingEnd

printAddrl
        * Print '$'
        LEA     HEXA,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Print long address and move current pointer
        MOVE.L  (A2)+,D2
        JSR     printHexLong
        BRA     printAddressingEnd

printDatab
        * Print '#$'
        LEA     HEXD,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Print byte data and move current pointer
        MOVE.W  (A2)+,D2
        JSR     printHexByte
        BRA     printAddressingEnd

printDataw
        * Print '#$'
        LEA     HEXD,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Print byte data and move current pointer
        MOVE.W  (A2)+,D2
        JSR     printHexWord
        BRA     printAddressingEnd

printDatal
        * Print '#$'
        LEA     HEXD,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Print byte data and move current pointer
        MOVE.L  (A2)+,D2
        JSR     printHexLong
        BRA     printAddressingEnd

printQuickData
        * Print '#$'
        LEA     HEXD,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Print hex data from first 4 bits of D6
        MOVE.B  D6,D2
        AND.B   #%1111,D2
        JSR     printHexByte
        BRA     printAddressingEnd

printBranching
        * Print '$'
        LEA     HEXA,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Load byte data from D6 to print
        LSR.W   #8,D6
        MOVE.B  D6,D2
        JSR     printHexByte
        BRA     printAddressingEnd

printAddressingEnd
        * Check if there is a destination parameter to print
        LSR.W   #8,D6
        CMPI.B  #0,D6
        BEQ     printEnd
        * There is a destination, print comma then print destination
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     printAddressing

printMovem
        * Get opcode to check direction
        SUBA.L  #2,A2
        MOVE.W  (A2)+,D3
        * Isolate direction bit
        LSR.W   #5,D3
        LSR.W   #5,D3
        AND.B   #%1,D3
        CMPI.B  #0,D3
        BEQ     printMovem0
        BRA     printMovem1

printMovem0
        * If pre-decrement, we must call alternate register print
        MOVE.B  D6,D5
        LSR.B   #4,D5
        CMPI.B  #5,D5
        BEQ     printMovem0dec
        BRA     printMovem0norm

printMovem0norm
        JSR     printMovemReg1
        BRA     printMovem0Cont

printMovem0dec
        JSR     printMovemReg2
        BRA     printMovem0Cont

printMovem0Cont
        * Print Comma
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Utilizing regular addressing printing works here
        BRA     printAddressing

printMovem1
        * Must check for possible register modes
        MOVE.B  D6,D5
        LSR.B   #4,D5
        CMPI.B  #3,D5
        BEQ     printMovemAtAn
        CMPI.B  #4,D5
        BEQ     printMovemAnplus
        CMPI.B  #6,D5
        BEQ     printMovemAddrw
        BRA     printMovemAddrl

printMovem1Cont
        * Print Comma
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        JSR     printMovemReg1
        BRA     printEnd

printMovemReg1
        * Set counters for reg printer
        MOVE.L  #7,D5
        MOVE.L  #0,D4
        BRA     printMovemReg1Loop

printMovemReg1Loop
        * Check counter first
        CMPI.L  #0,D5
        BLT     printMovemReg1Cont
        * Copy register masks
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.W   D5,D3
        AND.B   #%1,D3
        CMPI.B  #1,D3
        BEQ     printMovemReg1A
        SUBI.L  #1,D5
        BRA     printMovemReg1Loop

printMovemReg1A
        JSR     printMovemA
        SUBI.L  #1,D5
        BRA     printMovemReg1Loop

printMovemReg1Cont
        * Set counter for printing again
        MOVE.L  #7,D5
        BRA     printMovemReg1ContLoop

printMovemReg1ContLoop
        * Check counter first
        CMPI.L  #0,D5
        BLT     printMovemReg1End
        * Copy register masks
        MOVE.W  (A2),D3
        LSR.W   D5,D3
        AND.B   #%1,D3
        CMPI.B  #1,D3
        BEQ     printMovemReg1D
        SUBI.L  #1,D5
        BRA     printMovemReg1ContLoop

printMovemReg1D
        JSR     printMovemD
        SUBI.L  #1,D5
        BRA     printMovemReg1ContLoop

printMovemReg1End
        * Shift pointer after masks and return
        ADDA.L  #2,A2
        RTS

printMovemReg2
        * Set counters for reg printer
        MOVE.L  #7,D5
        MOVE.L  #0,D4
        BRA     printMovemReg2Loop

printMovemReg2Loop
        * Check counter first
        CMPI.L  #0,D5
        BLT     printMovemReg2Cont
        * Copy register masks
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.W   D5,D3
        AND.B   #%1,D3
        CMPI.B  #1,D3
        BEQ     printMovemReg2D
        SUBI.L  #1,D5
        BRA     printMovemReg2Loop

printMovemReg2D
        * Adjust counter to adjust for opposite offset
        MOVE.L  #7,D3
        SUB.B   D5,D3
        MOVE.B  D3,D5
        JSR     printMovemD
        * Put counter back
        MOVE.L  #7,D3
        SUB.B   D5,D3
        MOVE.B  D3,D5
        SUBI.L  #1,D5
        BRA     printMovemReg2Loop

printMovemReg2Cont
        * Set counter for printing again
        MOVE.L  #7,D5
        BRA     printMovemReg2ContLoop

printMovemReg2ContLoop
        * Check counter first
        CMPI.L  #0,D5
        BLT     printMovemReg2End
        * Copy register masks
        MOVE.W  (A2),D3
        LSR.W   D5,D3
        AND.B   #%1,D3
        CMPI.B  #1,D3
        BEQ     printMovemReg2A
        SUBI.L  #1,D5
        BRA     printMovemReg2ContLoop

printMovemReg2A
        * Adjust counter to adjust for opposite offset
        MOVE.L  #7,D3
        SUB.B   D5,D3
        MOVE.B  D3,D5
        JSR     printMovemA
        * Put counter back
        MOVE.L  #7,D3
        SUB.B   D5,D3
        MOVE.B  D3,D5
        SUBI.L  #1,D5
        BRA     printMovemReg2ContLoop

printMovemReg2End
        * Shift pointer after masks and return
        ADDA.L  #2,A2
        RTS

printMovemAtAn
        * Isolate first 4 bits (register number)
        LSL.B   #4,D6
        LSR.B   #4,D6
        * Print '(A'
        LEA     ANP1,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        * Print ')'
        LEA     ANM2,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     printMovem1Cont

printMovemAnplus
        * Isolate first 4 bits (register number)
        LSL.B   #4,D6
        LSR.B   #4,D6
        * Print '(A'
        LEA     ANP1,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        * Print ')+'
        LEA     ANP2,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     printMovem1Cont

printMovemAddrw
        * Print '$'
        LEA     HEXA,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Adjust pointer to correct point in memory
        ADDA.L  #2,A2
        * Print word address and move current pointer
        MOVE.W  (A2),D2
        JSR     printHexWord
        * Print Comma
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move pointer back to correct spot before printing masks
        SUBA.L  #2,A2
        JSR     printMovemReg1
        * Finally move pointer to correct spot after entire opcode
        ADDA.L  #2,A2
        BRA     printEnd

printMovemAddrl
        * Print '$'
        LEA     HEXA,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Adjust pointer to correct point in memory
        ADDA.L  #2,A2
        * Print long address and move current pointer
        MOVE.L  (A2),D2
        JSR     printHexLong
        * Print Comma
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move pointer back to correct spot before printing masks
        SUBA.L  #2,A2
        JSR     printMovemReg1
        * Finally move pointer to correct spot after entire opcode
        ADDA.L  #4,A2
        BRA     printEnd

printMovemD
        CMPI.B  #0,D4
        BNE     printMovemDSlash
        ADDQ.B  #1,D4
        BRA     printMovemDCont

printMovemDSlash
        * Print slash
        LEA     SLASH,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     printMovemDCont

printMovemDCont
        * Print DN
        LEA     DN,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D5,D1
        MOVE.B  #3,D0
        TRAP    #15
        RTS

printMovemA
        CMPI.B  #0,D4
        BNE     printMovemASlash
        ADDQ.B  #1,D4
        BRA     printMovemACont

printMovemASlash
        * Print slash
        LEA     SLASH,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     printMovemACont

printMovemACont
        * Print AN
        LEA     AN,A1
        MOVE.B  #14,D0
        TRAP    #15
        * Move register number to D1.L to print
        MOVE.L  #0,D1
        MOVE.B  D5,D1
        MOVE.B  #3,D0
        TRAP    #15
        RTS

printEnd
        * End line
        LEA     SPACE,A1
        MOVE.B  #13,D0
        TRAP    #15
        * Add to printed line counter
        ADD.B   #1,D7
        * Evaluate next instruction
        BRA     readLoop

* Prints the long hex from D2 i.e. 3DAB5A39
printHexLong
        * Save registers we will use to restore at end
        MOVEM.L D3,-(SP)
        * Copy to D3 first, then move to print in correct order
        MOVE.W  D2,D3
        LSR.L   #8,D2
        LSR.L   #8,D2
        JSR     printHexWord
        MOVE.W  D3,D2
        JSR     printHexWord
        MOVEM.L (SP)+,D3
        RTS

* Prints the word hex from D2 i.e. 15AF
printHexWord
        * Save registers we will use to restore at end
        MOVEM.L D3,-(SP)
        * Copy to D3 first, then move to print in correct order
        MOVE.B  D2,D3
        LSR.W   #8,D2
        JSR     printHexByte
        MOVE.B  D3,D2
        JSR     printHexByte
        MOVEM.L (SP)+,D3
        RTS

* Prints the byte hex from D2 i.e. 1A
printHexByte
        * Save registers we will use to restore at end
        MOVEM.L D0-D4/A1,-(SP)
        * Set counters on D3
        MOVE.L  #0,D3
        * Load buffer
        LEA     BUFF,A1
        BRA     printHexLoop

printHexLoop
        * Check counter before continuing
        CMPI.B  #4,D3
        BGT     printHexTrap

        MOVE.B  D2,D4
        * Shift data to isolate single hex digit
        LSL.B   D3,D4
        LSR.B   #4,D4
        CMPI.B  #$9,D4
        BLE     hexNum
        ADDI.B  #$37,D4
        MOVE.B  D4,(A1)+
        * Set counter and continue
        ADDI.B  #4,D3
        BRA     printHexLoop

hexNum
        ADDI.B  #$30,D4
        MOVE.B  D4,(A1)+
        * Set counter and continue
        ADDI.B  #4,D3
        BRA     printHexLoop

printHexTrap
        * Print 2 characters from the buffer
        MOVE.W  #2,D1
        MOVE.B  #1,D0
        LEA     BUFF,A1
        TRAP    #15
        * Put buffers back and return
        MOVEM.L (SP)+,D0-D4/A1
        RTS

askToContinue
        * Print message prompting user input
        LEA     CONTM,A1
        MOVE.B  #13,D0
        TRAP    #15
        * Wait for input
        MOVE.B  #4,D0
        TRAP    #15

        MOVE.B  #0,D7
        BRA     print

ending
        * Ask user if they want to do it again
        LEA     MORE,A1
        MOVE.B  #13,D0
        TRAP    #15
        * Wait for single character input
        MOVE.B  #5,D0
        TRAP    #15
        * Print a new line to seperate input from next line
        LEA     SPACE,A1
        MOVE.B  #13,D0
        TRAP    #15

        CMPI.B  #'y',D1
        BEQ     start
        CMPI.B  #'n',D1
        BEQ     final

        BRA     endingInv

endingInv
        LEA     MINV,A1
        MOVE.B  #13,D0
        TRAP    #15
        BRA     ending

res0000
        MOVE.B  (A2),D3
        LSR.B   #1,D3
        AND.B   #%00000111,D3
        CMPI.B  #%010,D3
        *SUBI   0000 010
        BEQ     checkSubi
        *ADDI   0000 011
        BRA     checkAddi

res0001
        *MOVE.B 0001
        BRA     checkMoveb

res0010
        MOVE.W  (A2),D3
        LSR.B   #6,D3
        CMPI.B  #%01,D3
        *MOVEA.L 0010 xxx 001
        BEQ     checkMoveal
        *MOVE.L  0010 xxx !001
        BRA     checkMovel

res0011
        MOVE.W  (A2),D3
        LSR.B   #6,D3
        CMPI.B  #%01,D3
        *MOVEA.W 0011 xxx 001
        BEQ     checkMoveaw
        *MOVE.W  0011 xxx !001
        BRA     checkMovew

res0100
        MOVE.B  (A2),D3
        AND.B   #%00000001,D3
        CMPI.B  #1,D3
        *LEA    0100 xxx 1
        BEQ     checkLea
        MOVE.B  (A2),D3
        LSR.B   #1,D3
        AND.B   #%00000111,D3
        CMPI.B  #%111,D3
        BEQ     res0100111
        CMPI.B  #%110,D3
        BEQ     checkMovem
        CMPI.B  #%100,D3
        *CLR    0100 001 0
        BLT     checkClr
        *MOVEM  0100 1x0 01
        BRA     checkMovem

res0100111
        MOVE.W  (A2),D3
        LSR.B   #7,D3
        CMPI.B  #1,D3
        *JSR    0100 111 01
        BEQ     checkJsr
        MOVE.W  (A2),D3
        LSR.B   #2,D3
        CMPI.B  #%00011100,D3
        *NOP    0100 111 001 110 0
        BEQ     checkNop
        *RTS    0100 111 001 110 1
        BRA     checkRts

res0101
        *ADDQ   0101
        BRA     checkAddq

res0110
        MOVE.B  (A2),D3
        AND.B   #%00001111,D3
        CMPI.B  #%1110,D3
        *BCC    0110 0
        BLT     checkBcc
        CMPI.B  #%1111,D3
        *BGT    0110 1110
        BLT     checkBgt
        *BLE    0110 1111
        BRA     checkBle

res0111
        *MOVEQ  0111
        BRA     checkMoveq

res1000
        MOVE.W  (A2),D3
        LSR.B   #6,D3
        CMPI.B  #%11,D3
        *DIVU.W 1000 xxx 011
        BEQ     checkDivuw
        *OR     1000 xxx !011
        BRA     checkOr

res1001
        MOVE.W  (A2),D3
        LSR.W   #6,D3
        AND.B   #%111,D3
        CMPI.B  #%011,D3
        *SUBA   1001 xxx (011 || 111)
        BEQ     checkSuba
        CMPI.B  #%111,D3
        *SUBA   1001 xxx (011 || 111)
        BEQ     checkSuba
        *SUB    1001 xxx !(011 || 111)
        BRA     checkSub

res1011
        *CMP    1011
        BRA     checkCmp

res1100
        MOVE.W  (A2),D3
        LSR.W   #6,D3
        AND.B   #%00000111,D3
        CMPI.B  #%011,D3
        *MULU.W 1100 xxx 011
        BEQ     checkMuluw
        CMPI.B  #%111,D3
        *MULS.W 1100 xxx 111
        BEQ     checkMulsw
        *AND    1100 xxx !(011 || 111)
        BRA     checkAnd

res1101
        MOVE.W  (A2),D3
        LSR.W   #6,D3
        AND.B   #%00000111,D3
        CMPI.B  #%011,D3
        *ADDA   1101 xxx (011 || 111)
        BEQ     checkAdda
        CMPI.B  #%111,D3
        *ADDA   1101 xxx (011 || 111)
        BEQ     checkAdda
        *ADD    1101 xxx !(011 || 111)
        BRA     checkAdd

res1110
        MOVE.W  (A2),D3
        LSR.W   #6,D3
        AND.B   #%00111111,D3
        CMPI.B  #%000011,D3
        *ASR MEM 1110 000 0 11
        BEQ     checkAsrmem
        CMPI.B  #%000111,D3
        *ASL MEM 1110 000 1 11
        BEQ     checkAslmem
        CMPI.B  #%001011,D3
        *LSR MEM 1110 001 0 11
        BEQ     checkLsrmem
        CMPI.B  #%001111,D3
        *LSL MEM 1110 001 1 11
        BEQ     checkLslmem
        CMPI.B  #%011011,D3
        *ROR MEM 1110 011 0 11
        BEQ     checkRormem
        CMPI.B  #%011111,D3
        *ROL MEM 1110 011 1 11
        BEQ     checkRolmem
        BRA     res1110Reg

res1110Reg
        MOVE.B  (A2),D3
        AND.B   #%00000001,D3
        CMPI.B  #1,D3
        BEQ     res1110Reg1
        MOVE.W  (A2),D3
        LSR.B   #3,D3
        AND.B   #%00000011,D3
        CMPI.B  #0,D3
        *ASR REG 1110 xxx 0 !(11) x00
        BEQ     checkAsrreg
        CMPI.B  #1,D3
        *LSR REG 1110 xxx 0 !(11) x01
        BEQ     checkLsrreg
        *ROR REG 1110 xxx 0 !(11) x1
        BRA     checkRorreg

res1110Reg1
        MOVE.W  (A2),D3
        LSR.B   #3,D3
        AND.B   #%00000011,D3
        CMPI.B  #0,D3
        *ASL REG 1110 xxx 1 !(11) x00
        BEQ     checkAslreg
        CMPI.B  #1,D3
        *LSL REG 1110 xxx 1 !(11) x01
        BEQ     checkLslreg
        *ROL REG 1110 xxx 1 !(11) x1
        BRA     checkRolreg


* Loads relevant address to indicate raw data then call print
loadRaw
        MOVEA.L #0,A4
        BRA     print

checkSubi
        MOVE.W  (A2),D4
        MOVE.L  #0,D6
        * d6 clear, d4 is data at
        LSR.W   #8,D4
        AND.B   #%1111,D4
        CMPI.B  #%0100,D4
        BNE     loadRaw
        MOVE.W  (A2),D4
        * isolating last 6 bits
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * does not take address register as destination
        CMPI.B  #0,D5
        BNE     loadRaw
        * checking for size
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        * comparing size
        CMPI.B   #0,D4
        BEQ     checkSubib
        CMPI.B   #1,D4
        BEQ     checkSubiw
        CMPI.B   #2,D4
        BEQ     checkSubil
        BRA     loadRaw

checkSubib
        * Print has valid branching for subib
        LEA     MSUBIB,A4
        LSL.W   #4,D6
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkSubiw
        * Print has valid branching for subiw
        LEA     MSUBIW,A4
        LSL.W   #4,D6
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkSubil
        * Print has valid branching for subil
        LEA     MSUBIL,A4
        LSL.W   #4,D6
        OR.B    #10,D6
        LSL.W   #4,D6
        BRA     print

checkAddi
        MOVE.W  (A2),D4
        MOVE.L  #0,D6
        *cleared d6 and set d4
        LSR.W   #8,D4
        AND.B   #%1111,D4
        CMPI.B  #%0110,D4
        BNE     loadRaw
        MOVE.W  (A2),D4
        * isolating last 6 bits
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * does not take address register as destination
        CMPI.B  #0,D5
        BNE     loadRaw
        *making sure it isnt AN
        MOVE.W D6,D4
        LSR.W #4,D4
        AND.B   #%1111,D4
        CMPI.B  #2,D4
        BEQ loadRaw
        * checking for size
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        * comparing size
        CMPI.B   #0,D4
        BEQ     checkAddib
        CMPI.B   #1,D4
        BEQ     checkAddiw
        CMPI.B   #2,D4
        BEQ     checkAddil
        BRA     loadRaw

checkAddib
        * Print has valid branching for addib
        LEA     MADDIB,A4
        LSL.W   #4,D6
        OR.B    #8,D6
        LSL.W   #4,D6
        BRA     print

checkAddiw
        * Print has valid branching for addiw
        LEA     MADDIW,A4
        LSL.W   #4,D6
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkAddil
        * Print has valid branching for addil
        LEA     MADDIL,A4
        LSL.W   #4,D6
        OR.B    #10,D6
        LSL.W   #4,D6
        BRA     print

checkMoveb
        * Reset D6 and check destination addressing
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        * Trim D4 to call subroutine
        LSR.W   #6,D4
        AND.B   #%111111,D4
        JSR     loadDstAddrCommon
        * If data or error, invalid move command
        CMPI.B  #0,D5
        BNE     loadRaw
        * Else ensure NOT addressing mode An which is also invalid move
        MOVE.B  D6,D5
        LSR.B   #4,D5
        CMPI.B  #2,D5
        BEQ     loadRaw
        * Valid destination addressing mode, continue
        MOVE.W  (A2),D4
        * Trim D4 to call subroutine
        AND.B   #%111111,D4
        * Shift D6 before calling
        LSL.W   #4,D6
        JSR     loadSrcAddrCommon
        * Ensure successful return
        CMPI.B  #2,D5
        BEQ     loadRaw
        LEA     MMOVEB,A4
        CMPI.B  #0,D5
        BEQ     print
        * Addressing mode is immediate data, fill in byte data addressing mode for D6
        OR.B    #8,D6
        LSL.W   #4,D6
        BRA     print

checkMovew
        * Reset D6 and check destination addressing
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        * Trim D4 to call subroutine
        LSR.W   #6,D4
        AND.B   #%111111,D4
        JSR     loadDstAddrCommon
        * If data or error, invalid move command
        CMPI.B  #0,D5
        BNE     loadRaw
        * Else ensure NOT addressing mode An which is also invalid move
        MOVE.B  D6,D5
        AND.B   #%00001100,D5
        CMPI.B  #$20,D5
        BEQ     loadRaw
        * Valid destination addressing mode, continue
        MOVE.W  (A2),D4
        * Trim D4 to call subroutine
        AND.B   #%111111,D4
        * Shift D6 before calling
        LSL.W   #4,D6
        JSR     loadSrcAddrCommon
        * Ensure successful return
        CMPI.B  #2,D5
        BEQ     loadRaw
        LEA     MMOVEW,A4
        CMPI.B  #0,D5
        BEQ     print
        * Addressing mode is immediate data, fill in word data addressing mode for D6
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkMovel
        * Reset D6 and check destination addressing
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        * Trim D4 to call subroutine
        LSR.W   #6,D4
        AND.B   #%111111,D4
        JSR     loadDstAddrCommon
        * If data or error, invalid move command
        CMPI.B  #0,D5
        BNE     loadRaw
        * Else ensure NOT addressing mode An which is also invalid move
        MOVE.B  D6,D5
        AND.B   #%00001100,D5
        CMPI.B  #$20,D5
        BEQ     loadRaw
        * Valid destination addressing mode, continue
        MOVE.W  (A2),D4
        * Trim D4 to call subroutine
        AND.B   #%111111,D4
        * Shift D6 before calling
        LSL.W   #4,D6
        JSR     loadSrcAddrCommon
        * Ensure successful return
        CMPI.B  #2,D5
        BEQ     loadRaw
        LEA     MMOVEL,A4
        CMPI.B  #0,D5
        BEQ     print
        * Addressing mode is immediate data, fill in long data addressing mode for D6
        OR.B    #10,D6
        LSL.W   #4,D6
        BRA     print

checkMoveaw
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        *trim d4 to find if 001
        LSR.W   #6,D4
        AND.B   #%111,D4
        CMPI.B  #%001,D4
        BNE loadRaw
        *load An addressing mode for destination
        OR.B    #2,D6
        LSL.W   #4,D6
        *subroutine for destination
        MOVE.W (A2),D4
        LSR.W   #4,D4
        LSR.W   #5,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        LSL.W   #4,D6
         *call subroutine for source
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #2,D5
        BEQ     loadRaw
        LEA     MMOVEAW,A4
        CMPI.B  #0,D5
        BEQ     print
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkMoveal
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        *trim d4 to find if 001
        LSR.W   #6,D4
        AND.B   #%111,D4
        CMPI.B  #%001,D4
        BNE loadRaw
        *load An addressing mode for destination
        OR.B    #2,D6
        LSL.W   #4,D6
        *subroutine for destination
        MOVE.W (A2),D4
        LSR.W   #4,D4
        LSR.W   #5,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        LSL.W   #4,D6
         *call subroutine for source
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #2,D5
        BEQ     loadRaw
        LEA     MMOVEAL,A4
        CMPI.B  #0,D5
        BEQ     print
        OR.B    #10,D6
        LSL.W   #4,D6
        BRA     print

checkClr
        MOVE.W  (A2),D4
        MOVE.L  #0,D6
        *cleared d6 and set d4
        LSR.W   #8,D4
        AND.B   #%1111,D4
        CMPI.B  #%0010,D4
        BNE     loadRaw
        MOVE.W  (A2),D4
        * isolating last 6 bits
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * does not take address register as destination
        CMPI.B  #0,D5
        BNE     loadRaw
        MOVE.W D6,D4
        LSR.W #4,D4
        AND.B   #%1111,D4
        CMPI.B  #2,D4
        BEQ loadRaw
        * checking for size
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        * comparing size
        CMPI.B   #0,D4
        BEQ     checkClrb
        CMPI.B   #1,D4
        BEQ     checkClrw
        CMPI.B   #2,D4
        BEQ     checkClrl
        BRA     loadRaw

checkClrb
        * Print has valid branching for clrb
        LEA     MCLRB,A4
        BRA     print

checkClrw
        * Print has valid branching for clrb
        LEA     MCLRW,A4
        BRA     print

checkClrl
        * Print has valid branching for clrb
        LEA     MCLRL,A4
        BRA     print

checkMuluw
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        *trim d4 to find if 001
        LSR.W   #6,D4
        AND.B   #%111,D4
        CMPI.B  #%011,D4
        BNE loadRaw
        *load Dn addressing mode for destination
        OR.B    #1,D6
        LSL.W   #4,D6
        *subroutine for destination
        MOVE.W (A2),D4
        LSR.W   #4,D4
        LSR.W   #5,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        LSL.W   #4,D6
         *call subroutine for source
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #2,D5
        BEQ     loadRaw
        CMPI.B  #1,D5
        BEQ     specialDataMULUW
        *make sure AN is invalid
        MOVE.W D6,D4
        LSR.W #4,D4
        AND.B   #%1111,D4
        CMPI.B  #%0010,D4
        BEQ loadRaw
        LEA     MMULUW,A4
        CMPI.B  #0,D5
        BEQ     print
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

specialDataMULUW
        OR.B    #9,D6
        LSL.W   #4,D6
        LEA     MMULUW,A4
        BRA     print

checkMulsw
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        *trim d4 to find if 111
        LSR.W   #6,D4
        AND.B   #%111,D4
        CMPI.B  #%111,D4
        BNE loadRaw
        *load Dn addressing mode for destination
        OR.B    #1,D6
        LSL.W   #4,D6
        *subroutine for destination
        MOVE.W (A2),D4
        LSR.W   #4,D4
        LSR.W   #5,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        LSL.W   #4,D6
         *call subroutine for source
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #2,D5
        BEQ     loadRaw
        CMPI.B  #1,D5
        BEQ     specialDataMULSW
        *make sure AN is invalid
        MOVE.W D6,D4
        LSR.W #4,D4
        AND.B   #%1111,D4
        CMPI.B  #%0010,D4
        BEQ loadRaw
        LEA     MMULSW,A4
        CMPI.B  #0,D5
        BEQ     print
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

specialDataMULSW
        OR.B    #9,D6
        LSL.W   #4,D6
        LEA     MMULSW,A4
        BRA     print

checkMovem
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check static bit 11
        LSR.W   #8,D3
        LSR.W   #3,D3
        AND.B   #%1,D3
        CMPI.B  #1,D3
        BNE     loadRaw
        * Check static bits 7-9
        MOVE.W  (A2),D3
        LSR.W   #7,D3
        AND.B   #%111,D3
        CMPI.B  #%001,D3
        BNE     loadRaw
        * Load effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BNE     loadRaw
        * Make sure not invalid addressing modes
        MOVE.B  D6,D3
        LSR.B   #4,D3
        AND.B   #%1111,D3
        * Can't be Dn or An or N/A
        CMPI.B  #3,D3
        BLT     loadRaw
        * Can only be (An)+ under certain circumstances
        CMPI.B  #4,D3
        BEQ     checkMovemDir1
        * Can't be -(An) under certain circumstances
        CMPI.B  #5,D3
        BEQ     checkMovemDir2
        BRA     checkMovemCont

checkMovemDir1
        * Check for valid direction in the case of (An)+
        MOVE.W  (A2),D3
        * Isolate direction bit
        LSR.W   #5,D3
        LSR.B   #5,D3
        AND.B   #%1,D3
        * Only valid for dr=1
        CMPI.B  #1,D3
        BNE     loadRaw
        BRA     checkMovemCont

checkMovemDir2
        * Check for valid direction in the case of -(An)
        MOVE.W  (A2),D3
        * Isolate direction bit
        LSR.W   #5,D3
        LSR.B   #5,D3
        AND.B   #%1,D3
        * Only valid for dr=0
        CMPI.B  #0,D3
        BNE     loadRaw
        BRA     checkMovemCont

checkMovemCont
        * Check size
        MOVE.W  (A2),D3
        LSR.B   #6,D3
        AND.B   #%1,D3
        CMPI.B  #0,D3
        BEQ     checkMovemw
        BRA     checkMoveml

checkMovemw
        LEA     MMOVEMW,A4
        BRA     print

checkMoveml
        LEA     MMOVEML,A4
        BRA     print

checkJsr
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        *trim d4 to find if 111010
        LSR.W   #6,D4
        AND.B   #%111111,D4
        CMPI.B  #%111010,D4
        BNE loadRaw
         *call subroutine for source
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BNE     loadRaw
         *make sure it isn't an invalid addressing mode
        MOVE.W D6,D4
        LSR.W #4,D4
        AND.B   #%1111,D4
        CMPI.B  #1,D4
        BEQ loadRaw
        CMPI.B  #2,D4
        BEQ loadRaw
        CMPI.B  #4,D4
        BEQ loadRaw
        CMPI.B  #5,D4
        BEQ loadRaw
        LEA     MJSR,A4
        CMPI.B  #0,D5
        BEQ     print

checkNop
        * Only 1 valid NOP data
        CMPI.W  #$4E71,(A2)
        BNE     loadRaw
        * Valid NOP, Load message and set addressing
        MOVE.W  #0,D6
        LEA     MNOP,A4
        BRA     print

checkRts
        * Only 1 valid RTS data
        CMPI.W  #$4E75,(A2)
        BNE     loadRaw
        * Valid RTS, Load message and set addressing
        MOVE.W  #0,D6
        LEA     MRTS,A4
        BRA     print

checkLea
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check for static bits 6-8
        LSR.W   #6,D3
        AND.B   #%111,D3
        CMPI.B  #%111,D3
        BNE     loadRaw
        * Load destination Addressing mode
        OR.B    #2,D6
        LSL.W   #4,D6
        * Load destination Addressing register
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.B   #1,D3
        AND.B   #%111,D3
        OR.B    D3,D6
        LSL.W   #4,D6
        * Load source effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * Check for valid return (also can't be immediate data)
        CMPI.B  #0,D5
        BNE     loadRaw
        * Check for valid returned addressing mode
        MOVE.B  D6,D5
        LSR.B   #4,D5
        CMPI.B  #3,D5
        BLT     loadRaw
        * Can't be (An)+
        CMPI.B  #4,D5
        BEQ     loadRaw
        * Can't be -(An)
        CMPI.B  #5,D5
        BEQ     loadRaw
        LEA     MLEA,A4
        BRA     print

checkAddq
        MOVE.L  #0,D6
        * Check bit 8 (must be 0 to be valid opcode)
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        AND.B   #1,D3
        CMP.B   #0,D3
        BNE     loadRaw
        * Parse effective address for destination
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMP.B   #0,D5
        BNE     loadRaw
        LSL.W   #4,D6
        * Quick data addressing mode
        OR.B    #$B,D6
        LSL.W   #4,D6
        * Load quick data into D6 register
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.B   #1,D3
        AND.B   #%111,D3
        * Must convert 0 to 8 if necessary
        CMPI.B  #0,D3
        BEQ     convertAddquick
        BRA     checkAddqCont

convertAddquick
        MOVE.B  #8,D3
        BRA     checkAddqCont

checkAddqCont
        OR.B    D3,D6
        * Check for size of opcode
        MOVE.W  (A2),D3
        LSR.B   #6,D3
        CMP.B   #0,D3
        BEQ     checkAddqb
        CMP.B   #1,D3
        BEQ     checkAddqw
        CMP.B   #2,D3
        BEQ     checkAddql
        BRA     loadRaw

checkAddqb
        * Print has valid branching for addqb
        LEA     MADDQB,A4
        BRA     print

checkAddqw
        * Print has valid branching for addqb
        LEA     MADDQW,A4
        BRA     print

checkAddql
        * Print has valid branching for addqb
        LEA     MADDQL,A4
        BRA     print

checkMoveq
        MOVE.L  #0,D6
        * Check bit 8 (must be 0 to be valid opcode)
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        AND.B   #1,D3
        CMP.B   #0,D3
        BNE     loadRaw
        * Load Dn destination addressing mode
        OR.B    #1,D6
        LSL.W   #4,D6
        * Parse destination register
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.B   #1,D3
        AND.B   #%111,D3
        OR.B    D3,D6
        LSL.W   #4,D6
        * Use immediate byte data addressing mode and shift pointer
        * This tricks the printer to print the byte in the end of the opcode correctly
        OR.B    #$8,D6
        LSL.W   #4,D6
        SUBA.L  #2,A2
        LEA     MMOVEQ,A4
        BRA     print

checkSub
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check opmode for branching
        LSR.W   #6,D3
        AND.B   #%111,D3
        CMPI.B  #%000,D3
        BEQ     checkSub1b
        CMPI.B  #%001,D3
        BEQ     checkSub1w
        CMPI.B  #%010,D3
        BEQ     checkSub1l
        CMPI.B  #%100,D3
        BEQ     checkSub2b
        CMPI.B  #%101,D3
        BEQ     checkSub2w
        CMPI.B  #%110,D3
        BEQ     checkSub2l
        BRA     loadRaw

checkSub1b
        LEA     MSUBB,A4
        BRA     checkMath1bCommon

checkSub1w
        LEA     MSUBW,A4
        BRA     checkMath1wCommon

checkSub1l
        LEA     MSUBL,A4
        BRA     checkMath1lCommon

checkSub2b
        LEA     MSUBB,A4
        BRA     checkMath2Common

checkSub2w
        LEA     MSUBW,A4
        BRA     checkMath2Common

checkSub2l
        LEA     MSUBL,A4
        BRA     checkMath2Common

checkDivuw
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        *trim d4 to find if 001
        LSR.W   #6,D4
        AND.B   #%111,D4
        CMPI.B  #%011,D4
        BNE loadRaw
        *load Dn addressing mode for destination
        OR.B    #1,D6
        LSL.W   #4,D6
        *subroutine for destination
        MOVE.W (A2),D4
        LSR.W   #4,D4
        LSR.W   #5,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        LSL.W   #4,D6
         *call subroutine for source
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #2,D5
        BEQ     loadRaw
        CMPI.B  #1,D5
        BEQ     specialDataDIVUW
        *make sure AN is invalid
        MOVE.W D6,D4
        LSR.W #4,D4
        AND.B   #%1111,D4
        CMPI.B  #%0010,D4
        BEQ loadRaw
        LEA     MDIVUW,A4
        CMPI.B  #0,D5
        BEQ     print
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

specialDataDIVUW
        OR.B    #9,D6
        LSL.W   #4,D6
        LEA     MDIVUW,A4
        BRA     print

checkOr
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check opmode for branching
        LSR.W   #6,D3
        AND.B   #%111,D3
        CMPI.B  #%000,D3
        BEQ     checkOr1b
        CMPI.B  #%001,D3
        BEQ     checkOr1w
        CMPI.B  #%010,D3
        BEQ     checkOr1l
        CMPI.B  #%100,D3
        BEQ     checkOr2b
        CMPI.B  #%101,D3
        BEQ     checkOr2w
        CMPI.B  #%110,D3
        BEQ     checkOr2l
        BRA     loadRaw

checkOr1b
        LEA     MORB,A4
        BRA     checkMath1bCommon

checkOr1w
        LEA     MORW,A4
        BRA     checkMath1wCommon

checkOr1l
        LEA     MORL,A4
        BRA     checkMath1lCommon

checkOr2b
        LEA     MORB,A4
        BRA     checkMath2Common

checkOr2w
        LEA     MORW,A4
        BRA     checkMath2Common

checkOr2l
        LEA     MORL,A4
        BRA     checkMath2Common

checkCmp
        * Load instruction to D3 to evaluate
        MOVE.W  (A2),D3
        * Load Dn addressing mode (must be D register for Cmp)
        MOVE.W  #$0001,D6
        LSL.W   #4,D6
        * Load destination register
        MOVE.W  D3,D4
        LSL.W   #4,D4
        LSR.W   #8,D4
        LSR.W   #5,D4
        OR.B    D4,D6
        LSL.W   #4,D6
        * Check for valid opmode (size)
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #8,D4
        LSR.W   #5,D4
        CMPI.W  #%000,D4
        BEQ     checkCmpb
        CMPI.W  #%001,D4
        BEQ     checkCmpw
        CMPI.W  #%010,D4
        BEQ     checkCmpl
        BRA     loadRaw

checkCmpb
        LEA     MCMPB,A4
        JSR     checkCmpCommon
        CMPI.B  #2,D5
        BEQ     loadRaw
        CMPI.B  #0,D5
        BEQ     print
        OR.B    #8,D6
        LSL.W   #4,D6
        BRA     print

checkCmpw
        LEA     MCMPW,A4
        JSR     checkCmpCommon
        CMPI.B  #2,D5
        BEQ     loadRaw
        CMPI.B  #0,D5
        BEQ     print
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkCmpl
        LEA     MCMPL,A4
        JSR     checkCmpCommon
        CMPI.B  #2,D5
        BEQ     loadRaw
        CMPI.B  #0,D5
        BEQ     print
        OR.B    #10,D6
        LSL.W   #4,D6
        BRA     print

checkCmpCommon
        MOVE.W  D3,D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        RTS

checkAnd
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check opmode for branching
        LSR.W   #6,D3
        AND.B   #%111,D3
        CMPI.B  #%000,D3
        BEQ     checkAnd1b
        CMPI.B  #%001,D3
        BEQ     checkAnd1w
        CMPI.B  #%010,D3
        BEQ     checkAnd1l
        CMPI.B  #%100,D3
        BEQ     checkAnd2b
        CMPI.B  #%101,D3
        BEQ     checkAnd2w
        CMPI.B  #%110,D3
        BEQ     checkAnd2l
        BRA     loadRaw

checkAnd1b
        LEA     MANDB,A4
        BRA     checkMath1bCommon

checkAnd1w
        LEA     MANDW,A4
        BRA     checkMath1wCommon

checkAnd1l
        LEA     MANDL,A4
        BRA     checkMath1lCommon

checkAnd2b
        LEA     MANDB,A4
        BRA     checkMath2Common

checkAnd2w
        LEA     MANDW,A4
        BRA     checkMath2Common

checkAnd2l
        LEA     MANDL,A4
        BRA     checkMath2Common

checkAdda
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Load destination addressing mode
        OR.B    #2,D6
        LSL.W   #4,D6
        * Load destination addressing register
        LSR.W   #8,D3
        LSR.B   #1,D3
        AND.B   #%111,D3
        OR.B    D3,D6
        LSL.W   #4,D6
        * Check for valid opmode (size)
        MOVE.W  (A2),D3
        LSR.W   #6,D3
        AND.B   #%111,D3
        CMPI.B  #%011,D3
        BEQ     checkAddaw
        CMPI.B  #%111,D3
        BEQ     checkAddal
        BRA     loadRaw

checkAddaw
        LEA     MADDAW,A4
        * Load source effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BEQ     print
        CMPI.B  #1,D5
        BNE     loadRaw
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkAddal
        LEA     MADDAL,A4
        * Load source effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BEQ     print
        CMPI.B  #1,D5
        BNE     loadRaw
        OR.B    #10,D6
        LSL.W   #4,D6
        BRA     print

checkSuba
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Load destination addressing mode
        OR.B    #2,D6
        LSL.W   #4,D6
        * Load destination addressing register
        LSR.W   #8,D3
        LSR.B   #1,D3
        AND.B   #%111,D3
        OR.B    D3,D6
        LSL.W   #4,D6
        * Check for valid opmode (size)
        MOVE.W  (A2),D3
        LSR.W   #6,D3
        AND.B   #%111,D3
        CMPI.B  #%011,D3
        BEQ     checkSubaw
        CMPI.B  #%111,D3
        BEQ     checkSubal
        BRA     loadRaw

checkSubaw
        LEA     MSUBAW,A4
        * Load source effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BEQ     print
        CMPI.B  #1,D5
        BNE     loadRaw
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkSubal
        LEA     MSUBAL,A4
        * Load source effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BEQ     print
        CMPI.B  #1,D5
        BNE     loadRaw
        OR.B    #10,D6
        LSL.W   #4,D6
        BRA     print

checkAdd
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check opmode for branching
        LSR.W   #6,D3
        AND.B   #%111,D3
        CMPI.B  #%000,D3
        BEQ     checkAdd1b
        CMPI.B  #%001,D3
        BEQ     checkAdd1w
        CMPI.B  #%010,D3
        BEQ     checkAdd1l
        CMPI.B  #%100,D3
        BEQ     checkAdd2b
        CMPI.B  #%101,D3
        BEQ     checkAdd2w
        CMPI.B  #%110,D3
        BEQ     checkAdd2l
        BRA     loadRaw

checkAdd1b
        LEA     MADDB,A4
        BRA     checkMath1bCommon

checkAdd1w
        LEA     MADDW,A4
        BRA     checkMath1wCommon

checkAdd1l
        LEA     MADDL,A4
        BRA     checkMath1lCommon

checkAdd2b
        LEA     MADDB,A4
        BRA     checkMath2Common

checkAdd2w
        LEA     MADDW,A4
        BRA     checkMath2Common

checkAdd2l
        LEA     MADDL,A4
        BRA     checkMath2Common

checkBcc
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check for correct condition
        LSR.W   #8,D3
        AND.B   #%1111,D3
        CMPI.B  #%0100,D3
        BNE     loadRaw
        LEA     MBCC,A4
        BRA     checkBranchCommon

checkBgt
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check for correct condition
        LSR.W   #8,D3
        AND.B   #%1111,D3
        CMPI.B  #%1110,D3
        BNE     loadRaw
        LEA     MBGT,A4
        BRA     checkBranchCommon

checkBle
        MOVE.L  #0,D6
        MOVE.W  (A2),D3
        * Check for correct condition
        LSR.W   #8,D3
        AND.B   #%1111,D3
        CMPI.B  #%1111,D3
        BNE     loadRaw
        LEA     MBLE,A4
        BRA     checkBranchCommon

checkBranchCommon
        * Check for 16/32 bit displacement
        MOVE.W  (A2),D3
        CMPI.B  #0,D3
        BEQ     checkBranchw
        CMPI.B  #$FF,D3
        BEQ     checkBranchl
        * Load 8 bit displacement into D6 with relevant addressing mode
        OR.B    D3,D6
        LSL.W   #8,D6
        OR.B    #$C0,D6
        BRA     print

checkBranchw
        * Load relevant addressing mode
        OR.B    #$60,D6
        BRA     print

checkBranchl
        * Load relevant addressing mode
        OR.B    #$70,D6
        BRA     print

checkLslreg
        * Reset D6 and check for correct direction
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        AND.B   #%1,D4
        CMPI.B  #1,D4
        BNE     loadRaw
        * Check static bits 3 and 4
        MOVE.W  (A2),D4
        LSR.B   #3,D4
        AND.B   #%11,D4
        CMPI.B  #%01,D4
        BNE     loadRaw
        * Load destination register
        MOVE.W  (A2),D4
        ANDI.W  #%111,D4
        OR.B    #1,D6
        LSL.W   #4,D6
        OR.B    D4,D6
        LSL.W   #4,D6
        * Check if immediate data or register shift
        MOVE.W  (A2),D4
        LSR.B   #5,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BEQ     checkLslImmediate
        BRA     checkLslregister

checkLslImmediate
        * Load immediate quick data and addressing mode
        OR.B    #$B,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        * Check if quick data is 0 (to convert to #8)
        CMPI.B  #0,D4
        BEQ     convertLslquick
        BRA     checkLslImmCont

convertLslquick
        MOVE.B  #8,D4
        BRA     checkLslImmCont

checkLslImmCont
        OR.B    D4,D6
        BRA     checkLslSize

checkLslregister
        * Load (source) data register addressing mode and register number
        OR.B    #1,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        BRA     checkLslSize

checkLslSize
        * Check the size of the LSL command
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        AND.B   #%11,D4
        CMPI.B  #0,D4
        BEQ     checkLslb
        CMPI.B  #1,D4
        BEQ     checkLslw
        CMPI.B  #2,D4
        BEQ     checkLsll
        BRA     loadRaw

checkLslb
        LEA     MLSLB,A4
        BRA     print

checkLslw
        LEA     MLSLW,A4
        BRA     print

checkLsll
        LEA     MLSLL,A4
        BRA     print

checkLslmem
        MOVE.L  #0,D6
        * Check for the validity of all static bits
        MOVE.W  (A2),D4
        LSR.W   #6,D4
        AND.B   #%111111,D4
        CMPI.B  #%001111,D4
        BNE     loadRaw
        * Load effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * Check for valid parse (can't be immediate data either)
        CMPI.B  #0,D5
        BNE     loadRaw
        * Verify addressing mode isn't Dn or An which are both invalid
        CMPI.W  #$30,D6
        BLT     loadRaw
        LEA     MLSL,A4
        BRA     print

checkLsrreg
        * Reset D6 and check for correct direction
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BNE     loadRaw
        * Check static bits 3 and 4
        MOVE.W  (A2),D4
        LSR.B   #3,D4
        AND.B   #%11,D4
        CMPI.B  #%01,D4
        BNE     loadRaw
        * Load destination register
        MOVE.W  (A2),D4
        ANDI.W  #%111,D4
        OR.B    #1,D6
        LSL.W   #4,D6
        OR.B    D4,D6
        LSL.W   #4,D6
        * Check if immediate data or register shift
        MOVE.W  (A2),D4
        LSR.B   #5,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BEQ     checkLsrImmediate
        BRA     checkLsrregister

checkLsrImmediate
        * Load immediate quick data and addressing mode
        OR.B    #$B,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        * Check if quick data is 0 (to convert to #8)
        CMPI.B  #0,D4
        BEQ     convertLsrquick
        BRA     checkLsrImmCont

convertLsrquick
        MOVE.B  #8,D4
        BRA     checkLsrImmCont

checkLsrImmCont
        OR.B    D4,D6
        BRA     checkLsrSize

checkLsrregister
        * Load (source) data register addressing mode and register number
        OR.B    #1,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        BRA     checkLsrSize

checkLsrSize
        * Check the size of the Lsr command
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        AND.B   #%11,D4
        CMPI.B  #0,D4
        BEQ     checkLsrb
        CMPI.B  #1,D4
        BEQ     checkLsrw
        CMPI.B  #2,D4
        BEQ     checkLsrl
        BRA     loadRaw

checkLsrb
        LEA     MLSRB,A4
        BRA     print

checkLsrw
        LEA     MLSRW,A4
        BRA     print

checkLsrl
        LEA     MLSRL,A4
        BRA     print

checkLsrmem
        MOVE.L  #0,D6
        * Check for the validity of all static bits
        MOVE.W  (A2),D4
        LSR.W   #6,D4
        AND.B   #%111111,D4
        CMPI.B  #%001011,D4
        BNE     loadRaw
        * Load effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * Check for valid parse (can't be immediate data either)
        CMPI.B  #0,D5
        BNE     loadRaw
        * Verify addressing mode isn't Dn or An which are both invalid
        CMPI.W  #$30,D6
        BLT     loadRaw
        LEA     MLSR,A4
        BRA     print

checkAslreg
        * Reset D6 and check for correct direction
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        AND.B   #%1,D4
        CMPI.B  #1,D4
        BNE     loadRaw
        * Check static bits 3 and 4
        MOVE.W  (A2),D4
        LSR.B   #3,D4
        AND.B   #%11,D4
        CMPI.B  #%00,D4
        BNE     loadRaw
        * Load destination register
        MOVE.W  (A2),D4
        ANDI.W  #%111,D4
        OR.B    #1,D6
        LSL.W   #4,D6
        OR.B    D4,D6
        LSL.W   #4,D6
        * Check if immediate data or register shift
        MOVE.W  (A2),D4
        LSR.B   #5,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BEQ     checkAslImmediate
        BRA     checkAslregister

checkAslImmediate
        * Load immediate quick data and addressing mode
        OR.B    #$B,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        * Check if quick data is 0 (to convert to #8)
        CMPI.B  #0,D4
        BEQ     convertAslquick
        BRA     checkAslImmCont

convertAslquick
        MOVE.B  #8,D4
        BRA     checkAslImmCont

checkAslImmCont
        OR.B    D4,D6
        BRA     checkAslSize

checkAslregister
        * Load (source) data register addressing mode and register number
        OR.B    #1,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        BRA     checkAslSize

checkAslSize
        * Check the size of the LSL command
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        AND.B   #%11,D4
        CMPI.B  #0,D4
        BEQ     checkAslb
        CMPI.B  #1,D4
        BEQ     checkAslw
        CMPI.B  #2,D4
        BEQ     checkAsll
        BRA     loadRaw

checkAslb
        LEA     MASLB,A4
        BRA     print

checkAslw
        LEA     MASLW,A4
        BRA     print

checkAsll
        LEA     MASLL,A4
        BRA     print

checkAslmem
        MOVE.L  #0,D6
        * Check for the validity of all static bits
        MOVE.W  (A2),D4
        LSR.W   #6,D4
        AND.B   #%111111,D4
        CMPI.B  #%000111,D4
        BNE     loadRaw
        * Load effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * Check for valid parse (can't be immediate data either)
        CMPI.B  #0,D5
        BNE     loadRaw
        * Verify addressing mode isn't Dn or An which are both invalid
        CMPI.W  #$30,D6
        BLT     loadRaw
        LEA     MASL,A4
        BRA     print

checkAsrreg
        * Reset D6 and check for correct direction
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BNE     loadRaw
        * Check static bits 3 and 4
        MOVE.W  (A2),D4
        LSR.B   #3,D4
        AND.B   #%11,D4
        CMPI.B  #%00,D4
        BNE     loadRaw
        * Load destination register
        MOVE.W  (A2),D4
        ANDI.W  #%111,D4
        OR.B    #1,D6
        LSL.W   #4,D6
        OR.B    D4,D6
        LSL.W   #4,D6
        * Check if immediate data or register shift
        MOVE.W  (A2),D4
        LSR.B   #5,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BEQ     checkAsrImmediate
        BRA     checkAsrregister

checkAsrImmediate
        * Load immediate quick data and addressing mode
        OR.B    #$B,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        * Check if quick data is 0 (to convert to #8)
        CMPI.B  #0,D4
        BEQ     convertAsrquick
        BRA     checkAsrImmCont

convertAsrquick
        MOVE.B  #8,D4
        BRA     checkAsrImmCont

checkAsrImmCont
        OR.B    D4,D6
        BRA     checkAsrSize

checkAsrregister
        * Load (source) data register addressing mode and register number
        OR.B    #1,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        BRA     checkAsrSize

checkAsrSize
        * Check the size of the LSL command
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        AND.B   #%11,D4
        CMPI.B  #0,D4
        BEQ     checkAsrb
        CMPI.B  #1,D4
        BEQ     checkAsrw
        CMPI.B  #2,D4
        BEQ     checkAsrl
        BRA     loadRaw

checkAsrb
        LEA     MASRB,A4
        BRA     print

checkAsrw
        LEA     MASRW,A4
        BRA     print

checkAsrl
        LEA     MASRL,A4
        BRA     print

checkAsrmem
        MOVE.L  #0,D6
        * Check for the validity of all static bits
        MOVE.W  (A2),D4
        LSR.W   #6,D4
        AND.B   #%111111,D4
        CMPI.B  #%000011,D4
        BNE     loadRaw
        * Load effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * Check for valid parse (can't be immediate data either)
        CMPI.B  #0,D5
        BNE     loadRaw
        * Verify addressing mode isn't Dn or An which are both invalid
        CMPI.W  #$30,D6
        BLT     loadRaw
        LEA     MASR,A4
        BRA     print

checkRolreg
        * Reset D6 and check for correct direction
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        AND.B   #%1,D4
        CMPI.B  #1,D4
        BNE     loadRaw
        * Check static bits 3 and 4
        MOVE.W  (A2),D4
        LSR.B   #3,D4
        AND.B   #%11,D4
        CMPI.B  #%11,D4
        BNE     loadRaw
        * Load destination register
        MOVE.W  (A2),D4
        ANDI.W  #%111,D4
        OR.B    #1,D6
        LSL.W   #4,D6
        OR.B    D4,D6
        LSL.W   #4,D6
        * Check if immediate data or register shift
        MOVE.W  (A2),D4
        LSR.B   #5,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BEQ     checkRolImmediate
        BRA     checkRolregister

checkRolImmediate
        * Load immediate quick data and addressing mode
        OR.B    #$B,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        * Check if quick data is 0 (to convert to #8)
        CMPI.B  #0,D4
        BEQ     convertRolquick
        BRA     checkRolImmCont

convertRolquick
        MOVE.B  #8,D4
        BRA     checkRolImmCont

checkRolImmCont
        OR.B    D4,D6
        BRA     checkRolSize

checkRolregister
        * Load (source) data register addressing mode and register number
        OR.B    #1,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        BRA     checkRolSize

checkRolSize
        * Check the size of the Rol command
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        AND.B   #%11,D4
        CMPI.B  #0,D4
        BEQ     checkRolb
        CMPI.B  #1,D4
        BEQ     checkRolw
        CMPI.B  #2,D4
        BEQ     checkRoll
        BRA     loadRaw

checkRolb
        LEA     MROLB,A4
        BRA     print

checkRolw
        LEA     MROLW,A4
        BRA     print

checkRoll
        LEA     MROLL,A4
        BRA     print

checkRolmem
        MOVE.L  #0,D6
        * Check for the validity of all static bits
        MOVE.W  (A2),D4
        LSR.W   #6,D4
        AND.B   #%111111,D4
        CMPI.B  #%011111,D4
        BNE     loadRaw
        * Load effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * Check for valid parse (can't be immediate data either)
        CMPI.B  #0,D5
        BNE     loadRaw
        * Verify addressing mode isn't Dn or An which are both invalid
        CMPI.W  #$30,D6
        BLT     loadRaw
        LEA     MROL,A4
        BRA     print

checkRorreg
        * Reset D6 and check for correct direction
        MOVE.L  #0,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BNE     loadRaw
        * Check static bits 3 and 4
        MOVE.W  (A2),D4
        LSR.B   #3,D4
        AND.B   #%11,D4
        CMPI.B  #%11,D4
        BNE     loadRaw
        * Load destination register
        MOVE.W  (A2),D4
        ANDI.W  #%111,D4
        OR.B    #1,D6
        LSL.W   #4,D6
        OR.B    D4,D6
        LSL.W   #4,D6
        * Check if immediate data or register shift
        MOVE.W  (A2),D4
        LSR.B   #5,D4
        AND.B   #%1,D4
        CMPI.B  #0,D4
        BEQ     checkRorImmediate
        BRA     checkRorregister

checkRorImmediate
        * Load immediate quick data and addressing mode
        OR.B    #$B,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        * Check if quick data is 0 (to convert to #8)
        CMPI.B  #0,D4
        BEQ     convertRorquick
        BRA     checkRorImmCont

convertRorquick
        MOVE.B  #8,D4
        BRA     checkRorImmCont

checkRorImmCont
        OR.B    D4,D6
        BRA     checkRorSize

checkRorregister
        * Load (source) data register addressing mode and register number
        OR.B    #1,D6
        LSL.W   #4,D6
        MOVE.W  (A2),D4
        LSR.W   #8,D4
        LSR.B   #1,D4
        AND.B   #%111,D4
        OR.B    D4,D6
        BRA     checkRorSize

checkRorSize
        * Check the size of the Ror command
        MOVE.W  (A2),D4
        LSR.B   #6,D4
        AND.B   #%11,D4
        CMPI.B  #0,D4
        BEQ     checkRorb
        CMPI.B  #1,D4
        BEQ     checkRorw
        CMPI.B  #2,D4
        BEQ     checkRorl
        BRA     loadRaw

checkRorb
        LEA     MRORB,A4
        BRA     print

checkRorw
        LEA     MRORW,A4
        BRA     print

checkRorl
        LEA     MRORL,A4
        BRA     print

checkRormem
        MOVE.L  #0,D6
        * Check for the validity of all static bits
        MOVE.W  (A2),D4
        LSR.W   #6,D4
        AND.B   #%111111,D4
        CMPI.B  #%011011,D4
        BNE     loadRaw
        * Load effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * Check for valid parse (can't be immediate data either)
        CMPI.B  #0,D5
        BNE     loadRaw
        * Verify addressing mode isn't Dn or An which are both invalid
        CMPI.W  #$30,D6
        BLT     loadRaw
        LEA     MROR,A4
        BRA     print

checkMath1bCommon
        * Load destination Addressing mode
        OR.B    #1,D6
        LSL.W   #4,D6
        * Load destination Register
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.W   #1,D3
        AND.B   #%111,D3
        OR.B    D3,D6
        LSL.W   #4,D6
        * Load source effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BEQ     print
        CMPI.B  #1,D5
        BNE     loadRaw
        * Load relevant addressing mode for immediate data
        OR.B    #8,D6
        LSL.W   #4,D6
        BRA     print

checkMath1wCommon
        * Load destination Addressing mode
        OR.B    #1,D6
        LSL.W   #4,D6
        * Load destination Register
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.W   #1,D3
        AND.B   #%111,D3
        OR.B    D3,D6
        LSL.W   #4,D6
        * Load source effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BEQ     print
        CMPI.B  #1,D5
        BNE     loadRaw
        * Load relevant addressing mode for immediate data
        OR.B    #9,D6
        LSL.W   #4,D6
        BRA     print

checkMath1lCommon
        * Load destination Addressing mode
        OR.B    #1,D6
        LSL.W   #4,D6
        * Load destination Register
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.W   #1,D3
        AND.B   #%111,D3
        OR.B    D3,D6
        LSL.W   #4,D6
        * Load source effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        CMPI.B  #0,D5
        BEQ     print
        CMPI.B  #1,D5
        BNE     loadRaw
        * Load relevant addressing mode for immediate data
        OR.B    #10,D6
        LSL.W   #4,D6
        BRA     print

checkMath2Common
        * Load destination effective address
        MOVE.W  (A2),D4
        AND.B   #%111111,D4
        JSR     loadSrcAddrCommon
        * Check for valid return (also can't be immediate data)
        CMPI.B  #0,D5
        BNE     loadRaw
        MOVE.B  D6,D5
        LSR.B   #4,D5
        CMPI.B  #$3,D5
        BLT     loadRaw
        * Load source addressing mode
        LSL.W   #4,D6
        OR.B    #1,D6
        LSL.W   #4,D6
        * Load source register
        MOVE.W  (A2),D3
        LSR.W   #8,D3
        LSR.B   #1,D3
        AND.B   #%111,D3
        OR.B    D3,D6
        BRA     print

* Loads the source effective addressing mode from trimmed D4 into D6 against
* the common addressing mode table (with no restrictions)
* Sets D5 to 2 if failed, 1 if register mode data, or 0 if normal success
loadSrcAddrCommon
        MOVEM.L D0-D4,-(SP)
        MOVE.B  D4,D1
        LSL.B   #2,D1
        LSR.B   #5,D1
        CMPI.B  #0,D1
        BEQ     loadSrcDn
        CMPI.B  #1,D1
        BEQ     loadSrcAn
        CMPI.B  #2,D1
        BEQ     loadSrcAtAn
        CMPI.B  #3,D1
        BEQ     loadSrcPlusAn
        CMPI.B  #4,D1
        BEQ     loadSrcMinusAn
        CMPI.B  #7,D1
        BEQ     loadSrcCont
        BRA     loadSrcFail

loadSrcFail
        MOVE.L  #2,D5
        MOVEM.L (SP)+,D0-D4
        RTS

loadSrcCont
        MOVE.B  D4,D1
        AND.B   #%00000111,D1
        CMPI.B  #0,D1
        BEQ     loadSrcAddrw
        CMPI.B  #1,D1
        BEQ     loadSrcAddrl
        CMPI.B  #4,D1
        BEQ     loadSrcData
        BRA     loadSrcFail

loadSrcDn
        OR.B    #1,D6
        LSL.W   #4,D6
        BRA     loadSrcRegister

loadSrcAn
        OR.B    #2,D6
        LSL.W   #4,D6
        BRA     loadSrcRegister

loadSrcAtAn
        OR.B    #3,D6
        LSL.W   #4,D6
        BRA     loadSrcRegister

loadSrcPlusAn
        OR.B    #4,D6
        LSL.W   #4,D6
        BRA     loadSrcRegister

loadSrcMinusAn
        OR.B    #5,D6
        LSL.W   #4,D6
        BRA     loadSrcRegister

loadSrcRegister
        MOVE.B  D4,D1
        AND.B   #%00000111,D1
        OR.B    D1,D6
        BRA     loadSrcFinish

loadSrcAddrw
        OR.B    #6,D6
        LSL.W   #4,D6
        BRA     loadSrcFinish

loadSrcAddrl
        OR.B    #7,D6
        LSL.W   #4,D6
        BRA     loadSrcFinish

loadSrcData
        MOVE.L  #1,D5
        MOVEM.L (SP)+,D0-D4
        RTS

loadSrcFinish
        MOVE.L  #0,D5
        MOVEM.L (SP)+,D0-D4
        RTS


* Loads the destination effective addressing mode from trimmed D4 into D6 against
* the common addressing mode table (with no restrictions)
* Sets D5 to 2 if failed, 1 if register mode data, or 0 if normal success
loadDstAddrCommon
        MOVEM.L D0-D4,-(SP)
        MOVE.B  D4,D1
        AND.B   #%00000111,D1
        CMPI.B  #0,D1
        BEQ     loadDstDn
        CMPI.B  #1,D1
        BEQ     loadDstAn
        CMPI.B  #2,D1
        BEQ     loadDstAtAn
        CMPI.B  #3,D1
        BEQ     loadDstPlusAn
        CMPI.B  #4,D1
        BEQ     loadDstMinusAn
        CMPI.B  #7,D1
        BEQ     loadDstCont
        BRA     loadDstFail

loadDstFail
        MOVE.L  #2,D5
        MOVEM.L (SP)+,D0-D4
        RTS

loadDstCont
        MOVE.B  D4,D1
        LSL.B   #2,D1
        LSR.B   #5,D1
        CMPI.B  #0,D1
        BEQ     loadDstAddrw
        CMPI.B  #1,D1
        BEQ     loadDstAddrl
        CMPI.B  #4,D1
        BEQ     loadDstData
        BRA     loadDstFail

loadDstDn
        OR.B    #1,D6
        LSL.W   #4,D6
        BRA     loadDstRegister

loadDstAn
        OR.B    #2,D6
        LSL.W   #4,D6
        BRA     loadDstRegister

loadDstAtAn
        OR.B    #3,D6
        LSL.W   #4,D6
        BRA     loadDstRegister

loadDstPlusAn
        OR.B    #4,D6
        LSL.W   #4,D6
        BRA     loadDstRegister

loadDstMinusAn
        OR.B    #5,D6
        LSL.W   #4,D6
        BRA     loadDstRegister

loadDstRegister
        MOVE.B  D4,D1
        LSL.B   #2,D1
        LSR.B   #5,D1
        OR.B    D1,D6
        BRA     loadDstFinish

loadDstAddrw
        OR.B    #6,D6
        LSL.W   #4,D6
        BRA     loadDstFinish

loadDstAddrl
        OR.B    #7,D6
        LSL.W   #4,D6
        BRA     loadDstFinish

loadDstData
        MOVE.L  #1,D5
        MOVEM.L (SP)+,D0-D4
        RTS

loadDstFinish
        MOVE.L  #0,D5
        MOVEM.L (SP)+,D0-D4
        RTS

final
        * Display final message, then end the program
        LEA     SPACE,A1
        MOVE.B  #13,D0
        TRAP    #15
        LEA     BYEM,A1
        TRAP    #15

        * Halt sim and end
        MOVE.B  #9,D0
        TRAP    #15
        END     $600


*~Font name~Courier~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
