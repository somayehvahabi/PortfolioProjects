SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
-- Shows what persentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2



-- Looking at Countries with Highest Infection Rate compare to population


SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
   PercentpopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
GROUP by location, population
order by PercentpopulationInfected desc

-- Showing Countries with Highest Death Count per Population


SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP by location, population
order by TotalDeathCount desc


--LET'S BREAK THING DOWN BY CONTINENT


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as  total_deaths, SUM (cast
  (new_deaths as int))/SUM (New_cases)* 100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
--GROUP by date
order by 1,2


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
   dea.Date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac







--TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
   dea.Date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
   dea.Date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated