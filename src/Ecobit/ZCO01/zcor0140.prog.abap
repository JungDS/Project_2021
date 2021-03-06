*&--------------------------------------------------------------------&*
*& PROGRAM ID  : ZCOR0140                                             &*
*& Title       : [CO] 목표계획수립_일반판매관리비                     &*
*& Created By  : BSGABAP8                                             &*
*& Created On  : 2019.07.22                                           &*
*& Description : [CO] 목표계획수립_일반판매관리비                     &*
*----------------------------------------------------------------------*
* MODIFICATION LOG
*----------------------------------------------------------------------*
* Tag  Date.       Author.     Description.
*----------------------------------------------------------------------*
* N    2019.07.22  BSGABAP8    INITIAL RELEASE
*----------------------------------------------------------------------*
REPORT ZCOR0140 MESSAGE-ID ZCO01.

INCLUDE ZCOR0140T01.    "Top
INCLUDE ZCOR0140ALV.    "Alv
INCLUDE ZCOR0140SCR.    "Screen - Condition screen
INCLUDE ZCOR0140O01.    "Process Befor Output
INCLUDE ZCOR0140I01.    "Process After Input
INCLUDE ZCOR0140F01.    "Form

*---------------------------------------------------------------------*
INITIALIZATION.
*---------------------------------------------------------------------*
  PERFORM INITAIL.
  PERFORM SET_INIT_HELP.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*---------------------------------------------------------------------*
  PERFORM SCR_USER_COMMAND_HELP.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*---------------------------------------------------------------------*
  PERFORM SET_SCREEN.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM SELECTED_DATA_RTN.
  CALL SCREEN 0100.
