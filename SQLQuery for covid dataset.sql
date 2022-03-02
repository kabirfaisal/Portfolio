Select*
From SQLproject..CovidDeaths
where continent is not null
order by 3,4



--Select*
--From SQLproject..CovidVaccinations
--order by 3,4


--select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
From SQLproject..CovidDeaths
where continent is not null
order by 1, 2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLproject..CovidDeaths
Where location like '%Germany%'
where continent is not null
order by 1, 2


--Looking at total cases vs population
--shows what percentage of population got covid

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From SQLproject..CovidDeaths
--Where location like '%Germany%'
where continent is not null
order by 1, 2


--looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases), MAX((total_cases/population))*100 as PercentPopulationInfected
From SQLproject..CovidDeaths
--Where location like '%Germany%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc





--showing countries with highest death count per population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SQLproject..CovidDeaths
--Where location like '%Germany%'
where continent is not null
Group by location
order by TotalDeathCount desc


--let's break things down by continent

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SQLproject..CovidDeaths
--Where location like '%Germany%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--global numbers
--let's break things down by continent

select date, SUM(new_cases) as SumNewCases, SUM(cast(new_deaths as int)) as SumNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From SQLproject..CovidDeaths
--where location like '%Germany%'
where continent is not null
group by date
order by 1, 2

--sum of cases, sum of deaths, sum of death percentage

select  SUM(new_cases) as SumNewCases, SUM(cast(new_deaths as int)) as SumNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From SQLproject..CovidDeaths
--where location like '%Germany%'
where continent is not null
--group by date
order by 1, 2


select*
From SQLproject..CovidDeaths death
join SQLproject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
	

--looking at total population vs vaccinations

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) over (partition by death.location order by death.location, death. date) as RollingSumVaccinated
From SQLproject..CovidDeaths death
join SQLproject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2, 3


--use CTE

with PopVsVacc (continent, location, date, population, new_vaccinations, RollingSumVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) over (partition by death.location order by death.location, death. date) as RollingSumVaccinated
From SQLproject..CovidDeaths death
join SQLproject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2, 3
)
select*, (RollingSumVaccinated/population)*100
From PopVsVacc


--TEMP table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingSumVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) over (partition by death.location order by death.location, death. date) as RollingSumVaccinated
From SQLproject..CovidDeaths death
join SQLproject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2, 3

select*, (RollingSumVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) over (partition by death.location order by death.location, death. date) as RollingSumVaccinated
From SQLproject..CovidDeaths death
join SQLproject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2, 3

select*
From PercentPopulationVaccinated
