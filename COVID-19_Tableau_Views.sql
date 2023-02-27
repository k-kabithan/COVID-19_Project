-- first tableau table
-- total number of cases and deaths worldwide up til march 2022
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.covid_deaths
-- WHERE Location like '%kingdom%'
WHERE continent is not null
ORDER BY 1,2

-- second tableau table
-- total death count in each continent up til march 2022
SELECT location, SUM(cast(new_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.covid_deaths
WHERE continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount desc

-- third tableau table
-- looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM PortfolioProject.dbo.covid_deaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY InfectedPopulationPercentage desc

-- fourth tableau table

SELECT Location, population, date, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM PortfolioProject.dbo.covid_deaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
and location like '%china%'
GROUP BY Location, population, date
ORDER BY InfectedPopulationPercentage desc