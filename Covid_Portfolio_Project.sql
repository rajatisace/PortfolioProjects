select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select the data that we are going to be using 

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

--Total cases vs Total Deaths
-- Shows likelihood of dying if you contract in USA
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%state%'
and continent is not null
order by 1,2

--Looking at Toatl Cases vs Polpulation
--Shows what percentage of population got Covid
select location,date,total_cases,population,(total_cases/population)*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%state%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%state%'
Group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
Group by location
order by TotalDeathCount desc


--total death By Continent

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is null
Group by location
order by TotalDeathCount desc


--Showing continents with highest death count per population
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent,location,date,Population,New_Vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated