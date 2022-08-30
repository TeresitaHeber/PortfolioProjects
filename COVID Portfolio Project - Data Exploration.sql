/* Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Select Data that we are going to be starting with

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Total deaths vs Total cases
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, (CAST(total_cases AS UNSIGNED)) AS TotalCases
, CAST(total_deaths AS UNSIGNED) AS TotalDeaths
, ((CAST(total_deaths AS UNSIGNED))/(CAST(total_cases AS UNSIGNED)))*100 AS DeathPercentage
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
-- AND location LIKE 'Argentina'
ORDER BY 1, 2;


-- Total cases vs population 
-- Shows what percentage of population infected with Covid

SELECT location, date, population, (CAST(total_cases AS UNSIGNED)) AS TotalCases
, (SUM((CAST(total_cases AS UNSIGNED))/population))*100 AS PercentPopulationInfected
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Countries with highest infection rate compared to population

SELECT location, population, MAX(CAST(total_cases AS UNSIGNED)) AS HighestInfectionCount
, (MAX((CAST(total_cases AS UNSIGNED))/population))*100 AS PercentPopulationInfected
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Continents with highest death count per population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeathscsv
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- OR

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global numbers: Total cases 

SELECT date, SUM(new_cases) AS TotalCases
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Global numbers: Total deaths

SELECT date, SUM(CAST(new_deaths AS UNSIGNED)) AS TotalDeaths
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Global numbers: Death percentage

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS UNSIGNED)) AS TotalDeaths
, ((SUM(CAST(new_deaths AS UNSIGNED)))/(SUM(new_cases)))*100 AS DeathPercentage
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
ORDER BY 1, 2;
