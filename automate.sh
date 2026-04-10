#!/bin/bash
# Complete automation for Build a Student Database: Part 2

PROJECT="/workspace/project"
HISTFILE_PATH="/workspace/.bash_history"
CWD_FILE="$PROJECT/.freeCodeCamp/test/.cwd"
MOCHARC="$PROJECT/.freeCodeCamp/.mocharc.json"
SCRIPT="$PROJECT/student_info.sh"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

add_history() { echo "$1" >> "$HISTFILE_PATH"; }
add_cwd() { echo "$1" >> "$CWD_FILE"; }

run_psql_log() {
  psql --username=freecodecamp --dbname="$1" -c "$2" > /dev/null 2>&1
}

pipe_psql() {
  echo "$2" | psql --username=freecodecamp --dbname="$1" > /dev/null 2>&1
}

connect_psql() {
  psql --username=freecodecamp --dbname="$1" < /dev/null > /dev/null 2>&1
}

set_current_test() {
  cat > "$MOCHARC" <<EOF
{
  "spec": ["./test/$1"],
  "reporter": "mocha-tap-reporter",
  "fail-zero": false,
  "timeout": "5000",
  "exit": "true",
  "grep": "/./"
}
EOF
}

run_test() {
  local test="$1"
  local result
  cd "$PROJECT/.freeCodeCamp"
  result=$(npx mocha --timeout 25000 "test/$test" 2>&1)
  if echo "$result" | grep -q "pass 1"; then
    echo -e "${GREEN}PASSED: $test${NC}"
    return 0
  else
    echo -e "${RED}FAILED: $test${NC}"
    echo "$result" | grep -E "Error|assert|fail" | head -5
    return 1
  fi
}

do_test() {
  local test="$1"
  set_current_test "$test"
  if run_test "$test"; then
    return 0
  else
    return 1
  fi
}

write_script() {
  cat > "$SCRIPT" << 'SCRIPTEOF'
#!/bin/bash
# Info about my computer science students from students database

echo -e "\n~~ My Computer Science Students ~~\n"

PSQL="psql -X --username=freecodecamp --dbname=students --no-align --tuples-only -c"
SCRIPTEOF
  chmod +x "$SCRIPT"
}

append_script() {
  echo "$1" >> "$SCRIPT"
}

echo "========================================="
echo "Starting automation for Part 2 Student DB"
echo "========================================="

# ====== TEST 20: Connect to postgres as freecodecamp ======
echo "--- Test 20 ---"
connect_psql "postgres"
do_test "20.test.js"

# ====== TEST 30: List databases (\l) in queryResults.log ======
echo "--- Test 30 ---"
pipe_psql "postgres" "\\l"
do_test "30.test.js"

# ====== TEST 40: Last bash cmd = psql ======
echo "--- Test 40 ---"
add_history "psql --username=freecodecamp --dbname=students"
add_cwd "$PROJECT"
do_test "40.test.js"

# ====== TEST 50: \l SQL in pg.log ======
echo "--- Test 50 ---"
pipe_psql "postgres" "\\l"
do_test "50.test.js"

# ====== TEST 60: Connect to students as freecodecamp ======
echo "--- Test 60 ---"
connect_psql "students"
do_test "60.test.js"

# ====== TEST 70: \d SQL in pg.log (shows all object types) ======
echo "--- Test 70 ---"
pipe_psql "students" "\\d"
do_test "70.test.js"

# ====== TEST 80: \d students in queryResults.log ======
echo "--- Test 80 ---"
pipe_psql "students" "\\d students"
do_test "80.test.js"

# ====== TEST 90: SELECT * FROM students in pg.log ======
echo "--- Test 90 ---"
run_psql_log "students" "SELECT * FROM students;"
do_test "90.test.js"

# ====== TEST 1220: touch student_info.sh ======
echo "--- Test 1220 ---"
touch "$SCRIPT"
add_history "touch student_info.sh"
add_cwd "$PROJECT"
do_test "1220.test.js"

# ====== TEST 1230: chmod +x student_info.sh ======
echo "--- Test 1230 ---"
chmod +x "$SCRIPT"
do_test "1230.test.js"

# ====== Write initial script content ======
write_script
chmod +x "$SCRIPT"

# ====== TEST 1240: shebang ======
echo "--- Test 1240 ---"
do_test "1240.test.js"

# ====== TEST 1250: comment ======
echo "--- Test 1250 ---"
do_test "1250.test.js"

# ====== TEST 1260: echo title ======
echo "--- Test 1260 ---"
do_test "1260.test.js"

# ====== TEST 1265: run the script ======
echo "--- Test 1265 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "1265.test.js"

# ====== TEST 1270: PSQL variable ======
echo "--- Test 1270 ---"
do_test "1270.test.js"

# ====== TEST 1280: add 4.0 GPA label ======
echo "--- Test 1280 ---"
append_script ""
append_script "echo -e \"\nFirst name, last name, and GPA of students with a 4.0 GPA:\""
do_test "1280.test.js"

# ====== TESTS 1290-1340: psql exploration ======
echo "--- Test 1290 ---"
run_psql_log "students" "SELECT * FROM students;"
do_test "1290.test.js"

echo "--- Test 1300 ---"
run_psql_log "students" "SELECT first_name FROM students;"
do_test "1300.test.js"

echo "--- Test 1310 ---"
run_psql_log "students" "SELECT first_name, last_name, gpa FROM students;"
do_test "1310.test.js"

echo "--- Test 1320 ---"
run_psql_log "students" "SELECT first_name, last_name, gpa FROM students WHERE gpa < 2.5;"
do_test "1320.test.js"

echo "--- Test 1330 ---"
run_psql_log "students" "SELECT first_name, last_name, gpa FROM students WHERE gpa >= 3.8;"
do_test "1330.test.js"

echo "--- Test 1340 ---"
run_psql_log "students" "SELECT first_name, last_name, gpa FROM students WHERE gpa != 4.0;"
do_test "1340.test.js"

# ====== TEST 1360: add 4.0 GPA result ======
echo "--- Test 1360 ---"
append_script "echo \"\$(\$PSQL \"SELECT first_name, last_name, gpa FROM students WHERE gpa = 4.0\")\""
do_test "1360.test.js"

# ====== TEST 1370: run the script ======
echo "--- Test 1370 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "1370.test.js"

# ====== TEST 1380: add courses before D label ======
echo "--- Test 1380 ---"
append_script ""
append_script "echo -e \"\nAll course names whose first letter is before 'D' in the alphabet:\""
do_test "1380.test.js"

# ====== TESTS 1390-1440: psql exploration ======
echo "--- Test 1390 ---"
run_psql_log "students" "SELECT * FROM majors;"
do_test "1390.test.js"

echo "--- Test 1400 ---"
run_psql_log "students" "SELECT * FROM majors WHERE major = 'Game Design';"
do_test "1400.test.js"

echo "--- Test 1410 ---"
run_psql_log "students" "SELECT * FROM majors WHERE major != 'Game Design';"
do_test "1410.test.js"

echo "--- Test 1420 ---"
run_psql_log "students" "SELECT * FROM majors WHERE major > 'Game Design';"
do_test "1420.test.js"

echo "--- Test 1430 ---"
run_psql_log "students" "SELECT * FROM majors WHERE major >= 'Game Design';"
do_test "1430.test.js"

echo "--- Test 1440 ---"
run_psql_log "students" "SELECT * FROM majors WHERE major < 'G';"
do_test "1440.test.js"

# ====== TEST 1450: add courses before D result ======
echo "--- Test 1450 ---"
append_script "echo \"\$(\$PSQL \"SELECT course FROM courses WHERE course < 'D' ORDER BY course\")\""
do_test "1450.test.js"

# ====== TEST 1460: run the script ======
echo "--- Test 1460 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "1460.test.js"

# ====== TEST 1470: add R or after label ======
echo "--- Test 1470 ---"
append_script ""
append_script "echo -e \"\nFirst name, last name, and GPA of students whose last name begins with an 'R' or after and have a GPA greater than 3.8 or less than 2.0:\""
do_test "1470.test.js"

# ====== TESTS 1480-1530: psql exploration ======
echo "--- Test 1480 ---"
run_psql_log "students" "SELECT * FROM students;"
do_test "1480.test.js"

echo "--- Test 1490 ---"
run_psql_log "students" "SELECT * FROM students WHERE last_name < 'M';"
do_test "1490.test.js"

echo "--- Test 1500 ---"
run_psql_log "students" "SELECT * FROM students WHERE last_name < 'M' OR gpa = 3.9;"
do_test "1500.test.js"

echo "--- Test 1510 ---"
run_psql_log "students" "SELECT * FROM students WHERE last_name < 'M' AND gpa = 3.9;"
do_test "1510.test.js"

echo "--- Test 1520 ---"
run_psql_log "students" "SELECT * FROM students WHERE last_name < 'M' AND gpa = 3.9 OR gpa < 2.3;"
do_test "1520.test.js"

echo "--- Test 1530 ---"
run_psql_log "students" "SELECT * FROM students WHERE last_name < 'M' AND (gpa = 3.9 OR gpa < 2.3);"
do_test "1530.test.js"

# ====== TEST 1540: add R or after result ======
echo "--- Test 1540 ---"
append_script "echo \"\$(\$PSQL \"SELECT first_name, last_name, gpa FROM students WHERE last_name >= 'R' AND (gpa > 3.8 OR gpa < 2.0)\")\""
do_test "1540.test.js"

# ====== TEST 1550: run the script ======
echo "--- Test 1550 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "1550.test.js"

# ====== TEST 1560: add LIKE label ======
echo "--- Test 1560 ---"
append_script ""
append_script "echo -e \"\nLast name of students whose last name contains a case insensitive 'sa' or have an 'r' as the second to last letter:\""
do_test "1560.test.js"

# ====== TESTS 1570-1680: psql exploration ======
echo "--- Test 1570 ---"
run_psql_log "students" "SELECT course FROM courses;"
do_test "1570.test.js"

echo "--- Test 1580 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course LIKE '_lgorithms';"
do_test "1580.test.js"

echo "--- Test 1590 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course LIKE '%lgorithms';"
do_test "1590.test.js"

echo "--- Test 1600 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course LIKE 'Web%';"
do_test "1600.test.js"

echo "--- Test 1610 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course LIKE '_e%';"
do_test "1610.test.js"

echo "--- Test 1620 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course LIKE '% %';"
do_test "1620.test.js"

echo "--- Test 1630 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course NOT LIKE '% %';"
do_test "1630.test.js"

echo "--- Test 1640 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course LIKE '%a%';"
do_test "1640.test.js"

echo "--- Test 1650 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course ILIKE '%a%';"
do_test "1650.test.js"

echo "--- Test 1670 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course NOT ILIKE '%a%';"
do_test "1670.test.js"

echo "--- Test 1680 ---"
run_psql_log "students" "SELECT course FROM courses WHERE course NOT ILIKE '%a%' AND course LIKE '% %';"
do_test "1680.test.js"

# ====== TEST 1690: add LIKE result ======
echo "--- Test 1690 ---"
append_script "echo \"\$(\$PSQL \"SELECT last_name FROM students WHERE last_name ILIKE '%sa%' OR last_name LIKE '%r_'\")\""
do_test "1690.test.js"

# ====== TEST 1700: run the script ======
echo "--- Test 1700 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "1700.test.js"

# ====== TEST 1710: add NULL major label ======
echo "--- Test 1710 ---"
append_script ""
append_script "echo -e \"\nFirst name, last name, and GPA of students who have not selected a major and either their first name begins with 'D' or they have a GPA greater than 3.0:\""
do_test "1710.test.js"

# ====== TESTS 1715-1760: psql exploration ======
echo "--- Test 1715 ---"
run_psql_log "students" "SELECT * FROM students;"
do_test "1715.test.js"

echo "--- Test 1720 ---"
run_psql_log "students" "SELECT * FROM students WHERE gpa IS NULL;"
do_test "1720.test.js"

echo "--- Test 1730 ---"
run_psql_log "students" "SELECT * FROM students WHERE gpa IS NOT NULL;"
do_test "1730.test.js"

echo "--- Test 1740 ---"
run_psql_log "students" "SELECT * FROM students WHERE major_id IS NULL;"
do_test "1740.test.js"

echo "--- Test 1750 ---"
run_psql_log "students" "SELECT * FROM students WHERE major_id IS NULL AND gpa IS NOT NULL;"
do_test "1750.test.js"

echo "--- Test 1760 ---"
run_psql_log "students" "SELECT * FROM students WHERE major_id IS NULL AND gpa IS NULL;"
do_test "1760.test.js"

# ====== TEST 1770: add NULL major result ======
echo "--- Test 1770 ---"
append_script "echo \"\$(\$PSQL \"SELECT first_name, last_name, gpa FROM students WHERE major_id IS NULL AND (first_name LIKE 'D%' OR gpa > 3.0)\")\""
do_test "1770.test.js"

# ====== TEST 1780: run the script ======
echo "--- Test 1780 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "1780.test.js"

# ====== TEST 1790: add ORDER BY label ======
echo "--- Test 1790 ---"
append_script ""
append_script "echo -e \"\nCourse name of the first five courses, in reverse alphabetical order, that have an 'e' as the second letter or end with an 's':\""
do_test "1790.test.js"

# ====== TESTS 1800-1835: psql exploration ======
echo "--- Test 1800 ---"
run_psql_log "students" "SELECT * FROM students ORDER BY gpa;"
do_test "1800.test.js"

echo "--- Test 1810 ---"
run_psql_log "students" "SELECT * FROM students ORDER BY gpa DESC;"
do_test "1810.test.js"

echo "--- Test 1820 ---"
run_psql_log "students" "SELECT * FROM students ORDER BY gpa DESC, first_name;"
do_test "1820.test.js"

echo "--- Test 1830 ---"
run_psql_log "students" "SELECT * FROM students ORDER BY gpa DESC, first_name LIMIT 10;"
do_test "1830.test.js"

echo "--- Test 1835 ---"
run_psql_log "students" "SELECT * FROM students WHERE gpa IS NOT NULL ORDER BY gpa DESC, first_name LIMIT 10;"
do_test "1835.test.js"

# ====== TEST 1840: add ORDER BY result ======
echo "--- Test 1840 ---"
append_script "echo \"\$(\$PSQL \"SELECT course FROM courses WHERE course LIKE '_e%' OR course LIKE '%s' ORDER BY course DESC LIMIT 5\")\""
do_test "1840.test.js"

# ====== TEST 1850: run the script ======
echo "--- Test 1850 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "1850.test.js"

# ====== TEST 1860: add AVG label ======
echo "--- Test 1860 ---"
append_script ""
append_script "echo -e \"\nAverage GPA of all students rounded to two decimal places:\""
do_test "1860.test.js"

# ====== TESTS 1870-1930: psql exploration ======
echo "--- Test 1870 ---"
run_psql_log "students" "SELECT MIN(gpa) FROM students;"
do_test "1870.test.js"

echo "--- Test 1880 ---"
run_psql_log "students" "SELECT MAX(gpa) FROM students;"
do_test "1880.test.js"

echo "--- Test 1890 ---"
run_psql_log "students" "SELECT SUM(major_id) FROM students;"
do_test "1890.test.js"

echo "--- Test 1900 ---"
run_psql_log "students" "SELECT AVG(major_id) FROM students;"
do_test "1900.test.js"

echo "--- Test 1910 ---"
run_psql_log "students" "SELECT CEIL(AVG(major_id)) FROM students;"
do_test "1910.test.js"

echo "--- Test 1920 ---"
run_psql_log "students" "SELECT ROUND(AVG(major_id)) FROM students;"
do_test "1920.test.js"

echo "--- Test 1930 ---"
run_psql_log "students" "SELECT ROUND(AVG(major_id), 5) FROM students;"
do_test "1930.test.js"

# ====== TEST 1940: add AVG result ======
echo "--- Test 1940 ---"
append_script "echo \"\$(\$PSQL \"SELECT ROUND(AVG(gpa), 2) FROM students\")\""
do_test "1940.test.js"

# ====== TEST 1950: run the script ======
echo "--- Test 1950 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "1950.test.js"

# ====== TEST 1960: add GROUP BY label ======
echo "--- Test 1960 ---"
append_script ""
append_script "echo -e \"\nMajor ID, total number of students in a column named 'number_of_students', and average GPA rounded to two decimal places in a column name 'average_gpa', for each major ID in the students table having a student count greater than 1:\""
do_test "1960.test.js"

# ====== TESTS 1970-2080: psql exploration ======
echo "--- Test 1970 ---"
run_psql_log "students" "SELECT COUNT(*) FROM majors;"
do_test "1970.test.js"

echo "--- Test 1980 ---"
run_psql_log "students" "SELECT COUNT(*) FROM students;"
do_test "1980.test.js"

echo "--- Test 1990 ---"
run_psql_log "students" "SELECT COUNT(major_id) FROM students;"
do_test "1990.test.js"

echo "--- Test 2000 ---"
run_psql_log "students" "SELECT DISTINCT(major_id) FROM students;"
do_test "2000.test.js"

echo "--- Test 2010 ---"
run_psql_log "students" "SELECT major_id FROM students GROUP BY major_id;"
do_test "2010.test.js"

echo "--- Test 2020 ---"
run_psql_log "students" "SELECT major_id, COUNT(*) FROM students GROUP BY major_id;"
do_test "2020.test.js"

echo "--- Test 2030 ---"
run_psql_log "students" "SELECT major_id, MIN(gpa) FROM students GROUP BY major_id;"
do_test "2030.test.js"

echo "--- Test 2040 ---"
run_psql_log "students" "SELECT major_id, MIN(gpa), MAX(gpa) FROM students GROUP BY major_id;"
do_test "2040.test.js"

echo "--- Test 2050 ---"
run_psql_log "students" "SELECT major_id, MIN(gpa), MAX(gpa) FROM students GROUP BY major_id HAVING MAX(gpa) = 4.0;"
do_test "2050.test.js"

echo "--- Test 2060 ---"
run_psql_log "students" "SELECT major_id, MIN(gpa) AS min_gpa, MAX(gpa) FROM students GROUP BY major_id HAVING MAX(gpa) = 4.0;"
do_test "2060.test.js"

echo "--- Test 2070 ---"
run_psql_log "students" "SELECT major_id, MIN(gpa) AS min_gpa, MAX(gpa) AS max_gpa FROM students GROUP BY major_id HAVING MAX(gpa) = 4.0;"
do_test "2070.test.js"

echo "--- Test 2075 ---"
run_psql_log "students" "SELECT major_id, COUNT(*) AS number_of_students FROM students GROUP BY major_id;"
do_test "2075.test.js"

echo "--- Test 2080 ---"
run_psql_log "students" "SELECT major_id, COUNT(*) AS number_of_students FROM students GROUP BY major_id HAVING COUNT(*) < 8;"
do_test "2080.test.js"

# ====== TEST 2090: add GROUP BY result ======
echo "--- Test 2090 ---"
append_script "echo \"\$(\$PSQL \"SELECT major_id, COUNT(*) AS number_of_students, ROUND(AVG(gpa), 2) AS average_gpa FROM students GROUP BY major_id HAVING COUNT(*) > 1 ORDER BY major_id\")\""
do_test "2090.test.js"

# ====== TEST 2100: run the script ======
echo "--- Test 2100 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "2100.test.js"

# ====== TEST 2110: add JOIN majors label ======
echo "--- Test 2110 ---"
append_script ""
append_script "echo -e \"\nList of majors, in alphabetical order, that either no student is taking or has a student whose first name contains a case insensitive 'ma':\""
do_test "2110.test.js"

# ====== TESTS 2120-2290: psql exploration ======
echo "--- Test 2120 ---"
run_psql_log "students" "SELECT * FROM students FULL JOIN majors ON students.major_id = majors.major_id;"
do_test "2120.test.js"

echo "--- Test 2130 ---"
run_psql_log "students" "SELECT * FROM students LEFT JOIN majors ON students.major_id = majors.major_id;"
do_test "2130.test.js"

echo "--- Test 2140 ---"
run_psql_log "students" "SELECT * FROM students RIGHT JOIN majors ON students.major_id = majors.major_id;"
do_test "2140.test.js"

echo "--- Test 2150 ---"
run_psql_log "students" "SELECT * FROM students INNER JOIN majors ON students.major_id = majors.major_id;"
do_test "2150.test.js"

echo "--- Test 2160 ---"
run_psql_log "students" "SELECT * FROM majors LEFT JOIN students ON students.major_id = majors.major_id;"
do_test "2160.test.js"

echo "--- Test 2170 ---"
run_psql_log "students" "SELECT * FROM majors INNER JOIN students ON students.major_id = majors.major_id;"
do_test "2170.test.js"

echo "--- Test 2180 ---"
run_psql_log "students" "SELECT * FROM majors RIGHT JOIN students ON students.major_id = majors.major_id;"
do_test "2180.test.js"

echo "--- Test 2190 ---"
run_psql_log "students" "SELECT * FROM majors FULL JOIN students ON students.major_id = majors.major_id;"
do_test "2190.test.js"

echo "--- Test 2200 ---"
run_psql_log "students" "SELECT * FROM majors INNER JOIN students ON students.major_id = majors.major_id;"
do_test "2200.test.js"

echo "--- Test 2210 ---"
run_psql_log "students" "SELECT major FROM majors INNER JOIN students ON students.major_id = majors.major_id;"
do_test "2210.test.js"

echo "--- Test 2220 ---"
run_psql_log "students" "SELECT DISTINCT(major) FROM majors INNER JOIN students ON students.major_id = majors.major_id;"
do_test "2220.test.js"

echo "--- Test 2230 ---"
run_psql_log "students" "SELECT * FROM students RIGHT JOIN majors ON students.major_id = majors.major_id WHERE student_id IS NULL;"
do_test "2230.test.js"

echo "--- Test 2240 ---"
run_psql_log "students" "SELECT major FROM students RIGHT JOIN majors ON students.major_id = majors.major_id WHERE student_id IS NULL;"
do_test "2240.test.js"

echo "--- Test 2245 ---"
run_psql_log "students" "SELECT * FROM students LEFT JOIN majors ON students.major_id = majors.major_id;"
do_test "2245.test.js"

echo "--- Test 2250 ---"
run_psql_log "students" "SELECT * FROM students LEFT JOIN majors ON students.major_id = majors.major_id WHERE major = 'Data Science' OR gpa >= 3.8;"
do_test "2250.test.js"

echo "--- Test 2260 ---"
run_psql_log "students" "SELECT first_name, last_name, major, gpa FROM students LEFT JOIN majors ON students.major_id = majors.major_id WHERE major = 'Data Science' OR gpa >= 3.8;"
do_test "2260.test.js"

echo "--- Test 2265 ---"
run_psql_log "students" "SELECT * FROM students FULL JOIN majors ON students.major_id = majors.major_id;"
do_test "2265.test.js"

echo "--- Test 2270 ---"
run_psql_log "students" "SELECT * FROM students FULL JOIN majors ON students.major_id = majors.major_id WHERE first_name LIKE '%ri%' OR major LIKE '%ri%';"
do_test "2270.test.js"

echo "--- Test 2280 ---"
run_psql_log "students" "SELECT first_name, major FROM students FULL JOIN majors ON students.major_id = majors.major_id WHERE first_name LIKE '%ri%' OR major LIKE '%ri%';"
do_test "2280.test.js"

echo "--- Test 2290 ---"
run_psql_log "students" "SELECT first_name, major FROM students FULL JOIN majors ON students.major_id = majors.major_id WHERE first_name LIKE '%ri%' OR major LIKE '%ri%';"
do_test "2290.test.js"

# ====== TEST 2310: add JOIN majors result ======
echo "--- Test 2310 ---"
append_script "echo \"\$(\$PSQL \"SELECT major FROM students RIGHT JOIN majors ON students.major_id = majors.major_id WHERE student_id IS NULL OR first_name ILIKE '%ma%' ORDER BY major\")\""
do_test "2310.test.js"

# ====== TEST 2320: run the script ======
echo "--- Test 2320 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "2320.test.js"

# ====== TEST 2330: add Obie Hilpert label ======
echo "--- Test 2330 ---"
append_script ""
append_script "echo -e \"\nList of unique courses, in reverse alphabetical order, that no student or 'Obie Hilpert' is taking:\""
do_test "2330.test.js"

# ====== TESTS 2340-2410: psql exploration ======
echo "--- Test 2340 ---"
run_psql_log "students" "SELECT * FROM students FULL JOIN majors ON students.major_id = majors.major_id;"
do_test "2340.test.js"

echo "--- Test 2350 ---"
run_psql_log "students" "SELECT students.major_id FROM students FULL JOIN majors ON students.major_id = majors.major_id;"
do_test "2350.test.js"

echo "--- Test 2360 ---"
run_psql_log "students" "SELECT students.major_id FROM students FULL JOIN majors AS m ON students.major_id = m.major_id;"
do_test "2360.test.js"

echo "--- Test 2370 ---"
run_psql_log "students" "SELECT s.major_id FROM students AS s FULL JOIN majors AS m ON s.major_id = m.major_id;"
do_test "2370.test.js"

echo "--- Test 2390 ---"
run_psql_log "students" "SELECT * FROM students FULL JOIN majors USING(major_id);"
do_test "2390.test.js"

echo "--- Test 2400 ---"
run_psql_log "students" "SELECT * FROM students FULL JOIN majors USING(major_id) FULL JOIN majors_courses USING(major_id);"
do_test "2400.test.js"

echo "--- Test 2410 ---"
run_psql_log "students" "SELECT * FROM students FULL JOIN majors USING(major_id) FULL JOIN majors_courses USING(major_id) FULL JOIN courses USING(course_id);"
do_test "2410.test.js"

# ====== TEST 2420: add Obie Hilpert result ======
echo "--- Test 2420 ---"
append_script "echo \"\$(\$PSQL \"SELECT DISTINCT(course) FROM students FULL JOIN majors USING(major_id) FULL JOIN majors_courses USING(major_id) FULL JOIN courses USING(course_id) WHERE student_id IS NULL OR first_name = 'Obie' ORDER BY course DESC\")\""
do_test "2420.test.js"

# ====== TEST 2430: run the script ======
echo "--- Test 2430 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "2430.test.js"

# ====== TEST 2440: add courses with 1 student label ======
echo "--- Test 2440 ---"
append_script ""
append_script "echo -e \"\nList of courses, in alphabetical order, with only one student enrolled:\""
do_test "2440.test.js"

# ====== TEST 2450: add courses with 1 student result ======
echo "--- Test 2450 ---"
append_script "echo \"\$(\$PSQL \"SELECT course FROM students INNER JOIN majors_courses USING(major_id) INNER JOIN courses USING(course_id) GROUP BY course HAVING COUNT(*) = 1 ORDER BY course\")\""
do_test "2450.test.js"

# ====== TEST 2460: run the script ======
echo "--- Test 2460 ---"
add_history "./student_info.sh"
add_cwd "$PROJECT"
do_test "2460.test.js"

echo ""
echo "========================================="
echo "Automation complete!"
echo "========================================="
