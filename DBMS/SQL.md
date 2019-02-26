## SQL语句复习

### 1. EXISTS
Find distinct customers who like some pizza sold by "Corleone Corner"<br/>
Likes(cname, pizza)<br/>
Sells(rname,pizza,price)<br/>
方法一：
```SQL
select distinct cname
from Likes L
where exists(
    select 1
    from Sells S
    where S.rname = 'Corleone Corner'
    and S.pizza = L.pizza
);
```
方法二：
```SQL
select distinct L.cname
from Likes L inner join Sells S
    on S.pizza = L.pizza
where S.rname = 'Corleone Corner'
```

### 2. NOT EXISTS
Find distinct customers who do not like any pizza sold by "Corleone Corner" <br/>
Customers(cname,area)<br/>
Likes(cname,pizza)<br/>
Sells(rname,pizza,price)<br/>
方法1：
```SQL
select cname
from customers C
where not exists(
    select 1
    from Likes L natural join Sells S
    where S.rname = 'Corleone Corner'
    and L.cname = C.cname
);
```
方法2：
```SQL
select cname from Customers
except
select cname 
from Likes natural join Sells
where rname = 'Corleone Corner';
```

### 3. IN
Find distinct customers who like pizza sold by "Corleone Corner"
```SQL
select distinct cname
from Likes
where pizza in (
    select pizza
    from Sells
    where rname = 'Corleone Corner'
);
```
**Other forms of IN Predicate**:<br/>
e.g.Find pizza that contains ham or seafood.<br/>
1.
```SQL
select distinct pizza from Contains
where ingredient in ('ham','sea food');
```
2.
```SQL
select distinct pizza from Contains
where ingredient = 'ham' or ingredient = 'seafood';
```
3. 
```SQL
select pizza from Contains where ingredient = 'ham'
union
select pizza from Contains where ingredient = 'seafood';
```
### 4. ANY/SOME
Find distinct restaurants that sell some pizza P1 that is more expensive than some pizza P2 sold by "CC". P1 and P2 are not necessarily the same pizza. Exclude "CC" from the query list.<br/>
Sells(rname,pizza,price)<br/>
方法1：
```SQL
select distinct rname
from Sells
where rname <> "CC"
and price > any(
    select price
    from Sells
    where rname = "CC"
);
```
方法2:
```SQL
select distinct rname
from Sells S1
where rname <> 'CC'
and exists(
    select 1
    from Sells S2
    where S2.rname = 'CC'
    and S1.price > S2.price
);
```
### 5. ALL
For each restaurant, find the name and price of its most expensive pizzas. Exclude restaurants that do not sell any pizza.<br/>
Sells(rname,pizza,price)<br/>
```SQL
select rname,pizza,price
from Sells S1
where price >= all (
    select S2.price
    from Sells S2
    where S2.rname = S1.rname
);
```
### 6. UNIQUE
Find distinct pizzas that are sold by at most one restaurant in each area;exclude pizzas that are not sold by any restaurant.<br/>
Sells(rname,pizza,sells)<br/>
Restaurants(rname,area)<br/>
```SQL
select distinct pizza
from Sells S
where unique(
    select R.area
    from Restaurants R natural join Sells S2
    where S2.pizza = S.pizza
);
```
### 7. Scalar
For each restaurant that sells Funghi, find its name, area,and selling price.
方法1：
```SQL
select R.rname, R.area, S.price
from Sells S natural join Restaurants R
where S.pizza = 'Funghi';
```
方法2：
```SQL
select rname,
       (select R.area from Restaurants R
        where R.rname = S.rname), price
from Sells S
where pizza = 'Funghi';
```
