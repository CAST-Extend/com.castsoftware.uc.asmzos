BEGIN_PROGRAM(CSQ4CAC1)
         TITLE 'CSQ4CAC1 - SAMPLE INQUIRE AND SET CICS TRANSACTION'     00100000
********************************************************************    00200000
* File Name:     CSQ4CAC1                                          *    00300000
*                                                                  *    00400000
* @START_COPYRIGHT@                                                *    00500000
*   Statement:     Licensed Materials - Property of IBM            *    00600000
*                                                                  *    00700000
*                  5695-137                                        *    00760000
*                  (C) Copyright IBM Corporation. 1993, 1997       *    00800000
*                                                                  *    00900000
*   Status:        Version 1 Release 2                             *    01000000
* @END_COPYRIGHT@                                                  *    01200000
*                                                                  *    01300000
* Environment:   CICS/ESA Version 3.3; BAL                         *    01400000
*                                                                  *    01500000
* CICS transaction name : MAC1 (in supplied definitions, this      *    01600000
*                          is changed in the code to the           *    01700000
*                          calling transaction name)               *    01800000
*                                                                  *    01900000
* Description:  Sample program to set and inquire about            *    02000000
*               two queue attributes                               *    02100000
*                                                                  *    02200000
* Function:     This is a CICS conversational program which        *    02300000
*               allows the user to set and inquire about the       *    02400000
*               INHIBIT_PUT and INHIBIT_GET attributes of a        *    02500000
*               queue                                              *    02600000
*                                                                  *    02700000
* Restrictions: The queue name must start with 'CSQ4SAMP'          *    02800000
*               This is to avoid any accidental interference with  *    02900000
*               other queues at user's installation                *    03000000
*                                                                  *    03100000
*               The queue names are translated to upper case       *    03200000
*                                                                  *    03300000
*                                                                  *    03400000
* Dependencies: A CICS MAP is required: CSQ4ACM                    *    03500000
*                                                                  *    03600000
********************************************************************    03700000
         EJECT                                                          03800000
********************************************************************    03900000
*                                                                  *    04000000
* ENTRY POINT =  CSQ4CAC1                                          *    04100000
*                                                                  *    04200000
*    INPUT  = PARAMETERS EXPLICITLY PASSED TO THIS FUNCTION:       *    04300000
*             = NONE                                               *    04400000
*                                                                  *    04500000
*    OUTPUT  = PARAMETERS EXPLICITLY RETURNED:                     *    04600000
*             = NONE                                               *    04700000
*                                                                  *    04800000
********************************************************************    04900000
*                                                                  *    05000000
* REGISTER USAGE :                                                 *    05100000
*         REGISTER R0  is work register                            *    05200000
*         REGISTER R1  is DFHEIPL                                  *    05300000
*         REGISTER R2  is not used                                 *    05400000
*         REGISTER R3  is base address register                    *    05500000
*         REGISTER R4  is CODES return address                     *    05600000
*         REGISTER R5  is INITIAL, PROCESS, ENDPROG return address *    05700000
*         REGISTER R6  is UPDATE, INQUIRE return address           *    05800000
*         REGISTER R7  is OPEN, CLOSE return address               *    05900000
*         REGISTER R8  is not used                                 *    06000000
*         REGISTER R9  is not used                                 *    06100000
*         REGISTER R10 is not used                                 *    06200000
*         REGISTER R11 is DFHEIBR                                  *    06300000
*         REGISTER R12 is not used                                 *    06400000
*         REGISTER R13 is automatic storage address register       *    06500000
*         REGISTER R14 is return address/work register             *    06600000
*         REGISTER R15 is work register                            *    06700000
*                                                                  *    06800000
********************************************************************    06900000
*                                                                  *    07000000
* EXECUTABLE MACROS                                                *    07100000
*    CALL   -  To execute MQCONN, MQOPEN, MQINQ, MQSET,            *    07200000
*                            MQCLOSE, MQDISC                       *    07300000
*              -  Needs ',MF=(E,CALLLIST)' to enable code to be    *    07400000
*                 reentrant                                        *    07500000
*              -  Needs ',VL' so diagnostic facilities             *    07600000
*                 know how long the parameter list is.             *    07700000
*                                                                  *    07800000
*    DFHEIENT  -  To obtain dynamic storage                        *    07900000
*                                                                  *    08000000
********************************************************************    08100000
*                                                                  *    08200000
* NOTES:                                                           *    08300000
*       Key usage in program:-                                     *    08400000
*         ENTER   - Process information                            *    08500000
*         PF1/13  - Display Help screen                            *    08600000
*         PF3/15  - Terminate program                              *    08700000
*         Other function keys - redisplay the map                  *    08800000
*       Key usage in Help screen:-                                 *    08900000
*         PF12/24 - Terminate program                              *    09000000
*         Other function keys - redisplay the map                  *    09100000
*                                                                  *    09200000
*       No checking is done of CICS return codes, the program      *    09300000
*       will abend if any problems occur; this is because          *    09400000
*       the purpose of the code is to show MQ calls, not CICS      *    09500000
*       error handling                                             *    09600000
*                                                                  *    09700000
********************************************************************    09800000
         EJECT                                                          09900000
********************************************************************    10000000
*                                                                       10100000
*                         Program logic                                 10200000
*                         -------------                                 10300000
*                                                                       10400000
*        Start    (MAIN SECTION)                                        10500000
*        -----                                                          10600000
*           Initialize                                                  10700000
*                                                                       10800000
*           Process                                                     10900000
*            Do while end key not pressed                               11000000
*               Display the screen map and wait for input data          11100000
*               If help key pressed                                     11200000
*                  display help screen                                  11300000
*               Else                                                    11400000
*                  If queue name does not begin with 'CSQ4SAMP',        11500000
*                     build error message                               11600000
*                  Else                                                 11700000
*                     Evaluate request                                  11800000
*                        When 'INQUIRE'  perform INQUIRE                11900000
*                        When 'INHIBIT'  perform UPDATE                 12000000
*                        When 'ALLOW'    perform UPDATE                 12100000
*                        Otherwise build error message                  12200000
*                     End-evaluate                                      12300000
*                  End-if                                               12400000
*               End-if                                                  12500000
*            End-do                                                     12600000
*                                                                       12700000
*           EndProg                                                     12800000
*            Clear the screen                                           12900000
*            Return to CICS                                             13000000
*                                                                       13100000
*        INQUIRE                                                        13200000
*        -------                                                        13300000
*            Perform OPEN                                               13400000
*            If open is successful                                      13500000
*               Inquire about INHIBIT-GET and INHIBIT-PUT attributes    13600000
*                  If inquire is successful                             13700000
*                     Build response screen                             13800000
*                  Else                                                 13900000
*                     Build error message                               14000000
*                  End-if                                               14100000
*               Perform CLOSE                                           14200000
*            End-if                                                     14300000
*            Return to caller                                           14400000
*                                                                       14500000
*        UPDATE                                                         14600000
*        ------                                                         14700000
*            Perform OPEN                                               14800000
*            If open is successful                                      14900000
*               If INHIBIT                                              15000000
*                  Set INHIBIT-GET attribute to GET-INHIBITED           15100000
*                  Set INHIBIT-PUT attribute to PUT-INHIBITED           15200000
*                  If set is successful                                 15300000
*                     Build response screen                             15400000
*                  Else                                                 15500000
*                     Build error message                               15600000
*                  End-if                                               15700000
*               Else  (ALLOW)                                           15800000
*                  Set INHIBIT-GET attribute to GET-ALLOWED             15900000
*                  Set INHIBIT-PUT attribute to PUT-ALLOWED             16000000
*                  If set is successful                                 16100000
*                     Build response screen                             16200000
*                  Else                                                 16300000
*                     Build error message                               16400000
*                  End-if                                               16500000
*               End-if                                                  16600000
*               Perform CLOSE                                           16700000
*            End-if                                                     16800000
*            Return to caller                                           16900000
*                                                                       17000000
*                                                                       17100000
*        OPEN                                                           17200000
*        ----                                                           17300000
*            Initialize the Object Descriptor (MQOD) structure          17400000
*            Set the open options for inquire and set                   17500000
*            Open the queue                                             17600000
*               If open is not successful                               17700000
*                  Build error message                                  17800000
*               End-if                                                  17900000
*            Return to caller                                           18000000
*                                                                       18100000
*        CLOSE                                                          18200000
*        -----                                                          18300000
*            Close the queue                                            18400000
*               If close is not successful                              18500000
*                  Build error message                                  18600000
*               End-if                                                  18700000
*            Return to caller                                           18800000
*                                                                       18900000
*        CODES                                                          19000000
*        -----                                                          19100000
*            (CODES is called when an error message contains            19200000
*             compcode and reason)                                      19300000
*            Convert compcode to displayable format                     19400000
*            Convert reason to displayable format                       19500000
*            Return to caller                                           19600000
*                                                                       19700000
* *************************************************************         19800000
         EJECT                                                          19900000
*                                                                       20000000
DFHEISTG DSECT                                                          20100000
*                                                                       20200000
         COPY  CSQ4ACM                      Get the MAP references      20300000
*                                                                       20400000
         EJECT                                                          20500000
*                                                                       20600000
M00_MSG  DS     CL79                        Current output message      20700000
M00_MSG4 DS     0CL79                       General error message       20800000
M00_4_OP DS     CL08                        Operation identifier        20900000
         DS     CL25                                                    21000000
M00_4_CC DS     CL08                        Completion Code             21100000
         DS     CL09                                                    21200000
M00_4_RC DS     CL08                        Reason                      21300000
         DS     CL21                                                    21400000
*                                                                       21500000
OBJDESC  CMQODA LIST=YES                    Working object descriptor   21600000
*                                                                       21700000
SELECTORCOUNT   DS F                        Number of selectors         21800000
INTATTRCOUNT    DS F                        Number of int attributes    21900000
CHARATTRLENGTH  DS F                        char attributes length      22000000
CHARATTRS       DS C                        Area for char attributes    22100000
*                                                                       22200000
OPTIONS  DS   F                             Command options             22300000
HCONN    DS   F                             Handle of connection        22400000
HOBJ     DS   F                             Handle of object            22500000
COMPCODE DS   F                             Completion code             22600000
REASON   DS   F                             Reason code                 22700000
SELECTOR DS   2F                            Array of selectors          22800000
INTATTRS DS   2F                            Array of int attributes     22900000
*                                                                       23000000
ACTION   DS   CL08                          Action on queue             23100000
OBJECT   DS   CL(MQ_Q_NAME_LENGTH)          Name of queue               23200000
DWORD    DS   D                             Work field                  23300000
UPDTYPE  DS   CL11                          Data store                  23400000
*                                                                       23500000
CALLLIST CALL ,(0,0,0,0,0,0,0,0,0,0,0),VL,MF=L                          23600000
*                                                                       23700000
********************************************************************    23800000
*                   PROGRAM EXECUTION STARTS HERE                  *    23900000
********************************************************************    24000000
         EJECT                                                          24100000
********************************************************************    24200000
*  Code start                                                      *    24300000
********************************************************************    24400000
*                                                                  *    24500000
*  Macro DFHEIENT is used to obtain working storage.               *    24600000
*  In our example a single register for code (R3) and              *    24700000
*   storage (R13) is sufficient                                    *    24800000
*                                                                  *    24900000
********************************************************************    25000000
CSQ4CAC1 DFHEIENT CODEREG=(R3),DATAREG=(R13)                            25100000
         B     MAIN                                                     25200000
         DC    C'MQSeries for MVS/ESA SAMPLE PROGRAM  '                 25300000
         DC    C'NAME : '                                               25400000
         DC    C'CSQ4CAC1'                                              25500000
         DC    C' DATE AND TIME ASSEMBLED : '                           25600000
         DC    C'&SYSDATE',C','                                         25700000
         DC    C'&SYSTIME '                                             25800000
         DC    C'&SYSPARM '                                             25900000
*                                                                       26000000
         SPACE 4                                                        26100000
********************************************************************    26200000
*  SECTION NAME : MAIN                                             *    26300000
*                                                                  *    26400000
*  FUNCTION     : Controls flow of program                         *    26500000
*                                                                  *    26600000
*  CALLED BY    : CSQ4CAC1 CSECT                                   *    26700000
*                                                                  *    26800000
*  CALLS        : INITIAL, PROCESS, ENDPROG                        *    26900000
*                                                                  *    27000000
********************************************************************    27100000
MAIN     DS    0H                                                       27200000
         BAS   R5,INITIAL                                               27300000
         BAS   R5,PROCESS                                               27400000
         BAS   R5,ENDPROG                                               27500000
*                                                                       27600000
         EXEC CICS RETURN                                               27700000
*                                                                       27800000
         EJECT                                                          27900000
********************************************************************    28000000
*  SECTION NAME : INITIAL                                          *    28100000
*                                                                  *    28200000
*  FUNCTION     : Performs initialization                          *    28300000
*                                                                  *    28400000
*  CALLED BY    : MAIN                                             *    28500000
*                                                                  *    28600000
*  CALLS        : NONE                                             *    28700000
*                                                                  *    28800000
*  RETURN       : To Register 5                                    *    28900000
*                                                                  *    29000000
********************************************************************    29100000
INITIAL  DS    0H                                                       29200000
*                                                                  *    29300000
*        Connection handle                                         *    29400000
*                                                                  *    29500000
         LA   R0,MQHC_DEF_HCONN             Set default value           29600000
         ST   R0,HCONN                      Place in field              29700000
*                                                                  *    29800000
*        MESSAGE FIELD                                             *    29900000
*                                                                  *    30000000
         MVI   M00_MSG,X'40'               Move in first character      30100000
         MVC   M00_MSG+1(L'M00_MSG-1),M00_MSG  and initialize           30200000
         MVC   M00_MSG4,M01_MSG4                                        30300000
*                                                                  *    30400000
*        OBJECT DESCRIPTOR FIELDS                                  *    30500000
*                                                                  *    30600000
         MVC   OBJDESC_AREA,CONST_MQOD_AREA Initialize from constant    30700000
*                                                                       30800000
         EXEC  CICS IGNORE CONDITION MAPFAIL                            30900000
*                                                                       31000000
         BR    R5                          Return to MAIN process       31100000
*                                                                       31200000
         EJECT                                                          31300000
********************************************************************    31400000
*  SECTION NAME : PROCESS                                          *    31500000
*                                                                  *    31600000
*  FUNCTION     : Performs main processing                         *    31700000
*                                                                  *    31800000
*  CALLED BY    : MAIN                                             *    31900000
*                                                                  *    32000000
*  CALLS        : INQUIRE, INHIBIT, ALLOW                          *    32100000
*                                                                  *    32200000
*  RETURN       : To Register 5                                    *    32300000
*                                                                  *    32400000
********************************************************************    32500000
PROCESS  DS   0H                                                        32600000
         MVC  QAC1MSO,M00_MSG                Put current message in map 32700000
         MVC  QTRNIDO,EIBTRNID               Move in transaction name   32800000
         MVC  QTRNHO,EIBTRNID                Move in transaction name   32900000
*                                                                       33000000
         EXEC CICS SEND MAP(MAPID)                                     C33100000
              MAPSET(MAPSETID)                                         C33200000
              FROM(CSQ4AC1O)                                           C33300000
              ERASE                                                     33400000
*                                                                       33500000
         EXEC CICS RECEIVE MAP(MAPID)                                  C33600000
              MAPSET(MAPSETID)                                         C33700000
              INTO(CSQ4AC1I)                                            33800000
*                                                                       33900000
         CLI  EIBAID,DFHPF1                 Help key pressed?           34000000
         BE   CMDHLP                                                    34100000
*                                                                       34200000
         CLI  EIBAID,DFHPF13                Help key pressed?           34300000
         BE   CMDHLP                                                    34400000
*                                                                       34500000
         CLI  EIBAID,DFHPF3                 End key pressed?            34600000
         BER  R5                            Return to caller            34700000
*                                                                       34800000
         CLI  EIBAID,DFHPF15                End key pressed?            34900000
         BER  R5                            Return to caller            35000000
*                                                                       35100000
         CLI  EIBAID,DFHENTER               Enter key pressed           35200000
         BNE  PROCESS                       if not - go back again      35300000
*                                                                       35400000
         MVI  M00_MSG,X'40'                Move in first character      35500000
         MVC  M00_MSG+1(L'M00_MSG-1),M00_MSG  and initialize            35600000
*                                                                       35700000
         MVC  ACTION,QACTNI                 Get action and object       35800000
         MVC  OBJECT,QNAMEI                 name from MAP               35900000
*                                                                       36000000
* ---------------------------------------------------------- *          36100000
*                 START OF RESTRICTION                                  36200000
*                                                                       36300000
*   OBJECT - The first 8 bytes must contain 'CSQ4SAMP'                  36400000
*                                                                       36500000
*   To remove this restriction, delete the next five lines              36600000
*                                                                       36700000
         CLC  QPREFIX,OBJECT                Valid queue for sample?     36800000
         BE   CMDINQ                        yes continue                36900000
*                                                                       37000000
         MVC  M00_MSG,M01_MSG5              Put restricted queue msg    37100000
         B    PROCESS                       Go and display message      37200000
*                                                                       37300000
*                 END OF RESTRICTION                                    37400000
* ---------------------------------------------------------- *          37500000
*                                                                       37600000
CMDINQ   DS   0H                                                        37700000
         CLC  ACTION,CINQUI                 Is it an inquire?           37800000
         BNE  CMDINH                        No .. try another           37900000
         BAS  R6,INQUIRE                    Yes                         38000000
         B    PROCESS                       Go around again             38100000
*                                                                       38200000
CMDINH   DS   0H                                                        38300000
         CLC  ACTION,CINHIB                 Is it an inhibit?           38400000
         BNE  CMDALW                        No .. try another           38500000
         BAS  R6,UPDATE                     Yes                         38600000
         B    PROCESS                       Go around again             38700000
*                                                                       38800000
CMDALW   DS   0H                                                        38900000
         CLC  ACTION,CALLOW                 Is it an allow?             39000000
         BNE  CMDERR                        No .. must be an error      39100000
         BAS  R6,UPDATE                     Yes                         39200000
         B    PROCESS                       Go around again             39300000
*                                                                       39400000
CMDERR   DS   0H                                                        39500000
         MVC  M00_MSG,M01_MSG1              Invalid request             39600000
         B    PROCESS                       Go around again             39700000
*                                                                       39800000
CMDHLP   DS   0H                                                        39900000
*                                                                       40000000
         EXEC CICS SEND MAP(MAPIDHLP)                                  C40100000
              MAPSET(MAPSETID)                                         C40200000
              FROM(CSQ4AC2O)                                           C40300000
              ERASE                                                     40400000
*                                                                       40500000
         EXEC CICS RECEIVE MAP(MAPIDHLP)                               C40600000
              MAPSET(MAPSETID)                                         C40700000
              INTO(CSQ4AC2I)                                            40800000
*                                                                       40900000
         CLI  EIBAID,DFHPF12                Cancel key pressed          41000000
         BE   PROCESS                       Yes - go to process again   41100000
*                                                                       41200000
         CLI  EIBAID,DFHPF24                Cancel key pressed          41300000
         BE   PROCESS                       Yes - go to process again   41400000
         B    CMDHLP                        No  - stay in help loop     41500000
*                                                                       41600000
         EJECT                                                          41700000
********************************************************************    41800000
*  SECTION NAME : ENDPROG                                          *    41900000
*                                                                  *    42000000
*  FUNCTION     : Tidies up and returns control to CICS            *    42100000
*                                                                  *    42200000
*  CALLED BY    : MAIN                                             *    42300000
*                                                                  *    42400000
*  CALLS        : NONE                                             *    42500000
*                                                                  *    42600000
*  RETURN       : To Register 5                                    *    42700000
*                                                                  *    42800000
********************************************************************    42900000
ENDPROG  DS   0H                                                        43000000
         MVI  M00_MSG,X'40'                Move in first character      43100000
         MVC  M00_MSG+1(L'M00_MSG-1),M00_MSG  clear the message field   43200000
         MVC  M00_MSG,M01_MSG7             Set termination message      43300000
*                                                                       43400000
         EXEC CICS SEND TEXT NOEDIT FROM(M00_MSG) ERASE FREEKB         C43500000
              LENGTH(SENDLEN)                                           43600000
*                                                                       43700000
         BR    R5                          Return to caller             43800000
*                                                                       43900000
         EJECT                                                          44000000
********************************************************************    44100000
*  SECTION NAME : UPDATE                                           *    44200000
*                                                                  *    44300000
*  FUNCTION     : Set get and put to inhibited or allowed          *    44400000
*                                                                  *    44500000
*  CALLED BY    : PROCESS                                          *    44600000
*                                                                  *    44700000
*  CALLS        : OPEN, CLOSE, CODES                               *    44800000
*                                                                  *    44900000
*  RETURN       : To Register 6                                    *    45000000
*                                                                  *    45100000
********************************************************************    45200000
UPDATE   DS   0H                                                        45300000
         BAS  R7,OPEN                       Open the queue              45400000
*                                                                       45500000
         LA   R0,MQCC_OK                    Load expected compcode      45600000
         C    R0,COMPCODE                   Was open successful         45700000
         BNER R6                            No ... return to caller     45800000
*                                                                       45900000
*        Initialize the variables for the set call                      46000000
*                                                                       46100000
         SR   R0,R0                         Clear register zero         46200000
         ST   R0,CHARATTRLENGTH             Set char length to zero     46300000
         LA   R0,2                          Load to set                 46400000
         ST   R0,SELECTORCOUNT              selectors add               46500000
         ST   R0,INTATTRCOUNT               integer attributes          46600000
*                                                                       46700000
         LA   R0,MQIA_INHIBIT_GET           Load q attribute selector   46800000
         ST   R0,SELECTOR+0                 Place in field              46900000
         LA   R0,MQIA_INHIBIT_PUT           Load q attribute selector   47000000
         ST   R0,SELECTOR+4                 Place in field              47100000
*                                                                       47200000
UPDTEST  DS   0H                                                        47300000
         CLC  ACTION,CINHIB                 Are we inhibiting?          47400000
         BE   UPDINHBT                      Yes branch to section       47500000
*                                                                       47600000
         CLC  ACTION,CALLOW                 Are we allowing?            47700000
         BE   UPDALLOW                      Yes branch to section       47800000
*                                                                       47900000
         MVC  M00_MSG,M01_MSG1              Invalid request             48000000
         BR   R6                            Return to caller            48100000
*                                                                       48200000
UPDINHBT DS   0H                                                        48300000
         MVC  UPDTYPE,CINHIBIT              Indicate action type        48400000
         LA   R0,MQQA_GET_INHIBITED         Load attribute value        48500000
         ST   R0,INTATTRS+0                 Place in field              48600000
         LA   R0,MQQA_PUT_INHIBITED         Load attribute value        48700000
         ST   R0,INTATTRS+4                 Place in field              48800000
         B    UPDCALL                       Go and do call              48900000
*                                                                       49000000
UPDALLOW DS   0H                                                        49100000
         MVC  UPDTYPE,CALLOWED              Indicate action type        49200000
         LA   R0,MQQA_GET_ALLOWED           Load attribute value        49300000
         ST   R0,INTATTRS+0                 Place in field              49400000
         LA   R0,MQQA_PUT_ALLOWED           Load attribute value        49500000
         ST   R0,INTATTRS+4                 Place in field              49600000
         B    UPDCALL                       Go and do call              49700000
*                                                                       49800000
UPDCALL  DS   0H                                                        49900000
         CALL MQSET,                                                   C50000000
               (HCONN,                                                 C50100000
               HOBJ,                                                   C50200000
               SELECTORCOUNT,                                          C50300000
               SELECTOR,                                               C50400000
               INTATTRCOUNT,                                           C50500000
               INTATTRS,                                               C50600000
               CHARATTRLENGTH,                                         C50700000
               CHARATTRS,                                              C50800000
               COMPCODE,                                               C50900000
               REASON),                                                C51000000
               VL,MF=(E,CALLLIST)                                       51100000
*                                                                       51200000
         LA   R0,MQCC_OK                    Load expected compcode      51300000
         C    R0,COMPCODE                   Was set successful?         51400000
         BE   CHKSET                        YES                         51500000
*                                                                       51600000
         MVC  M00_4_OP,OP_SET               Error ... construct message 51700000
         BAS  R4,CODES                      Translate codes             51800000
         MVC  M00_MSG,M00_MSG4              Move in general error msg   51900000
         B    ENDSET                        Branch to section exit      52000000
*                                                                       52100000
CHKSET   DS   0H                                                        52200000
         MVC  QGSTATO,UPDTYPE               Move new status for get     52300000
         MVC  QPSTATO,UPDTYPE               Move new status for put     52400000
         B    ENDSET                        Branch to section exit      52500000
*                                                                       52600000
ENDSET   DS   0H                                                        52700000
         BAS  R7,CLOSE                      Close the queue             52800000
         BR   R6                            Return to caller            52900000
*                                                                       53000000
         EJECT                                                          53100000
********************************************************************    53200000
*  SECTION NAME : INQUIRE                                          *    53300000
*                                                                  *    53400000
*  FUNCTION     : Inquires on the objects attributes               *    53500000
*                                                                  *    53600000
*  CALLED BY    : PROCESS                                          *    53700000
*                                                                  *    53800000
*  CALLS        : OPEN, CLOSE, CODES                               *    53900000
*                                                                  *    54000000
*  RETURN       : To Register 6                                    *    54100000
*                                                                  *    54200000
********************************************************************    54300000
INQUIRE  DS   0H                                                        54400000
         BAS  R7,OPEN                       Open the queue              54500000
*                                                                       54600000
         LA   R0,MQCC_OK                    Load expected compcode      54700000
         C    R0,COMPCODE                   Was open successful?        54800000
         BNER R6                            No ... return to caller     54900000
*                                                                       55000000
*        Initialize the variables for the inquire call                  55100000
*                                                                       55200000
         SR   R0,R0                         Clear register zero         55300000
         ST   R0,CHARATTRLENGTH             Set char length to zero     55400000
         LA   R0,2                          Load to set                 55500000
         ST   R0,SELECTORCOUNT              selectors add               55600000
         ST   R0,INTATTRCOUNT               integer attributes          55800000
*                                                                       56000000
         LA   R0,MQIA_INHIBIT_GET           Load attribute value        56200000
         ST   R0,SELECTOR+0                 Place in field              56400000
         LA   R0,MQIA_INHIBIT_PUT           Load attribute value        56600000
         ST   R0,SELECTOR+4                 Place in field              56800000
*                                                                       57000000
         CALL MQINQ,                                                   C57200000
               (HCONN,                                                 C57400000
               HOBJ,                                                   C57600000
               SELECTORCOUNT,                                          C57800000
               SELECTOR,                                               C58000000
               INTATTRCOUNT,                                           C58200000
               INTATTRS,                                               C58400000
               CHARATTRLENGTH,                                         C58600000
               CHARATTRS,                                              C58800000
               COMPCODE,                                               C59000000
               REASON),                                                C59200000
               VL,MF=(E,CALLLIST)                                       59400000
*                                                                       59600000
         LA   R0,MQCC_OK                    Load expected compcode      59800000
         C    R0,COMPCODE                   Was inquire successful?     60000000
         BE   CHKGET                        Yes                         60200000
*                                                                       60400000
         MVC  M00_4_OP,OP_INQ               Error ... construct message 60600000
         BAS  R4,CODES                      Translate codes             60800000
         MVC  M00_MSG,M00_MSG4              Move in general error msg   61000000
         B    ENDINQ                        Branch to section exit      61200000
*                                                                       61400000
CHKGET   DS   0H                                                        61600000
         MVC  QGSTATO,CINHIBIT              Set to inhibit              61800000
         LA   R0,MQQA_GET_ALLOWED           Check get is allowed        62000000
         C    R0,INTATTRS+0                 Is it allowed?              62200000
         BNE  CHKPUT                        No .. bypass move           62400000
         MVC  QGSTATO,CALLOWED              Indicate get is allowed     62600000
*                                                                       62800000
CHKPUT   DS   0H                                                        63000000
         MVC  QPSTATO,CINHIBIT              Set to inhibit              63200000
         LA   R0,MQQA_PUT_ALLOWED           Check put is allowed        63400000
         C    R0,INTATTRS+4                 Is it allowed               63600000
         BNE  ENDINQ                        NO .. BYPASS MOVE           63800000
         MVC  QPSTATO,CALLOWED              Indicate put is allowed     64000000
*                                                                       64200000
ENDINQ   DS   0H                                                        64400000
         BAS  R7,CLOSE                      Close the queue             64600000
         BR   R6                            Return to caller            64800000
*                                                                       65000000
         EJECT                                                          65200000
********************************************************************    65400000
* SUBROUTINES                                                      *    65600000
********************************************************************    65800000
*                                                                  *    66000000
********************************************************************    66200000
*  SECTION NAME : OPEN                                             *    66400000
*                                                                  *    66600000
*  FUNCTION     : To open the object                               *    66800000
*                                                                  *    67000000
*  CALLED BY    : UPDATE, INQUIRE                                  *    67200000
*                                                                  *    67400000
*  CALLS        : CODES                                            *    67600000
*                                                                  *    67800000
*  RETURN       : To Register 7                                    *    68000000
*                                                                  *    68200000
********************************************************************    68400000
OPEN     DS   0H                            Open the object             68600000
         LA   R0,MQOT_Q                     Set object type             68800000
         ST   R0,OBJDESC_OBJECTTYPE         to queue                    69000000
         MVC  OBJDESC_OBJECTNAME,OBJECT     Move in queue name          69200000
*                                                                       69400000
         LA   R0,MQOO_INQUIRE+MQOO_SET      Open for inquire            69600000
         ST   R0,OPTIONS                    and set                     69800000
*                                                                       70000000
         CALL MQOPEN,                                                  C70200000
               (HCONN,                                                 C70400000
               OBJDESC,                                                C70600000
               OPTIONS,                                                C70800000
               HOBJ,                                                   C71000000
               COMPCODE,                                               C71200000
               REASON),                                                C71400000
               MF=(E,CALLLIST),VL                                       71600000
*                                                                       71800000
         LA   R0,MQCC_OK                    Load expected code          72000000
         C    R0,COMPCODE                   Code as expected?           72200000
         BE   ENDOPEN                       Yes ... branch to exit      72400000
*                                                                       72600000
OPENEVAL DS   0H                            Evaluate error              72800000
         L    R0,=AL4(MQRC_Q_MGR_NOT_AVAILABLE) Load                    73000000
         C    R0,REASON                     Special error?              73200000
         BE   OPENCONN                      Yes .. display MSG6         73400000
         L    R0,=AL4(MQRC_CONNECTION_BROKEN) Load                      73600000
         C    R0,REASON                     Special error?              73800000
         BE   OPENCONN                      Yes .. display MSG6         74000000
         L    R0,=AL4(MQRC_UNKNOWN_OBJECT_NAME) Load                    74200000
         C    R0,REASON                     Special error?              74400000
         BE   OPENUNKN                      Yes .. display MSG2         74600000
         L    R0,=AL4(MQRC_NOT_AUTHORIZED)  Load                        74800000
         C    R0,REASON                     Special error?              75000000
         BE   OPENAUTH                      Yes .. display MSG3         75200000
         B    OPENGENL                      General error               75400000
*                                                                       75600000
OPENCONN DS   0H                                                        75800000
         MVC  M00_MSG,M01_MSG6              Move in connection err msg  76000000
         B    ENDOPEN                       Branch to section exit      76200000
*                                                                       76400000
OPENUNKN DS   0H                                                        76600000
         MVC  M00_MSG,M01_MSG2              Move in unknown q error msg 76800000
         B    ENDOPEN                       Branch to section exit      77000000
*                                                                       77200000
OPENAUTH DS   0H                                                        77400000
         MVC  M00_MSG,M01_MSG3              Move in authorization error 77600000
         B    ENDOPEN                       Branch to section exit      77800000
*                                                                       78000000
OPENGENL DS   0H                                                        78200000
         MVC  M00_4_OP,OP_OPEN              Error ... construct message 78400000
         BAS  R4,CODES                      Translate codes             78600000
         MVC  M00_MSG,M00_MSG4              Move in general error msg   78800000
         B    ENDOPEN                       Branch to section exit      79000000
*                                                                       79200000
ENDOPEN  DS   0H                                                        79400000
         BR   R7                            Return to caller            79600000
*                                                                       79800000
         EJECT                                                          80000000
********************************************************************    80200000
*  SECTION NAME : CLOSE                                            *    80400000
*                                                                  *    80600000
*  FUNCTION     : To close the object                              *    80800000
*                                                                  *    81000000
*  CALLED BY    : UPDATE, INQUIRE                                  *    81200000
*                                                                  *    81400000
*  CALLS        : CODES                                            *    81600000
*                                                                  *    81800000
*  RETURN       : To Register 7                                    *    82000000
*                                                                  *    82200000
********************************************************************    82400000
CLOSE    DS   0H                            Close the object            82600000
         LA   R0,MQCO_NONE                  Normal close                82800000
         ST   R0,OPTIONS                    options here                83000000
*                                                                       83200000
         CALL MQCLOSE,                                                 C83400000
               (HCONN,                                                 C83600000
               HOBJ,                                                   C83800000
               OPTIONS,                                                C84000000
               COMPCODE,                                               C84200000
               REASON),                                                C84400000
               MF=(E,CALLLIST),VL                                       84600000
*                                                                       84800000
         LA   R0,MQCC_OK                    Load expected code          85000000
         C    R0,COMPCODE                   Code as expected?           85200000
         BE   ENDCLOSE                      Yes ... branch to exit      85400000
*                                                                       85600000
         MVC  M00_4_OP,OP_CLOSE             Error ... construct message 85800000
         BAS  R4,CODES                      Translate codes             86000000
         MVC  M00_MSG,M00_MSG4              Move in message             86200000
         B    ENDCLOSE                      Branch to section exit      86400000
*                                                                       86600000
ENDCLOSE DS   0H                                                        86800000
         BR   R7                            Return to caller            87000000
*                                                                       87200000
         EJECT                                                          87400000
********************************************************************    87600000
*  SECTION NAME : CODES                                            *    87800000
*                                                                  *    88000000
*  FUNCTION     : Translates COMPCODE and REASON to a format       *    88200000
*                 for displaying                                   *    88400000
*                                                                  *    88600000
*  CALLED BY    : UPDATE, INQUIRE, OPEN, CLOSE                     *    88800000
*                                                                  *    89000000
*  CALLS        : None                                             *    89200000
*                                                                  *    89400000
*  RETURN       : To Register 4                                    *    89600000
*                                                                  *    89800000
********************************************************************    90000000
CODES    DS   0H                                                        90200000
         L    R0,COMPCODE                   Load compcode value         90400000
         CVD  R0,DWORD                      Binary to packed decimal    90600000
         UNPK M00_4_CC,DWORD+4(4)           Packed to zoned decimal     90800000
         MVZ  M00_4_CC+7(1),M00_4_CC+6      Make it display             91000000
*                                                                       91200000
         L    R0,REASON                     Load reason value           91400000
         CVD  R0,DWORD                      Binary to packed decimal    91600000
         UNPK M00_4_RC,DWORD+4(4)           Packed to zoned decimal     91800000
         MVZ  M00_4_RC+7(1),M00_4_RC+6      Make it display             92000000
         BR   R4                            Return to caller            92200000
*                                                                       92400000
         EJECT                                                          92600000
********************************************************************    92800000
***     CONSTANTS                                                  *    93000000
********************************************************************    93200000
         COPY  DFHAID                       PF keys etc                 93400000
         COPY  DFHBMSCA                     BMS MAP command             93600000
*                                                                       93800000
         DFHREGS                            Register equates            94000000
*                                                                       94200000
         CMQA  LIST=NO                      Equates for MQ constants    94400000
*                                                                       94600000
         COPY  CSQ4AMSG                     Get the messages            94800000
*                                                                       95000000
CONST_MQOD     CMQODA LIST=NO                                           95200000
*                                                                       95400000
QPREFIX  DC    CL8'CSQ4SAMP'                Queue start restriction     95600000
SENDLEN  DC    Y(L'M00_MSG)                 Length of message           95800000
*                                                                       96000000
OP_SET   DC    CL08'MQSET'                  MQI Call                    96200000
OP_INQ   DC    CL08'MQINQ'                  MQI Call                    96400000
OP_OPEN  DC    CL08'MQOPEN'                 MQI Call                    96600000
OP_CLOSE DC    CL08'MQCLOSE'                MQI Call                    96800000
*                                                                       97000000
CALLOW   DC    CL08'ALLOW'                  Action verb                 97200000
CINQUI   DC    CL08'INQUIRE'                Action verb                 97400000
CINHIB   DC    CL08'INHIBIT'                Action verb                 97600000
*                                                                       97800000
CALLOWED DC    CL11'ALLOWED '               Queue status                98000000
CINHIBIT DC    CL11'INHIBITED '             Queue status                98200000
*                                                                       98400000
MAPSETID DC    CL08'CSQ4ACM '               Name of the mapset          98600000
MAPID    DC    CL08'CSQ4AC1 '               Name of the map             98800000
MAPIDHLP DC    CL08'CSQ4AC2 '               Name of the help map        99000000
*                                                                       99200000
         LTORG                                                          99400000
*                                                                       99600000
         END   CSQ4CAC1                                                 99800000

END_PROGRAM