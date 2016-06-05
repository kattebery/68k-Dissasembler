*-----------------------------------------------------------
* Title      : Op_jumpTable
* Written by : Kristen Attebery
* Date       : 6/4/16
* Description: OP code decoder for 68k disassembler
*              Team.cpp CSS 422 Spring 2016
*-----------------------------------------------------------
VERIFY_OPCODE

    *MOVE.L A2, A6 ->2C4A ??  0010 1100 0100 1010 
    
    *SHOULD BE                0010 110 001 001 010



    MOVE.W  D0,D1   *Copy instruction for modification
    
    **ISOLATE BITS F-C**                                             
    LSR.W   #4,D1       *Shift right four bits
    LSR.W   #8,D1       *Shift right again (12 shifts total)
    
    CLR     D2
    MOVE.B  D1,D2       *Copy bits to jump table instruction register(D2)
    
    LEA     OP_JTAB,A0  *Load the jump table 
    MULS    #6, D2      *Get the offset
    JSR     0(A0,D2)    *Go to jump table address


**************************************************************************
*              OP_JTAB. Determine OP code.                               *
*        Analyzes the first four bits within the instruction             *
*        and jumps to the corresponding subroutine.                      *
**************************************************************************

OP_JTAB     JMP     OP0000       *ADDI
            JMP     OP0001              *MOVE.B
            JMP     OP0010              *MOVE.L, MOVEA(LONG)
            JMP     OP0011              *MOVE.W, MOVEA(WORD) 
            JMP     OP0100              *NOP, MOVEM, LEA, CLR, JSR, RTS
            JMP     OP0101              *ADDQ
            JMP     OP0110              *Bcc
            JMP     OP0111              *MOVEQ
            JMP     OP1000              *DIVU, OR
            JMP     OP1001              *SUB
            JMP     OP1010              *this is necessary for the jump table 
            JMP     OP1011              *CMP
            JMP     OP1100              *MULS, AND
            JMP     OP1101              *ADD, ADDA
            JMP     OP1110              *LSR, LSL, ASR, ASL, ROL, ROR
            JMP     INVALID_OPCODE      *No required opcodes


    JMP    INVALID_OPCODE     *If you're reading this line, it's invalid.
    RTS

**************************************************************************
*        OP0000 - Subroutine for operations beginning with 0000          *
*        ADDI         *MORE ERROR CHECKING IS POSSIBLE BC OF THE IMMEDIATE DATA LIMITS
**************************************************************************
OP0000
    MOVE.W  D0, D1 *BITS 11, 10, 9, 8 MUST BE 0110
    LSL.W   #4, D1
    LSR.W   #4, D1
    LSR.W   #8, D1
    CMP.B   #6, D1
    BNE     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 7, 6 MUST BE LESS THAN OR EQUAL TO 2
    LSR.B   #6, D1
    CMP.B   #3, D1
    BGE     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 5,4,3 MAY NEVER BE 001, 101, 110
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    
    MOVE.B  D0, D1 *BITS 5,4,3,2,1,0 MAY NEVER BE GT (111 010) 0011 1010 
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    
    LEA     ADDI, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_ADDI         *Branch to EA analysis of the command

**************************************************************************
*        OP0001 - Subroutine for operations beginning with 0001          *
*        MOVE.B                                                          *
**************************************************************************
OP0001
    MOVE.W  D0, D1 *BITS 8,7,6 CAN NEVER BE 001, 110, 101
    LSL.W   #7, D1
    LSR.W   #7, D1
    LSR.W   #6, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 11,10,9,8,7,6 MAY NOT BE 00 100 111, 00 010 111, 00 011 111
    LSL.W   #4, D1
    LSR.W   #4, D1
    LSR.W   #6, D1
    CMP.B   #%00100111, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00010111, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00011111, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 5,4,3 CANT BE 110, OR 101
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 5,4,3,2,1,0 MAY NOT BE 111 010, 111 011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE
    
    LEA     MOVE, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_MOVE         *Branch to EA analysis of the command

**************************************************************************
*        OP0010 - Subroutine for operations beginning with 0010          *
*        MOVE.W, MOVEA(WORD)                                             *
**************************************************************************
OP0010
    *Identical to OP0011 for these purposes, branch there
    BRA OP0011

**************************************************************************
*        OP0011 - Subroutine for operations beginning with 0011          *
*        MOVE.L, MOVEA(LONG)                                             *
**************************************************************************
OP0011

    *20e0 -> 0010 0000 1110 0000 
     *       0010 000 011 100 000  = move.l (a0)+, 
     
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    **ISOLATE NEXT BITS TO CHECK**
    MOVE.W  D0, D1 *BITS 5,4,3 CANT BE 110, OR 101
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 5,4,3,2,1,0 MAY NOT BE 111 010, 111 011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #7,D1           *Shift left 7 bits 
    LSR.W   #5,D1           *Rotate right 5 bits
    LSR.W   #8,D1           *Shift right again (13 shifts total)
    
    CMP     #%001,D1      *Check for 001 to eliminate CLR
    BEQ     _MOVEA          *If equal, branch to CLR
    BRA     _MOVE
    
********* MOVEL *************        
_MOVE
    MOVE.W  D0, D1 *BITS 8,7,6 CAN NEVER BE 001, 110, 101
    LSL.W   #7, D1
    LSR.W   #7, D1
    LSR.W   #6, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 11,10,9,8,7,6 MAY NOT BE 00 100 111, 00 010 111, 00 011 111
    LSL.W   #4, D1
    LSR.W   #4, D1
    LSR.W   #6, D1
    CMP.B   #%00100111, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00010111, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00011111, D1
    BEQ     INVALID_OPCODE

    LEA     MOVE, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_MOVE        *Branch to EA analysis of the command

********* MOVEAL *************  

      
_MOVEA
    MOVE.W  D0, D1 *BITS 13,12 MUST BE 11 OR 10
    LSL.W   #2, D1
    LSR.W   #8, D1
    LSR.W   #6, D1
    CMP.B   #2, D1
    BEQ     NX1
    CMP.B   #3, D1
    BEQ     NX1
    BRA     INVALID_OPCODE
    
NX1     
    MOVE.W  D0, D1 *BITS 8,7,6 MUST BE 001
    LSL.W   #7, D1
    LSR.W   #7, D1
    LSR.W   #6, D1
    CMP.B   #1, D1
    BNE     INVALID_OPCODE
    
    LEA     MOVEA, A4        *Load output string to A4
    JSR     PASTE_5
    BRA     EA_MOVEA       *Branch to EA analysis of the command

**************************************************************************
*        OP0100 - Subroutine for operations beginning with 0100          *
*        NOP(), MOVEM(), LEA(), CLR(), JSR(), RTS()                            *
**************************************************************************
OP0100
    *4EF9 -> 0100 1110 1111 1001 

    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    MOVE.W  D0,D1           *Copy instruction for modification
    
    CMP     #%0100111001110001,D1   *Check to eliminate NOP
    BEQ     _NOP
    CMP     #%0100111001110101,D1   *Check to eliminate RTS
    BEQ     _RTS
    
    LSR.W   #6,D1                   *Shift right 6 bits
    CMP     #%0000000100111010,D1   *Check to eliminate JSR
    BEQ     _JSR
    
    **ISOLATE 4 BITS TO CHECK CLR**    
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left 7 bits 
    LSR.W   #4,D1           *Rotate right 5 bits
    LSR.W   #8,D1           *Shift right again (13 shifts total)
    ANDI.W  #$000F,D1       *Keep 4 bits
    
    CMP     #%0010,D1       *Check for 0010 to eliminate CLR
    BEQ     _CLR            *If equal, branch to CLR

    **ISOLATE 3 BITS TO CHECK MOVEM**
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #6,D1           *Shift left 6 bits 
    LSR.W   #5,D1           *Shift right 5 bits
    LSR.W   #8,D1           *Shift right again (13 shifts total)
    ANDI.W  #$00F,D1        *Keep 3 bits
    
    CMP     #%001,D1
    BEQ     _MOVEM
    
    *CHECK FOR JMP 
    CMP.W   #%0100111011111001, D0
    BEQ     EAT_LONG
    CMP.W   #%0100111011111000, D0
    BEQ     EAT_WORD
    
    BRA     _LEA            *Else by process of elimination it must be LEA   
    
********* CLR *************        
_CLR
    MOVE.W  D0, D1 *BITS 7,6 CANT BE 11
    LSR.B   #6, D1
    CMP.B   #3, D1
    BGE     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 5,4,3 CANT BE 001, 110, 101
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 5,4,3,2,1,0 CANT BE GT 00111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    
    LEA     OPCLR, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_CLR          *Branch to EA analysis of the command

********* LEA *************        
_LEA
    MOVE.W      D0, D1 *BITS 8,7,6 MUST BE 111
    LSL.W           #7, D1
    LSR.W           #7, D1
    LSR.W           #6, D1 
    CMP.B           #7, D1
    BNE                INVALID_OPCODE

    MOVE.W      D0, D1 *BITS 5,4,3, MUST BE 010, OR 111
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #2, D1
    BEQ        NX5
    CMP.B   #7, D1
    BEQ         NX5

NX5
    MOVE.W      D0, D1 *BITS 5,4,3,2,1,0 MUST NOT BE GT 111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE

    LEA     OPLEA, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_LEA          *Branch to EA analysis of the command

********* JSR *************     
_JSR
    MOVE.W  D0, D1 *BITS 5,4,3 MUST BE 010, 111
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #7, D1
    BEQ     NX2
    CMP.B   #2, D1
    BEQ     NX2
    BRA     EAT_WORD
    
NX2 
    MOVE.W  D0, D1 *BITS 5,4,3,2,1,0 CANT BE GT 00111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    
    LEA     OPJSR, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_JSR          *Branch to EA analysis of the command

********* NOP *************     
_NOP
    LEA     OPNOP, A4        *Load output string to A4
    JSR     PASTE_3
    MOVE.B  #00,(A3)+
    BRA     VALID_OPCODE          *Branch to EA analysis of the command      

********* RTS *************     
_RTS
    LEA     OPRTS, A4        *Load output string to A4
    JSR     PASTE_3
    MOVE.B  #00,(A3)+
    BRA     VALID_OPCODE          *Branch to EA analysis of the command      

********* MOVEM *************     
_MOVEM
    MOVE.W      D0, D1 *BIT 11 MUST BE 1
    LSL.W           #4, D1
    LSR.W           #8, D1
    LSR.W           #7, D1
    CMP.B           #0, D1
    BEQ                INVALID_OPCODE
                            *
    MOVE.W      D0, D1 *BIT 10 DETERMINES MODE
    LSL.W           #5, D1
    LSR.W           #8, D1
    LSR.W           #7, D1
    CMP.B           #1, D1
    BEQ                MEM_REG
    CMP.B           #0, D1
    BEQ                REG_MEM

MEM_REG
    MOVE.W       D0, D1 * BITS 5,4,3 MUST BE 010, 011, 111
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #7, D1
    BEQ         NX3
    CMP.B   #2, D1
    BEQ         NX3
    CMP.B   #3, D1
    BEQ         NX3
    BRA     INVALID_OPCODE

REG_MEM
    MOVE.W      D0, D1 * BITS 5,4,3 MUST BE 010 100, 111
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #7, D1
    BEQ         NX3
    CMP.B   #2, D1
    BEQ         NX3
    CMP.B   #4, D1
    BEQ         NX3
    BRA     INVALID_OPCODE

NX3
    MOVE.W      D0, D1  *BITS 5,4,3,2,1,0 MUST NOT BE GT 111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    BRA     NX4

NX4
    LEA     MOVEM, A4        *Load output string to A4
    JSR     PASTE_5
    BRA     EA_MOVEM        *Branch to EA analysis of the command
    
**************************************************************************
*        OP0101 - Subroutine for operations beginning with 0101          *
*        ADDQ                                                            *
**************************************************************************
OP0101
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT

    MOVE.W      D0, D1 *BITS 8,7,6 MUST NOT BE GT 2
    LSL.W           #7, D1
    LSR.W           #7, D1
    LSR.W           #6, D1 
    CMP.B           #3, D1
    BGE                INVALID_OPCODE

    MOVE.W      D0, D1 * BITS 5,4,3 MUST NOT BE 101, 110 
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W      D0, D1 *BITS 5,4,3,2,1,0   MUST NOT BE GT 111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE

    
    LEA     ADDQ, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_ADDQ         *Branch to EA analysis of the command
    
**************************************************************************
*        OP0110 - Subroutine for operations beginning with 0110          *
*        Bcc                                                             *
**************************************************************************
OP0110
    MOVE.W      D0, D1 *BITS 11,10,9,8 MUST BE EITHER 4, 14, 15
    LSL.W           #4, D1
    LSR.W           #4, D1
    LSR.W           #8, D1
    CMP.B           #4, D1 
    BEQ             NX6
    CMP.B           #14, D1
    BEQ             NX6
    CMP.B           #15, D1
    BEQ             NX6
    BRA             EAT_STUFF
    
EAT_STUFF   
    MOVE.W      D0, D1
    LSL.W       #8, D1
    LSR.W       #8, D1 *D1 = 8 BIT DISPLACEMENT
    CMP.B       #0, D1
    BEQ         EAT_WORD
    CMP.B       #$FF, D1
    BEQ         EAT_LONG
    ADD.L       #1, A2
    BRA         INVALID_OPCODE
    
EAT_WORD
    ADD.L       #3, A2
    BRA         INVALID_OPCODE

EAT_LONG
    ADD.L       #3, A2
    ADD.L       #2, A2
    BRA         INVALID_OPCODE
    
NX6
    MOVE.B  Bcc,(A3)+       *Load 'Bcc' to Add Reg 1 and then increment 
    BRA     EA_BCC          *Branch to EA analysis of the command

**************************************************************************
*        OP0111 - Subroutine for operations beginning with 0111          *
*        MOVEQ                                                           *
**************************************************************************
OP0111
    MOVE.W      D0, D1 * BIT 8 MUST BE A ZERO
    LSL.W           #7, D1
    LSR.W           #7, D1
    LSR.W           #8, D1
    CMP.B           #0, D1
    BNE                INVALID_OPCODE

    
    LEA     MOVEQ, A4        *Load output string to A4
    JSR     PASTE_5
    BRA     EA_MOVEQ        *Branch to EA analysis of the command
    
**************************************************************************
*        OP1000 - Subroutine for operations beginning with 1000          *
*        DIVU, OR                                                        *
**************************************************************************
OP1000

    **ISOLATE NEXT BITS TO CHECK**
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #7,D1           *Shift left 7 bits 
    LSR.W   #5,D1           *Rotate right 5 bits
    LSR.W   #8,D1           *Shift right again (13 shifts total)
    ANDI.W  #$00F,D1        *Keep 3 bits
          
    CMP     #%011,D1    *Check for 011 to eliminate DIVU
    BEQ     _DIVU        *If equal, branch to DIVU
    BRA     _OR          *Else must be OR, branch
    
********* DIVU *************        
_DIVU
    MOVE.W          D0, D1  * BITS 5,4,3, CANT BE 001, 101, 110
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W          D0, D1 *BITS 5,4,3,2,1,0 CANT BE  00111010 OR 00111011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE

    LEA     DIVU, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_MULS         *Branch to EA analysis of the command

********* OR *************        
_OR
    MOVE.W          D0, D1 * BITS 8,7,6 CANT BE 111
    LSL.W           #7, D1
    LSR.W           #7, D1
    LSR.W           #6, D1 
    CMP.B           #7, D1
    BEQ                INVALID_OPCODE
    CMP.B           #3, D1
    BLT                 DN_V
    CMP.B           #3, D1
    BGT                EA_V

DN_V                                                        *EA IS SOURCE, REGISTER IS DESTINATION
    MOVE.W          D0, D1 *BITS 5,4,3 CANT BE 001, 101, 110
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W          D0, D1 *BITS 5,4,3,2,1,0 CANT BE 00111010 OR 00111011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE
    BRA         NX7

EA_V
    MOVE.W          D0, D1 * BITS 5,4,3, CANT BE 000, 001, 110, 101
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    CMP.B       #0, D1
    BEQ         INVALID_OPCODE

    MOVE.W          D0, D1 *BITS 5,4,3,2,1,0 CANT BE GT 00111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    BRA         NX7


NX7
    LEA     OR, A4        *Load output string to A4
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    BRA     EA_ADD           *Branch to EA analysis of the command


**************************************************************************
*        OP1001 - Subroutine for operations beginning with 1001          *
*        SUB                                                             *
**************************************************************************
OP1001

    MOVE.W          D0, D1 * BITS 8,7,6  CANT BE 111, 011
    LSL.W           #7, D1
    LSR.W           #7, D1
    LSR.W           #6, D1 
    CMP.B           #7, D1
    BEQ                INVALID_OPCODE
    CMP.B           #3, D1
    BEQ                 INVALID_OPCODE
    CMP.B           #3, D1
    BLT                 DN_V1
    CMP.B           #3, D1
    BGT                EA_V1

DN_V1
    MOVE.W      D0, D1 *BITS 5,4,3 CANT BE 101, 110 
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W      D0, D1 *BITS 5,4,3,2,1,0 CANT BE 00111010 OR 00111011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE
    BRA     NX8

EA_V1
    MOVE.W          D0, D1 * BITS 5,4,3 CANT BE 000, 001, 101, 110
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    CMP.B       #0, D1
    BEQ         INVALID_OPCODE

    MOVE.W          D0, D1 * BITS 5,4,3,2,1,0 CANT BE GT 00111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    BRA         NX8

NX8
    LEA     OPSUB, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_ADD          *Branch to EA analysis of the command
    
***************************************************************************
*       OP1010
*     NULL
***************************************************************************
OP1010 *DO NOT DELETE THIS, HAS TO BE HERE FOR THE JUMP TABLE TO WORK
    BRA     INVALID_OPCODE
    

**************************************************************************
*        OP1011 - Subroutine for operations beginning with 1011          *
*        CMP                                                             *
**************************************************************************
OP1011
    MOVE.W  D0, D1 *ISOLATE 8,7,6 TO CHECK FOR CMPA
    LSL.W   #7, D1
    LSR.W   #7, D1
    LSR.W   #6, D1 *D1 HOLDS SIZE AKA OPMODE, IF OPMODE IS 111 OR 011 ITS INVALID
    CMP.B   #3, D1
    BGE         INVALID_OPCODE

    MOVE.W      D0, D1 *BITS 5,4,3 CANNOT BE 101, 110
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W      D0, D1 *BITS 5,4,3,2,1,0 CANNOT BE 00111010 OR 00111011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE

    LEA     CMP, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_CMP          *Branch to EA analysis of the command

**************************************************************************
*        OP1100 - Subroutine for operations beginning with 1100          *
*        MULS, AND                                                       *
**************************************************************************
OP1100 *CASE C24E -> 1100 0010 0100 1110 -> 1100 001 001 001 110
                                        **                                   -> AUTO REG OMO EAM EAR\
                          
    *EA MODE CAN NEVER BE A 001; ISOLATING
    MOVE.W  D0, D1
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE

    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS

    MOVE.W  D0,D1           *Copy instruction for modification    *8,7,6
    LSL.W   #7,D1           *Shift left 7 bits 
    LSR.W   #5,D1           *Rotate right 5 bits
    LSR.W   #8,D1           *Shift right again (13 shifts total)
    ANDI.W  #$00F,D1        *Keep 3 bits
         
    CMP.B   #3, D1
    BEQ         INVALID_OPCODE
    CMP     #%111,D1       *Check for 111 to eliminate MULS
    BEQ     _MULS           *If equal, branch to MULS
    BRA     _AND            *Else must be AND, branch
    
********* MULS *************        
_MULS
    MOVE.W      D0,D1 *BITS 5,4,3 CANT BE 1, 5, 6
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W          D0, D1 *BITS 5,4,3,2,1,0 SAME AS DIVU
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE

    LEA     MULS, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_MULS         *Branch to EA analysis of the command

********* AND *************        
_AND
    MOVE.W          D0, D1 * BITS 8,7,6 CANT BE 111
    LSL.W           #7, D1
    LSR.W           #7, D1
    LSR.W           #6, D1 
    CMP.B           #3, D1
    BLT                 DN_V2
    CMP.B           #3, D1
    BGT                EA_V2

DN_V2                                                      *EA IS SOURCE, REGISTER IS DESTINATION
    MOVE.W          D0, D1 *BITS 5,4,3 CANT BE 001, 101, 110
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W          D0, D1 *BITS 5,4,3,2,1,0 CANT BE 00111010 OR 00111011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE
    BRA         NX9

EA_V2
    MOVE.W          D0, D1 * BITS 5,4,3, CANT BE 000, 001, 110, 101
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    CMP.B       #0, D1
    BEQ         INVALID_OPCODE

    MOVE.W          D0, D1 *BITS 5,4,3,2,1,0 CANT BE GT 00111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    BRA         NX9

NX9
    LEA     AND, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_ADD          *Branch to EA analysis of the command
    
**************************************************************************
*        OP1101 - Subroutine for operations beginning with 1101          *
*        ADD, ADDA                                                       *
**************************************************************************
OP1101
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS  

    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #8,D1           *Shift left 7 bits 
    LSR.W   #6,D1           *Rotate left 5 bits
    LSR.W   #8,D1           *Shift left again (13 shifts total)
    ANDI.W  #$0F,D1         *Keep 3 bits
              
    CMP     #%11,D1         *Check for 011 to eliminate ADDA (Size dependant)
    BEQ     _ADDA           *If equal, branch to ADDA
    BRA     _ADD            *Else must be ADD, branch
    
********* ADD *************        
_ADD
    MOVE.W          D0, D1 * BITS 8,7,6  CANT BE 111, 011
    LSL.W           #7, D1
    LSR.W           #7, D1
    LSR.W           #6, D1 
    CMP.B           #3, D1
    BLT                 DN_V3
    CMP.B           #3, D1
    BGT                EA_V3

DN_V3
    MOVE.W      D0, D1 *BITS 5,4,3 CANT BE 101, 110 
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W      D0, D1 *BITS 5,4,3,2,1,0 CANT BE 00111010 OR 00111011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE
    BRA     NX11

EA_V3
    MOVE.W          D0, D1 * BITS 5,4,3 CANT BE 000, 001, 101, 110
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    CMP.B       #0, D1
    BEQ         INVALID_OPCODE

    MOVE.W          D0, D1 * BITS 5,4,3,2,1,0 CANT BE GT 00111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    BRA         NX11

NX11

    LEA     ADD, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_ADD          *Branch to EA analysis of the command

********* AND *************        
_ADDA

    MOVE.W      D0, D1 *BITS 5,4,3 CANT BE 101, 110 
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE

    MOVE.W      D0, D1 *BITS 5,4,3,2,1,0 CANT BE 00111010 OR 00111011
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BEQ     INVALID_OPCODE
    CMP.B   #%00111011, D1
    BEQ     INVALID_OPCODE


    LEA     ADDA, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_ADDA         *Branch to EA analysis of the command



    
**************************************************************************
*        OP1110 - Subroutine for operations beginning with 1110          *
*        LSR, LSL, ASR, ASL, ROL, ROR                                    *
**************************************************************************
OP1110
    MOVE.W  D0, D1           *iso bits 7, 6 to determine shift type
    LSL.W   #8, D1          
    LSR.W   #8, D1           
    LSR.W   #6, D1           * d1 = shift type
    CMP.B   #3, D1
    BEQ     MEM_SHIFT
    BNE     REG_SHIFT
               
MEM_SHIFT   *BITS 10 AND 9 DECIDE THE OPERATION
    MOVE.W  D0, D1 * BIT 11 SHOULD ALWAYS BE A 0
    LSL.W   #4, D1
    LSR.W   #8, D1
    LSR.W   #7, D1
    CMP.B   #0, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0, D1 * BITS 5,4,3 MAY NOT BE 000, 001, 101, 110
    LSL.B   #2, D1
    LSR.B   #5, D1
    CMP.B   #1, D1
    BEQ     INVALID_OPCODE
    CMP.B   #5, D1
    BEQ     INVALID_OPCODE
    CMP.B   #6, D1
    BEQ     INVALID_OPCODE
    CMP.B   #0, D1
    BEQ     INVALID_OPCODE
    
    MOVE.W  D0, D1 *BITS 5,4,3,2,1,0 CANT BE GT 00111010
    LSL.B   #2, D1
    LSR.B   #2, D1 
    CMP.B   #%00111010, D1
    BGE     INVALID_OPCODE
    
    MOVE.W  D0, D1
    LSL.W   #5, D1
    LSR.W   #8, D1
    LSR.W   #6, D1 *D1 = OP CODE
    BRA     GET_OP
    
REG_SHIFT   *BITS 4 AND 3 DECIDE THE OPERATION
    MOVE.W  D0, D1
    LSL.W   #8, D1
    LSL.W   #3, D1
    LSR.W   #8, D1
    LSR.W   #6, D1 *D1 = OP CODE
    BRA     GET_OP
    
GET_OP
    CMP.B   #0, D1
    BEQ     ARI
    CMP.B   #1, D1
    BEQ     LOG
    CMP.B   #3, D1
    BEQ     ROT
    BRA     INVALID_OPCODE
    
LOG
    MOVE.W  D0, D1
    LSL.W   #7, D1
    LSR.W   #7, D1
    LSR.W   #8, D1
    CMP.B   #0, D1
    BEQ     _LSR
    BNE     _LSL
    
ARI
    MOVE.W  D0, D1
    LSL.W   #7, D1
    LSR.W   #7, D1
    LSR.W   #8, D1
    CMP.B   #0, D1
    BEQ     _ASR
    BNE     _ASL

ROT
    MOVE.W  D0, D1
    LSL.W   #7, D1
    LSR.W   #7, D1
    LSR.W   #8, D1
    CMP.B   #0, D1
    BEQ     _ROR
    BNE     _ROL
    
*--------------------------------------good below---------------------------
_LSL    
    LEA     LSL, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_LSD         *Branch to EA analysis of the command

_LSR
    LEA     LSR, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_LSD          *Branch to EA analysis of the command
    
_ASL    
    LEA     ASL, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_LSD          *Branch to EA analysis of the command

_ASR
    LEA     ASR, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_LSD          *Branch to EA analysis of the command
    
_ROL    
    LEA     ROL, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_LSD          *Branch to EA analysis of the command

_ROR
    LEA     ROR, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_LSD          *Branch to EA analysis of the command
    
PASTE_3
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    RTS

PASTE_4
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    RTS

PASTE_5
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    RTS

    SIMHALT










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
