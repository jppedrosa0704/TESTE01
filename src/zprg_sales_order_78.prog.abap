REPORT ZPRG_SALES_ORDER_78.

*-----------------------------------------------------------------------
* Declaração de variáveis auxiliares
*-----------------------------------------------------------------------
DATA: lv_vbeln TYPE vbeln_va.

*-----------------------------------------------------------------------
* Catálogo de campos do ALV para VBAK (cabeçalho)
*-----------------------------------------------------------------------
DATA: lt_fieldcat_vbak TYPE slis_t_fieldcat_alv,
      ls_fieldcat_vbak TYPE slis_fieldcat_alv.

*-----------------------------------------------------------------------
* Catálogo de campos do ALV para VBAP (itens)
*-----------------------------------------------------------------------
DATA: lt_fieldcat_vbap TYPE slis_t_fieldcat_alv,
      ls_fieldcat_vbap TYPE slis_fieldcat_alv.

*-----------------------------------------------------------------------
* Estrutura para armazenar os dados do cabeçalho do pedido de venda
* (Tabela VBAK)
*-----------------------------------------------------------------------
TYPES: BEGIN OF lty_vbak,
         vbeln TYPE vbeln_va,   "Número do pedido
         erdat TYPE erdat,      "Data de criação
         erzet TYPE erzet,      "Hora de criação
         ernam TYPE ernam,      "Utilizador criador
         vbtyp TYPE vbtyp,      "Tipo de documento SD
       END OF lty_vbak.

*-----------------------------------------------------------------------
* Tabela interna e Work Area para armazenar os registos da VBAK
*-----------------------------------------------------------------------
DATA: lt_vbak TYPE TABLE OF lty_vbak,
      ls_vbak TYPE lty_vbak.

*-----------------------------------------------------------------------
* Estrutura para armazenar os itens do pedido de venda
* (Tabela VBAP)
*-----------------------------------------------------------------------
TYPES: BEGIN OF lty_vbap,
         vbeln TYPE vbeln_va,   "Número do pedido
         posnr TYPE posnr_va,   "Número do item
         matnr TYPE matnr,      "Código do material
       END OF lty_vbap.

*-----------------------------------------------------------------------
* Tabela interna e Work Area dos itens
*-----------------------------------------------------------------------
DATA: lt_vbap TYPE TABLE OF lty_vbap,
      ls_vbap TYPE lty_vbap.

*-----------------------------------------------------------------------
* Select-Option para permitir ao utilizador informar
* um ou vários números de pedido
*-----------------------------------------------------------------------
SELECT-OPTIONS: s_vbeln FOR lv_vbeln.

*-----------------------------------------------------------------------
* Leitura dos dados do cabeçalho dos pedidos de venda
* conforme seleção do utilizador
*-----------------------------------------------------------------------
SELECT vbeln
       erdat
       erzet
       ernam
       vbtyp
  FROM vbak
  INTO TABLE lt_vbak
 WHERE vbeln IN s_vbeln.

*-----------------------------------------------------------------------
* Construção do catálogo de campos do ALV - VBAK
*-----------------------------------------------------------------------

* Coluna 1 - Número do Pedido
ls_fieldcat_vbak-col_pos   = '1'.
ls_fieldcat_vbak-fieldname = 'VBELN'.
ls_fieldcat_vbak-tabname   = 'LT_VBAK'.
ls_fieldcat_vbak-hotspot   = 'X'.
ls_fieldcat_vbak-seltext_l = 'Sales Order Number'.
APPEND ls_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

* Coluna 2 - Data de Criação
ls_fieldcat_vbak-col_pos   = '2'.
ls_fieldcat_vbak-fieldname = 'ERDAT'.
ls_fieldcat_vbak-tabname   = 'LT_VBAK'.
ls_fieldcat_vbak-seltext_l = 'Creation Date'.
APPEND ls_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

* Coluna 3 - Hora de Criação
ls_fieldcat_vbak-col_pos   = '3'.
ls_fieldcat_vbak-fieldname = 'ERZET'.
ls_fieldcat_vbak-tabname   = 'LT_VBAK'.
ls_fieldcat_vbak-seltext_l = 'Time'.
APPEND ls_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

* Coluna 4 - Utilizador Criador
ls_fieldcat_vbak-col_pos   = '4'.
ls_fieldcat_vbak-fieldname = 'ERNAM'.
ls_fieldcat_vbak-tabname   = 'LT_VBAK'.
ls_fieldcat_vbak-seltext_l = 'Created By'.
APPEND ls_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

* Coluna 5 - Tipo de Documento
ls_fieldcat_vbak-col_pos   = '5'.
ls_fieldcat_vbak-fieldname = 'VBTYP'.
ls_fieldcat_vbak-tabname   = 'LT_VBAK'.
ls_fieldcat_vbak-seltext_l = 'Document Type'.
APPEND ls_fieldcat_vbak TO lt_fieldcat_vbak.
CLEAR ls_fieldcat_vbak.

*-----------------------------------------------------------------------
* Apresentação do ALV principal (Cabeçalho de Pedidos)
*-----------------------------------------------------------------------
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program      = sy-repid
    i_callback_pf_status_set = 'PF-STATUS'
    i_callback_user_command  = 'USR_COMMAND'
    it_fieldcat             = lt_fieldcat_vbak
  TABLES
    t_outtab                = lt_vbak
  EXCEPTIONS
    program_error           = 1
    others                  = 2.

IF sy-subrc <> 0.
* Tratamento de erro da chamada do ALV
ENDIF.

*-----------------------------------------------------------------------
* FORM responsável por definir o PF-STATUS do ALV
*-----------------------------------------------------------------------
FORM pf-status USING rt_extab TYPE slis_t_extab.

* Ativa o status GUI chamado SALES
  SET PF-STATUS 'SALES'.

ENDFORM.

*-----------------------------------------------------------------------
* Evento disparado quando o utilizador faz uma ação
* sobre uma linha do ALV (duplo clique, botão, etc.)
*-----------------------------------------------------------------------
FORM usr_command USING r_ucomm LIKE sy-ucomm
                       rs_selfield TYPE slis_selfield.
  IF r_ucomm = 'DISPLAY'.
*-----------------------------------------------------------------------
* Limpa catálogo dos itens antes de reconstruí-lo
*-----------------------------------------------------------------------
    REFRESH lt_fieldcat_vbap.

*  -----------------------------------------------------------------------
*   Obtém a linha selecionada no ALV principal
*  -----------------------------------------------------------------------
    READ TABLE lt_vbak INTO ls_vbak
         INDEX rs_selfield-tabindex.

    IF sy-subrc = 0.

*  -----------------------------------------------------------------------
*   Procura todos os itens do pedido selecionado
*   na tabela VBAP
*  -----------------------------------------------------------------------
      SELECT vbeln
             posnr
             matnr
        FROM vbap
        INTO TABLE lt_vbap
        WHERE vbeln = ls_vbak-vbeln.

*  -----------------------------------------------------------------------
*   Construção do catálogo de campos do ALV dos itens
*  -----------------------------------------------------------------------

*   Coluna 1 - Número do Pedido
      ls_fieldcat_vbap-col_pos   = '1'.
      ls_fieldcat_vbap-fieldname = 'VBELN'.
      ls_fieldcat_vbap-tabname   = 'LT_VBAP'.
      ls_fieldcat_vbap-seltext_l = 'Sales Order'.
      APPEND ls_fieldcat_vbap TO lt_fieldcat_vbap.
      CLEAR ls_fieldcat_vbap.

*   Coluna 2 - Número do Item
      ls_fieldcat_vbap-col_pos   = '2'.
      ls_fieldcat_vbap-fieldname = 'POSNR'.
      ls_fieldcat_vbap-tabname   = 'LT_VBAP'.
      ls_fieldcat_vbap-seltext_l = 'Item Number'.
      APPEND ls_fieldcat_vbap TO lt_fieldcat_vbap.
      CLEAR ls_fieldcat_vbap.

*   Coluna 3 - Material
      ls_fieldcat_vbap-col_pos   = '3'.
      ls_fieldcat_vbap-fieldname = 'MATNR'.
      ls_fieldcat_vbap-tabname   = 'LT_VBAP'.
      ls_fieldcat_vbap-seltext_l = 'Material'.
      APPEND ls_fieldcat_vbap TO lt_fieldcat_vbap.
      CLEAR ls_fieldcat_vbap.

*  -----------------------------------------------------------------------
*   Exibe um segundo ALV com os itens do pedido selecionado
*  -----------------------------------------------------------------------
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          it_fieldcat = lt_fieldcat_vbap
        TABLES
          t_outtab    = lt_vbap
        EXCEPTIONS
          program_error = 1
          others        = 2.

      IF sy-subrc <> 0.
*       Tratamento de erro
      ENDIF.
    ENDIF.
  ENDIF.
  IF r_ucomm = '&IC1'.
    SET PARAMETER ID 'AUN' FIELD rs_selfield-value.
    CALL TRANSACTION 'VA03'.
*    LEAVE TO TRANSACTION 'VA03'.
  ENDIF.
ENDFORM.
