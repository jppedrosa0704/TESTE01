REPORT ZPRG_TESTE_ALV.

TABLES: ZORDH_28.

TYPES: BEGIN OF lty_data,
        ONO	  TYPE ZDEONO_28,
        ODATE	TYPE ZDEODATE_28,
        PM    TYPE ZDEPM_28,
        TA    TYPE ZDETA_28,
        CURR  TYPE ZEDCUR_28,
       END OF lty_data.

DATA: lt_data TYPE TABLE OF lty_data,
      ls_data TYPE lty_data.


" -----------------------------------------------------------
"  TABELA INTERNA FIELDCAT
" -----------------------------------------------------------
DATA: lt_fieldcat TYPE SLIS_T_FIELDCAT_ALV.

TYPES: BEGIN OF lty_data1,
        ONO	  TYPE ZDEONO_28,
        OIN	  TYPE ZDEOITMNO_28,
        ODESC	TYPE ZDEODESC_28,
        ICOST	TYPE ZDEOICOST28,
       END OF lty_data1.

DATA: lt_data1 TYPE TABLE OF lty_data1,
      ls_data1 TYPE lty_data1.



*TYPES: BEGIN OF lty_final,
*        ONO    TYPE ZDEONO_28,
*        ODATE  TYPE ZDEODATE_28,
*        PM    TYPE ZDEPM_28,
*        TA    TYPE ZDETA_28,
*        CURR  TYPE ZEDCUR_28,
*        OIN    TYPE ZDEOITMNO_28,
*        ODESC  TYPE ZDEODESC_28,
*        ICOST  TYPE ZDEOICOST28,
*       END OF lty_final.


DATA: lt_final TYPE TABLE OF ZSTR_ALV_TESTE,
      ls_final TYPE ZSTR_ALV_TESTE.

DATA: lv_ono TYPE ZDEONO_28.
SELECT-OPTIONS: s_ono FOR lv_ono.

SELECT ONO ODATE PM TA CURR
  FROM ZORDH_28
  INTO TABLE lt_data
  WHERE ono in s_ono.

IF lt_data IS NOT INITIAL.
  SELECT ONO OIN ODESC ICOST
    FROM ZORDI_29
    INTO TABLE lt_data1
    FOR ALL ENTRIES IN lt_data
    WHERE ono = lt_data-ono.
ENDIF.

LOOP AT lt_data INTO ls_data.
  LOOP AT lt_data1 INTO ls_data1 WHERE ono = ls_data-ono.
    ls_final-ono = ls_data-ono.
    ls_final-ODATE = ls_data-ODATE.
    ls_final-PM = ls_data-PM.
    ls_final-TA = ls_data-TA.
    ls_final-CURR = ls_data-CURR.
    ls_final-OIN = ls_data1-OIN.
    ls_final-ODESC = ls_data1-ODESC.
    ls_final-ICOST = ls_data1-ICOST.
    APPEND ls_final TO lt_final.
    CLEAR ls_final.
  ENDLOOP.
ENDLOOP.




CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
 EXPORTING
*   I_PROGRAM_NAME               =
*   I_INTERNAL_TABNAME           =
   I_STRUCTURE_NAME             = 'ZSTR_ALV_TESTE'
*   I_CLIENT_NEVER_DISPLAY       = 'X'
*   I_INCLNAME                   =
*   I_BYPASSING_BUFFER           =
*   I_BUFFER_ACTIVE              =
  CHANGING
    CT_FIELDCAT                  = lt_fieldcat
 EXCEPTIONS
   INCONSISTENT_INTERFACE       = 1
   PROGRAM_ERROR                = 2
   OTHERS                       = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
   IT_FIELDCAT                       = lt_fieldcat
  TABLES
    T_OUTTAB                          = lt_final
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.
