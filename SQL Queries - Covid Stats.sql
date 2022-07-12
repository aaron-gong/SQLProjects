select *
from PortfolioProject..CovidStats
where continent is not null


select location, date, new_cases, total_cases, population, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidStats
where location like '%australia%'
order by 1,2

-- Shows likelihood of dying if you contract covid in your country


select location, date, new_cases, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidStats
where location like '%australia%'
order by 1,2

-- Shows what % of population got covid. 


select location,  MAX(total_cases) as HighestInfectionCount, population, (Max(total_cases)/population)*100 as CovidPercentage
from PortfolioProject..CovidStats
Group By location, population
order by CovidPercentage desc

--which countries have highest infection rates


select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidStats
where continent is not null
Group By location
order by TotalDeathCount desc

--countries with highest death count

select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidStats
where continent is null
Group By location
order by TotalDeathCount desc

--regions with highest death count

select location,  MAX(cast(total_deaths as int)) as TotalDeathCount, population, (Max(cast(total_deaths as int))/population)*100 as DeathPercentage
from PortfolioProject..CovidStats
where continent is not null
Group By location, population
order by DeathPercentage desc

--countries with the highest death rate compared to population

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100  as daily_global_death_percentage
from PortfolioProject..CovidStats
where continent is not null
group by date
order by 1,2

--daily global death percentage

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100  as daily_global_death_percentage
from PortfolioProject..CovidStats
where continent is not null
order by 1,2

--all time global death percentage - deaths/cases

use PortfolioProject
go
create view new_vaccinations_and_cases_daily_Australia as
select date, location, new_vaccinations, new_cases
from PortfolioProject..CovidStats
where location = 'Australia'
--order by date

--new vaccinations and new cases in Australia by day

select location, max(population) as Population, max(convert(bigint,total_vaccinations)) as Total_Vax
from PortfolioProject..CovidStats
where continent is not null
group by location
order by total_vax desc

--Lookng at Total Population vs Vaccinations per country

select continent, location, date, population, new_vaccinations, sum(convert(bigint,new_vaccinations)) OVER (partition by Location  order by location,date) as rolling_people_vaccinated
from PortfolioProject..CovidStats
where continent is not null
order by 2,3

--rolling people vaccinated

with Pop_vs_Vax (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaccinated) as
(
select continent, location, date, population, new_vaccinations, sum(convert(bigint,new_vaccinations)) OVER (partition by Location  order by location,date) as rolling_people_vaccinated
from PortfolioProject..CovidStats
where continent is not null
)

select *, (rolling_people_vaccinated/(population*3))*100 as percentage_triple_vaccinated
from Pop_vs_Vax
where Location = ('Australia')

--rolling % of ppl triple vaccinated using CTE

Drop Table if exists triple_vaccination_percentage
create table triple_vaccination_percentage (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric)

insert into triple_vaccination_percentage

	select continent, location, date, population, new_vaccinations, sum(convert(bigint,new_vaccinations)) OVER (partition by Location  order by location,date) as rolling_people_vaccinated
	from PortfolioProject..CovidStats
	where continent is not null
	order by 2,3

select *, (rolling_people_vaccinated/(population*3))*100 as percentage_triple_vaccinated
from triple_vaccination_percentage

--rolling % of ppl triple vaxed using create table. 

use PortfolioProject
go
Create View Highest_Infection_Rates AS

select location,  MAX(total_cases) as HighestInfectionCount, population, (Max(total_cases)/population)*100 as CovidPercentage
from PortfolioProject..CovidStats
Group By location, population
order by CovidPercentage desc

--creating view for later visualizations