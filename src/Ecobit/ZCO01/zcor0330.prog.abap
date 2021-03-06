*&--------------------------------------------------------------------&*
*& PROGRAM ID  : ZCOR0330                                             &*
*& Title       : [CO] 예산신청 현황 레포트                            &*
*& Created By  : BSGABAP4                                             &*
*& Created On  : 2019.09.05                                           &*
*& Description : [CO] 예산신청 현황 레포트                            &*
*----------------------------------------------------------------------*
* MODIFICATION LOG
*----------------------------------------------------------------------*
* Tag  Date.       Author.     Description.
*----------------------------------------------------------------------*
* N    2019.09.05  BSGABAP4    INITIAL RELEASE
*----------------------------------------------------------------------*
REPORT ZCOR0330 MESSAGE-ID ZCO01.

INCLUDE ZCOR0330T01.   " TOP-Decration
INCLUDE ZCOR0330ALV.   " Class ALV OR Others
INCLUDE ZCOR0330SCR.   " Selection-Screen
INCLUDE ZCOR0330O01.    "Process Befor Output
INCLUDE ZCOR0330I01.    "Process After Input
INCLUDE ZCOR0330F01.   " Subroutine

*---------------------------------------------------------------------*
INITIALIZATION.
*---------------------------------------------------------------------*
  PERFORM INITAIL.
  PERFORM SCRFIELDS_FUNCTXT.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*---------------------------------------------------------------------*
  PERFORM SET_SCREEN.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*---------------------------------------------------------------------*
  PERFORM SCR_USER_COMMAND.

*---------------------------------------------------------------------*
START-OF-SELECTION.
*---------------------------------------------------------------------*
  PERFORM DATA_GET.
  CALL SCREEN 0100.


*---------------------------------------------------------------------*
END-OF-SELECTION.
*---------------------------------------------------------------------*
