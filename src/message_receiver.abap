REPORT zamc_message_receiver.

CLASS lcl_amc_callback DEFINITION.

  PUBLIC SECTION.
    INTERFACES: if_amc_message_receiver_text.
    METHODS: get_messages
      RETURNING VALUE(rt_messages) TYPE string_table.
  PRIVATE SECTION.
    DATA: t_messages TYPE TABLE OF string.
ENDCLASS.

PARAMETERS: wait_sec TYPE i DEFAULT 4 OBLIGATORY.

START-OF-SELECTION.
  TRY.
      DATA(o_amc_consumer) = CAST if_amc_message_consumer( cl_amc_channel_manager=>create_message_consumer(
                                                              i_application_id       =   'ZAMC_BASIC'
                                                              i_channel_id           =   '/ping' ) ).



      IF o_amc_consumer IS BOUND.

        DATA(o_amc_callback_object) = NEW lcl_amc_callback(  ).
        o_amc_consumer->start_message_delivery( i_receiver = o_amc_callback_object ).

        WAIT FOR MESSAGING CHANNELS UNTIL lines( o_amc_callback_object->get_messages(  ) ) > 4 UP TO wait_sec SECONDS.

        IF lines( o_amc_callback_object->get_messages(  ) ) = 0.

          cl_demo_output=>display( |Message sender didn't send any message :( | ).
        ELSE.

          LOOP AT o_amc_callback_object->get_messages(  )  INTO DATA(v_message).
            MESSAGE v_message TYPE 'I'.
          ENDLOOP.

        ENDIF.
      ELSE.

        WRITE: 'Consumer object not bound'.
      ENDIF.

    CATCH cx_root INTO DATA(x_root).
      WRITE: x_root->get_longtext(  ).

  ENDTRY.


CLASS lcl_amc_callback IMPLEMENTATION.
  METHOD get_messages.
    rt_messages = t_messages.
  ENDMETHOD.
  METHOD if_amc_message_receiver_text~receive.
    APPEND i_message TO t_messages.
  ENDMETHOD.
ENDCLASS.