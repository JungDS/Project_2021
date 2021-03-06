*&---------------------------------------------------------------------*
*& Include          ZCOR0540F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  GV_MODE = GC_D. " 조회모드 기본값

  TEXT_S01 = '실행기준'(S01).
  TEXT_S02 = 'WBS별 매핑'(S02).
  TEXT_S03 = 'WBS속성기준 매핑'(S03).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTED_DATA_RTN
*&---------------------------------------------------------------------*
FORM SELECTED_DATA_RTN .

  CASE GC_X.
    WHEN P_R01.
      TRY.
        CALL TRANSACTION 'ZCOV1320' WITHOUT AUTHORITY-CHECK.

      CATCH CX_SY_AUTHORIZATION_ERROR INTO DATA(LX_ERROR).
        MESSAGE LX_ERROR->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.

      ENDTRY.
    WHEN P_R02.
      PERFORM SELECTED_DATA_R02.
      CALL SCREEN 0100.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTED_DATA_R02
*&---------------------------------------------------------------------*
FORM SELECTED_DATA_R02 .

  PERFORM CLEAR_ITAB.
  PERFORM SELECT_DB.
  PERFORM SELECT_OTHERS.

  PERFORM MAKE_DISPLAY_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_ITAB
*&---------------------------------------------------------------------*
FORM CLEAR_ITAB .

  _CLEAR_ITAB : GT_DATA,
                GT_DISPLAY,
                GT_1310,
                GT_1040,
                GT_1100,
                GT_T2501.

  CLEAR GV_DRDN_HANDLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DB
*&---------------------------------------------------------------------*
FORM SELECT_DB .

  SELECT A~BUKRS,
         B~BUTXT,
         A~ZZBGU,
         A~ZZBGD,
         A~ZZPRG,
         A~WW120,
         A~ERDAT,
         A~ERZET,
         A~ERNAM,
         A~AEDAT,
         A~AEZET,
         A~AENAM
    FROM ZCOT1310 AS A LEFT JOIN T001 AS B ON B~BUKRS EQ A~BUKRS
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.


  SORT GT_DATA BY BUKRS
                  ZZBGU
                  ZZBGD
                  ZZPRG
                  WW120.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SELECT_DB
*&---------------------------------------------------------------------*
FORM SELECT_OTHERS.

  SELECT FROM ZCOT1040  AS A
    LEFT JOIN ZCOT1040T AS B  ON  B~SPRAS EQ @SY-LANGU
                              AND B~ZZBGU EQ A~ZZBGU
         FIELDS   A~ZZBGU, B~ZZBGUTX
         ORDER BY A~ZZBGU
         INTO TABLE @GT_1040 .


  SELECT FROM ZCOT1050  AS A
    LEFT JOIN ZCOT1050T AS B  ON  B~SPRAS EQ @SY-LANGU
                              AND B~ZZBGU EQ A~ZZBGU
                              AND B~ZZBGD EQ A~ZZBGD
         FIELDS   A~ZZBGU, A~ZZBGD, B~ZZBGDTX
         ORDER BY A~ZZBGU, A~ZZBGD
         INTO TABLE @GT_1050 .

  SELECT FROM ZCOT1100  AS A
    LEFT JOIN ZCOT1100T AS B  ON  B~SPRAS EQ @SY-LANGU
                              AND B~ZZPRG EQ A~ZZPRG
         FIELDS   A~ZZPRG, B~ZZPRGTX
         ORDER BY A~ZZPRG
         INTO TABLE @GT_1100.

  SELECT FROM T2501  AS A
    LEFT JOIN T25A1  AS B  ON  B~SPRAS EQ @SY-LANGU
                           AND B~WW120 EQ A~WW120
         FIELDS   A~WW120, B~BEZEK
         ORDER BY A~WW120
         INTO TABLE @GT_T2501.

  PERFORM MAKE_DRDN_VALUE TABLES : GT_1040,
                                   GT_1100,
                                   GT_T2501.

  LOOP AT GT_1040 INTO GS_1040.

    READ TABLE GT_1050 TRANSPORTING NO FIELDS
                       WITH KEY ZZBGU = GS_1040-ZZBGU
                                BINARY SEARCH.

    CHECK SY-SUBRC EQ 0.

    LOOP AT GT_1050 INTO GS_1050 FROM SY-TABIX.
      IF GS_1040-ZZBGU NE GS_1050-ZZBGU.
        EXIT.
      ENDIF.

      GS_1050-HANDLE = GS_1040-HANDLE2.
      GS_1050-VALUE  = |{ GS_1050-ZZBGD } { GS_1050-ZZBGDTX }|.
      MODIFY GT_1050 FROM GS_1050.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DRDN_VALUE
*&---------------------------------------------------------------------*
FORM MAKE_DRDN_VALUE  TABLES PT_DATA TYPE TABLE.

  FIELD-SYMBOLS: <FS>,
                 <FS_HANDLE>,
                 <FS_VALUE>.

  ADD 1 TO GV_DRDN_HANDLE.

  DATA LV_DRDN_HANDLE LIKE GV_DRDN_HANDLE.
  LV_DRDN_HANDLE = GV_DRDN_HANDLE.

  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_WA>).

    ASSIGN COMPONENT 'HANDLE' OF STRUCTURE <FS_WA> TO <FS_HANDLE>.
    IF SY-SUBRC EQ 0.
      <FS_HANDLE> = LV_DRDN_HANDLE.
    ENDIF.

    ASSIGN COMPONENT 'HANDLE2' OF STRUCTURE <FS_WA> TO <FS_HANDLE>.
    IF SY-SUBRC EQ 0.
      ADD 1 TO GV_DRDN_HANDLE.
      <FS_HANDLE> = GV_DRDN_HANDLE.
    ENDIF.



    ASSIGN COMPONENT 'VALUE'  OF STRUCTURE <FS_WA> TO <FS_VALUE>.
    IF SY-SUBRC EQ 0.
      DO 2 TIMES.
        ASSIGN COMPONENT SY-INDEX OF STRUCTURE <FS_WA> TO <FS>.
        IF SY-SUBRC NE 0.
          EXIT.
        ENDIF.

        IF <FS_VALUE> IS INITIAL.
          <FS_VALUE> = <FS>.
        ELSE.
          CONCATENATE <FS_VALUE> <FS>
                 INTO <FS_VALUE> SEPARATED BY SPACE.
        ENDIF.

        UNASSIGN <FS>.
      ENDDO.
      UNASSIGN <FS_VALUE>.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM MAKE_DISPLAY_DATA .

  LOOP AT GT_DATA INTO GS_DATA.

    GS_DISPLAY = CORRESPONDING #( GS_DATA ).
    GS_DISPLAY-O_BUKRS = GS_DATA-BUKRS.
    GS_DISPLAY-O_ZZBGU = GS_DATA-ZZBGU.
    GS_DISPLAY-O_ZZBGD = GS_DATA-ZZBGD.
    GS_DISPLAY-O_ZZPRG = GS_DATA-ZZPRG.
    GS_DISPLAY-O_WW120 = GS_DATA-WW120.

    IF GS_DATA-ZZBGU IS NOT INITIAL.
      READ TABLE GT_1040 INTO GS_1040
                         WITH KEY ZZBGU = GS_DATA-ZZBGU
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GS_DISPLAY-ZZBGU_DRDN   = GS_1040-VALUE.
        " 사업구분이 지정되면, 세부사업 Dropdown Handle 도 기록한다.
        GS_DISPLAY-ZZBGD_HANDLE = GS_1040-HANDLE2.
      ELSE.
        GS_DISPLAY-ZZBGU_DRDN   = GS_DATA-ZZBGU && '(제거된 속성)'.
      ENDIF.
    ENDIF.


    IF GS_DATA-ZZBGD IS NOT INITIAL.
      READ TABLE GT_1050 INTO GS_1050
                         WITH KEY ZZBGU = GS_DATA-ZZBGU
                                  ZZBGD = GS_DATA-ZZBGD
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GS_DISPLAY-ZZBGD_DRDN = GS_1050-VALUE.
      ELSE.
        GS_DISPLAY-ZZBGD_DRDN = GS_DATA-ZZBGD && '(제거된 속성)'.
      ENDIF.
    ENDIF.

    IF GS_DATA-ZZPRG IS NOT INITIAL.
      READ TABLE GT_1100 INTO GS_1100
                         WITH KEY ZZPRG = GS_DATA-ZZPRG
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GS_DISPLAY-ZZPRG_DRDN = GS_1100-VALUE.
      ELSE.
        GS_DISPLAY-ZZPRG_DRDN = GS_DATA-ZZPRG && '(제거된 속성)'.
      ENDIF.
    ENDIF.


    IF GS_DATA-WW120 IS NOT INITIAL.
      READ TABLE GT_T2501 INTO GS_T2501
                         WITH KEY WW120 = GS_DATA-WW120
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GS_DISPLAY-WW120_DRDN = GS_T2501-VALUE.
      ELSE.
        GS_DISPLAY-WW120_DRDN = GS_DATA-WW120 && '(제거된 속성)'.
      ENDIF.
    ENDIF.

    APPEND GS_DISPLAY TO GT_DISPLAY.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_MAIN_GRID_0100
*&---------------------------------------------------------------------*
FORM CREATE_MAIN_GRID_0100 .

  IF GR_ALV IS NOT BOUND.
    GR_ALV = NEW #( GR_CON ).
  ENDIF.

  PERFORM MAKE_FIELDCATALOG_0100.
  PERFORM REGISTER_EVENT_0100.

  GR_ALV->SET_LAYOUT(
    I_TYPE       = 'C'
    I_BOX_FNAME  = 'MARK'
    I_STYLEFNAME = 'STYLE'
    I_CTAB_FNAME = 'COLOR'
  ).
  GR_ALV->SET_SORT( IT_FIELD = VALUE #( ( 'BUKRS' )
                                        ( 'BUTXT' )
                                        ( 'ZZBGU_DRDN' )
                                        ( 'ZZBGD_DRDN' ) ) ).


  GR_ALV->MS_VARIANT-REPORT = SY-REPID.
  GR_ALV->MV_SAVE = 'A'.
  GR_ALV->DISPLAY( CHANGING T_OUTTAB = GT_DISPLAY ).

*  CREATE OBJECT GR_GRID
*    EXPORTING
**      I_SHELLSTYLE            = 0                " Control Style
**      I_LIFETIME              =                  " Lifetime
*      I_PARENT                = GR_CON                 " Parent Container
**      I_APPL_EVENTS           = SPACE            " Register Events as Application Events
**      I_PARENTDBG             =                  " Internal, Do not Use
**      I_APPLOGPARENT          =                  " Container for Application Log
**      I_GRAPHICSPARENT        =                  " Container for Graphics
**      I_NAME                  =                  " Name
**      I_FCAT_COMPLETE         = SPACE            " Boolean Variable (X=True, Space=False)
**      O_PREVIOUS_SRAL_HANDLER =
*    EXCEPTIONS
*      ERROR_CNTL_CREATE       = 1                " Error when creating the control
*      ERROR_CNTL_INIT         = 2                " Error While Initializing Control
*      ERROR_CNTL_LINK         = 3                " Error While Linking Control
*      ERROR_DP_CREATE         = 4                " Error While Creating DataProvider Control
*      OTHERS                  = 5
*    .
*  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*
*  DATA LT_FIELDCAT_KKB TYPE KKBLO_T_FIELDCAT.
*  DATA LT_FIELDCAT_LVC TYPE LVC_T_FCAT.
*
*  CALL FUNCTION 'K_KKB_FIELDCAT_MERGE'
*    EXPORTING
*      I_CALLBACK_PROGRAM     = SY-REPID          " Internal table declaration program
*      I_INCLNAME             = SY-REPID
*      I_TABNAME              = 'GS_DISPLAY'        " Name of table to be displayed
*      I_BYPASSING_BUFFER     = GC_X              " Ignore buffer while reading
**      I_STRUCNAME            =
**      I_BUFFER_ACTIVE        =
*    CHANGING
*      CT_FIELDCAT            = LT_FIELDCAT_KKB     " Field Catalog with Field Descriptions
*    EXCEPTIONS
*      INCONSISTENT_INTERFACE = 1
*      OTHERS                 = 2.
*
*  CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
*    EXPORTING
*      IT_FIELDCAT_KKBLO         = LT_FIELDCAT_KKB
*    IMPORTING
*      ET_FIELDCAT_LVC           = LT_FIELDCAT_LVC
*    EXCEPTIONS
*      IT_DATA_MISSING           = 1
*      OTHERS                    = 2.
*
*
*
*  CALL METHOD GR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
**    EXPORTING
**      I_BUFFER_ACTIVE               =                  " Buffering Active
**      I_BYPASSING_BUFFER            =                  " Switch Off Buffer
**      I_CONSISTENCY_CHECK           =                  " Starting Consistency Check for Interface Error Recognition
**      I_STRUCTURE_NAME              =                  " Internal Output Table Structure Name
**      IS_VARIANT                    =                  " Layout
**      I_SAVE                        =                  " Save Layout
**      I_DEFAULT                     = GC_X              " Default Display Variant
**      IS_LAYOUT                     =                  " Layout
**      IS_PRINT                      =                  " Print Control
**      IT_SPECIAL_GROUPS             =                  " Field Groups
**      IT_TOOLBAR_EXCLUDING          =                  " Excluded Toolbar Standard Functions
**      IT_HYPERLINK                  =                  " Hyperlinks
**      IT_ALV_GRAPHICS               =                  " Table of Structure DTC_S_TC
**      IT_EXCEPT_QINFO               =                  " Table for Exception Tooltip
**      IR_SALV_ADAPTER               =                  " Interface ALV Adapter
*    CHANGING
*      IT_OUTTAB                     = GT_DISPLAY        " Output Table
*      IT_FIELDCATALOG               = LT_FIELDCAT_LVC   " Field Catalog
**      IT_SORT                       =                  " Sort Criteria
**      IT_FILTER                     =                  " Filter Criteria
*    EXCEPTIONS
*      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
*      PROGRAM_ERROR                 = 2                " Program Errors
*      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
*      OTHERS                        = 4
*    .
*  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_FIELDCATALOG_0100
*&---------------------------------------------------------------------*
FORM MAKE_FIELDCATALOG_0100 .

  GR_ALV->SET_FIELD_CATALOG(
    EXPORTING
      I_TABNAME               = 'GS_DISPLAY'
    EXCEPTIONS
      INVALID_INPUT_PARAMETER = 1
      EMPTY_FIELD_CATALOG     = 2
      OTHERS                  = 3
  ).

  IF SY-SUBRC <> 0.
    FREE GR_ALV.
    MESSAGE '필드카탈로그가 비어있습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN 0.
  ENDIF.


  DATA LV_TEXT TYPE TEXT100.


  LOOP AT GR_ALV->MT_FIELDCAT INTO DATA(LS_FIELDCAT).

    CLEAR LV_TEXT.
    CLEAR LS_FIELDCAT-KEY.
    CLEAR LS_FIELDCAT-COL_OPT.

    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'BUKRS'.
        LS_FIELDCAT-OUTPUTLEN = 10.
        LS_FIELDCAT-EDIT = GC_X.
        LS_FIELDCAT-KEY  = GC_X.

      WHEN 'BUTXT'.
        LS_FIELDCAT-OUTPUTLEN = 25.
        LS_FIELDCAT-EDIT = SPACE.
        LS_FIELDCAT-EMPHASIZE = 'C500'.

      WHEN 'ZZBGU_DRDN'.
        LS_FIELDCAT-OUTPUTLEN = 15.
        LS_FIELDCAT-EDIT = GC_X.
        PERFORM MAKE_DROPDOWN CHANGING LS_FIELDCAT.

      WHEN 'ZZBGD_DRDN'.
        LS_FIELDCAT-OUTPUTLEN = 25.
        LS_FIELDCAT-EDIT = GC_X.
        PERFORM MAKE_DROPDOWN CHANGING LS_FIELDCAT.

      WHEN 'ZZPRG_DRDN'.
        LS_FIELDCAT-OUTPUTLEN = 15.
        LS_FIELDCAT-EDIT = GC_X.
        PERFORM MAKE_DROPDOWN CHANGING LS_FIELDCAT.

      WHEN 'WW120_DRDN'.
        LS_FIELDCAT-OUTPUTLEN = 15.
        LS_FIELDCAT-EDIT = GC_X.
        PERFORM MAKE_DROPDOWN CHANGING LS_FIELDCAT.
        LS_FIELDCAT-EMPHASIZE = 'C300'.

      WHEN 'AEDAT'.
        LS_FIELDCAT-OUTPUTLEN = 13.
        LS_FIELDCAT-EDIT = SPACE.

      WHEN 'AEZET'.
        LS_FIELDCAT-OUTPUTLEN = 11.
        LS_FIELDCAT-EDIT = SPACE.

      WHEN 'AENAM'.
        LS_FIELDCAT-OUTPUTLEN = 11.
        LS_FIELDCAT-EDIT = SPACE.

      WHEN OTHERS.
        LS_FIELDCAT-TECH = GC_X.

    ENDCASE.


    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'BUKRS'.        LV_TEXT = '회사코드'(F01).
      WHEN 'ZZBGU_DRDN'.   LV_TEXT = '사업구분'(F02).
      WHEN 'ZZBGD_DRDN'.   LV_TEXT = '세부사업'(F03).
      WHEN 'ZZPRG_DRDN'.   LV_TEXT = '발주처유형'(F04).
      WHEN 'WW120_DRDN'.   LV_TEXT = 'BU구분'(F05).
      WHEN 'AEDAT'.        LV_TEXT = '수정일자'(F06).
      WHEN 'AEZET'.        LV_TEXT = '수정시간'(F07).
      WHEN 'AENAM'.        LV_TEXT = '수정자'(F08).
    ENDCASE.

    IF LV_TEXT IS NOT INITIAL.
      LS_FIELDCAT-REPTEXT   = LV_TEXT.
      LS_FIELDCAT-COLTEXT   = LV_TEXT.
      LS_FIELDCAT-SCRTEXT_L = LV_TEXT.
      LS_FIELDCAT-SCRTEXT_M = LV_TEXT.
      LS_FIELDCAT-SCRTEXT_S = LV_TEXT.
    ENDIF.

    MODIFY GR_ALV->MT_FIELDCAT FROM LS_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DROPDOWN
*&---------------------------------------------------------------------*
FORM MAKE_DROPDOWN CHANGING PS_FIELDCAT TYPE LVC_S_FCAT.

  DATA LT_DROP TYPE LVC_T_DROP.


  PS_FIELDCAT-CHECKTABLE = '!'.

  "-- Dropdown List 구성
  CASE PS_FIELDCAT-FIELDNAME.

    WHEN 'ZZBGU_DRDN'.

      READ TABLE GT_1040 INTO GS_1040 INDEX 1.
      IF SY-SUBRC EQ 0.
        PS_FIELDCAT-DRDN_HNDL = GS_1040-HANDLE.
      ENDIF.

      LT_DROP[] = CORRESPONDING #( GT_1040 ).

    WHEN 'ZZBGD_DRDN'.

      CLEAR PS_FIELDCAT-DRDN_HNDL.
      PS_FIELDCAT-DRDN_FIELD = 'ZZBGD_HANDLE'.

      LT_DROP[] = CORRESPONDING #( GT_1050 ).

    WHEN 'ZZPRG_DRDN'.

      READ TABLE GT_1100 INTO GS_1100 INDEX 1.
      IF SY-SUBRC EQ 0.
        PS_FIELDCAT-DRDN_HNDL = GS_1100-HANDLE.
      ENDIF.

      LT_DROP[] = CORRESPONDING #( GT_1100 ).

    WHEN 'WW120_DRDN'.

      READ TABLE GT_T2501 INTO GS_T2501 INDEX 1.
      IF SY-SUBRC EQ 0.
        PS_FIELDCAT-DRDN_HNDL = GS_T2501-HANDLE.
      ENDIF.

      LT_DROP[] = CORRESPONDING #( GT_T2501 ).

    WHEN OTHERS.

      EXIT.

  ENDCASE.


  GR_ALV->MR_ALV_GRID->SET_DROP_DOWN_TABLE(
    IT_DROP_DOWN = LT_DROP
  ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
FORM SAVE_DATA .

  IF GC_X NE ZCL_CO_COMMON=>POPUP_CONFIRM(
      I_TITLEBAR = '확인'(PT1)
      I_QUESTION = CONV #( '저장하시겠습니까?'(QT1) )
  ).
    MESSAGE '취소되었습니다.' TYPE GC_S DISPLAY LIKE GC_W.
    EXIT.
  ENDIF.


  PERFORM CHECK_DATA.
  CHECK GV_EXIT IS INITIAL.


  DELETE FROM ZCOT1310 WHERE BUKRS IN @R_BUKRS.
  MODIFY      ZCOT1310 FROM TABLE @GT_1310.

  IF SY-SUBRC EQ 0.
    COMMIT WORK.
    MESSAGE '저장이 완료되었습니다.' TYPE GC_S.


    " Log 저장
    MODIFY ZCOT1340 FROM TABLE @GT_1340.
    IF SY-SUBRC EQ 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.


    " 조회모드로 변경
    GV_MODE = GC_D.
    PERFORM REFRESH_DATA.

  ELSE.

    ROLLBACK WORK.
    MESSAGE '저장이 실패되었습니다.' TYPE GC_S DISPLAY LIKE GC_E.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
FORM CHECK_DATA.

  DATA LT_MESSAGE TYPE TABLE OF STRING WITH HEADER LINE.
  DATA LT_1310    LIKE GT_1310.
  DATA LS_COLOR   TYPE LVC_S_SCOL.
  DATA LV_TABIX   TYPE SY-TABIX.


  CLEAR GV_EXIT.

  REFRESH GT_1310.
  REFRESH GT_1340.


*.. DB 조회
  SELECT *
    FROM ZCOT1310
   WHERE BUKRS IN @R_BUKRS
    INTO CORRESPONDING FIELDS OF TABLE @LT_1310.

  SORT LT_1310 BY BUKRS ZZBGU ZZBGD ZZPRG WW120.


  LS_COLOR = VALUE #( COLOR = VALUE #( COL = 6 ) ) .


  LOOP AT GT_DISPLAY INTO GS_DISPLAY.

    LV_TABIX = SY-TABIX.

    REFRESH: GS_DISPLAY-COLOR.

    CLEAR GS_1040.
    CLEAR GS_1050.
    CLEAR GS_1100.
    CLEAR GS_T2501.

    PERFORM CHECK_DATA_BUKRS TABLES LT_MESSAGE USING LS_COLOR.
    PERFORM CHECK_DATA_ZZBGU TABLES LT_MESSAGE USING LS_COLOR.
    PERFORM CHECK_DATA_ZZBGD TABLES LT_MESSAGE USING LS_COLOR.
    PERFORM CHECK_DATA_ZZPRG TABLES LT_MESSAGE USING LS_COLOR.
    PERFORM CHECK_DATA_WW120 TABLES LT_MESSAGE USING LS_COLOR.

    MODIFY GT_DISPLAY FROM GS_DISPLAY TRANSPORTING COLOR.


    PERFORM APPEND_1340 TABLES LT_1310 USING LV_TABIX.
    PERFORM APPEND_1310.

  ENDLOOP.


  SORT GT_1310 BY BUKRS
                  ZZBGU
                  ZZBGD
                  ZZPRG
                  WW120.

  SORT GT_1340 BY BUKRS
                  O_ZZBGU
                  O_ZZBGD
                  O_ZZPRG
                  O_WW120.


  PERFORM APPEND_1340_DEL TABLES LT_1310.
  PERFORM MAKE_LOG_DATA.


  " 중복여부 체크
  PERFORM CHECK_DUPLICATED_DATA TABLES LT_MESSAGE.


  IF LT_MESSAGE[] IS NOT INITIAL.
    READ TABLE LT_MESSAGE INDEX 1.

    MESSAGE LT_MESSAGE TYPE 'I' DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PV_ONF4
                                PV_ONF4_BEFORE
                                PV_ONF4_AFTER
                                PV_UCOMM
                                PR_SENDER TYPE REF TO CL_GUI_ALV_GRID.

DEFINE __MODIFY_CELL.
  PR_DATA_CHANGED->MODIFY_CELL(
    I_ROW_ID    = &1 " Row ID
    I_FIELDNAME = &2 " Field Name
    I_VALUE     = &3 " Value
  ).
END-OF-DEFINITION.

  CHECK PR_SENDER EQ GR_ALV->MR_ALV_GRID.

  DATA(LT_INS) = PR_DATA_CHANGED->MT_INSERTED_ROWS.
  DATA(LT_MOD) = PR_DATA_CHANGED->MT_MOD_CELLS.

  DATA LS_DISPLAY LIKE GS_DISPLAY.

  IF GT_T001 IS INITIAL.
    PERFORM SELECT_T001.
  ENDIF.

  IF LT_INS[] IS NOT INITIAL.

    CLEAR GS_T001.
    READ TABLE GT_T001 INTO GS_T001
                       WITH KEY BUKRS = R_BUKRS-LOW
                                BINARY SEARCH.

    LOOP AT LT_INS INTO DATA(LS_INS).
      __MODIFY_CELL LS_INS-ROW_ID:
        'BUKRS'   R_BUKRS-LOW,
        'BUTXT'   GS_T001-BUTXT,
        'ERDAT'   LS_DISPLAY-ERDAT,
        'ERZET'   LS_DISPLAY-ERZET,
        'ERNAM'   LS_DISPLAY-ERNAM,
        'AEDAT'   LS_DISPLAY-AEDAT,
        'AEZET'   LS_DISPLAY-AEZET,
        'AENAM'   LS_DISPLAY-AENAM,
        'O_BUKRS' LS_DISPLAY-O_BUKRS,
        'O_ZZBGU' LS_DISPLAY-O_ZZBGU,
        'O_ZZBGD' LS_DISPLAY-O_ZZBGD,
        'O_ZZPRG' LS_DISPLAY-O_ZZPRG,
        'O_WW120' LS_DISPLAY-O_WW120.
    ENDLOOP.

  ENDIF.


  LOOP AT LT_MOD INTO DATA(LS_MOD).

    CLEAR GS_DISPLAY.
    READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX LS_MOD-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD-FIELDNAME.
      WHEN 'BUKRS'.

        IF GS_DISPLAY-BUKRS NE LS_MOD-VALUE.
          CLEAR GS_T001.
          READ TABLE GT_T001 INTO GS_T001
                             WITH KEY BUKRS = LS_MOD-VALUE
                                      BINARY SEARCH.
          __MODIFY_CELL LS_MOD-ROW_ID: 'BUTXT' GS_T001-BUTXT.
        ENDIF.

      WHEN 'ZZBGU_DRDN'.
        IF GS_DISPLAY-ZZBGU_DRDN NE LS_MOD-VALUE.
          __MODIFY_CELL LS_MOD-ROW_ID: 'ZZBGD_DRDN' SPACE.
          GV_REFRESH = GC_X.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_FINISHED
*&---------------------------------------------------------------------*
FORM HANDLE_FINISHED  USING PV_MODIFIED
                            PT_GOOD_CELLS TYPE LVC_T_MODI
                            PR_SENDER TYPE REF TO CL_GUI_ALV_GRID.

  CHECK GV_REFRESH EQ GC_X.
  CLEAR GV_REFRESH.

  DATA(LT_GOOD_CELLS) = PT_GOOD_CELLS.


  SORT LT_GOOD_CELLS BY FIELDNAME ROW_ID.

  READ TABLE LT_GOOD_CELLS TRANSPORTING NO FIELDS
                           WITH KEY FIELDNAME = 'ZZBGU_DRDN'
                                    BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    LOOP AT LT_GOOD_CELLS INTO DATA(LS_GOOD_CELLS) FROM SY-TABIX.
      IF LS_GOOD_CELLS-FIELDNAME NE 'ZZBGU_DRDN'.
        EXIT.
      ENDIF.

      READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX LS_GOOD_CELLS-ROW_ID.
      CHECK SY-SUBRC EQ 0.

      CLEAR GS_1040.
*      READ TABLE GT_1040 INTO GS_1040 WITH KEY VALUE = LS_GOOD_CELLS-VALUE.
      READ TABLE GT_1040 INTO GS_1040 WITH KEY VALUE = GS_DISPLAY-ZZBGU_DRDN.
      GS_DISPLAY-ZZBGD_HANDLE = GS_1040-HANDLE2.

      MODIFY GT_DISPLAY FROM GS_DISPLAY INDEX LS_GOOD_CELLS-ROW_ID TRANSPORTING ZZBGD_HANDLE .

    ENDLOOP.
  ENDIF.


  PR_SENDER->REFRESH_TABLE_DISPLAY(
    EXPORTING
      IS_STABLE      = VALUE #( ROW = GC_X
                                COL = GC_X )  " With Stable Rows/Columns
      I_SOFT_REFRESH = GC_X                   " Without Sort, Filter, etc.
    EXCEPTIONS
      FINISHED       = 1                " Display was Ended (by Export)
      OTHERS         = 2
  ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_EVENT_0100
*&---------------------------------------------------------------------*
FORM REGISTER_EVENT_0100 .

  GR_ALV->MR_ALV_GRID->REGISTER_EDIT_EVENT(
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED " Event ID
    EXCEPTIONS
      ERROR      = 1                " Error
      OTHERS     = 2
  ).

  IF GR_EVENT_RECEIVER IS INITIAL.
    CREATE OBJECT GR_EVENT_RECEIVER.
  ENDIF.

  SET HANDLER GR_EVENT_RECEIVER->ON_DATA_CHANGED FOR GR_ALV->MR_ALV_GRID.
  SET HANDLER GR_EVENT_RECEIVER->ON_FINISHED     FOR GR_ALV->MR_ALV_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_T001
*&---------------------------------------------------------------------*
FORM SELECT_T001 .

  REFRESH GT_T001.

  SELECT BUKRS,
         BUTXT
    FROM T001
    INTO TABLE @GT_T001.

  SORT GT_T001 BY BUKRS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_DATA
*&---------------------------------------------------------------------*
FORM REFRESH_DATA .

  PERFORM SELECTED_DATA_R02.

  LOOP AT GR_ALV->MT_FIELDCAT INTO DATA(LS_FIELDCAT).
    PERFORM MAKE_DROPDOWN USING LS_FIELDCAT.
  ENDLOOP.

  GR_ALV->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_UPDATE_INFO
*&---------------------------------------------------------------------*
FORM SET_UPDATE_INFO .

  DATA: LV_DATE TYPE CHAR12,
        LV_TIME TYPE CHAR10,
        LV_NAME TYPE CHAR40.


  SELECT USR21~BNAME,
         ADRP~DATE_FROM,
         ADRP~NATION,
         ADRP~NAME_TEXT
    FROM USR21
    JOIN ADRP   ON ADRP~PERSNUMBER EQ USR21~PERSNUMBER
   WHERE ADRP~DATE_FROM LE @SY-DATUM
    INTO TABLE @DATA(LT_USR21).

  SORT LT_USR21 BY BNAME
                   DATE_FROM.

  DELETE ADJACENT DUPLICATES FROM LT_USR21 COMPARING BNAME.




  SELECT AEDAT,
         AEZET,
         AENAM
    FROM ZCOT1320
    INTO TABLE @DATA(LT_1320).

  IF SY-SUBRC EQ 0.

    SORT LT_1320 BY AEDAT DESCENDING
                    AEZET DESCENDING.

    READ TABLE LT_1320 INTO DATA(LS_1320) INDEX 1.
    IF SY-SUBRC EQ 0.
      WRITE LS_1320-AEDAT TO LV_DATE.
      WRITE LS_1320-AEZET TO LV_TIME.

      READ TABLE LT_USR21 INTO DATA(LS_USR21)
                          WITH KEY BNAME = LS_1320-AENAM
                                   BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LV_NAME = LS_1320-AENAM && '(' && LS_USR21-NAME_TEXT && ')'.
      ELSE.
        LV_NAME = LS_1320-AENAM.
      ENDIF.


      CONCATENATE LV_DATE LV_TIME LV_NAME
             INTO TEXT_S04 SEPARATED BY ' / '.
    ENDIF.

  ENDIF.


  SELECT DISTINCT
         AEDAT,
         AEZET,
         AENAM
    FROM ZCOT1310
   WHERE AEDAT IN ( SELECT MAX( AEDAT ) FROM ZCOT1310 )
    INTO TABLE @DATA(LT_1310).

  IF SY-SUBRC EQ 0.

    SORT LT_1310 BY AEDAT DESCENDING
                    AEZET DESCENDING.

    READ TABLE LT_1310 INTO DATA(LS_1310) INDEX 1.
    IF SY-SUBRC EQ 0.
      WRITE LS_1310-AEDAT TO LV_DATE.
      WRITE LS_1310-AEZET TO LV_TIME.

      READ TABLE LT_USR21 INTO LS_USR21
                          WITH KEY BNAME = LS_1310-AENAM
                                   BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LV_NAME = LS_1310-AENAM && '(' && LS_USR21-NAME_TEXT && ')'.
      ELSE.
        LV_NAME = LS_1310-AENAM.
      ENDIF.

      CONCATENATE LV_DATE LV_TIME LV_NAME
             INTO TEXT_S05 SEPARATED BY ' / '.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCRFIELDS_FUNCTXT
*&---------------------------------------------------------------------*
FORM SCRFIELDS_FUNCTXT .

  SSCRFIELDS = VALUE #(
    FUNCTXT_01 = VALUE SMP_DYNTXT( ICON_ID   = ICON_INFORMATION
                                   QUICKINFO = TEXT-S04 ) " Program Help
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCR_USER_COMMAND
*&---------------------------------------------------------------------*
FORM SCR_USER_COMMAND .

  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      PERFORM CALL_POPUP_HELP(ZCAR9000) USING SY-REPID
                                              SY-DYNNR
                                              SY-LANGU ''.


    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOGGLE_GRID
*&---------------------------------------------------------------------*
FORM TOGGLE_GRID .



  IF GV_MODE EQ GC_E.

    PERFORM TOGGLE_GRID_D.

  ELSE.

    CLEAR: R_BUKRS, R_BUKRS[].
    GET PARAMETER ID 'BUK' FIELD R_BUKRS-LOW.
    CALL SCREEN 0200 STARTING AT 30 2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COMPANY_CODE
*&---------------------------------------------------------------------*
FORM SET_COMPANY_CODE .

  IF R_BUKRS-LOW IS INITIAL.
    " 회사코드를 입력하세요.
    MESSAGE TEXT-M03 TYPE 'I' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.



  SELECT COUNT(*)
    FROM T001
   WHERE BUKRS EQ @R_BUKRS-LOW.

  IF SY-SUBRC EQ 0.
    R_BUKRS-SIGN   = 'I'.
    R_BUKRS-OPTION = 'EQ'.
    CLEAR  R_BUKRS-HIGH.
    APPEND R_BUKRS.

    GV_MODE = GC_E.

    DELETE GT_DISPLAY WHERE BUKRS NOT IN R_BUKRS.

    LOOP AT GT_DISPLAY INTO GS_DISPLAY.
      GS_DISPLAY-STYLE = VALUE #( ( FIELDNAME = 'BUKRS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
      MODIFY GT_DISPLAY FROM GS_DISPLAY.

    ENDLOOP.

    GT_DISPLAY_2[] = GT_DISPLAY[].
    GR_ALV->REFRESH( ).

    LEAVE TO SCREEN 0.
  ELSE.

    " 올바른 회사코드를 입력하세요.
    MESSAGE TEXT-M04 TYPE 'I' DISPLAY LIKE 'E'.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BUTXT
*&---------------------------------------------------------------------*
FORM SET_BUTXT  USING PV_BUKRS.

  CLEAR BUTXT.
  CHECK PV_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUTXT
    FROM T001
   WHERE BUKRS EQ @PV_BUKRS
    INTO @BUTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXIT_PROGRAM
*&---------------------------------------------------------------------*
FORM EXIT_PROGRAM .

  IF GV_MODE EQ GC_E.

    " 편집모드인 경우 조회로 이동한다.
    PERFORM TOGGLE_GRID_D.

  ELSE.

    LEAVE TO SCREEN 0.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOGGLE_GRID_D
*&---------------------------------------------------------------------*
FORM TOGGLE_GRID_D .

  DATA LV_TITLEBAR TYPE TEXT60.
  DATA LV_QUESTION TYPE STRING.

  LV_TITLEBAR = '확인'(PT1).
  LV_QUESTION = '조회로 전환합니다. 변경 중인 내용은 제거됩니다.'(QT2).

  IF GT_DISPLAY_2[] NE GT_DISPLAY[] AND
     GC_X NE ZCL_CO_COMMON=>POPUP_CONFIRM( I_TITLEBAR = LV_TITLEBAR
                                           I_QUESTION = LV_QUESTION ).

    MESSAGE '취소되었습니다.' TYPE GC_S DISPLAY LIKE GC_W.
    EXIT.
  ENDIF.

  GV_MODE = GC_D.
  PERFORM REFRESH_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_LOG
*&---------------------------------------------------------------------*
FORM DISPLAY_LOG .

  REFRESH GT_LOG_ALL.
  REFRESH GT_LOG_DISP.
  PERFORM SELECT_LOG.

  CALL SCREEN 0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_LOG
*&---------------------------------------------------------------------*
FORM SELECT_LOG .

  DATA: LT_LOG TYPE TABLE OF ZCOT1340,
        LS_LOG LIKE LINE  OF LT_LOG.

  SELECT *
    FROM ZCOT1340
   WHERE BUKRS IN @R_BUKRS
   ORDER BY PRIMARY KEY
    INTO TABLE @LT_LOG.

  LOOP AT LT_LOG INTO LS_LOG.

    GS_LOG = CORRESPONDING #( LS_LOG ).

    CASE GS_LOG-METHOD.
      WHEN 'N'. GS_LOG-STATUS = ICON_POSITIVE.      " 신규

        CONCATENATE:
          LS_LOG-ZZBGU   LS_LOG-ZZBGUTX   INTO GS_LOG-N_ZZBGU SEPARATED BY ', ',
          LS_LOG-ZZBGD   LS_LOG-ZZBGDTX   INTO GS_LOG-N_ZZBGD SEPARATED BY ', ',
          LS_LOG-ZZPRG   LS_LOG-ZZPRGTX   INTO GS_LOG-N_ZZPRG SEPARATED BY ', ',
          LS_LOG-WW120   LS_LOG-WW120TX   INTO GS_LOG-N_WW120 SEPARATED BY ', '.

      WHEN 'D'. GS_LOG-STATUS = ICON_NEGATIVE.      " 삭제
        CONCATENATE:
          LS_LOG-O_ZZBGU LS_LOG-O_ZZBGUTX INTO GS_LOG-O_ZZBGU SEPARATED BY ', ',
          LS_LOG-O_ZZBGD LS_LOG-O_ZZBGDTX INTO GS_LOG-O_ZZBGD SEPARATED BY ', ',
          LS_LOG-O_ZZPRG LS_LOG-O_ZZPRGTX INTO GS_LOG-O_ZZPRG SEPARATED BY ', ',
          LS_LOG-O_WW120 LS_LOG-O_WW120TX INTO GS_LOG-O_WW120 SEPARATED BY ', '.

      WHEN 'C'. GS_LOG-STATUS = ICON_ARROW_RIGHT.   " 변경
        CONCATENATE:
          LS_LOG-O_ZZBGU LS_LOG-O_ZZBGUTX INTO GS_LOG-O_ZZBGU SEPARATED BY ', ',
          LS_LOG-O_ZZBGD LS_LOG-O_ZZBGDTX INTO GS_LOG-O_ZZBGD SEPARATED BY ', ',
          LS_LOG-O_ZZPRG LS_LOG-O_ZZPRGTX INTO GS_LOG-O_ZZPRG SEPARATED BY ', ',
          LS_LOG-O_WW120 LS_LOG-O_WW120TX INTO GS_LOG-O_WW120 SEPARATED BY ', ',
          LS_LOG-ZZBGU   LS_LOG-ZZBGUTX   INTO GS_LOG-N_ZZBGU SEPARATED BY ', ',
          LS_LOG-ZZBGD   LS_LOG-ZZBGDTX   INTO GS_LOG-N_ZZBGD SEPARATED BY ', ',
          LS_LOG-ZZPRG   LS_LOG-ZZPRGTX   INTO GS_LOG-N_ZZPRG SEPARATED BY ', ',
          LS_LOG-WW120   LS_LOG-WW120TX   INTO GS_LOG-N_WW120 SEPARATED BY ', '.

    ENDCASE.

    APPEND GS_LOG TO GT_LOG_ALL.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_LOG_DATA
*&---------------------------------------------------------------------*
FORM MAKE_LOG_DATA .

  SORT GT_1340 BY TABIX.

  LOOP AT GT_1340 INTO DATA(LS_1340).

    LS_1340-TABIX = SY-TABIX.


    IF LS_1340-O_ZZBGU IS NOT INITIAL.
      CLEAR GS_1040.
      READ TABLE GT_1040 INTO GS_1040
                         WITH KEY ZZBGU = LS_1340-O_ZZBGU
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LS_1340-O_ZZBGUTX = GS_1040-ZZBGUTX.

        IF LS_1340-O_ZZBGD IS NOT INITIAL.
          CLEAR GS_1050.
          READ TABLE GT_1050 INTO GS_1050
                             WITH KEY ZZBGU = LS_1340-O_ZZBGU
                                      ZZBGD = LS_1340-O_ZZBGD
                                      BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            LS_1340-O_ZZBGDTX = GS_1050-ZZBGDTX.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    IF LS_1340-O_ZZPRG IS NOT INITIAL.
      CLEAR GS_1100.
      READ TABLE GT_1100 INTO GS_1100
                         WITH KEY ZZPRG = LS_1340-O_ZZPRG
                                  BINARY SEARCH.

      IF SY-SUBRC EQ 0.
        LS_1340-O_ZZPRGTX = GS_1100-ZZPRGTX.
      ENDIF.
    ENDIF.


    IF LS_1340-O_WW120 IS NOT INITIAL.
      CLEAR GS_T2501.
      READ TABLE GT_T2501 INTO GS_T2501
                          WITH KEY WW120 = LS_1340-O_WW120
                                   BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LS_1340-O_WW120TX = GS_T2501-BEZEK.
      ENDIF.
    ENDIF.


    MODIFY GT_1340 FROM LS_1340.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA_BUKRS
*&---------------------------------------------------------------------*
FORM CHECK_DATA_BUKRS TABLES PT_MESSAGE TYPE STANDARD TABLE
                       USING VALUE(PS_COLOR) TYPE LVC_S_SCOL.

  PS_COLOR-FNAME = 'BUKRS'.


  IF GS_DISPLAY-BUKRS IS INITIAL.

    APPEND PS_COLOR TO GS_DISPLAY-COLOR.

    PT_MESSAGE = '회사코드는 필수값 입니다.'.
    APPEND PT_MESSAGE.
    GV_EXIT = GC_X.

  ELSEIF GS_DISPLAY-BUKRS NOT IN R_BUKRS.

    APPEND PS_COLOR TO GS_DISPLAY-COLOR.

    PT_MESSAGE = |허용되지 않은 회사코드입니다.|.
    APPEND PT_MESSAGE.
    GV_EXIT = GC_X.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA_ZZBGU
*&---------------------------------------------------------------------*
FORM CHECK_DATA_ZZBGU  TABLES PT_MESSAGE TYPE STANDARD TABLE
                       USING VALUE(PS_COLOR) TYPE LVC_S_SCOL.


  CHECK GS_DISPLAY-ZZBGU_DRDN IS NOT INITIAL.

  READ TABLE GT_1040 INTO GS_1040
                     WITH KEY VALUE = GS_DISPLAY-ZZBGU_DRDN.

  CHECK SY-SUBRC NE 0.
  PS_COLOR-FNAME = 'ZZBGU_DRDN'.
  APPEND PS_COLOR TO GS_DISPLAY-COLOR.

  PT_MESSAGE = '알 수 없는 사업구분 입니다.'.
  APPEND PT_MESSAGE.
  GV_EXIT = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA_ZZBGD
*&---------------------------------------------------------------------*
FORM CHECK_DATA_ZZBGD  TABLES PT_MESSAGE TYPE STANDARD TABLE
                       USING VALUE(PS_COLOR) TYPE LVC_S_SCOL.


  CHECK GS_DISPLAY-ZZBGD_DRDN IS NOT INITIAL.

  READ TABLE GT_1050 INTO GS_1050
                     WITH KEY VALUE = GS_DISPLAY-ZZBGD_DRDN.

  CHECK SY-SUBRC NE 0.
  PS_COLOR-FNAME = 'ZZBGD_DRDN'.
  APPEND PS_COLOR TO GS_DISPLAY-COLOR.

  PT_MESSAGE = '알 수 없는 세부사업 입니다.'.
  APPEND PT_MESSAGE.
  GV_EXIT = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA_ZZPRG
*&---------------------------------------------------------------------*
FORM CHECK_DATA_ZZPRG  TABLES PT_MESSAGE TYPE STANDARD TABLE
                       USING VALUE(PS_COLOR) TYPE LVC_S_SCOL.


  CHECK GS_DISPLAY-ZZPRG_DRDN IS NOT INITIAL.

  READ TABLE GT_1100 INTO GS_1100
                     WITH KEY VALUE = GS_DISPLAY-ZZPRG_DRDN.

  CHECK SY-SUBRC NE 0.

  PS_COLOR-FNAME = 'ZZPRG_DRDN'.
  APPEND PS_COLOR TO GS_DISPLAY-COLOR.

  PT_MESSAGE = '알 수 없는 발주처유형 입니다.'.
  APPEND PT_MESSAGE.
  GV_EXIT = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA_WW120
*&---------------------------------------------------------------------*
FORM CHECK_DATA_WW120  TABLES PT_MESSAGE TYPE STANDARD TABLE
                       USING VALUE(PS_COLOR) TYPE LVC_S_SCOL.

  PS_COLOR-FNAME = 'WW120_DRDN'.


  IF GS_DISPLAY-WW120_DRDN IS INITIAL.
    PT_MESSAGE = 'BU구분은 필수값 입니다.'.
  ELSE.
    READ TABLE GT_T2501 INTO GS_T2501
                        WITH KEY VALUE = GS_DISPLAY-WW120_DRDN.
    CHECK SY-SUBRC NE 0.
    PT_MESSAGE = '알 수 없는 BU구분 입니다.'.
  ENDIF.


  APPEND PS_COLOR TO GS_DISPLAY-COLOR.
  APPEND PT_MESSAGE.
  GV_EXIT = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_1340
*&---------------------------------------------------------------------*
FORM APPEND_1340    TABLES PT_1310  STRUCTURE ZCOT1310
                    USING  PV_TABIX LIKE SY-TABIX.

  DATA LS_1340 LIKE LINE OF GT_1340.

  READ TABLE PT_1310 INTO DATA(LS_1310)
                     WITH KEY BUKRS = GS_DISPLAY-BUKRS
                              ZZBGU = GS_1040-ZZBGU
                              ZZBGD = GS_1050-ZZBGD
                              ZZPRG = GS_1100-ZZPRG
                              WW120 = GS_T2501-WW120
                              BINARY SEARCH.

  IF SY-SUBRC EQ 0.

    GS_DISPLAY-ERDAT = LS_1310-ERDAT.
    GS_DISPLAY-ERZET = LS_1310-ERZET.
    GS_DISPLAY-ERNAM = LS_1310-ERNAM.
    GS_DISPLAY-AEDAT = LS_1310-AEDAT.
    GS_DISPLAY-AEZET = LS_1310-AEZET.
    GS_DISPLAY-AENAM = LS_1310-AENAM.

  ELSE.

    " Log 정보
    LS_1340 = VALUE #(
      LOGID     = SY-DATUM && SY-UZEIT
      TABIX     = PV_TABIX
*      METHOD    =
      BUKRS     = GS_DISPLAY-BUKRS
      ZZBGU     = GS_1040-ZZBGU
      ZZBGUTX   = GS_1040-ZZBGUTX
      ZZBGD     = GS_1050-ZZBGD
      ZZBGDTX   = GS_1050-ZZBGDTX
      ZZPRG     = GS_1100-ZZPRG
      ZZPRGTX   = GS_1100-ZZPRGTX
      WW120     = GS_T2501-WW120
      WW120TX   = GS_T2501-BEZEK
      O_ZZBGU   = GS_DISPLAY-O_ZZBGU
*      O_ZZBGUTX =
      O_ZZBGD   = GS_DISPLAY-O_ZZBGD
*      O_ZZBGDTX =
      O_ZZPRG   = GS_DISPLAY-O_ZZPRG
*      O_ZZPRGTX =
      O_WW120   = GS_DISPLAY-O_WW120
*      O_WW120TX =
      AEDAT     = SY-DATUM
      AEZET     = SY-UZEIT
      AENAM     = SY-UNAME
    ).


    IF GS_DISPLAY-ERDAT IS INITIAL.

      " 사용자에 의해 생성된 라인...
      " 기존 라인 삭제 후 동일한 키값으로 생성했을 가능성 존재

      READ TABLE PT_1310 INTO LS_1310
                         WITH KEY BUKRS = GS_DISPLAY-BUKRS
                                  ZZBGU = GS_1040-ZZBGU
                                  ZZBGD = GS_1050-ZZBGD
                                  ZZPRG = GS_1100-ZZPRG
                                  BINARY SEARCH.

      IF SY-SUBRC EQ 0.

        " 있는 경우 WW120 ( BU ) 가 달라진 경우
        GS_DISPLAY-ERDAT = LS_1310-ERDAT.
        GS_DISPLAY-ERZET = LS_1310-ERZET.
        GS_DISPLAY-ERNAM = LS_1310-ERNAM.
        GS_DISPLAY-AEDAT = SY-DATUM.
        GS_DISPLAY-AEZET = SY-UZEIT.
        GS_DISPLAY-AENAM = SY-UNAME.

        LS_1340-METHOD = 'C'.

      ELSE.

        " 없는 경우 신규 BU 매핑정보
        GS_DISPLAY-ERDAT = SY-DATUM.
        GS_DISPLAY-ERZET = SY-UZEIT.
        GS_DISPLAY-ERNAM = SY-UNAME.
        GS_DISPLAY-AEDAT = SY-DATUM.
        GS_DISPLAY-AEZET = SY-UZEIT.
        GS_DISPLAY-AENAM = SY-UNAME.

        LS_1340-METHOD = 'N'.

      ENDIF.

    ELSE.

      " 기존 라인의 특정 필드 변경건
      GS_DISPLAY-AEDAT = SY-DATUM.
      GS_DISPLAY-AEZET = SY-UZEIT.
      GS_DISPLAY-AENAM = SY-UNAME.

      LS_1340-METHOD = 'C'.

    ENDIF.

    APPEND LS_1340 TO GT_1340.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_1310
*&---------------------------------------------------------------------*
FORM APPEND_1310 .

  DATA LS_1310 LIKE LINE OF GT_1310.

  CLEAR LS_1310.
  LS_1310 = VALUE #(
    BUKRS = GS_DISPLAY-BUKRS
    ZZBGU = GS_1040-ZZBGU
    ZZBGD = GS_1050-ZZBGD
    ZZPRG = GS_1100-ZZPRG
    WW120 = GS_T2501-WW120
    ERDAT = GS_DISPLAY-ERDAT
    ERZET = GS_DISPLAY-ERZET
    ERNAM = GS_DISPLAY-ERNAM
    AEDAT = GS_DISPLAY-AEDAT
    AEZET = GS_DISPLAY-AEZET
    AENAM = GS_DISPLAY-AENAM
  ).

  APPEND LS_1310 TO GT_1310.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_1340_DEL
*&---------------------------------------------------------------------*
FORM APPEND_1340_DEL TABLES PT_1310 STRUCTURE ZCOT1310.

  DATA LS_1340 LIKE LINE OF GT_1340.

  " DB 에는 존재하는데 To-Be 에도 없고, As-Is 에도 없는 데이터는
  " 사용자의 작업에 의해 삭제된 데이터

  LOOP AT PT_1310 INTO DATA(LS_1310).

    READ TABLE GT_1310 TRANSPORTING NO FIELDS
                       WITH KEY BUKRS = LS_1310-BUKRS
                                ZZBGU = LS_1310-ZZBGU
                                ZZBGD = LS_1310-ZZBGD
                                ZZPRG = LS_1310-ZZPRG
                                WW120 = LS_1310-WW120
                                BINARY SEARCH.
    CHECK SY-SUBRC NE 0.

    READ TABLE GT_1340 TRANSPORTING NO FIELDS
                       WITH KEY BUKRS   = LS_1310-BUKRS
                                O_ZZBGU = LS_1310-ZZBGU
                                O_ZZBGD = LS_1310-ZZBGD
                                O_ZZPRG = LS_1310-ZZPRG
                                O_WW120 = LS_1310-WW120
                                BINARY SEARCH.
    CHECK SY-SUBRC NE 0.

    " Log 정보
    LS_1340 = VALUE #(
      LOGID     = SY-DATUM && SY-UZEIT
      TABIX     = 99999999
      METHOD    = 'D'
      BUKRS     = LS_1310-BUKRS
*      ZZBGU     =
*      ZZBGUTX   =
*      ZZBGD     =
*      ZZBGDTX   =
*      ZZPRG     =
*      ZZPRGTX   =
*      WW120     =
*      WW120TX   =
      O_ZZBGU   = LS_1310-ZZBGU
*      O_ZZBGUTX =
      O_ZZBGD   = LS_1310-ZZBGD
*      O_ZZBGDTX =
      O_ZZPRG   = LS_1310-ZZPRG
*      O_ZZPRGTX =
      O_WW120   = LS_1310-WW120
*      O_WW120TX =
      AEDAT     = SY-DATUM
      AEZET     = SY-UZEIT
      AENAM     = SY-UNAME
    ).

    APPEND LS_1340 TO GT_1340.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUPLICATED_DATA
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATED_DATA TABLES PT_MESSAGE TYPE STANDARD TABLE.

  DATA LS_TEMP  LIKE LINE OF GT_1310.
  DATA LS_COLOR TYPE LVC_S_SCOL.

  LOOP AT GT_1310 INTO DATA(LS_1310).

    IF LS_TEMP-BUKRS EQ LS_1310-BUKRS AND
       LS_TEMP-ZZBGU EQ LS_1310-ZZBGU AND
       LS_TEMP-ZZBGD EQ LS_1310-ZZBGD AND
       LS_TEMP-ZZPRG EQ LS_1310-ZZPRG .

      GV_EXIT = GC_X.

      LOOP AT GT_DISPLAY INTO GS_DISPLAY WHERE BUKRS         EQ LS_1310-BUKRS
                                           AND ZZBGU_DRDN(1) EQ LS_1310-ZZBGU
                                           AND ZZBGD_DRDN(2) EQ LS_1310-ZZBGD
                                           AND ZZPRG_DRDN(3) EQ LS_1310-ZZPRG.

        LS_COLOR-FNAME    = SPACE.
        LS_COLOR-NOKEYCOL = GC_X.
        APPEND LS_COLOR TO GS_DISPLAY-COLOR.

*        LS_COLOR-FNAME = 'ZZBGU_DRDN'.
*        APPEND LS_COLOR TO GS_DISPLAY-COLOR.
*
*        LS_COLOR-FNAME = 'ZZBGD_DRDN'.
*        APPEND LS_COLOR TO GS_DISPLAY-COLOR.
*
*        LS_COLOR-FNAME = 'ZZPRG_DRDN'.
*        APPEND LS_COLOR TO GS_DISPLAY-COLOR.

        MODIFY GT_DISPLAY FROM GS_DISPLAY TRANSPORTING COLOR.
      ENDLOOP.

      PT_MESSAGE = '중복된 BU 매핑정보 입니다.'.
      APPEND PT_MESSAGE.

    ENDIF.

    LS_TEMP = LS_1310.
  ENDLOOP.


ENDFORM.
