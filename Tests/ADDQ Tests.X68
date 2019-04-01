    ORG    $4000

    ADDQ.B #1,D0
    ADDQ.B #2,(A1)
    ADDQ.B #3,-(A3)
    ADDQ.B #4,(A4)+
    ADDQ.B #5,$4002
    ADDQ.B #6,$9000
    ADDQ.B #7,$000F9000

    ADDQ.W #8,D2
    ADDQ.W #1,A7
    ADDQ.W #2,(A6)
    ADDQ.W #2,-(A5)
    ADDQ.W #2,(A4)+
    ADDQ.W #3,$4002
    ADDQ.W #2,$9000
    ADDQ.W #2,$000F9000

    ADDQ.L #2,D4
    ADDQ.L #5,A3
    ADDQ.L #2,(A5)
    ADDQ.L #4,-(A4)
    ADDQ.L #2,(A2)+
    ADDQ.L #2,$4002
    ADDQ.L #1,$9000
    ADDQ.L #2,$000F9000

    END    $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
