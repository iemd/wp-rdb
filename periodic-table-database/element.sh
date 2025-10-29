#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # if not a number
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    # get element info
    ELEMENT_INFO=$($PSQL "SELECT * FROM elements
    INNER JOIN properties USING(atomic_number)
    INNER JOIN types USING(type_id)
    WHERE symbol='$1' OR name='$1'
    ORDER BY atomic_number;")
  else
    # get element info
    ELEMENT_INFO=$($PSQL "SELECT * FROM elements
    INNER JOIN properties USING(atomic_number)
    INNER JOIN types USING(type_id)
    WHERE atomic_number=$1
    ORDER BY atomic_number;")
  fi
  # if not found
  if [[ -z $ELEMENT_INFO ]]
  then
    echo "I could not find that element in the database."
  else
    # display element info
    echo "$ELEMENT_INFO" | while IFS="|" read TYPE_ID AN SYMBOL NAME AM MPC BPC TYPE
    do
      echo -e "The element with atomic number $AN is $NAME ($SYMBOL). It's a $TYPE, with a mass of $AM amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius."
    done
  fi
fi
