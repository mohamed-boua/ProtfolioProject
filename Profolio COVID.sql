select location,date,population,total_cases,new_cases,total_deaths
from Profolio_CoviD..[COVID Deths]
order by 1,2

--Loking for total cases vs total deths 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as hello
from Profolio_CoviD..[COVID Deths]
where location like 'alg%'
order by 1,2

-- Loking total_cases Vs population 
select location,date,population,total_cases,(total_cases/population)*100 as '%'
from Profolio_CoviD..[COVID Deths]
where location like 'alg%'
order by 1,2

-- Loking Most infecten Compare population 
 
select location,population,Max(total_cases)as maxtotalcase,Max((total_cases/population))*100 as Test
from Profolio_CoviD..[COVID Deths]
--where location like 'alg%'
group by population,location
order by Test desc


--Loking for countries with hightdeths per Countrier 

Select location,MAX(total_deaths)AS Deaths
from Profolio_CoviD..[COVID Deths]
where continent is not null 
group by location
order by 2 desc


--Loking for countries with hightdeths per LOCATION قارة  

Select continent,MAX(total_deaths)AS Deaths
from Profolio_CoviD..[COVID Deths]
where continent is not null 
group by continent
order by 2 desc

-- the sum of deaths and cases in entier world
select date,sum(total_cases)as Cases,sum(total_deaths)as Deaths, (sum(total_deaths)/sum(total_cases))*100 as Persentege
from Profolio_CoviD..[COVID Deths]
where continent is not null
group by date
order by 1

--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (partition by death.location 
									order by death.location,death.date)
from Profolio_CoviD..[COVID Deths] death 
Join Profolio_CoviD..[COVID VACC] vac
	On death.location = vac.location
		and death.date = vac.date
where death.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
with EVRythig (continent,location,date,population,new_vaccinations,sum_Vac) AS
(
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (partition by death.location 
									order by death.location,death.date) as sum_Vac
from Profolio_CoviD..[COVID Deths] death 
Join Profolio_CoviD..[COVID VACC] vac
	On death.location = vac.location
		and death.date = vac.date
where death.continent is not null
--order by 2,3
)

select *,(sum_Vac/population)*100
from EVRythig


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #TempVAC
Create table #TempVAC
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
sum_Vac numeric
)

insert into #TempVAC
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (partition by death.location 
									order by death.location,death.date) as sum_Vac
from Profolio_CoviD..[COVID Deths] death 
Join Profolio_CoviD..[COVID VACC] vac
	On death.location = vac.location
		and death.date = vac.date
where death.continent is not null
--order by 2,3

select *,(sum_Vac/population)*100
from #TempVAC 





-- Modifi comlum + table 
Alter table  Profolio_CoviD..[COVID Deths]
Alter Column total_deaths float

Alter table  Profolio_CoviD..[COVID Deths]
Alter Column total_cases float

Alter table  Profolio_CoviD..[COVID VACC]
Alter Column new_vaccinations float

