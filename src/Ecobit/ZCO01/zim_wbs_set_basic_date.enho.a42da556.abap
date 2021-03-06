"Name: \PR:SAPLCJDT\EX:EHP603_CJDT_CHANGE_FLG_GET\EN:PS_ST_EHP3_SFWS_SC_UPDATE_PRTE\SE:END\EI
ENHANCEMENT 0 ZIM_WBS_SET_BASIC_DATE.
*
  IF TRTAB[] IS INITIAL.
    DATA: LV_FLAG_1.
    DATA: LV_FLAG_2.

    IF PROJWA IS INITIAL.
    CALL FUNCTION 'CJDW_GLOBAL_VALUES'
       IMPORTING
            V_PROJ = PROJWA
       EXCEPTIONS
            OTHERS = 1.
    ENDIF.

    IF PRPSWA-POSID IS INITIAL.
      LV_FLAG_1 = 'X'.
    ENDIF.

    CALL FUNCTION 'CJDT_PRTE_GET'
      EXPORTING
        INDEX_IMP = 1
      IMPORTING
        NO_APP    = LV_FLAG_2.

    IF LV_FLAG_2 IS NOT INITIAL.
      CALL FUNCTION 'CJDT_TRTAB_CREATE'
        EXPORTING
          PROJWA    = PROJWA
          SELKZ_IMP = LV_FLAG_1
        EXCEPTIONS
          NOT_FOUND = 01.
    ENDIF.
  ENDIF.

  LOOP AT TRTAB.
    IF TRTAB-PSTRT IS INITIAL.
      TRTAB-PSTRT = '20010101'.
    ENDIF.

    IF TRTAB-PENDE IS INITIAL.
      TRTAB-PENDE = '20471231'.
    ENDIF.

    IF TRTAB-PSTRT EQ '20010101'.
      TRTAB-PDAUR = '9999.9'.
    ENDIF.

    MODIFY TRTAB.
  ENDLOOP.
ENDENHANCEMENT.
