*&---------------------------------------------------------------------*
*& Include          ZCOR0300T01
*&---------------------------------------------------------------------*
TYPE-POOLS : ICON,ABAP.

TABLES : SSCRFIELDS, "선택화면의 필드(Function Key)
         CSKS,
         T001,
         TKA01,
         TKA02,
         TKA05,
         TCURC,
         CEPC,
         PRPS,
         CSKA,
         ZCOT0040.

*---------------------------------------------------------------------*
* CONSTANTS
*---------------------------------------------------------------------*
CONSTANTS : GC_LZONE TYPE LZONE    VALUE '0000000001',
            GC_A     TYPE CHAR01   VALUE 'A',
            GC_S     TYPE CHAR01   VALUE 'S',
            GC_E     TYPE CHAR01   VALUE 'E',
            GC_X     TYPE CHAR01   VALUE 'X',
            GC_N     TYPE CHAR01   VALUE 'N',
            GC_TCODE TYPE SY-TCODE VALUE 'KS01'.

CONSTANTS GC_KTOPL TYPE KTOPL VALUE '1000'.

*---------------------------------------------------------------------*
* TYPES
*---------------------------------------------------------------------*

TYPES: BEGIN OF TY_ACDOCA,
         OBJNR TYPE J_OBJNR,
         HSL   TYPE FINS_VHCUR12,
       END OF TY_ACDOCA.

TYPES: BEGIN OF TY_DATA,
         OBJNR  TYPE J_OBJNR,
         KSTAR  TYPE KSTAR,
         WKG001 TYPE WKGXXX,
         WKG002 TYPE WKGXXX,
         WKG003 TYPE WKGXXX,
         WKG004 TYPE WKGXXX,
         WKG005 TYPE WKGXXX,
         WKG006 TYPE WKGXXX,
         WKG007 TYPE WKGXXX,
         WKG008 TYPE WKGXXX,
         WKG009 TYPE WKGXXX,
         WKG010 TYPE WKGXXX,
         WKG011 TYPE WKGXXX,
         WKG012 TYPE WKGXXX,
       END OF TY_DATA.

TYPES: BEGIN OF TY_DISPLAY.
         INCLUDE STRUCTURE ZCOS0300.
TYPES : COLOR TYPE LVC_T_SCOL,
        END OF TY_DISPLAY.

*---------------------------------------------------------------------*
* VARIABLE
*---------------------------------------------------------------------*
* - Prefix 정의
*   1. GV_  : Global Variable
*   2. LV_  : Local Variable

*EX) DATA: GV_EXIT   TYPE C,
*          GV_ANSWER TYPE C,
*          OK_CODE   TYPE SY-UCOMM,   "예외
*          SAVE_OK   TYPE SY-UCOMM.   "예외

DATA: GV_EXIT TYPE C,
      OK_CODE TYPE SY-UCOMM,   "예외
      SAVE_OK TYPE SY-UCOMM.   "예외

DATA: GV_TOTAL  TYPE C LENGTH 30,
      GV_SUCESS TYPE C LENGTH 30,
      GV_ERROR  TYPE C LENGTH 30.

DATA GV_ANSWER.

DATA GV_MESSAGE TYPE C LENGTH 100.

DATA: G_VALID TYPE C.
DATA: LS_TOOLBAR TYPE STB_BUTTON.

TYPES: BEGIN OF TY_LAYOUT,
         REPID    TYPE SYREPID,
         RESTRICT TYPE SALV_DE_LAYOUT_RESTRICTION,
         DEFAULT  TYPE SAP_BOOL,
         LAYOUT   TYPE DISVARIANT-VARIANT,
       END OF TY_LAYOUT.

DATA: GO_ALV        TYPE REF TO CL_SALV_TABLE,
      GO_FUNCTIONS  TYPE REF TO CL_SALV_FUNCTIONS_LIST,
      GO_LAYOUT     TYPE REF TO CL_SALV_LAYOUT,
      GO_DSPSET     TYPE REF TO CL_SALV_DISPLAY_SETTINGS,
      GS_KEY        TYPE SALV_S_LAYOUT_KEY,
      GT_COLUMN_REF TYPE SALV_T_COLUMN_REF.

DATA GS_COLOR  TYPE LVC_S_COLO.

DATA GR_COLUMN TYPE REF TO CL_SALV_COLUMN_TABLE.

DATA: GT_ROWS TYPE SALV_T_ROW,
      GS_ROW  TYPE INT4.  "ALV position 기억

DATA: GV_COLUMN_TEXT TYPE STRING,
      GV_SCRTEXT_S   TYPE SCRTEXT_S,
      GV_SCRTEXT_M   TYPE SCRTEXT_M,
      GV_SCRTEXT_L   TYPE SCRTEXT_L.

DATA: GS_SALV_LAYOUT TYPE TY_LAYOUT.
DATA  GV_REPID TYPE SYREPID.

DATA GT_RETURN TYPE TABLE OF BAPIRET2 WITH HEADER LINE.

DATA GV_COUNT TYPE I.

DATA GV_KTOPL TYPE KTOPL VALUE '1000'.
DATA GV_WAERS TYPE WAERS.

DATA:  GT_CELL_COLOR TYPE LVC_T_SCOL,
       GS_CELL_COLOR TYPE LVC_S_SCOL.

*---------------------------------------------------------------------*
* STRUCTURE
*---------------------------------------------------------------------*
DATA : GS_FUNTXT TYPE SMP_DYNTXT.

*---------------------------------------------------------------------*
* INTERNAL TABLE
*---------------------------------------------------------------------*
DATA GT_VALUES TYPE TABLE OF GRPVALUES WITH HEADER LINE.

DATA GT_OUTTAB TYPE TABLE OF ZCOS0300.
DATA GS_OUTTAB TYPE ZCOS0300.

DATA GT_DISPLAY TYPE TABLE OF TY_DISPLAY.
DATA GS_DISPLAY TYPE TY_DISPLAY.

DATA: BEGIN OF GT_KOSTL OCCURS 0 ,
        KOSTL TYPE KOSTL,
        KTEXT TYPE KTEXT,
      END OF GT_KOSTL.

DATA: BEGIN OF GT_PRPS OCCURS 0,
        OBJNR TYPE J_OBJNR,
        PSPNR TYPE PS_POSNR,
        POSID TYPE PS_POSID,
        POST1 TYPE PS_POST1,
        ZZCYP TYPE ZECTYPE,
      END OF GT_PRPS.

DATA GT_ACDOCA TYPE TABLE OF TY_ACDOCA WITH HEADER LINE.
DATA GT_DATA   TYPE TABLE OF TY_DATA   WITH HEADER LINE.

*---------------------------------------------------------------------*
* RANGES
*---------------------------------------------------------------------*
RANGES R_OBJNR FOR ZCOT0040-ROBJNR.
RANGES R_KSTAR FOR ZCOT0040-RKSTAR.
RANGES R_FYEAR FOR ACDOCA-FISCYEARPER.

*---------------------------------------------------------------------*
* FIELD-SYMBOLS
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
* MACRO (Define)
*---------------------------------------------------------------------*
* - Prefix 정의
*   1. _ : '_' 1개로 시작; Global, Local 구분 없음.
DEFINE _INITIAL_CHK.
  IF &1 IS INITIAL.
  GS_OUTTAB-STATUS    = 'E'.
  GS_OUTTAB-MESSAGE   = &2.
  ENDIF.
END-OF-DEFINITION.

DEFINE _CONVERSION_IN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
  input = &1
  IMPORTING
  output = &1.
END-OF-DEFINITION.

DEFINE _CONVERSION_WBS_IN.
  CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
  EXPORTING
  input = &1
  IMPORTING
  output = &1.
END-OF-DEFINITION.

DEFINE _CONVERSION_WBS_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_ABPSN_OUTPUT'
  EXPORTING
  input = &1
  IMPORTING
  output = &1.
END-OF-DEFINITION.

DEFINE _CONVERSION_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
  EXPORTING
  input = &1
  IMPORTING
  output = &1.
END-OF-DEFINITION.

DEFINE _CLEAR.
  CLEAR &1. REFRESH &1.
END-OF-DEFINITION.

DEFINE _MAKEICON.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      NAME                  = &1
      INFO                  = &2
    IMPORTING
      RESULT                = &3
    EXCEPTIONS
      ICON_NOT_FOUND        = 1
      OUTPUTFIELD_TOO_SHORT = 2
      OTHERS                = 3.

END-OF-DEFINITION.

DEFINE _SET_COLOR.

  GS_COLOR-COL = &1.
  GS_COLOR-INT = &2.
  GS_COLOR-INV = &3.

END-OF-DEFINITION.

DEFINE _STRING_REPLACE.

  IF &1 IS NOT INITIAL.

  CALL FUNCTION 'STRING_REPLACE'
    EXPORTING
      PATTERN    = ','
      SUBSTITUTE = ''
    CHANGING
      TEXT       = &1.

 CONDENSE  &1.

  TRY.

    MOVE &1 TO A.

    CATCH CX_SY_CONVERSION_NO_NUMBER INTO DATA(ERR).

      GS_OUTTAB-STATUS =  'E'.
      GS_OUTTAB-MESSAGE = TEXT-E01.

      CLEAR  &1.

  ENDTRY.

 ENDIF.

END-OF-DEFINITION.
DEFINE _CURR_INPUT.
  WRITE &1 CURRENCY 'KRW' TO &2.
  CONDENSE &2.
END-OF-DEFINITION.

DEFINE _CONV_KRW.
  IF &1 IS NOT INITIAL .
    &1 = &1 / 100.
  ENDIF.
END-OF-DEFINITION.

DEFINE ADD_COLOR.

   CLEAR GS_CELL_COLOR.
   GS_CELL_COLOR-FNAME     = &1.
   GS_CELL_COLOR-COLOR-COL = &2.
   GS_CELL_COLOR-COLOR-INT = 1.
   GS_CELL_COLOR-COLOR-INV = 0.
   GS_CELL_COLOR-NOKEYCOL  = 'X'.
   APPEND GS_CELL_COLOR TO GT_CELL_COLOR.

END-OF-DEFINITION.

*---------------------------------------------------------------------*
* Table Controls
*---------------------------------------------------------------------*
* - Prefix 정의
*   1. TC_ : Table Controls

*---------------------------------------------------------------------*
* Custom Controls
*---------------------------------------------------------------------*
* - Prefix 정의
*   1. CC_ : Custom Controls

*---------------------------------------------------------------------*
* Tabstrip Controls
*---------------------------------------------------------------------*
* - Prefix 정의
*   1. TS_ : Tabstrip Controls
