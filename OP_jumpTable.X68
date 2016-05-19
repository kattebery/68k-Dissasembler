    MOVE.W  D0,D1   *Copy instruction for modification
    
    **ISOLATE FIRST FOUR BITS**
    LSR.W   #4,D1       *Shift left four bits
    LSR.W   #8,D1       *Shift left again (12 shifts total)
    ANDI.W  #$000F,D1   *Keep only four bits


**************************************************************************
*               Jump table 1. Determine OP code.                         *
*        Analyzes the first four bits within the instruction             *
*        and jumps to the corresponding subroutine.                      *
**************************************************************************
OP_JTAB
    JMP     OP0000      *Subroutine for operations beginning with 0000
    JMP     OP0001      *Subroutine for operations beginning with 0001
    JMP     OP0010      *Subroutine for operations beginning with 0010
    JMP     OP0011      *Subroutine for operations beginning with 0011
    JMP     OP0100      *Subroutine for operations beginning with 0100
    JMP     OP0101      *Subroutine for operations beginning with 0101
    JMP     OP0110      *Subroutine for operations beginning with 0110
    JMP     OP1000      *Subroutine for operations beginning with 1000
    JMP     OP1001      *Subroutine for operations beginning with 1001
    JMP     OP1011      *Subroutine for operations beginning with 1011
    JMP     OP1100      *Subroutine for operations beginning with 1100
    JMP     OP1101      *Subroutine for operations beginning with 1101
    JMP     OP1110      *Subroutine for operations beginning with 1110
    
    BRA     INVALID_OPCODE     *Subroutine to store as non-decodable


**************************************************************************
*        OP0000 - Subroutine for operations beginning with 0000          *
*        ADDI                                                            *
**************************************************************************
OP0000
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    LEA     ADDI,(A1)+      *Load "ADDI" to Add Reg 1 and then increment
    BRA     EA_ADDI         *Branch to EA analysis of the command

ADDI    DC.B    "ADDI"

**************************************************************************
*        OP0001 - Subroutine for operations beginning with 0001          *
*        MOVE.B                                                          *
**************************************************************************
OP0001
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT

    LEA     MOVEB,(A1)+     *Load "MOVE.B" to Add Reg 1 and then increment
    BRA     EA_MOVEB        *Branch to EA analysis of the command
    
MOVEB   DC.B    "MOVE.B"

**************************************************************************
*        OP0010 - Subroutine for operations beginning with 0010          *
*        MOVE.W, MOVEA(WORD)                                             *
**************************************************************************
OP0010
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS       
    CMP     #%001,D1        *Check for 001 to eliminate MOVEA.W
    BEQ     _MOVEAW         *If equal, branch to MOVEA.W
    BRA     _MOVEW          *Else must be MOVE.W. branch.
    
********* MOVEW *************        
_MOVEW
    LEA     MOVEW,(A1)+     *Load "MOVE.W" to Add Reg 1 and then increment
    BRA     EA_MOVEW        *Branch to EA analysis of the command
MOVEW     DC.B    "MOVE.W"

********* MOVEAW *************        
_MOVEAW
    LEA     MOVEAW,(A1)+    *Load "MOVEA.W" to Add Reg 1 and then increment
    BRA     EA_MOVEAW       *Branch to EA analysis of the command      
MOVEAW     DC.B    "MOVEA.W"


**************************************************************************
*        OP0011 - Subroutine for operations beginning with 0011          *
*        MOVE.L, MOVEA(LONG)                                             *
**************************************************************************
OP0011
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS

    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS            
    CMP     #%001,D1        *Check for 001 to eliminate MOVEA.W
    BEQ     _MOVEAL         *If equal, branch to MOVEA.L
    BRA     _MOVEL          *Else must be MOVEL, branch
    
********* MOVEL *************        
_MOVEL
    LEA     MOVEL,(A1)+     *Load "MOVE.L" to Add Reg 1 and then increment
    BRA     EA_MOVEL        *Branch to EA analysis of the command
MOVEL     DC.B    "MOVE.L"

********* MOVEAL *************        
_MOVEAL
    LEA     MOVEAL,(A1)+    *Load "MOVEA.L" to Add Reg 1 and then increment
    BRA     EA_MOVEAL       *Branch to EA analysis of the command
MOVEAL     DC.B    "MOVEA.L"

**************************************************************************
*        OP0100 - Subroutine for operations beginning with 0100          *
*        NOP, MOVEM, LEA, CLR, JSR, RTS                                  *
**************************************************************************
OP0100
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**    
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS
    CMP     #%001,D1        *Check for 001 to eliminate CLR
    BEQ     _CLR            *If equal, branch to CLR
    BRA     0100_1          *Else continue checking

0100_1 **Could be MOVEM, LEA, NOP, JSR, or RTS**

    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as 1/4 already checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS
    CMP     #%111,D1        *Check for 111 to eliminate LEA
    BEQ     _LEA            *If equal, branch to LEA
                            
    CMP     #%010,D1        *Else check for 010 to eliminate JSR
    BEQ     _JSR            *If equal, branch to JSR
    
    BRA     0100_2          *Else continue checking

0100_2 **Could be MOVEM, NOP, or RTS**

    **ISOLATE NEXT BITS TO CHECK**
    **Look to 4/4 as 1/4,2/4 already checked
    **and NOP and RTS both contain 110 in 3/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (3/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (4/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS    
    CMP     #%001,D1        *Check for 001 to eliminate NOP
    BEQ     _NOP            *If equal, branch to NOP
    
    CMP     #%101,D1        *Else Check for 101 to eliminate RTS
    BEQ     _RTS            *If equal, branch to RTS
    
    BRA     _MOVEM          *Else by process of elimination it must be MOVEM    
    
********* CLR *************        
_CLR
    LEA     OPCLR,(A1)+     *Load "CLR" to Add Reg 1 and then increment
    BRA     EA_CLR          *Branch to EA analysis of the command
OPCLR     DC.B    "CLR"

********* LEA *************        
_LEA
    LEA     OPLEA,(A1)+     *Load "LEA" to Add Reg 1 and then increment
    BRA     EA_LEA          *Branch to EA analysis of the command
OPLEA     DC.B    "LEA"

********* JSR *************     
_JSR
    LEA     OPJSR,(A1)+     *Load "JSR" to Add Reg 1 and then increment
    BRA     EA_JSR          *Branch to EA analysis of the command
OPJSR     DC.B    "JSR"

********* NOP *************     
_NOP
    LEA     OPNOP,(A1)+     *Load "NOP" to Add Reg 1 and then increment    
    BRA     EA_NOP          *Branch to EA analysis of the command
OPNOP     DC.B    "NOP"

********* RTS *************     
_RTS
    LEA     OPRTS,(A1)+     *Load "RTS" to Add Reg 1 and then increment
    BRA     EA_RTS          *Branch to EA analysis of the command
OPRTS     DC.B    "RTS"

********* MOVEM *************     
_MOVEM
    LEA     MOVEM,(A1)+     *Load "MOVEM" to Add Reg 1 and then increment
    BRA     EA_MOVEM        *Branch to EA analysis of the command
MOVEM     DC.B    "MOVEM"
    
**************************************************************************
*        OP0101 - Subroutine for operations beginning with 0101          *
*        ADDQ                                                            *
**************************************************************************
OP0101
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    LEA     ADDQ,(A1)+      *Load "AddQ" to Add Reg 1 and then increment
    BRA     EA_ADDQ         *Branch to EA analysis of the command
    
ADDQ   DC.B    "ADDQ"
    
**************************************************************************
*        OP0110 - Subroutine for operations beginning with 0110          *
*        Bcc                                                             ***********MIGHT NEED MORE, Bcc is weird****
**************************************************************************
OP0110
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    LEA     Bcc,(A1)+       *Load "Bcc" to Add Reg 1 and then increment
    BRA     EA_Bcc          *Branch to EA analysis of the command
    
Bcc  DC.B    "Bcc"

**************************************************************************
*        OP0111 - Subroutine for operations beginning with 0101          *
*        MOVEQ                                                           *
**************************************************************************
OP0101
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    LEA     MOVEQ,(A1)+     *Load "MOVEQ" to Add Reg 1 and then increment
    BRA     EA_MOVEQ        *Branch to EA analysis of the command
    
MOVEQ   DC.B    "MOVEQ"
    
**************************************************************************
*        OP1000 - Subroutine for operations beginning with 1000          *
*        DIVU, OR                                                        *
**************************************************************************
OP1000
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS           
    CMP     #%011,D1X    *Check for 011 to eliminate DIVU
    BEQ     _DIVU        *If equal, branch to DIVU
    BRA     _OR          *Else must be OR, branch
    
********* DIVU *************        
_DIVU
    LEA     DIVU,(A1)+      *Load "DIVU" to Add Reg 1 and then increment
    BRA     EA_DIVU         *Branch to EA analysis of the command
DIVU     DC.B    "DIVU"

********* OR *************        
_OR
    LEA     OR,(A1)+        *Load "OR" to Add Reg 1 and then increment
    BRA     EA_OR           *Branch to EA analysis of the command
OR       DC.B    "OR"

**************************************************************************
*        OP1001 - Subroutine for operations beginning with 1001          *
*        SUB                                                             *
**************************************************************************
OP1001
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    
    LEA     SUB,(AXXX)+     *Load "SUB" to Add Reg 1 and then increment
    BRA     EA_SUB          *Branch to EA analysis of the command

SUB     DC.B    "SUB"

**************************************************************************
*        OP1011 - Subroutine for operations beginning with 1011          *
*        CMP                                                             *
**************************************************************************
OP1011
    *SINGLE CODE, DO NOT NEED FURTHER CHECKING
    *BEGIN OUTPUT
    LEA     CMP,(AXXX)+     *Load "CMP" to Add Reg 1 and then increment
    BRA     EA_CMP          *Branch to EA analysis of the command

CMP     DC.B    "CMP"

**************************************************************************
*        OP1100 - Subroutine for operations beginning with 1100          *
*        MULS, AND                                                       *
**************************************************************************
OP1100
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
 
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS          
    CMP     #%111,D1X       *Check for 111 to eliminate MULS
    BEQ     _MULS           *If equal, branch to MULS
    BRA     _AND            *Else must be AND, branch
    
********* MULS *************        
_MULS
    LEA     MULS,(A1)+      *Load "MULS" to Add Reg 1 and then increment
    BRA     EA_MULS         *Branch to EA analysis of the command
MULS     DC.B    "MULS"

********* AND *************        
_AND
    LEA     AND,(A1)+       *Load "AND" to Add Reg 1 and then increment
    BRA     EA_AND          *Branch to EA analysis of the command
AND       DC.B    "AND"
    
**************************************************************************
*        OP1101 - Subroutine for operations beginning with 1101          *
*        ADD, ADDA                                                       *
**************************************************************************
OP1101
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS  
    
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 2/4 as both contain Xn in 1/4
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS             
    CMP     #%011,D1X       *Check for 011 to eliminate ADDA (Size dependant)
    BEQ     _ADDA           *If equal, branch to ADDA
    CMP     #%111,D1        *Else check for 111 to eliminate ADDA (Size dependant)
    BEQ     _ADDA           *If equal, branch to ADDA
    BRA     _AND            *Else must be AND, branch
    
********* ADD *************        
_ADD
    LEA     ADD,(A1)+       *Load "ADD" to Add Reg 1 and then increment
    BRA     EA_ADD          *Branch to EA analysis of the command
ADD     DC.B    "ADD"

********* AND *************        
_ADDA
    LEA     ADDA,(A1)+      *Load "ADDA" to Add Reg 1 and then increment
    BRA     EA_ADDA         *Branch to EA analysis of the command
ADDA      DC.B    "ADDA" 
    
**************************************************************************
*        OP1110 - Subroutine for operations beginning with 1110          *
*        LSR, LSL, ASR, ASL, ROL, ROR                                    *
**************************************************************************
OP1110
    *MULTIPLE CODE, CHECK AND GET NEXT 3 BITS
    
    **ISOLATE NEXT BITS TO CHECK**    
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

                  
    CMP     #%001,D1X       *Check for 001 to eliminate LSd instructions
    BEQ     _LSd            *If equal, branch to LSd to determine LSR or LSL
    BRA     1110_1
    
1110_1
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4 has been checked and 2/4 is ambiguous
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits
    
    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS                   
    CMP     #%000,D1X       *Check for 000 to eliminate ASd (Rotation dependant)
    BEQ     _ASd            *If equal, branch to ASd to determine ASR or ASL
    CMP     #%100,D1X       *Check for 100 to eliminate ASd (Rotation dependant)
    BEQ     _ASd            *If equal, branch to ASd to determine ASR or ASL
    BRA     ROd             *Else must be a ROd instruction, branch to determine
    
********* LSd *************        
_LSd    
    **ISOLATE NEXT BITS TO CHECK**  
    **Look to 2/4 as 1/4 has been checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS          
    CMP     #%011,D1        *Check for 011 to eliminate LSR
    BEQ     _LSR            *If equal, branch to LSR
    BRA     _LSL            *Else must be LSL, branch

_LSL    
    LEA     LSL,(A1)+       *Load "LSL" to Add Reg 1 and then increment
    BRA     EA_LSL          *Branch to EA analysis of the command
LSL     DC.B    "LSL"

_LSR
    LEA     LSR,(A1)+       *Load "LSR" to Add Reg 1 and then increment
    BRA     EA_LSR          *Branch to EA analysis of the command
LSR     DC.B    "LSR"

********* ASd *************
_ASd
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4,2/4 already checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (3/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS       
    CMP     #%000,D1        *Check for 000 to eliminate ASR
    BEQ     _ASR            *If equal, branch to ASR
    BRA     _ASL            *Else must be ASL, branch

_ASL    
    LEA     ASL,(A1)+       *Load "ASL" to Add Reg 1 and then increment
    BRA     EA_ASL          *Branch to EA analysis of the command
ASL     DC.B    "ASL"

_ASR
    LEA     ASR,(A1)+       *Load "ASR" to Add Reg 1 and then increment
    BRA     EA_ASR          *Branch to EA analysis of the command
ASR     DC.B    "ASR"

********* ROd *************
_ROd
    **ISOLATE NEXT BITS TO CHECK**
    **Look to 3/4 as 1/4,2/4 already checked
    MOVE.W  D0,D1           *Copy instruction for modification
    LSL.W   #4,D1           *Shift left to grab 3 bits (1/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (2/4 "chunks")
    LSL.W   #4,D1           *Shift left to grab 3 bits (3/4 "chunks")
    LSR.W   #4,D1           *Rotate left four bits
    LSR.W   #8,D1           *Shift left again (12 shifts total)
    ANDI.W  #$00F,D1        *Keep only three bits

    **BEGIN ELIMINATION "IF/ELSE" STATEMENTS   
    CMP     #%011,D1        *Check for 011 to eliminate ROR
    BEQ     _ROR            *If equal, branch to ROR
    BRA     _ROL            *Else must be ROL, branch
    
_ROL    
    LEA     ROL,(A1)+       *Load "ROL" to Add Reg 1 and then increment
    BRA     EA_ROL          *Branch to EA analysis of the command
ROL     DC.B    "ROL"

_ROR
    LEA     ROR,(A1)+       *Load "ROR" to Add Reg 1 and then increment
    BRA     EA_ROR          *Branch to EA analysis of the command
ROR     DC.B    "ROR"







**************************************************************************
*                          GET4                                          *
*                Reference code for get 4 bits                           *
**************************************************************************
*
*    MOVE.W  D0,D1   *Copy instruction for modification
*    LSR.W   #4,D1       *Shift left four bits
*    LSR.W   #8,D1       *Shift left again (12 shifts total)
*    ANDI.W  #$000F,D1   *Keep only four bits



***************************************************************************
**                         GET3                                           *
**                Reference code for get 3 bits                           *
***************************************************************************

*    MOVE.W  D0,D1    *Copy instruction for modification
*    LSL.W   #4,D1    *Shift left to grab 3 bits (1/4 "chunks")
*    LSR.W   #4,D1    *Rotate left four bits
*    LSR.W   #8,D1      *Shift left again (12 shifts total)
*    ANDI.W  #$00F,D1   *Keep only three bits




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
