*&--------------------------------------------------------------------*
*& Report ZCOR0220
*&--------------------------------------------------------------------*
*&-------------------------------------------------------------------&*
*& PROGRAM ID  : ZCOR0220                                            &*
*& Title       : [CO] WBS 실적Vs계획 레포트                          &*
*& Created By  : BSGABAP4                                            &*
*& Created On  : 2019.08.15                                          &*
*& Description : [CO] WBS 실적Vs계획 레포트                          &*
*---------------------------------------------------------------------*
* MODIFICATION LOG
*---------------------------------------------------------------------*
* Tag  Date.       Author.     Description.
*----------------------------------------------------------------------*
* N    2019.08.15  BSGABAP4    INITIAL RELEASE
* U    2021.12.06  MDP_06      설비WBS 제외 및 포함여부 선택가능 추가
*---------------------------------------------------------------------*
REPORT ZCOR0220 MESSAGE-ID ZCO01.

*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE ZCOR0220T01.     "Top
INCLUDE ZCOR0220ALV.     "Alv
INCLUDE ZCOR0220SCR.     "Screen - Condition screen
INCLUDE ZCOR0220O01.     "Process Befor Output
INCLUDE ZCOR0220I01.     "Process After Input
INCLUDE ZCOR0220F01.     "Form

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
  PERFORM INITIAL_SET.
  PERFORM SCRFIELDS_FUNCTXT.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON BLOCK BL1.
*---------------------------------------------------------------------*
  PERFORM CHECK_SELECTION_SCREEN.

*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_PDGR.
*---------------------------------------------------------------------*
  PERFORM F4_PDGR CHANGING PA_PDGR.     "WBS 그룹

*---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*---------------------------------------------------------------------*
  PERFORM SET_SCREEN.


*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*---------------------------------------------------------------------*
  PERFORM SCR_USER_COMMAND.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM SET_RANGES_OBJNR.
  PERFORM SELECTED_DATA_RTN.
  CALL SCREEN 0100.

  SET PARAMETER ID 'ZPROG' FIELD SY-CPROG.

*----------------------------------------------------------------------*
END-OF-SELECTION.
*----------------------------------------------------------------------*
