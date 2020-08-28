-- loadflights.sql

DROP TABLE IF EXISTS airlines;
DROP TABLE IF EXISTS airports;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS planes;
DROP TABLE IF EXISTS weather;

CREATE TABLE airlines (
  carrier varchar(2) PRIMARY KEY,
  name varchar(30) NOT NULL
  );
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/SQLfiles/airlines.csv' 
INTO TABLE airlines 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE airports (
  faa char(3),
  name varchar(100),
  lat double precision,
  lon double precision,
  alt integer,
  tz integer,
  dst char(1)
  );
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/SQLfiles/airports.csv' 
INTO TABLE airports
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE flights (
year integer,
month integer,
day integer,
dep_time integer,
dep_delay integer,
arr_time integer,
arr_delay integer,
carrier char(2),
tailnum char(6),
flight integer,
origin char(3),
dest char(3),
air_time integer,
distance integer,
hour integer,
minute integer
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/SQLfiles/flights.csv' 
INTO TABLE flights
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(year, month, day, @dep_time, @dep_delay, @arr_time, @arr_delay,
 @carrier, @tailnum, @flight, origin, dest, @air_time, @distance, @hour, @minute)
SET
dep_time = nullif(@dep_time,''),
dep_delay = nullif(@dep_delay,''),
arr_time = nullif(@arr_time,''),
arr_delay = nullif(@arr_delay,''),
carrier = nullif(@carrier,''),
tailnum = nullif(@tailnum,''),
flight = nullif(@flight,''),
air_time = nullif(@air_time,''),
distance = nullif(@distance,''),
hour = dep_time / 100,
minute = dep_time % 100
;

CREATE TABLE planes (
tailnum char(6),
year integer,
type varchar(50),
manufacturer varchar(50),
model varchar(50),
engines integer,
seats integer,
speed integer,
engine varchar(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/SQLfiles/planes.csv' 
INTO TABLE planes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tailnum, @year, type, manufacturer, model, engines, seats, @speed, engine)
SET
year = nullif(@year,''),
speed = nullif(@speed,'')
;

CREATE TABLE weather (
origin char(3),
year integer,
month integer,
day integer,
hour integer,
temp double precision,
dewp double precision,
humid double precision,
wind_dir integer,
wind_speed double precision,
wind_gust double precision,
precip double precision,
pressure double precision,
visib double precision
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/SQLfiles/weather.csv' 
INTO TABLE weather
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(origin, @year, @month, @day, @hour, @temp, @dewp, @humid, @wind_dir,
@wind_speed, @wind_gust, @precip, @pressure, @visib)
SET
year = nullif(@year,''),
month = nullif(@month,''),
day = nullif(@day,''),
hour = nullif(@hour,''),
temp = nullif(@temp,''),
dewp = nullif(@dewp,''),
humid = nullif(@humid,''),
wind_dir = FORMAT(@wind_dir, 0),
wind_speed = nullif(@wind_speed,''),
wind_gust = nullif(@wind_gust,''),
precip = nullif(@precip,''),
pressure = nullif(@pressure,''),
visib = FORMAT(@visib,0)
;

SET SQL_SAFE_UPDATES = 0;
UPDATE planes SET engine = SUBSTRING(engine, 1, CHAR_LENGTH(engine)-1);

#Q1
SELECT 'speed', MIN(speed) as "Minimum", MAX(speed) as "Maximum", COUNT(*) as "Listed speed count" FROM planes WHERE speed > 0;

#Q2
SELECT 'distance', SUM(distance) as "Total Distance" FROM flights;

#Q.2
SELECT 'distance Jan 2013', SUM(distance) as "Total Distance" FROM flights WHERE month=1 AND year=2013;

#Q2.3
SELECT 'distance Jan 2013 tailnum empty', SUM(distance) as "Total Distance" FROM flights WHERE month=1 AND year=2013 AND tailnum="";

#Q3
SELECT manufacturer, SUM(distance) as "total distance"
FROM flights
INNER JOIN planes ON flights.tailnum = planes.tailnum AND (flights.year=2013 AND flights.month=7 AND flights.day=5)
GROUP BY manufacturer
ORDER BY manufacturer;

#Q3.2
SELECT manufacturer, SUM(distance) as "total distance"
FROM flights
LEFT JOIN planes ON flights.tailnum = planes.tailnum AND (flights.year=2013 AND flights.month=7 AND flights.day=5)
GROUP BY manufacturer
ORDER BY manufacturer;

#Left join includes a row with the total distance of ALL flights minus the distance of all subsequent distance totals that were matched from both tables.

#Q4 Show all the model numbers from all flights grouped by airline name.
SELECT name, model
FROM airlines
INNER JOIN flights ON flights.carrier = airlines.carrier
INNER JOIN planes ON flights.tailnum = planes.tailnum
GROUP BY name
;

