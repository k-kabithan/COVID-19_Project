--SELECT *
--FROM PortfolioProject.dbo.covid_deaths
--WHERE continent is not null
--ORDER BY 3,4

------------------------------------------------------------Country numbers----------------------------------------------------------------

-- looking at total cases vs total deaths
-- shows the chances of dying from covid when infected in different countries
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
WHERE Location like '%kingdom%' --specifying country
and continent is not null
ORDER BY 1,2


-- looking at total cases vs population
-- shows percentage of population that were infected with covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM PortfolioProject.dbo.covid_deaths
WHERE Location like '%kingdom%'
ORDER BY 1,2


-- looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM PortfolioProject.dbo.covid_deaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY InfectedPopulationPercentage desc


------------------------------------------------------------Continent numbers--------------------------------------------------------------

-- showing the continents with highest to lowest death count
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- continents with the highest to lowest infections, and ratio with population
SELECT continent, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM PortfolioProject.dbo.covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY InfectedPopulationPercentage desc

-- number of total cases and deaths globally by day
SELECT continent, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
-- WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER BY 1,2

------------------------------------------------------------Global numbers-----------------------------------------------------------------

-- number of total cases and deaths globally by day
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
-- WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- total number of cases and deaths worldwide up til march 2022
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
-- WHERE Location like '%kingdom%'
WHERE continent is not null
ORDER BY 1,2

-- looking at total population vs vaccinated_pop
--join both vaccine and deaths tables
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS IncrementalVaccinated
FROM PortfolioProject.dbo.covid_deaths dea
JOIN PortfolioProject.dbo.covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date =  vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Making either temp table or using CTE to call back IncrementalVaccinated
-- to get percentage of population that is vaccinated
-- CTE easier to implement
-- Using CTE

WITH PopvsVac (continent, location, date, population, New_Vaccinations, IncrementalVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS IncrementalVaccinated
FROM PortfolioProject.dbo.covid_deaths dea
JOIN PortfolioProject.dbo.covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date =  vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (IncrementalVaccinated/population)*100 AS VaccPopPercentage
FROM PopvsVac

-- TEMP TABLE

IF OBJECT_ID('PercentPopVaccinated') IS NOT NULL
    DROP TABLE PercentPopVaccinated;
GO
CREATE TABLE PercentPopVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric, 
IncrementalVaccinated numeric
)

INSERT INTO PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS IncrementalVaccinated
FROM PortfolioProject.dbo.covid_deaths dea
JOIN PortfolioProject.dbo.covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date =  vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, (IncrementalVaccinated/population)*100 AS VaccPopPercentage
FROM PercentPopVaccinated


----------------- CREATING VIEWS to store data for later visualisations in Tableau ----------------------------

CREATE VIEW PercentagePopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS IncrementalVaccinated
FROM PortfolioProject.dbo.covid_deaths dea
JOIN PortfolioProject.dbo.covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date =  vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *
FROM PercentagePopVaccinated


