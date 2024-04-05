# CSCI403 - Database Management Final Project

## Dataset

The dataset used for this project is a private dataset that contains log entry information from an event in 2021. This is from a project which I work on for a non-profit STEM initiative. Fully explaining the entire breath and meaning of what the dataset is used for is difficult without a good amount of background info. The dataset is in CSV format and contains the main tables are as follows:

NOTE: The two primary tables are `score_rawclickeydata.csv` and `score_diary.csv`. The other tables are used to provide context to the data. I only provided two of the 10 less important tables.

### score_rawclickeydata.csv (18,327 lines)

| id   | day | team_id | time_stamp                    | judge           |
|------|-----|---------|-------------------------------|-----------------|
| 1636 | 1   | 1       | 2021-07-19 10:33:23.707104+00 | Jarrett's Laptop|
| 1637 | 1   | 2       | 2021-07-19 10:33:25+00        | nfikwm-Eric     |

- id: unique identifier for the record
- day: the day of the event (1-4)
- team_id: the team identifier
- time_stamp: the timestamp of the log entry stored in UTC
- judge: the judge identifier

### score_diary.csv (~1,000 lines)

| id   | team_id | time_stamp                    | judge   | day | event    | num_passengers |
|------|---------|-------------------------------|---------|-----|----------|----------------|
| 3513 | 1       | 2021-07-19 10:30:01.256693+00 | LUCAS   | 1   | Enter    | 0              |
| 3514 | 1       | 2021-07-19 10:30:06.349055+00 | Michael | Diary| Enter    | 0              |

- id: unique identifier for the record
- team_id: the team identifier
- time_stamp: the timestamp of the log entry stored in UTC
- judge: the judge identifier
- day: the day of the event (1-4)
- event: the event identifier
- num_passengers: the number of passengers in the vehicle

### score_team.csv (45 records)

| id  | team_name                | team_website                                                               | division |
|-----|--------------------------|----------------------------------------------------------------------------|----------|
| 28  | Winston Solar            | [https://www.solarcarchallenge.org/challenge/teams2024/winston.shtml](https://www.solarcarchallenge.org/challenge/teams2024/winston.shtml)           | 2        |
| 22  | Iron Lions Solar Car Team | [https://www.solarcarchallenge.org/challenge/teams2024/ironlions_adv.shtml](https://www.solarcarchallenge.org/challenge/teams2024/ironlions_adv.shtml) | 2        |

- id: unique identifier for the record
- team_name: the name of the team
- team_website: the website of the team
- division: the division of the team

### score_division.csv (5 records)

| id | racing_periods | duration | order | name               | visible |
|----|----------------|----------|-------|--------------------|---------|
| 1  | 2              | 3        | 1     | Classic            | TRUE    |
| 2  | 2              | 3        | 2     | Advanced Classic   | TRUE    |

- id: unique identifier for the record
- racing_periods: the number of racing periods
- duration: the total hours of the event
- order: the order of the division
- name: the name of the division
- visible: whether the division is visible

## Schema

The data was imported into a PostgreSQL database using DataGrip bulk import. Being this data is an archived dataset from an active project, a dev server hosted on Heroku is used to run this data in parallel with current development/testing. While the table schema already exist in the dev environment, the following SQL queries could be used to replicate the schema on any server:

```sql
create table if not exists score_currentday ();
create table if not exists score_division (
    id integer,
    racing_periods integer,
    duration integer,
    "order" integer,
    name varchar,
    visible boolean
);
create table if not exists score_live_stats ();
create table if not exists score_resultsaudited (
    id integer,
    team_id integer,
    day_one integer,
    day_two integer,
    day_three integer,
    day_four integer,
    penalty_one integer,
    penalty_two integer,
    penalty_three integer,
    penalty_four integer,
    video integer
);
create table if not exists score_team (
    id integer,
    team_name varchar,
    team_website varchar,
    division integer
);
create table if not exists score_rawclickeydata (
    id bigserial primary key,
    day integer,
    team_id smallint,
    time_stamp timestamp,
    judge varchar,
    "Used" boolean default false
);
create table if not exists score_diary (
    id bigserial primary key,
    team_id integer,
    time_stamp timestamp,
    judge varchar,
    day integer,
    event varchar,
    num_passengers integer
);
create table if not exists score_penalty (
    team_id integer,
    day integer,
    laps integer
);
create table if not exists score_forever_laps (team_id integer, laps integer);
create table if not exists race_days (
    day_id integer,
    start_time timestamp,
    end_time timestamp,
    description varchar
);
```

## Analysis

While there is many things that can be analyzed from this dataset, I will focus on the following questions:

1. What is the total number of laps completed by each team on each day?

```sql
SELECT rank() OVER (PARTITION BY score_team.division ORDER BY parsed_day_score.day_lap_credit DESC) AS rank,
       score_team.division,
       parsed_day_score.team_id,
       parsed_day_score.day_lap_credit,
       parsed_day_score.average_lap_time,
       parsed_day_score.best_lap_time,
       total_laps.total_laps,
       score_team.team_name,
       score_team.team_website
FROM (SELECT live_rawscore.team_id,
             sum(live_rawscore.lap_credit)            AS day_lap_credit,
             to_char(avg(
                             CASE
                                 WHEN live_rawscore.lap_time > '00:00:00'::interval THEN live_rawscore.lap_time
                                 WHEN live_rawscore.lap_time = '00:00:00'::interval THEN '00:00:00'::interval
                                 ELSE NULL::interval
                                 END), 'MI:SS'::text) AS average_lap_time,
             to_char(
                     CASE
                         WHEN min(
                                 CASE
                                     WHEN live_rawscore.lap_time > '00:00:00'::interval THEN live_rawscore.lap_time
                                     ELSE NULL::interval
                                     END) IS NULL THEN '00:00:00'::interval
                         ELSE min(
                                 CASE
                                     WHEN live_rawscore.lap_time > '00:00:00'::interval THEN live_rawscore.lap_time
                                     ELSE NULL::interval
                                     END)
                         END, 'MI:SS'::text)          AS best_lap_time
      FROM live_rawscore
      WHERE live_rawscore.day = ((SELECT race_days.day_id
                                  FROM race_days
                                  WHERE now() >= race_days.start_time
                                    AND now() <= race_days.end_time))
      GROUP BY live_rawscore.team_id) parsed_day_score
         JOIN score_team ON score_team.id = parsed_day_score.team_id
         JOIN (SELECT total_laps_1.team_id,
                      total_laps_1.total_lap_credit + score_forever_laps.laps - score_penalty.laps AS total_laps
               FROM (SELECT live_rawscore.team_id,
                            sum(live_rawscore.lap_credit) AS total_lap_credit
                     FROM live_rawscore
                     WHERE live_rawscore.day <= ((SELECT race_days.day_id
                                                  FROM race_days
                                                  WHERE now() >= race_days.start_time
                                                    AND now() <= race_days.end_time))
                     GROUP BY live_rawscore.team_id) total_laps_1
                        JOIN score_penalty ON score_penalty.team_id = total_laps_1.team_id
                        JOIN score_forever_laps ON score_forever_laps.team_id = total_laps_1.team_id
               WHERE score_penalty.day <= ((SELECT race_days.day_id
                                            FROM race_days
                                            WHERE now() >= race_days.start_time
                                              AND now() <= race_days.end_time))) total_laps
              ON total_laps.team_id = score_team.id
ORDER BY score_team.division,
         (rank() OVER (PARTITION BY score_team.division ORDER BY parsed_day_score.day_lap_credit DESC));
```

The following table shows the output:

| rank | division | team_id | day_lap_credit | average_lap_time | best_lap_time | total_laps | team_name               | team_website                                                                |
|------|----------|---------|----------------|------------------|---------------|------------|-------------------------|-----------------------------------------------------------------------------|
| 1    | 0        | 1       | 5              | 1:32             | 1:31          | 25         | Coppell Solar Car       | [https://www.solarcarchallenge.org/challenge/teams2024/coppell.shtml](https://www.solarcarchallenge.org/challenge/teams2024/coppell.shtml)                     |
| 2    | 0        | 9       | 4              | 1:18             | 1:33          | 24         | South River Solar Hawks | [https://www.solarcarchallenge.org/challenge/teams2024/solar_hawks.shtml](https://www.solarcarchallenge.org/challenge/teams2024/solar_hawks.shtml)       |
| 2    | 0        | 5       | 4              | 0:48             | 1:30          | 20        | Falcon EV               | [https://www.solarcarchallenge.org/challenge/](https://www.solarcarchallenge.org/challenge/)                   |
| 4    | 0        | 2       | 3              | 0:55             | 1:31          | 23         | The Eagle Eye Innovators| [https://www.solarcarchallenge.org/challenge/teams2024/eagle_eye.shtml](<https://www.solarcarchallenge.org/challenge/teams2024/eagle_eye.shtml>) |

The primary columns in this table are the ```team_id```, ```day_lap_credit``` and ```total_laps```. The ```team_id``` is the unique identifier for the team, the ```day_lap_credit``` is the number of laps completed by the team on the day, and the ```total_laps``` is the total number of laps completed by the team.

With this resulting table, we can see the total number of laps completed by each team on each day. For example team 1 completed 5 laps on the day, and has completed 25 laps in total.

The rest of the columns are auxiliary and used to generate a live preview of the data in a web application.

1. Generate a table that allows a user to audit the data for each team on each day.

NOTE: This one is really hard to explain the reason this data is needed and important without giving a lot of background.

```sql
SELECT raw_and_diary_2.id,
       raw_and_diary_2.day,
       raw_and_diary_2.team_id,
       raw_and_diary_2.time_stamp,
       raw_and_diary_2.judge,
       raw_and_diary_2.event,
       raw_and_diary_2.num_passengers,
       raw_and_diary_2.passengers_change_timestamp,
       raw_and_diary_2.any_event_prev_time_diff,
       raw_and_diary_2.any_event_next_time_diff,
       raw_and_diary_2.same_event_prev_time_stamp,
       raw_and_diary_2.same_event_prev_time_diff,
       raw_and_diary_2.same_event_prev_2_time_diff,
       raw_and_diary_2.same_event_next_time_stamp,
       raw_and_diary_2.same_event_next_time_diff,
       raw_and_diary_2.same_event_next_2_time_diff,
       raw_and_diary_2.same_event_same_judge_next_time_diff,
       raw_and_diary_2.last_time_entered_track,
       raw_and_diary_2.last_time_exited_track,
       raw_and_diary_2.current_location,
       raw_and_diary_2.confirmed_lap,
       raw_and_diary_2.lap_click_count,
       raw_and_diary_2.lap_click_any,
       raw_and_diary_2.self_confirmed_lap,
       raw_and_diary_2.num_passengers_impute,
       CASE
           WHEN raw_and_diary_2.num_passengers_impute IS NOT NULL
               THEN raw_and_diary_2.num_passengers_impute * raw_and_diary_2.confirmed_lap
           ELSE raw_and_diary_2.confirmed_lap
           END AS lap_credit,
       CASE
           WHEN raw_and_diary_2.lap_click_any >= 1 AND raw_and_diary_2.same_event_prev_time_stamp >=
                                                       COALESCE(raw_and_diary_2.last_time_entered_track,
                                                                '2021-01-01 00:00:00'::timestamp without time zone)
               THEN raw_and_diary_2.time_stamp - raw_and_diary_2.same_event_prev_time_stamp
           WHEN raw_and_diary_2.lap_click_any >= 1 AND COALESCE(raw_and_diary_2.same_event_prev_time_stamp,
                                                                '2021-01-01 00:00:00'::timestamp without time zone) <
                                                       raw_and_diary_2.last_time_entered_track
               THEN raw_and_diary_2.time_stamp - raw_and_diary_2.last_time_entered_track
           ELSE '00:00:00'::interval
           END AS lap_time,
       CASE
           WHEN raw_and_diary_2.lap_click_count = 1 THEN 'single click lap'::text
           WHEN raw_and_diary_2.lap_click_count = 2 AND raw_and_diary_2.self_confirmed_lap = 1 THEN 'self confirmed lap'::text
           WHEN raw_and_diary_2.lap_click_count >= 2 AND
                (raw_and_diary_2.current_location <> ALL (ARRAY ['on track'::text, 'leaving track'::text]))
               THEN 'check car location'::text
           ELSE ''::text
           END AS low_confidence_lap
FROM (SELECT raw_and_diary_1.id,
             raw_and_diary_1.day,
             raw_and_diary_1.team_id,
             raw_and_diary_1.time_stamp,
             raw_and_diary_1.judge,
             raw_and_diary_1.event,
             raw_and_diary_1.num_passengers,
             raw_and_diary_1.passengers_change_timestamp,
             raw_and_diary_1.any_event_prev_time_diff,
             raw_and_diary_1.any_event_next_time_diff,
             raw_and_diary_1.same_event_prev_time_stamp,
             raw_and_diary_1.same_event_prev_time_diff,
             raw_and_diary_1.same_event_prev_2_time_diff,
             raw_and_diary_1.same_event_next_time_stamp,
             raw_and_diary_1.same_event_next_time_diff,
             raw_and_diary_1.same_event_next_2_time_diff,
             raw_and_diary_1.same_event_same_judge_next_time_diff,
             raw_and_diary_1.last_time_entered_track,
             raw_and_diary_1.last_time_exited_track,
             CASE
                 WHEN raw_and_diary_1.last_time_entered_track > raw_and_diary_1.last_time_exited_track THEN 'on track'::text
                 WHEN raw_and_diary_1.last_time_entered_track IS NOT NULL AND
                      raw_and_diary_1.last_time_exited_track IS NULL THEN 'on track'::text
                 WHEN raw_and_diary_1.last_time_entered_track < raw_and_diary_1.last_time_exited_track AND
                      (raw_and_diary_1.time_stamp - raw_and_diary_1.last_time_exited_track) <= '00:00:05'::interval
                     THEN 'leaving track'::text
                 WHEN raw_and_diary_1.last_time_entered_track < raw_and_diary_1.last_time_exited_track THEN 'in garage'::text
                 ELSE 'unknown location'::text
                 END                       AS current_location,
             CASE
                 WHEN lower(raw_and_diary_1.event::text) = 'mark lap'::text AND
                      raw_and_diary_1.same_event_next_time_diff <= '00:00:30'::interval AND
                      COALESCE(raw_and_diary_1.same_event_prev_time_diff, '00:10:00'::interval) >= '00:00:31'::interval
                     THEN 1
                 WHEN lower(raw_and_diary_1.event::text) = 'mark lap'::text AND
                      raw_and_diary_1.same_event_next_time_diff <= '00:00:30'::interval AND
                      raw_and_diary_1.same_event_prev_time_diff IS NULL THEN 1
                 ELSE 0
                 END                       AS confirmed_lap,
             CASE
                 WHEN lower(raw_and_diary_1.event::text) = 'mark lap'::text AND
                      COALESCE(raw_and_diary_1.same_event_prev_time_diff, '00:10:00'::interval) >=
                      '00:00:31'::interval AND raw_and_diary_1.same_event_next_time_diff <= '00:00:30'::interval AND
                      raw_and_diary_1.same_event_next_2_time_diff <= '00:00:30'::interval THEN 3
                 WHEN lower(raw_and_diary_1.event::text) = 'mark lap'::text AND
                      COALESCE(raw_and_diary_1.same_event_prev_time_diff, '00:10:00'::interval) >=
                      '00:00:31'::interval AND raw_and_diary_1.same_event_next_time_diff <= '00:00:30'::interval THEN 2
                 WHEN lower(raw_and_diary_1.event::text) = 'mark lap'::text AND
                      COALESCE(raw_and_diary_1.same_event_prev_time_diff, '00:10:00'::interval) >= '00:00:31'::interval
                     THEN 1
                 ELSE 0
                 END                       AS lap_click_count,
             CASE
                 WHEN lower(raw_and_diary_1.event::text) = 'mark lap'::text AND
                      COALESCE(raw_and_diary_1.same_event_prev_time_diff, '00:10:00'::interval) >= '00:00:31'::interval
                     THEN 1
                 ELSE 0
                 END                       AS lap_click_any,
             CASE
                 WHEN lower(raw_and_diary_1.event::text) = 'mark lap'::text AND
                      raw_and_diary_1.same_event_same_judge_next_time_diff <= '00:00:30'::interval THEN 1
                 ELSE 0
                 END                       AS self_confirmed_lap,
             num_pass_diary.num_passengers AS num_passengers_impute
      FROM (SELECT raw_and_diary.id,
                   raw_and_diary.day,
                   raw_and_diary.team_id,
                   raw_and_diary.time_stamp,
                   raw_and_diary.judge,
                   raw_and_diary.event,
                   raw_and_diary.num_passengers,
                   max(
                   CASE
                       WHEN COALESCE(raw_and_diary.num_passengers, '-1'::integer) > 0 THEN raw_and_diary.time_stamp
                       ELSE NULL::timestamp without time zone
                       END)
                   OVER (PARTITION BY raw_and_diary.team_id, (EXTRACT(day FROM raw_and_diary.time_stamp)) ORDER BY raw_and_diary.time_stamp, raw_and_diary.id ROWS UNBOUNDED PRECEDING) AS passengers_change_timestamp,
                   raw_and_diary.time_stamp - lag(raw_and_diary.time_stamp, 1)
                                              OVER (PARTITION BY raw_and_diary.team_id ORDER BY raw_and_diary.time_stamp, raw_and_diary.id)                                             AS any_event_prev_time_diff,
                   lead(raw_and_diary.time_stamp, 1)
                   OVER (PARTITION BY raw_and_diary.team_id ORDER BY raw_and_diary.time_stamp, raw_and_diary.id) -
                   raw_and_diary.time_stamp                                                                                                                                             AS any_event_next_time_diff,
                   lag(raw_and_diary.time_stamp, 1)
                   OVER (PARTITION BY raw_and_diary.team_id, raw_and_diary.event ORDER BY raw_and_diary.time_stamp, raw_and_diary.id)                                                   AS same_event_prev_time_stamp,
                   raw_and_diary.time_stamp - lag(raw_and_diary.time_stamp, 1)
                                              OVER (PARTITION BY raw_and_diary.team_id, raw_and_diary.event ORDER BY raw_and_diary.time_stamp, raw_and_diary.id)                        AS same_event_prev_time_diff,
                   raw_and_diary.time_stamp - lag(raw_and_diary.time_stamp, 2)
                                              OVER (PARTITION BY raw_and_diary.team_id, raw_and_diary.event ORDER BY raw_and_diary.time_stamp, raw_and_diary.id)                        AS same_event_prev_2_time_diff,
                   lead(raw_and_diary.time_stamp, 1)
                   OVER (PARTITION BY raw_and_diary.team_id, raw_and_diary.event ORDER BY raw_and_diary.time_stamp, raw_and_diary.id)                                                   AS same_event_next_time_stamp,
                   lead(raw_and_diary.time_stamp, 1)
                   OVER (PARTITION BY raw_and_diary.team_id, raw_and_diary.event ORDER BY raw_and_diary.time_stamp, raw_and_diary.id) -
                   raw_and_diary.time_stamp                                                                                                                                             AS same_event_next_time_diff,
                   lead(raw_and_diary.time_stamp, 2)
                   OVER (PARTITION BY raw_and_diary.team_id, raw_and_diary.event ORDER BY raw_and_diary.time_stamp, raw_and_diary.id) -
                   raw_and_diary.time_stamp                                                                                                                                             AS same_event_next_2_time_diff,
                   lead(raw_and_diary.time_stamp, 1)
                   OVER (PARTITION BY raw_and_diary.team_id, raw_and_diary.event, raw_and_diary.judge ORDER BY raw_and_diary.time_stamp, raw_and_diary.id) -
                   raw_and_diary.time_stamp                                                                                                                                             AS same_event_same_judge_next_time_diff,
                   max(
                   CASE
                       WHEN lower(raw_and_diary.event::text) = 'enter track'::text THEN raw_and_diary.time_stamp
                       ELSE NULL::timestamp without time zone
                       END)
                   OVER (PARTITION BY raw_and_diary.team_id, (EXTRACT(day FROM raw_and_diary.time_stamp)) ORDER BY raw_and_diary.time_stamp, raw_and_diary.id ROWS UNBOUNDED PRECEDING) AS last_time_entered_track,
                   max(
                   CASE
                       WHEN lower(raw_and_diary.event::text) = 'exit track'::text THEN raw_and_diary.time_stamp
                       ELSE NULL::timestamp without time zone
                       END)
                   OVER (PARTITION BY raw_and_diary.team_id, (EXTRACT(day FROM raw_and_diary.time_stamp)) ORDER BY raw_and_diary.time_stamp, raw_and_diary.id ROWS UNBOUNDED PRECEDING) AS last_time_exited_track
            FROM (SELECT score_rawclickeydata.id,
                         score_rawclickeydata.day,
                         score_rawclickeydata.team_id,
                         score_rawclickeydata.time_stamp,
                         score_rawclickeydata.judge,
                         'mark lap'::character varying AS event,
                         '-1'::integer                 AS num_passengers
                  FROM score_rawclickeydata
                  UNION ALL
                  SELECT score_diary.id,
                         score_diary.day,
                         score_diary.team_id,
                         score_diary.time_stamp,
                         score_diary.judge,
                         score_diary.event,
                         score_diary.num_passengers
                  FROM score_diary) raw_and_diary
            ORDER BY raw_and_diary.team_id, raw_and_diary.time_stamp, raw_and_diary.id) raw_and_diary_1
               LEFT JOIN (SELECT score_diary.time_stamp,
                                 score_diary.team_id,
                                 score_diary.num_passengers
                          FROM score_diary) num_pass_diary
                         ON num_pass_diary.time_stamp = raw_and_diary_1.passengers_change_timestamp AND
                            raw_and_diary_1.team_id = num_pass_diary.team_id
      ORDER BY raw_and_diary_1.team_id, raw_and_diary_1.time_stamp, raw_and_diary_1.id) raw_and_diary_2
ORDER BY raw_and_diary_2.team_id, raw_and_diary_2.time_stamp, raw_and_diary_2.id
```

The following table shows the output:
| id   | day | team_id | time_stamp                 | judge           | event   | num_passengers | passengers_change_timestamp | any_event_prev_time_diff               | any_event_next_time_diff | same_event_prev_time_stamp        | same_event_prev_time_diff | same_event_prev_2_time_diff | same_event_next_time_stamp        | same_event_next_time_diff | same_event_next_2_time_diff | same_event_same_judge_next_time_diff | last_time_entered_track | last_time_exited_track | current_location | confirmed_lap | lap_click_count | lap_click_any | self_confirmed_lap | num_passengers_impute | lap_credit | lap_time                                 | low_confidence_lap   |
|------|-----|---------|----------------------------|-----------------|---------|----------------|-----------------------------|---------------------------------------|---------------------------|----------------------------------|---------------------------|------------------------------|----------------------------------|---------------------------|------------------------------|-------------------------------------|-------------------------|------------------------|------------------|----------------|-----------------|----------------|---------------------|-----------------------|------------|------------------------------------------|----------------------|
| 1636 | 1   | 1       | 2021-07-19 10:33:23.707104 | Jarrett's Laptop | mark lap| -1             |                             |                                     | 0 years 0 mons 0 days 0 hours 0 mins 1.155542 secs |                                 | 2021-07-19 10:33:24.862646       | 0 years 0 mons 0 days 0 hours 0 mins 1.155542 secs | 0 years 0 mons 0 days 0 hours 0 mins 1.292896 secs |                                  |                               | 0 years 0 mons 0 days 0 hours 3 mins 1.98599 secs |                                  | unknown location        | 1              | 3               | 1              | 0                  |                       | 1          | 0 years 0 mons 0 days 0 hours 0 mins 0.0 secs  | check car location   |
| 1909 | 1   | 1       | 2021-07-19 10:33:24.862646 | Ricardo         | mark lap| -1             |                             | 0 years 0 mons 0 days 0 hours 0 mins 1.155542 secs | 0 years 0 mons 0 days 0 hours 0 mins 0.137354 secs | 2021-07-19 10:33:23.707104       | 0 years 0 mons 0 days 0 hours 0 mins 1.155542 secs |                                  | 2021-07-19 10:33:25.000000       | 0 years 0 mons 0 days 0 hours 0 mins 0.137354 secs | 0 years 0 mons 0 days 0 hours 3 mins 0.830448 secs | 0 years 0 mons 0 days 0 hours 18 mins 30.463468 secs | unknown location        | 0              | 0               | 0              | 0                  |                       | 0          | 0 years 0 mons 0 days 0 hours 0 mins 0.0 secs  |                      |
| 1637 | 1   | 1       | 2021-07-19 10:33:25.000000 | nfikwm-Eric     | mark lap| -1             |                             | 0 years 0 mons 0 days 0 hours 0 mins 0.137354 secs | 0 years 0 mons 0 days 0 hours 3 mins 0.693094 secs | 2021-07-19 10:33:24.862646       | 0 years 0 mons 0 days 0 hours 0 mins 0.137354 secs | 0 years 0 mons 0 days 0 hours 0 mins 1.292896 secs | 2021-07-19 10:36:25.693094       | 0 years 0 mons 0 days 0 hours 3 mins 0.693094 secs | 0 years 0 mons 0 days 0 hours 3 mins 1.0 secs | 0 years 0 mons 0 days 0 hours 3 mins 1.0 secs | unknown location        | 0              | 0               | 0              | 0                  |                       | 0          | 0 years 0 mons 0 days 0 hours 0 mins 0.0 secs  |                      |

A lot of the table is auxiliary and intermediate data used to generate the table. In total, 1 record is generated for every record in the score_rawclickeydata table. When analyzed together, you are able to identify errors in the dataset and manually correct them. For example in the group of records provided, you can see in the ```low_confidence_lap``` column that the last record is a "check car location" which is a low confidence lap. This is because the logs show the car was not on the track when the lap was marked.

In isolation, these 3 datapoints are not very useful. However, when you have the full dataset to review, you can identify patterns and errors in the data, extremely quickly.
