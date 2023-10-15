Select *
From ProjectNew..CovidDeaths
Order by 3,4

Select *
From ProjectNew..CovidVaccinations
Order by 3,4

-- TOTAL CASES VS POPULATION

Select date, location, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From ProjectNew..CovidDeaths
Order By 2,3

-- TOTAL DEATHS VS TOTAL CASES

Select date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectNew..CovidDeaths
Where location like '%Pakistan%'
Order By 2,3

-- Total Cases VS Population
-- Percentage of Population got Infected

Select location, date, total_cases, population, (total_cases/population)*100 as PercentInfected
From ProjectNew..CovidDeaths
--where location like '%States%'
Order By 1,2

-- Countries With Highest Infection Rate Compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From ProjectNew..CovidDeaths
--where location like '%States%'
Group By location, population
Order By PercentagePopulationInfected desc

-- Countries with Highest Death Count Per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathsCount
From ProjectNew..CovidDeaths
--where location like '%States%'
Where continent is not null
Group By location
Order By TotalDeathsCount desc

-- Continent Wise Breakup 

--Showing Continents with Highest Death Count

Select continent, Max(cast(total_deaths as int)) as TotalDeathsCount
From ProjectNew..CovidDeaths
--where location like '%States%'
Where continent is not null
Group By continent
Order By TotalDeathsCount desc

-- GLOBAL NUMBERS

Select sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From ProjectNew..CovidDeaths
--where location like '%States%'
where continent is not null
--Group by date
Order By 1,2

-- Total Population VS Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinatedCount
From ProjectNew..CovidDeaths dea
Join ProjectNew..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USING CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinatedCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinatedCount
From ProjectNew..CovidDeaths dea
Join ProjectNew..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinatedCount/population)*100
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
RollingVaccinatedCount numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinatedCount
From ProjectNew..CovidDeaths dea
Join ProjectNew..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingVaccinatedCount/population)*100
From #PercentPopulationVaccinated