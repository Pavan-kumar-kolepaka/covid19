 

--Covid Death Table

select *
from Protfolioprojet..covidDeaths
order by 3,4


--Covid Vaccinations Table

select *
from Protfolioprojet..covidVaccinations
order by 3,4

--select Data that we are using

select location,date,total_cases,new_cases,total_deaths,population
from Protfolioprojet..covidDeaths
order by 1,2


--Looking at Total Cases VS Total Deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Protfolioprojet..covidDeaths
where location like '%istates%'


--Looking at Total Cases VS  Population

select location,date,total_cases,population,(total_cases/population)*100 as PercentageofPopulation
from Protfolioprojet..covidDeaths
where location like '%states%'
order by 1,2

--Looking at highest infection rate compared to population 

select location,population,date,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as PercentageofPopulationInfeceted
from Protfolioprojet..covidDeaths
--where location like '%states%'
Group by location,population,date
order by PercentageofPopulationInfeceted desc



--Showing Countries with Hight Infection Death Count per Infection

select location,population,MAX(cast(total_deaths as int)) as TotalDeathCount
from Protfolioprojet..covidDeaths
--where location like '%states%'
where continent is not null
Group by location,population
order by TotalDeathCount desc


--Total Death Count by Continent


select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from Protfolioprojet..covidDeaths
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc


--Showing Continent with highest death count per population


select location,SUM(cast(new_deaths as int)) as TotalDeathCount
from Protfolioprojet..covidDeaths
--where location like '%states%'
where continent is null
and location not in ('world','European union','International','Upper middle income','High income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS


select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Protfolioprojet..covidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--looking at toatal population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From Protfolioprojet..covidDeaths as dea
JOIN  Protfolioprojet..covidVaccinations as vac
ON dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3



--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(bigint,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From Protfolioprojet..covidDeaths as dea
JOIN  Protfolioprojet..covidVaccinations as vac
ON dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated  numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Protfolioprojet..covidDeaths as dea
JOIN  Protfolioprojet..covidVaccinations as vac
ON dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated



--creating view to store data for later visualizations

Create view PercentPopulationVaccinatedview as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Protfolioprojet..covidDeaths as dea
JOIN  Protfolioprojet..covidVaccinations as vac
ON dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select *
From PercentPopulationVaccinatedview
