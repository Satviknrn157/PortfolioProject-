select * from CovidDeaths$
SELECT * FROM covidvaccinations$

-- to know the data type of the column

exec sp_help CovidDeaths$
--Alter accordingly
ALTER TABLE CovidDeaths$
ALTER COLUMN new_deaths_smoothed float

ALTER TABLE CovidDeaths$

ALTER COLUMN weekly_hosp_admissions_per_million float


-- Selecting data we will use

Select Location , date, total_cases , new_cases , total_deaths , population
from CovidDeaths$
-- Total cases vs total death vs deathpercent
Select Location ,SUM(total_cases)  as tot_cases 
	, SUM(total_deaths ) as tot_deaths
	, 100*SUM(total_deaths )/SUM(total_cases) as  death_percent
from CovidDeaths$
where location like '%United%' OR location like 'India'
group by location
order by death_percent desc

-- percent died of covid

Select Location , population , SUM(total_deaths ) as tot_deaths 
, SUM(total_deaths )/population 
from CovidDeaths$
where location like '%United%' OR location like 'India'
group by location , population

-- highest infection rate 

Select Location , population , max(total_cases) as max_case 
, 100*max(total_cases)/population as infec_rate
from CovidDeaths$
group by location , population
order by infec_rate asc

-- highest death count

Select Location , population , max(total_deaths) as tot_death 
, 100*max(total_deaths)/population as death_rate
from CovidDeaths$
where continent is not null
group by location , population
order by  death_rate desc

-- highest death count continent wise 
Select Location , population , max(total_deaths) as tot_death 
, 100*max(total_deaths)/population as death_rate
from CovidDeaths$
where continent is  null
group by location , population
order by  death_rate desc

-- Breaking down to global numbers 
SELECT Location , population , max(total_deaths) as tot_death 
, 100*max(total_deaths)/population as death_rate
FROM CovidDeaths$
where Location ='World'
group by location , population

-- each day case , death 
SELECT Location ,date ,  population ,SUM(total_cases)  as tot_cases 
	, SUM(total_deaths ) as tot_deaths
	, 100*SUM(total_deaths )/SUM(total_cases) as  death_percent
FROM CovidDeaths$
where Location ='World'
group by location ,date, population
order by date

-- Joining the vaccination and death table

select * from CovidDeaths$
SELECT * FROM covidvaccinations$

--
SELECT cd.location , cd.date , cd.location , cd.population 
,cd.total_cases , cd.total_cases , cv.total_tests , cv.total_vaccinations 
, cv.new_vaccinations 
FROM CovidDeaths$ cd
JOIN covidvaccinations$ cv
on cd.date = cv.date and cd.location=cv.location

-- total Population vs vaccination 
exec sp_help covidvaccinations$


SELECT cd.location ,
cd.population ,
MAX(cd.total_cases) ,
max(cv.total_tests),
max(cv.total_vaccinations),
SUM(cast(cv.new_vaccinations as float )) over(partition by cd.location 
order by cd.location range between unbounded preceding and current row ) rollingvaccinated 
FROM CovidDeaths$ cd
JOIN covidvaccinations$ cv
on cd.date = cv.date and cd.location=cv.location
where cd.continent is not null
group by  cd.location , cd.population ,cv.new_vaccinations


--Create view for later visualisation

create view  recentview as 
Select Location , population , max(total_deaths) as tot_death 
, 100*max(total_deaths)/population as death_rate
from CovidDeaths$
where continent is not null
group by location , population

