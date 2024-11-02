#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( (RANDOM % 1000) + 1 ))

MAIN() {
  echo Enter your username:
  read NAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME';")

  # if user not found

  if [[ -z $USER_ID ]]
  then
    echo "Welcome, $NAME! It looks like this is your first time here."
    INSERT_NEW_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$NAME');")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME';")
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id) VALUES($USER_ID);")
  else
    # if user is found
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID;")
    MAX_SCORE=$($PSQL "SELECT MAX(score) FROM games WHERE user_id = $USER_ID;")
    if [[ $MAX_SCORE -gt 0 ]]
    then
      BEST_GAME=$($PSQL "SELECT MIN(score) FROM games WHERE user_id = $USER_ID AND score > 0;")
    else
      BEST_GAME=0
    fi
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id) VALUES($USER_ID);")
  fi
  GAME
}

GAME() {
  echo Guess the secret number between 1 and 1000:
  GUESS_CHECK
  SCORE=1;
  # Player is guessing
  while [[ $GUESS != $RANDOM_NUMBER ]];
  do
    # if guess is higher than number
    if [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      # if guess is lower than number
      echo "It's higher than that, guess again:"
    fi
    GUESS_CHECK
    ((SCORE++))
  done
  
  # Player has won
  INSERT_WIN_RESULT=$($PSQL "UPDATE games SET score = $SCORE WHERE game_id = (SELECT MAX(game_id) FROM games WHERE user_id = $USER_ID);")
  echo "You guessed it in $SCORE tries. The secret number was $RANDOM_NUMBER. Nice job!"
}

GUESS_CHECK() {
  read GUESS
  while [[ ! $GUESS =~ ^[0-9]+$ ]];
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done
}

MAIN