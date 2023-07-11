

--Select *
--From PortfoloProject..covid_vacinations$
--order by 3,4

--Select Data that is being used
--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfoloProject..covid_deaths$
--order by 1,2

--Looking at total cases vs total deaths
Select Location, date, total_cases, new_cases, total_deaths, continent
From PortfoloProject..covid_deaths$
order by 1,2

--looking at total deaths per cases in Kenya
SELECT Location, date, total_cases, new_cases, total_deaths,CONVERT(float, total_deaths) / CONVERT(float, total_cases)*100 AS death_per_cases
FROM PortfoloProject..covid_deaths$
where Location like '%enya%'
ORDER BY 1,2;

--looking at percentage of population infected
SELECT Location, total_cases, population, total_deaths,CONVERT(float, total_cases) / CONVERT(float, population)*100 AS population_percentage
FROM PortfoloProject..covid_deaths$
where Location like '%enya%'
ORDER BY 1,2;

--looking at countries with the highest no. of infections compared to population
Select Location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population)*100 AS percent_population_infected
From PortfoloProject..covid_deaths$
Group by location, population
order by 4 DESC

--Showing countries with highest death count per population
Select Location, MAX(CAST (total_deaths AS int)) AS population_died
From PortfoloProject..covid_deaths$
where continent is not null
Group by location, population
order by population_died DESC
 
 --Showing continents with highest death counts per population
 Select Location, MAX(CAST (total_deaths AS int)) AS population_died
From PortfoloProject..covid_deaths$
where continent is null
Group by location, population
order by population_died DESC

 Select Location, MAX(CAST (total_deaths AS int)) AS population_died
From PortfoloProject..covid_deaths$
where continent is null
and Location like '%pper%'
Group by location, population
order by population_died DESC

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfoloProject..covid_deaths$
where continent is not null
Group by date
order by 1,2

-- looking at total population vs vaccination vs people fully vacinatted
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as accumulating_people_vaccinated
From PortfoloProject..covid_deaths$ dea
Join PortfoloProject..covid_vacinations$ vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--creating a column and using the same column in arthimetic functions
With Popvsvac(continent, location, date, population, new_vaccinations, accumulating_poeple_vaccinated)as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as accumulating_people_vaccinated
--, (accumulating_people_vaccinated/population)*100
From PortfoloProject..covid_deaths$ dea
Join PortfoloProject..covid_vacinations$ vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select*, (accumulating_poeple_vaccinated/population)*100 as percentage_accumulating_poeple_vaccinated
From Popvsvac

--TEMP TABLE
Create Table #Percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
accumulating_poeple_vaccinated numeric
)

 Insert into #Percent_population_vaccinated
 Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as accumulating_people_vaccinated
--, (accumulating_people_vaccinated/population)*100
From PortfoloProject..covid_deaths$ dea
Join PortfoloProject..covid_vacinations$ vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select*, (accumulating_poeple_vaccinated/population)*100 
From #Percent_population_vaccinated

--Creating view to store data for visualization
CREATE VIEW New_Percent_population_vaccinated AS
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as accumulating_people_vaccinated
--, (accumulating_people_vaccinated/population)*100
From PortfoloProject..covid_deaths$ dea
Join PortfoloProject..covid_vacinations$ vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
 
Select *
From New_Percent_population_vaccinated


CREATE VIEW Total_death_cases_kenya AS
SELECT Location, date, total_cases, new_cases, total_deaths,CONVERT(float, total_deaths) / CONVERT(float, total_cases)*100 AS death_per_cases
FROM PortfoloProject..covid_deaths$
where Location like '%enya%'
--ORDER BY 1,2;
