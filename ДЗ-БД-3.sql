
CREATE TABLE IF NOT EXISTS public.service
(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.subscription
(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price MONEY NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.client
(
    id SERIAL NOT NULL PRIMARY KEY,
    surname VARCHAR(150) NOT NULL,
    name VARCHAR(150) NOT NULL,
    sex BOOL NOT NULL,
    birthday DATE NOT NULL,
    subscription_id INT NOT NULL,
    subscription_start DATE NOT NULL,
    subscription_end DATE NOT NULL,
    FOREIGN KEY(subscription_id) REFERENCES public.subscription(id)
);

CREATE TABLE IF NOT EXISTS public.sub_to_service
(
    sub_id INT NOT NULL,
    service_id INT NOT NULL,
    PRIMARY KEY (sub_id, service_id),
    FOREIGN KEY(sub_id) REFERENCES public.subscription(id),
    FOREIGN KEY(service_id) REFERENCES public.service(id)
);

-- === Таблица service ===
INSERT INTO public.service (name) VALUES
('Тренажёрный зал'),
('Бассейн'),
('Групповые занятия'),
('Йога'),
('Сауна'),
('Массаж'),
('Персональный тренер'),
('Кроссфит'),
('Бокс'),
('Танцы');

-- === Таблица subscription ===
INSERT INTO public.subscription (name, price, description) VALUES
('Базовый', 30.000, 'Доступ в тренажёрный зал.'),
('Стандарт', 45.000, 'Зал + групповые занятия.'),
('Премиум', 60.000, 'Зал, бассейн и сауна.'),
('VIP', 10.000, 'Все услуги, включая персонального тренера.'),
('Йога+', 40.000, 'Йога и групповые занятия.'),
('Аква', 500.0, 'Бассейн и аквааэробика.'),
('Тело+', 700.00, 'Массаж + тренажёрный зал.'),
('Кроссфит-профи', 800.00, 'Кроссфит и персональные тренировки.'),
('Боец', 650.00, 'Бокс и тренажёрный зал.'),
('Танцы+', 55000, 'Танцы и групповые занятия.');

-- === Таблица client ===
INSERT INTO public.client (surname, name, sex, birthday, subscription_id, subscription_start, subscription_end) VALUES
('Иванов', 'Алексей', TRUE, '1990-05-12', 1, '2025-01-10', '2025-04-10'),
('Петрова', 'Мария', FALSE, '1995-08-22', 3, '2025-02-01', '2025-05-01'),
('Сидоров', 'Николай', TRUE, '1988-03-03', 2, '2025-03-15', '2025-06-15'),
('Кузнецова', 'Анна', FALSE, '1992-07-11', 4, '2025-04-01', '2025-07-01'),
('Волков', 'Дмитрий', TRUE, '1985-12-20', 5, '2025-02-20', '2025-05-20'),
('Морозова', 'Екатерина', FALSE, '1998-01-09', 6, '2025-03-10', '2025-06-10'),
('Орлов', 'Игорь', TRUE, '1991-11-05', 7, '2025-01-15', '2025-04-15'),
('Соколова', 'Елена', FALSE, '1999-09-30', 8, '2025-03-01', '2025-06-01'),
('Тарасов', 'Павел', TRUE, '1987-04-17', 9, '2025-02-05', '2025-05-05'),
('Федорова', 'Ольга', FALSE, '1996-06-14', 10, '2025-01-25', '2025-04-25');

-- === Таблица sub_to_service ===
INSERT INTO public.sub_to_service (sub_id, service_id) VALUES
(1, 1),  -- Базовый: тренажёрный зал
(2, 1), (2, 3),  -- Стандарт: зал + групповые
(3, 1), (3, 2), (3, 5),  -- Премиум
(4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6), (4, 7), (4, 8), (4, 9), (4, 10),  -- VIP — все
(5, 3), (5, 4),  -- Йога+
(6, 2), (6, 3),  -- Аква
(7, 1), (7, 6),  -- Тело+
(8, 1), (8, 7), (8, 8),  -- Кроссфит-профи
(9, 1), (9, 9),  -- Боец
(10, 3), (10, 4);  -- Танцы+

--1.
select distinct c.surname
from public.client c
join public.subscription s on c.subscription_id = s.id 
where s.name = 'demo.sub';
--2.
select * from public.client 
where extract(year from subscription_end)= extract(year from current_date);
--3.
select s.id ,s.name, count(c.id) as count_client
from public.subscription s 
inner join public.client c on s.id=c.subscription_id 
group by s.id, s.name
having count(c.id)>=10;
--4.
select s.id,s.name, count(sub_s.service_id) as count_service
from public.subscription s
inner join public.sub_to_service sub_s on s.id = sub_s.sub_id
group by s.id,s.name
having count(sub_s.service_id)>=5;
--5.
select c.surname,c.name from public.client c
inner join public.subscription s on c.subscription_id=s.id 
inner join public.sub_to_service sts on sts.sub_id = s.id 
inner join public.service ser on ser.id = sts.service_id 
where c.sex= true and s.name = 'отчислиться на АиСД';
--6.
select sub.name as subscription_name, s.name as service_name
from public.subscription sub
inner join  public.sub_to_service sub_t on sub.id = sub_t.sub_id
inner join public.service s on s.id = sub_t.service_id;
--7.
select c.name, c.surname
from public.client c
where subscription_end < current_date;
--8.
select c.surname,c.name from public.client c
inner join public.subscription s on s.id=c.subscription_id 
inner join public.sub_to_service sts on sts.sub_id=s.id 
inner join public.service ser on ser.id = sts.service_id
where ser.name = 'ПМИ'and c.subscription_end = '2025-11-03';
--9.????
select c.name,c.surname,s.price from public.client c
inner join public.subscription s on s.id = c.subscription_id 
where s.price::numeric > 52.000
order by c.name,c.surname;
--10.
select c.name,c.surname from public.client c
inner join public.subscription s on s.id =c.subscription_id 
inner join public.sub_to_service sts on sts.sub_id =s.id
where c.sex=false and sts.service_id = 3;
--11.
create or replace view active_service as
select distinct s.id,s.name
from public.service s
inner join public.sub_to_service sts on s.id=sts.service_id
inner join public.subscription sub on sts.sub_id = sub_id
inner join public.client c on c.subscription_id = sub.id;

--12.
update public.client 
set subscription_id =  2,
subscription_start = '2015-03-23',
subscription_end ='2025-07-08'
where id = 11;

--13.
 update public.client 
 set subscription_id = (select id from public.subscription where name = 'Базовый' limit 1),
 subscription_start = '2000-08-09',
 subscription_end = '2024-03-04'
 where id = 12;
--14.

select count(c.id) as count_id from public.client c
inner join public.subscription s on c.subscription_id = s.id
inner join public.sub_to_service sts on sts.sub_id=s.id 
inner join public.service ser on ser.id = sts.service_id
where c.sex=true and ser.name = 'Бонусы для 2 курса' and
extract(year from (NOW() - c.birthday)) > 35;

--15.??
select sub.id,sub.name from public.subscription sub
inner join public.sub_to_service sts  on sub.id = sts.sub_id 
inner join public.client c on c.subscription_id = sub.id 
where sub.price:: numeric>85.000
