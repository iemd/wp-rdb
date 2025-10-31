#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

NUMBER_GUESSING_GAME() {
  if [[ -z $1 ]]
  then
    # if username already exists
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    # get user game info
    GAME_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id = $USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
  else
    USER_ID=$1
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi

  # generate secret number
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  START_GAME=$($PSQL "INSERT INTO games(secret_number, user_id) VALUES($SECRET_NUMBER, $USER_ID)")
  GAME_ID=$($PSQL "SELECT game_id From games WHERE secret_number = $SECRET_NUMBER AND user_id = $USER_ID")

  # get user input
  echo "Guess the secret number between 1 and 1000:"
  read USER_INPUT
  # count number of guesses
  NUMBER_OF_GUESSES=1

  # if not a number
  until [[ $USER_INPUT =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_INPUT
    (( NUMBER_OF_GUESSES++ ))
  done

  # check for secret number
  while [[ $USER_INPUT != $SECRET_NUMBER ]]
  do
    if (( $USER_INPUT > $SECRET_NUMBER ))
    then
      echo "It's lower than that, guess again:"
      read USER_INPUT
    else
      echo "It's higher than that, guess again:"
      read USER_INPUT
    fi
    (( NUMBER_OF_GUESSES++ ))
  done

  # insert number of guesses
  UPDATE_GUESSES_RESULT=$($PSQL "UPDATE games SET number_of_guesses=$NUMBER_OF_GUESSES
  WHERE game_id = $GAME_ID AND user_id = $USER_ID")
  # display number of guesses
  if [[ $UPDATE_GUESSES_RESULT == "UPDATE 1" ]]
  then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi
}

# get user_id from database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
# if not found
if [[ -z $USER_ID ]]
then
  # insert new username
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  if [[ $INSERT_USERNAME_RESULT == "INSERT 0 1" ]]
  then
    # get new user_id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    # start a new game
    NUMBER_GUESSING_GAME $USER_ID
  fi
else
  # start a new game
  NUMBER_GUESSING_GAME
fi
