-- select the data we will use

select location, date, total_cases, total_deaths, population
from Portfolio.dbo.CovidDeath
order by 1,2


-- Total cases vs Total Deaths
--estimation of the risk of dying if you infected by covid in a specific country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolio.dbo.CovidDeath
where location like '%Turkey%'
order by 1,2

--total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as infectionpercentage
from Portfolio.dbo.CovidDeath
where location like '%Turkey%'
order by 1,2

--countries with highest infection
select location , max(total_cases) as Total_cases, population, max((total_cases/population))*100 as TotalCasePercentage
from Portfolio.dbo.CovidDeath
group by location,population
order by 4 DESC

--Showing countries with highest death count per population
select location , population,max(cast(total_deaths as int)) as Total_deaths,  max((total_deaths/population))*100 as TotalDeathPercentage
from Portfolio.dbo.CovidDeath
where continent is not null
group by location,population
order by 3 DESC


--Group by continents(highest to lowest deaths)
select continent ,max(cast(total_deaths as int)) as Total_deaths,  max((total_deaths/population))*100 as TotalDeathPercentage
from Portfolio.dbo.CovidDeath
where continent is  not null
group by continent
order by 2 DESC

--Global cases and death 
select date ,sum(new_cases) as newcases,sum(cast(new_deaths as int)) as new_deaths,  (sum(cast(new_deaths as int))/sum(new_cases))*100 as TotalDeathPercentage
from Portfolio.dbo.CovidDeath
where continent is  not null
group by date
order by 1 DESC


--total population vs vaccination
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
      ,sum(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
from Portfolio.dbo.CovidDeath dea
join Portfolio.dbo.CovidVaccination vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is  not null
order by 2,3

--Create CTE (to use RollingVaccinated that we created)

with popvsVac(
Continent, Location, Date, Population, New_Vaccination, RollingVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
      ,sum(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
from Portfolio.dbo.CovidDeath dea
join Portfolio.dbo.CovidVaccination vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is  not null
--order by 2,3

)
select *,(RollingVaccinated/Population)*100 as RollingVaccinatedPercentage
from popvsVac


--create view for future use

create view Percent_Of_Vaccinated_People1 as
with popvsVac(
Continent, Location, Date, Population, New_Vaccination, RollingVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
      ,sum(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
from Portfolio.dbo.CovidDeath dea
join Portfolio.dbo.CovidVaccination vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is  not null
--order by 2,3

)
select *,(RollingVaccinated/Population)*100 as RollingVaccinatedPercentage
from popvsVac


select*
from Percent_Of_Vaccinated_People

