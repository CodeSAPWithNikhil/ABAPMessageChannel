REPORT zamc_message_sender.
PARAMETERS: msg TYPE string DEFAULT 'Hey, message receiver ❤️!' OBLIGATORY LOWER CASE.

START-OF-SELECTION.
  DATA: o_msg_producer TYPE REF TO if_amc_message_producer_text.
  TRY.
      o_msg_producer ?= cl_amc_channel_manager=>create_message_producer(
        i_application_id = 'ZAMC_BASIC'
        i_channel_id     = '/ping' ).

      IF o_msg_producer IS BOUND.
        o_msg_producer->send( msg ).

        "MESSAGE 'message sent to receiver ;)' TYPE 'I'.
      ENDIF.
    CATCH cx_root INTO DATA(x_dump).
      WRITE:/ x_dump->get_longtext(  ).
  ENDTRY.