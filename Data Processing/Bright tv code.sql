---Viewership table---
SELECT *
FROM workspace.brighttv_analysis.viewership
LIMIT 100;

---user profile table---
SELECT *
FROM workspace.brighttv_analysis.user_profile
LIMIT 100;

SELECT Channel2,
 COUNT(*) as sessions
FROM workspace.brighttv_analysis.viewership
GROUP BY Channel2
ORDER BY sessions DESC;

SELECT COUNT(*) 
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID;

---Count the people watching bright tv ---
---There are 10 000 viewers of bright tv channels--- 
SELECT  COUNT(*) AS number_of_viewers
FROM workspace.brighttv_analysis.viewership;

---There are only 5375 user profiles provided of the Bright tv viewers---
SELECT  COUNT(*) AS number_of_viewers
FROM workspace.brighttv_analysis.user_profile;

---There are 4386 subscribers---
SELECT  COUNT( DISTINCT UserID) AS number_of_viewers
FROM workspace.brighttv_analysis.viewership;

---Check for null values---
---No null values in the userid---
SELECT *
FROM workspace.brighttv_analysis.user_profile
WHERE UserID is NULL;

SELECT *
FROM workspace.brighttv_analysis.viewership
WHERE UserID is NULL;

---we have 855 null values classified as 00:00:00, no duration provided---
SELECT Duration2 
FROM workspace.brighttv_analysis.viewership
WHERE Duration2='00:00:00';

---There are 702 viewers who did not provide their provinces---
SELECT Province 
FROM workspace.brighttv_analysis.user_profile
WHERE Province ='None';

---920 viewers did not provide their age---
SELECT Age
FROM workspace.brighttv_analysis.user_profile
WHERE Age=0;

--- 1000 viewers did not provide their race---
SELECT Race
FROM workspace.brighttv_analysis.user_profile
WHERE Race='None';

--- 702 viewers did not mention their gender---
SELECT Gender
FROM workspace.brighttv_analysis.user_profile
WHERE Gender ='None';


---we have data for 3 months Starts the beginning of January and ends the beginning of April---
SELECT MIN(RecordDate2) AS first_active_date,
       MAX(RecordDate2) AS last_active_date
FROM workspace.brighttv_analysis.viewership;

---We have 21 different channels on Bright TV but there is 2 same channels with different capitalisation and other two same problem--
SELECT DISTINCT Channel2
FROM workspace.brighttv_analysis.viewership;

---Convert the time and the date to the south african standard time and date, time must be 2 hours ahead of UTC---
---Convert the datetime from utc to local sast---
SELECT
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg' ) AS sast_timestamp
FROM workspace.brighttv_analysis.viewership;

---Extract the date and time to separate columns---
SELECT
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time
FROM workspace.brighttv_analysis.viewership
ORDER BY Record_Time DESC;
------------------------------

---cleaned and combined--
SELECT V.UserID,
    Channel2,
    Duration2,
    Gender,
    Race,
    Age,
    Province,
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time,
    MONTHNAME(Record_Date) AS Month_name,
    DAYNAME(Record_Date) AS Day_name,
    Dayofmonth(Record_Date) AS day_of_month,

    CASE 
          WHEN Dayname(Record_Date) IN ('Sun','Sat') THEN 'weekend'
          ELSE 'weekday'
    END AS day_classification,
    
      CASE
         WHEN Record_Time >= '00:00:00' AND Record_Time < '06:00:00' THEN 'Early Morning'
         WHEN Record_Time >= '06:00:00' AND Record_Time < '12:00:00' THEN 'Morning'
         WHEN Record_Time >= '12:00:00' AND Record_Time < '18:00:00' THEN 'Afternoon'
         ELSE 'Evening'
      END AS Record_time_bucket,

    CASE
        WHEN Age=0 THEN 'Age_unknown'
        WHEN Age < 18 THEN 'under_age'
        WHEN Age BETWEEN 18 AND 25 THEN 'young_adults'
        WHEN Age BETWEEN 26 AND 35 THEN 'adults'
        WHEN Age BETWEEN 36 AND 50 THEN 'mature_adults'
        ELSE 'seniors'
    END AS age_group,

    CASE 
       WHEN Duration2='00:00:00' THEN 'NULL'
       ELSE Duration2
    END AS Duration_Clean,

    CASE
       WHEN Province IN ('None', 'none', '') THEN 'No_Province'
      ELSE Province
    END AS Province_Clean,

     CASE 
        WHEN Race IN ('None','none','') THEN 'Unknown'
        ELSE Race
    END AS Race_clean,

   CASE 
        WHEN Gender IN ('None','none','') THEN 'Prefer_not_to_say'
        ELSE Gender
    END AS Gender_clean,

   CASE 
    WHEN channel2 IS NULL THEN 'Not Applicable'
    ELSE channel2
   END AS channel2_clean
      
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID;


---Insights---
WITH clean_data AS (
   SELECT V.UserID,
    Channel2,
    Duration2,
    Gender,
    Race,
    Age,
    Province,
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time,
    MONTHNAME(Record_Date) AS Month_name,
    DAYNAME(Record_Date) AS Day_name,
    Dayofmonth(Record_Date) AS day_of_month,

    CASE 
          WHEN Dayname(Record_Date) IN ('Sun','Sat') THEN 'weekend'
          ELSE 'weekday'
    END AS day_classification,
    
      CASE
         WHEN Record_Time >= '00:00:00' AND Record_Time < '06:00:00' THEN 'Early Morning'
         WHEN Record_Time >= '06:00:00' AND Record_Time < '12:00:00' THEN 'Morning'
         WHEN Record_Time >= '12:00:00' AND Record_Time < '18:00:00' THEN 'Afternoon'
         ELSE 'Evening'
      END AS Record_time_bucket,

    CASE
        WHEN Age=0 THEN 'Age_unknown'
        WHEN Age < 18 THEN 'under_age'
        WHEN Age BETWEEN 18 AND 25 THEN 'young_adults'
        WHEN Age BETWEEN 26 AND 35 THEN 'adults'
        WHEN Age BETWEEN 36 AND 50 THEN 'mature_adults'
        ELSE 'seniors'
    END AS age_group,

    CASE 
       WHEN Duration2='00:00:00' THEN 'NULL'
       ELSE Duration2
    END AS Duration_Clean,

    CASE
       WHEN Province IN ('None', 'none', '') THEN 'No_Province'
      ELSE Province
    END AS Province_Clean,

     CASE 
        WHEN Race IN ('None','none','') THEN 'Unknown'
        ELSE Race
    END AS Race_clean,

   CASE 
        WHEN Gender IN ('None','none','') THEN 'Prefer_not_to_say'
        ELSE Gender
    END AS Gender_clean
      
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID)
---Supersport Live Events has many views 1638, followed by ICC Cricket World Cup 2011 with 1465 views, Channel O follows with 1050 views----
---Sawsee, Wimbledon and Live on SuperSport are the least watched channels---
SELECT Channel2, 
       COUNT(*) AS total_views
FROM clean_data
GROUP BY Channel2
ORDER BY total_views DESC;
--------------------------------------------

WITH clean_data AS (
    SELECT V.UserID,
    Channel2,
    Duration2,
    Gender,
    Race,
    Age,
    Province,
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time,
    MONTHNAME(Record_Date) AS Month_name,
    DAYNAME(Record_Date) AS Day_name,
    Dayofmonth(Record_Date) AS day_of_month,

    CASE 
          WHEN Dayname(Record_Date) IN ('Sun','Sat') THEN 'weekend'
          ELSE 'weekday'
    END AS day_classification,
    
      CASE
         WHEN Record_Time >= '00:00:00' AND Record_Time < '06:00:00' THEN 'Early Morning'
         WHEN Record_Time >= '06:00:00' AND Record_Time < '12:00:00' THEN 'Morning'
         WHEN Record_Time >= '12:00:00' AND Record_Time < '18:00:00' THEN 'Afternoon'
         ELSE 'Evening'
      END AS Record_time_bucket,

    CASE
        WHEN Age=0 THEN 'Age_unknown'
        WHEN Age < 18 THEN 'under_age'
        WHEN Age BETWEEN 18 AND 25 THEN 'young_adults'
        WHEN Age BETWEEN 26 AND 35 THEN 'adults'
        WHEN Age BETWEEN 36 AND 50 THEN 'mature_adults'
        ELSE 'seniors'
    END AS age_group,

    CASE 
       WHEN Duration2='00:00:00' THEN 'NULL'
       ELSE Duration2
    END AS Duration_Clean,

    CASE
       WHEN Province IN ('None', 'none', '') THEN 'No_Province'
      ELSE Province
    END AS Province_Clean,

     CASE 
        WHEN Race IN ('None','none','') THEN 'Unknown'
        ELSE Race
    END AS Race_clean,

   CASE 
        WHEN Gender IN ('None','none','') THEN 'Prefer_not_to_say'
        ELSE Gender
    END AS Gender_clean
      
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID)
---many viewers watch channels in the evening, followed by the afternoon time bucket, Morning has average views and Early morning have least views----
SELECT Record_time_bucket, 
      COUNT(*) AS views
FROM clean_data
GROUP BY Record_time_bucket;
---------------------------------------------

WITH clean_data AS ( SELECT V.UserID,
    Channel2,
    Duration2,
    Gender,
    Race,
    Age,
    Province,
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time,
    MONTHNAME(Record_Date) AS Month_name,
    DAYNAME(Record_Date) AS Day_name,
    Dayofmonth(Record_Date) AS day_of_month,

    CASE 
          WHEN Dayname(Record_Date) IN ('Sun','Sat') THEN 'weekend'
          ELSE 'weekday'
    END AS day_classification,
    
      CASE
         WHEN Record_Time >= '00:00:00' AND Record_Time < '06:00:00' THEN 'Early Morning'
         WHEN Record_Time >= '06:00:00' AND Record_Time < '12:00:00' THEN 'Morning'
         WHEN Record_Time >= '12:00:00' AND Record_Time < '18:00:00' THEN 'Afternoon'
         ELSE 'Evening'
      END AS Record_time_bucket,

    CASE
        WHEN Age=0 THEN 'Age_unknown'
        WHEN Age < 18 THEN 'under_age'
        WHEN Age BETWEEN 18 AND 25 THEN 'young_adults'
        WHEN Age BETWEEN 26 AND 35 THEN 'adults'
        WHEN Age BETWEEN 36 AND 50 THEN 'mature_adults'
        ELSE 'seniors'
    END AS age_group,

    CASE 
       WHEN Duration2='00:00:00' THEN 'NULL'
       ELSE Duration2
    END AS Duration_Clean,

    CASE
       WHEN Province IN ('None', 'none', '') THEN 'No_Province'
      ELSE Province
    END AS Province_Clean,

     CASE 
        WHEN Race IN ('None','none','') THEN 'Unknown'
        ELSE Race
    END AS Race_clean,

   CASE 
        WHEN Gender IN ('None','none','') THEN 'Prefer_not_to_say'
        ELSE Gender
    END AS Gender_clean
      
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID)
---Many  viwers are the adults and mature, there are 175 people who did not provide their age--- 
SELECT age_group, 
COUNT(DISTINCT UserID) AS viewers
FROM clean_data
GROUP BY age_group;
--------------------------------------


WITH clean_data AS ( SELECT V.UserID,
    Channel2,
    Duration2,
    Gender,
    Race,
    Age,
    Province,
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time,
    MONTHNAME(Record_Date) AS Month_name,
    DAYNAME(Record_Date) AS Day_name,
    Dayofmonth(Record_Date) AS day_of_month,

    CASE 
          WHEN Dayname(Record_Date) IN ('Sun','Sat') THEN 'weekend'
          ELSE 'weekday'
    END AS day_classification,
    
      CASE
         WHEN Record_Time >= '00:00:00' AND Record_Time < '06:00:00' THEN 'Early Morning'
         WHEN Record_Time >= '06:00:00' AND Record_Time < '12:00:00' THEN 'Morning'
         WHEN Record_Time >= '12:00:00' AND Record_Time < '18:00:00' THEN 'Afternoon'
         ELSE 'Evening'
      END AS Record_time_bucket,

    CASE
        WHEN Age=0 THEN 'Age_unknown'
        WHEN Age < 18 THEN 'under_age'
        WHEN Age BETWEEN 18 AND 25 THEN 'young_adults'
        WHEN Age BETWEEN 26 AND 35 THEN 'adults'
        WHEN Age BETWEEN 36 AND 50 THEN 'mature_adults'
        ELSE 'seniors'
    END AS age_group,

    CASE 
       WHEN Duration2='00:00:00' THEN 'NULL'
       ELSE Duration2
    END AS Duration_Clean,

    CASE
       WHEN Province IN ('None', 'none', '') THEN 'No_Province'
      ELSE Province
    END AS Province_Clean,

     CASE 
        WHEN Race IN ('None','none','') THEN 'Unknown'
        ELSE Race
    END AS Race_clean,

   CASE 
        WHEN Gender IN ('None','none','') THEN 'Prefer_not_to_say'
        ELSE Gender
    END AS Gender_clean
      
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID)
---There are many males than females besides the people who did not provide their gender---
SELECT Gender,
    COUNT(*) Number_per_gender
FROM clean_data
GROUP BY Gender;
-----------------------------------------

WITH clean_data AS ( SELECT V.UserID,
    Channel2,
    Duration2,
    Gender,
    Race,
    Age,
    Province,
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time,
    MONTHNAME(Record_Date) AS Month_name,
    DAYNAME(Record_Date) AS Day_name,
    Dayofmonth(Record_Date) AS day_of_month,

    CASE 
          WHEN Dayname(Record_Date) IN ('Sun','Sat') THEN 'weekend'
          ELSE 'weekday'
    END AS day_classification,
    
      CASE
         WHEN Record_Time >= '00:00:00' AND Record_Time < '06:00:00' THEN 'Early Morning'
         WHEN Record_Time >= '06:00:00' AND Record_Time < '12:00:00' THEN 'Morning'
         WHEN Record_Time >= '12:00:00' AND Record_Time < '18:00:00' THEN 'Afternoon'
         ELSE 'Evening'
      END AS Record_time_bucket,

    CASE
        WHEN Age=0 THEN 'Age_unknown'
        WHEN Age < 18 THEN 'under_age'
        WHEN Age BETWEEN 18 AND 25 THEN 'young_adults'
        WHEN Age BETWEEN 26 AND 35 THEN 'adults'
        WHEN Age BETWEEN 36 AND 50 THEN 'mature_adults'
        ELSE 'seniors'
    END AS age_group,

    CASE 
       WHEN Duration2='00:00:00' THEN 'NULL'
       ELSE Duration2
    END AS Duration_Clean,

    CASE
       WHEN Province IN ('None', 'none', '') THEN 'No_Province'
      ELSE Province
    END AS Province_Clean,

     CASE 
        WHEN Race IN ('None','none','') THEN 'Unknown'
        ELSE Race
    END AS Race_clean,

   CASE 
        WHEN Gender IN ('None','none','') THEN 'Prefer_not_to_say'
        ELSE Gender
    END AS Gender_clean
      
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID)
---There are many black people than other race---
SELECT Race,
    COUNT(*) AS people_per_race
FROM clean_data
GROUP BY Race;
------------------------------------
---verify the channels--=
WITH clean_data AS(
    SELECT V.UserID,
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time,
    date_format(Duration2, 'HH:mm:ss') AS Duration,
    MONTHNAME(Record_Date) AS Month_name,
    DAYNAME(Record_Date) AS Day_name,
    Dayofmonth(Record_Date) AS day_of_month,

    CASE 
          WHEN Dayname(Record_Date) IN ('Sun','Sat') THEN 'weekend'
          ELSE 'weekday'
    END AS day_classification,
    
      CASE
         WHEN Record_Time >= '00:00:00' AND Record_Time < '06:00:00' THEN 'Early Morning'
         WHEN Record_Time >= '06:00:00' AND Record_Time < '12:00:00' THEN 'Morning'
         WHEN Record_Time >= '12:00:00' AND Record_Time < '18:00:00' THEN 'Afternoon'
         ELSE 'Evening'
      END AS Record_time_bucket,

    CASE
        WHEN Age=0 THEN 'Age_unknown'
        WHEN Age < 18 THEN 'under_age'
        WHEN Age BETWEEN 18 AND 25 THEN 'young_adults'
        WHEN Age BETWEEN 26 AND 35 THEN 'adults'
        WHEN Age BETWEEN 36 AND 50 THEN 'mature_adults'
        ELSE 'seniors'
    END AS age_group,

    CASE 
       WHEN Duration='00:00:00' THEN 'NULL'
       ELSE Duration
    END AS Duration_Clean,

    CASE
       WHEN Province IN ('None', 'none', '') THEN 'No_Province'
      ELSE Province
    END AS Province_Clean,

     CASE 
        WHEN Race IN ('None','none','') THEN 'Unknown'
        ELSE Race
    END AS Race_clean,

   CASE 
        WHEN Gender IN ('None','none','') THEN 'Prefer_not_to_say'
        ELSE Gender
    END AS Gender_clean,

   CASE 
    WHEN channel2 IS NULL THEN 'Not Applicable'
    ELSE channel2
   END AS channel2_clean
      
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID)
SELECT DISTINCT Channel2_Clean
FROM clean_data;

---------------------------------------------------------------------------------
----the executed table with important columns----
SELECT V.UserID,
    RecordDate2 AS utc_DateTime,
    from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp,
    DATE(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg')) AS Record_Date,
    date_format(from_utc_timestamp(to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg'),'HH:mm:ss') AS Record_Time,
    date_format(Duration2, 'HH:mm:ss') AS Duration,
    MONTHNAME(Record_Date) AS Month_name,
    DAYNAME(Record_Date) AS Day_name,
    Dayofmonth(Record_Date) AS day_of_month,

    CASE 
          WHEN Dayname(Record_Date) IN ('Sun','Sat') THEN 'weekend'
          ELSE 'weekday'
    END AS day_classification,
    
      CASE
         WHEN Record_Time >= '00:00:00' AND Record_Time < '06:00:00' THEN 'Early Morning'
         WHEN Record_Time >= '06:00:00' AND Record_Time < '12:00:00' THEN 'Morning'
         WHEN Record_Time >= '12:00:00' AND Record_Time < '18:00:00' THEN 'Afternoon'
         ELSE 'Evening'
      END AS Record_time_bucket,

    CASE
        WHEN Age=0 THEN 'Age_unknown'
        WHEN Age < 18 THEN 'under_age'
        WHEN Age BETWEEN 18 AND 25 THEN 'young_adults'
        WHEN Age BETWEEN 26 AND 35 THEN 'adults'
        WHEN Age BETWEEN 36 AND 50 THEN 'mature_adults'
        ELSE 'seniors'
    END AS age_group,

    CASE 
       WHEN Duration='00:00:00' THEN 'NULL'
       ELSE Duration
    END AS Duration_Clean,

    CASE
       WHEN Province IN ('None', 'none', '') THEN 'No_Province'
      ELSE Province
    END AS Province_Clean,

     CASE 
        WHEN Race IN ('None','none','') THEN 'Unknown'
        ELSE Race
    END AS Race_clean,

   CASE 
        WHEN Gender IN ('None','none','') THEN 'Prefer_not_to_say'
        ELSE Gender
    END AS Gender_clean,

   CASE 
    WHEN channel2 IS NULL THEN 'Not Applicable'
    ELSE channel2
   END AS channel2_clean
      
FROM workspace.brighttv_analysis.viewership AS V
FULL OUTER JOIN workspace.brighttv_analysis.user_profile AS U_p
ON V.UserID = U_p.UserID;
