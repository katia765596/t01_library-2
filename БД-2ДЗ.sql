-- 1.задание
insert into public.author (surname,name) values ('Фамилия','Имя') returning id;
update public.author set surname = 'Фамилия изм', name = 'Имя изм' where id =1;
delete from public.author where id =1;
--2.задание
insert into public.publishing_house (name,city) values('Издательство','Город') returning id; 
update public.publishing_house set name ='Издательство изм', city = 'Город изм' where id = 1;
delete from public.publishing_house where id=5;
-- 3.задание
insert into public.book (title,author_id ,publishing_house_id,edition,year,print_run ) values('Назание',5,1,'Издание',2025,10) returning id;
update public.book set title = 'Название изм',edition = 'Издание изм',year=2026,print_run=12 where id=1;
delete from public.book where id =1;
-- 4. задание
insert into  public.reader (ticket_number,surname,name,birth_date,gender,registration_date) values('qwerty','Фамилия','Имя','2006-06-27','F', current_date ) returning ticket_number;
update public.reader set surname = 'Фамилия изм', name = 'Имя изм' where ticket_number = 'qwerty';
delete from public.reader where ticket_number ='qwerty';
-- 5. задание
insert into public.book_instance (inventory_number ,book_id,state,status,location) values('12345',4,'отличное','в наличии','зал2') returning inventory_number ;
update public.book_instance set state = 'хорошее', location = 'зал4' where inventory_number ='12345';
delete from public.book_instance where inventory_number ='12345';
--6. задание
create or replace procedure i_book(
_ticket_number varchar(20),
_inventory_number varchar(50),
_expected_return_date date)
language plpgsql as $$
begin 
	if (select status from public.book_instance where inventory_number = _inventory_number)!='в наличии' then raise exception 'Экземпляра нет';
	end if;
	insert into public.issuance (ticket_number,inventory_number,issue_datetime,expected_return_date,actual_return_date) values(_ticket_number,_inventory_number,current_timestamp,_expected_return_date,null);
	update public.book_instance set status='выдана' where inventory_number = _inventory_number;
end;
$$;
--7.задание
create or replace procedure return_book(_ticket_number varchar(20),_inventory_number varchar(50))
language plpgsql as $$
begin
    if not exists (select 1 from public.issuance where ticket_number = _ticket_number and inventory_number = _inventory_number and actual_return_date is null) then raise exception 'Книга не выдана или возвращена';
    end if;
    update public.issuance set actual_return_date = current_date where ticket_number = _ticket_number and inventory_number = _inventory_number and actual_return_date is null;
    update public.book_instance set status = 'в наличии' where inventory_number = _inventory_number;
end;
$$;
--8.задание
create or replace view i_books as
select 
    concat(r.surname, ' ', r.name) as rfio,
    concat(a.surname, ' ', a.name) as aname,
    b.title as book_name,
    bi.state as book_state,
    i.issue_datetime as issue_date
from public.issuance i
join public.reader r on i.ticket_number = r.ticket_number
join public.book_instance bi on i.inventory_number = bi.inventory_number
join public.book b on bi.book_id = b.id
join public.author a on b.author_id = a.id
where i.actual_return_date is null;
--9.задание
create or replace view o_books as
select 
    concat_ws(' ', r.surname, r.name) as r_name,
    concat_ws(' ', a.surname, a.name) as a_name,
    b.title as book_name,
    current_date - i.expected_return_date as d_late
from public.issuance i
join public.reader r on i.ticket_number = r.ticket_number
join public.book_instance bi on i.inventory_number = bi.inventory_number
join public.book b on bi.book_id = b.id
join public.author a on b.author_id = a.id
where i.actual_return_date is null
  and i.expected_return_date < current_date;
--10.задание
create or replace procedure i_book(
    _ticket_number varchar(20),
    _inventory_number varchar(50),
    _expected_return_date date)
language plpgsql as $$
begin
    if exists (select 1 from o_books where rfio = (select surname || ' ' || name from public.reader where ticket_number = _ticket_number)) then raise exception 'есть просрочки';
    end if;
    if (select status from public.book_instance where inventory_number = _inventory_number) != 'в наличии' then raise exception 'не в наличии';
    end if;
    insert into public.issuance (ticket_number, inventory_number, issue_datetime, expected_return_date, actual_return_date)
    values (_ticket_number, _inventory_number, current_timestamp, _expected_return_date, null);
    update public.book_instance set status = 'выдана' where inventory_number = _inventory_number;
end;
$$;
--11.задание
create or replace procedure b_booking(
    _ticket_number varchar(20),
    _inventory_number varchar(50),
    _min_state varchar(50))
language plpgsql as $$
declare v_book_id integer;
begin
    select book_id into v_book_id from public.book_instance where inventory_number = _inventory_number;
    if (select status from public.book_instance where inventory_number = _inventory_number) != 'в наличии' or 
       (select state from public.book_instance where inventory_number = _inventory_number) not in (select unnest(enum_range(NULL::book_state)) where unnest >= _min_state::book_state) then
        raise exception 'не подходит';
    end if;
    insert into public.booking (ticket_number, book_id, min_state, booking_datetime) values (_ticket_number, _book_id, _min_state, current_timestamp);
    update public.book_instance set status = 'забронирована' where inventory_number = _inventory_number;
end;
$$;
--12.задание
create or replace procedure otm_booking(
    _ticket_number varchar(20),
    _inventory_number varchar(50))
language plpgsql as $$
declare v_book_id integer;
begin
    select book_id into v_book_id from public.book_instance where inventory_number = _inventory_number;
    delete from public.booking where ticket_number = _ticket_number and book_id = v_book_id;
    update public.book_instance set status = 'в наличии' where inventory_number = _inventory_number;
end;
$$;
--13.задание
--14.задание
create or replace function book_location(p_book_id integer)
returns table (location varchar, state book_state) as $$
select location, state from public.book_instance where book_id = p_book_id order by case state
    when 'отличное' then 1
    when 'хорошее' then 2
    when 'удовлетворительное' then 3
    when 'ветхое' then 4
    when 'утеряна' then 5
end;
$$ language sql;
--15.задание
create or replace view cvob_books as
select 
    b.id as book_id,
    b.title,
    bi.state,
    count(*) as count
from public.book_instance bi join public.book b on bi.book_id = b.id where bi.status = 'в наличии'
group by b.id, b.title, bi.state;
--16. задание
create or replace view long_overdue_books as
select 
    concat_ws(' ', r.surname, r.name) as r_name,
    concat_ws(' ', a.surname, a.name) as a_name,
    b.title as book_title,
    i.issue_datetime
from public.issuance i
join public.reader r on i.ticket_number = r.ticket_number
join public.book_instance bi on i.inventory_number = bi.inventory_number
join public.book b on bi.book_id = b.id
join public.author a on b.author_id = a.id
where i.actual_return_date is null and i.issue_datetime < current_date - interval '1 year';
--17.задание
create table public.logs (
    id serial primary key,
    log_datetime timestamp not null default current_timestamp,
    table_name varchar(100) not null,
    log_message text not null);

