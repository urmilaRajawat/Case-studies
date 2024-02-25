select * FROM swiggy;
-- HOW MANY RESTAURANTS HAVE A RATING GREATER THAN 4.5?
SELECT Count(DISTINCT restaurant_no) AS High_rated_restaurant 
FROM swiggy
WHERE rating > 4.5;

-- WHICH IS THE TOP 1 CITY WITH THE HIGHEST NUMBER OF RESTAURANTS?
SELECT city, COUNT(DISTINCT restaurant_no) as restaurant_count
FROM swiggy
GROUP BY city
ORDER BY no_restaurant DESC
LIMIT 1;

-- HOW MANY RESTAURANTS HAVE THE WORD "PIZZA" IN THEIR NAME?
SELECT restaurant_name, COUNT(DISTINCT restaurant_no) AS restaurant_count
FROM swiggy
WHERE restaurant_name LIKE '%PIZZA%'
GROUP BY restaurant_name;

-- WHAT IS THE MOST COMMON CUISINE AMONG THE RESTAURANTS IN THE DATASET?
SELECT cuisine AS most_common_cuisine, COUNT(cuisine) AS cuisin_count
FROM swiggy
GROUP BY cuisine
ORDER BY COUNT(cuisine) DESC
LIMIT 1;

-- WHAT IS THE AVERAGE RATING OF RESTAURANTS IN EACH CITY?
SELECT city, ROUND(AVG(rating),2) AS avg_rating
FROM swiggy
GROUP BY city;

-- WHAT IS THE HIGHEST PRICE OF ITEM UNDER THE 'RECOMMENDED' MENU CATEGORY FOR EACH RESTAURANT?
SELECT restaurant_name, menu_category, MAX(price) AS Highest_price
FROM swiggy
WHERE menu_category = 'recommended'
GROUP BY restaurant_name,menu_category;

-- FIND THE TOP 5 MOST EXPENSIVE RESTAURANTS THAT OFFER CUISINE OTHER THAN INDIAN CUISINE.
SELECT DISTINCT restaurant_name, cost_per_person 
FROM swiggy
WHERE cuisine != 'Indian'
ORDER BY cost_per_person  DESC
LIMIT 5;

-- FIND THE RESTAURANTS THAT HAVE AN AVERAGE COST WHICH IS HIGHER THAN THE TOTAL AVERAGE COST OF ALL RESTAURANTS TOGETHER

SELECT DISTINCT restaurant_name, cost_per_person AS avg_cost
FROM swiggy 
WHERE cost_per_person > (SELECT AVG( cost_per_person) FROM swiggy)
ORDER BY avg_cost DESC;

-- RETRIEVE THE DETAILS OF RESTAURANTS THAT HAVE THE SAME NAME BUT ARE LOCATED IN DIFFERENT CITIES.
SELECT DISTINCT s1.restaurant_name, s1.city, s2.city
FROM swiggy s1
JOIN swiggy s2
ON s1.restaurant_name = s2.restaurant_name
AND s1.city != s2.city;

-- WHICH RESTAURANT OFFERS THE MOST NUMBER OF ITEMS IN THE 'MAIN COURSE' CATEGORY?
SELECT restaurant_name, COUNT(item) AS item_count
FROM swiggy
WHERE menu_category = 'main course'
GROUP BY restaurant_name
ORDER BY item_count DESC
LIMIT 1;

-- LIST THE NAMES OF RESTAURANTS THAT ARE 100% VEGEATARIAN IN ALPHABETICAL ORDER OF RESTAURANT NAME.
SELECT DISTINCT restaurant_name
FROM swiggy
WHERE veg_or_nonveg = 'veg'
ORDER BY restaurant_name;

-- WHICH IS THE RESTAURANT PROVIDING THE LOWEST AVERAGE PRICE FOR ALL ITEMS?
SELECT restaurant_name, AVG(price) AS avg_price
FROM swiggy
GROUP BY restaurant_name
ORDER BY avg_price LIMIT 1;

-- WHICH TOP 5 RESTAURANT OFFERS HIGHEST NUMBER OF CATEGORIES?
SELECT restaurant_name, COUNT(DISTINCT menu_category) as categ_count
FROM swiggy
GROUP BY restaurant_name
ORDER BY categ_count DESC 
LIMIT 5;

-- WHICH RESTAURANT PROVIDES THE HIGHEST PERCENTAGE OF NON-VEGEATARIAN FOOD?
SELECT restaurant_name, SUM(CASE WHEN veg_or_nonveg = 'non-veg' THEN 1 ELSE 0 END)*100/COUNT(*) AS nonveg_percent
FROM swiggy
GROUP BY restaurant_name
ORDER BY nonveg_percent DESC 
LIMIT 1;





