Select Location, date, total_cases, new_cases, total_deaths, population
From  [dbo].[CovidDeath]
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying for Covid in different country
Select Location, date, total_cases, total_deaths, Cast(total_deaths as Float) / Cast(total_cases as Float) * 100 DeathPercentage
From  [dbo].[CovidDeath]
Where Location like 'Nepal%'
order by 1,2

--Looking at the Total Cases vs Population
Select Location, date, population, total_cases,  Cast(total_cases as Float) / Cast(population as Float) * 100 CovidPercentage
From  [dbo].[CovidDeath]
--Where Location like 'Nepal'
order by 1,2

--Looking for the highest Covid-19 infection in comparision to population
Select Location, population, Max(total_cases) HighestInfectionCount, Max(Cast(total_cases as Float)) / Cast(population as Float) * 100 Percentage
From  [dbo].[CovidDeath]
--Where Location like 'Nepal'
Group by Location, population 
order by 4 desc


-- Showing Countries with Highest Death Count per Population
Select Location, population, Max(total_deaths) HighestDeathCount
From  [dbo].[CovidDeath]
--Where Location like 'Nepal'
Where continent is not null
Group by Location, population 
order by 3 desc


-- Death by continent

Select continent, Max(total_deaths) HighestDeathCount
From  [dbo].[CovidDeath]
--Where Location like 'Nepal'
Where continent is not null  
Group by continent
order by HighestDeathCount desc


-- Global Numbers
Select date, SUM(new_cases), SUM(new_deaths),
CASE WHEN SUM(new_cases) = 0 Then Null 
ELSE (SUM(new_deaths) /SUM(new_cases)*100) END as Percentage
From  [dbo].[CovidDeath]
--Where Location like 'Nepal%'
Where continent is not null
Group by date
order by 4


-- Looking Total Popultaion vs Vaccination
-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccination, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(Bigint, vac.new_vaccinations),
SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Date) RollingPeopleVaccinated 
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVacnation] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

)
select *,  (RollingPeopleVaccinated/Population)*100 percentage
From PopvsVac
Order by 2,3;



-- Using TEMP TABLE


DROP TABLE if exists #RollingPeopleVaccinated
CREATE TABLE #RollingPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #RollingPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(Bigint, vac.new_vaccinations),
SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Date) RollingPeopleVaccinated 
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVacnation] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *,  (RollingPeopleVaccinated/Population)*100 percentage
From #RollingPeopleVaccinated
Order by 2,3;


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(Bigint, vac.new_vaccinations) New_Vaccination,
SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Date) RollingPeopleVaccinated 
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVacnation] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
