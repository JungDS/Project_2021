*&---------------------------------------------------------------------*
*& Include          ZCOR0480T01
*&---------------------------------------------------------------------*

TYPE-POOLS ICON.

TABLES : ZCOT1260,
         T001 ,
         SSCRFIELDS.

DATA : GS_FUNTXT TYPE SMP_DYNTXT.

DATA  GV_REPID TYPE SYREPID.
DATA: GV_WAERS  TYPE WAERS,
      GV_EXIT   TYPE XFELD,
      GV_ERROR  TYPE XFELD,
      GV_ANSWER TYPE C.

DATA:
  GV_LINES   LIKE SY-TABIX,
  GV_TITLE   LIKE SY-TITLE,
  GV_MESSAGE TYPE BAPI_MSG.


DATA : GV_WE_NM TYPE T001W-NAME1. " 플랜트명


DATA : BEGIN OF GT_1260 OCCURS 0 .
         INCLUDE STRUCTURE ZCOS0480.
         DATA :
         BOX     .
DATA : END OF GT_1260,
GS_1260 LIKE LINE OF GT_1260.

DATA : BEGIN OF GT_SDMM OCCURS 0 .
         INCLUDE STRUCTURE ZCOS0480 .
         DATA :
         BOX    .
DATA : END OF GT_SDMM,
GS_SDMM LIKE LINE OF GT_SDMM.

DATA : GT_ZMMT600 TYPE TABLE OF ZMMT0600,
       GS_ZMMT600 LIKE LINE OF GT_ZMMT600.


DATA   : GS_T001 LIKE T001 .

DATA : I_SPLIT.


DATA : GV_M1    TYPE SPMON,
       GV_M2    TYPE SPMON,
*       GV_TDATE TYPE SY-DATUM, "입력기간 말일
       GV_NDATE TYPE SY-DATUM, "익월1일
       GV_DATUM TYPE SY-DATUM, "전기일
       GV_SPMON TYPE SY-DATUM. "전기일

DATA :  GV_LFGJA TYPE MARD-LFGJA.  " mm 전년
DATA :  GV_LFMON  TYPE MARD-LFMON.  " mm 전월

DATA : BEGIN OF GT_MARD OCCURS 0,
         LFGJA TYPE MARD-LFGJA,
         LFMON TYPE MARD-LFMON,
         MATNR TYPE MARD-MATNR,
         LABST TYPE MARD-LABST,
       END OF GT_MARD.


*SD 펑션용

DATA : E_SPMON TYPE SPMON,
       E_WERKS TYPE WERKS_D,
       E_MATNR TYPE MATNR. " 선택

DATA : GT_SD_RESULT  TYPE ZSDS0460 OCCURS 0.
DATA : GT_SD_RESULT2 TYPE  ZSDS0460  OCCURS 0.
DATA : GT_STOCK LIKE ZMMS4020 OCCURS 0.

TYPES: BEGIN OF TY_RAW ,
         WERKS        TYPE ZMMT0610-WERKS  , " 플랜트
         WERKS_NAME   TYPE ZCOS0450-WERKS_NAME, " 플랜트명

         RMBLNR       TYPE ZMMT0610-RMBLNR, " 원자재의 자재문서번호
         MATKL        TYPE ZCOS0450-MATKL,  "자재 그룹
         WGBEZ        TYPE ZCOS0450-WGBEZ,  " 자재 그룹 내역
         FMATNR       TYPE ZCOS0450-FMATNR, "[CO] 제품 자재코드
         FMATNR_MAKTX TYPE MAKTX, " 자재내역
         FMENGE       TYPE ZCOS0450-FMENGE,  " [CO]수량(생산)
         FMEINS       TYPE ZCOS0450-FMEINS,  "기본 단위
         RMATNR       TYPE ZCOS0450-RMATNR,  " [CO]원자재
         RMATNR_MAKTX TYPE MAKTX, " 자재내역
         RMENGE       TYPE ZCOS0450-RMENGE,  " 수량
         RMEINS       TYPE ZCOS0450-RMEINS ,  "기본 단위
         RWRBTR       TYPE ZCOS0450-RWRBTR,
         TWAER        TYPE ZCOS0450-TWAER,
       END OF TY_RAW.

DATA : GT_RAW TYPE STANDARD TABLE OF TY_RAW   .

RANGES : GR_GJAHR FOR ACDOCA-GJAHR,
         GR_BUDAT FOR ACDOCA-BUDAT,
         GR_RACCT FOR ACDOCA-RACCT,
         GR_POSID FOR ACDOCA-PS_POSID,
         GR_GSBER FOR T134G-GSBER.

CONSTANTS : GC_X   TYPE CHAR1 VALUE 'X',
            GC_C   TYPE CHAR1 VALUE 'C',
            GC_E   TYPE CHAR1 VALUE 'E',
            GC_S   TYPE CHAR1 VALUE 'S',
            GC_D   TYPE CHAR1 VALUE 'D',
            GC_R   TYPE CHAR1 VALUE 'R',
            GC_KRW TYPE TCURR_CURR VALUE 'KRW'.



DATA : IT_DYNP TYPE TABLE OF DYNPREAD WITH HEADER LINE,
       I_REPID TYPE SY-REPID,
       I_DYNNR TYPE SY-DYNNR.

* MESSAGE.
DATA : GT_MSG TYPE BAPIRETTAB,
       GS_MSG LIKE BAPIRET2.

DATA : G_INIT.

DATA : G_TNAME        TYPE DD02L-TABNAME.


DEFINE D_MSG.
  clear : &1.
  &1-type       = &2.
  &1-id         = &3.
  &1-number     = &4.
  &1-message_v1 = &5.
  &1-message_v2 = &6.
  &1-message_v3 = &7.
  &1-message_v4 = &8.
END-OF-DEFINITION.


DEFINE DG_SELECTION .
  &1-sign   = &2.
  &1-option = &3.
  &1-low    = &4.
  &1-high   = &5.
  append &1 . clear &1.
END-OF-DEFINITION.



DEFINE    _GET_LAST_DATE.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = &1
      DAYS      = &2
      MONTHS    = &3
      YEARS     = &5
      SIGNUM    = &4         "'+'
    IMPORTING
      CALC_DATE = &6.
END-OF-DEFINITION.



DEFINE _SET_RANGES.
  &1-SIGN = &2.
  &1-OPTION = &3.
  &1-LOW = &4.
  &1-HIGH = &5.

  APPEND &1.
END-OF-DEFINITION.
*DEFINE _MAKE_ACDOCA_ITAB.
*  &1-SIGN = &2.
*  &1-OPTION = &3.
*  &1-LOW = &4.
*
*  APPEND &1.
*END-OF-DEFINITION.
DEFINE $_SET_REPLACE.
  IF &1 IS NOT INITIAL.
    REPLACE ALL OCCURRENCES OF &2 IN &1 WITH space.
    CONDENSE &1 NO-GAPS.
  ENDIF.
END-OF-DEFINITION.
DEFINE    _GET_LAST_DATE.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = &1
      DAYS      = &2
      MONTHS    = &3
      YEARS     = &5
      SIGNUM    = &4         "'+'
    IMPORTING
      CALC_DATE = &6.
END-OF-DEFINITION.
DEFINE _INVDT_INPUT.
  CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.
