*-----------------------------------------------------------
* Title      : Op_jumpTable
* Written by : Kristen Attebery
* Date       : 6/4/16
* Description: OP code decoder for 68k disassembler
*              Team.cpp CSS 422 Spring 2016
*-----------------------------------------------------------
VERIFY_OPCODE
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
            JMP     OP0010              *MOVE.W, MOVEA(WORD)
            JMP     OP0011              *MOVE.L, MOVEA(LONG) 
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
*        ADDI                                                            *
**************************************************************************
OP0000
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    *MOVE.W  ADDI,(A3)+     *Load 'ADDI' to Add Reg 1 and then increment
    LEA     ADDI, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_ADDI         *Branch to EA analysis of the command

**************************************************************************
*        OP0001 - Subroutine for operations beginning with 0001          *
*        MOVE.B                                                          *
**************************************************************************
OP0001  *SINGLE CODE, DO NOT NEED FURTHER CHECKING 
        *BEGIN OUTPUT
    
    *MOVE.L  MOVE,(A3)+     *Load 'MOVE.B' to Add Reg 1 and then increment
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
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS

    **ISOLATE NEXT BITS TO CHECK**
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #7,D1           *Shift left 7 bits 
    LSR.W   #5,D1           *Rotate right 5 bits
    LSR.W   #8,D1           *Shift right again (13 shifts total)
    ANDI.W  #$00F,D1        *Keep 3 bits
    
    CMP     #%001,D1      *Check for 0010 to eliminate CLR
    BEQ     _MOVEA          *If equal, branch to CLR
    
    BRA     _MOVE
    
********* MOVEL *************        
_MOVE
    *MOVE.L  MOVE,(A3)+     *Load 'MOVE.L' to Add Reg 1 and then increment  
    LEA     MOVE, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_MOVE        *Branch to EA analysis of the command

********* MOVEAL *************        
_MOVEA
    *MOVE.L  MOVEA,(A3)+    *Load 'MOVEA.L' to Add Reg 1 and then increment
    LEA     MOVEA, A4        *Load output string to A4
    JSR     PASTE_5
    BRA     EA_MOVEA       *Branch to EA analysis of the command

**************************************************************************
*        OP0100 - Subroutine for operations beginning with 0100          *
*        NOP, MOVEM, LEA, CLR, JSR, RTS                                  *
**************************************************************************
OP0100
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
     MOVE.W  D0,D1           *Copy instruction for modification
    
    CMP     #%0100111001110001,D1   *Check to eliminate NOP
    BEQ     _NOP
    CMP     #%0100111001110101,D1   *Check to eliminate RTS
    BEQ     _RTS
    
    LSR.W   #6,D1                   *Shift right 6 bits
    CMP     #%0000000100111010,D1   *Check to eliminate RTS
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
    
    BRA     _LEA            *Else by process of elimination it must be LEA   
    
********* CLR *************        
_CLR
    *MOVE.W  OPCLR,(A3)+     *Load 'CLR' to Add Reg 1 and then increment
    LEA     OPCLR, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_CLR          *Branch to EA analysis of the command

********* LEA *************        
_LEA
    *MOVE.W  OPLEA,(A3)+     *Load 'LEA' to Add Reg 1 and then increment
    LEA     OPLEA, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_LEA          *Branch to EA analysis of the command

********* JSR *************     
_JSR
    *MOVE.W  OPJSR,(A3)+     *Load 'JSR' to Add Reg 1 and then increment
    LEA     OPJSR, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_JSR          *Branch to EA analysis of the command

********* NOP *************     
_NOP
    *MOVE.W  OPNOP,(A3)+     *Load 'NOP' to Add Reg 1 and then increment
    LEA     OPNOP, A4        *Load output string to A4
    JSR     PASTE_3
    MOVE.B  #00,(A3)+
    BRA     VALID_OPCODE          *Branch to EA analysis of the command      

********* RTS *************     
_RTS
    *MOVE.W  OPRTS,(A3)+     *Load 'RTS' to Add Reg 1 and then increment
    LEA     OPRTS, A4        *Load output string to A4
    JSR     PASTE_3
        MOVE.B  #00,(A3)+
    BRA     VALID_OPCODE          *Branch to EA analysis of the command      

********* MOVEM *************     
_MOVEM
    *MOVE.W  MOVEM,(A3)+     *Load 'MOVEM' to Add Reg 1 and then increment
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
    
    *MOVE.W  ADDQ,(A3)+      *Load 'AddQ' to Add Reg 1 and then increment
    LEA     ADDQ, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_ADDQ         *Branch to EA analysis of the command
    
**************************************************************************
*        OP0110 - Subroutine for operations beginning with 0110          *
*        Bcc                                                             *
**************************************************************************
OP0110
    MOVE.W  D0, D1  *CASE FOR BRA
    LSL.W   #4, D1
    LSR.W   #8, D1
    LSR.W   #4, D1
    CMP.B   #0, D1
    BEQ     INVALID_OPCODE
    
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    MOVE.W  D0,D1
    LSL.W   #4,D1
    LSR.W   #4,D1
    LSR.W   #8,D1
    CMP.B   #0,D1
    BEQ     INVALID_OPCODE
    
    MOVE.B  Bcc,(A3)+       *Load 'Bcc' to Add Reg 1 and then increment 
    BRA     EA_BCC          *Branch to EA analysis of the command

**************************************************************************
*        OP0111 - Subroutine for operations beginning with 0101          *
*        MOVEQ                                                           *
**************************************************************************
OP0111
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    *MOVE.W  MOVEQ,(A3)+     *Load 'MOVEQ' to Add Reg 1 and then increment
    LEA     MOVEQ, A4        *Load output string to A4
    JSR     PASTE_5
    BRA     EA_MOVEQ        *Branch to EA analysis of the command
    
**************************************************************************
*        OP1000 - Subroutine for operations beginning with 1000          *
*        DIVU, OR                                                        *
**************************************************************************
OP1000
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
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
    *MOVE.W  DIVU,(A3)+      *Load 'DIVU' to Add Reg 1 and then increment
    LEA     DIVU, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_MULS         *Branch to EA analysis of the command

********* OR *************        
_OR
    *MOVE.W  OR,(A3)+        *Load 'OR' to Add Reg 1 and then increment
    LEA     OR, A4        *Load output string to A4
    MOVE.B  (A4)+, (A3)+
    MOVE.B  (A4)+, (A3)+
    BRA     EA_ADD           *Branch to EA analysis of the command

**************************************************************************
*        OP1001 - Subroutine for operations beginning with 1001          *
*        SUB                                                             *
**************************************************************************
OP1001
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    *MOVE.W  OPSUB,(A3)+     *Load 'SUB' to Add Reg 1 and then increment
    LEA     OPSUB, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_ADD          *Branch to EA analysis of the command
    
    
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
    CMP.B   #7, D1
    BEQ     INVALID_OPCODE
    CMP.B   #3, D1
    BEQ     INVALID_OPCODE
    
    LEA     CMP, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_CMP          *Branch to EA analysis of the command

**************************************************************************
*        OP1100 - Subroutine for operations beginning with 1100          *
*        MULS, AND                                                       *
**************************************************************************
OP1100
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS

    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #7,D1           *Shift left 7 bits 
    LSR.W   #5,D1           *Rotate right 5 bits
    LSR.W   #8,D1           *Shift right again (13 shifts total)
    ANDI.W  #$00F,D1        *Keep 3 bits
         
    CMP     #%111,D1       *Check for 111 to eliminate MULS
    BEQ     _MULS           *If equal, branch to MULS
    BRA     _AND            *Else must be AND, branch
    
********* MULS *************        
_MULS
    *MOVE.W  MULS,(A3)+      *Load 'MULS' to Add Reg 1 and then increment
    LEA     MULS, A4        *Load output string to A4
    JSR     PASTE_4
    BRA     EA_MULS         *Branch to EA analysis of the command

********* AND *************        
_AND
    *MOVE.W  AND,(A3)+       *Load 'AND' to Add Reg 1 and then increment
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
    *MOVE.W  ADD,(A3)+       *Load 'ADD' to Add Reg 1 and then increment
    LEA     ADD, A4        *Load output string to A4
    JSR     PASTE_3
    BRA     EA_ADD          *Branch to EA analysis of the command

********* AND *************        
_ADDA
    *MOVE.W  ADDA,(A3)+      *Load 'ADDA' to Add Reg 1 and then increment
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

    **ELSE CONTINUE CHECKING**
*    MOVE.W  D0,D1           *Copy instruction for modification
*    LSL.W   #8,D1          *Shift left 7 bits
*    LSL.W   #3,D1 
*    LSR.W   #5,D1           *Rotate left 5 bits
*    LSR.W   #8,D1           *Shift left again (13 shifts total)
*    ANDI.W  #$0F,D1         *Keep 2 bits
*    
*    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS                   
*    CMP     #%00,D1         *Check for 00 to eliminate ASd
*    BEQ     _ASd            *If equal, branch to ASd to determine ASR or ASL
*    BRA     _ROd            *Else must be a ROd instruction, branch to determine
*    
*********** LSd *************        
*_LSd   
* 
*    MOVE.W  D0,D1           *Copy instruction for modification
*    LSL.W   #7,D1           *Shift left 7 bits 
*    LSR.W   #7,D1           *Rotate right 5 bits
*    LSR.W   #8,D1           *Shift right again (13 shifts total)
*    ANDI.W  #$F,D1          *Keep 1 bit
*
*    CMP     #%0,D1        *Check for 011 to eliminate LSR
*    BEQ     _LSR            *If equal, branch to LSR
*    BRA     _LSL            *Else must be LSL, branch
*
********** ASd *************
*_ASd
*
*    MOVE.W  D0,D1           *Copy instruction for modification
*    LSL.W   #8,D1           *Shift left 7 bits 
*    LSL.W   #2,D1           *Shift left 7 bits
*    LSR.W   #5,D1           *Rotate right 5 bits
*    LSR.W   #8,D1           *Shift right again (13 shifts total)
*    ANDI.W  #$00F,D1        *Keep 3 bits
*   
*    CMP     #%000,D1        *Check for 000 to eliminate ASR
*    BEQ     _ASR            *If equal, branch to ASR
*    BRA     _ASL            *Else must be ASL, branch
*
********** ROd *************
*_ROd
*
*    MOVE.W  D0,D1           *Copy instruction for modification
*    LSL.W   #2,D1           *Shift left 7 bits
*    LSL.W   #8,D1           *Shift left 7 bits 
*    LSR.W   #5,D1           *Rotate right 5 bits
*    LSR.W   #8,D1           *Shift right again (13 shifts total)
*    ANDI.W  #$00F,D1        *Keep 3 bits
*
*    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS   
*    CMP     #%011,D1        *Check for 011 to eliminate ROR
*    BEQ     _ROR            *If equal, branch to ROR
*    BRA     _ROL            *Else must be ROL, branch







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
