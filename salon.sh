#! /bin/bash

#
# Variables
#

readonly PSQL="psql --username=freecodecamp --dbname=salon -t -c "

#
# Functions
#
get_service_menu() {
  if [[ -n "$1" ]]; then
    echo -e "$1"
  fi
  services=$(${PSQL} "SELECT service_id, name FROM services ORDER BY service_id")
  
  echo "$services" | while read SERVICE_ID SERVICE
  do
    service_id=$(echo ${SERVICE_ID} | sed -e 's/ //g')
    service_name=$(echo ${SERVICE} | sed -e 's/ //g' -e 's/|//g')
    echo "${service_id}) ${service_name}"
  done
}

#
# Main program
#

echo
echo " ~  ~  ~  ~  ~ Netz' Salon ~  ~  ~  ~  ~ "
echo
echo  "Welcome to us, how can we help you?"
echo 

# Fetching all services and printing them as menu.
msg=
while [[ -z "${valid_service}" ]]; do
  get_service_menu "I could not find that service. What would you like today?"
  read SERVICE_ID_SELECTED
  valid_service=$(${PSQL} "SELECT name FROM services WHERE service_id = '${SERVICE_ID_SELECTED}'" | sed -e 's/^ //g')
    
  if [[ -z "${valid_service}" ]]; then
    msg="I could not find that service. What would you like today?"
  fi
done
SERVICE="${valid_service}"

echo "What's your phone number?"
read CUSTOMER_PHONE

existent_customer=$(${PSQL} "SELECT name FROM customers WHERE phone = '${CUSTOMER_PHONE}'" | sed -e 's/^ //g')
      
if [[ -z "${existent_customer}" ]]; then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  create_result=$(${PSQL} "INSERT INTO customers (phone, name) VALUES('${CUSTOMER_PHONE}','${CUSTOMER_NAME}');")
else
  CUSTOMER_NAME="${existent_customer}"
fi

echo
echo "What time would you like your ${SERVICE}, ${CUSTOMER_NAME}?"
read SERVICE_TIME
      
book_result=$(${PSQL} "INSERT INTO appointments (customer_id, service_id,time) VALUES( (SELECT customer_id FROM customers WHERE phone = '${CUSTOMER_PHONE}'), '${SERVICE_ID_SELECTED}', '${SERVICE_TIME}' );")
echo
echo "I have put you down for a ${SERVICE} at ${SERVICE_TIME}, ${CUSTOMER_NAME}."

      


