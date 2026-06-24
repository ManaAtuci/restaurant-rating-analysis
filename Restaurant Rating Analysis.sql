--CONSUMER PREFERENCE TABLE
CREATE TABLE consumer_preference(
Consumer_ID VARCHAR(20),
	Preferred_Cuisine VARCHAR(50)
);


--CONSUMERS TABLE
CREATE TABLE consumers_table(
Consumer_ID VARCHAR(20),
	City VARCHAR(100),
	State VARCHAR(100),
	Country VARCHAR(50),
	Latitude NUMERIC(10,3),
	Longitude NUMERIC(10,3),
	Smoker VARCHAR(5),
	Drink_Level VARCHAR(20),
	Transportation_Method VARCHAR(20),
	Marital_Status VARCHAR(20),
	Children VARCHAR(20),
	Age INT,
	Occupation VARCHAR(20),
	Budget VARCHAR(20)
);



--RATINGS TABLE
CREATE TABLE ratings(
Consumer_ID VARCHAR(20),
Resturant_ID VARCHAR(20),
	Overall_Rating INT,
	Food_Rating INT,
	Service_Rating INT
);





--RESTAURANT CUISINE TABLE
CREATE TABLE resturant_cuisines(
Resturant_ID VARCHAR(20),
	Cuisine VARCHAR(50)
);





--RESTURANT TABLE
CREATE TABLE resturants(
Resturant_ID VARCHAR(20),
	Name VARCHAR(100),
	City VARCHAR(50),
	State VARCHAR(50),
	Country VARCHAR(20),
	Zip_Code VARCHAR(10),
	Latitude NUMERIC(10,3),
	Longitude NUMERIC(10,3),
	Alcohol_Service VARCHAR(20),
	Smoking_Allowed VARCHAR(20),
	Price VARCHAR(10),
	Franchise VARCHAR(5),
	Area VARCHAR(20),
	Parking VARCHAR(20)
);



SELECT * FROM consumer_preference;

SELECT * FROM consumers_table;

--Correcting the Data Type
ALTER TABLE consumers_table
ALTER COLUMN Latitude TYPE NUMERIC(10,7)
USING Latitude::NUMERIC(10,7);

ALTER TABLE consumers_table
ALTER COLUMN Longitude TYPE NUMERIC(10,7)
USING Longitude::NUMERIC(10,7);

ALTER TABLE consumers_table
RENAME TO consumers;



SELECT * FROM ratings;


SELECT * FROM resturant_cuisines;


SELECT * FROM resturants;


ALTER TABLE resturants
ALTER COLUMN Latitude TYPE NUMERIC(10,7)
USING Latitude::NUMERIC(10,7);

ALTER TABLE resturants
ALTER COLUMN Longitude TYPE NUMERIC(10,7)
USING Longitude::NUMERIC(10,7);




--DATA QUALITY CHECK
--Check for missing values
SELECT 
    'consumers' AS table_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN Occupation IS NULL THEN 1 ELSE 0 END) AS null_occupation,
    SUM(CASE WHEN Budget IS NULL THEN 1 ELSE 0 END) AS null_budget
FROM consumers

UNION ALL

SELECT 
    'ratings',
    COUNT(*),
    SUM(CASE WHEN Overall_Rating IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Food_Rating IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Service_Rating IS NULL THEN 1 ELSE 0 END)
FROM ratings;

-- Check for duplicate consumer-restaurant pairs
SELECT 
    Consumer_ID, 
    Resturant_ID, 
    COUNT(*) as rating_count
FROM ratings
GROUP BY Consumer_ID, Resturant_ID
HAVING COUNT(*) > 1;



-- Comprehensive NULL audit across all columns
-- Full NULL audit for CONSUMERS table
SELECT 
    COUNT(*) FILTER (WHERE Consumer_ID IS NULL) AS missing_consumer_id,
    COUNT(*) FILTER (WHERE City IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE State IS NULL) AS missing_state,
    COUNT(*) FILTER (WHERE Country IS NULL) AS missing_country,
    COUNT(*) FILTER (WHERE Latitude IS NULL) AS missing_latitude,
    COUNT(*) FILTER (WHERE Longitude IS NULL) AS missing_longitude,
    COUNT(*) FILTER (WHERE Smoker IS NULL) AS missing_smoker,
    COUNT(*) FILTER (WHERE Drink_Level IS NULL) AS missing_drink_level,
    COUNT(*) FILTER (WHERE Transportation_Method IS NULL) AS missing_transportation,
    COUNT(*) FILTER (WHERE Marital_Status IS NULL) AS missing_marital_status,
    COUNT(*) FILTER (WHERE Children IS NULL) AS missing_children,
    COUNT(*) FILTER (WHERE Age IS NULL) AS missing_age,
    COUNT(*) FILTER (WHERE Occupation IS NULL) AS missing_occupation,
    COUNT(*) FILTER (WHERE Budget IS NULL) AS missing_budget
FROM consumers;

-- Full NULL audit for RATINGS table
SELECT 
    COUNT(*) FILTER (WHERE Consumer_ID IS NULL) AS missing_consumer_id,
    COUNT(*) FILTER (WHERE Overall_Rating IS NULL) AS missing_overall_rating,
    COUNT(*) FILTER (WHERE Food_Rating IS NULL) AS missing_food_rating,
    COUNT(*) FILTER (WHERE Service_Rating IS NULL) AS missing_service_rating
FROM ratings;

-- Full NULL audit for RESTAURANTS table
SELECT 
    COUNT(*) FILTER (WHERE Resturant_ID IS NULL) AS missing_resturant_id,
    COUNT(*) FILTER (WHERE Name IS NULL) AS missing_name,
    COUNT(*) FILTER (WHERE City IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE State IS NULL) AS missing_state,
    COUNT(*) FILTER (WHERE Country IS NULL) AS missing_country,
    COUNT(*) FILTER (WHERE Latitude IS NULL) AS missing_latitude,
    COUNT(*) FILTER (WHERE Longitude IS NULL) AS missing_longitude,
    COUNT(*) FILTER (WHERE Alcohol_Service IS NULL) AS missing_alcohol_service,
    COUNT(*) FILTER (WHERE Smoking_Allowed IS NULL) AS missing_smoking_allowed,
    COUNT(*) FILTER (WHERE Price IS NULL) AS missing_price,
    COUNT(*) FILTER (WHERE Franchise IS NULL) AS missing_franchise,
    COUNT(*) FILTER (WHERE Parking IS NULL) AS missing_parking
FROM resturants;

-- Full NULL audit for RESTAURANT_CUISINES table
SELECT 
    COUNT(*) FILTER (WHERE Resturant_ID IS NULL) AS missing_resturant_id,
    COUNT(*) FILTER (WHERE Cuisine IS NULL) AS missing_cuisine
FROM resturant_cuisines;

-- Full NULL audit for CONSUMER_PREFERENCES table
SELECT 
    COUNT(*) FILTER (WHERE Consumer_ID IS NULL) AS missing_consumer_id,
    COUNT(*) FILTER (WHERE Preferred_Cuisine IS NULL) AS missing_preferred_cuisine
FROM consumer_preference;



-- HANDLE MISSING VALUES (IMPUTATION)

-- For AGE: Using average (mean)
-- Calculate average age
SELECT AVG(Age) AS average_age
FROM consumers
WHERE Age IS NOT NULL;

-- Impute missing ages with average (mean)
UPDATE consumers
SET Age = (
    SELECT AVG(Age)
    FROM consumers
    WHERE Age IS NOT NULL
)
WHERE Age IS NULL;

-- For OCCUPATION: Most common is 'Student'
UPDATE consumers
SET Occupation = 'Student'
WHERE Occupation IS NULL;

-- For BUDGET: Most common is 'Medium'
UPDATE consumers
SET Budget = 'Medium'
WHERE Budget IS NULL;

-- For DRINK_LEVEL: Most common is 'Abstemious'
UPDATE consumers
SET Drink_Level = 'Abstemious'
WHERE Drink_Level IS NULL;

-- For SMOKER: Default to 'No' (most common)
UPDATE consumers
SET Smoker = 'No'
WHERE Smoker IS NULL;

-- For MARITAL_STATUS: Default to 'Single' (most common)
UPDATE consumers
SET Marital_Status = 'Single'
WHERE Marital_Status IS NULL;

-- For CHILDREN: Default to 'Independent' (most common)
UPDATE consumers
SET Children = 'Independent'
WHERE Children IS NULL;

-- For TRANSPORTATION_METHOD: Default to 'Public' (most common)
UPDATE consumers
SET Transportation_Method = 'Public'
WHERE Transportation_Method IS NULL;

-- For RATINGS: Default missing ratings to 1 (middle of 0-3 scale)
UPDATE ratings
SET Overall_Rating = 1
WHERE Overall_Rating IS NULL;

UPDATE ratings
SET Food_Rating = 1
WHERE Food_Rating IS NULL;

UPDATE ratings
SET Service_Rating = 1
WHERE Service_Rating IS NULL;

-- For RESTAURANTS: Missing values
UPDATE resturants
SET Price = 'Medium'
WHERE Price IS NULL;

UPDATE resturants
SET Alcohol_Service = 'None'
WHERE Alcohol_Service IS NULL;

UPDATE resturants
SET Parking = 'None'
WHERE Parking IS NULL;

UPDATE resturants
SET Smoking_Allowed = 'No'
WHERE Smoking_Allowed IS NULL;




-- VERIFY
-- Verify consumers table (demographic and behavioral fields)
SELECT 
    COUNT(*) FILTER (WHERE Age IS NULL) AS remaining_null_age,
    COUNT(*) FILTER (WHERE Occupation IS NULL) AS remaining_null_occupation,
    COUNT(*) FILTER (WHERE Budget IS NULL) AS remaining_null_budget,
    COUNT(*) FILTER (WHERE Drink_Level IS NULL) AS remaining_null_drink_level,
    COUNT(*) FILTER (WHERE Smoker IS NULL) AS remaining_null_smoker,
    COUNT(*) FILTER (WHERE Marital_Status IS NULL) AS remaining_null_marital_status,
    COUNT(*) FILTER (WHERE Children IS NULL) AS remaining_null_children,
    COUNT(*) FILTER (WHERE Transportation_Method IS NULL) AS remaining_null_transportation
FROM consumers;

-- Expected: All zeros (0) for every column

-- Verify ratings table
SELECT 
    COUNT(*) FILTER (WHERE Overall_Rating IS NULL) AS remaining_null_overall_rating,
    COUNT(*) FILTER (WHERE Food_Rating IS NULL) AS remaining_null_food_rating,
    COUNT(*) FILTER (WHERE Service_Rating IS NULL) AS remaining_null_service_rating
FROM ratings;

-- Expected: All zeros (0) for every column

-- Verify restaurants table (note: your table is spelled 'resturants')
SELECT 
    COUNT(*) FILTER (WHERE Price IS NULL) AS remaining_null_price,
    COUNT(*) FILTER (WHERE Alcohol_Service IS NULL) AS remaining_null_alcohol_service,
    COUNT(*) FILTER (WHERE Parking IS NULL) AS remaining_null_parking,
    COUNT(*) FILTER (WHERE Smoking_Allowed IS NULL) AS remaining_null_smoking_allowed
FROM resturants;






-- REMOVE BLANK ROWS (COMPLETELY EMPTY RECORDS)

-- Remove any rating records where ALL rating columns are NULL
DELETE FROM ratings
WHERE Overall_Rating IS NULL 
  AND Food_Rating IS NULL 
  AND Service_Rating IS NULL;

-- Remove any consumer records with no usable information (all demographic fields NULL)
DELETE FROM consumers
WHERE Age IS NULL 
  AND Occupation IS NULL 
  AND Budget IS NULL 
  AND City IS NULL;





-- CHECK FOR DUPLICATES

-- Add a temporary id column if none exists
ALTER TABLE consumer_preference ADD COLUMN temp_id SERIAL;

-- Delete duplicates keeping the one with smallest temp_id
DELETE FROM consumer_preference
WHERE temp_id NOT IN (
    SELECT MIN(temp_id)
    FROM consumer_preference
    GROUP BY Consumer_ID, Preferred_Cuisine
);

-- Drop the temporary column
ALTER TABLE consumer_preference DROP COLUMN temp_id;





-- VALIDATE CATEGORICAL COLUMNS

-- Validate Budget values (should be Low, Medium, High)
SELECT Budget, COUNT(*) AS total 
FROM consumers 
GROUP BY Budget 
ORDER BY total DESC;

-- Validate Drink_Level values
SELECT Drink_Level, COUNT(*) AS total 
FROM consumers 
GROUP BY Drink_Level 
ORDER BY total DESC;

-- Validate Marital_Status values
SELECT Marital_Status, COUNT(*) AS total 
FROM consumers 
GROUP BY Marital_Status 
ORDER BY total DESC;

-- Validate Children values
SELECT Children, COUNT(*) AS total 
FROM consumers 
GROUP BY Children 
ORDER BY total DESC;

-- Validate Occupation values
SELECT Occupation, COUNT(*) AS total 
FROM consumers 
GROUP BY Occupation 
ORDER BY total DESC;

-- Validate Price values in restaurants
SELECT Price, COUNT(*) AS total 
FROM resturants 
GROUP BY Price 
ORDER BY total DESC;

-- Validate Alcohol_Service values
SELECT Alcohol_Service, COUNT(*) AS total 
FROM resturants 
GROUP BY Alcohol_Service 
ORDER BY total DESC;

-- Validate Parking values
SELECT Parking, COUNT(*) AS total 
FROM resturants 
GROUP BY Parking 
ORDER BY total DESC;





-- VALIDATE NUMERIC RANGES

-- Age should be between 18 and 100
SELECT MIN(Age), MAX(Age), AVG(Age)
FROM consumers;

-- Ratings should be between min and max
SELECT 
    MIN(Overall_Rating) AS min_overall,
    MAX(Overall_Rating) AS max_overall,
    MIN(Food_Rating) AS min_food,
    MAX(Food_Rating) AS max_food,
    MIN(Service_Rating) AS min_service,
    MAX(Service_Rating) AS max_service
FROM ratings;

-- Fix any ratings outside 0-3 range
UPDATE ratings
SET Overall_Rating = CASE 
    WHEN Overall_Rating < 0 THEN 0
    WHEN Overall_Rating > 3 THEN 3
    ELSE Overall_Rating
END;

UPDATE ratings
SET Food_Rating = CASE 
    WHEN Food_Rating < 0 THEN 0
    WHEN Food_Rating > 3 THEN 3
    ELSE Food_Rating
END;

UPDATE ratings
SET Service_Rating = CASE 
    WHEN Service_Rating < 0 THEN 0
    WHEN Service_Rating > 3 THEN 3
    ELSE Service_Rating
END;

-- Fix any ages outside reasonable range
UPDATE consumers
SET Age = 22
WHERE Age < 18 OR Age > 100;




-- VALIDATE RELATIONSHIPS & FOREIGN KEYS

-- Verify all tables have expected row counts after cleaning
SELECT 'consumers' AS table_name, COUNT(*) AS row_count FROM consumers
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings
UNION ALL
SELECT 'restaurants', COUNT(*) FROM resturants
UNION ALL
SELECT 'restaurant_cuisines', COUNT(*) FROM resturant_cuisines
UNION ALL
SELECT 'consumer_preferences', COUNT(*) FROM consumer_preference;

-- Check for ratings without a valid consumer
SELECT COUNT(*) AS orphaned_ratings
FROM ratings r
LEFT JOIN consumers c ON r.Consumer_ID = c.Consumer_ID
WHERE c.Consumer_ID IS NULL;


-- Check for ratings without a valid restaurant
SELECT COUNT(*) AS orphaned_ratings
FROM ratings r
LEFT JOIN resturants rt ON r.Resturant_ID = rt.Resturant_ID
WHERE rt.Resturant_ID IS NULL;


-- Check for ratings without a valid consumer preferences
SELECT COUNT(*) AS orphaned_preference
FROM consumer_preference cp
LEFT JOIN consumers c ON cp.Consumer_ID = c.Consumer_ID
WHERE c.Consumer_ID IS NULL;
-- 

-- Check for ratings without a valid restaurant cuisines
SELECT COUNT(*) AS orphaned_cuisines
FROM resturant_cuisines rc
LEFT JOIN resturants rt ON rc.Resturant_ID = rt.Resturant_ID
WHERE rt.Resturant_ID IS NULL;




-- VERIFY DATA CLEANING WAS SUCCESSFUL

-- Confirm no NULL values remain in critical consumer fields
SELECT 
    COUNT(*) FILTER (WHERE Age IS NULL) AS remaining_null_age,
    COUNT(*) FILTER (WHERE Occupation IS NULL) AS remaining_null_occupation,
    COUNT(*) FILTER (WHERE Budget IS NULL) AS remaining_null_budget
FROM consumers;

-- Confirm no NULL values remain in critical rating fields
SELECT 
    COUNT(*) FILTER (WHERE Overall_Rating IS NULL) AS remaining_null_overall,
    COUNT(*) FILTER (WHERE Food_Rating IS NULL) AS remaining_null_food,
    COUNT(*) FILTER (WHERE Service_Rating IS NULL) AS remaining_null_service
FROM ratings;

-- Confirm no duplicate consumer-restaurant pairs remain
SELECT COUNT(*) AS duplicate_pairs_remaining
FROM (
    SELECT Consumer_ID, Resturant_ID, COUNT(*) AS rating_count
    FROM ratings
    GROUP BY Consumer_ID, Resturant_ID
    HAVING COUNT(*) > 1
) AS duplicates;



-- PREVIEW CLEANED DATASET

-- Preview joined dataset (first 10 rows)
SELECT
    c.Consumer_ID,
    c.Age,
    c.Occupation,
    c.Budget,
    c.Drink_Level,
    r.Resturant_ID,
    r.Overall_Rating,
    r.Food_Rating,
    r.Service_Rating,
    rt.Name AS resturant_name,
    rt.Price,
    rt.Alcohol_Service
FROM consumers c
JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
JOIN resturants rt ON r.Resturant_ID = rt.Resturant_ID
LIMIT 10;




-- FINAL DATA QUALITY REPORT

-- Use separate subqueries
SELECT 
    'DATA QUALITY CHECK COMPLETE' AS status,
    (SELECT COUNT(DISTINCT Consumer_ID) FROM consumers) AS total_consumers,
    (SELECT COUNT(DISTINCT Resturant_ID) FROM resturants) AS total_resturants,
    (SELECT COUNT(*) FROM ratings) AS total_ratings,
    (SELECT ROUND(AVG(Overall_Rating), 2) FROM ratings) AS avg_overall_rating,
    (SELECT COUNT(*) FROM consumers WHERE Age BETWEEN 18 AND 30) AS young_consumers,
    (SELECT ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM consumers), 1) 
     FROM consumers WHERE Occupation = 'Student') AS student_percentage,
    (SELECT COUNT(*) FROM consumers WHERE Budget = 'Low') AS low_budget_consumers,
    (SELECT COUNT(*) FROM resturants WHERE Alcohol_Service IN ('Wine & Beer', 'Full Bar')) AS resturants_with_bar
;




--
-- HIGHEST RATED RESTAURANTS

--1.1 TOP 20 RESTAURANTS WITH BEST RATINGS
-- Find restaurants with at least 10 ratings, showing their average score
SELECT 
    r.Resturant_ID,
    rt.Name,
    rt.City,
    rt.Price,
    AVG(r.Overall_Rating) AS avg_rating,
    COUNT(r.Overall_Rating) AS num_ratings
FROM ratings r
JOIN resturants rt ON r.Resturant_ID = rt.Resturant_ID
GROUP BY r.Resturant_ID, rt.Name, rt.City, rt.Price
HAVING COUNT(r.Overall_Rating) >= 10
ORDER BY avg_rating DESC
LIMIT 20;


-- 1.2 Do consumer preferences affect ratings?
-- Compare ratings when restaurant matches vs doesn't match consumer's preferred cuisine

WITH preference_matches AS (
    SELECT 
        r.Consumer_ID,
        r.Resturant_ID,
        r.Overall_Rating,
        cp.Preferred_Cuisine,
        rc.Cuisine
    FROM ratings r
    JOIN consumers c ON r.Consumer_ID = c.Consumer_ID
    JOIN resturants rt ON r.Resturant_ID = rt.Resturant_ID
    JOIN resturant_cuisines rc ON rt.Resturant_ID = rc.Resturant_ID
    LEFT JOIN consumer_preference cp ON cp.Consumer_ID = c.Consumer_ID
)
SELECT 
    -- Check if preference matches or not
    CASE 
        WHEN Preferred_Cuisine = Cuisine THEN 'Match'
        ELSE 'No Match'
    END AS preference_match,
    COUNT(*) AS total_ratings,
    AVG(Overall_Rating) AS avg_rating
FROM preference_matches
GROUP BY 
    CASE 
        WHEN Preferred_Cuisine = Cuisine THEN 'Match'
        ELSE 'No Match'
    END;


-- 1.3 Which cuisines get higher ratings when it matches consumer preference?
-- Compare ratings when restaurant matches vs doesn't match consumer's favorite food

-- See match vs no-match ratings for each cuisine
SELECT 
    cp.Preferred_Cuisine AS cuisine,
    COUNT(*) AS total_ratings,
    ROUND(AVG(rt.Overall_Rating), 2) AS avg_overall_rating,
    -- Match ratings
    ROUND(AVG(CASE WHEN rc.Cuisine = cp.Preferred_Cuisine THEN rt.Overall_Rating END), 2) AS avg_when_match,
    -- No match ratings  
    ROUND(AVG(CASE WHEN rc.Cuisine != cp.Preferred_Cuisine THEN rt.Overall_Rating END), 2) AS avg_when_no_match
FROM ratings rt
JOIN consumers c ON rt.Consumer_ID = c.Consumer_ID
JOIN resturant_cuisines rc ON rt.Resturant_ID = rc.Resturant_ID
JOIN consumer_preference cp ON c.Consumer_ID = cp.Consumer_ID
GROUP BY cp.Preferred_Cuisine
HAVING COUNT(*) >= 20
ORDER BY avg_when_match DESC;



-- CONSUMER DEMOGRAPHICS & BIAS

-- 2.1 Age distribution
SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 24 THEN '18-24 (Young Adult)'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34 (Early Career)'
        WHEN Age BETWEEN 35 AND 50 THEN '35-50 (Mid Career)'
        WHEN Age > 50 THEN '50+ (Senior)'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS consumer_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM consumers WHERE Age IS NOT NULL), 1) AS percentage
FROM consumers
WHERE Age IS NOT NULL
GROUP BY age_group
ORDER BY MIN(Age);


-- 2.2 Occupation breakdown
SELECT 
    Occupation,
    COUNT(*) AS consumer_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM consumers WHERE Occupation IS NOT NULL), 1) AS percentage
FROM consumers
WHERE Occupation IS NOT NULL
GROUP BY Occupation
ORDER BY consumer_count DESC;


-- 2.3 Budget distribution
SELECT 
    Budget,
    COUNT(*) AS consumer_count,
    ROUND(AVG(Age), 1) AS avg_age,
    COUNT(DISTINCT Occupation) AS num_occupations,
    MIN(Occupation) AS example_occupation
FROM consumers
WHERE Budget IS NOT NULL
GROUP BY Budget
ORDER BY CASE Budget 
    WHEN 'Low' THEN 1 
    WHEN 'Medium' THEN 2 
    WHEN 'High' THEN 3 
    ELSE 4 
END;


-- 2.4 Geographic distribution
SELECT 
    City,
    State,
    COUNT(*) AS consumer_count,
    COUNT(DISTINCT Consumer_ID) AS unique_consumers
FROM consumers
GROUP BY City, State
ORDER BY consumer_count DESC;



-- 2.5 BIAS ANALYSIS: Compare sample to expected population
-- Check if our data has too many students or low-budget people

SELECT 
    -- Calculate average age
    ROUND(AVG(Age), 1) AS avg_age,
    
    -- Calculate percentage of students
    ROUND(100.0 * SUM(CASE WHEN Occupation = 'Student' THEN 1 ELSE 0 END) / COUNT(*), 1) AS student_percentage,
    
    -- Calculate percentage of low budget
    ROUND(100.0 * SUM(CASE WHEN Budget = 'Low' THEN 1 ELSE 0 END) / COUNT(*), 1) AS low_budget_percentage,
    
    -- Total number of people
    COUNT(*) AS total_consumers,
    
    -- Check if we have too many students
    CASE 
        WHEN SUM(CASE WHEN Occupation = 'Student' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 60 
            THEN 'HIGH STUDENT BIAS - Results skewed toward student preferences'
        WHEN SUM(CASE WHEN Occupation = 'Student' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 40 
            THEN 'MODERATE STUDENT BIAS'
        ELSE 'REPRESENTATIVE SAMPLE'
    END AS bias_assessment
    
FROM consumers
WHERE Age IS NOT NULL AND Occupation IS NOT NULL;





-- Q3: DEMAND & SUPPLY GAP ANALYSIS

-- 3.1 Consumer preferences (DEMAND)
-- Find which cuisines have high demand but low supply

SELECT 
    cp.Preferred_Cuisine AS cuisine,
    COUNT(DISTINCT cp.Consumer_ID) AS consumers_who_want_it,
    COUNT(DISTINCT rc.Resturant_ID) AS resturants_that_serve_it,
    
    -- Ratio (more consumers per restaurant = better opportunity)
    ROUND(COUNT(DISTINCT cp.Consumer_ID) * 1.0 / 
          NULLIF(COUNT(DISTINCT rc.Resturant_ID), 0), 1) AS consumers_per_resturant,
    
    -- Opportunity level
    CASE 
        WHEN COUNT(DISTINCT rc.Resturant_ID) = 0 THEN 'CRITICAL GAP - Open a restaurant!'
        WHEN COUNT(DISTINCT cp.Consumer_ID) * 1.0 / COUNT(DISTINCT rc.Resturant_ID) > 50 THEN 'HIGH OPPORTUNITY'
        WHEN COUNT(DISTINCT cp.Consumer_ID) * 1.0 / COUNT(DISTINCT rc.Resturant_ID) > 20 THEN 'GOOD OPPORTUNITY'
        ELSE 'MARKET IS SATURATED'
    END AS opportunity_level
    
FROM consumer_preference cp
LEFT JOIN resturant_cuisines rc ON cp.Preferred_Cuisine = rc.Cuisine
GROUP BY cp.Preferred_Cuisine
HAVING COUNT(DISTINCT cp.Consumer_ID) >= 5
ORDER BY consumers_per_resturant DESC;



-- 3.2 City-level gap analysis
-- Find which cities have high demand but low supply for specific cuisines

SELECT 
    c.City,
    cp.Preferred_Cuisine,
    COUNT(DISTINCT c.Consumer_ID) AS demand_count,
    COUNT(DISTINCT r.Resturant_ID) AS supply_count,
    
    -- Calculate gap (more demand than supply = opportunity)
    COUNT(DISTINCT c.Consumer_ID) - COUNT(DISTINCT r.Resturant_ID) AS gap_size,
    
    -- Easy-to-understand gap severity
    CASE 
        WHEN COUNT(DISTINCT r.Resturant_ID) = 0 THEN 'UNMET DEMAND - No restaurants'
        WHEN COUNT(DISTINCT c.Consumer_ID) > COUNT(DISTINCT r.Resturant_ID) * 10 THEN 'SEVERE SHORTAGE'
        WHEN COUNT(DISTINCT c.Consumer_ID) > COUNT(DISTINCT r.Resturant_ID) * 5 THEN 'MODERATE SHORTAGE'
        ELSE 'BALANCED'
    END AS gap_severity
    
FROM consumers c
JOIN consumer_preference cp ON c.Consumer_ID = cp.Consumer_ID
LEFT JOIN resturants r ON c.City = r.City
LEFT JOIN resturant_cuisines rc ON r.Resturant_ID = rc.Resturant_ID AND cp.Preferred_Cuisine = rc.Cuisine
GROUP BY c.City, cp.Preferred_Cuisine
HAVING COUNT(DISTINCT c.Consumer_ID) >= 3
ORDER BY gap_size DESC
LIMIT 30;



-- 3.3 Price point gaps
-- See how many people with different budgets want each cuisine

SELECT 
    cp.Preferred_Cuisine AS cuisine,
    c.Budget,
    COUNT(*) AS number_of_consumers,
    
    -- What budget level means for spending
    CASE 
        WHEN c.Budget = 'Low' THEN 'Price Sensitive'
        WHEN c.Budget = 'Medium' THEN 'Moderate Spender'
        WHEN c.Budget = 'High' THEN 'Premium Seeker'
        ELSE 'Unknown'
    END AS spending_segment
    
FROM consumer_preference cp
JOIN consumers c ON cp.Consumer_ID = c.Consumer_ID
GROUP BY cp.Preferred_Cuisine, c.Budget
HAVING COUNT(*) >= 5
ORDER BY cp.Preferred_Cuisine, 
         CASE c.Budget 
             WHEN 'High' THEN 1 
             WHEN 'Medium' THEN 2 
             WHEN 'Low' THEN 3 
             ELSE 4 
         END;


SELECT * FROM resturants;

-- Q4: INVESTMENT CHARACTERISTICS

-- Query 1: Best price level
SELECT 
	rt.Name,
    rt.Price,
    ROUND(AVG(r.Overall_Rating), 2) AS avg_rating,
    COUNT(*) AS num_ratings
FROM resturants rt
JOIN ratings r ON rt.Resturant_ID = r.Resturant_ID
GROUP BY rt.Price, rt.Name
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;

-- Query 2: Best alcohol service
SELECT 
	rt.Name,
    rt.Alcohol_Service,
    ROUND(AVG(r.Overall_Rating), 2) AS avg_rating,
    COUNT(*) AS num_ratings
FROM resturants rt
JOIN ratings r ON rt.Resturant_ID = r.Resturant_ID
GROUP BY rt.Alcohol_Service, rt.Name
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;

-- Query 3: Best parking option
SELECT 
	rt.Name,
    rt.Parking,
    ROUND(AVG(r.Overall_Rating), 2) AS avg_rating,
    COUNT(*) AS num_ratings
FROM resturants rt
JOIN ratings r ON rt.Resturant_ID = r.Resturant_ID
GROUP BY rt.Parking, rt.Name
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;

-- Query 4: Franchise vs independent
SELECT 
	rt.Name,
    rt.Franchise,
    ROUND(AVG(r.Overall_Rating), 2) AS avg_rating,
    COUNT(*) AS num_ratings
FROM resturants rt
JOIN ratings r ON rt.Resturant_ID = r.Resturant_ID
GROUP BY rt.Franchise, rt.Name
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;

-- Query 5: Smoking allowed vs not
SELECT 
	rt.Name,
    rt.Smoking_Allowed,
    ROUND(AVG(r.Overall_Rating), 2) AS avg_rating,
    COUNT(*) AS num_ratings
FROM resturants rt
JOIN ratings r ON rt.Resturant_ID = r.Resturant_ID
GROUP BY rt.Smoking_Allowed, rt.Name
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;


-- 4.1 Best performing restaurant attributes
-- Find which combinations of features get the best ratings

SELECT 
	rt.Name,
    rt.Price,
    rt.Alcohol_Service,
    rt.Parking,
    rt.Franchise,
    rt.Smoking_Allowed,
    COUNT(DISTINCT rt.Resturant_ID) AS num_restaurants,
    COUNT(r.Overall_Rating) AS total_ratings,
    ROUND(AVG(r.Overall_Rating), 2) AS avg_rating,
    ROUND(AVG(r.Food_Rating), 2) AS avg_food_rating,
    ROUND(AVG(r.Service_Rating), 2) AS avg_service_rating
FROM resturants rt
JOIN ratings r ON rt.Resturant_ID = r.Resturant_ID
GROUP BY rt.Price, rt.Alcohol_Service, rt.Parking, rt.Franchise, rt.Smoking_Allowed, rt.Name
HAVING COUNT(r.Overall_Rating) >= 20
ORDER BY avg_rating DESC
LIMIT 10;



-- 4.2 Best performing cuisines for investment
-- Find which cuisine types get the best ratings

SELECT 
    rc.Cuisine,
    COUNT(DISTINCT rc.Resturant_ID) AS num_restaurants,
    COUNT(rat.Overall_Rating) AS total_ratings,
    ROUND(AVG(rat.Overall_Rating), 2) AS avg_rating,
    ROUND(AVG(rat.Food_Rating), 2) AS avg_food_rating,
    ROUND(AVG(rat.Service_Rating), 2) AS avg_service_rating
FROM resturant_cuisines rc
JOIN ratings rat ON rc.Resturant_ID = rat.Resturant_ID
GROUP BY rc.Cuisine
HAVING COUNT(DISTINCT rc.Resturant_ID) >= 3 
   AND COUNT(rat.Overall_Rating) >= 30
ORDER BY avg_rating DESC
LIMIT 15;



-- 4.3 Top restaurant investment recommendations
-- Find the best restaurants to invest in based on ratings and customer loyalty

-- Top rated restaurants with enough reviews
SELECT 
    rt.Name,
    rt.City,
    ROUND(AVG(rat.Overall_Rating), 2) AS avg_rating,
    COUNT(rat.Overall_Rating) AS num_reviews
FROM resturants rt
JOIN ratings rat ON rt.Resturant_ID = rat.Resturant_ID
GROUP BY rt.Resturant_ID, rt.Name, rt.City
HAVING COUNT(rat.Overall_Rating) >= 10
ORDER BY avg_rating DESC
LIMIT 10;


-- 4.4 Investment Recommendation Score
-- Combine multiple factors into one score
SELECT 
    rt.Name,
    rt.City,
    rc.Cuisine,
    ROUND(AVG(rat.Overall_Rating), 2) AS avg_rating,
    COUNT(rat.Overall_Rating) AS num_reviews,
    COUNT(DISTINCT rat.Consumer_ID) AS unique_customers,
    
    -- Investment Score (0-100)
    ROUND(
        (AVG(rat.Overall_Rating) * 25) +           -- Rating quality (max 75)
        (CASE WHEN COUNT(rat.Overall_Rating) > 50 THEN 10 ELSE 0 END) +  -- Popularity
        (CASE WHEN COUNT(DISTINCT rat.Consumer_ID) > 20 THEN 10 ELSE 0 END) + -- Customer base
        (CASE WHEN rt.Price = 'Medium' THEN 5 ELSE 0 END),  -- Optimal price point
    1) AS investment_score,
    
    -- Recommendation
    CASE 
        WHEN AVG(rat.Overall_Rating) >= 2.5 AND COUNT(rat.Overall_Rating) >= 30 
            THEN 'STRONG BUY'
        WHEN AVG(rat.Overall_Rating) >= 2.0 AND COUNT(rat.Overall_Rating) >= 20 
            THEN 'CONSIDER'
        ELSE 'HOLD'
    END AS recommendation
    
FROM resturants rt
JOIN ratings rat ON rt.Resturant_ID = rat.Resturant_ID
JOIN resturant_cuisines rc ON rt.Resturant_ID = rc.Resturant_ID
GROUP BY rt.Resturant_ID, rt.Name, rt.City, rc.Cuisine, rt.Price
HAVING COUNT(rat.Overall_Rating) >= 10
ORDER BY investment_score DESC
LIMIT 20;






-- EXECUTIVE SUMMARY - Key Metrics
-- =============================================
-- Create a temporary table to hold the results
CREATE TEMP TABLE executive_summary AS
SELECT 'Total Consumers' AS metric, 
       COUNT(DISTINCT Consumer_ID)::TEXT AS value 
FROM consumers

UNION ALL

SELECT 'Total Restaurants', 
       COUNT(DISTINCT Resturant_ID)::TEXT 
FROM resturants

UNION ALL

SELECT 'Total Ratings', 
       COUNT(*)::TEXT 
FROM ratings

UNION ALL

SELECT 'Average Overall Rating', 
       ROUND(AVG(Overall_Rating), 2)::TEXT 
FROM ratings

UNION ALL

SELECT 'Unique Cuisines (Demand)', 
       COUNT(DISTINCT Preferred_Cuisine)::TEXT 
FROM consumer_preference

UNION ALL

SELECT 'Unique Cuisines (Supply)', 
       COUNT(DISTINCT Cuisine)::TEXT 
FROM resturant_cuisines

UNION ALL

SELECT 'Consumer Age Range', 
       MIN(Age)::TEXT || ' - ' || MAX(Age)::TEXT 
FROM consumers 
WHERE Age IS NOT NULL

UNION ALL

SELECT '% Students in Sample', 
       ROUND(100.0 * SUM(CASE WHEN Occupation = 'Student' THEN 1 ELSE 0 END) / COUNT(*), 1)::TEXT 
FROM consumers

UNION ALL

SELECT 'Top City', 
       (SELECT City 
        FROM consumers 
        GROUP BY City 
        ORDER BY COUNT(*) DESC 
        LIMIT 1)::TEXT;

-- Display the summary
SELECT * FROM executive_summary;

-- Optional: Format as a single row for presentation
SELECT 
    MAX(CASE WHEN metric = 'Total Consumers' THEN value END) AS total_consumers,
    MAX(CASE WHEN metric = 'Total Restaurants' THEN value END) AS total_restaurants,
    MAX(CASE WHEN metric = 'Total Ratings' THEN value END) AS total_ratings,
    MAX(CASE WHEN metric = 'Average Overall Rating' THEN value END) AS avg_rating,
    MAX(CASE WHEN metric = 'Consumer Age Range' THEN value END) AS age_range,
    MAX(CASE WHEN metric = '% Students in Sample' THEN value END) AS student_pct,
    MAX(CASE WHEN metric = 'Top City' THEN value END) AS top_city
FROM executive_summary;
