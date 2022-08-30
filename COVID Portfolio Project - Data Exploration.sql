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

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global numbers: Total cases 

SELECT SUM(new_cases) AS GlobalTotalCases
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL;



-- Global numbers: Total deaths

SELECT SUM(CAST(new_deaths AS UNSIGNED)) AS GlobalTotalDeaths
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL;


-- Global numbers: Death percentage

SELECT SUM(new_cases) AS GlobalTotalCases, SUM(CAST(new_deaths AS UNSIGNED)) AS GlobalTotalDeaths
, ((SUM(CAST(new_deaths AS UNSIGNED)))/(SUM(new_cases)))*100 AS DeathPercentage
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Total Population vs Vaccinations (using CTE and Temp Table)
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathscsv AS dea
INNER JOIN portfolio_project.covidvaccinationscsv AS vac 
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathscsv AS dea
INNER JOIN portfolio_project.covidvaccinationscsv AS vac 
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated 
FROM PopvsVac
ORDER BY 2, 3;


-- Using Temp Table


DROP TABLE IF EXISTS PercentPeopleVaccinated;
CREATE TABLE PercentPeopleVaccinated (
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population INT,
new_vaccinations INT,
RollingPeopleVaccinated INT
);

INSERT INTO PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathscsv AS dea
INNER JOIN portfolio_project.covidvaccinationscsv AS vac 
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated 
FROM PercentPeopleVaccinated
ORDER BY 2, 3;


-- Creating Views

DROP VIEW IF EXISTS GlobalTotalCases;
CREATE VIEW GlobalTotalCases
AS
SELECT SUM(new_cases) AS GlobalTotalCases
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL;

DROP VIEW IF EXISTS GlobalTotalDeaths;
CREATE VIEW GlobalTotalDeaths
AS
SELECT SUM(CAST(new_deaths AS UNSIGNED)) AS GlobalTotalDeaths
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL;


CREATE VIEW GlobalDeathPercentaje
AS
SELECT SUM(new_cases) AS GlobalTotalCases, SUM(CAST(new_deaths AS UNSIGNED)) AS GlobalTotalDeaths
, ((SUM(CAST(new_deaths AS UNSIGNED)))/(SUM(new_cases)))*100 AS GlobalDeathPercentage
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
ORDER BY 1, 2;


CREATE VIEW PercentPopulationInfected
AS
SELECT location, date, population, (CAST(total_cases AS UNSIGNED)) AS TotalCases
, (SUM((CAST(total_cases AS UNSIGNED))/population))*100 AS PercentPopulationInfected
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
ORDER BY 1, 2;

CREATE VIEW HighestInfectionRatePerCountry
AS
SELECT location, population, MAX(CAST(total_cases AS UNSIGNED)) AS HighestInfectionCount
, (MAX((CAST(total_cases AS UNSIGNED))/population))*100 AS PercentPopulationInfected
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

CREATE VIEW HighestDeathRatePerCountry
AS
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeathscsv
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
