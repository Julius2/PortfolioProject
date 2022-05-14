select *
from PortfolioProject..CovidDeath
order by 3,4

--select *
--from PortfolioProject..CovidVaccination
--order by 3,4

--select Data that we are going to be using

Select Location,Date, total_cases_per_million, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
order by 1,2

----Total Cases versus Total Deaths
--shows likelihood of dying if contract covid in your country

Select Location,Date, total_cases_per_million, total_deaths,(total_deaths/total_cases_per_million)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%Kenya%'
order by 1,2

--looking at Total Cases vs Population

Select Location,Date, population, total_cases_per_million, (total_cases_per_million/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
where location like '%kenya%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases_per_million) as HighestInfectioncount, MAX(total_cases_per_million/population)*100 as 
	PercentPopulationInfected
from PortfolioProject..CovidDeath
--where location like '%kenya%'
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with the highest deathcount per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeath
--where location like '%kenya%'
where continent is null
Group by location
order by TotalDeathCount desc

--showing the continent with the heighest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeath
--where location like '%kenya%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select continent, SUM(cast(Total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeath
--where location like '%kenya%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--looking at Total Popuation vs Vaccinations.

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeath dea
join Portfolioproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With popvsVac (continent, location, date, populatin,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeath dea
join Portfolioproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
From popvsVac


--Temp Table
Create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvachar (max),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeath dea
join Portfolioproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
From popvsVac

--creating view to store data for later visualisation

Create view PercentPopulationaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeath dea
join Portfolioproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

