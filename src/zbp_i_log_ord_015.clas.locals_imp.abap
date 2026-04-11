" 1. THE BUFFER
CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_insert TYPE TABLE OF ztlog_ord_015,
                mt_update TYPE TABLE OF ztlog_ord_015,
                mt_delete TYPE TABLE OF ztlog_ord_015,
                mt_item_insert TYPE TABLE OF ztlog_itm_015,
                mt_item_update TYPE TABLE OF ztlog_itm_015,
                mt_item_delete TYPE TABLE OF ztlog_itm_015.
ENDCLASS.

" 2. THE PARENT HANDLER (Freight Order)
CLASS lhc_FreightOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR FreightOrder RESULT result.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE FreightOrder.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE FreightOrder.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE FreightOrder.
    METHODS read FOR READ IMPORTING keys FOR READ FreightOrder RESULT result.
    METHODS SetDelivered FOR MODIFY IMPORTING keys FOR ACTION FreightOrder~SetDelivered RESULT result.
    METHODS cba_Items FOR MODIFY IMPORTING entities_cba FOR CREATE FreightOrder\_Items.

    " Lock method to prevent dumps
    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK FreightOrder.

    " RBA Method to clear Eclipse warnings
    METHODS rba_Items FOR READ
      IMPORTING keys_rba FOR READ FreightOrder\_Items FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_FreightOrder IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
      GET TIME STAMP FIELD DATA(lv_ts).
      APPEND VALUE #(
        order_id        = ls_entity-OrderId
        customer_name   = ls_entity-CustomerName
        status          = 'N'
        total_weight    = ls_entity-TotalWeight
        weight_unit     = ls_entity-WeightUnit
        created_at      = lv_ts
        last_changed_at = lv_ts
      ) TO lcl_buffer=>mt_insert.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA ls_db TYPE ztlog_ord_015.

    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM ztlog_ord_015 WHERE order_id = @ls_entity-OrderId INTO @ls_db.

      IF sy-subrc = 0.
        " Safety checks using %control
        IF ls_entity-%control-CustomerName = if_abap_behv=>mk-on.
          ls_db-customer_name = ls_entity-CustomerName.
        ENDIF.

        IF ls_entity-%control-Status = if_abap_behv=>mk-on.
          ls_db-status = ls_entity-Status.
        ENDIF.

        IF ls_entity-%control-TotalWeight = if_abap_behv=>mk-on.
          ls_db-total_weight = ls_entity-TotalWeight.
        ENDIF.

        IF ls_entity-%control-WeightUnit = if_abap_behv=>mk-on.
          ls_db-weight_unit = ls_entity-WeightUnit.
        ENDIF.

        GET TIME STAMP FIELD ls_db-last_changed_at.
        APPEND ls_db TO lcl_buffer=>mt_update.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( order_id = ls_key-OrderId ) TO lcl_buffer=>mt_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM ztlog_ord_015 FOR ALL ENTRIES IN @keys
      WHERE order_id = @keys-OrderId INTO TABLE @DATA(lt_db).

    " Explicit mapping to preserve UI data
    result = CORRESPONDING #( lt_db MAPPING OrderId = order_id
                                            CustomerName = customer_name
                                            Status = status
                                            TotalWeight = total_weight
                                            WeightUnit = weight_unit
                                            CreatedAt = created_at
                                            LastChangedAt = last_changed_at ).
  ENDMETHOD.

  METHOD SetDelivered.
    MODIFY ENTITIES OF zi_log_ord_015 IN LOCAL MODE
      ENTITY FreightOrder
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'D' ) ).
    READ ENTITIES OF zi_log_ord_015 IN LOCAL MODE
      ENTITY FreightOrder ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_order).
    result = VALUE #( FOR order IN lt_order ( %tky = order-%tky %param = order ) ).
  ENDMETHOD.

  METHOD cba_Items.
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_item).
        APPEND VALUE #(
          order_id      = ls_cba-OrderId
          item_id       = ls_item-ItemId
          material_name = ls_item-MaterialName
          quantity      = ls_item-Quantity
          unit          = ls_item-Unit
        ) TO lcl_buffer=>mt_item_insert.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Items.
  ENDMETHOD.
ENDCLASS.

" 3. THE CHILD HANDLER (Freight Item)
CLASS lhc_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Item.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Item.
    METHODS read FOR READ IMPORTING keys FOR READ Item RESULT result.

    " RBA Method to clear Eclipse warnings
    METHODS rba_Order FOR READ
      IMPORTING keys_rba FOR READ Item\_Order FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_Item IMPLEMENTATION.

  METHOD update.
    DATA ls_db TYPE ztlog_itm_015.

    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM ztlog_itm_015
        WHERE order_id = @ls_entity-OrderId AND item_id = @ls_entity-ItemId
        INTO @ls_db.

      IF sy-subrc = 0.
        " Safety checks using %control for Items
        IF ls_entity-%control-MaterialName = if_abap_behv=>mk-on.
          ls_db-material_name = ls_entity-MaterialName.
        ENDIF.

        IF ls_entity-%control-Quantity = if_abap_behv=>mk-on.
          ls_db-quantity = ls_entity-Quantity.
        ENDIF.

        IF ls_entity-%control-Unit = if_abap_behv=>mk-on.
          ls_db-unit = ls_entity-Unit.
        ENDIF.

        APPEND ls_db TO lcl_buffer=>mt_item_update.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( order_id = ls_key-OrderId item_id = ls_key-ItemId ) TO lcl_buffer=>mt_item_delete.
    ENDLOOP.
  ENDMETHOD.

METHOD read.
    SELECT * FROM ztlog_itm_015 FOR ALL ENTRIES IN @keys
      WHERE order_id = @keys-OrderId AND item_id = @keys-ItemId INTO TABLE @DATA(lt_db).

    " Explicit mapping for the Item
    result = CORRESPONDING #( lt_db MAPPING OrderId = order_id
                                            ItemId = item_id
                                            MaterialName = material_name
                                            Quantity = quantity
                                            Unit = unit ).
  ENDMETHOD.
  METHOD rba_Order.
  ENDMETHOD.
ENDCLASS.

" 4. THE SAVER CLASS
CLASS lsc_zi_log_ord_015 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save              REDEFINITION.
    METHODS cleanup           REDEFINITION.
    METHODS cleanup_finalize  REDEFINITION.
ENDCLASS.

CLASS lsc_zi_log_ord_015 IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    " --- Save Orders ---
    IF lcl_buffer=>mt_insert IS NOT INITIAL.
      INSERT ztlog_ord_015 FROM TABLE @lcl_buffer=>mt_insert.
    ENDIF.

    IF lcl_buffer=>mt_update IS NOT INITIAL.
      LOOP AT lcl_buffer=>mt_update INTO DATA(ls_upd).
        UPDATE ztlog_ord_015
          SET customer_name = @ls_upd-customer_name,
              status = @ls_upd-status,
              total_weight = @ls_upd-total_weight,
              weight_unit = @ls_upd-weight_unit,
              last_changed_at = @ls_upd-last_changed_at
          WHERE order_id = @ls_upd-order_id.
      ENDLOOP.
    ENDIF.

    IF lcl_buffer=>mt_delete IS NOT INITIAL.
      LOOP AT lcl_buffer=>mt_delete INTO DATA(ls_del).
        DELETE FROM ztlog_ord_015 WHERE order_id = @ls_del-order_id.
      ENDLOOP.
    ENDIF.

    " --- Save Items ---
    IF lcl_buffer=>mt_item_insert IS NOT INITIAL.
      INSERT ztlog_itm_015 FROM TABLE @lcl_buffer=>mt_item_insert.
    ENDIF.

    IF lcl_buffer=>mt_item_update IS NOT INITIAL.
      LOOP AT lcl_buffer=>mt_item_update INTO DATA(ls_itm_upd).
        UPDATE ztlog_itm_015
          SET material_name = @ls_itm_upd-material_name,
              quantity = @ls_itm_upd-quantity,
              unit = @ls_itm_upd-unit
          WHERE order_id = @ls_itm_upd-order_id AND item_id = @ls_itm_upd-item_id.
      ENDLOOP.
    ENDIF.

    IF lcl_buffer=>mt_item_delete IS NOT INITIAL.
      LOOP AT lcl_buffer=>mt_item_delete INTO DATA(ls_itm_del).
        DELETE FROM ztlog_itm_015 WHERE order_id = @ls_itm_del-order_id AND item_id = @ls_itm_del-item_id.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lcl_buffer=>mt_insert, lcl_buffer=>mt_update, lcl_buffer=>mt_delete,
           lcl_buffer=>mt_item_insert, lcl_buffer=>mt_item_update, lcl_buffer=>mt_item_delete.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
" --- END OF CODE - ENSURE YOU COPIED DOWN TO THE PERIOD ABOVE THIS LINE ---
