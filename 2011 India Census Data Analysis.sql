select * from shreya.dbo.Data1$

select * from shreya.dbo.Sheet1$

-- number of rows into our dataset

select count(*) from shreya..Data1$
select count(*) from shreya..Sheet1$

-- dataset for jharkhand and bihar

select * from shreya..Data1$ where State in ('Jharkhand' ,'Bihar')

-- population of India

select sum(population) as Population from shreya..Sheet1$

-- avg growth 

select state, avg(growth)*100 Avg_Growth from shreya..Data1$ group by state;

 
-- avg sex ratio

select state,round(avg(sex_ratio),0) Avg_Sex_Ratio from shreya..Data1$ group by state order by Avg_Sex_Ratio desc;

-- avg literacy rate
 
select state,round(avg(literacy),0) Avg_Literacy_Ratio from shreya..Data1$ 
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;

-- top 3 state showing highest growth ratio


select top 3 state, avg(growth)*100 Avg_Growth from shreya..Data1$ group by state order by Avg_Growth desc;


--bottom 3 state showing lowest sex ratio

select top 3 state,round(avg(sex_ratio),0) Avg_Sex_Ratio from shreya..Data1$ group by state order by Avg_Sex_Ratio asc; 

-- top and bottom 3 states in literacy state

drop table if exists #Topstates;
create table #Topstates
( State nvarchar(255),
  Topstates float

  )

insert into #Topstates
select state,round(avg(literacy),0) avg_literacy_ratio from shreya..Data1$
group by state order by avg_literacy_ratio desc;

select top 3 * from #Topstates order by #Topstates.Topstates desc;

drop table if exists #Bottomstates;
create table #Bottomstates
( state nvarchar(255),
  Bottomstate float

  )
  insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from shreya..Data1$
group by state order by avg_literacy_ratio desc;

select top 3 * from #Bottomstates order by #Bottomstates.Bottomstate asc;

--union opertor

select * from (
select top 3 * from #Topstates order by #Topstates.Topstates desc) a

union

select * from (
select top 3 * from #Bottomstates order by #Bottomstates.Bottomstate asc) b;

-- states starting with letter a

select distinct state from shreya..Data1$ where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from shreya..Data1$ where lower(state) like 'a%' and lower(state) like '%m'

-- joining both table
select a.district,a.state,a.sex_ratio,b.population from  shreya..Data1$ a inner join shreya..Sheet1$ b on a.district = b.district 

--total males and females

select d.state,sum(d.males) Total_Males,sum(d.females) Total_Females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio,b.population from  shreya..Data1$ a inner join shreya..Sheet1$ b on a.district = b.district  ) c)d
group by d.state;

-- total literacy rate

select a.district,a.state,a.Literacy/100 Literacy_ratio,b.population from  shreya..Data1$ a inner join shreya..Sheet1$ b on a.district = b.district 

select c.State,sum(Literate_people) Total_Literate_pop,sum(Illiterate_people) Total_Iliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.Literacy/100 Literacy_ratio,b.population from  shreya..Data1$ a inner join shreya..Sheet1$ b on a.district = b.district) d) c
group by c.state;


-- population in previous census

select a.district,a.state,a.Growth Growth,b.population from  shreya..Data1$ a inner join shreya..Sheet1$ b on a.district = b.district 

select sum(m.Previous_census_population) Previous_census_population,sum(m.Current_census_population) Current_census_population from(
select e.state,sum(e.Previous_census_population) Previous_census_population,sum(e.Current_census_population) Current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) Previous_census_population,d.population Current_census_population from
(select a.district,a.state,a.Growth Growth,b.population from  shreya..Data1$ a inner join shreya..Sheet1$ b on a.district = b.district) d) e
group by e.state)m

-- population vs area

select (g.total_area/g.previous_census_population)  as Previous_census_population_vs_Area, (g.total_area/g.current_census_population) as 
Current_census_population_vs_Area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.Previous_census_population) Previous_census_population,sum(m.Current_census_population) Current_census_population from(
select e.state,sum(e.Previous_census_population) Previous_census_population,sum(e.Current_census_population) Current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) Previous_census_population,d.population Current_census_population from
(select a.district,a.state,a.Growth Growth,b.population from  shreya..Data1$ a inner join shreya..Sheet1$ b on a.district = b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from shreya..Sheet1$)z) r on q.keyy=r.keyy)g


--window 

---output top 3 districts from each state with highest literacy rate


select a.* from
(select District,State,Literacy,rank() over(partition by state order by literacy desc) Literacy_Rank from shreya..Data1$) a

where a.Literacy_Rank in (1,2,3) order by state