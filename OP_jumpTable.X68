*-----------------------------------------------------------
* Title      : Op Codes
* Written by : Kristen Attebery
* Date       :
* Description:
*-----------------------------------------------------------
VERIFY_OPCODE
    MOVE.W  D0,D1   *Copy instruction for modification
    
    **ISOLATE FIRST FOUR BITS**                                             
    LSR.W   #4,D1       *Shift left four bits
    LSR.W   #8,D1       *Shift left again (12 shifts total)
    ANDI.W  #$000F,D1   *Keep only four bits
    
    LEA     OP_JTAB,A0 
    MULU    #6, D1
    JSR     0(A0,D1)
        



**************************************************************************
*               CMP table 1. Determine OP code.                         *
*        Analyzes the first four bits within the instruction             *
*        and jumps to the corresponding subroutine.                      *
**************************************************************************

OP_JTAB

*OP_JTAB
    JMP     OP0000      *Subroutine for operations beginning with 0000
    JMP     OP0001      *Subroutine for operations beginning with 0001
    JMP     OP0010      *Subroutine for operations beginning with 0010
    JMP     OP0011      *Subroutine for operations beginning with 0011
    JMP     OP0100      *Subroutine for operations beginning with 0100
    JMP     OP0101      *Subroutine for operations beginning with 0101
    JMP     OP0110      *Subroutine for operations beginning with 0110
    JSR     OP1000      *Subroutine for operations beginning with 1000
    JMP     OP1001      *Subroutine for operations beginning with 1001
    JMP     OP1011      *Subroutine for operations beginning with 1011
    JMP     OP1100      *Subroutine for operations beginning with 1100
    JMP     OP1101      *Subroutine for operations beginning with 1101
    JMP     OP1110      *Subroutine for operations beginning with 1110


*    CMP     #%0000,D1   *ADDI 
*    BEQ     OP0000
*    CMP     #%0001,D1   *MOVE.B
*    BEQ     OP0001
*    CMP     #%0010,D1   *MOVE.W, MOVEA(WORD)
*    BEQ     OP0010 
*    CMP     #%0011,D1   *MOVE.L, MOVEA(LONG)  
*    BEQ     OP0011   
*    CMP     #%0100,D1   *NOP, MOVEM, LEA, CLR, JSR, RTS
*    BEQ     OP0100
*    CMP     #%0101,D1   *ADDQ
*    BEQ     OP0101    
*    CMP     #%0110,D1   *Bcc
*    BEQ     OP0110   
*    CMP     #%1000,D1   *MOVEQ
*    BEQ     OP1000    
*    CMP     #%1001,D1   *DIVU, OR
*    BEQ     OP1000    
*    CMP     #%1010,D1   *SUB
*    BEQ     OP1000    
*    CMP     #%1011,D1   *CMP
*    BEQ     OP1000    
*    CMP     #%1100,D1   *MULS, AND 
*    BEQ     OP1000   
*    CMP     #%1101,D1   *ADD, ADDA
*    BEQ     OP1000   
*    CMP     #%1110,D1   *LSR, LSL, ASR, ASL, ROL, ROR  
*    BEQ     OP1000

    
    BRA    INVALID_OPCODE     *Subroutine to store as non-decodable

**************************************************************************
*        OP0000 - Subroutine for operations beginning with 0000          *
*        ADDI                                                            *
**************************************************************************
OP0000
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    MOVE.W  ADDI,(A3)+      *Load 'ADDI' to Add Reg 1 and then increment
    BRA     EA_ADDI         *Branch to EA analysis of the command

ADDI    DC.B    'ADDI',0
**************************************************************************
*        OP0001 - Subroutine for operations beginning with 0001          *
*        MOVE.B                                                          *
**************************************************************************
OP0001  *SINGLE CODE, DO NOT NEED FURTHER CHECKING 
        *BEGIN OUTPUT
    
    MOVE.W  MOVEB,(A3)+     *Load 'MOVE.B' to Add Reg 1 and then increment
    BRA     EA_MOVE        *Branch to EA analysis of the command
    
MOVEB   DC.B    'MOVE',0

**************************************************************************
*        OP0010 - Subroutine for operations beginning with 0010          *
*        MOVE.W, MOVEA(WORD)                                             *******************************************************************************
**************************************************************************
OP0010
    *MULTIPLE CODE, BEGIN ELIMINATIONS
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS       
    CMP     #%001,D1        *Check for 001 to eliminate MOVEA.W
    BEQ     _MOVEAW         *If equal, branch to MOVEA.W
    BRA     _MOVEW          *Else must be MOVE.W. branch.
    
********* MOVEW *************        
_MOVEW
    MOVE.W  MOVEW,(A3)+     *Load 'MOVE.W' to Add Reg 1 and then increment  
    BRA     EA_MOVE        *Branch to EA analysis of the command
MOVEW     DC.B    'MOVE',0

********* MOVEAW *************        
_MOVEAW
    MOVE.W  MOVEAW,(A3)+    *Load 'MOVEA.W' to Add Reg 1 and then increment
    BRA     EA_MOVEA       *Branch to EA analysis of the command      
MOVEAW     DC.B    'MOVEA',0


**************************************************************************
*        OP0011 - Subroutine for operations beginning with 0011          *
*        MOVE.L, MOVEA(LONG)                                             **************************************************************************
**************************************************************************
OP0011
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS

    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS            
    CMP     #%001,D1        *Check for 001 to eliminate MOVEA.W
    BEQ     _MOVEAL         *If equal, branch to MOVEA.L
    BRA     _MOVEL          *Else must be MOVEL, branch
    
********* MOVEL *************        
_MOVEL
    MOVE.W  MOVEL,(A3)+     *Load 'MOVE.L' to Add Reg 1 and then increment
     
    BRA     EA_MOVE        *Branch to EA analysis of the command
MOVEL     DC.B    'MOVE',0

********* MOVEAL *************        
_MOVEAL
    MOVE.W  MOVEAL,(A3)+    *Load 'MOVEA.L' to Add Reg 1 and then increment
 
    BRA     EA_MOVEA       *Branch to EA analysis of the command
MOVEAL     DC.B    'MOVEA',0

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
    MOVE.W  D0,D1
    LSL.W   #4,D1           *Shift left to grab 4 bits 
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$000F,D1        *Keep 4 bits
    
    CMP     #%0010,D1       *Check for 0010 to eliminate CLR
    BEQ     _CLR            *If equal, branch to CLR

    **ISOLATE 3 BITS TO CHECK MOVEM**
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #6,D1           *Shift left 6 bits 
    LSR.W   #5,D1           *Rotate left 5 bits
    LSR.W   #8,D1           *Shift left again (13 shifts total)
    ANDI.W  #$00F,D1        *Keep 3 bits
    
    CMP     #%001,D1
    BEQ     _MOVEM
    
    BRA     _LEA            *Else by process of elimination it must be LEA   
    
********* CLR *************        
_CLR
    MOVE.W  OPCLR,(A3)+     *Load 'CLR' to Add Reg 1 and then increment
    BRA     EA_CLR          *Branch to EA analysis of the command
OPCLR     DC.B    'CLR',0

********* LEA *************        
_LEA
    MOVE.W  OPLEA,(A3)+     *Load 'LEA' to Add Reg 1 and then increment
    BRA     EA_LEA          *Branch to EA analysis of the command
OPLEA     DC.B    'LEA',0

********* JSR *************     
_JSR
    MOVE.W  OPJSR,(A3)+     *Load 'JSR' to Add Reg 1 and then increment
    BRA     EA_JSR          *Branch to EA analysis of the command
OPJSR     DC.B    'JSR',0

********* NOP *************     
_NOP
    MOVE.W  OPNOP,(A3)+     *Load 'NOP' to Add Reg 1 and then increment
*    MOVE.W  A3,A1           *load message
*    MOVE.B  #14,D0          *display string
*    TRAP    #15             *output string    
    BRA     VALID_OPCODE          *Branch to EA analysis of the command      
OPNOP     DC.B    'NOP',0

********* RTS *************     
_RTS
    MOVE.W  OPRTS,(A3)+     *Load 'RTS' to Add Reg 1 and then increment
    BRA     VALID_OPCODE          *Branch to EA analysis of the command      
OPRTS     DC.B    'RTS',0

********* MOVEM *************     
_MOVEM
    MOVE.W  MOVEM,(A3)+     *Load 'MOVEM' to Add Reg 1 and then increment
    BRA     EA_MOVEM        *Branch to EA analysis of the command
MOVEM     DC.B    'MOVEM',0
    
**************************************************************************
*        OP0101 - Subroutine for operations beginning with 0101          *
*        ADDQ                                                            *
**************************************************************************
OP0101
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    MOVE.W  ADDQ,(A3)+      *Load 'AddQ' to Add Reg 1 and then increment
    BRA     EA_ADDQ         *Branch to EA analysis of the command
    
ADDQ   DC.B    'ADDQ',0
    
**************************************************************************
*        OP0110 - Subroutine for operations beginning with 0110          *
*        Bcc                                                             *
**************************************************************************
OP0110
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    *MOVE.W  Bcc,(A3)+       *Load 'Bcc' to Add Reg 1 and then increment       ******************I don't THINK I need this line
    BRA     EA_BCC          *Branch to EA analysis of the command
    
Bcc  DC.B    'Bcc',0

**************************************************************************
*        OP0111 - Subroutine for operations beginning with 0101          *
*        MOVEQ                                                           *
**************************************************************************
OP0111
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    MOVE.W  MOVEQ,(A3)+     *Load 'MOVEQ' to Add Reg 1 and then increment
    BRA     EA_MOVEQ        *Branch to EA analysis of the command
    
MOVEQ   DC.B    'MOVEQ',0
    
**************************************************************************
*        OP1000 - Subroutine for operations beginning with 1000          *
*        DIVU, OR                                                        *******************************************************************************
**************************************************************************
OP1000
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #7,D1           *Shift left 7 bits 
    LSR.W   #5,D1           *Rotate left 5 bits
    LSR.W   #8,D1           *Shift left again (13 shifts total)
    ANDI.W  #$00F,D1        *Keep 3 bits
          
    CMP     #%011,D1    *Check for 011 to eliminate DIVU
    BEQ     _DIVU        *If equal, branch to DIVU
    BRA     _OR          *Else must be OR, branch
    RTS
    
********* DIVU *************        
_DIVU
    MOVE.W  DIVU,(A3)+      *Load 'DIVU' to Add Reg 1 and then increment
    BRA     EA_MULS         *Branch to EA analysis of the command
DIVU     DC.B    'DIVU',0

********* OR *************        
_OR
    MOVE.W  OR,(A3)+        *Load 'OR' to Add Reg 1 and then increment
    BRA     EA_ADD           *Branch to EA analysis of the command
OR       DC.B    'OR',0

**************************************************************************
*        OP1001 - Subroutine for operations beginning with 1001          *
*        SUB                                                             *
**************************************************************************
OP1001
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    MOVE.W  _SUB,(A3)+     *Load 'SUB' to Add Reg 1 and then increment
    BRA     EA_ADD          *Branch to EA analysis of the command

_SUB     DC.B    'SUB',0
**************************************************************************
*        OP1011 - Subroutine for operations beginning with 1011          *
*        CMP                                                             *
**************************************************************************
OP1011
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    MOVE.W  CMP,(A3)+     *Load 'CMP' to Add Reg 1 and then increment
    BRA     EA_CMP          *Branch to EA analysis of the command

CMP     DC.B    'CMP',0

**************************************************************************
*        OP1100 - Subroutine for operations beginning with 1100          *
*        MULS, AND                                                       *******************************************************************************
**************************************************************************
OP1100
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
 
    **ISOLATE NEXT BITS TO CHECK**
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #7,D1           *Shift left 7 bits 
    LSR.W   #5,D1           *Rotate left 5 bits
    LSR.W   #8,D1           *Shift left again (13 shifts total)
    ANDI.W  #$00F,D1        *Keep 3 bits
         
    CMP     #%111,D1       *Check for 111 to eliminate MULS
    BEQ     _MULS           *If equal, branch to MULS
    BRA     _AND            *Else must be AND, branch
    
********* MULS *************        
_MULS
    MOVE.W  MULS,(A3)+      *Load 'MULS' to Add Reg 1 and then increment
    BRA     EA_MULS         *Branch to EA analysis of the command
MULS     DC.B    'MULS',0

********* AND *************        
_AND
    MOVE.W  AND,(A3)+       *Load 'AND' to Add Reg 1 and then increment
    BRA     EA_ADD          *Branch to EA analysis of the command
AND       DC.B    'AND',0
    
**************************************************************************
*        OP1101 - Subroutine for operations beginning with 1101          *
*        ADD, ADDA                                                       *******************************************************************************
**************************************************************************
OP1101
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS  
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS             
    CMP     #%011,D1       *Check for 011 to eliminate ADDA (Size dependant)
    BEQ     _ADDA           *If equal, branch to ADDA
    CMP     #%111,D1        *Else check for 111 to eliminate ADDA (Size dependant)
    BEQ     _ADDA           *If equal, branch to ADDA
    BRA     _ADD            *Else must be ADD, branch
    
********* ADD *************        
_ADD
    MOVE.W  ADD,(A3)+       *Load 'ADD' to Add Reg 1 and then increment
    BRA     EA_ADD          *Branch to EA analysis of the command
ADD     DC.B    'ADD',0

********* AND *************        
_ADDA
    MOVE.W  ADDA,(A3)+      *Load 'ADDA' to Add Reg 1 and then increment
    BRA     EA_ADDA         *Branch to EA analysis of the command
ADDA      DC.B    'ADDA',0
    
**************************************************************************
*        OP1110 - Subroutine for operations beginning with 1110          *
*        LSR, LSL, ASR, ASL, ROL, ROR                                    *****************************************************************************
**************************************************************************
OP1110
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**    
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

                  
    CMP     #%001,D1       *Check for 001 to eliminate LSd instructions
    BEQ     _LSd            *If equal, branch to LSd to determine LSR or LSL
    BRA     OP1110_1
    
OP1110_1
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4 has been checked and 2/4 is ambiguous
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS                   
    CMP     #%000,D1       *Check for 000 to eliminate ASd (Rotation dependant)
    BEQ     _ASd            *If equal, branch to ASd to determine ASR or ASL
    CMP     #%100,D1       *Check for 100 to eliminate ASd (Rotation dependant)
    BEQ     _ASd            *If equal, branch to ASd to determine ASR or ASL
    BRA     _ROd             *Else must be a ROd instruction, branch to determine
    
********** LSd *************        
_LSd    
    **ISOLATE NEXT BITS TO CHECK**  
    **Look to 2/4 as 1/4 has been checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS          
    CMP     #%011,D1        *Check for 011 to eliminate LSR
    BEQ     _LSR            *If equal, branch to LSR
    BRA     _LSL            *Else must be LSL, branch

_LSL    
    MOVE.W  LSL,(A3)+       *Load 'LSL' to Add Reg 1 and then increment
    BRA     EA_LSD         *Branch to EA analysis of the command
LSL     DC.B    'LSL',0

_LSR
    MOVE.W  LSR,(A3)+       *Load 'LSR' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
LSR     DC.B    'LSR',0

********* ASd *************
_ASd
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4,2/4 already checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (3/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS       
    CMP     #%000,D1        *Check for 000 to eliminate ASR
    BEQ     _ASR            *If equal, branch to ASR
    BRA     _ASL            *Else must be ASL, branch

_ASL    
    MOVE.W  ASL,(A3)+       *Load 'ASL' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
ASL     DC.B    'ASL',0

_ASR
    MOVE.W  ASR,(A3)+       *Load 'ASR' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
ASR     DC.B    'ASR',0

********* ROd *************
_ROd
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4,2/4 already checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 'chunks')
    LSL.W   #4,D1           *Shift left to grab 3 bits (3/4 'chunks')
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION 'IF/ELSE' STATEMENTS   
    CMP     #%011,D1        *Check for 011 to eliminate ROR
    BEQ     _ROR            *If equal, branch to ROR
    *BRA     _ROL            *Else must be ROL, branch
    
_ROL    
    MOVE.W  ROL,(A3)+       *Load 'ROL' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
ROL     DC.B    'ROL',0

_ROR
    MOVE.W  ROR,(A3)+       *Load 'ROR' to Add Reg 1 and then increment
    BRA     EA_LSD          *Branch to EA analysis of the command
ROR     DC.B    'ROR',0


