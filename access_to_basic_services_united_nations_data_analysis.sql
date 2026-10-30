/* ============================================================
   SCRIPT 1: UNITED NATIONS BASIC SERVICES AND ECONOMIC INDICATORS

   Purpose:
   Organizes country-level geographic, economic and basic
   services data into related tables and performs analyses
   involving unemployment, land area, GDP, population, drinking
   water services and sanitation services.

   SQL concepts:
   CREATE TABLE, INSERT INTO, SELECT, JOIN, IFNULL, UNION,
   aggregate functions, subqueries, CTEs and CREATE VIEW.
   ============================================================ */


/* 1. Creating a Geographic Location Table - to store each country's geographic information,
   including its sub-region, region and land area.*/
CREATE TABLE Geographic_Location(
	Country_name VARCHAR(37) PRIMARY KEY,
    Sub_Region VARCHAR(25),
    Region VARCHAR(32),
    Land_area NUMERIC(10,2)
);
  
/*2. Inserting data into Geographic Location Table*/
INSERT INTO Geographic_location(Country_name,Sub_Region,Region,Land_area)
SELECT
		Country_name,
        Sub_region,
        Region,
        AVG(Land_area) AS Country_Area
FROM access_to_basic_services
GROUP BY Country_name,Sub_region,Region;

/*3. Creating a Basic services table - containing country-level drinking water and
   sanitation service percentages for each time period.*/
   
CREATE TABLE united_nations.Basic_Services (
	Country_name VARCHAR(37) ,
    Time_period INTEGER,
    Pct_managed_drinking_water_services NUMERIC(5,2),
    Pct_managed_sanitation_services NUMERIC(5,2),
    PRIMARY KEY(Country_name, Time_period),
    FOREIGN KEY (Country_name) REFERENCES Geographic_location(Country_name)
);

/*4. Inserting relevant data into Basic.services table*/
INSERT INTO Basic_services(Country_name,Time_period,Pct_managed_drinking_water_services,Pct_managed_sanitation_services)
SELECT
		Country_name,
		Time_period,
        Pct_managed_drinking_water_services,
        Pct_managed_sanitation_services
FROM access_to_basic_services;

/*5. Creating Economic_indicators Table -  a table containing GDP, population and unemployment
   estimates for each country and time period. */
CREATE TABLE united_nations.Economic_indicators (
	Country_name VARCHAR(37) ,
    Time_period INTEGER,
    Est_gdp_in_billions NUMERIC(8,2),
    Est_population_in_millions NUMERIC(11,6),
    Pct_unemployment NUMERIC(5,2),
    PRIMARY KEY(Country_name, Time_period),
    FOREIGN KEY (Country_name) REFERENCES Geographic_location(Country_name)
);

 /*6. Inserting relevant data into Economic_indicators table*/
 INSERT INTO Economic_indicators(Country_name,Time_period,Est_gdp_in_billions,Est_population_in_millions,Pct_unemployment)
 SELECT
		Country_name,
 		Time_period,
		Est_gdp_in_billions,
        Est_population_in_millions,
        Pct_unemployment
FROM access_to_basic_services;

/*7. Joining Geographic, Economic and Basic Services Data. Combining the geographic information with economic indicators
   and basic services information.
   LEFT JOIN retains geographic records even when matching
   economic or service records are unavailable.
   The services table is matched using both country and year.*/
SELECT
*
FROM Geographic_location as geo
LEFT JOIN economic_indicators as econ
ON geo.Country_name = econ.Country_name
LEFT JOIN basic_services as svc
ON geo.Country_name = svc.Country_name
AND econ.Time_period = svc.Time_period;


/*8. Using Sub_queries to Handle Missing Unemployment Values*/
SELECT
	geo.Country_name,
    econ.Time_period,
    IFNULL(econ.pct_unemployment, 19.59) AS Pct_unemployment_imputed
FROM Geographic_location as geo
LEFT JOIN economic_indicators as econ
ON geo.Country_name = econ.Country_name
WHERE Region Like '%Central and Southern Asia%';

/*9. Imputing Unemployment Values Across Regions
   Uses UNION to combine results for seven geographic regions.
   Each SELECT replaces missing unemployment values with the
   specified value for that region.
   UNION removes duplicate rows across the combined results. */
SELECT
	loc.Country_name,
	eco.Time_period,
	IFNULL(eco.Pct_unemployment, 19.59) as Pct_unemployment_imputed
FROM
	united_nations.Geographic_Location as loc
LEFT JOIN
	united_nations.Economic_Indicators as eco
	ON eco.Country_name = loc.Country_name
WHERE REGION LIKE '%Central and Southern Asia%'

UNION

SELECT
	loc.Country_name,
	eco.Time_period,
	IFNULL(eco.Pct_unemployment, 22.64) as Pct_unemployment_imputed
FROM
	united_nations.Geographic_Location as loc
LEFT JOIN
	united_nations.Economic_Indicators as eco
	ON eco.Country_name = loc.Country_name
WHERE REGION LIKE '%Eastern and South-Eastern Asia%'

UNION

SELECT
	loc.Country_name,
	eco.Time_period,
	IFNULL(eco.Pct_unemployment, 24.43) as Pct_unemployment_imputed
FROM united_nations.Geographic_Location as loc
LEFT JOIN
	united_nations.Economic_Indicators as eco
	ON eco.Country_name = loc.Country_name
WHERE REGION LIKE '%Europe and Northern America%'

UNION

SELECT
	loc.Country_name,
	eco.Time_period,
	IFNULL(eco.Pct_unemployment, 24.23) as Pct_unemployment_imputed
FROM united_nations.Geographic_Location as loc
LEFT JOIN
	united_nations.Economic_Indicators as eco
	ON eco.Country_name = loc.Country_name
WHERE REGION LIKE '%Latin America and the Caribbean%'

UNION

SELECT
	loc.Country_name,
	eco.Time_period,
	IFNULL(eco.Pct_unemployment, 17.84) as Pct_unemployment_imputed
FROM
	united_nations.Geographic_Location as loc
LEFT JOIN
	united_nations.Economic_Indicators as eco
	ON eco.Country_name = loc.Country_name
WHERE REGION LIKE '%Northern Africa and Western Asia%'

UNION

SELECT
	loc.Country_name,
	eco.Time_period,
	IFNULL(eco.Pct_unemployment, 4.98) as Pct_unemployment_imputed
FROM
	united_nations.Geographic_Location as loc
LEFT JOIN
	united_nations.Economic_Indicators as eco
	ON eco.Country_name = loc.Country_name
WHERE REGION LIKE '%Oceania%'

UNION

SELECT
	loc.Country_name,
	eco.Time_period,
	IFNULL(eco.Pct_unemployment, 33.65) as Pct_unemployment_imputed
FROM
	united_nations.Geographic_Location as loc
LEFT JOIN united_nations.Economic_Indicators as eco
	ON eco.Country_name = loc.Country_name
WHERE REGION LIKE '%Sub-Saharan Africa%';


/*10. Calculating Each Country's Percentage of Regional Land
   Using a correlated subquery to calculate the total land area
   for the country's sub-region, then dividing the country's land area by that sub-regional total
   and multiplying by 100 to obtain its percentage contribution. The resulting percentage rounded to a whole number.*/
SELECT
	Country_name,
	ROUND(Land_area /(SELECT
						SUM(Land_area)
                        FROM Geographic_location
                        WHERE Sub_region = geo.sub_region
                      )*100) AS pct_regional_land
FROM Geographic_location as geo;

/* 11. Calculating Total Land Area by Sub-region.*/
SELECT
	sub_region,
    SUM(Land_area) AS Total_land_area
FROM Geographic_location
GROUP BY Sub_region;

/* 12. Calculating Regional Land Percentages Using a Derived Table
   The subquery calculates the total land area for each sub-region.
   The outer query joins these totals to individual countries.
   It then calculates each country's percentage of its sub-region's
   total land area. */
SELECT
	geo.country_name,
    geo.land_area,
    geo.sub_region,
    (geo.Land_area/land_per_region.TotalLandArea) * 100 AS Pct_Region_Land
FROM Geographic_location AS geo
JOIN (SELECT
		sub_region,
		SUM(Land_area) AS Totallandarea
	FROM Geographic_location
	GROUP BY Sub_region) AS land_per_region
ON 
geo.sub_region = land_per_region.sub_region;

/*13. Calculating Average GDP and Population for select countries, year 2020 and with unemployment above 5%.*/ 
SELECT
	Country_name,
    AVG(Est_gdp_in_billions) AS Avg_GDP,
    AVG(Est_population_in_millions) AS Avg_Population
FROM
	(SELECT
		Country_name,
		Est_gdp_in_billions,
		Est_population_in_millions
    FROM economic_indicators
    WHERE Pct_unemployment > 5
    AND Time_period = 2020) AS FilteredCountries
GROUP BY 
	Country_name;

/* 14. Calculating the Average GDP for 2020
   This value can be used as a benchmark when comparing countries. */
SELECT
	AVG(Est_gdp_in_billions)
FROM economic_indicators
WHERE Time_period = 2020;

/* 15. Identifying Countries with Below-90% Drinking Water
   and Above-Average GDP.
   Joins economic indicators to basic services using country and year.
   Filters for 2020 records where drinking water service coverage
   is below 90% and GDP exceeds the average GDP for 2020.*/
SELECT
	econ.Country_name,
    econ.Time_period,
    econ.Est_gdp_in_billions,
    service.Pct_managed_drinking_water_services
FROM 
	Economic_indicators AS econ
INNER JOIN 
	Basic_services AS service
ON 
	econ.Country_name = service.Country_name
	AND econ.Time_period = service.Time_period
WHERE 
	econ.Time_period = 2020
	AND service.Pct_managed_drinking_water_services < 90
	AND econ.Est_gdp_in_billions > (SELECT
										AVG(Est_gdp_in_billions)
									FROM economic_indicators
									WHERE Time_period = 2020);

/*Using Common Table Expressions (CTEs).*/
/*16. Comparing a Subquery with a CTE.*/

/*First example is a subquery.
   Calculates average GDP for each region using a window function.
   Filters the source data to Sub-Saharan African countries in 2020
   with drinking water service coverage below 60%.
   The outer query returns countries whose GDP is below their
   region's calculated average. */

SELECT *
FROM(
	SELECT
		Region,
		Country_name,
		Pct_managed_drinking_water_services,
		Pct_managed_sanitation_services,
		Est_gdp_in_billions,
		AVG(Est_gdp_in_billions) OVER(PARTITION BY Region) AS Avg_gdp_for_region
	FROM access_to_basic_services
	WHERE Region = 'Sub-Saharan Africa'
		AND Time_period = 2020
		AND Pct_managed_drinking_water_services < 60
      ) AS Regional_comparison
WHERE Est_gdp_in_billions < Avg_gdp_for_region;

/* Performing the Same Regional Comparison Using a CTE.
   This example is a CTE.
   It defines Regional_Avg_GDP as a temporary named result set and calculates average GDP using the same filters and
   window function as the preceding subquery.
   The final SELECT returns countries whose GDP is below the
   calculated regional average. */

WITH Regional_Avg_GDP AS (
	SELECT
		Region,
		Country_name,
		Pct_managed_drinking_water_services,
		Pct_managed_sanitation_services,
		Est_gdp_in_billions,
		AVG(Est_gdp_in_billions) OVER(PARTITION BY Region) AS Avg_gdp_for_region
	FROM access_to_basic_services
	WHERE Region = 'Sub-Saharan Africa'
		AND Time_period = 2020
		AND Pct_managed_drinking_water_services < 60
)
SELECT *
FROM Regional_Avg_GDP
WHERE Est_gdp_in_billions < Avg_gdp_for_region;

/*17. Creating Views. 
Creating a view containing countries in Sub-Saharan
   Africa, their time periods and unemployment values.*/
CREATE VIEW united_nations.Country_unemployment_rate AS
SELECT
	loc.Country_name,
    eco.Time_period,
	IFNULL(eco.Pct_unemployment, 33.65) as Pct_unemployment_imputed
FROM
	united_nations.Geographic_Location as loc
LEFT JOIN united_nations.Economic_Indicators as eco
	ON eco.Country_name = loc.Country_name
WHERE REGION = 'Sub-Saharan Africa';

/* 18. Retrieving the View's Results.*/
SELECT *
FROM country_unemployment_rate;