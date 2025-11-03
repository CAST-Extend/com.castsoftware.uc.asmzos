         TITLE 'MQSeries for MVS/ESA - SAMPLE PLT CONNECT PROGRAM'      00700000
*********************************************************************** 01400000
*                                                                     * 02100000
* MODULE NAME = CSQCSPLT                                              * 02800000
*                                                                     * 03500000
* DESCRIPTIVE NAME = Sample Connect program in phase 2 PLT execution  * 04200000
*                                                                     * 04900000
* @START_COPYRIGHT@                                                   * 05600000
* Statement:     Licensed Materials - Property of IBM                 * 06300000
*                                                                     * 07000000
*                5695-137                                             * 07700000
*                (C) Copyright IBM Corporation. 1994, 1997            * 08400000
*                                                                     * 11200000
* Status:        Version 1 Release 2                                  * 11900000
*                                                                     * 12600000
* @END_COPYRIGHT@                                                     * 15400000
*                                                                     * 16100000
*********************************************************************** 37800000
DFHEISTG DSECT                                                          38500000
*********************************************************************** 39200000
*                                                                     * 39500000
* Parameter list for CSQCQCON                                         * 39900000
* CKQC     CL4  - must be 'CKQC'                                      * 40600000
* DISPMODE CL1  - must be ' '                                         * 41300000
* CONNREQ  CL10 - must be 'START     '                                * 42000000
*          CL1  - must be ' '                                         * 42700000
* INITP    CL1  - can be 'Y' or 'N'. 'Y' to use defaults              * 43400000
*          CL1  - must be ' '                                         * 44100000
*                                                                     * 44800000
*** The following is to override INITPARM(V3) or EXEC PARM(V2)    ***** 45500000
*                                                                     * 46200000
* CONNSSN  CL4  - MVS subsystem name of the target queue manager      * 46900000
*          CL1  - must be  ' '                                        * 47600000
* CONNTN   CL3  - the trace number. Must be numeric and < 199.        * 48300000
*          CL1 -  must be  ' '                                        * 49000000
* CONNIQ   CL(MQ_Q_NAME_LENGTH)                                       * 49700000
*              -  the name of the default initiation queue            * 50400000
*********************************************************************** 51100000
CONNPL   DS   0H                                                        51800000
CKQC     DS   CL4                                                       52500000
DISPMODE DS   CL1                                                       53200000
CONNREQ  DS   CL10                                                      53900000
DELIM1   DS   CL1                                                       54600000
INITP    DS   CL1                                                       55300000
DELIM2   DS   CL1                                                       56000000
CONNSSN  DS   CL4                                                       56700000
DELIM3   DS   CL1                                                       57400000
CONNTN   DS   CL3                                                       58100000
DELIM4   DS   CL1                                                       58800000
CONNIQ   DS   CL(MQ_Q_NAME_LENGTH)                                      59500000
*********************************************************************** 60200000
* Application constants.                                              * 60900000
* This can also be achieved by including the supplied macro           * 61600000
*        MQA  LIST=YES                                                * 62300000
*********************************************************************** 63000000
MQ_Q_NAME_LENGTH EQU 48                                                 63700000
*                                                                       64400000
CSQCSPLT DFHEIENT                                                       65100000
*                                                                       65800000
* Construct Connect Parameter List                                      66500000
*                                                                       67200000
         MVC  CKQC,TRANCKQC           set up basic values               67900000
         MVC  DISPMODE,=CL1' '                                          68600000
         MVC  CONNREQ,CONN                                              69300000
         MVC  DELIM1,BLANK            fill in blank                     70000000
         MVC  INITP,USEINITP          use INITPARM for missing values   70700000
         MVC  DELIM2,BLANK            fill in blank                     71400000
         MVC  CONNSSN,=CL4'    '      don't specify SSN                 72100000
         MVC  DELIM3,BLANK            fill in blank                     72800000
         MVC  CONNTN,=CL3'   '        don't specify trace number        73500000
         MVC  DELIM4,BLANK            fill in blank                     74200000
         MVC  CONNIQ,LONGIQN          use a different IQ name           74900000
*                                                                       75600000
* Link to connection front end program                                  76300000
* Don't want an abend if program is not there                           77000000
*                                                                       77700000
         EXEC CICS LINK PROGRAM(CSQCQCON)                              *78400000
              COMMAREA(CONNPL) LENGTH(COMMLEN)                         *79200000
              NOHANDLE                                                  80000000
*                                                                       80800000
* Should include code to check CICS response and                        81600000
* take appropriate action. Try not to abend in any case.                82400000
*                                                                       83200000
*     if eibresp = ... then ...                                         84000000
*                  ...                                                  84800000
*                  ...                                                  85600000
*                  ...                                                  86400000
*                                                                       87200000
* Return to CICS                                                        88000000
*                                                                       88800000
         EXEC CICS RETURN                                               89600000
*                                                                       90400000
* Values to be used for this connection                                 91200000
*                                                                       92000000
TRANCKQC DC   CL4'CKQC'                                                 92800000
CONN     DC   CL10'START'                                               93600000
BLANK    DC   CL1' '                                                    94400000
USEINITP DC   CL1'Y'                                                    95200000
CSQCQCON DC   CL8'CSQCQCON'                                             96000000
LONGIQN  DC   CL48'INITIATION.QUEUE.FOR.THIS.PARTICULAR.CICS.AOR'       96800000
COMMLEN  DC   H'75'                                                     97600000
*                                                                       98400000
         END     CSQCSPLT                                               99200000
