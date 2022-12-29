Select *
from Portfolio_Project.dbo.CovidDeath
where continent is not null
order by 3,5

Select *
from Portfolio_Project.dbo.covidVaccinations
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project.dbo.CovidDeath
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location,  total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathPrecentage
from Portfolio_Project.dbo.CovidDeath
where location like '%states%'
and continent is not null
order by 1,2

--Looking at total cases vs population
--shows what population got covid
select date,location,  total_cases,  population, (total_cases/population)*100 as PrecentagePopulation Infected
from Portfolio_Project.dbo.CovidDeath
where location like '%states%'
and continent is not null
order by 2,3

--Looking at countries with highest infection rate as compared to population
select location, population, max(total_cases) as HighestInfectedCount, max((total_cases/population)*100) as PrecentagePopulationInfected
from Portfolio_Project.dbo.CovidDeath
--where location like 'India'
where continent is not null
group by location,population
order by PrecentagePopulationInfected desc

--showing countries with highest death count per population
select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project.dbo.CovidDeath
--where location like 'India'
where continent is not null
group by location,population
order by TotalDeathCount  desc

--LETS BREAK THINGS BY CONTINENT
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project.dbo.CovidDeath
--where location like 'India'
where continent is not null
group by continent
order by TotalDeathCount  desc

--showing continent with highest death per population
select continent, max(total_deaths/population) as DeathperPopulation 
from Portfolio_Project.dbo.CovidDeath
--where location like 'India'
where continent is not null
group by continent
order by DeathperPopulation desc

--GLOBAL NUMBERS
select sum(new_cases) as  totalcases,sum(cast(new_deaths as int)) as  totaldeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathPrecentage
from Portfolio_Project.dbo.CovidDeath
--where location like '%states%'
where continent is not null
order by 1,2

--JOINING BOTH TABLES
--looking at total populations vs vaccinations
Select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.date) as TotalVaccinationOfCountry
--,(TotalVaccinationOfCountry/population)*100 ---it will give error because we cant use the column that we just created for further calculations
from Portfolio_Project.dbo.CovidDeath as DTH
JOIN Portfolio_Project.dbo.covidVaccinations as vac
on dth.location=vac.location
and dth.date=vac.date
where dth.continent is not null
--and dth.location like 'India'
order by 2,3

--USE CTE
with popvsvac (continent,location,date,population,new_vaccinations,totalvaccinationsofcountry) as
(
Select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.date) as TotalVaccinationOfCountry
from Portfolio_Project.dbo.CovidDeath as DTH
JOIN Portfolio_Project.dbo.covidVaccinations as vac
on dth.location=vac.location
and dth.date=vac.date
where dth.continent is not null
)
select *,(totalvaccinationsofcountry/population)*100 as PercentPopulationVaccinated
from popvsvac
where new_vaccinations is not null
order by 2,3

--Creating temporary table
create table PopulationVsVaccination
( continent nvarchar(255),
 location nvarchar(255),
 date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinationOfCountry numeric
)
Insert into PopulationVsVaccination
Select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.date) as TotalVaccinationOfCountry
from Portfolio_Project.dbo.CovidDeath as DTH
JOIN Portfolio_Project.dbo.covidVaccinations as vac
on dth.location=vac.location
and dth.date=vac.date
where dth.continent is not null

select continent,location,max(date) as DATE,population,
max(TotalVaccinationOfCountry) as TotalVaccination,
max(TotalVaccinationOfCountry/population)*100 as PercentPopulationVaccinated
from PopulationVsVaccination
where new_vaccinations is not null
--and location like 'India'
group by location,continent,population
order by PercentPopulationVaccinated desc

select max(new_vaccinations)
--max(TotalVaccinationOfCountry/population)*100 as PercentPopulationVaccinated
from PopulationVsVaccination
where new_vaccinations is not null
and location like 'Cuba'
group by location,continent,population
-- by PercentPopulationVaccinated desc
