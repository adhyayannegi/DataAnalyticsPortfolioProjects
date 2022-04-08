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
--Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%india%'
order by 1,2



-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc,population

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

 --1 by continent (not as accurate)
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--2 by location (accurate) for tableau viz
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location in ('Europe', 'South America', 'North America','Asia','Oceania','Africa')
Group by location
order by TotalDeathCount desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select * from PortfolioProject..CovidVaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from
PortfolioProject..CovidDeaths dea inner join
PortfolioProject..CovidVaccinations vac on
dea.date=vac.date and dea.location=vac.location
where dea.continent is not null --and new_vaccinations is not null
order by 2,3

--Using CTE

WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated,Full_Vaccinations) as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
vac.people_fully_vaccinated
from
PortfolioProject..CovidDeaths dea inner join
PortfolioProject..CovidVaccinations vac on
dea.date=vac.date and dea.location=vac.location
where dea.continent is not null --and new_vaccinations is not null
--order by 2,3
)
select *,((RollingPeopleVaccinated/Population)*100) ,((Full_Vaccinations/Population)*100) from PopvsVac


--Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
Full_Vaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
vac.people_fully_vaccinated
from
PortfolioProject..CovidDeaths dea inner join
PortfolioProject..CovidVaccinations vac on
dea.date=vac.date and dea.location=vac.location
where dea.continent is not null --and new_vaccinations is not null

select *,((RollingPeopleVaccinated/Population)*100) as PercRollingPeopleVaccinated,
((Full_Vaccinations/Population)*100) as PercPeopleFullyVaccinated from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Drop View If Exists PercentPopulationVaccinated ;
Create View PercentPopulationVaccinated
as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
vac.people_fully_vaccinated as Full_Vaccinations
from
PortfolioProject..CovidDeaths dea inner join
PortfolioProject..CovidVaccinations vac on
dea.date=vac.date and dea.location=vac.location
where dea.continent is not null --and new_vaccinations is not null;

select *,((RollingPeopleVaccinated/Population)*100) as PercRollingPeopleVaccinated,
((Full_Vaccinations/Population)*100) as PercPeopleFullyVaccinated from PercentPopulationVaccinated;



Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
