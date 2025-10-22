--1.
select s.* from student s
inner join "group" g on s.id_group = g.id 
where g.course =3;
--2.
select g.cipher, count(s.id) as all_id from "group" g
inner join student s on s.id_group = g.id 
group by g.id 
having count(s.id)>=10;
--3.
select sub.title, avg(m.grade) as avgg from subject sub
inner join marks m on sub.id = m.subj_id
where sub.type_of_reporting = 'exam' and 
m.semester_number = 4
group by sub.title 
having avg(m.grade)>3.5;
--4.
select s.id,s.surname,s.name from student s
inner join marks m on s.id = m.stud_id
inner join subject sub  on m.subj_id = sub.id
where sub.type_of_reporting = 'exam' and 
m.semester_number =3
group by s.id,s.surname,s.name
having min(m.grade)=5
limit 10;
--5.
select distinct sub.title from subject sub
inner join marks m on m.subj_id = sub.id 
inner join student s on s.id= m.stud_id
inner join "group" g on g.id= s.id_group
where (g.course =3 or g.course=4) and 
sub.type_of_reporting   = 'paper';
--6.
select semester_number 
from (
select m.semester_number,s.id,avg(m.grade) as avgg from marks m
inner join student s on s.id=m.stud_id 
inner join subject sub on sub.id=m.subj_id 
inner join "group" g on g.id = s.id_group 
where g.cipher = 'ИТПМ-124' and sub.type_of_reporting ='exam'
group by m.semester_number , s.id 
having avg(m.grade)>4.5) as stud_avgg
group by semester_number
having count(*)>=3;
--7.
select s.* from student s
inner join "group" g on s.id=s.id_group
where (g.course =2 or g.course=4) and s.gender = 'M'
order by s.birthday 
limit(5);
--8.
select sub.title, round(avg(m.grade),2) as avgg from marks m
inner join subject sub on sub.id =m.subj_id
inner join student s on s.id=m.subj_id 
inner join "group" g on g.id = s.id_group 
where g.cipher = 'ИТПМ-124'
group by sub.title 
having round(avg(m.grade),2) between 3.0 and 4.0;
--9.
select s.surname, s.name from student s
inner join marks m on s.id = m.stud_id 
inner join subject sub on sub.id = m.subj_id 
where m.semester_number = 3 and sub.title = 'Базы данных'
 and m.grade=2;
--10.
select s.surname,s.name from student s 
inner join marks m on s.id = m.stud_id 
inner join subject sub on sub.id = m.subj_id 
where m.semester_number  = 4 and sub.title = 
'Защита информации ' and m.grade >2 and sub.type_of_reporting = 'paper';
--11.
select distinct s.* from student s
inner join marks m on s.id = m.stud_id 
inner join subject sub on sub.id = m.subj_id
where m.grade=2 and sub.type_of_reporting = 'exam';
--12.
select distinct g.cipher from "group" g
inner join student s on g.id = s.id_group 
inner join marks m on m.stud_id = s.id 
join subject sub on sub.id = m.subj_id 
where sub.type_of_reporting ='paper' and m.grade =2;
--13.
select distinct sub.title from subject sub
inner join marks m on sub.id= m.subj_id
where m.grade = 2 and m.stud_id in 
(select stud_id from marks where grade =2 group by stud_id having count(*)>1);
--14. 
select s.surname,s.name, avg(m.grade) as avgg from marks m
inner join student s on m.stud_id = s.id 
inner join "group" g on g.id = s.id_group 
where g.cipher = 'ИТПМ-124' and m.semester_number =3
group by s.id
order by (avgg) desc;
--15.
select avg(m.grade) as avgg from marks m
inner join student s on m.stud_id = s.id 
inner join subject sub on sub.id=m.subj_id
where sub.title = 'Дифференциальные уравнения' and s.name = 'Давид';
--16.
select s.name,s.surname, avg(m.grade) as avgg from student s
inner join marks m on m.stud_id = s.id 
where s.name like '%Степан%'
group by s.id;
--17.
--18.
select sub.title, count(*) as all_count from subject sub
inner join marks m on sub.id = m.subj_id
where sub.type_of_reporting = 'rating' and m.grade = 2
group by sub.title
having count(*) >= 5;









