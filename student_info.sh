#!/bin/bash

# Info about my computer science students from students database

echo -e "\n~~ My Computer Science Students ~~\n"

PSQL="psql -X --username=freecodecamp --dbname=students --no-align --tuples-only -c"

echo -e "\nAll course names whose first letter is before 'D' in the alphabet:"
echo "$($PSQL "SELECT course FROM students INNER JOIN majors_courses USING(major_id) INNER JOIN courses USING(course_id) GROUP BY course HAVING COUNT(*) = 1 ORDER BY course")"
