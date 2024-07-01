select * 
from PortfolioProject .. CovidDeaths
where continent is not null
order by 3,4


--select * 
--from PortfolioProject .. CovidVaccinations
--where continent is not null
--order by 3,4

-- select data that we are going to be using  
select location , date , total_cases , new_cases , total_deaths , population_density
from PortfolioProject .. CovidDeaths
where continent is not null
order by 1,2

----looking at total cases vs total deaths

Select  location , date , total_cases , total_deaths , cast (total_deaths as float) / total_cases *(100) as deathpercentatge  
from PortfolioProject .. CovidDeaths

where location like '%states%'
and continent is not null
order by 1,2
 
 --- looking at total cases vs population 
 --- show  the percentatge of population_density got covid 
 
Select  location , date , population_density ,total_cases , total_deaths  , ( total_cases /population_density) *100 as percentpopulationinfected
from PortfolioProject .. CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--- looking at countries with highest infection rate compared to population 
Select  location , population_density ,MAX(total_cases)as highestinfectioncount   , Max( total_cases /population_density)*100  as 
  percentpopulationinfected
from PortfolioProject .. CovidDeaths
where continent is not null
Group by location , population_density
order by percentpopulationinfected desc 

--- showing countries with highest Death Count per population 
Select  location , Max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject .. CovidDeaths
where continent is  null
Group by location 
order by totalDeathCount desc 

--- Globlal Numbers 

Select  sum (new_cases) as total_Cases , sum(cast (new_deaths as int)) as total_Deathes , sum(cast (new_deaths as int)) /
sum (new_cases) *100 as Deathpercentatge
from PortfolioProject .. CovidDeaths
--where location like '%states%'
where  continent is not null
order by 1,2



select dea.continent , dea.location , dea.date , dea.population_density, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingpeopleVaccination
from PortfolioProject .. CovidDeaths dea 
Join PortfolioProject .. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where  dea.continent is not null
order by 2,3

--- Use CTE 
with PopvsVac (continent,location,date,population_density,new_vaccinations,RollingpeopleVaccination)
as
(
select dea.continent , dea.location , dea.date , dea.population_density, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingpeopleVaccination
from PortfolioProject .. CovidDeaths dea 
Join PortfolioProject .. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where  dea.continent is not null
--order by 2,3
)
select * , (RollingpeopleVaccination/population_density)*100 
from PopvsVac 
 

 --- Temp Table 
 DROP table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (
Continent nvarchar (255),
Location nvarchar (255),
Date datetime ,
Population_density numeric ,
New_vacvaccinations numeric,
RollingpeopleVaccination numeric
 )

 Insert into #percentpopulationvaccinated	
 select dea.continent , dea.location , dea.date , dea.population_density, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingpeopleVaccination
from PortfolioProject .. CovidDeaths dea 
Join PortfolioProject .. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where  dea.continent is not null
--order by 2,3

select * , (RollingpeopleVaccination/population_density)*100 
from #percentpopulationvaccinated

--- creating view to store data	for later visulisation 

create view  percentpopulationvaccinated as 
select dea.continent , dea.location , dea.date , dea.population_density, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingpeopleVaccination
from PortfolioProject .. CovidDeaths dea 
Join PortfolioProject .. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where  dea.continent is not null
--order by 2,3

select * 
from  percentpopulationvaccinated