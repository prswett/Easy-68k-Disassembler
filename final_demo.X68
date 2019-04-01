    ORG    $4000
START:

* start of add tests

    ADD.B   D0,D6
    ADD.B   (A1),D5
    ADD.B   -(A2),D4
    ADD.B   (A3)+,D3
    ADD.B   $4002,D2
    ADD.B   $9000,D1

    ADD.W   D0,D6
    ADD.W   (A1),D5
    ADD.W   -(A2),D4
    ADD.W   (A3)+,D3
    ADD.W   $4002,D2
    ADD.W   $9000,D1

    ADD.L   D0,D6
    ADD.L   (A1),D5
    ADD.L   -(A2),D4
    ADD.L   (A3)+,D3
    ADD.L   $4002,D2
    ADD.L   $9000,D1

    ADD.B   D5,(A1)
    ADD.B   D4,-(A2)
    ADD.B   D3,(A3)+
    ADD.B   D2,$4002
    ADD.B   D1,$9000

    ADD.W   D5,(A1)
    ADD.W   D4,-(A2)
    ADD.W   D3,(A3)+
    ADD.W   D2,$4002
    ADD.W   D1,$9000

    ADD.L   D5,(A1)
    ADD.L   D4,-(A2)
    ADD.L   D3,(A3)+
    ADD.L   D2,$4002
    ADD.L   D1,$9000

* end of add tests, start of ADDA

    ADDA.W D4,A0
    ADDA.W A2,A1
    ADDA.W (A2),A2
    ADDA.W -(A2),A3
    ADDA.W (A2)+,A4
    ADDA.W $4002,A5
    ADDA.W $9000,A6
    ADDA.W #$23,A7

    ADDA.L #$34,A7
    ADDA.L D4,A6
    ADDA.L A2,A5
    ADDA.L (A2),A4
    ADDA.L -(A2),A3
    ADDA.L (A2)+,A2
    ADDA.L $4002,A1
    ADDA.L $9000,A0

* end of ADDA tests, start of ADDI

    ADDI.B  #$40,D4
    ADDI.W  #$4000,D4
    ADDI.L  #$40000000,D4
    ADDI.B  #$40,(A1)
    ADDI.W  #$4000,(A1)
    ADDI.L  #$40000000,(A1)
    ADDI.B  #$40,(A1)+
    ADDI.W  #$4000,(A1)+
    ADDI.L  #$40000000,(A1)+
    ADDI.B  #$40,-(A1)
    ADDI.W  #$4000,-(A1)
    ADDI.L  #$40000000,-(A1)

    ADDI.B  #$40,$4002
    ADDI.W  #$4000,$4002
    ADDI.L  #$40000000,$4002
    ADDI.B  #$40,$9005
    ADDI.W  #$4000,$9005
    ADDI.L  #$40000000,$9005
    ADDI.B  #$40,$00004002
    ADDI.W  #$4000,$00004002
    ADDI.L  #$40000000,$00004002
    ADDI.B  #$40,$00009005
    ADDI.W  #$4000,$00009005
    ADDI.L  #$40000000,$00009005

* end of ADDI tests, start of ADDQ

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

* end of ADDQ, start of AND

    AND.B   D0,D6
    AND.B   (A1),D5
    AND.B   -(A2),D4
    AND.B   (A3)+,D3
    AND.B   $4002,D2
    AND.B   $9000,D1

    AND.W   D0,D6
    AND.W   (A1),D5
    AND.W   -(A2),D4
    AND.W   (A3)+,D3
    AND.W   $4002,D2
    AND.W   $9000,D1

    AND.L   D0,D6
    AND.L   (A1),D5
    AND.L   -(A2),D4
    AND.L   (A3)+,D3
    AND.L   $4002,D2
    AND.L   $9000,D1

    AND.B   D5,(A1)
    AND.B   D4,-(A2)
    AND.B   D3,(A3)+
    AND.B   D2,$4002
    AND.B   D1,$9000

    AND.W   D5,(A1)
    AND.W   D4,-(A2)
    AND.W   D3,(A3)+
    AND.W   D2,$4002
    AND.W   D1,$9000

    AND.L   D5,(A1)
    AND.L   D4,-(A2)
    AND.L   D3,(A3)+
    AND.L   D2,$4002
    AND.L   D1,$9000

* end of AND, start of ASL

    ASL.B   #$02,D4
    ASL     (A1)
    ASL     -(A1)
    ASL     (A1)+
    ASL     $4002
    ASL     $00004002
    ASL     $9000
    ASL     $00009000
    ASL.W   #$02,D4
    ASL.W   #$0002,D4

    ASL.L   #$02,D4
    ASL.L   #$0002,D4
    ASL.L   #$00000002,D4

    ASL.B   D3,D4
    ASL.W   D3,D4
    ASL.L   D3,D4

* end of ASL, start of ASR

    ASR.B   #$02,D4
    ASR     (A1)
    ASR     -(A1)
    ASR     (A1)+
    ASR     $4002
    ASR     $00004002
    ASR     $9000
    ASR     $00009000
    ASR.W #$02,D4
    ASR.W #$0002,D4

    ASR.L #$02,D4
    ASR.L #$0002,D4
    ASR.L #$00000002,D4

    ASR.B D3,D4
    ASR.W D3,D4
    ASR.L D3,D4

* end of ASR, start of BCC

    BCC     $3FF8 *F6
    BCC     $4008 *04
    BCC     $2000 *DFFA
    BCC     $6000 *1FF6
    BCC     $C00D *7FFF
    BCC     $0    *BFEE

* end of BCC, start of BGT

    BGT     $3FF8 *F6
    BGT     $4008 *04
    BGT     $2000 *DFFA
    BGT     $6000 *1FF6
    BGT     $C00D *7FFF
    BGT     $0    *BFEE

* end of BGT, start of BLE

    BLE     $3FF8 *F6
    BLE     $4008 *04
    BLE     $2000 *DFFA
    BLE     $6000 *1FF6
    BLE     $C00D *7FFF
    BLE     $0    *BFEE

* end of BLE, start of CLR V1

    CLR.W   D1
    CLR.W   (A1)+
    CLR.W   -(A1)
    CLR.W   (A1)

    CLR.W   D2
    CLR.W   (A3)+
    CLR.W   -(A4)
    CLR.W   (A5)

    CLR.B   $9000
    CLR.W   $9000
    CLR.L   $9000

    CLR.B   $00007000
    CLR.W   $00007000
    CLR.L   $00007000

* end of CLR V1, start of CLR V2

    CLR     D1
    CLR     (A1)+
    CLR     -(A1)
    CLR     (A1)

    CLR     D2
    CLR     (A3)+
    CLR     -(A4)
    CLR     (A5)

    CLR.B   $9000
    CLR.W   $9000
    CLR.L   $9000

    CLR.B   $00007000
    CLR.W   $00007000
    CLR.L   $00007000

* end of CLR V2, start of CMP

    CMP.B   D0,D1
    CMP.W   A1,D1
    CMP.L   (A2),D1
    CMP.W   (A3)+,D2
    CMP.W   -(A4),D2
    CMP.L   $1234,D3
    CMP.L   $000A1234,D3
    CMP.B   #$1A,D4
    CMP.W   #$1A1A,D4
    CMP.L   #$1F1A1F1A,D4

* end of CMP, start of DIVU

    DIVU.W #$1234,D2
    DIVU.W D3,D2
    DIVU.W (A1),D4
    DIVU.W (A1)+,D1
    DIVU.W -(A1),D5
    DIVU.W $4002,D1
    DIVU.W $9000,D4
    DIVU.W $00004002,D3
    DIVU.W $000F9000,D1
    DIVU.W #29183,D3

* end of DIVU, start of JSR

    JSR (A3)
    JSR $4002
    JSR $00004000
    JSR $9000
    JSR $000F9000

* end of JSR, start of LEA

    LEA     (A5),A0
    LEA     $4002,A1
    LEA     $00004002,A2
    LEA     $9000,A3
    LEA     $00F9000,A4
    LEA     (A6),A7

* end of LEA, start of LSL

    LSL     (A0)
    LSL     (A1)+
    LSL     -(A2)
    LSL     $3000
    LSL     $F9000
    LSL     (A3)
    LSL     (A4)+
    LSL     -(A5)
    LSL     (A6)
    LSL     (A7)+
    LSL     $0001
    LSL     $FFFFFF

    LSL.B   #1,D7
    LSL.B   #2,D6
    LSL.B   #3,D5
    LSL.B   #4,D4
    LSL.B   #5,D3
    LSL.B   #6,D2
    LSL.B   #7,D1
    LSL.B   #8,D0

    LSL.W   #1,D7
    LSL.W   #2,D6
    LSL.W   #3,D5
    LSL.W   #4,D4
    LSL.W   #5,D3
    LSL.W   #6,D2
    LSL.W   #7,D1
    LSL.W   #8,D0

    LSL.L   #1,D7
    LSL.L   #2,D6
    LSL.L   #3,D5
    LSL.L   #4,D4
    LSL.L   #5,D3
    LSL.L   #6,D2
    LSL.L   #7,D1
    LSL.L   #8,D0

    LSL.B   D0,D7
    LSL.B   D1,D6
    LSL.B   D2,D5
    LSL.B   D3,D4
    LSL.B   D4,D3
    LSL.B   D5,D2
    LSL.B   D6,D1
    LSL.B   D7,D0

    LSL.W   D0,D7
    LSL.W   D1,D6
    LSL.W   D2,D5
    LSL.W   D3,D4
    LSL.W   D4,D3
    LSL.W   D5,D2
    LSL.W   D6,D1
    LSL.W   D7,D0

    LSL.L   D0,D7
    LSL.L   D1,D6
    LSL.L   D2,D5
    LSL.L   D3,D4
    LSL.L   D4,D3
    LSL.L   D5,D2
    LSL.L   D6,D1
    LSL.L   D7,D0

* end of LSL, start of LSR

    LSR     (A0)
    LSR     (A1)+
    LSR     -(A2)
    LSR     $3000
    LSR     $F9000
    LSR     (A3)
    LSR     (A4)+
    LSR     -(A5)
    LSR     (A6)
    LSR     (A7)+
    LSR     $0001
    LSR     $FFFFFF

    LSR.B   #1,D7
    LSR.B   #2,D6
    LSR.B   #3,D5
    LSR.B   #4,D4
    LSR.B   #5,D3
    LSR.B   #6,D2
    LSR.B   #7,D1
    LSR.B   #8,D0

    LSR.W   #1,D7
    LSR.W   #2,D6
    LSR.W   #3,D5
    LSR.W   #4,D4
    LSR.W   #5,D3
    LSR.W   #6,D2
    LSR.W   #7,D1
    LSR.W   #8,D0

    LSR.L   #1,D7
    LSR.L   #2,D6
    LSR.L   #3,D5
    LSR.L   #4,D4
    LSR.L   #5,D3
    LSR.L   #6,D2
    LSR.L   #7,D1
    LSR.L   #8,D0

    LSR.B   D0,D7
    LSR.B   D1,D6
    LSR.B   D2,D5
    LSR.B   D3,D4
    LSR.B   D4,D3
    LSR.B   D5,D2
    LSR.B   D6,D1
    LSR.B   D7,D0

    LSR.W   D0,D7
    LSR.W   D1,D6
    LSR.W   D2,D5
    LSR.W   D3,D4
    LSR.W   D4,D3
    LSR.W   D5,D2
    LSR.W   D6,D1
    LSR.W   D7,D0

    LSR.L   D0,D7
    LSR.L   D1,D6
    LSR.L   D2,D5
    LSR.L   D3,D4
    LSR.L   D4,D3
    LSR.L   D5,D2
    LSR.L   D6,D1
    LSR.L   D7,D0

* end of LSR, start of MOVE

    MOVE.B  D0,D1
    MOVE.W  A1,D1
    MOVE.L  (A2),D1
    MOVE.W  (A3)+,D2
    MOVE.W  -(A4),D2
    MOVE.L  $1234,D3
    MOVE.L  $000A1234,D3
    MOVE.B  #$1A,D4
    MOVE.W  #$1A1A,D4
    MOVE.L  #$1F1A1F1A,D4

    MOVE.B  D0,(A1)
    MOVE.W  A1,(A1)
    MOVE.L  (A2),(A1)
    MOVE.W  (A3)+,(A2)
    MOVE.W  -(A4),(A2)
    MOVE.L  $1234,(A3)
    MOVE.L  $000A1234,(A3)
    MOVE.B  #$1A,(A4)
    MOVE.W  #$1A1A,(A4)
    MOVE.L  #$1F1A1F1A,(A4)

    MOVE.B  D0,(A1)+
    MOVE.W  A1,(A1)+
    MOVE.L  (A2),(A1)+
    MOVE.W  (A3)+,(A2)+
    MOVE.W  -(A4),(A2)+
    MOVE.L  $1234,(A3)+
    MOVE.L  $000A1234,(A3)+
    MOVE.B  #$1A,(A4)+
    MOVE.W  #$1A1A,(A4)+
    MOVE.L  #$1F1A1F1A,(A4)+

    MOVE.B  D0,-(A1)
    MOVE.W  A1,-(A1)
    MOVE.L  (A2),-(A1)
    MOVE.W  (A3)+,-(A2)
    MOVE.W  -(A4),-(A2)
    MOVE.L  $1234,-(A3)
    MOVE.L  $000A1234,-(A3)
    MOVE.B  #$1A,-(A4)
    MOVE.W  #$1A1A,-(A4)
    MOVE.L  #$1F1A1F1A,-(A4)

    MOVE.B  D0,$23BC
    MOVE.W  A1,$23BC
    MOVE.L  (A2),$23BC
    MOVE.W  (A3)+,$23BC
    MOVE.W  -(A4),$23BC
    MOVE.L  $1234,$23BC
    MOVE.L  $000A1234,$23BC
    MOVE.B  #$1A,$23BC
    MOVE.W  #$1A1A,$23BC
    MOVE.L  #$1F1A1F1A,$23BC

    MOVE.B  D0,$23BC45EF
    MOVE.W  A1,$23BC45EF
    MOVE.L  (A2),$23BC45EF
    MOVE.W  (A3)+,$23BC45EF
    MOVE.W  -(A4),$23BC45EF
    MOVE.L  $1234,$23BC45EF
    MOVE.L  $000A1234,$23BC45EF
    MOVE.B  #$1A,$23BC45EF
    MOVE.W  #$1A1A,$23BC45EF
    MOVE.L  #$1F1A1F1A,$23BC45EF

* end of MOVE, start of MOVEA

    MOVEA.W D0,A1
    MOVEA.L D0,A2
    MOVEA.W A2,A3
    MOVEA.L A2,A4
    MOVEA.W (A2)+,A5
    MOVEA.L (A2)+,A6
    MOVEA.W -(A2),A1
    MOVEA.L -(A2),A1

    MOVEA.W $0002,A1
    MOVEA.W $5002,A1
    MOVEA.W $9004,A1
    MOVEA.W $FFFF,A1

    MOVEA.W $00000002,A1
    MOVEA.W $00005002,A1
    MOVEA.W $00009004,A1
    MOVEA.W $0000FFFF,A1

    MOVEA.L $0002,A1
    MOVEA.L $5002,A1
    MOVEA.L $9004,A1
    MOVEA.L $FFFF,A1

    MOVEA.L $00000002,A1
    MOVEA.L $00005002,A1
    MOVEA.L $00009004,A1
    MOVEA.L $0000FFFF,A1

*end of MOVEA, start of MOVEM V1

    MOVEM.W     D2,-(A7)
    MOVEM.W     A5,-(A7)
    MOVEM.W     D2/A3,-(A7)
    MOVEM.W     (A0)+,D2
    MOVEM.W     (A2)+,A5
    MOVEM.W     (A7)+,D2/A3
    MOVEM.W     (A3),D2/A3-A5
    MOVEM.W     $5000,D2/A3-A5
    MOVEM.W     $F5000,D0-D2/D4/A1/A3-A5

    MOVEM.L     D0-D7/A0-A7,$5000
    MOVEM.L     D0/D7/A0/A7,$F9000
    MOVEM.L     $5000,D0-D7/A0-A7

* end of MOVEM V1, start of MOVEM V2

    MOVEA.L     #$1000,SP
    MOVE.B      #$1,D0
    MOVE.W      #$15,D1
    MOVE.W      #$2,D2
    MOVE.L      #$123431,D3
    MOVE.B      #$4,D4
    MOVE.B      #$5,D5
    MOVE.B      #$6,D6
    MOVE.W      #$7,D7
    MOVEA.L     #$1234,A1
    MOVEA.W     #$21,A2
    MOVEA.W     #$32,A3
    MOVEA.W     #$43,A4
    MOVEA.L     #$54,A5
    MOVEA.L     #$65,A6
    
    MOVEM.W     D0/D2/D3,-(SP)
    MOVEM.W     (SP)+,D0/D2/D3
    MOVEM.L     A1-A6/D0-D3,-(SP)
    MOVEM.L     (SP)+,A1-A6/D0-D3
    MOVEM.L     D1/D3-D5/D6/A0-A3/A5-A7,-(SP)
    MOVEM.L     (SP)+,D1/D3-D5/D6/A0-A3/A5-A7
    MOVEM.W     D1/D3-D5/D6/A0-A3/A5-A7,-(SP)
    MOVEM.W     (SP)+,D1/D3-D5/D6/A0-A3/A5-A7

* end of MOVEM V2, start of MOVEQ

    MOVEQ   #$00,D0
    MOVEQ   #$19,D1
    MOVEQ   #$28,D2
    MOVEQ   #$37,D3
    MOVEQ   #$46,D4
    MOVEQ   #$55,D5
    MOVEQ   #$64,D6
    MOVEQ   #$73,D7

* end of MOVEQ, start of MULS

    MULS.W  #$1234,D2
    MULS.W  #$2919,D4
    MULS.W  D3,D4
    MULS.W  (A1),D4
    MULS.W  (A1)+,D4
    MULS.W  -(A1),D4
    MULS.W  $4002,D4
    MULS.W  $9000,D4
    MULS.W  $00004002,D4
    MULS.W  $000F9000,D4

* end of MULS, start of MULU

    MULU.W  #$1234,D2
    MULU.W  #$2919,D4
    MULU.W  D3,D4
    MULU.W  (A1),D4
    MULU.W  (A1)+,D4
    MULU.W  -(A1),D4
    MULU.W  $4002,D4
    MULU.W  $9000,D4
    MULU.W  $00004002,D4
    MULU.W  $000F9000,D4

* end of MULU, start of NOP

    NOP
    NOP
    NOP

* end of NOP, start of OR

    OR.B    D0,D6
    OR.B    (A1),D5
    OR.B    -(A2),D4
    OR.B    (A3)+,D3
    OR.B    $4002,D2
    OR.B    $9000,D1

    OR.W    D0,D6
    OR.W    (A1),D5
    OR.W    -(A2),D4
    OR.W    (A3)+,D3
    OR.W    $4002,D2
    OR.W    $9000,D1

    OR.L    D0,D6
    OR.L    (A1),D5
    OR.L    -(A2),D4
    OR.L    (A3)+,D3
    OR.L    $4002,D2
    OR.L    $9000,D1

    OR.B    D5,(A1)
    OR.B    D4,-(A2)
    OR.B    D3,(A3)+
    OR.B    D2,$4002
    OR.B    D1,$9000

    OR.W    D5,(A1)
    OR.W    D4,-(A2)
    OR.W    D3,(A3)+
    OR.W    D2,$4002
    OR.W    D1,$9000

    OR.L    D5,(A1)
    OR.L    D4,-(A2)
    OR.L    D3,(A3)+
    OR.L    D2,$4002
    OR.L    D1,$9000

* end of OR, start of ROL

    ROL     $3112
    ROL     $5612
    ROL   $7812
    ROL   $83112
    ROL.B #$02,D4

    ROL   (A1)
    ROL   -(A1)
    ROL   (A1)+
    ROL   $4002
    ROL   $00004002
    ROL   $9000
    ROL   $00009000
    ROL.W #$02,D4
    ROL.W #$0002,D4

    ROL.L #$02,D4
    ROL.L #$0002,D4
    ROL.L #$00000002,D4

    ROL.B D3,D4
    ROL.W D3,D4
    ROL.L D3,D4
    ROL   $3112

* end of ROL, start of ROR

    ROR     $3112
    ROR     $5612
    ROR     $7812
    ROR     $83112
    ROR.B   #$02,D4

    ROR     (A1)
    ROR     -(A1)
    ROR     (A1)+
    ROR      $4002
    ROR     $00004002
    ROR     $9000
    ROR     $00009000
    ROR.W   #$02,D4
    ROR.W   #$0002,D4

    ROR.L   #$02,D4
    ROR.L   #$0002,D4
    ROR.L   #$00000002,D4

    ROR.B   D3,D4
    ROR.W   D3,D4
    ROR.L   D3,D4

    ROR     $3112

* end of ROR, start of RTS

    RTS
    RTS
    RTS

* end of RTS, start of SUB

    SUB.B   D0,D6
    SUB.B   (A1),D5
    SUB.B   -(A2),D4
    SUB.B   (A3)+,D3
    SUB.B   $4002,D2
    SUB.B   $9000,D1

    SUB.W   D0,D6
    SUB.W   (A1),D5
    SUB.W   -(A2),D4
    SUB.W   (A3)+,D3
    SUB.W   $4002,D2
    SUB.W   $9000,D1

    SUB.L   D0,D6
    SUB.L   (A1),D5
    SUB.L   -(A2),D4
    SUB.L   (A3)+,D3
    SUB.L   $4002,D2
    SUB.L   $9000,D1

    SUB.B   D5,(A1)
    SUB.B   D4,-(A2)
    SUB.B   D3,(A3)+
    SUB.B   D2,$4002
    SUB.B   D1,$9000

    SUB.W   D5,(A1)
    SUB.W   D4,-(A2)
    SUB.W   D3,(A3)+
    SUB.W   D2,$4002
    SUB.W   D1,$9000

    SUB.L   D5,(A1)
    SUB.L   D4,-(A2)
    SUB.L   D3,(A3)+
    SUB.L   D2,$4002
    SUB.L   D1,$9000

* end of SUB, start of SUBI

    SUBI.B #$40,D0
    SUBI.W #$4000,D1
    SUBI.L #$40000000,D2
    SUBI.B #$40,(A1)
    SUBI.W #$4000,(A2)
    SUBI.L #$40000000,(A3)
    SUBI.B #$40,(A4)+
    SUBI.W #$4000,(A5)+
    SUBI.L #$40000000,(A6)+
    SUBI.B #$40,-(A7)
    SUBI.W #$4000,-(A1)
    SUBI.L #$40000000,-(A1)

    SUBI.B #$40,$4002
    SUBI.W #$4000,$4002
    SUBI.L #$40000000,$4002
    SUBI.B #$40,$9005
    SUBI.W #$4000,$9005
    SUBI.L #$40000000,$9005
    SUBI.B #$40,$00004002
    SUBI.W #$4000,$00004002
    SUBI.L #$40000000,$00004002
    SUBI.B #$40,$00009005
    SUBI.W #$4000,$00009005
    SUBI.L #$40000000,$00009005

* end of SUBI, end of program.

    end     START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
