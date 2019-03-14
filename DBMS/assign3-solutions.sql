
/*
Q1
*/
create view v1 (eid)  as
select eid
from Managers M
where 	(select count(*) from Departments  where eid = M.eid) =
	(select count(*) from Projects where eid = M.eid)
;


/*
Q2
Collaborators(eid, eid2) stores pairs of collaborators.
The left outer join is necessary to preserve engineers who do have any collaborators.
*/
create view v2 (eid, num)  as
with Collaborators as (
	select distinct E.eid as eid, W2.eid as eid2
	from Engineers E left outer join 
		(Works W1 join Works W2 on W1.pid = W2.pid and W1.eid <> W2.eid)
		on E.eid = W1.eid
)
select eid, count(eid2) as num
from Collaborators 
group by eid
;



/* 
Q3
MgrInfo(oid, numMgr) stores the number of managers located in each office. 
EngrInfo(oid, numEngr) stores the number of engineers located in each office. 
The left outer join for computing MgrInfo is necessary to preserve departments that do not have any managers belonging to it.
Similarly, the left outer join for computing EngrInfo is necessary to preserve departments that do not have any engineers belonging to it.
*/
create view v3 (oid, numDept, numEmp, numMgr, numEngr) as
with MgrInfo as (
	select  D.oid, count(distinct M.eid) as numMgr
	from Departments D left outer join (Employees E join Managers M on E.eid = M.eid) on D.did = E.did
	group by D.oid
),
EngrInfo as (
	select  D.oid, count(EE.eid) as numEngr
	from Departments D left outer join (Employees E join Engineers EE on E.eid = EE.eid)
		on D.did = E.did
	group by D.oid
)
select  D.oid, count(distinct D.did) as numDept, count(E.eid) as numEmp, 
	MI.numMgr, EI.numEngr
from (Departments D join Employees E on D.did = E.did) 
	join MgrInfo MI on D.oid = MI.oid
	join EngrInfo EI on D.oid = EI.oid
group by D.oid, MI.numMgr, EI.numEngr
;

/*
Q4
*/
create view v4 (eid)  as
select D.eid
from  Departments D join Employees E 
	on (D.did = E.did) and (E.eid = D.eid)
;

/*
Q5
*/
create view v5 (pid)  as
select  P.pid
from  Projects P
where not exists (
	/* some engineer who works on P but does not specialize in 'A' */
	select	1
	from 	Works W
	where	W.pid = P.pid
	and	W.eid not in (
		select	eid
		from 	Specializes
		where	aid = 'A'
	)
)
;

/*
Q6
*/
create view v6 (eid, eid2)  as
select E1.eid, E2.eid
from Engineers E1,  Engineers E2  
where E2.eid in (select eid from Specializes)
and not exists (
	/* some area that S2 specializes in but S1 does not specialize in */
	select 	1
	from 	Specializes S2 
	where 	S2.eid = E2.eid
	and	S2.aid not in (
		select 	aid
		from 	Specializes S1 
		where 	S1.eid = E1.eid
	)
) and exists (
	/* some area that S1 specializes in but S2 does not specialize in */
	select 	1
	from 	Specializes S1 
	where 	S1.eid = E1.eid
	and	S1.aid not in (
		select 	aid
		from 	Specializes S2
		where 	S2.eid = E2.eid
	)
)
;



/*
Q7
*/
create view v7 (eid, mid)  as
select  E.eid, M.eid
from (Engineers E  join Employees EE on E.eid = EE.eid)
	join (Managers M join Employees EM on M.eid = EM.eid)
	on EE.did = EM.did
where E.eid in (select eid from Works)
and not exists (
	/* some project that E works on but not managed by M */
	select	1
	from 	Works W
	where	W.eid = E.eid
	and 	W.pid not in (select pid from Projects where eid = M.eid)
)
and not exists (
	/* some project that M manages but E does not not work on it */
	select	1
	from 	Projects P
	where	P.eid = M.eid
	and 	P.pid not in (select pid from Works where eid = E.eid)
);


/*
Q8
*/
create view v8 (eid, eid2) as
select  E1.eid, E2.eid
from Engineers E1 join Engineers E2 on E1.eid <> E2.eid
where exists (
	/* some project that both E1 & E2 work on */
	select 1
	from 	Works W1 join Works W2 on W1.pid = W2.pid
		and W1.eid = E1.eid and W2.eid = E2.eid
	)
and not exists (
	/* some project that both E1 & E2 work on where E1's hours is not higher than E2's */
	select 	1
	from 	Works W1 join Works W2 on W1.pid = W2.pid
		and W1.eid = E1.eid and W2.eid = E2.eid
		and W1.hours <= W2.hours
)
;


/*
Q9
Candidates(eid, did, numHours) records an engineer (identified by eid) from department did where numHours (the engineer's total weekly project hours) is at most 20.
The left outer join is necessary to preserve engineers who are not working on any project.
The use of coalesce function is necessary as engineers may not be working on any project.
*/
create view v9 (eid, eid2)  as
with Candidates as (
	select E.eid, E.did, coalesce(sum(W.hours),0) as numHours
	from (Engineers EE join Employees E on EE.eid = E.eid) left outer join Works W on EE.eid = W.eid
	group by E.eid
	having coalesce(sum(W.hours),0) <= 20
)
select C1.eid, C2.eid
from Candidates C1 join Candidates C2 on C1.eid < C2.eid
	and C1.did = C2.did
	and C1.numHours + C2.numHours <= 30
;




/*
Q10
Budget(eid, deptBudget, projectBudget) records the two budgets associated with each manager (identified by eid).
The use of coalesce function is necessary as a manager may not be managing any department or may not be supervising any project.
*/
create view v10 (eid)  as
with Budget as (
	select	M.eid, 
		coalesce((select sum (D.dbudget) 
			from 	Departments D
			where	D.eid = M.eid),0) as deptBudget,
		coalesce((select sum (P.pbudget) 
			from 	Projects P
			where	P.eid = M.eid),0) as projectBudget
	from	Managers M
	group by M.eid
)
select 	M.eid
from  	Managers M natural join Budget B 
where	((B.deptBudget > 0) or (B.projectBudget > 0))
and 	not exists (
	/* some other manager B2.eid has more resources than M.eid */
	select	1
	from 	Budget B2
	where	(B2.deptBudget > B.deptBudget and B2.projectBudget >= B.projectBudget)
	or	(B2.deptBudget >= B.deptBudget and B2.projectBudget > B.projectBudget)
)
;


