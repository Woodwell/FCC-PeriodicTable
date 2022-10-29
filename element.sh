#!/bin/bash

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
else
  ELEMENT=$1
fi

# join for all the data
BIGTABLE="((elements join properties on (elements.atomic_number=properties.atomic_number)) join types on (properties.type_id=types.type_id))"
COLUMNS="name,elements.atomic_number,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius"

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# is the element an integer?
if [[ $1 =~ ^[0-9]+$ ]]
then
# if so, query by atomic number
  RESULT=$($PSQL "select $COLUMNS from $BIGTABLE where elements.atomic_number='$ELEMENT'")
else
#otherwise, query by either symbol or name - only one will match
  RESULT=$($PSQL "select $COLUMNS from $BIGTABLE where (name='$ELEMENT' OR symbol='$ELEMENT')")
fi

if [[ ! -z $RESULT ]]
then
  IFS='|' read NAME ATOMICNUMBER SYM TYPE MASS MPOINT BPOINT <<-EOF
$RESULT
EOF
else
  echo "I could not find that element in the database."
  exit 0
fi

echo "The element with atomic number $ATOMICNUMBER is $NAME ($SYM). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MPOINT celsius and a boiling point of $BPOINT celsius."


