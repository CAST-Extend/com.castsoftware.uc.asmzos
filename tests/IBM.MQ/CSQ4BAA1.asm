BEGIN_PROGRAM(CSQ4BAA1)
CSQ4BAA1 TITLE 'MQSeries SAMPLE MESSAGE PRINT PROGRAM - ASSEMBLER'      00090000
*********************************************************************** 00180000
* PRODUCT NUMBER : 5695-137                                           * 00270000
*                                                                     * 00360000
* MODULE NAME    : CSQ4BAA1                                           * 00450000
*                                                                     * 00540000
* ENVIRONMENT    : MVS Batch; BAL                                     * 00630000
*                                                                     * 00720000
* DESCRIPTION    : Sample Program to print messages from a            * 00810000
*                  specified queue.                                   * 00900000
*                                                                     * 00990000
* @START_COPYRIGHT@                                                   * 01080000
*   Statement:     Licensed Materials - Property of IBM               * 01170000
*                                                                     * 01260000
*                  5695-137                                           * 01320000
*                  (C) Copyright IBM Corporation. 1993, 1997          * 01350000
*                                                                     * 01440000
*   Status:        Version 1 Release 2                                * 01530000
* @END_COPYRIGHT@                                                     * 01710000
*                                                                     * 01800000
* FUNCTION       : This program prints a report showing all the       * 01890000
*                  messages in a specified queue in the specified     * 01980000
*                  queue manager.                                     * 02070000
*                                                                     * 02160000
*                  The program processes the first 80 bytes only of   * 02250000
*                  each message. It uses the BROWSE option on the     * 02340000
*                  MQGET call to ensure that data is not lost         * 02430000
*                                                                     * 02520000
* PARAMETERS     : Standard MVS passing of parameters.                * 02610000
*                  This program expects two parameters delimited      * 02700000
*                  by a comma                                         * 02790000
*                                                                     * 02880000
*                  PARM1 = Name of the queue manager to connect to.   * 02970000
*                  PARM2 = Name of the queue to be printed            * 03060000
*                                                                     * 03150000
* REGISTERS      :                                                    * 03240000
*                  R0  - Work register                                * 03330000
*                  R1  - Work register                                * 03420000
*                  R2  - Work register                                * 03510000
*                  R3  - Work register                                * 03600000
*                  R4  - Work register                                * 03690000
*                  R5  - Length for executes                          * 03780000
*                  R6  - Branch for main routines                     * 03870000
*                  R7  - Branch for sub routines                      * 03960000
*                  R8  - Page format routine                          * 04050000
*                  R9  - Write SYSPRINT routine                       * 04140000
*                  R10 - Address work area                            * 04230000
*                  R11 - Base register                                * 04320000
*                  R12 - Second base register                         * 04410000
*                  R13 - Address of register save area                * 04500000
*                  R14 - Return address/work register                 * 04590000
*                  R15 - Work register/return code                    * 04680000
*                                                                     * 04770000
*********************************************************************** 04860000
*                                                                     * 04950000
* EXECUTABLE MACROS                                                   * 05040000
*                                                                     * 05130000
*    CALL    -  To execute MQCONN, MQOPEN, MQGET, MQCLOSE, MQDISC     * 05220000
*              -  Needs ',MF=(E,CALLLIST)' to enable code to be       * 05310000
*                 reentrant                                           * 05400000
*              -  Needs ',VL' so diagnostic facilities                * 05490000
*                 know how long the parameter list is.                * 05580000
*                                                                     * 05670000
*    SAVE    - To save register contents                              * 05700000
*                                                                     * 05730000
*    GETMAIN - To get storage                                         * 05760000
*                                                                     * 05850000
*    TIME    - To get current date                                    * 05940000
*                                                                     * 06030000
*********************************************************************** 06120000
         EJECT                                                          06210000
********************************************************************    06300000
*                                                                       06390000
*                         Program logic                                 06480000
*                         -------------                                 06570000
*        CSQ4BAA1 CSECT                                                 06660000
*        --------------                                                 06750000
*                                                                       06840000
*           Save registers                                              06930000
*           Establish addressability                                    07020000
*           Get working storage                                         07110000
*           Branch to MAIN                                              07200000
*                                                                       07290000
*        MAIN                                                           07380000
*        ----                                                           07470000
*           Call MAININIT                                               07560000
*           Call MAINPARM                                               07650000
*           Call MAINCONN                                               07740000
*           Call MAINMSGS                                               07830000
*           Call MAINDISC                                               07920000
*           Call ENDPROG                                                08010000
*                                                                       08100000
*        MAININIT                                                       08190000
*        --------                                                       08280000
*           Open SYSPRINT file                                          08370000
*           Get and initialize storage                                  08460000
*                                                                       08550000
*        MAINPARM                                                       08640000
*        --------                                                       08730000
*           Obtain the input data from parameters passed                08820000
*                                                                       08910000
*           If the name of the queue manager is missing                 09000000
*              Build a warning message and move it into data line       09090000
*              Print the line (using PRTLINE)                           09180000
*              Continue (using default queue manager name)              09270000
*           End-if                                                      09360000
*                                                                       09450000
*           If the name of the queue is missing                         09540000
*              Build an error message and move it into data line        09630000
*              Print the line (using PRTLINE)                           09720000
*              Branch to ENDPROG                                        09810000
*           End-if                                                      09900000
*                                                                       09990000
*        MAINCONN                                                       10080000
*        --------                                                       10170000
*           Connect to the queue manager                                10260000
*           If an error occurs                                          10350000
*              Build an error message and move it into data line        10440000
*              Print the line (using PRTLINE)                           10530000
*              Branch to Exit2                                          10620000
*           End-if                                                      10710000
*                                                                       10800000
*        MAINMSGS                                                       10890000
*        --------                                                       10980000
*           Open the queue                                              11070000
*           If an error occurs                                          11160000
*              Build an error message and move it into data line        11250000
*              Print the line (using PRTLINE)                           11340000
*              Branch to Exit1                                          11430000
*           End-if                                                      11520000
*                                                                       11610000
*           Do while no error                                           11700000
*                                                                       11790000
*              Add 1 to relative message number                         11880000
*              Move message into print line (maximum 80 bytes)          11970000
*              Print the line (using PRTLINE)                           12060000
*                                                                       12150000
*              Get the message (using BROWSE-NEXT option)               12240000
*                                                                       12330000
*           End-do                                                      12420000
*                                                                       12510000
*           When an error occurs                                        12600000
*              If no more messages                                      12690000
*                 Do nothing                                            12780000
*              else                                                     12870000
*                 Build an error message and move it into data line     12960000
*                 Print the line (using PRTLINE)                        13050000
*              End-if                                                   13140000
*           End-if                                                      13230000
*                                                                       13320000
*           Close the queue                                             13410000
*           If an error occurs                                          13500000
*              Build an error message and move it into data line        13590000
*              Print the line (using PRTLINE)                           13680000
*           End-if                                                      13770000
*                                                                       13860000
*        MAINDISC                                                       13950000
*        --------                                                       14040000
*           Disconnect from the queue manager                           14130000
*           If an error occurs                                          14220000
*              Build an error message and move it into data line        14310000
*              Print the line (using PRTLINE)                           14400000
*           End-if                                                      14490000
*                                                                       14580000
*        ENDPROG                                                        14670000
*        -------                                                        14760000
*           Print end report message                                    14850000
*           Close output file                                           14940000
*           Restore registers                                           15030000
*           Return to caller                                            15120000
*                                                                       15210000
*        PUTREC                                                         15300000
*        ------                                                         15390000
*           Put the output record to SYSPRINT                           15480000
*                                                                       15570000
*        PRINTHDR                                                       15660000
*        --------                                                       15750000
*           Add 1 to page number                                        15840000
*           Print first line after jumping to top of page               15930000
*           Set number of lines printed to 1                            16020000
*           Return to calling section                                   16110000
*                                                                       16200000
*        PRTLINE                                                        16290000
*        -------                                                        16380000
*           If number of lines printed is greater than page maximum     16470000
*              Print first line of header (Perform PRINTHDR)            16560000
*              Print the rest of the header (Perform PRINTHDG)          16650000
*           End-if                                                      16740000
*           Print data line                                             16830000
*           Add 1 to count of lines printed                             16920000
*           Return to calling section                                   17010000
*                                                                       17100000
*        PRINTHDG                                                       17190000
*        --------                                                       17280000
*           Print remaining header lines                                17370000
*           Return to calling section                                   17460000
*                                                                       17550000
*        ERRCODE                                                        17640000
*        -------                                                        17730000
*           Convert compcode to displayable format                      17820000
*           Convert reason to displayable format                        17910000
*           Print the error message                                     18000000
*           Return to calling section                                   18100000
*                                                                       18200000
*********************************************************************** 18300000
         EJECT                                                          18400000
*********************************************************************** 18500000
*        REGISTERs                                                    * 18600000
*********************************************************************** 18700000
R0       EQU   0                                                        18800000
R1       EQU   1                                                        18900000
R2       EQU   2                                                        19000000
R3       EQU   3                                                        19100000
R4       EQU   4                                                        19200000
R5       EQU   5                                                        19300000
R6       EQU   6                                                        19400000
R7       EQU   7                                                        19500000
R8       EQU   8                                                        19600000
R9       EQU   9                                                        19700000
R10      EQU   10                                                       19800000
R11      EQU   11                                                       19900000
R12      EQU   12                                                       20000000
R13      EQU   13                                                       20100000
R14      EQU   14                                                       20200000
R15      EQU   15                                                       20300000
*********************************************************************** 20400000
*  MQ API CONSTANTS                                                   * 20500000
*********************************************************************** 20600000
         CMQA LIST=NO                                                   20700000
*********************************************************************** 20800000
*  DSECTS USED BY THIS PROGRAM                                        * 20900000
*********************************************************************** 21000000
WORKAREA DSECT                                                          21100000
*                                                                       21200000
PARMLIST CALL ,(0,0,0,0,0,0,0,0,0,0,0),VL,MF=L                          21300000
*                                                                       21400000
PRTREC   DS    0CL133                       Output data record          21500000
PRTCC    DS    CL1                          Carriage control            21600000
PRTDATA  DS    CL132                        Data                        21700000
SKIPLINE DS    CL1                          Carriage control store      21800000
*                                                                       21900000
WORKDWRD DS    D                            Used for data conversion    22000000
PAGENUM  DS    F                            Page number counter         22100000
LINENUM  DS    F                            Line number printed         22200000
MSGNUM   DS    F                            Message count number        22300000
DATALENGTH DS  F                            Actual message length       22400000
OPTIONS  DS    F                            Options                     22500000
COMPCODE DS    F                            Completion code             22600000
REASON   DS    F                            Reason code                 22700000
HCONN    DS    F                            Connection handle           22800000
HOBJ     DS    F                            Connection handle           22900000
OBJECT   DS    F                            Object handle               23000000
EXITCODE DS    F                            Exit return code            23100000
TIMEDATE DS    0CL6                         Used for data conversion    23200000
DATECONV DS    0CL6                         Used for data conversion    23300000
         ORG   DATECONV                                                 23400000
         DS    CL1                                                      23500000
DATE_YR  DS    CL2                          The year                    23600000
DATE_JN  DS    CL3                          The Julian date             23700000
         ORG                                                            23800000
PARMADDR DS    F                            Address of parm field       23900000
PARMLEN  DS    H                            Length of parm field        24000000
*                                                                       24100000
MQMNAME  DS    CL48                         Queue manager name          24200000
MQMQUEUE DS    CL48                         Queue name                  24300000
*                                                                       24400000
MSGDATA  DS    CL132                        Used by print routine       24500000
DSPCOMP  DS    CL04                         Display compcode            24600000
DSPREAS  DS    CL04                         Display reaon               24700000
DSPMSGL  DS    CL08                         Display message length      24800000
CONVAREA DS    CL8                          Used for data conversion    24900000
*                                                                       25000000
BUFFER   DS    CL80                         Target for message          25100000
WORKLEN  EQU   *-WORKAREA                                               25200000
         EJECT                                                          25300000
**********************************************************************  25400000
* START OF PROGRAM                                                   *  25500000
**********************************************************************  25600000
CSQ4BAA1 CSECT                                                          25700000
CSQ4BAA1 AMODE 31                                                       25800000
         SAVE  (14,12)                      Save register               25900000
         LR    R11,R15                      Set program                 26000000
         LA    R12,4095(R11)                Set up second base          26100000
         LA    R12,1(R12)                                               26200000
         USING CSQ4BAA1,R11,R12             Addressability              26300000
         ST    R13,SAVEAREA+4               Backward pointer            26400000
         LR    R2,R13                       Save in R2                  26500000
         LA    R13,SAVEAREA                 Set addr of out savearea    26600000
         ST    R13,8(,R2)                   Forward savearea            26700000
         ST    R1,PARMSAVE                  Save parmlist               26800000
         GETMAIN RU,LV=WORKLEN,LOC=(RES,ANY) Get some storage           26900000
         LR    R10,R1                       Address of storage          27000000
         USING WORKAREA,R10                 Set addressability          27100000
         B     MAIN                         Branch to MAIN process      27200000
*                                                                       27300000
         EJECT                                                          27400000
********************************************************************    27500000
*  SECTION NAME : MAIN                                             *    27600000
*                                                                  *    27700000
*  FUNCTION     : Controls flow of program                         *    27800000
*                                                                  *    27900000
*  CALLED BY    : CSQ4BAA1 CSECT                                   *    28000000
*                                                                  *    28100000
*  CALLS        : MAININIT, MAINPARM, MAINCONN, MAINMSGS, MAINDISC *    28200000
*                 ENDPROG                                          *    28300000
*                                                                  *    28400000
********************************************************************    28500000
MAIN     DS    0H                                                       28600000
         BAL   R6,MAININIT                  Initialize storage          28700000
         BAL   R6,MAINPARM                  Reads the parms             28800000
         BAL   R6,MAINCONN                  Connect to qmgr             28900000
         BAL   R6,MAINMSGS                  Gets messages from queue    29000000
         BAL   R6,MAINDISC                  Disconnect from qmgr        29100000
         B     ENDPROG                      Terminate program           29200000
*                                                                       29300000
         EJECT                                                          29400000
********************************************************************    29500000
*  SECTION NAME : MAININIT                                         *    29600000
*                                                                  *    29700000
*  FUNCTION     : Performs initialization                          *    29800000
*                                                                  *    29900000
*  CALLED BY    : MAIN                                             *    30000000
*                                                                  *    30100000
*  CALLS        : PRINTHDR                                         *    30200000
*                                                                  *    30300000
*  RETURN       : To Register 6                                    *    30400000
*                                                                  *    30500000
********************************************************************    30600000
MAININIT DS    0H                                                       30700000
         OPEN  (SYSPRINT),MF=(E,PRINTOPN),MODE=31                       30800000
*                                                                       30900000
         TIME  DEC,ZONE=LT                                              31000000
*                                                                       31100000
         ST    R1,TIMEDATE                  Julian date in packed dec   31200000
         UNPK  DATECONV,TIMEDATE+1(3)       To unsigned zoned           31300000
         MVZ   DATECONV+5(1),DATECONV+4     Decimal                     31400000
         MVC   DATEYR,DATE_YR               Move date - year            31500000
         MVC   DATEJN,DATE_JN               Move date - Julian          31600000
*                                                                       31700000
         XR    R0,R0                        Zero register               31800000
         ST    R0,PAGENUM                   Zero page number            31900000
         ST    R0,MSGNUM                    Zero message number         32000000
         ST    R0,LINENUM                   Zero line number            32100000
         ST    R0,EXITCODE                  Default return code         32200000
         BAL   R7,PRINTHDR                  Write print headings        32300000
         BR    R6                                                       32400000
*                                                                       32500000
         EJECT                                                          32600000
********************************************************************    32700000
*  SECTION NAME : MAINPARM                                         *    32800000
*                                                                  *    32900000
*  FUNCTION     : Read the parameters passed to the program, and   *    33000000
*                 incorrect number of parameters passed            *    33100000
*                                                                  *    33200000
*  CALLED BY    : MAIN                                             *    33300000
*                                                                  *    33400000
*  CALLS        : PRINTHDG, PRTLINE                                *    33500000
*                                                                  *    33600000
*  RETURN       : Normal to Register 6                             *    33700000
*                 Error  to ENDPROG                                *    33800000
*                                                                  *    33900000
********************************************************************    34000000
MAINPARM DS    0H                                                       34100000
         MVI   MQMNAME,X'40'                Space out first byte        34200000
         MVC   MQMNAME+1(L'MQMNAME-1),MQMNAME  and initialize           34300000
         MVI   MQMQUEUE,X'40'               Space out first byte        34400000
         MVC   MQMQUEUE+1(L'MQMQUEUE-1),MQMQUEUE  and initialize        34500000
*                                                                       34600000
         L     R1,PARMSAVE                  Address of parm list        34700000
         L     R1,0(R1)                     Address of first parm       34800000
         LH    R5,0(R1)                     Length of parm              34900000
         STH   R5,PARMLEN                   Save away                   35000000
         LTR   R5,R5                        any data passed             35100000
         BZ    NOPARMS                      No names passed             35200000
*                                                                       35300000
TRANPARM DS    0H                                                       35400000
         LA    R3,2(R1)                     Advance to start of parm    35500000
         LR    R2,R5                        Load length and reduce      35600000
         BCTR  R2,R0                        for execute                 35700000
         EX    R2,TRANSCAN                  Scan variable bytes         35800000
         BC    4,TWOPARMS                   Comma imbedded in text      35900000
         B     NOPARM2                      No .. issue error           36000000
*                                                                       36100000
TWOPARMS DS    0H                                                       36200000
         ST    R1,PARMADDR                  Address of the comma        36300000
         CR    R1,R3                        Is comma first char         36400000
         BNE   PARM1MVE                     No then no default qmgr     36500000
         BCTR  R5,R0                        Reduce length               36600000
         MVI   HDR2_QMN,C' '                Space out first byte        36700000
         MVC   HDR2_QMN+1(L'HDR2_QMN-1),HDR2_QMN  and initialize        36800000
         MVC   MSGDATA,INF2                 Move in the message         36900000
         BAL   R8,PRTLINE                   and print the line          37000000
         L     R0,LINENUM                   Current line number         37100000
         LA    R0,1(R0)                     Add one and                 37200000
         ST    R0,LINENUM                   save again                  37300000
         LA    R0,4                         Set return code             37400000
         ST    R0,EXITCODE                  ready for exit              37500000
         L     R1,PARMADDR                  Load Addr of Comma          37600000
         LA    R4,MQMQUEUE                  addr of the queue           37700000
         BCTR  R5,R0                        reduce length for execute   37800000
         EX    R5,ONLYPARM                  parameter                   37900000
         B     ENDPARMS                     exit from parms             38000000
*                                                                       38100000
PARM1MVE DS    0H                                                       38200000
         SR    R1,R3                        Length of data              38300000
         LA    R4,MQMNAME                   Address for target          38400000
         BCTR  R1,R0                        Reduce for execute          38500000
         EX    R1,MOVEPARM                  Move the data               38600000
         LA    R3,2(R1,R3)                  past first parm + comma     38700000
         LH    R2,PARMLEN                   Original length             38800000
         LA    R1,2(R1)                     Add two to R1               38900000
         SR    R2,R1                        Length of second parm       39000000
         LR    R1,R2                        Load length for move        39100000
*                                                                       39200000
PARM2MVE DS    0H                                                       39300000
         LA    R4,MQMQUEUE                  Address of target           39400000
         BCTR  R1,R0                        Reduce for execute          39500000
         EX    R1,MOVEPARM                  Move second parm            39600000
         B     ENDPARMS                     Exit from parms             39700000
*                                                                       39800000
NOPARM2  DS    0H                                                       39900000
         MVC   MSGDATA,INF3                 Move in the message         40000000
         BAL   R8,PRTLINE                   and print the line          40100000
         LA    R0,4                         Set return code             40200000
         ST    R0,EXITCODE                  ready for exit              40300000
         B     ENDPROG                      End the program             40400000
*                                                                       40500000
NOPARMS  DS    0H                                                       40600000
         MVC   MSGDATA,INF1                 Move message to buffer      40700000
         BAL   R8,PRTLINE                   Write the record            40800000
         LA    R0,4                         Set return code             40900000
         ST    R0,EXITCODE                  ready for exit              41000000
         B     ENDPROG                      End the program             41100000
*                                                                       41200000
ENDPARMS DS    0H                                                       41300000
         BAL   R7,PRINTHDG                  Print rest of headings      41400000
         BR    R6                           Return to caller            41500000
*                                                                       41600000
         EJECT                                                          41700000
********************************************************************    41800000
*  SECTION NAME : MAINCONN                                         *    41900000
*                                                                  *    42000000
*  FUNCTION     : Connect to the queue manager                     *    42100000
*                                                                  *    42200000
*  CALLED BY    : MAIN                                             *    42300000
*                                                                  *    42400000
*  CALLS        : ERRCODE                                          *    42500000
*                                                                  *    42600000
*  RETURN       : Normal to Register 6                             *    42700000
*                 Error  to ENDPROG                                *    42800000
*                                                                  *    42900000
********************************************************************    43000000
MAINCONN DS    0H                                                       43100000
         XC    HCONN,HCONN                  Null connection handle      43200000
*                                                                       43300000
         CALL  MQCONN,                                                 X43400000
               (MQMNAME,                                               X43500000
               HCONN,                                                  X43600000
               COMPCODE,                                               X43700000
               REASON),                                                X43800000
               MF=(E,PARMLIST),VL                                       43900000
*                                                                       44000000
         LA    R0,MQCC_OK                   Expected compcode           44100000
         C     R0,COMPCODE                  As expected ?               44200000
         BER   R6                           Yes .. return to caller     44300000
*                                                                       44400000
         MVC   INF4_TYP,=CL10'CONNECT   '                               44500000
         BAL   R7,ERRCODE                   Translate error             44600000
         LA    R0,8                         Set exit code               44700000
         ST    R0,EXITCODE                  to 8                        44800000
         B     ENDPROG                      End the program             44900000
*                                                                       45000000
         EJECT                                                          45100000
********************************************************************    45200000
*  SECTION NAME : MAINMSGS                                         *    45300000
*                                                                  *    45400000
*  FUNCTION     : Read the messages from the queue                 *    45500000
*                                                                  *    45600000
*  CALLED BY    : MAIN                                             *    45700000
*                                                                  *    45800000
*  CALLS        : ERRCODE, PRTLINE                                 *    45900000
*                                                                  *    46000000
*  RETURN       : to Register 6                                    *    46100000
*                                                                  *    46200000
********************************************************************    46300000
MAINMSGS DS    0H                                                       46400000
         LA    R0,MQOT_Q                    Object is a queue           46500000
         ST    R0,OBJDESC_OBJECTTYPE        In object type field        46600000
         MVC   OBJDESC_OBJECTNAME,MQMQUEUE  Move queue name             46700000
         LA    R0,MQOO_BROWSE               Indicate open is            46800000
         ST    R0,OPTIONS                   Browse only                 46900000
*                                                                       47000000
         CALL MQOPEN,                                                  X47100000
               (HCONN,                                                 X47200000
               OBJDESC,                                                X47300000
               OPTIONS,                                                X47400000
               HOBJ,                                                   X47500000
               COMPCODE,                                               X47600000
               REASON),                                                X47700000
               MF=(E,PARMLIST),VL                                       47800000
*                                                                       47900000
         LA    R0,MQCC_OK                   Expected compcode           48000000
         C     R0,COMPCODE                  As expected?                48100000
         BE    MSGSINIT                     Yes .. continue             48200000
         MVC   INF4_TYP,=CL10'OPEN      '                               48300000
         BAL   R7,ERRCODE                   Translate error             48400000
         LA    R0,8                         Set exit code               48500000
         ST    R0,EXITCODE                  to 8                        48600000
         BR    R6                           Return to disconnect from   48700000
*                                           qmgr and terminate program  48800000
*                                                                       48900000
MSGSINIT DS    0H                                                       49000000
         LA    R0,MQGMO_BROWSE_NEXT+MQGMO_ACCEPT_TRUNCATED_MSG          49100000
         ST    R0,GETMSGOPTS_OPTIONS        Indicate get options        49200000
*                                                                       49300000
*-------------------------------------------------------------------*   49400000
* Code segment which gets the message from the requested queue.     *   49500000
*-------------------------------------------------------------------*   49600000
MSGSGETS DS    0H                                                       49700000
         XC    MSGDESC_CORRELID,MSGDESC_CORRELID  Null correlation id   49800000
         XC    MSGDESC_MSGID,MSGDESC_MSGID        Null message id       49900000
         MVC   BUFFER,MSGCLEAR                    Blank buffer          50000000
*                                                                       50100000
         CALL  MQGET,                                                  X50200000
               (HCONN,                                                 X50300000
               HOBJ,                                                   X50400000
               MSGDESC,                                                X50500000
               GETMSGOPTS,                                             X50600000
               BUFFERLENGTH,                                           X50700000
               BUFFER,                                                 X50800000
               DATALENGTH,                                             X50900000
               COMPCODE,                                               X51000000
               REASON),                                                X51100000
               MF=(E,PARMLIST),VL                                       51200000
*                                                                       51300000
         LA    R0,MQCC_OK                   Load compcode MQCC_OK       51400000
         C     R0,COMPCODE                  As expected?                51500000
         BE    MSGSPRNT                     Yes .. print message        51600000
*                                                                       51700000
         LA    R0,MQCC_WARNING              Load compcode MQCC_WARNING  51800000
         C     R0,COMPCODE                  As expected                 51900000
         BE    MSGSPRNT                     Yes .. print message        52000000
*                                                                       52100000
         LA    R0,MQRC_NO_MSG_AVAILABLE     No more message?            52200000
         C     R0,REASON                    Yes .. then close           52300000
         BE    MSGSCLOS                     Otherwise must be           52400000
         B     MSGSERR                      an error                    52500000
*                                                                       52600000
MSGSPRNT DS    0H                                                       52700000
         LA    R0,MQRC_TRUNCATED_MSG_ACCEPTED Was the warning because   52800000
         C     R0,REASON                    message was too long?       52900000
         BE    GETMSGS                      Yes .. get the message      53000000
         LA    R0,MQRC_NONE                 Was it ok?                  53100000
         C     R0,REASON                                                53200000
         BE    GETMSGS                      Yes .. get the message      53300000
         B     MSGSERR                      Its unacceptable            53400000
*                                                                       53500000
*-------------------------------------------------------------------*   53600000
* Code segment which prints the message                             *   53700000
*-------------------------------------------------------------------*   53800000
GETMSGS  DS    0H                                                       53900000
         L     R1,MSGNUM                    Load current msg number     54000000
         LA    R1,1(R1)                     Increment it by 1           54100000
         ST    R1,MSGNUM                    Save back for next time     54200000
*                                                                       54300000
         CVD   R1,WORKDWRD                  To packed decimal           54400000
         UNPK  CONVAREA,WORKDWRD+4(4)       Convert to zoned decimal    54500000
         MVZ   CONVAREA+7(1),CONVAREA+6     Make it displayable         54600000
         MVC   REP1_MGN,CONVAREA            Move to display area        54700000
*                                                                       54800000
         L     R5,DATALENGTH                Load length of message      54900000
         CVD   R5,WORKDWRD                  To packed decimal           55000000
         UNPK  CONVAREA,WORKDWRD+4(4)       Convert to zoned decimal    55100000
         MVZ   CONVAREA+7(1),CONVAREA+6     Make it displayable         55200000
         MVC   REP1_MGL,CONVAREA            Move to display area        55300000
*                                                                       55400000
         LA    R3,BUFFER                    Addr of source data         55500000
         LA    R4,REP1_MSG                  Addr of target area         55600000
         C     R5,BUFFERLENGTH              Message greater than 80     55700000
         BNH   WRITELIN                     Ok to write it              55800000
         L     R5,BUFFERLENGTH              Reset to maximum            55900000
*                                                                       56000000
WRITELIN DS    0H                                                       56100000
         MVC   REP1_MSG,MSGCLEAR            Clear the message           56200000
         C     R5,ZEROREC                   Is message zero length      56300000
         BE    WRITEREP                     Write blank line            56400000
         BCTR  R5,R0                        Reduce by 1 for execute     56500000
         EX    R5,MOVEDATA                  Move data into output rec   56600000
         B     WRITEREP                     Write the message           56700000
*                                                                       56800000
WRITEREP DS    0H                                                       56900000
         MVC   MSGDATA,REP1                 Move in the message         57000000
         BAL   R8,PRTLINE                   Go and print line           57100000
         L     R1,LINENUM                   Current line number         57200000
         LA    R1,1(R1)                     Add one                     57300000
         ST    R1,LINENUM                   Save new value              57400000
         B     MSGSGETS                     Get the next message        57500000
*                                                                       57600000
*-------------------------------------------------------------------*   57700000
* Code segment closes the queue                                     *   57800000
*-------------------------------------------------------------------*   57900000
MSGSCLOS DS    0H                                                       58000000
         LA    R0,MQCO_NONE                 Indicate normal close       58100000
         ST    R0,OPTIONS                   of the queue                58200000
*                                                                       58300000
         CALL MQCLOSE,                                                 X58400000
               (HCONN,                                                 X58500000
               HOBJ,                                                   X58600000
               OPTIONS,                                                X58700000
               COMPCODE,                                               X58800000
               REASON),                                                X58900000
               MF=(E,PARMLIST),VL                                       59000000
*                                                                       59100000
         LA    R0,MQCC_OK                   Expected compcode           59200000
         C     R0,COMPCODE                  As expected?                59300000
         BER   R6                           Yes .. continue             59400000
         MVC   INF4_TYP,=CL10'CLOSE     '                               59500000
         BAL   R7,ERRCODE                   Translate error             59600000
         LA    R0,8                         Set exit code               59700000
         ST    R0,EXITCODE                  To 8                        59800000
         BR    R6                           Return to caller            59900000
*                                                                       60000000
MSGSERR  DS    0H                                                       60100000
         MVC   INF4_TYP,=CL10'GET       '                               60200000
         BAL   R7,ERRCODE                   Translate error             60300000
         LA    R0,8                         Set exit code               60400000
         ST    R0,EXITCODE                  To 8                        60500000
         BR    R6                           Return to caller            60600000
*                                                                       60700000
         EJECT                                                          60800000
********************************************************************    60900000
*  SECTION NAME : MAINDISC                                         *    61000000
*                                                                  *    61100000
*  FUNCTION     : Disconnect from the queue manager                *    61200000
*                                                                  *    61300000
*  CALLED BY    : MAIN                                             *    61400000
*                                                                  *    61500000
*  CALLS        : ERRCODE                                          *    61600000
*                                                                  *    61700000
*  RETURN       : to Register 6                                    *    61800000
*                                                                  *    61900000
********************************************************************    62000000
MAINDISC DS    0H                                                       62100000
         CALL  MQDISC,                                                 X62200000
               (HCONN,                                                 X62300000
               COMPCODE,                                               X62400000
               REASON),                                                X62500000
               MF=(E,PARMLIST),VL                                       62600000
*                                                                       62700000
         LA    R0,MQCC_OK                   Expected compcode           62800000
         C     R0,COMPCODE                  As expected?                62900000
         BER   R6                           Yes .. continue             63000000
         MVC   INF4_TYP,=CL10'DISCONNECT'                               63100000
         BAL   R7,ERRCODE                   Translate error             63200000
         LA    R0,8                         Set exit code               63300000
         ST    R0,EXITCODE                  To 8                        63400000
         BR    R6                           Return to caller            63500000
*                                                                       63600000
         EJECT                                                          63700000
********************************************************************    63800000
*  SECTION NAME : ENDPROG                                          *    63900000
*                                                                  *    64000000
*  FUNCTION     : Program termination                              *    64100000
*                                                                  *    64200000
*  CALLED BY    : MAIN                                             *    64300000
*                                                                  *    64400000
*  CALLS        : PRTLINE                                          *    64500000
*                                                                  *    64600000
*  RETURN       : leaves program                                   *    64700000
*                                                                  *    64800000
********************************************************************    64900000
ENDPROG  DS    0H                                                       65000000
         MVC   SKIPLINE,TWOLINES            Skip a line                 65100000
         MVC   MSGDATA,INF0                 End report message          65200000
         BAL   R8,PRTLINE                   Go and print line           65300000
         CLOSE (SYSPRINT)                   Close output file           65400000
         L     R15,EXITCODE                 Load termination code       65500000
         L     R13,4(R13)                   Readdr caller SAVEAREA      65600000
         ST    R15,16(R13)                  Place in return code        65700000
         LM    R14,R12,12(R13)              Restore registers           65800000
         L     R14,12(,R13)                 Load return address         65900000
         BR    R14                          Return to caller            66000000
*                                                                       66100000
         EJECT                                                          66200000
*********************************************************************   66300000
* SUBROUTINES                                                       *   66400000
*********************************************************************   66500000
*                                                                       66600000
         SPACE 4                                                        66700000
********************************************************************    66800000
*  SECTION NAME : PUTREC                                           *    66900000
*                                                                  *    67000000
*  FUNCTION     : Print a line                                     *    67100000
*                                                                  *    67200000
*  CALLED BY    : PRINTHDR,                                        *    67300000
*                                                                  *    67400000
*  CALLS        : nothing                                          *    67500000
*                                                                  *    67600000
*  RETURN       : to Register 9                                    *    67700000
*                                                                  *    67800000
********************************************************************    67900000
PUTREC   DS    0H                                                       68000000
         LA    R4,THEPUT                    Address of put              68100000
         BSM   0,R4                         Set correct mode            68200000
THEPUT   PUT   SYSPRINT,PRTREC              Get buffer address          68300000
         BSM   0,R9                         Set mode of return          68400000
*                                                                       68500000
         EJECT                                                          68600000
********************************************************************    68700000
*  SECTION NAME : PRINTHDR                                         *    68800000
*                                                                  *    68900000
*  FUNCTION     : Print first header line                          *    69000000
*                                                                  *    69100000
*  CALLED BY    : MAININIT, PRTLINE                                *    69200000
*                                                                  *    69300000
*  CALLS        : PUTREC                                           *    69400000
*                                                                  *    69500000
*  RETURN       : to Register 7                                    *    69600000
*                                                                  *    69700000
********************************************************************    69800000
PRINTHDR DS    0H                                                       69900000
         LA    R1,1                         Load 1 into register        70000000
         ST    R1,LINENUM                   Reset the line number       70100000
         L     R1,PAGENUM                   Get current page number     70200000
         LA    R1,1(R1)                     Increment by 1              70300000
         ST    R1,PAGENUM                   Save again                  70400000
*                                                                       70500000
         CVD   R1,WORKDWRD                  To packed decimal           70600000
         UNPK  CONVAREA,WORKDWRD+4(4)       Convert to zoned decimal    70700000
         MVZ   CONVAREA+7(1),CONVAREA+6     Make it displayable         70800000
         MVC   HDR1_PGE,CONVAREA+4          Move to display area        70900000
*                                                                       71000000
         MVC   HDR1_DTE,REPDATE             Move in the date            71100000
         MVC   PRTDATA,HDR1                 Move record to buffer       71200000
         MVC   PRTCC,NEWPAGE                Carriage control to page    71300000
         BAL   R9,PUTREC                    Write the record            71400000
         BR    R7                                                       71500000
*                                                                       71600000
         EJECT                                                          71700000
********************************************************************    71800000
*  SECTION NAME : PRTLINE                                          *    71900000
*                                                                  *    72000000
*  FUNCTION     : Print the next line                              *    72100000
*                                                                  *    72200000
*  CALLED BY    : MAINPARM, MAINMSGS, ENDPROG, ERRCODE             *    72300000
*                                                                  *    72400000
*  CALLS        : PRINTHDR, PRINTHDG, PUTREC                       *    72500000
*                                                                  *    72600000
*  RETURN       : to Register 8                                    *    72700000
*                                                                  *    72800000
********************************************************************    72900000
PRTLINE  DS    0H                                                       73000000
         L     R1,LINENUM                   Current line number         73100000
         C     R1,MAXLINES                  Reached max lines           73200000
         BNH   PRTLINE1                     No need for new page        73300000
         BAL   R7,PRINTHDR                  Print first heading         73400000
         BAL   R7,PRINTHDG                  Print other headings        73500000
*                                                                       73600000
PRTLINE1 DS    0H                                                       73700000
         MVC   PRTDATA,MSGDATA              Move in the message         73800000
         MVC   PRTCC,SKIPLINE               Indicate skip lines         73900000
         BAL   R9,PUTREC                    Write the record            74000000
         MVC   SKIPLINE,ONELINE             Reset to next line          74100000
         BR    R8                                                       74200000
*                                                                       74300000
         EJECT                                                          74400000
********************************************************************    74500000
*  SECTION NAME : PRINTHDG                                         *    74600000
*                                                                  *    74700000
*  FUNCTION     : Print the remaining header lines                 *    74800000
*                                                                  *    74900000
*  CALLED BY    : PRTLINE, MAINPARM                                *    75000000
*                                                                  *    75100000
*  CALLS        : PUTREC                                           *    75200000
*                                                                  *    75300000
*  RETURN       : to Register 7                                    *    75400000
*                                                                  *    75500000
********************************************************************    75600000
PRINTHDG DS    0H                                                       75700000
         MVC   HDR2_QMN,MQMNAME                                         75800000
         MVC   PRTDATA,HDR2                 Second heading line         75900000
         MVC   PRTCC,TWOLINES               After skip 1 line           76000000
         BAL   R9,PUTREC                    Go and print line           76100000
         L     R1,LINENUM                   Current line number         76200000
         LA    R1,2(R1)                     Add two to line number      76300000
         ST    R1,LINENUM                   Save again                  76400000
*                                                                       76500000
         MVC   HDR3_QUE,MQMQUEUE                                        76600000
         MVC   PRTDATA,HDR3                 Third heading line          76700000
         MVC   PRTCC,ONELINE                After skip 1 line           76800000
         BAL   R9,PUTREC                    Go and print line           76900000
         L     R1,LINENUM                   Current line number         77000000
         LA    R1,1(R1)                     Add one to line number      77100000
         ST    R1,LINENUM                   Save again                  77200000
*                                                                       77300000
         MVC   PRTDATA,HDR4                 Fourth heading line         77400000
         MVC   PRTCC,TWOLINES               After skip 1 line           77500000
         BAL   R9,PUTREC                    Go and print line           77600000
         L     R1,LINENUM                   Current line number         77700000
         LA    R1,2(R1)                     Add one to line number      77800000
         ST    R1,LINENUM                   Save again                  77900000
*                                                                       78000000
         MVC   PRTDATA,HDR5                 Fifth heading line          78100000
         MVC   PRTCC,ONELINE                After skip 1 line           78200000
         BAL   R9,PUTREC                    Go and print line           78300000
         L     R1,LINENUM                   Current line number         78400000
         LA    R1,1(R1)                     Add one to line number      78500000
         ST    R1,LINENUM                   Save again                  78600000
*                                                                       78700000
         MVC   PRTDATA,HDR6                 Second heading line         78800000
         MVC   PRTCC,TWOLINES               After skip 1 line           78900000
         BAL   R9,PUTREC                    Go and print line           79000000
         L     R1,LINENUM                   Current line number         79100000
         LA    R1,2(R1)                     Add two to line number      79200000
         ST    R1,LINENUM                   Save again                  79300000
*                                                                       79400000
         MVI   PRTDATA,C' '                 Blank line                  79500000
         MVC   PRTDATA+1(L'PRTDATA-1),PRTDATA                           79600000
         MVC   PRTCC,ONELINE                After skip 1 line           79700000
         BAL   R9,PUTREC                    Go and print line           79800000
         L     R1,LINENUM                   Current line number         79900000
         LA    R1,1(R1)                     Add one to line number      80000000
         ST    R1,LINENUM                   Save again                  80100000
         BR    R7                           Return to caller            80200000
*                                                                       80300000
         EJECT                                                          80400000
********************************************************************    80500000
*  SECTION NAME : ERRCODE                                          *    80600000
*                                                                  *    80700000
*  FUNCTION     : Print an error message including compcode and    *    80800000
*                 reason                                           *    80900000
*                                                                  *    81000000
*  CALLED BY    : MAINCONN, MAINMSGS, MAINDISC                     *    81100000
*                                                                  *    81200000
*  CALLS        : PRTLINE                                          *    81300000
*                                                                  *    81400000
*  RETURN       : to Register 7                                    *    81500000
*                                                                  *    81600000
********************************************************************    81700000
ERRCODE  DS    0H                                                       81800000
         L     R0,COMPCODE                  Translate compcode          81900000
         CVD   R0,WORKDWRD                  To packed decimal           82000000
         UNPK  CONVAREA,WORKDWRD+4(4)       Convert to zoned decimal    82100000
         MVZ   CONVAREA+7(1),CONVAREA+6     Make it displayable         82200000
         MVC   INF4_CC,CONVAREA+4           Move to display area        82300000
*                                                                       82400000
         L     R0,REASON                    Translate reason            82500000
         CVD   R0,WORKDWRD                  To packed decimal           82600000
         UNPK  CONVAREA,WORKDWRD+4(4)       Convert to zoned decimal    82700000
         MVZ   CONVAREA+7(1),CONVAREA+6     Make it displayable         82800000
         MVC   INF4_RC,CONVAREA+4           Move to display area        82900000
*                                                                       83000000
         L     R1,LINENUM                   Current line number         83100000
         LA    R1,1(R1)                     Add one to line number      83200000
         ST    R1,LINENUM                   Save again                  83300000
         MVC   MSGDATA,INF4                 Move in the message         83400000
         BAL   R8,PRTLINE                   Print the line              83500000
         BR    R7                           Return to caller            83600000
*                                                                       83700000
         EJECT                                                          83800000
*********************************************************************   83900000
* CONSTANTS, DATA STRUCTURES                                        *   84000000
*********************************************************************   84100000
SAVEAREA DS    9D                           Save area                   84200000
PARMSAVE DS    F                            Save area for parms         84300000
NEWPAGE  DC    C'1'                         New page indicator          84400000
ONELINE  DC    C' '                         Write next line             84500000
TWOLINES DC    C'-'                         Write after advance 1       84600000
BUFFERLENGTH DC F'80'                       Buffer size                 84700000
MSGCLEAR DC    CL80' '                      Blank out message           84800000
MAXLINES DC    F'60'                        Max lines per page          84900000
ZEROREC  DC    F'0'                         Check for zero length       85000000
*                                                                       85100000
OBJDESC    CMQODA  DSECT=NO,LIST=NO         Object descriptor           85200000
MSGDESC    CMQMDA  DSECT=NO,LIST=NO         Message descriptor          85300000
GETMSGOPTS CMQGMOA DSECT=NO,LIST=NO         Get message options         85400000
*                                                                       85500000
         SPACE 4                                                        85600000
*********************************************************************   85700000
* EXECUTES                                                          *   85800000
*********************************************************************   85900000
ONLYPARM MVC   0(*-*,R4),1(R1)                                          86000000
MOVEPARM MVC   0(*-*,R4),0(R3)                                          86100000
MOVEDATA MVC   0(*-*,R4),0(R3)                                          86200000
TRANSCAN TRT   0(*-*,R3),TRANTAB                                        86300000
*                                                                       86400000
         SPACE 4                                                        86500000
*********************************************************************   86600000
* TRANSLATE TABLE TO SCAN FOR DELIMETER.                            *   86700000
*********************************************************************   86800000
TRANTAB  DS   0CL256                                                    86900000
         ORG  TRANTAB                                                   87000000
         DC   X'00000000000000000000000000000000'     00 - 0F           87100000
         DC   X'00000000000000000000000000000000'     10 - 1F           87200000
         DC   X'00000000000000000000000000000000'     20 - 2F           87300000
         DC   X'00000000000000000000000000000000'     30 - 3F           87400000
         DC   X'00000000000000000000000000000000'     40 - 4F           87500000
         DC   X'00000000000000000000000000000000'     50 - 5F           87600000
         DC   X'00000000000000000000004000000000'     60 - 6F           87700000
         DC   X'00000000000000000000000000000000'     70 - 7F           87800000
         DC   X'00000000000000000000000000000000'     80 - 8F           87900000
         DC   X'00000000000000000000000000000000'     90 - 9F           88000000
         DC   X'00000000000000000000000000000000'     A0 - AF           88100000
         DC   X'00000000000000000000000000000000'     B0 - BF           88200000
         DC   X'00000000000000000000000000000000'     C0 - CF           88300000
         DC   X'00000000000000000000000000000000'     D0 - DF           88400000
         DC   X'00000000000000000000000000000000'     E0 - EF           88500000
         DC   X'00000000000000000000000000000000'     F0 - FF           88600000
         ORG                                                            88700000
*                                                                       88800000
         EJECT                                                          88900000
*********************************************************************   89000000
* FIELDS USED BY PRINT ROUTINE                                      *   89100000
*********************************************************************   89200000
REPDATE  DS    0CL8                                                     89300000
DATEYR   DS    CL02                                                     89400000
DATEF1   DC    CL01'/'                                                  89500000
DATEJN   DS    CL03                                                     89600000
DATEF2   DC    CL02'  '                                                 89700000
*                                                                       89800000
HDR1     DS    0CL132                       First heading line          89900000
         DC    CL10' '                                                  90000000
HDR1_DTE DS    CL08                                                     90100000
         DC    CL38' '                                                  90200000
         DC    CL19'SAMPLE QUEUE REPORT'                                90300000
         DC    CL38' '                                                  90400000
         DC    CL05'PAGE '                                              90500000
HDR1_PGE DS    CL04                                                     90600000
         DC    CL10' '                                                  90700000
*                                                                       90800000
HDR2     DS    0CL132                       Second heading line         90900000
         DC    CL25' '                                                  91000000
         DC    CL29'MESSAGE QUEUE MANAGER NAME : '                      91100000
HDR2_QMN DS    CL48                                                     91200000
         DC    CL30' '                                                  91300000
*                                                                       91400000
HDR3     DS    0CL132                       Third heading line          91500000
         DC    CL41' '                                                  91600000
         DC    CL13'QUEUE NAME : '                                      91700000
HDR3_QUE DS    CL48                                                     91800000
         DC    CL30' '                                                  91900000
*                                                                       92000000
HDR4     DS    0CL132                       Fourth heading line         92100000
         DC    CL12' '                                                  92200000
         DC    CL08'RELATIVE'                                           92300000
         DC    CL112' '                                                 92400000
*                                                                       92500000
HDR5     DS    0CL132                       Fifth heading line          92600000
         DC    CL12' '                                                  92700000
         DC    CL07'MESSAGE'                                            92800000
         DC    CL113' '                                                 92900000
*                                                                       93000000
HDR6     DS    0CL132                       Sixth heading line          93100000
         DC    CL11' '                                                  93200000
         DC    CL18' NUMBER   LENGTH '                                  93300000
         DC    CL33'---------------------------------'                  93400000
         DC    CL14' MESSAGE DATA '                                     93500000
         DC    CL33'---------------------------------'                  93600000
         DC    CL23' '                                                  93700000
*                                                                       93800000
REP1     DS    0CL132                       First report line           93900000
         DC    CL11' '                                                  94000000
REP1_MGN DS    CL08                                                     94100000
         DC    CL01' '                                                  94200000
REP1_MGL DS    CL08                                                     94300000
         DC    CL01' '                                                  94400000
REP1_MSG DS    CL80                                                     94500000
         DC    CL20' '                                                  94600000
*                                                                       94700000
INF0     DS    0CL132                                                   94800000
         DC    CL48' '                                                  94900000
         DC    CL35'********** END OF REPORT **********'                95000000
         DC    CL49' '                                                  95100000
*                                                                       95200000
INF1     DS    0CL132                                                   95300000
         DC    CL10' '                                                  95400000
         DC    CL46'********** NO DATA PASSED TO PROGRAM. PROGRAM '     95500000
         DC    CL46'REQUIRES A QUEUE MANAGER NAME AND A QUEUE NAME'     95600000
         DC    CL30'. **********                  '                     95700000
*                                                                       95800000
INF2     DS    0CL132                                                   95900000
         DC    CL25' '                                                  96000000
         DC    CL46'********** NO QUEUE MANAGER NAME PASSED TO PRO'     96100000
         DC    CL25'GRAM - DEFAULT USED *****'                          96200000
         DC    CL36' '                                                  96300000
*                                                                       96400000
INF3     DS    0CL132                                                   96500000
         DC    CL38' '                                                  96600000
         DC    CL10'**********'                                         96700000
         DC    CL34' NO QUEUE NAME PASSED TO PROGRAM. '                 96800000
         DC    CL10'**********'                                         96900000
         DC    CL40' '                                                  97000000
*                                                                       97100000
INF4     DS    0CL132                                                   97200000
         DC    CL13' '                                                  97300000
         DC    CL32'********** AN ERROR OCCURRED IN '                   97400000
INF4_TYP DS    CL10                                                     97500000
         DC    CL20'. COMPLETION CODE = '                               97600000
INF4_CC  DS    CL04                                                     97700000
         DC    CL16' REASON CODE = '                                    97800000
INF4_RC  DS    CL04                                                     97900000
         DC    CL33' **********                      '                  98000000
*                                                                       98100000
         EJECT                                                          98200000
*********************************************************************   98300000
* DCBS ETC                                                          *   98400000
*********************************************************************   98500000
         PRINT NOGEN                                                    98600000
SYSPRINT DCB   DDNAME=SYSPRINT,                                        X98700000
               DSORG=PS,,                                              X98800000
               LRECL=133,                                              X98900000
               BLKSIZE=7980,                                           X99000000
               MACRF=PM,                                               X99100000
               RECFM=FBA                                                99200000
*                                                                       99300000
PRINTOPN OPEN (SYSPRINT,(OUTPUT)),MODE=31,MF=L                          99400000
*                                                                       99500000
         PRINT GEN                                                      99600000
         LTORG                                                          99700000
*                                                                       99800000
         END                                                            99900000

END_PROGRAM