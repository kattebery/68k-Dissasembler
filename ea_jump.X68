*----------------------------------------------------------------------*
* Title      :  ea jump tables
* Written by :  john, blake, kristen
* Date       :  5/17/16
* Description:  jump tables for ea's
*----------------------------------------------------------------------*

    ORG     $1000
START:

EA_JUMP
    BRA     ADDQ_JUMP

    
*ASSUMING THAT THE WORD ADDQ HAS BEEN PRINTED
*-----------------------------------------------------------------------*
ADDQ_JUMP   *EXAMPLE: ADDQ.W  #1, (A6)     AUT* DAT * SZ EAM EAR
            *                              0101 001 0 01 010 110  ->5256
      
      
    MOVE.W      #$5256, D6  *D6 = <00005246> *SIMULATING ADDQ.W #1, (A6)
    MOVE.W      D6, D5      
    LSL.W       #4, D5      *D5 = <00002460> *GOT RID OF LEFT 4 BITS
    LSR.W       #8, D5      *D5 = <00000024> *GOT RID OF RIGHT 8
    LSR.W       #5, D5      *D5 = <0000000 1> GOT RID OF RIGHT 5
    *D5 NOW HOLDS DAT
    
    MOVE.B      D6, D4      *D4 = <000000 46> ONLY LAST BYTE OF D6
    LSR.B       #6, D4      *D4 = <0000000 1> GOT RID OF RIGHT 6
    *D4 NOW HOLDS SIZE IN ITS LAST BYTE (BYTE, WORD, LONG)
    
    MOVE.B      D6, D3      *D3 = <000000 46>
    LSL.B       #2, D3      *D3 = <000000 18>
    LSR.B       #5, D3      *D3 = <0000000 0> 
    *D3 NOW HOLDS MODE IN ITS LAST BYTE
    
    LSL.B       #5, D6      *D6 = <000000 C0>
    LSR.B       #5, D6      *D6 = <000000 06>
    *D6 NOW HOLDS REGISTER IN ITS LAST BYTE
    
    JSR GET_SIZE
    JSR SPACE
    JSR POUND
    JSR GET_DATA
    JSR COMMA
    JSR SPACE

    *for now this works, albeit only with data registers
        *.... i need to implement a mode choosing thing
    *subroutine that determines mode 
        *...and get reg needs to go inside the dreg thing
    
    *JSR DREG  -> WORKS
    *JSR AREG  -> WORKS
    JSR AIND   
    
   SIMHALT

GET_REG
    MOVE.B      D6, D1
    MOVE        #3, D0
    TRAP        #15
    RTS
    
GET_DATA
    CMP.B       #$0, D5
    BEQ         PRINT_8
    MOVE.L      D5, D1
    MOVE        #3, D0
    TRAP        #15
    RTS
    
PRINT_8
    MOVE.L      #8, D1
    MOVE        #3, D0
    TRAP        #15
    RTS
     
GET_SIZE
    JSR         DOT
    CMP.B       #00, D4
    BEQ         BYTE
    CMP.B       #01, D4
    BEQ         WORD
    CMP.B       #10, D4
    BEQ         LONG
    
COMMA
    LEA         M_COMMA, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
    
POUND
    LEA         M_POUND, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
        
DOT
    LEA         M_DOT, A1
    MOVE        #14, D0
    TRAP        #15 
    RTS   

WORD
    LEA         M_WORD, A1
    MOVE        #14, D0
    TRAP        #15
    RTS

BYTE
    LEA         M_BYTE, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
    
LONG
    LEA         M_LONG, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
    
OPEN
    LEA         M_OPEN, A1
    MOVE        #14, D0
    TRAP        #15
    RTS

CLOSE
    LEA         M_CLOSE, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
    
PLUS
    LEA         M_PLUS, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
    
SUB
    LEA         M_SUB, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
    
DREG
    LEA         M_DREG, A1
    MOVE        #14, D0
    TRAP        #15
    JSR GET_REG
    RTS
    
AREG
    LEA         M_AREG, A1
    MOVE        #14, D0
    TRAP        #15
    JSR GET_REG
    RTS
    
AIND
    JSR OPEN
    JSR AREG
    JSR CLOSE
    RTS
           
SPACE
    LEA         M_SPACE, A1
    MOVE        #14, D0
    TRAP        #15
    RTS

    
CR      EQU     $0D
LF      EQU     $0A

M_SPACE DC.B ' ',0
M_COMMA DC.B ',',0
M_POUND DC.B '#',0
M_DOT   DC.B '.',0
M_WORD  DC.B 'W',0
M_BYTE  DC.B 'B',0
M_LONG  DC.B 'L',0
M_OPEN  DC.B '(',0
M_CLOSE DC.B ')',0
M_PLUS  DC.B '+',0
M_SUB   DC.B '-',0
M_DREG  DC.B 'D',0
M_AREG  DC.B 'A',0
    
    END     START
    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
