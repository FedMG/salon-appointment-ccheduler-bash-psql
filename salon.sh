#!/bin/bash

PSQL="psql -X -U freecodecamp -d salon --no-align --tuples-only -c"
echo -e "\n~~~~ Welcome to Beauty Haven Salon ~~~~\n"

PRINT () {
  if [[ $2 == 'success' ]]; then
    echo -e "\033[32m$1\033[0m"
    elif [[ $2 == 'warning' ]]; then
    echo -e "\033[33m$1\033[0m"
    elif [[ $2 == 'error' ]]; then
    echo -e "\033[31m$1\033[0m"
    else
    echo -e "$1"
  fi

}

GET_SERVICES_LIST () {
  if [[ $1 ]]
   then
     PRINT "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n~ $1 ~\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" "warning"
  fi


  PRINT "\nHello, Sary here! I'm your Virtual Assistant,\nWould you like to make an appointment?\nThis following list are our services:"
  PRINT "\n1) Haircut and styling.\n2) Hair coloring and highlights.\n3) Hair extensions.\n4) Hair straightening and perming.\n5) Manicures and pedicures.\n6) Nail extensions and nail art.\n7) Facials and skincare treatments.\n8) Waxing and hair removal.\n9) Makeup application and lessons.\n10) Eyelash extensions and tinting.\n-----------------------------------------------------------------"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    [1-9]|10) SET_APPOINTMENT $SERVICE_ID_SELECTED;;    
    *) GET_SERVICES_LIST "Please, enter a valid option.";;
  esac
}


SET_APPOINTMENT () {
  local SERVICE_ID="$1"
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
  PRINT "\n\n ~~~~~~~~~~ [  $SERVICE_NAME  ] ~~~~~~~~~~\n"


  while true; do
    PRINT 'Enter your phone number to make your appointment:'
    read CUSTOMER_PHONE
    IS_CUSTOMER_REGISTERED=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    PHONE_LENGTH=${#CUSTOMER_PHONE}
    if [[ $IS_CUSTOMER_REGISTERED && $PHONE_LENGTH -ge 10 && $PHONE_LENGTH -lt 15 ]]; then
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $IS_CUSTOMER_REGISTERED")

      while true; do
        PRINT "\nHi $CUSTOMER_NAME, what time would you like to make an appointment?"
        read SERVICE_TIME

        if [[ $SERVICE_TIME =~ ^([01]?[0-9]|2[0-3])(:[0-5][0-9])?([ap]m)?$ ]]; then
            echo $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($IS_CUSTOMER_REGISTERED, $SERVICE_ID, '$SERVICE_TIME')" > /dev/null)
            PRINT "\n\nI have put you down for a \033[32m$SERVICE_NAME\033[0m at \033[32m$SERVICE_TIME\033[0m, \033[32m$CUSTOMER_NAME\033[0m. \n\n"                

            break
          else
            PRINT "$CUSTOMER_NAME, enter a valid time format (HH:MM)." "warning"
        fi
      done

      break
    elif [[ -z $IS_CUSTOMER_REGISTERED && $PHONE_LENGTH -ge 10 && $PHONE_LENGTH -lt 15 ]]; then
      PRINT "\nYour phone is not registered." "error"

      while true; do
        PRINT "Enter your name to register you:"
        read CUSTOMER_NAME
        NAME_LENGTH=${#CUSTOMER_NAME}
        
        if [[ $CUSTOMER_NAME && $NAME_LENGTH -ge 3 && $NAME_LENGTH -le 50 ]]; then
          echo $($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" > /dev/null)
          PRINT "\n#### Hello $CUSTOMER_NAME, your phone number has been registered! ####\n" "success"

            while true; do
              PRINT "\n$CUSTOMER_NAME, what time would you like to make an appointment?"
              read SERVICE_TIME

              if [[ $SERVICE_TIME =~ ^([01]?[0-9]|2[0-3])(:[0-5][0-9])?([ap]m)?$ ]]; then
                  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
                  echo $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')" > /dev/null)

                  PRINT "\n\nI have put you down for a \033[32m$SERVICE_NAME\033[0m at \033[32m$SERVICE_TIME\033[0m, \033[32m$CUSTOMER_NAME\033[0m. \n\n"
                  break
                else
                  PRINT "$CUSTOMER_NAME, please enter a valid time format (HH:MM)." "warning"
              fi
            done

          break
          else
            PRINT "\nInvalid name, please try again." "warning"
        fi
      done
      break
    else
      PRINT "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n~ [ Your phone number is invalid ] ~\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" "warning"
      PRINT "Note: It should has a length greater than or equal to 10 and less than 15.\n\n\nPlease, try again."
    fi
  done

  echo -e "A- Did you do it?\nB- Yes...\nA- What did it cost?\nB- Everything..."
}

GET_SERVICES_LIST
