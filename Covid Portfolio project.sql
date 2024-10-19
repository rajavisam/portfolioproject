Select*
from Portfolio..CovidDeaths$
where continent is not null
order by 3,4

--Select*
--from Portfolio..CovidVaccinations$
--order by 3,4

---- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio..CovidDeaths$
where location like '%ndia%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as Cases_Percentage
from Portfolio..CovidDeaths$
where location like '%ndia%'
order by 1,2

-- looking at the countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
from Portfolio..CovidDeaths$
where continent is not null
GROUP BY location, population
order by Percent_Population_Infected desc

-- showing Countries with highest Death Count Per Population

SELECT location, MAX(CAST(total_deaths AS int)) as Total_Death_Count
from Portfolio..CovidDeaths$
where continent is not null
GROUP BY location
order by Total_Death_Count desc


-- break things down by Continent

-- showing continents with the highest death count by population


SELECT continent, MAX(CAST(total_deaths AS int)) as Total_Death_Count
from Portfolio..CovidDeaths$
where continent is not null
GROUP BY continent
order by Total_Death_Count desc

--- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths$
where continent is not null
--Group By date
order by 1,2


---Looking at Total Population vs Vaccinations

-- USE CTE
With popvsvac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
)
Select *, (Rolling_People_Vaccinated/population)*100
From popvsvac



--Temp Table
Drop Table if exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	And dea.date = vac.date
--where dea.continent is not null

Select *, (Rolling_People_Vaccinated/population)*100
From #Percent_Population_Vaccinated

---visualizations
Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null

Select*
From Percent_Population_Vaccinated