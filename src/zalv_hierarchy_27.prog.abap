REPORT ZALV_HIERARCHY_27.

"------------------------------------------------------
" Declaração de tabelas internas para o ALV
"------------------------------------------------------
DATA: lt_fieldcat TYPE SLIS_T_FIELDCAT_ALV,   "Tabela de catálogo de campos
      ls_fieldcat TYPE slis_fieldcat_alv.     "Linha do catálogo de campos

DATA: ls_keyinfo TYPE SLIS_KEYINFO_ALV.       "Estrutura que define relação Header → Item

"------------------------------------------------------
" Estrutura para dados de cabeçalho (VBAK)
"------------------------------------------------------
TYPES: BEGIN OF lty_vbak,
         VBELN TYPE VBELN_VA,   "Número do documento de vendas
         ERDAT TYPE ERDAT,      "Data de criação
         ERZET TYPE ERZET,      "Hora de criação
         ERNAM TYPE ERNAM,      "Usuário criador
         VBTYP TYPE VBTYP,      "Categoria do documento
       END OF lty_vbak.

DATA: lt_vbak TYPE TABLE OF lty_vbak,         "Tabela interna com cabeçalhos
      ls_vbak TYPE lty_vbak.

"------------------------------------------------------
" Estrutura para itens (VBAP)
"------------------------------------------------------
TYPES: BEGIN OF lty_vbap,
        VBELN TYPE VBELN_VA,    "Número do documento
        POSNR TYPE POSNR_VA,    "Número do item
        MATNR TYPE MATNR,       "Código do material
      END OF lty_vbap.

DATA: lt_vbap TYPE TABLE OF lty_vbap,         "Tabela interna com itens
      ls_vbap TYPE lty_vbap.

"------------------------------------------------------
" Seleção de documentos
"------------------------------------------------------
DATA: lv_vbeln TYPE VBELN_VA.
SELECT-OPTIONS: s_vbeln FOR lv_vbeln.

"------------------------------------------------------
" Seleção dos dados de cabeçalho (VBAK)
"------------------------------------------------------
SELECT VBELN ERDAT ERZET ERNAM VBTYP
  FROM VBAK
  INTO TABLE lt_vbak
  WHERE vbeln IN s_vbeln.

"------------------------------------------------------
" Seleção dos itens (VBAP) apenas se houver cabeçalhos
"------------------------------------------------------
IF lt_vbak IS NOT INITIAL.
  SELECT VBELN POSNR MATNR
    FROM VBAP
    INTO TABLE lt_vbap
    FOR ALL ENTRIES IN lt_vbak
    WHERE VBELN = lt_vbak-vbeln.
ENDIF.

"------------------------------------------------------
" Construção do catálogo de campos para o ALV (Header)
"------------------------------------------------------
ls_fieldcat-col_pos = '1'.
ls_fieldcat-fieldname  = 'VBELN'.
ls_fieldcat-tabname = 'LT_VBAK'.
ls_fieldcat-seltext_l = 'Sales Document Number'.
APPEND ls_fieldcat TO lt_fieldcat.
CLEAR ls_fieldcat.

ls_fieldcat-col_pos = '2'.
ls_fieldcat-fieldname  = 'ERDAT'.
ls_fieldcat-tabname = 'LT_VBAK'.
ls_fieldcat-seltext_l = 'Creation Date'.
APPEND ls_fieldcat TO lt_fieldcat.
CLEAR ls_fieldcat.

ls_fieldcat-col_pos = '3'.
ls_fieldcat-fieldname  = 'ERZET'.   "Removido espaço no final
ls_fieldcat-tabname = 'LT_VBAK'.
ls_fieldcat-seltext_l = 'Creation Time'.
APPEND ls_fieldcat TO lt_fieldcat.
CLEAR ls_fieldcat.

ls_fieldcat-col_pos = '4'.
ls_fieldcat-fieldname  = 'ERNAM'.
ls_fieldcat-tabname = 'LT_VBAK'.
ls_fieldcat-seltext_l = 'User'.
APPEND ls_fieldcat TO lt_fieldcat.
CLEAR ls_fieldcat.

ls_fieldcat-col_pos = '5'.
ls_fieldcat-fieldname  = 'VBTYP'.
ls_fieldcat-tabname = 'LT_VBAK'.
ls_fieldcat-seltext_l = 'Category'.
APPEND ls_fieldcat TO lt_fieldcat.
CLEAR ls_fieldcat.

"------------------------------------------------------
" Catálogo de campos para itens (VBAP)
"------------------------------------------------------
ls_fieldcat-col_pos = '1'.
ls_fieldcat-fieldname  = 'VBELN'.
ls_fieldcat-tabname = 'LT_VBAP'.
ls_fieldcat-seltext_l = 'Sales Document Number'.
APPEND ls_fieldcat TO lt_fieldcat.
CLEAR ls_fieldcat.

ls_fieldcat-col_pos = '2'.
ls_fieldcat-fieldname  = 'POSNR'.
ls_fieldcat-tabname = 'LT_VBAP'.
ls_fieldcat-seltext_l = 'Item Number'.
APPEND ls_fieldcat TO lt_fieldcat.
CLEAR ls_fieldcat.

ls_fieldcat-col_pos = '3'.
ls_fieldcat-fieldname  = 'MATNR'.
ls_fieldcat-tabname = 'LT_VBAP'.
ls_fieldcat-seltext_l = 'Material Number'.
APPEND ls_fieldcat TO lt_fieldcat.
CLEAR ls_fieldcat.

"------------------------------------------------------
" Definição da chave que liga Header → Item
"------------------------------------------------------
ls_keyinfo-header01 = 'VBELN'.   "Campo chave no cabeçalho
ls_keyinfo-item01   = 'VBELN'.   "Campo chave no item

"------------------------------------------------------
" Chamada do ALV Hierárquico
"------------------------------------------------------
CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
  EXPORTING
    IT_FIELDCAT          = lt_fieldcat
    I_TABNAME_HEADER     = 'LT_VBAK'   "Nome da tabela de cabeçalho
    I_TABNAME_ITEM       = 'LT_VBAP'   "Nome da tabela de itens (corrigido)
    IS_KEYINFO           = ls_keyinfo
  TABLES
    T_OUTTAB_HEADER      = lt_vbak
    T_OUTTAB_ITEM        = lt_vbap
  EXCEPTIONS
    PROGRAM_ERROR        = 1
    OTHERS               = 2.

IF sy-subrc <> 0.
  MESSAGE 'Erro ao gerar ALV hierárquico' TYPE 'E'.
ENDIF.
