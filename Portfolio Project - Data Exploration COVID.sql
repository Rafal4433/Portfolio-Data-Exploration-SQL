/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, Round((total_deaths/total_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'poland'
And total_cases is not	null	
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases, population, Round((total_cases/population)*100, 2) as CasesPercentage
From PortfolioProject..CovidDeaths
where location = 'poland'
And total_cases is not	null	
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, population, max(total_cases) as HighestInfectionCount, Round(Max(total_cases/population)*100, 2) as CasesPercentage
From PortfolioProject..CovidDeaths
Group by Location, population
order by CasesPercentage desc


-- Countries with Highest Death Count per Population
Select Location, population, max(total_deaths) as HighestDeathCount, Round(Max(total_deaths/population)*100, 2) as DeathPercentage
From PortfolioProject..CovidDeaths
Group by Location, population
order by DeathPercentage desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinations
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinations)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinations
	From PortfolioProject..covidDeaths dea
	Join PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
	where dea.continent is not null
)

Select *, (RollingPeopleVaccinations/Population)*100 as PercentOfVaccinationsPeople
From PopvsVac

-- Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinations numeric
)

Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinations
	From PortfolioProject..covidDeaths dea
	Join PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
	where dea.continent is not null

Select *, (RollingPeopleVaccinations/Population)*100 as PercentOfVaccinationsPeople
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinations
	From PortfolioProject..covidDeaths dea
	Join PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
	where dea.continent is not null
	)

select *
From PercentPopulationVaccinated