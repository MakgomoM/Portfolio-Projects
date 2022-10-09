/* 
Queries used for Tableau Project

*/

--1
SELECT SUM(new_cases ) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases ))*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
--WHERE location like '%africa%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2
GO

--2
SELECT location, SUM(cast(new_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
--WHERE location like '%africa%'
WHERE continent IS NULL
AND location NOT IN ('World','European Union','International')
GROUP BY location
ORDER BY Total_Death_Count DESC
GO

--3
SELECT Location, population,MAX(total_cases) AS Highest_Infection_Count,
		MAX((total_cases/population))*100 AS Percentage_PopulationInfected
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
--WHERE location like '%africa%'
GROUP BY location, population
ORDER BY Percentage_PopulationInfected DESC
GO

--4
SELECT location, Population,date,MAX(total_cases) AS Highest_Infection_Count,MAX((total_cases/population))*100 AS Percentage_PopulationInfected
FROM PortfolioProject..CovidDeaths WITH (NOLOCK)
----WHERE location like '%africa%'
GROUP BY location,Population,date
ORDER BY Percentage_PopulationInfected DESC
GO