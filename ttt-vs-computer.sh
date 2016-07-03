#!/bin/bash

# Game of tic-tac-toe

cell_w=10
# horizontal line
line_seg="---------"
line="  ""$line_seg""|""$line_seg""|""$line_seg"

pink="\033[35m"
cyan="\033[36m"
blue="\033[34m"
green="\033[32m"
reset="\033[0m"

player_1_str=$green"Human"$reset
player_2_str=$blue"Computer"$reset

positions=(- - - - - - - - -)  # initial positions

player_one=true  # player switch init
game_finished=false  # is the game finished
stall=false  # stall - if an invalid or empty move was input

# functions that draws instructions and board based on positions arr
function draw_board {
  clear

  name=$1[@]  # passing an array as argument
  positions=("${!name}")

  # first lines - instructions
  echo -e "\n       Q W E       _|_|_\n        A S D   →   | | \n         Z X C     ‾|‾|‾\n\n"

  for (( row_id=1; row_id<=3; row_id++ ));do
    # row
    row="  "
    empty_row="  "
    for (( col_id=1; col_id<$(($cell_w*3)); col_id++ ));do
      # column

      # every 10th is a separator
      if [[ $(( $col_id%$cell_w )) == 0 ]]; then
        row=$row"|"
        empty_row=$empty_row"|"
      else
        if [[ $(( $col_id%5 )) == 0 ]]; then  # get the center of the tile

          x=$(($row_id-1))
          y=$((($col_id - 5) / 10))

          if [[ $x == 0 ]]; then
            what=${positions[$y]}
          elif [[ $x == 1 ]]; then
            what=${positions[(($y+3))]}
          else
            what=${positions[(($y+6))]}
          fi

          # if it's "-", it's empty
          if [[ $what == "-" ]]; then what=" "; fi

          if [[ $what == "X" ]] ; then  # append to row
            row=$row$green$what$reset
          else
            row=$row$blue$what$reset
          fi

          empty_row=$empty_row" "  # advance empty row
        else  # not the center - space
          row=$row" "
          empty_row=$empty_row" "
        fi
      fi
    done
    echo -e "$empty_row""\n""$row""\n""$empty_row"  # row is three lines high
    if [[ $row_id != 3 ]]; then
      echo -e "$line"
    fi
  done
  echo -e "\n"
}

# function that displays the prompt based on turn, reads the input and advances the game
function read_move {

  positions_str=$(printf "%s" "${positions[@]}")

  test_position_str $positions_str  # finish the game if all postiions have been taken or a player has won

  if [ "$game_finished" = false ] ; then

    if [ "$stall" = false ] ; then
      if [ "$player_one" = true ] ; then
        prompt="Your move, "$player_1_str"?"
      fi
    else
      stall=false
    fi

    if [ "$player_one" = true ] ; then
      echo -e $prompt
      read -d'' -s -n1 input  # read input

      index=10  # init with nonexistent
      case $input in
            q) index=0;;
            a) index=3;;
            z) index=6;;
            w) index=1;;
            s) index=4;;
            x) index=7;;
            e) index=2;;
            d) index=5;;
            c) index=8;;
      esac

      if [ "${positions["$index"]}" == "-" ]; then
        positions["$index"]="X"
        player_one=false
      else
        stall=true  # prevent player switch
      fi

    else
      # computer, choose your position!
      set_next_avail_pos_index "O"
      player_one=true
    fi

    init_game  # reinit, because positions persist
  fi
}

function init_game {
  draw_board positions
  read_move
}

function end_game {
  game_finished=true
  draw_board positions
}

function test_position_str {
  rows=${1:0:3}" "${1:3:3}" "${1:6:8}
  cols=${1:0:1}${1:3:1}${1:6:1}" "${1:1:1}${1:4:1}${1:7:1}" "${1:2:1}${1:5:1}${1:8:1}
  diagonals=${1:0:1}${1:4:1}${1:8:1}" "${1:2:1}${1:4:1}${1:6:1}
  if [[ $rows =~ [X]{3,} || $cols =~ [X]{3,} || $diagonals =~ [X]{3,} ]]; then
    end_game
    echo -e $player_1_str" wins! \n"
    return
  fi
  if [[ $rows =~ [O]{3,} || $cols =~ [O]{3,} || $diagonals =~ [O]{3,} ]]; then
    end_game
    echo -e $player_2_str" wins! \n"
    return
  fi
  if [[ ! $positions_str =~ [-] ]]; then
    end_game
    echo -e "End with a "$pink"draw"$reset"\n"
  fi
}

# get next available position and set it to value of argument
function set_next_avail_pos_index {
  available=()
  for (( i = 0; i < ${#positions[@]}; i++ )); do
    if [[ ${positions[$i]} == '-' ]]; then
      available+=($i)
    fi
  done

  rand=$(jot -r 1 0 $(( ${#available[@]}-1 )))  # random in range 0 to available_len
  positions[${available[$rand]}]=$1
}

init_game
