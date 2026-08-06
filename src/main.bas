' Jemima vs the Fish - route prediction prototype 0.1
' Target: ZX Spectrum 48K, Boriel BASIC

#pragma explicit = true

CONST GRID_W AS UBYTE = 4
CONST GRID_H AS UBYTE = 3
CONST ROUTE_LEN AS UBYTE = 4

CONST MOVE_UP AS UBYTE = 1
CONST MOVE_DOWN AS UBYTE = 2
CONST MOVE_LEFT AS UBYTE = 3
CONST MOVE_RIGHT AS UBYTE = 4

DIM fishMoves(0 TO 3) AS UBYTE
DIM jemimaMoves(0 TO 3) AS UBYTE
DIM startX AS UBYTE
DIM startY AS UBYTE
DIM endX AS UBYTE
DIM endY AS UBYTE
DIM fishX AS UBYTE
DIM fishY AS UBYTE
DIM jemimaX AS UBYTE
DIM jemimaY AS UBYTE
DIM i AS UBYTE
DIM matches AS UBYTE
DIM streak AS UBYTE
DIM bestStreak AS UBYTE

SUB WaitForRelease()
    WHILE INKEY$ <> ""
    END WHILE
END SUB

SUB WaitForSpace()
    DIM key$ AS STRING
    LET key$ = ""
    WHILE key$ <> " "
        LET key$ = INKEY$
    END WHILE
    WaitForRelease()
END SUB

FUNCTION ReadMove() AS UBYTE
    DIM key$ AS STRING
    WHILE 1
        LET key$ = INKEY$
        IF key$ = "q" OR key$ = "Q" THEN
            WaitForRelease()
            RETURN MOVE_UP
        END IF
        IF key$ = "a" OR key$ = "A" THEN
            WaitForRelease()
            RETURN MOVE_DOWN
        END IF
        IF key$ = "o" OR key$ = "O" THEN
            WaitForRelease()
            RETURN MOVE_LEFT
        END IF
        IF key$ = "p" OR key$ = "P" THEN
            WaitForRelease()
            RETURN MOVE_RIGHT
        END IF
    END WHILE
END FUNCTION

FUNCTION CanMove(x AS UBYTE, y AS UBYTE, moveCode AS UBYTE) AS UBYTE
    IF moveCode = MOVE_UP AND y = 0 THEN RETURN 0
    IF moveCode = MOVE_DOWN AND y = GRID_H - 1 THEN RETURN 0
    IF moveCode = MOVE_LEFT AND x = 0 THEN RETURN 0
    IF moveCode = MOVE_RIGHT AND x = GRID_W - 1 THEN RETURN 0
    RETURN 1
END FUNCTION

SUB ApplyMove(BYREF x AS UBYTE, BYREF y AS UBYTE, moveCode AS UBYTE)
    IF moveCode = MOVE_UP THEN LET y = y - 1
    IF moveCode = MOVE_DOWN THEN LET y = y + 1
    IF moveCode = MOVE_LEFT THEN LET x = x - 1
    IF moveCode = MOVE_RIGHT THEN LET x = x + 1
END SUB

SUB PrintMove(moveCode AS UBYTE)
    IF moveCode = MOVE_UP THEN PRINT "U";
    IF moveCode = MOVE_DOWN THEN PRINT "D";
    IF moveCode = MOVE_LEFT THEN PRINT "L";
    IF moveCode = MOVE_RIGHT THEN PRINT "R";
END SUB

SUB DrawGrid()
    DIM row AS UBYTE
    DIM y AS UBYTE

    PRINT AT 4, 6; INK 7; "1     2     3     4"
    FOR y = 0 TO GRID_H
        LET row = 5 + y * 4
        PRINT AT row, 3; INK 7; "+-----+-----+-----+-----+"
        IF y < GRID_H THEN
            PRINT AT row + 1, 3; INK 7; "|     |     |     |     |"
            PRINT AT row + 2, 3; INK 7; "|     |     |     |     |"
            PRINT AT row + 3, 3; INK 7; "|     |     |     |     |"
        END IF
    NEXT y
    PRINT AT 7, 1; INK 7; "1"
    PRINT AT 11, 1; INK 7; "2"
    PRINT AT 15, 1; INK 7; "3"
END SUB

SUB PutMarker(x AS UBYTE, y AS UBYTE, marker$ AS STRING, colour AS UBYTE)
    PRINT AT 7 + y * 4, 6 + x * 6; INK colour; marker$;
END SUB

SUB DrawHeader(title$ AS STRING)
    BORDER 0
    PAPER 0
    INK 7
    CLS
    PRINT AT 0, 0; INK 6; "JEMIMA VS THE FISH"
    PRINT AT 1, 0; INK 7; title$
END SUB

SUB ShowFishMoves()
    DIM n AS UBYTE
    FOR n = 0 TO ROUTE_LEN - 1
        PrintMove(fishMoves(n))
        IF n < ROUTE_LEN - 1 THEN PRINT " ";
    NEXT n
END SUB

SUB ShowJemimaMoves()
    DIM n AS UBYTE
    FOR n = 0 TO ROUTE_LEN - 1
        PrintMove(jemimaMoves(n))
        IF n < ROUTE_LEN - 1 THEN PRINT " ";
    NEXT n
END SUB

SUB PlanFishRoute()
    DIM moveCode AS UBYTE
    DIM stepNo AS UBYTE

    LET fishX = startX
    LET fishY = startY
    LET stepNo = 0

    DrawHeader("FISH: SECRETLY PLAN 4 MOVES")
    DrawGrid()
    PutMarker(fishX, fishY, "F", 3)
    PRINT AT 20, 0; INK 5; "Q A O P MOVE THE ROD"

    WHILE stepNo < ROUTE_LEN
        LET moveCode = ReadMove()
        IF CanMove(fishX, fishY, moveCode) THEN
            LET fishMoves(stepNo) = moveCode
            ApplyMove(fishX, fishY, moveCode)
            LET stepNo = stepNo + 1
            DrawHeader("FISH: SECRETLY PLAN 4 MOVES")
            DrawGrid()
            PutMarker(startX, startY, "S", 5)
            PutMarker(fishX, fishY, "F", 3)
            PRINT AT 19, 0; INK 7; "ROUTE: ";
            FOR i = 0 TO stepNo - 1
                PrintMove(fishMoves(i))
                PRINT " ";
            NEXT i
            PRINT AT 21, 0; INK 5; "MOVES "; stepNo; "/"; ROUTE_LEN
        ELSE
            BEEP .03, -8
        END IF
    END WHILE

    LET endX = fishX
    LET endY = fishY
    PRINT AT 22, 0; INK 7; "PRESS SPACE, THEN PASS CONTROL"
    WaitForSpace()
END SUB

SUB EnterPrediction()
    DIM moveCode AS UBYTE
    DIM stepNo AS UBYTE

    LET jemimaX = startX
    LET jemimaY = startY
    LET stepNo = 0

    DrawHeader("JEMIMA: PREDICT THE HIDDEN ROUTE")
    DrawGrid()
    PutMarker(startX, startY, "S", 5)
    PutMarker(endX, endY, "E", 4)
    PRINT AT 19, 0; INK 7; "START "; startX + 1; ","; startY + 1;
    PRINT "  END "; endX + 1; ","; endY + 1
    PRINT AT 21, 0; INK 6; "Q A O P ENTER YOUR PREDICTION"

    WHILE stepNo < ROUTE_LEN
        LET moveCode = ReadMove()
        IF CanMove(jemimaX, jemimaY, moveCode) THEN
            LET jemimaMoves(stepNo) = moveCode
            ApplyMove(jemimaX, jemimaY, moveCode)
            LET stepNo = stepNo + 1
            DrawHeader("JEMIMA: PREDICT THE HIDDEN ROUTE")
            DrawGrid()
            PutMarker(startX, startY, "S", 5)
            PutMarker(endX, endY, "E", 4)
            PutMarker(jemimaX, jemimaY, "J", 6)
            PRINT AT 19, 0; INK 7; "PREDICTION: ";
            FOR i = 0 TO stepNo - 1
                PrintMove(jemimaMoves(i))
                PRINT " ";
            NEXT i
            PRINT AT 21, 0; INK 6; "MOVES "; stepNo; "/"; ROUTE_LEN
        ELSE
            BEEP .03, -8
        END IF
    END WHILE
END SUB

SUB ResolveRoute()
    LET fishX = startX
    LET fishY = startY
    LET jemimaX = startX
    LET jemimaY = startY
    LET matches = 0
    LET streak = 0
    LET bestStreak = 0

    FOR i = 0 TO ROUTE_LEN - 1
        ApplyMove(fishX, fishY, fishMoves(i))
        ApplyMove(jemimaX, jemimaY, jemimaMoves(i))

        IF fishMoves(i) = jemimaMoves(i) THEN
            LET matches = matches + 1
            LET streak = streak + 1
            IF streak > bestStreak THEN LET bestStreak = streak
            BEEP .04, 8
        ELSE
            LET streak = 0
            BEEP .04, -6
        END IF

        DrawHeader("ROUTE RESOLUTION")
        DrawGrid()
        PutMarker(startX, startY, "S", 5)
        PutMarker(endX, endY, "E", 4)
        PutMarker(fishX, fishY, "F", 3)
        PutMarker(jemimaX, jemimaY, "J", 6)
        PRINT AT 19, 0; INK 3; "FISH: ";
        ShowFishMoves()
        PRINT AT 20, 0; INK 6; "JEMIMA: ";
        ShowJemimaMoves()
        PRINT AT 22, 0; INK 7; "STEP "; i + 1; "  MATCHES "; matches
        PAUSE 35
    NEXT i

    DrawHeader("ROUND RESULT")
    DrawGrid()
    PutMarker(startX, startY, "S", 5)
    PutMarker(endX, endY, "E", 4)
    PRINT AT 18, 0; INK 3; "FISH ROUTE: ";
    ShowFishMoves()
    PRINT AT 19, 0; INK 6; "PREDICTION: ";
    ShowJemimaMoves()
    PRINT AT 21, 0; INK 7; "MATCHES "; matches; "  BEST STREAK "; bestStreak

    IF matches = ROUTE_LEN THEN
        PRINT AT 22, 4; PAPER 2; INK 7; " COMPLETE CAPTURE "
    ELSE
        PRINT AT 22, 6; PAPER 1; INK 7; " THE FISH ESCAPES "
    END IF

    PRINT AT 23, 3; PAPER 0; INK 7; "SPACE: ANOTHER ROUND"
    WaitForSpace()
END SUB

RANDOMIZE

WHILE 1
    LET startX = INT(RND * GRID_W)
    LET startY = INT(RND * GRID_H)
    PlanFishRoute()
    EnterPrediction()
    ResolveRoute()
END WHILE
