create schema if not exists public_1;
create table if not exists public_1.contest_info (
	id serial primary key,
	name varchar(100) not null,
	date_event date not null);
create table if not exists public_1.participant (
	id serial primary key,
	surname varchar(100) not null,
	name varchar(100) not null,
	birthday date not null,
	sex char(1) check (sex in('M','F')));
create table if not exists public_1.task (
	task_id serial not null,
	contest_id int not null references public_1.contest_info(id),
	name_task varchar(100) not null,
	description_task varchar(100) not null,
	primary key (contest_id,task_id));	
create table if not exists public_1.solution(
	contest_id int not null,
	task_id int not null,
	participant_id int references public_1.participant(id),
	text_decision text not null,
	name_language_programm varchar(100) not null,
	version_language integer not null,
	grade int check(grade between 0 and 100),
	comment text,
	primary key (contest_id,task_id, participant_id),
	foreign key (contest_id,task_id)
	references public_1.task(contest_id,task_id));
 insert into public_1.contest_info(id,name,date_event)
 values (1,'Contest 03.11.2025','2025-11-03'),
 (2,'Summer Contest','2025-07-15'),
 (3, 'Winter Contest', '2025-01-10'),
 (4, 'поставьте 3 плиз', '2025-08-20'),
 (5,'no way back','2025-11-03'),
 (6, 'памагити((9(9', '2025-09-10');
insert into public_1.participant(id, surname, name, birthday, sex) values
(1, 'иванов', 'ваня', '2000-05-10', 'M'),
(2, 'петров', 'никита', '2001-11-20', 'M'),
(3, 'кузнецов', 'федя', '2001-11-22', 'M'),
(4, 'смирнова', 'маша', '2002-06-30', 'F'),
(5, 'кузнецова', 'алина', '2000-05-15', 'F'),
(6, 'Demchenko', 'никитаа', '1998-12-12', 'F'),
(7, 'орлов', 'миша', '1999-09-09', 'M'),
(8, 'римский', 'дмитрий', '2000-01-01', 'M'),
(9, 'иыванова', 'елена', '2001-04-04', 'F'),
(10, 'петров', 'сергей', '2002-02-02', 'M');
insert into public_1.task(contest_id,task_id,name_task,description_task)
values (1,1,'task a', 'описание задачи а переменная и значение'),
(1,2,'task f', 'описание задачи f значение'),
(1,3,'task c', 'описание задачи c переменная и значение'),
(2,1,'task r', 'описание задачи r переменная'),
(2,2,'task p', 'описание задачи p переменная и значение'),
(3,1,'task o', 'описание задачи o переменная и значение'),
(3,2,'task e', 'описание e переменная и значение'),
(4,1,'task a', 'описание задачи а переменная и значение'),
(5,1,'task u', 'описание задачи u переменная и значение'),
(5,2,'task a', 'описание задачи а переменная и значение'),
(6,1,'task yy', 'описание задачи yy переменная и значение'),
(6,2,'task eeee', 'описание задачи eee переменная и значение');
insert into public_1.solution(contest_id, task_id, participant_id, text_decision, name_language_programm, version_language, grade, comment) 
values
(1,1,1,'text1','Py***n',3,95,'GOOD'),
(1,2,1,'text2','C#',3,100,'GOOD'),
(1,3,2,'text3','C',99,85,'GOOD'),
(1,1,3,'text4','C',99,100,'GOOD'),
(2,1,4,'text2','Py***n',3,80,'где лабы?'),
(2,2,5,'text1','C++',99,90,'GOOD'),
(4,1,6,'texttt','Py***n',3,70,'BAD'),
(5,1,6,'unsigned double','C++',11,0,'BAD'),
(5,2,6,'unsigned double','C++',11,0,'GOOD'),
(6,1,7,'texxt','C',99,70,'GOOD'),
(6,2,7,'text5','Py***n',3,90,'GOOD'),
(1,1,8,'text','Py***n',3,85,'Good'),
(1,2,9,'text','Py***n',3,90,'Good'),
(2,1,10,'text','C++',99,100,'bad'),
(3,2,10,'text','C',99,95,'goof'),
(2,2,4,'text','Py***n',3,52,'где лабы?');

--1.Найти всех участников контестов от 03.11.2025 мужского пола, которым уже исполнилось 18 лет.
select distinct p.surname, p.name from public_1.participant p
inner join public_1.solution s on p.id=s.participant_id
inner join public_1.task t on t.task_id =s.task_id
inner join public_1.contest_info ci on ci.id = t.contest_id 
where ci.date_event = '2025-11-03' and p.sex = 'M' and 
p.birthday  <= ci.date_event - interval '18 years';
--2. Найти все задачи, в описании которых присутствуют подстроки “переменная” и “значение”.
select t.name_task, t.description_task 
from public_1.task t 
where t.description_task like '%переменная%'  
and t.description_task like '%значение%';
--3.Найти фамилии, имена и возраст (кол-во полных лет) всех участников, участвовавших хотя бы в трёх контестах.
select p.surname,p.name, extract(year from age(current_date, p.birthday)) as age_p
from public_1.participant p 
inner join public_1.solution s on p.id = s.participant_id
inner join public_1.task t on t.task_id= s.task_id
inner join public_1.contest_info ci on ci.id=t.contest_id
group by p.id
having count(ci.id)>=3;
--4.Найти все задачи, которые были хотя бы раз решены на высший балл (100).
select distinct t.name_task, s.grade from public_1.task t
inner join public_1.solution s on t.contest_id=s.contest_id and t.task_id = s.task_id
where s.grade=100;
--5.Найти все задачи, которые ни разу не были решены хотя бы на 52 балла на языке программирования “Py***n”. 
select t.name_task
from public_1.task t 
left join public_1.solution s on t.contest_id=s.contest_id and t.task_id=s.task_id and s.name_language_programm ='Py***n' and s.grade>=52
where  s.task_id is null;
--6. Найти все названия контестов, которые проводились летом. 
select ci.name from public_1.contest_info ci
where extract(month from date_event) in (6,7,8);
--7. Найти все пары, состоящие из языка программирования и его версии, на которых были решены хотя бы две задачи на 85 баллов и выше. 
select s.name_language_programm, s.version_language
from public_1.solution s 
where s.grade>=85
group by s.name_language_programm , s.version_language 
having count(*)>=2;
--8. Найти все задачи, в решении которых на языке программирования “C” версии “C99” используется инструкция “#include <string.h>”.
select distinct t.name_task from public_1.task t 
inner join public_1.solution s on s.task_id=t.task_id and t.contest_id =s.contest_id
where s.name_language_programm ='C' and s.version_language = '99' and s.text_decision  like '%#include <string.h>%';
--9.Найти контесты, в которых хотя бы три участника решили все задачи на одном и том же языке программирования одной и той же версии, средний балл за которые превышает 75 и ни одна задача не решена менее чем на 50 баллов. 
select ci.id, ci.name from public_1.contest_info ci
inner join public_1.solution s on s.contest_id = ci.id
group by ci.id, ci.name, s.name_language_programm, s.version_language
having count(s.participant_id) >= 3 and min(s.grade) >= 50 and avg(s.grade) > 75;
--10. Найти все языки программирования, которые использовались в контесте с названием “поставьте 3 плиз”.  
select s.name_language_programm from public_1.solution s
inner join public_1.contest_info ci on ci.id=s.contest_id
where ci.name = 'поставьте 3 плиз';
--11. Найти всех участников контеста с названием “памагити((9(9”, которые решили все задачи контеста минимум на 45 баллов, и все задачи решены на разных языках программирования, либо на разных версиях одного и того же языка программирования. 
select p.id, p.surname,p.name 
from public_1.participant p
inner join public_1.solution s on s.participant_id = p.id 
inner join public_1.contest_info ci  on ci.id = s.contest_id 
where ci.name = 'памагити((9(9'
group by p.id,p.surname,p.name,ci.id
having count(*) = (
select count(*) 
from public_1.task t
where t.contest_id = ci.id) 
and min(s.grade)>=45 and (count(s.name_language_programm) > 1
or count( s.version_language) > 1);
--12. Найти всех девушек, решивших хотя бы 3 задачи любого одного контеста на 52 балла и выше.
select p.name,p.surname from public_1.participant p  
inner join public_1.solution s on p.id=s.participant_id 
where p.sex = 'F' and s.grade >=52
group by p.id,s.contest_id 
having count(*)>=3;
--13.
select distinct p.id, p.surname, p.name from public_1.participant p
inner join public_1.solution s on s.participant_id = p.id
inner join public_1.contest_info ci on ci.id = s.contest_id
inner join public_1.task t on t.contest_id = ci.id and t.task_id = s.task_id
where p.surname = 'Demchenko'and ci.name = 'no way back' and ci.date_event = '2025-11-03'
and s.text_decision like '%unsigned double%' 
and s.name_language_programm = 'C++' and s.grade=0;
--14. Найти все задания со средней оценкой от 80 до 85 баллов среди всех его решений хотя бы на 70 баллов. 
select t.name_task from public_1.task t 
inner join public_1.solution s on s.task_id=t.task_id and t.contest_id =s.contest_id
where s.grade>=70
group by t.contest_id,t.task_id,t.name_task
having avg(s.grade) between 80 and 85;
--15. Найти все задания, любой комментарий проверяющего которое содержит подстроку “где лабы?”.
select t.name_task from public_1.task t 
inner join public_1.solution s on s.task_id=t.task_id and t.contest_id =s.contest_id
where s.comment like '%где лабы?%';

