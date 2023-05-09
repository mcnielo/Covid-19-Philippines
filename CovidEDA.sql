-- Database: Portfolio Project

-- DROP DATABASE IF EXISTS "Portfolio Project";

CREATE DATABASE "Portfolio Project"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_Philippines.1252'
    LC_CTYPE = 'English_Philippines.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


-- Creating CovidDeaths table in PostgreSQL

CREATE TABLE CovidDeaths (
  iso_code VARCHAR(10),
  continent VARCHAR(20),
  location VARCHAR(50),
  date DATE,
  population FLOAT,
  total_cases FLOAT,
  new_cases FLOAT,
  new_cases_smoothed FLOAT,
  total_deaths FLOAT,
  new_deaths FLOAT,
  new_deaths_smoothed FLOAT,
  total_cases_per_million FLOAT,
  new_cases_per_million FLOAT,
  new_cases_smoothed_per_million FLOAT,
  total_deaths_per_million FLOAT,
  new_deaths_per_million FLOAT,
  new_deaths_smoothed_per_million FLOAT,
  reproduction_rate FLOAT,
  icu_patients FLOAT,
  icu_patients_per_million FLOAT,
  hosp_patients FLOAT,
  hosp_patients_per_million FLOAT,
  weekly_icu_admissions FLOAT,
  weekly_icu_admissions_per_million FLOAT,
  weekly_hosp_admissions FLOAT,
  weekly_hosp_admissions_per_million FLOAT
);


-- Importing CovidDeaths csv into PostgreSQL

COPY CovidDeaths 
FROM 'C:\Users\mcand\OneDrive\Desktop\Data Analyst Portfolio\SQL\COVID_DATA_EXPLORATION\CovidDeaths.csv'
DELIMITER ',' CSV HEADER;


-- Creating CovidVaccination table in PostgreSQL

CREATE TABLE CovidVaccination (
  iso_code varchar(10),
  continent varchar(50),
  location varchar(50),
  date date,
  total_tests FLOAT,
  new_tests FLOAT,
  total_tests_per_thousand numeric(10,3),
  new_tests_per_thousand numeric(10,3),
  new_tests_smoothed numeric(20,3),
  new_tests_smoothed_per_thousand numeric(20,3),
  positive_rate numeric(10,4),
  tests_per_case numeric(10,1),
  tests_units varchar(50),
  total_vaccinations FLOAT,
  people_vaccinated FLOAT,
  people_fully_vaccinated FLOAT,
  total_boosters FLOAT,
  new_vaccinations FLOAT,
  new_vaccinations_smoothed numeric(20,3),
  total_vaccinations_per_hundred numeric(10,3),
  people_vaccinated_per_hundred numeric(10,3),
  people_fully_vaccinated_per_hundred numeric(10,3),
  total_boosters_per_hundred numeric(10,3),
  new_vaccinations_smoothed_per_million numeric(20,3),
  new_people_vaccinated_smoothed FLOAT,
  new_people_vaccinated_smoothed_per_hundred numeric(10,3),
  stringency_index numeric(10,3),
  population_density numeric(20,3),
  median_age numeric(20,3),
  aged_65_older numeric(20,3),
  aged_70_older numeric(20,3),
  gdp_per_capita numeric(20,3),
  extreme_poverty numeric(20,3),
  cardiovasc_death_rate numeric(20,3),
  diabetes_prevalence numeric(20,3),
  female_smokers numeric(20,3),
  male_smokers numeric(20,3),
  handwashing_facilities numeric(20,3),
  hospital_beds_per_thousand numeric(20,3),
  life_expectancy numeric(20,3),
  human_development_index numeric(20,3),
  excess_mortality_cumulative_absolute numeric(20,3),
  excess_mortality_cumulative numeric(20,3),
  excess_mortality numeric(20,3),
  excess_mortality_cumulative_per_million numeric(20,3)
);

-- Importing CovidVaccination csv into PostgreSQL

COPY CovidVaccination
FROM 'C:\Users\mcand\OneDrive\Desktop\Data Analyst Portfolio\SQL\COVID_DATA_EXPLORATION\CovidVaccinations.csv'
DELIMITER ',' CSV HEADER;


-- Retrieve Covid-19 data from CovidDeaths table

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths order by 1,2;


-- Calculate the percentage of Covid deaths in the Philippines

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Philippines' AND continent IS NOT NULL
ORDER BY 1, 2;


-- Calculate the percentage of the population in the Philippines that contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location = 'Philippines' AND continent IS NOT NULL
ORDER BY 1, 2;


-- Find countries with the highest Covid infection rates compared to their population

SELECT location, population, MAX(total_cases) AS HighestInfectioncount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Find countries with the highest Covid death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Show continents with the highest Covid death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Calculate global Covid numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases <> 0
GROUP BY date
ORDER BY 1, 2;


-- Use a CTE to calculate percentage of population that has received at least one Covid vaccine

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac


--Creating view to store data later for visualization

CREATE VIEW PopvsVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
