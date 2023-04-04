--Selection 

select * 
from dataset.covid_vaccination 
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population 
from dataset.covid_deaths  
order by location, date

--Total Cases vs Total Deaths %

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
from dataset.covid_deaths 
order by location, date

--Chances of a Fatal Covid Contraction in Pakistan

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from dataset.covid_deaths 
where location = 'Pakistan' 
order by location, date 

--Infection rate in Pakistan

select location, date, total_cases, population, (total_cases/population)*100 as effected_population_percentage 
from dataset.covid_deaths 
where location = 'Pakistan' 
order by location, date 

--Countries with the highest infection rate with respect to population

select location, population, max(total_cases) as max_cases, max((total_cases/population)*100) as effected_population_percentage 
from dataset.covid_deaths 
group by location, population 
order by effected_population_percentage desc

--Countries with the most deaths

select location, max(total_deaths) as death_count 
from groovy-bonus-381909.dataset.covid_deaths 
where continent is not null 
group by location 
order by death_count desc

--Continents with the most deaths

select continent, max(total_deaths) as death_count 
from groovy-bonus-38109.dataset.covid_deaths 
where continent is not null 
group by continent 
order by death_count desc

select location, max(total_deaths) as death_count 
from groovy-bonus-381909.dataset.covid_deaths 
where continent is null 
group by location 
order by death_count desc

--Global Death Rate

select date, sum(new_cases) as case_count ,sum(new_deaths) as death_count, sum(new_deaths)/sum(new_cases)*100 as death_rate 
from groovy-bonus-381909.dataset.covid_deaths 
where continent is not null 
group by date 
order by date

select sum(new_cases) as case_count ,sum(new_deaths) as death_count, sum(new_deaths)/sum(new_cases)*100 as death_rate 
from groovy-bonus-381909.dataset.covid_deaths 
where continent is not null

--Joining the death and vaccination tables

Select * from groovy-bonus-381909.dataset.covid_vaccination cov_vac
join groovy-bonus-381909.dataset.covid_deaths cov_dea
on cov_vac.location = cov_dea.location and cov_vac.date = cov_dea.date

--Total population vs vaccinated population

Select cov_dea.continent, cov_dea.location, cov_dea.date, cov_dea.population, cov_vac.new_vaccinations 
from groovy-bonus-381909.dataset.covid_vaccination cov_vac
join groovy-bonus-381909.dataset.covid_deaths cov_dea
on cov_vac.location = cov_dea.location and cov_vac.date = cov_dea.date
where cov_dea.continent is not null
order by 2,3

Select cov_dea.continent, cov_dea.location, cov_dea.date, cov_dea.population, cov_vac.new_vaccinations, 
sum(cov_vac.new_vaccinations) over (partition by cov_dea.location order by cov_dea.location, cov_dea.date) as vaccination_summation
from groovy-bonus-381909.dataset.covid_vaccination cov_vac
join groovy-bonus-381909.dataset.covid_deaths cov_dea
on cov_vac.location = cov_dea.location and cov_vac.date = cov_dea.date
where cov_dea.continent is not null
order by 2,3

--Global vaccination percentage grouped by country

--(Using CTE)

with popvsvac as (
  Select cov_dea.continent, cov_dea.location, cov_dea.date, cov_dea.population, cov_vac.new_vaccinations, 
sum(cov_vac.new_vaccinations) over (partition by cov_dea.location order by cov_dea.location, cov_dea.date) as vaccination_summation,
from groovy-bonus-381909.dataset.covid_vaccination cov_vac
join groovy-bonus-381909.dataset.covid_deaths cov_dea
on cov_vac.location = cov_dea.location and cov_vac.date = cov_dea.date
where cov_dea.continent is not null
order by 2,3)

select *, vaccination_summation/population*100 as vaccinated_pop_percentage from popvsvac

--(Using View)

create view dataset.popvsvac as (
  Select cov_dea.continent, cov_dea.location, cov_dea.date, cov_dea.population, cov_vac.new_vaccinations, 
sum(cov_vac.new_vaccinations) over (partition by cov_dea.location order by cov_dea.location, cov_dea.date) as vaccination_summation,
from groovy-bonus-381909.dataset.covid_vaccination cov_vac
join groovy-bonus-381909.dataset.covid_deaths cov_dea
on cov_vac.location = cov_dea.location and cov_vac.date = cov_dea.date
where cov_dea.continent is not null
order by 2,3)

select *, vaccination_summation/population*100 as vaccinated_pop_percentage from dataset.popvsvac
