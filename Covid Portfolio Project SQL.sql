SELECT * 
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
WHERE continent IS NOT NULL
ORDER BY 3,4
GO

--SELECT *
--FROM PortfolioProject..CovidVaccinations WITH (NOLOCK)
--ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
ORDER BY 1,2
GO

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in Africa

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS Death_Precentage
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
WHERE location like '%africa%'
ORDER BY 1,2
GO

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location, date, total_cases, Population,(total_cases/population)*100 AS Death_Precentage
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
--WHERE location like '%africa%'
ORDER BY 1,2
GO

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population,MAX(total_cases) AS Highest_Infection_Count,
		MAX((total_cases/population))*100 AS Percentage_PopulationInfected
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
--WHERE location like '%africa%'
GROUP BY location, population
ORDER BY Percentage_PopulationInfected DESC
GO

--Showing countries with the Highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
--WHERE location like '%africa%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC
GO

--Showing continents with the Highest Death Count per population

SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
--WHERE location like '%africa%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC
GO

--Breaking Global Numbers 

SELECT SUM(new_cases ) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases ))*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
--WHERE location like '%africa%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2
GO

--Join the two tables of Covid_Deaths and Covid_Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea WITH (NOLOCK)
INNER JOIN PortfolioProject..CovidVaccinations AS vac WITH (NOLOCK)
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3
GO

--Looking at Total Population vs Vaccinations

WITH PopvsVac (continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date ) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/popultion)*100
FROM PortfolioProject..CovidDeaths AS dea WITH (NOLOCK)
 JOIN PortfolioProject..CovidVaccinations AS vac WITH (NOLOCK)
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopvsVac

--TEMP TABLE


DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date ) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/popultion)*100
FROM PortfolioProject..CovidDeaths AS dea WITH (NOLOCK)
 JOIN PortfolioProject..CovidVaccinations AS vac WITH (NOLOCK)
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *, (Rolling_People_Vaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date ) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/popultion)*100
FROM PortfolioProject..CovidDeaths AS dea WITH (NOLOCK)
 JOIN PortfolioProject..CovidVaccinations AS vac WITH (NOLOCK)
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated


















