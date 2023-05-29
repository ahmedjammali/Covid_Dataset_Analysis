select * 
from CovidDeaths
order by 3,4

--select * 
--from CovidDeaths
--order by 3,4

--select data that will be using

select location, date,total_cases,new_cases ,total_deaths ,population
from CovidDeaths
order by 1,2

--loking ay Total cases vs total Deaths
--shows likelihood of dying if you contract covid in your country

select location, date,total_cases,total_deaths,(cast (total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from CovidDeaths
where location like '%tunis%'
order by 1,2

--looking at Totla  cases vs population
--show what percentage of population got covid

select location, date,total_cases,population,(cast (total_cases as float)/cast(population as float))*100 as infectedPercentage
from CovidDeaths
--where location like '%tunis%'
order by 1,2


--looking at country with heighest infection rate compared to population

select location, population,MAX(cast (total_cases as float)) as highestInfectionCount,max((cast (total_cases as float)/cast(population as float)))*100 as
PercentagePopulationInfected
from CovidDeaths
--where location like '%tunis%'
group by location,population
order by PercentagePopulationInfected desc

--looking at country with the highest death count per population

select location, population,MAX(cast (total_deaths as float)) as highestDeathsCount,max((cast (total_deaths as float)/cast(population as float)))*100 as
PercentagePopulationDeaths
from CovidDeaths
--where location like '%tunis%'
where continent is not null
group by location,population
order by PercentagePopulationDeaths desc


--let's break things down with continent




--showing the continent with the highest death count

select continent,MAX(cast (total_deaths as float)) as highestDeathsCount,max((cast (total_deaths as float)/cast(population as float)))*100 as
PercentagePopulationDeaths
from CovidDeaths
--where location like '%tunis%'
where continent is not null
group by continent
order by highestDeathsCount desc



--GLOBAL NUMBERS

select sum(cast (new_cases as float )) as total_cases,SUM(cast (new_deaths as float)) total_Deaths,
(sum(cast (new_deaths as float))/sum(cast (new_cases as float)))*100 as DeathPercecntage 
from CovidDeaths
--where location like '%tunis%'

where continent is not null and cast (new_cases as float ) <> 0
--group by date
order by 1,2



--looking for Total Population vs Vaccination


select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.Location ,dea.date) as RollingPeopleVaccination
from CovidDeaths dea
join CovidVaccination vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null --and dea.location like '%tunis%'
order by 2,3

--use CTE
with PopvsVac(Continent,location,date,population,new_vaccinations,RollingPeopleVaccination) as
(
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.Location ,dea.date) as RollingPeopleVaccination
from CovidDeaths dea
join CovidVaccination vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null 
--order by 2,3
)

select * ,(RollingPeopleVaccination / population)*100 as VaccinationPercentage
from PopvsVac


--temp Table

drop table if exists #PercentPopulationVaccination
create table #PercentPopulationVaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)

insert into #PercentPopulationVaccination
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.Location ,dea.date) as RollingPeopleVaccination
from CovidDeaths dea
join CovidVaccination vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null 
--order by 2,3

select * ,(RollingPeopleVaccination / population)*100 as VaccinationPercentage
from #PercentPopulationVaccination


--creating view to store data for later visulations

create View PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.Location ,dea.date) as RollingPeopleVaccination
from CovidDeaths dea
join CovidVaccination vac
	on dea.location= vac.location
	and dea.date= vac.date
--where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated
