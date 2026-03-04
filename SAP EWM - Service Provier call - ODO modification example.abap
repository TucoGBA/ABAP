    DATA lt_docno               TYPE /scwm/dlv_docno_tab.
    DATA lt_mapping             TYPE /scwm/dlv_prd_map_tab.
    DATA lt_docid               TYPE /scwm/dlv_docid_item_tab.
    DATA ls_include_data        TYPE /scwm/dlv_query_incl_str_prd.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lt_headers             TYPE /scwm/dlv_header_out_prd_tab.
    DATA lt_items               TYPE /scwm/dlv_item_out_prd_tab.
    DATA lt_sp_k_head           TYPE /scdl/t_sp_k_head.
    DATA lt_sp_k_head_transport TYPE /scdl/t_sp_k_head_transport.
    DATA lv_rejected            TYPE boole_d.
    DATA lt_return_codes        TYPE /scdl/t_sp_return_code.
    DATA lt_outrecords          TYPE /scdl/t_sp_a_head_transport.
    DATA lt_sp_k_item           TYPE /scdl/t_sp_k_item.
    DATA lt_items_outrecords    TYPE /scdl/t_sp_a_item.
    DATA lt_in_head_transport   TYPE /scdl/t_sp_a_head_transport.
    DATA ls_sp_action           TYPE /scdl/s_sp_act_action.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lt_head_out            TYPE /scdl/t_sp_a_head.
    DATA lv_error_occured       TYPE abap_bool.
    DATA ls_entity              TYPE /rbl0/cl_ewm_next_pack_mpc_ext=>bapireturn.

    DATA(lo_msg) = mo_context->get_message_container( ).
    DATA(lo_message_box) = NEW /scdl/cl_sp_message_box( ).
    DATA(lo_dlv_bo) = /scwm/cl_dlv_management_prd=>get_instance( ).

    DATA(lv_docno) = |{ iv_docno ALPHA = IN }|.
    DATA(lv_lgnum) = iv_lgnum.

    lt_docno = VALUE #( ( doccat = /scdl/if_dl_doc_c=>sc_doccat_out_prd docno = lv_docno ) ).

    lo_dlv_bo->map_docno_to_docid( EXPORTING it_docno   = lt_docno
                                   IMPORTING et_mapping = lt_mapping ).

    DATA(lv_docid) = lt_mapping[ docno = lv_docno ]-docid.

    IF lv_docid IS INITIAL.
      lo_msg->add_message( iv_msg_type   = 'E'
                           iv_msg_id     = '/RBL0/EWM_NPD'
                           iv_msg_number = 009 ).
      error_handling( lo_msg ).
    ENDIF.

*    ROLLBACK WORK.
*    /scwm/cl_tm=>cleanup( ).

    IF /scwm/cl_tm=>sv_lgnum IS INITIAL.
      /scwm/cl_tm=>set_lgnum( iv_lgnum = lv_lgnum ).
    ENDIF.

    lt_docid = VALUE #( ( doccat = /scdl/if_dl_doc_c=>sc_doccat_out_prd docid = lv_docid ) ).
    ls_include_data-head_transport = 'X'.

    TRY.
        lo_dlv_bo->query( EXPORTING it_docid        = lt_docid
                                    iv_whno         = lv_lgnum
                                    is_include_data = ls_include_data
                          IMPORTING et_headers      = lt_headers
                                    et_items        = lt_items ).
      CATCH /scdl/cx_delivery.
        lo_msg->add_message( iv_msg_type   = 'E'
                             iv_msg_id     = '/RBL0/EWM_NPD'
                             iv_msg_number = 009 ).
        error_handling( lo_msg ).
    ENDTRY.

    DATA(lo_dlv) = NEW /scdl/cl_sp_prd_out( io_message_box = lo_message_box
                                            iv_doccat      = /scdl/if_dl_doc_c=>sc_doccat_out_prd
                                            iv_mode        = /scdl/cl_sp=>sc_mode_classic ).

    lt_sp_k_head = VALUE #( ( docid = lv_docid ) ).
    lt_sp_k_head_transport = VALUE #( ( docid = lv_docid counter = 1  ) ).

    " lock dlv.
    lo_dlv->lock( EXPORTING inkeys       = lt_sp_k_head
                            aspect       = /scdl/if_sp_c=>sc_asp_head
                            lockmode     = /scdl/if_sp1_locking=>sc_exclusive_lock
                  IMPORTING rejected     = lv_rejected
                            return_codes = lt_return_codes ).
    " select head aspect
    lo_dlv->select( EXPORTING inkeys       = lt_sp_k_head_transport
                              aspect       = /scdl/if_sp_c=>sc_asp_head_transport
                    IMPORTING outrecords   = lt_outrecords
                              rejected     = lv_rejected
                              return_codes = lt_return_codes ).

    lt_sp_k_item = VALUE #( FOR wa IN lt_items
                            ( docid = wa-docid itemid = wa-itemid ) ).
    " select item aspect
    lo_dlv->select( EXPORTING inkeys       = lt_sp_k_item
                              aspect       = /scdl/if_sp_c=>sc_asp_item
                    IMPORTING outrecords   = lt_items_outrecords
                              rejected     = lv_rejected
                              return_codes = lt_return_codes ).

    IF line_exists( lt_return_codes[ failed = abap_true ] ) OR lv_rejected = abap_true.
      DATA(lt_messages) = lo_message_box->get_messages( ).
      LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<fs_message>).
        lo_msg->add_message( iv_msg_type               = <fs_message>-msgty
                             iv_msg_id                 = <fs_message>-msgid
                             iv_msg_number             = <fs_message>-msgno
                             iv_msg_v1                 = <fs_message>-msgv1
                             iv_msg_v2                 = <fs_message>-msgv2
                             iv_msg_v3                 = <fs_message>-msgv3
                             iv_msg_v4                 = <fs_message>-msgv4
                             iv_add_to_response_header = abap_true ).
      ENDLOOP.
      error_handling( lo_msg ).
    ENDIF.

    " make dummy change to trigger all dlv. actions (like save).
    lt_in_head_transport = lt_outrecords.
    LOOP AT lt_in_head_transport ASSIGNING FIELD-SYMBOL(<fs_in_head_transport>).
      <fs_in_head_transport>-transmeans_id = <fs_in_head_transport>-transmeans_id && '1'.
    ENDLOOP.

    ls_sp_action-action_code = /scdl/if_bo_action_c=>sc_change.
    lo_dlv->execute( EXPORTING aspect       = /scdl/if_sp_c=>sc_asp_head
                               inkeys       = lt_sp_k_head
                               inparam      = ls_sp_action
                               action       = /scdl/if_sp_c=>sc_act_execute_action
                     IMPORTING outrecords   = lt_head_out
                               rejected     = lv_rejected
                               return_codes = lt_return_codes ).

    " check if any error occurred
    IF line_exists( lt_return_codes[ failed = abap_true ] ) OR lv_rejected = abap_true.
      lv_error_occured = abap_true.
      lt_messages = lo_message_box->get_messages( ).
      LOOP AT lt_messages ASSIGNING <fs_message>.
        lo_msg->add_message( iv_msg_type               = <fs_message>-msgty
                             iv_msg_id                 = <fs_message>-msgid
                             iv_msg_number             = <fs_message>-msgno
                             iv_msg_v1                 = <fs_message>-msgv1
                             iv_msg_v2                 = <fs_message>-msgv2
                             iv_msg_v3                 = <fs_message>-msgv3
                             iv_msg_v4                 = <fs_message>-msgv4
                             iv_add_to_response_header = abap_true ).
      ENDLOOP.
      error_handling( lo_msg ).
    ENDIF.

    lo_dlv->update( EXPORTING aspect       = /scdl/if_sp_c=>sc_asp_head_transport
                              inrecords    = lt_in_head_transport
                    IMPORTING outrecords   = lt_outrecords
                              rejected     = lv_rejected
                              return_codes = lt_return_codes ).

    IF line_exists( lt_return_codes[ failed = abap_true ] ) OR lv_rejected = abap_true.
      lv_error_occured = abap_true.
      lt_messages = lo_message_box->get_messages( ).
      LOOP AT lt_messages ASSIGNING <fs_message>.
        lo_msg->add_message( iv_msg_type               = <fs_message>-msgty
                             iv_msg_id                 = <fs_message>-msgid
                             iv_msg_number             = <fs_message>-msgno
                             iv_msg_v1                 = <fs_message>-msgv1
                             iv_msg_v2                 = <fs_message>-msgv2
                             iv_msg_v3                 = <fs_message>-msgv3
                             iv_msg_v4                 = <fs_message>-msgv4
                             iv_add_to_response_header = abap_true ).
      ENDLOOP.
      error_handling( lo_msg ).
    ENDIF.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(lt_items_new_out) = lt_items_outrecords.
    CLEAR lt_items_new_out.

    lo_dlv->update( EXPORTING aspect       = /scdl/if_sp_c=>sc_asp_item
                              inrecords    = lt_items_outrecords
                    IMPORTING outrecords   = lt_items_new_out
                              rejected     = lv_rejected
                              return_codes = lt_return_codes ).

    IF line_exists( lt_return_codes[ failed = abap_true ] ) OR lv_rejected = abap_true.
      lv_error_occured = abap_true.
      lt_messages = lo_message_box->get_messages( ).
      LOOP AT lt_messages ASSIGNING <fs_message>.
        lo_msg->add_message( iv_msg_type               = <fs_message>-msgty
                             iv_msg_id                 = <fs_message>-msgid
                             iv_msg_number             = <fs_message>-msgno
                             iv_msg_v1                 = <fs_message>-msgv1
                             iv_msg_v2                 = <fs_message>-msgv2
                             iv_msg_v3                 = <fs_message>-msgv3
                             iv_msg_v4                 = <fs_message>-msgv4
                             iv_add_to_response_header = abap_true ).
      ENDLOOP.
      error_handling( lo_msg ).
    ENDIF.

    IF lv_error_occured = abap_false.

      lo_dlv->save( EXPORTING synchronously = abap_false
                    IMPORTING rejected      = lv_rejected ).

      COMMIT WORK AND WAIT.
      /scwm/cl_tm=>cleanup( ). " clear buffers and release locks
      ls_entity-type = 'S'.
    ELSE.
      ROLLBACK WORK.
      /scwm/cl_tm=>cleanup( ). " clear buffers and release locks
      ls_entity-type = 'E'.
    ENDIF.

    lo_dlv->unlock( inkeys = lt_sp_k_head
                    aspect = /scdl/if_sp_c=>sc_asp_head ).

    rs_enrity = ls_entity.
