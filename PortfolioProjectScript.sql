ALTER TABLE portfolio.covidvaccinations
MODIFY COLUMN new_vaccinations INT;
ALTER TABLE portfolio.coviddeaths
MODIFY COLUMN total_deaths INT;
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From Portfolio.CovidDeaths
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio.CovidDeaths
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio.CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Portfolio.CovidDeaths
-- Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio.CovidDeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From Portfolio.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From Portfolio.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From Portfolio.CovidDeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;


#rolling count

Select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations 
, sum(vac.new_vaccinations)
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated  
-- , (RollingPeopleVaccainated/Population)*100             
from portfolio.coviddeaths dea join portfolio.covidvaccinations vac
on dea.location = vac.location and dea.date =vac.date
where dea.continent is not null 
order by 2,3;

# in the table above we cannot use rollingpeoplevaccinated column as it was just made
# there are 2 options to do that which we are gonna see

# Using CTE

WITH PopvsVac (continent , location, date, population, New_Vaccinations ,RollingPeopleVaccinated)
as
(
Select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated  
-- ,  (RollingPeopleVaccainated/Population)*100             
from portfolio.coviddeaths dea join portfolio.covidvaccinations vac
on dea.location = vac.location and dea.date =vac.date
where dea.continent is not null 
-- order by 2,3
)
select * from popsvac;
# this method is not running in this computer

# temp table

drop table if exists PercentTablePopulationVaccination;
create table PercentTablePopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric );

insert into PercentTablePopulationVaccination
Select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated  
-- ,  (RollingPeopleVaccainated/Population)*100             
from portfolio.coviddeaths dea join portfolio.covidvaccinations vac
on dea.location = vac.location and dea.date =vac.date
where dea.continent is not null ;
-- order by 2,3
select *,(RollingPeopleVaccinated/Population) from PercentTablePopulationVaccination;

-- creating view to store data for later visualizations 
-- view is something so that we can use later 
-- most importantly it will help us connect table to tableau 
Create view PercentTablePopulationVaccinated as
Select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated  
-- ,  (RollingPeopleVaccainated/Population)*100             
from portfolio.coviddeaths dea join portfolio.covidvaccinations vac
on dea.location = vac.location and dea.date =vac.date
where dea.continent is not null ;
-- order by 2,3
 