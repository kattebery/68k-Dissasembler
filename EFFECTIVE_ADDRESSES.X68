*-----------------------------------------------------------
* Title      : EFFECTIVE_ADDRESSES
* Written by : JOHN ZOELLER
* Date       : 5/24/16
* Description: ALL THE EFFECTIVE ADDRESSES
*-----------------------------------------------------------
    ORG    $1000
START:
    *EXAMPLE, MOVE A HEX CODE INTO D6
    *CALL THE CORRESPONDING EA CODE
    MOVE.W     #$2E7C, D6
    JSR         EA_MOVE
    BRA         BYEBYE
    *END EXAMPLE
*-------------------------MOVE------------------------------------
EA_MOVE      
*----------------SOURCE-------------------------------------------  
    MOVE.W      D6, D4      *
    LSR.W       #8, D4      *
    LSR.W       #4, D4      *D4 = SIZE
    JSR GET_SIZE
    
    MOVE.W      D6, D4      *
    LSL.W       #8, D4      *
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = <0000 0000> D4 = SOURCE MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*---------------END SOURCE---------------------------------------
    JSR COMMA
    JSR SPACE
*--------------DESTINATION-------------------------------------
    MOVE.W      D6, D4      *
    LSL.W       #7, D4      *
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = DESTINATION MODE
    JSR         MOVE_ERROR_CHECK
    
    MOVE.W      D6, D5      *
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*------------END DESTINATION-------------------------------------
    RTS
*-------------------------END MOVE--------------------------------
*------------------------------------------------------------------
*-------------------------MOVEA-----------------------------------
EA_MOVEA
*------------------------SOURCE----------------------------------------
    MOVE.W      D6, D4      *GETTING SIZE
    LSR.W       #8, D4      *
    LSR.W       #4, D4      *SHIFT 12 BITS RIGHT
    JSR         GET_SIZE    *D4 = SIZE
    
    MOVE.W      D6, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE

    MOVE.W      D6, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUMP
*--------------------END SOURCE------------------------------------------
    JSR         COMMA
    JSR         SPACE
*--------------------DESTINATION--------------------------------------
    MOVE.W      D6, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    RTS
*------------------END DESTINATION--------------------------------------
*------------------------END MOVEA------------------------------
*----------------------------------------------------------------
*-----------------------MOVEQ---------------------------------------
EA_MOVEQ
*-----------------------SOURCE-----------------------------------------
    JSR SPACE
    JSR POUND
    JSR CASH
    BSR OUTPUT_HEX    
*----------------------END SOURCE--------------------------------------
    JSR COMMA
    JSR SPACE
*---------------------DESTINATION------------------------------------
    MOVE.W      D6, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      * D5 = DESTINATION REGISTER
    
    JSR         DATA_0
    RTS
*----------------------END MOVEQ--------------------------------
*---------------------------------------------------------------
*------------------------ADD------------------------------------
EA_ADD
*COVERS ADD, SUB, AND, OR
*--------------------GET MODES-----------------------------
    MOVE.W      D6, D4      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D4      * 
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = OPMODE AKA SIZE
    JSR         GET_OPMODE_MATH *PRINTS THE SIZE

    CMP.B       #3, D4
    BLT         DN_VERSION
    CMP.B       #3, D4
    BGT         EA_VERSION
    RTS
*-------------------END GETS MODES------------------------------
*-------------------DN VERSION------------------------
DN_VERSION *EA IS SOURCE, REGISTER IS DESTINATION <EA> + DN -> DN
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
        
    JSR         COMMA
    JSR         SPACE
    
    MOVE.W      D6, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    RTS
*-------------------END DN VERSION-------------------
*-------------------EA VERSION-------------------------
EA_VERSION
    MOVE.W      D6, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    JSR         DATA_0
    
    JSR         COMMA
    JSR         SPACE
    
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG 
    JSR         ADD_ERROR_CHECK
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    RTS
*------------------END EA VERSION----------------------
*--------------------END ADD----------------------------
*------------------------------------------------------
*-------------------ADDI--------------------------------
EA_ADDI
*-------------------PRINT SIZE-----------------------------------
    MOVE.W      D6, D4      *
    LSL.W       #8, D4      *
    LSR.W       #8, D4      *
    LSR.W       #6, D4      *D4 = SIZE
    JSR         GET_SIZE_ADDI
*-----------------END PRINT SIZE-----------------------------
*----------------PRINT IMMEDIATE----------------------------
    JSR         POUND
    JSR         CASH
    BSR         OUTPUT_HEX
*-------------END PRINT IMMEDIATE-----------------------------
    JSR         COMMA
    JSR         SPACE
*-----------------PRINT EA------------------------------------
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP'
    RTS
*-------------------END PRINT EA--------------------------
*-------------------END ADDI------------------------------
*----------------------------------------------------------
*------------------------ADDQ----------------------------------
EA_ADDQ
*-----------------------SOURCE------------------------------------
    MOVE.W      D6, D4
    LSL.W       #8, D4
    LSR.W       #8, D4
    LSR.W       #6, D4
    JSR         GET_SIZE_ADDI    *PRINT SIZE
    
    MOVE.W      D6, D5      *GETTING DATA
    LSL.W       #4, D5      *SHIFT LEFT 4; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DATA
    JSR         GET_DATA
*--------------------END SOURCE-------------------------------------
    JSR COMMA
    JSR SPACE
*-------------------PRINT EA-----------------------------------
    MOVE.W      D6, D4      *GETTING EA MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *GETTING EA REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = EA REGISTER
    
    JSR         MODE_CHOOSER
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    RTS
*-------------------END PRINT EA-------------------------------
*----------------------END ADDQ---------------------------------
*--------------------------------------------------------------
*-------------------------ADDA------------------------------------
EA_ADDA
*-----------------------SOURCE------------------------------
    MOVE.W      D6, D4      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D4      * 
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = OPMODE AKA SIZE
    JSR         GET_OPMODE
    
    MOVE.W      D6, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D6, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUMP
*-----------------------END SOURCE--------------------------
    JSR COMMA 
    JSR SPACE
*-----------------------DESTINATION-------------------------
    MOVE.W      D6, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    RTS
*-----------------------END DESTINATION---------------------
*-------------------------END ADDA--------------------------------
*---------------------------------------------------------------
*------------------------------MULS--------------------------------
MULS_EA 
*COVERS DIVU, MULS
*----------------------PRINT EA-------------------------
    JSR         SPACE
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*--------------------END PRINT EA----------------------
    JSR         COMMA
    JSR         SPACE
*--------------------PRINT REGISTER--------------------
    MOVE.W      D6, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    RTS
*---------------------------END MULS------------------------------
*----------------------------------------------------------------
*-------------------------LEA-----------------------------------
LEA_EA
*-------------------SOURCE-------------------------------------
    JSR         SPACE
    MOVE.W      D6, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D6, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUMP
*-------------------END SOURCE---------------------------------
    JSR COMMA
    JSR SPACE
*-------------------DESTINATION-------------------------------
    MOVE.W      D6, D5      *GET THE DESTINATION REGISTER
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *SHIFT 4 BITS LEFT; 13 RIGHT
    LSR.W       #5, D5      *D5 = DESTINATION REGISTER
    
    JSR         ADDR_1
    RTS
*-----------------END DESTINATION-----------------------------
*------------------------END LEA--------------------------------
*-----------------------------------------------------------------
*------------------------CLR-------------------------------------
CLR_EA 
*-------------------PRINT SIZE-----------------------
    MOVE.W      D6, D4
    LSL.W       #8, D4      *
    LSR.W       #8, D4      *
    LSR.W       #6, D4      *D4 = SIZE
    JSR         GET_SIZE_ADDI
*----------------END PRINT SIZE-------------------------
*---------------PRINT EA---------------------------------
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    RTS
*---------------END PRINT EA-------------------------
*------------------------END CLR--------------------------------
*----------------------------------------------------------------
*--------------------------SHIFTS------------------------------
LSD_EA
*COVERS LSD, ASD, ROD
*-------------------------SIZE---------------------------
    MOVE.W      D6, D4
    LSL.W       #8, D4
    LSR.W       #8, D4
    LSR.W       #6, D4      *ISOLATE SIZE
    JSR         GET_SIZE_ADDI  *PRINT SIZE
    CMP.B       #3, D4      *EA SHIFT
    BEQ         EA_SHIFT    *BRANCH TO EA SHIFT
*-----------------------END SIZE--------------------------
*-----------------------SHIFTING------------------------------
    MOVE.W      D6, D4
    LSL.W       #8, D4
    LSL.W       #2, D4
    LSR.W       #8, D4
    LSR.W       #7, D4      *D4 = TYPE
    
    MOVE.W      D6, D5      *GETTING DATA
    LSL.W       #4, D5      *SHIFT LEFT 4; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = DATA / REGISTER
    
    JSR         TYPE_CHOOSER
*-----------------------END SHIFTING---------------------------
    JSR         COMMA
    JSR         SPACE
*----------------------DESTINATION------------------------------
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    JSR         DATA_0
    RTS
*----------------------END DESTINATION-------------------------    
*---------------------------EA SHIFT-------------------------------
EA_SHIFT
    JSR         SPACE
    MOVE.W      D6, D4      *
    LSL.W       #8, D4      *
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
    BRA         DONE
*-------------------------END EA SHIFT------------------------------
DONE
    RTS

*----------------------------END SHIFTS---------------------------
*---------------------------------------------------------------
*-------------------------------CMP-----------------------------
CMP_EA
*------------------PRINT SIZE----------------------------
    MOVE.W      D6, D4      *GETTING OPMODE AKA SIZE
    LSL.W       #7, D4      * 
    LSR.W       #7, D4      *
    LSR.W       #6, D4      *D4 = OPMODE AKA SIZE
    JSR         GET_SIZE_ADDI
*---------------END PRINT SIZE-------------------------
*------------------PRINT EA---------------------------
    MOVE.W      D6, D4      
    LSL.W       #8, D4      *LEFT 10; RIGHT 13
    LSL.W       #2, D4
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = EA MODE
    
    MOVE.W      D6, D5      *SHIFT LEFT 13; RIGHT 13
    LSL.W       #8, D5  
    LSL.W       #5, D5      *
    LSR.W       #8, D5
    LSR.W       #5, D5      * D5 = EA REGISTER
    
    JSR         MODE_CHOOSER    *IF A WORD OR LONG    
    LEA         MODE_JUMP, A0   *LOAD MODE JUMP TABLE
    MULS        #6, D4          *GET JUMP
    JSR         0(A0, D4)       *JUMP
*-----------------END PRINT EA-------------------------
    JSR         COMMA
    JSR         SPACE
*----------------PRINT REG----------------------------
    MOVE.W      D6, D5      *LEFT 4; RIGHT 13
    LSL.W       #4, D5      *
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 DESTINATION REGISTER
    
    JSR         DATA_0
    RTS
*--------------END PRINT REG---------------------------
*------------------------------END CMP----------------------------
*-----------------------------------------------------------------
*--------------------------------BCC------------------------------
BCC_EA
*--------------------PRINT TYPE------------------------
    MOVE.W      D6, D4
    LSL.W       #4, D4
    LSR.W       #8, D4
    LSR.W       #4, D4   *D4 = BINARY CONDITION CODE
    JSR         PRINT_BCC
*-------------------END PRINT TYPE---------------------
    JSR         SPACE
*------------------PRINT ADDRESS OR SOMETHING---------
    JSR         OUTPUT_HEX
    RTS
*-------------END PRINT ADDRESS OR SOMETHING-------------
*-----------------------------END BCC-------------------------------
*-------------------------------------------------------------------
*---------------------------JSR---------------------------------------
JSR_EA
    JSR         SPACE
    MOVE.W      D6, D4      *GETTING SOURCE MODE
    LSL.W       #8, D4      *
    LSL.W       #2, D4      *SHIFT 10 BITS LEFT; 13 RIGHT
    LSR.W       #8, D4      *
    LSR.W       #5, D4      *D4 = SOURCE MODE
    
    MOVE.W      D6, D5      *GETTING SOURCE REGISTER
    LSL.W       #8, D5      *
    LSL.W       #5, D5      *SHIFT LEFT 13; RIGHT 13
    LSR.W       #8, D5      *
    LSR.W       #5, D5      *D5 = SOURCE REGISTER
    
    JSR         MODE_CHOOSER  *INCASE MODE IS $111
    LEA         MODE_JUMP, A0 *LOAD MODE JUMP TABLE
    MULS        #6, D4        *GET JUMP
    JSR         0(A0, D4)     *JUM
    RTS
*---------------------------END JSR----------------------------------
*-----------------------------------------------------------------














BYEBYE
    SIMHALT















*-------------------ERROR CHECK--------------------------------
MOVE_ERROR_CHECK
    CMP.B       #1, D4
    BEQ         INVALID
    RTS
    
ADD_ERROR_CHECK
    CMP.B       #7, D4
    BEQ         INVALID 
    RTS   
    
*-----------------END ERROR CHECK-------------------------------
*-----------------START MODE JUMP-----------------------------------
MODE_JUMP       JMP     DATA_0
                JMP     ADDR_1
                JMP     ADDI_2
                JMP     ADDP_3
                JMP     ADDM_4
                JMP     ABSW_5
                JMP     ABSL_6
                JMP     IMME_7

DATA_0 *DONE
    LEA         M_DREG, A1
    MOVE        #14, D0
    TRAP        #15
    JSR         GET_REG
    RTS

ADDR_1 *ADD CONDITIONS FOR SOURCE ONLY, AND NEVER BYTES
    LEA         M_AREG, A1
    MOVE        #14, D0
    TRAP        #15
    JSR         GET_REG
    RTS
 
ADDI_2 *DONE
    JSR         OPEN
    JSR         ADDR_1
    JSR         CLOSE
    RTS
    
ADDP_3 *DONE
    JSR         ADDI_2
    JSR         PLUS
    RTS
    
ADDM_4 *DONE
    JSR         SUB
    JSR         ADDI_2
    RTS
    
ABSW_5  *DONE
    JSR         CASH
    BSR         OUTPUT_HEX
    RTS

 
ABSL_6 *
    JSR         CASH
    MOVE.W      #$0FFF, D2 *GET PART 1 EXAMPLE VALUES
    BSR         OUTPUT_HEX
    MOVE.W      #$AB57, D2 *GET PART 2
    BSR         OUTPUT_HEX
    RTS
    
IMME_7  *FOR NOW ONLY WORKING WITH IMMEDIATE HEX VALUES
    JSR         POUND
    MOVE.W      #$9999, D2  *GET PART 1 EXAMPLE VALUE
    BSR         OUTPUT_HEX
    MOVE.W      #$AB57, D2  *GET PART 2
    BSR         OUTPUT_HEX
    RTS

*-------------------------END MODE JUMP----------------------------  
*-------------------------START HELPERS-----------------------------
GET_SIZE
    JSR         DOT
    CMP.B       #1, D4
    BEQ         BYTE
    CMP.B       #3, D4
    BEQ         WORD
    CMP.B       #2, D4
    BEQ         LONG  
    RTS
    
GET_REG
    MOVE.L      D5, D1 
    MOVE        #3, D0
    TRAP        #15
    RTS
    
GET_OPMODE
    JSR         DOT
    CMP.B       #3, D4
    BEQ         WORD
    CMP.B       #7, D4
    BEQ         LONG
    RTS
    
GET_OPMODE_MATH
    JSR         DOT
    CMP.B       #0, D4
    BEQ         BYTE
    CMP.B       #4, D4
    BEQ         BYTE
    CMP.B       #1, D4
    BEQ         WORD
    CMP.B       #5, D4
    BEQ         WORD
    CMP.B       #2, D4
    BEQ         LONG
    CMP.B       #6, D4
    BEQ         LONG
    RTS
    
GET_DATA
    JSR         POUND
    CMP.B       #0, D5
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
    
GET_SIZE_ADDI
    JSR         DOT
    CMP.B       #0, D4
    BEQ         BYTE
    CMP.B       #1, D4
    BEQ         WORD
    CMP.B       #2, D4
    BEQ         LONG  
    RTS
    
TYPE_CHOOSER
    CMP.B       #0, D4      *IF IMMEDIATE
    BEQ         GET_DATA    *IF BRANCHED  ->  #1 IS NOW PRINTED
    CMP.B       #1, D4      *IF A DATA REG
    BEQ         DATA_0
    RTS
    
PRINT_BCC
    CMP.B       #4, D4
    BEQ         CC
    CMP.B       #14, D4
    BEQ         GT
    CMP.B       #15, D4
    BEQ         LE
    RTS
*-------------------------END HELPERS----------------------------
*---------------------START CHANGE MODE--------------------------
MODE_CHOOSER
    CMP.B       #7, D4
    BEQ         NEW_MODE
    RTS
    
NEW_MODE
    CMP.B       #0, D5 *CHECK REGISTER(D5), WORD ADDRESS?
    BEQ         TO_FIVE *CHANGE MODE (D4) TO 5
    CMP.B       #1, D5 *CHECK REGISTER(D5), LONG ADDRESS?
    BEQ         TO_SIX *CHANGE MODE(D4) TO 6
    RTS
    
TO_SIX  
    SUB.B      #1, D4
    RTS

TO_FIVE
    SUB.B      #2, D4
    RTS
*---------------------------END CHANGE MODE-----------------------
*--------------------------START PRINT HEX------------------------

OUTPUT_HEX
    *OUTPUT 1ST
    MOVE.W      D2, D7              *D7 = <1010 1111 0101 0111>
    LSR.W       #8, D7              *D7 = <0000 0000 1010 1111>
    LSR.W       #4, D7              *D7 = <0000 0000 0000 1010>
    MOVE.B      D7, D1
    BSR         CONVERT_TO_ASCII    *convert value in D1, to ascii
    BSR         OUTPUT_CHAR         *print the char in D1  
    *OUTPUT 2ND
    MOVE.W      D2, D7
    LSL.W       #4, D7              *SHIFT OUT FURTHEST RIGHT BIT
    LSR.W       #8, D7
    LSR.W       #4, D7  
    MOVE.B      D7, D1
    BSR         CONVERT_TO_ASCII
    BSR         OUTPUT_CHAR
    *OUTPUT 3RD
    MOVE.W      D2, D7
    LSL.W       #8, D7
    LSR.W       #8, D7
    LSR.W       #4, D7
    MOVE.B      D7, D1
    BSR         CONVERT_TO_ASCII
    BSR         OUTPUT_CHAR
    *OUTPUT 4TH
    MOVE.W      D2, D7  *D7 = <1010 1111 0101 0111>
    LSL.W       #8, D7  *     <0101 0111 0000 0000>
    LSL.W       #4, D7  *     <0111 0000 0000 0000>
    LSR.W       #8, D7  *     <
    LSR.W       #4, D7
    MOVE.B      D7, D1
    BSR         CONVERT_TO_ASCII
    BSR         OUTPUT_CHAR
    RTS

CONVERT_TO_ASCII
    CMP.B       #9,D1           *compare value with 9
    BGT         ALPH_CHAR       *convert to numeric ascii
    BRA         NUMERIC_CHAR    *convert to alphabetical ascii
NUMERIC_CHAR        
    ADD.B       #48,D1          *convert to ascii value
    RTS                         *continue converting
ALPH_CHAR
    ADD.B       #55,D1          *convert to ascii value
    RTS
                                   *continue converting            
OUTPUT_CHAR
    MOVE.B      #6,D0           *output whatever's in D1
    TRAP        #15
    RTS

*---------------------------END PRINT HEX------------------------
*---------------------------START CHARACTERS---------------------------
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
    JSR         SPACE
    RTS

BYTE
    LEA         M_BYTE, A1
    MOVE        #14, D0
    TRAP        #15
    JSR         SPACE
    RTS
    
LONG
    LEA         M_LONG, A1
    MOVE        #14, D0
    TRAP        #15
    JSR         SPACE
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
    
SPACE
    LEA         M_SPACE, A1
    MOVE        #14, D0
    TRAP        #15
    RTS    
    
CASH
    LEA         M_CASH, A1
    MOVE        #14, D0
    TRAP        #15
    RTS

CC
    LEA         M_CC, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
GT
    LEA         M_GT, A1
    MOVE        #14, D0
    TRAP        #15
    RTS

LE
    LEA         M_LE, A1
    MOVE        #14, D0
    TRAP        #15
    RTS
    
INVALID
    LEA         M_INVAL, A1
    MOVE        #14, D0
    TRAP        #15
*----------------------------END CHARACTERS---------------------------        

CR      EQU     $0D
LF      EQU     $0A

M_INVAL DC.B 'INVALID',0
M_CASH  DC.B '$',0
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
M_CC    DC.B 'CC',0
M_GT    DC.B 'GT',0
M_LE    DC.B 'LE',0

    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
