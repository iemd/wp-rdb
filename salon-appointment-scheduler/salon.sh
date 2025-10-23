#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {

  if [[ -z $1 ]]
  then
    echo -e "Welcome to My Salon, how can I help you?"
    echo -e "\n"
  else
    echo -e "\n$1"
  fi

  # get all services
  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services")

  # display all services
  echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  # ask for service
  read SERVICE_ID_SELECTED
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # if not found
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if not found
    if [[ -z $CUSTOMER_ID ]]
    then
      # ask customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # ask service time
      echo -e "\nWhat time would you like your$SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name)
      VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      # get new customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # add appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time)
      VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
      then
        echo -e "\nI have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    else
      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # ask service time
      echo -e "\nWhat time would you like your$SERVICE_NAME_SELECTED,$CUSTOMER_NAME?"
      read SERVICE_TIME
      # add new appointment
      INSERT_NEW_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time)
      VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      if [[ $INSERT_NEW_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
      then
        echo -e "\nI have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME,$CUSTOMER_NAME."
      fi
    fi
  fi
}

MAIN_MENU
