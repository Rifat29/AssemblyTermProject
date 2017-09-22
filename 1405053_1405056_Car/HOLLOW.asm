.MODEL SMALL

.STACK 100H

.DATA

P1_X DW ?
P1_Y DW ?
P2_X DW ?
P2_Y DW ?
LVAR DW ?
TIMER_FLAG DB 0
NEW_TIMER_VEC   DW  ?,?
OLD_TIMER_VEC   DW  ?,?
SCORE_MSG DB 'SCORE:$'
IS_GAME_OVER DW 0
COL1_X DW 81
COL1_Y DW -40
COL2_X DW 146
COL2_Y DW -140
COL3_X DW 211
COL3_Y DW -250
USER_X DW 81
USER_Y DW 170
COLOUR DB 4
SCORE  DB 0
TEXT_ROW DB ?
TEXT_COL DB ?
TEXT_LENGTH DW ?
TEXT_COLOUR DB 2
INT_ROW DB ?
INT_COL DB ?
INT_LENGTH DW ?
INT_COLOUR DB 2
INT_TO_DISPLAY DB ?
GAME_OVER_MSG  DB 'GAME OVER$'
HIGH_SCORE_MSG DB 'HIGH SCORE:$'
HIGH_SCORE DB 0
FILE_NAME DB 'HIGHSCORE.TXT',0
BUFFER DB ?
HANDLE DW ?
CONGRATULATIONS_MSG DB 'CONGRATULATIONS$'
NEW_HIGH_SCORE_MSG DB 'NEW HIGH SCORE:$'
COUNT DB 0
SPEED DW 3
SPEED_MSG DB 'SPEED:$'

.CODE

MAIN PROC
    
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    
    CALL READ_FILE
    
    MOV AH, 0
    MOV AL, 13H                             ; 320X200 4 COLOR
    INT 10H
    
    MOV BH, 0
    MOV BL, 0                               ; BLACK
    INT 10H
    
    CALL BUILD_ROAD
    
    MOV NEW_TIMER_VEC, OFFSET TIMER_TICK
    MOV NEW_TIMER_VEC+2, CS
    MOV AL, 1CH                             ; INTERRUPT TYPE
    LEA DI, OLD_TIMER_VEC
    LEA SI, NEW_TIMER_VEC
    CALL SETUP_INT
    
    CALL USER_CAR
    
    TT:
    
        CMP TIMER_FLAG, 1
        JNE TT
        MOV TIMER_FLAG, 0
       
        CALL MOVE_CAR
        CALL MOVE_USER_CAR
        CALL COLLISION
        
        CMP IS_GAME_OVER,1
        JE GAME_OVER
    
    TT2:
    
        CMP TIMER_FLAG, 1
        JNE TT2
        MOV TIMER_FLAG, 0
        JMP TT
    
    GAME_OVER:
    
        CALL SCORE_GAME
        
        MOV AH,4CH
        INT 21H
        
        RET
    
MAIN ENDP

BUILD_ROAD PROC

    BOUNDARY1:
        
        MOV COLOUR,4
        
        MOV P1_X,62
        MOV P1_Y,0
        MOV P2_X,62
        MOV P2_Y,200
        CALL DRAW_COLUMN
        
        MOV P1_X,63
        MOV P1_Y,0
        MOV P2_X,63
        MOV P2_Y,200
        CALL DRAW_COLUMN
        
        MOV P1_X,64
        MOV P1_Y,0
        MOV P2_X,64
        MOV P2_Y,200
        CALL DRAW_COLUMN
        
    LANE1:

        MOV P1_X,129
        MOV P1_Y,0
        MOV P2_X,129
        MOV P2_Y,42
        CALL DRAW_COLUMN
        
        MOV P1_X,129
        MOV P1_Y,52
        MOV P2_X,129
        MOV P2_Y,94
        CALL DRAW_COLUMN
        
        MOV P1_X,129
        MOV P1_Y,104
        MOV P2_X,129
        MOV P2_Y,146
        CALL DRAW_COLUMN
        
        MOV P1_X,129
        MOV P1_Y,156
        MOV P2_X,129
        MOV P2_Y,200
        CALL DRAW_COLUMN
        
    LANE2:
        
        MOV P1_X,193
        MOV P1_Y,0
        MOV P2_X,193
        MOV P2_Y,42
        CALL DRAW_COLUMN
        
        MOV P1_X,193
        MOV P1_Y,52
        MOV P2_X,193
        MOV P2_Y,94
        CALL DRAW_COLUMN
        
        MOV P1_X,193
        MOV P1_Y,104
        MOV P2_X,193
        MOV P2_Y,146
        CALL DRAW_COLUMN
        
        MOV P1_X,193
        MOV P1_Y,156
        MOV P2_X,193
        MOV P2_Y,200
        CALL DRAW_COLUMN
        
    BOUNDARY2:
        
        MOV P1_X,257
        MOV P1_Y,0
        MOV P2_X,257
        MOV P2_Y,200
        CALL DRAW_COLUMN
        
        MOV P1_X,258
        MOV P1_Y,0
        MOV P2_X,258
        MOV P2_Y,200
        CALL DRAW_COLUMN
        
        MOV P1_X,259
        MOV P1_Y,0
        MOV P2_X,259
        MOV P2_Y,200
        CALL DRAW_COLUMN
        
    RET

BUILD_ROAD ENDP

USER_CAR PROC

    MOV COLOUR,2
    
    MOV AX,USER_X
    MOV P1_X,AX
    ADD AX,10
    MOV P2_X,AX
    MOV AX,USER_Y
    MOV P1_Y,AX
    MOV P2_Y,AX
    
    CALL BUILD_CAR 
    
    RET  

USER_CAR ENDP

BUILD_CAR PROC
    
    MOV LVAR,10
    
    CALL DRAW_BLOCK
    
    ADD P1_Y,11
    ADD P2_Y,11
    
    MOV LVAR,10
    CALL DRAW_BLOCK
    
    ADD P1_X,10
    SUB P1_Y,39 
    ADD P2_X,10
    SUB P2_Y,39
    
    MOV LVAR,10
    CALL DRAW_BLOCK
    
    ADD P1_Y,11
    ADD P2_Y,11
    
    MOV LVAR,10
    CALL DRAW_BLOCK
    
    ADD P1_X,10
    SUB P1_Y,19 
    ADD P2_X,10
    SUB P2_Y,19
    
    MOV LVAR,10 
    CALL DRAW_BLOCK
    
    ADD P1_Y,11
    ADD P2_Y,11
    
    MOV LVAR,10 
    CALL DRAW_BLOCK
    
    RET
    
BUILD_CAR ENDP

DRAW_BLOCK PROC
    
    LOOP_BLOCK:
        
        CALL DRAW_ROW
        DEC LVAR
        CMP LVAR,0
        JG NEXT_BLOCK
        JMP END_BLOCK
        
    NEXT_BLOCK:
        
        INC P1_Y
        INC P2_Y
        JMP LOOP_BLOCK
       
    END_BLOCK:
    
        RET    

DRAW_BLOCK ENDP

DRAW_COLUMN PROC
    
    MOV AH,0CH
    MOV AL,COLOUR
    MOV CX,P1_X
    MOV DX,P1_Y
    
    L2: 
    
        INT 10H
        INC DX
        CMP DX,P2_Y
        JL L2
    
    RET
    
DRAW_COLUMN ENDP

DRAW_ROW PROC
    
    MOV AH,0CH
    MOV AL,COLOUR 
    MOV CX,P1_X
    MOV DX,P1_Y 
    CMP DX,0
    JL END_ROW
    CMP DX,200
    JG END_ROW
    
    L1:
   
        INT 10H
        INC CX
        CMP CX,P2_X
        JL L1 

    END_ROW:
        
        RET
    
DRAW_ROW ENDP

TIMER_TICK PROC

    PUSH DS
    PUSH AX
    
    MOV AX, SEG TIMER_FLAG
    MOV DS, AX
    MOV TIMER_FLAG, 1
    
    POP AX
    POP DS
    
    IRET
    
TIMER_TICK ENDP

MOVE_CAR PROC

    COL_1:

        CMP COL1_Y,210
        JG COL_2
        PUSH AX
        XOR AX,AX
        MOV AX,SPEED
        ADD COL1_Y,AX
        POP AX
           
    COL_2:
        
        CMP COL2_Y,210
        JG COL_3
        PUSH AX
        XOR AX,AX
        MOV AX,SPEED
        ADD COL2_Y,AX
        POP AX

    COL_3:
        
        CMP COL3_Y,210
        JG EXIT_MOVE
        PUSH AX
        XOR AX,AX
        MOV AX,SPEED
        ADD COL3_Y,AX
        POP AX 
       
    EXIT_MOVE:
        
        CALL CLEAR_SCREEN
        CALL BUILD_ROAD
        CALL DRAW_OTHER_CARS
        CALL RESTORE
        CALL USER_CAR
        CALL SPEED_METER
        CALL SHOW_SCORE_SPEED
        RET
 
MOVE_CAR ENDP

MOVE_USER_CAR PROC

    MOV AH,06H
    MOV DX,0FFFH
    INT 21H
    JZ END_MOVE_CAR

    CMP AL,4BH
    JZ LEFT
    CMP AL,4DH
    JZ RIGHT
    JMP END_MOVE_CAR

    LEFT:

        CMP USER_X,81
        JE END_MOVE_CAR

        SUB USER_X,65
        JMP END_MOVE_CAR


    RIGHT:

        CMP USER_X,211
        JE END_MOVE_CAR

        ADD USER_X,65
        JMP END_MOVE_CAR


    END_MOVE_CAR:   

        RET

MOVE_USER_CAR ENDP

DRAW_OTHER_CARS PROC

    MOV COLOUR,4
    
    MOV AX,COL1_X
    MOV P1_X,AX
    ADD AX,10
    MOV P2_X,AX
    MOV AX,COL1_Y
    MOV P1_Y,AX
    MOV P2_Y,AX
    
    CALL BUILD_CAR
    
    MOV AX,COL2_X
    MOV P1_X,AX
    ADD AX,10
    MOV P2_X,AX
    MOV AX,COL2_Y
    MOV P1_Y,AX
    MOV P2_Y,AX
    
    CALL BUILD_CAR
    
    MOV AX,COL3_X
    MOV P1_X,AX
    ADD AX,10
    MOV P2_X,AX
    MOV AX,COL3_Y
    MOV P1_Y,AX
    MOV P2_Y,AX
    
    CALL BUILD_CAR

DRAW_OTHER_CARS ENDP

SETUP_INT PROC
    ; SAVE OLD VECTOR AND SET UP NEW VECTOR
    ; INPUT: AL = INTERRUPT NUMBER
    ; DI = ADDRESS OF BUFFER FOR OLD VECTOR
    ; SI = ADDRESS OF BUFFER CONTAINING NEW VECTOR

    ; SAVE OLD INTERRUPT VECTOR

    MOV AH, 35H     ; GET VECTOR
    INT 21H
    MOV [DI], BX    ; SAVE OFFSET
    MOV [DI+2], ES  ; SAVE SEGMENT
        
    ; SETUP NEW VECTOR
    MOV DX, [SI]    ; DX HAS OFFSET
    PUSH DS         ; SAVE DS
    MOV DS, [SI+2]  ; DS HAS THE SEGMENT NUMBER
    MOV AH, 25H     ; SET VECTOR
    INT 21H
    POP DS
    RET
SETUP_INT ENDP    

CLEAR_SCREEN PROC
    
    PUSH P1_X
    PUSH P1_Y
    PUSH P2_X
    PUSH P2_Y
    
    MOV COLOUR,0
    MOV LVAR,200
    
    MOV P1_X,65
    MOV P1_Y,0
    MOV P2_X,128
    MOV P2_Y,200
    
    CALL DRAW_BLOCK
     
    MOV LVAR,200
    
    MOV P1_X,132
    MOV P1_Y,0
    MOV P2_X,192
    MOV P2_Y,200
    
    CALL DRAW_BLOCK
    
    MOV LVAR,200
    
    MOV P1_X,196
    MOV P1_Y,0
    MOV P2_X,256
    MOV P2_Y,200
    
    CALL DRAW_BLOCK
    
    POP P2_Y
    POP P2_X
    POP P1_Y
    POP P1_X

    RET
    
CLEAR_SCREEN ENDP

RESTORE PROC

    COL1_RESTORE:

        CMP COL1_Y,210
        JL COL2_RESTORE
        MOV COL1_Y,-30
        INC SCORE
        INC COUNT
        
    COL2_RESTORE:
        
        CMP COL2_Y,210
        JL COL3_RESTORE
        MOV COL2_Y,-30
        INC SCORE
        INC COUNT
        
    COL3_RESTORE:
        
        CMP COL3_Y,210
        JL RET_RESTORE
        MOV COL3_Y,-50
        INC SCORE
        INC COUNT

    RET_RESTORE:
        
        RET    
    
RESTORE ENDP

COLLISION PROC

    LANE1_COLLISION:

        CMP USER_X,81
        JNE LANE2_COLLISION
        MOV AX,USER_Y
        SUB AX,COL1_Y
        CMP AX,40
        JGE RET_COLLISION
        MOV IS_GAME_OVER,1

    LANE2_COLLISION:

        CMP USER_X,146
        JNE LANE3_COLLISION
        MOV AX,USER_Y
        SUB AX,COL2_Y
        CMP AX,40
        JGE RET_COLLISION
        MOV IS_GAME_OVER,1

    LANE3_COLLISION:
        
        CMP USER_X,211
        JNE RET_COLLISION
        MOV AX,USER_Y
        SUB AX,COL3_Y
        CMP AX,40
        JGE RET_COLLISION
        MOV IS_GAME_OVER,1    

    RET_COLLISION:
        
        RET

COLLISION ENDP

SCORE_GAME PROC

    MOV AH,0H
    MOV AL,4H
    INT 10H
    
    MOV AH,0BH
    MOV BH,00H
    MOV BL,1
    INT 10H
    
    MOV BH,1
    MOV BL,0
    INT 10H

    LEA SI,GAME_OVER_MSG
    MOV TEXT_LENGTH,9
    MOV TEXT_ROW,9
    MOV TEXT_COL,15
    CLD

    CALL DISPLAY_TEXT    
    
    LEA SI,SCORE_MSG
    MOV TEXT_LENGTH,6
    MOV TEXT_ROW,12
    MOV TEXT_COL,16
    CLD

    CALL DISPLAY_TEXT
    
    PUSH AX
    
    XOR AX,AX
    MOV AL,SCORE
    MOV INT_TO_DISPLAY,AL
    MOV INT_ROW,12
    MOV INT_COL,22
    
    POP AX
    
    CALL DISPLAY_INT
    
    PUSH AX
    MOV AL,HIGH_SCORE
    CMP SCORE,AL
    JG SECOND_SCORE
    
    LEA SI,HIGH_SCORE_MSG
    MOV TEXT_LENGTH,11
    MOV TEXT_ROW,14
    MOV TEXT_COL,13
    CLD
    
    CALL DISPLAY_TEXT
    
    PUSH AX
    
    XOR AX,AX
    MOV AL,HIGH_SCORE
    MOV INT_TO_DISPLAY,AL
    MOV INT_ROW,14
    MOV INT_COL,24
    
    POP AX
    
    CALL DISPLAY_INT
    JMP RET_SCORE
    
    SECOND_SCORE:
        
        LEA SI,CONGRATULATIONS_MSG
        MOV TEXT_LENGTH,15
        MOV TEXT_ROW,14
        MOV TEXT_COL,13
        CLD
        
        CALL DISPLAY_TEXT
        
        LEA SI,NEW_HIGH_SCORE_MSG
        MOV TEXT_LENGTH,14
        MOV TEXT_ROW,16
        MOV TEXT_COL,13
        CLD
        
        CALL DISPLAY_TEXT
        CALL WRITE_FILE

    RET_SCORE:
    
        ; GETCH     
        MOV AH, 0
        INT 16H
        
        ; RETURN TO TEXT MODE
        MOV AX, 3
        INT 10H

        RET
SCORE_GAME ENDP

DISPLAY_TEXT PROC
    
    MOV DH,TEXT_ROW
    MOV DL,TEXT_COL

    PRINT_TEXT:
        
        MOV AH,02
        MOV BH,0
        INT 10H
        
        LODSB
        
        MOV AH,9
        MOV BL,TEXT_COLOUR
        MOV CX,1
        INT 10H
        
        INC DL
        DEC TEXT_LENGTH
        
        CMP TEXT_LENGTH,0
        JG PRINT_TEXT
        
    RET
    
DISPLAY_TEXT ENDP

DISPLAY_INT PROC

    MOV CX,0
    MOV BL,10
    
    MOV AL,INT_TO_DISPLAY
    
    LOOP_INT:
        
        MOV AH,0
     
        DIV BL
        XOR DX,DX
        MOV DL,AH
        PUSH DX

        INC CX
        CMP AL,0
        JG LOOP_INT
        
        MOV INT_LENGTH,CX
        MOV DH,INT_ROW
        MOV DL,INT_COL

    PRINT_INT:
        
        MOV AH,02
        MOV BH,0
        INT 10H
        
        POP AX
        
        MOV AH,9
        ADD AL,30H 
        MOV BL,INT_COLOUR
        MOV CX,1
        INT 10H
        
        INC DL
        DEC INT_LENGTH
        CMP INT_LENGTH,0
        JG PRINT_INT
        
    RET

DISPLAY_INT ENDP

READ_FILE PROC

    MOV AH,3DH
    LEA DX,FILE_NAME
    MOV AL,0
    INT 21H
    
    JC ERROR_OPEN
    MOV BX,AX

    READ_LOOP:
        
        MOV AH,3FH
        MOV CX,1
        LEA DX,BUFFER
        INT 21H
        CMP AX,0
        JE CLOSE_READ
        SUB BUFFER,30H
        PUSH AX
        PUSH BX
        XOR AX,AX
        XOR BX,BX
        MOV AL,HIGH_SCORE
        MOV BL,10
        MUL BL
        ADD AL,BUFFER
        MOV HIGH_SCORE,AL
        POP BX
        POP AX
        JMP READ_LOOP
        
    ERROR_OPEN:
        
        MOV HIGH_SCORE,'R'
        
    CLOSE_READ:
        
        MOV AH,3EH
        INT 21H
        RET
    
READ_FILE ENDP

WRITE_FILE PROC
    
    PUSH AX
    
    MOV AH,3CH
    LEA DX,FILE_NAME
    MOV CL,0
    INT 21H
    MOV HANDLE,AX
    MOV BX,AX
    
    XOR AX,AX
    MOV AL,SCORE
    CALL OUTDEC 
    
    MOV AH,3EH
    MOV BX,HANDLE
    INT 21H
    
    POP AX
    RET
    
WRITE_FILE ENDP

OUTDEC PROC
    
    ;INPUT AX
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    OR AX,AX
    JGE END_IF1
    PUSH AX
    MOV DL,'-'
    MOV AH,2
    INT 21H
    
    POP AX
    NEG AX
    
    END_IF1:

        XOR CX,CX
        MOV BX,10D
        
    REPEAT1:

        XOR DX,DX
        DIV BX
        PUSH DX
        INC CX
        OR AX,AX
        JNE REPEAT1
        
    PRINT_LOOP:
        
        POP DX
        OR DL,30H
        MOV BUFFER,DL
        PUSH CX 
        
        MOV AH,40H
        MOV BX,HANDLE
        MOV CX,1
        LEA DX,BUFFER
        INT 21H
        
        POP CX
        
        LOOP PRINT_LOOP
    
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
    
OUTDEC ENDP

SPEED_METER PROC

    CMP COUNT,5
    JL RET_SPEED
    INC SPEED
    MOV COUNT,0
    
    RET_SPEED:
        
        RET

SPEED_METER ENDP

SHOW_SCORE_SPEED PROC

    LEA SI,SCORE_MSG
    MOV TEXT_LENGTH,6
    MOV TEXT_ROW,1
    MOV TEXT_COL,1
    CLD
    
    CALL DISPLAY_TEXT
    
    PUSH AX
    
    XOR AX,AX
    MOV AL,SCORE
    MOV INT_TO_DISPLAY,AL
    MOV INT_ROW,2
    MOV INT_COL,3
    
    POP AX
    
    CALL DISPLAY_INT
    
    LEA SI,SPEED_MSG
    MOV TEXT_LENGTH,6
    MOV TEXT_ROW,1
    MOV TEXT_COL,34
    CLD
    
    CALL DISPLAY_TEXT
    
    PUSH AX
    
    XOR AX,AX
    MOV AX,SPEED
    MOV INT_TO_DISPLAY,AL
    MOV INT_ROW,2
    MOV INT_COL,36
    
    POP AX 
    
    CALL DISPLAY_INT
      
    RET
    
SHOW_SCORE_SPEED ENDP

    END MAIN