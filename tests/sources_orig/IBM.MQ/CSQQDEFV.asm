CSQQDEFV TITLE 'IMS Adapter - Subsystem definition table'               02000000
*********************************************************************** 04000000
*                                                                     * 06000000
*  MODULE NAME = CSQQDEFV                                             * 08000000
*                                                                     * 10000000
*  DESCRIPTIVE NAME = MQM MVS/ESA IMS Adapter:                        * 12000000
*                     Subsystem definition table                      * 14000000
*                                                                     * 16000000
*********************************************************************** 18000000
* @START_COPYRIGHT@                                                   * 20000000
* Statement:     Licensed Materials - Property of IBM                 * 22000000
*                                                                     * 24000000
*                5695-137                                             * 30000000
*                (C) Copyright IBM Corporation. 1993, 1997            * 32000000
*                                                                     * 40000000
* Status:        Version 1 Release 2                                  * 42000000
*                                                                     * 44000000
* @END_COPYRIGHT@                                                     * 52000000
*********************************************************************** 54000000
*  FUNCTION    = This table defines the MQM                           * 56000000
*                subsystems available to an IMS application.          * 58000000
*                It is generated using CSQQDEFX.                      * 60000000
*                                                                     * 62000000
*********************************************************************** 64000000
*                                                                       66000000
*                                                                       68000000
CSQQDEFV CSECT ,                                                        70000000
*                                                                       73000000
         CSQQDEFX NAME=CSQ1,LIT=MQM1,TYPE=DEFAULT                       76000000
         CSQQDEFX TYPE=END                                              79000000
*                                                                       82000000
*                                                                       85000000
*********************************************************************** 88000000
*        End of CSQQDEFV                                              * 91000000
*********************************************************************** 94000000
         END   CSQQDEFV                                                 97000000
