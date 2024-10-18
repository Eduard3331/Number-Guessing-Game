#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( 1 + $RANDOM%1000 ))


MAIN(){
#ask for username
echo -e "\nEnter your username:"
read USERNAME
REGISTERED_USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
#if not registered
if [[ -z $REGISTERED_USER ]]
then
INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
if [[ -z $INSERT_USERNAME ]]
then
echo "Error inserting user"
fi
echo "Welcome, $USERNAME! It looks like this is your first time here."
else
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id=$USER_ID")
BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
#ask for guess
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
NUMBER_OF_GUESSES=0
GUESSING_GAME $NUMBER_OF_GUESSES
}



#function will have current guess as $2 and the number of guesses as $1

GUESSING_GAME(){
#if won
if [[ $2 == $RANDOM_NUMBER ]]
  then
  echo "You guessed it in $1 tries. The secret number was $2. Nice job!"
  INSERT_GAME=$($PSQL "INSERT INTO games(user_id,guesses) VALUES ($USER_ID, $1)")
  else

#if first guess
  if [[ -z $2 ]]
  then
  echo "Guess the secret number between 1 and 1000:"
  else
  #if not integer
  if [[ ! $2 =~ ^[0-9]*$ ]]
  then
  echo "That is not an integer, guess again:"
  else
  #if guess is lower
  if [[ $2 -lt $RANDOM_NUMBER ]]
  then
  echo "It's higher than that, guess again:"
  else
  #if guess is higher
  echo "It's lower than that, guess again:"
  fi
  fi
  fi
  read GUESS
  NUMBER_OF_GUESSES=$(( 1 + $NUMBER_OF_GUESSES ))
  GUESSING_GAME $NUMBER_OF_GUESSES $GUESS
fi
}

MAIN