create database logistics;
use logistics;
-- 1. List all startups founded after 2022.
SELECT * FROM startups WHERE YEAR(Join_Date) > 2022;

-- 2. Count total staff by department. 

SELECT Department, COUNT(*) AS Staff_Count
FROM staff
GROUP BY Department
ORDER BY Staff_Count DESC;

-- 3. Show total visitors logged today. 

SELECT * FROM access_logs;
select count(*) from access_logs
where person_type = 'Visitor'
AND DATE(Entry_Time) = CURDATE();
-- 4. Find startups with more than 20 employees.

select Startup_Name,No_of_Employees from startups
where No_of_Employees>20;

-- 5. List all staff with ID card category = "flexi seat".

select Person_ID
from access_logs where ID_Card_Type ='flexi';

-- 6. Total revenue per startup (join payments & startups). 

DESC payment;
ALTER TABLE startups 
CHANGE `ï»¿Startup_ID` Startup_ID TEXT;
SELECT 
    s.Startup_ID,
    s.Startup_Name,
    SUM(p.Amount) AS Total_Revenue
FROM startups s
JOIN payment p
    ON p.Payer_ID = s.Startup_ID
GROUP BY 
    s.Startup_ID,
    s.Startup_Name
ORDER BY 
    Total_Revenue DESC;
    
ALTER TABLE staff 
CHANGE `ï»¿Staff_ID` Staff_ID TEXT;

ALTER TABLE services
CHANGE `ï»¿Record_ID` Record_ID TEXT;

ALTER TABLE payment
CHANGE `ï»¿Payment_ID` Payment_ID TEXT;

-- 7. Employees who logged in but didn't log out
SELECT Person_ID, Entry_Time, Exit_Time
FROM access_logs
WHERE Exit_Time IS NULL
OR Exit_Time < Entry_Time;

-- 8. Top 5 startups by service usage count
SELECT s.Startup_Name, COUNT(*) AS Usage_Count
FROM services sv
JOIN startups s ON sv.Startup_ID = s.Startup_ID
GROUP BY s.Startup_Name
ORDER BY Usage_Count DESC
LIMIT 5;

--  9. Identify startups booking meeting rooms max hours.
SELECT s.Startup_Name, SUM(sv.Meeting_Room_Hours) AS Total_Hrs
FROM services sv
JOIN startups s ON sv.Startup_ID = s.Startup_ID
GROUP BY s.Startup_Name
ORDER BY Total_Hrs DESC
LIMIT 10;

-- 10. Average working hours per startup

ALTER TABLE staff ADD COLUMN Startup_ID TEXT;

SELECT 
    s.Startup_Name,
    AVG(TIMESTAMPDIFF(MINUTE, a.Entry_Time, a.Exit_Time)/60) AS Avg_Hours
FROM access_logs a
JOIN staff st 
    ON a.Person_ID = st.Staff_ID
JOIN startups s 
    ON st.Startup_ID = s.Startup_ID
WHERE a.Exit_Time IS NOT NULL
GROUP BY s.Startup_Name;

-- 11. Detect users violating 6-hour meeting room rule

SELECT sv.Startup_ID, sv.Month, sv.Meeting_Room_Hours
FROM services sv
WHERE sv.Meeting_Room_Hours > 6;

-- 12. Month-wise revenue trends

SELECT DATE_FORMAT(Payment_Date,'%Y-%m') AS Month,
  SUM(Amount) AS Monthly_Revenue
FROM payments
GROUP BY Month
ORDER BY Month;

-- 13. Wi-Fi login frequency per startup

SELECT s.Startup_Name, SUM(a.WiFi_Login) AS WiFi_Logins
FROM access_logs a
JOIN startups s ON a.Person_ID LIKE CONCAT(s.Startup_ID,'%')
GROUP BY s.Startup_Name
ORDER BY WiFi_Logins DESC;

-- 14. Employees accessing office on weekends
SELECT Person_ID, Entry_Time, DAYNAME(Entry_Time) AS Day
FROM access_logs
WHERE DAYOFWEEK(Entry_Time) IN (1, 7);


-- 15. Detect excessive building entry attempts (>5/day)

SELECT Person_ID,
  COUNT(*) AS Entry_Count
FROM access_logs
GROUP BY Person_ID, DATE(Entry_Time)
HAVING COUNT(*) > 5
ORDER BY Entry_Count DESC;