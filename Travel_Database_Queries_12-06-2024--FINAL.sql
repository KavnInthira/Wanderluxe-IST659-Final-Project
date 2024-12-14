/* 
============================================================
Project: Travel Booking System Database Setup
Group Name: Team 5 WanderLuxe
Class: IST-659 Data Admin Concepts & Db Mgmt

Group Members:
    - Elizabeth M Frank - efrank03@syr.edu
    - Freddy E Valle Jr - fevallej@syr.edu
    - Elyse Peterson    - emwarren@syr.edu
    - Jariel S Jacobs   - jjacob27@syr.edu
    - Kavin Inthirakot  - kjinthir@syr.edu

============================================================
*/
----------------------------------------------------------------------------------------------------------
--What are the current bookings intinerary, what was their budget, and how much was they trip they chose?
----------------------------------------------------------------------------------------------------------

select c.client_first_name + ' ' + c.client_last_name as client_name,
    h.hotel_name, e.experience_company, 
    d.destination_city + ', ' + d.destination_country as destination,
    b.booking_budget, h.hotel_price + e.experience_price as trip_total_cost
from bookings b
    join clients c on c.client_id = b.client_id
    join hotels h on h.hotel_id = b.hotel_id
    join experiences e on e.experience_id = b.experience_id
    join destinations d on d.destination_id = b.destination_id


---------------------------------------------
--Who are our VIP booking client, the top 5%
---------------------------------------------

select top 5 percent 
    c.client_first_name + ' ' + c.client_last_name as client_name,
    h.hotel_name, e.experience_company, 
    d.destination_city + ', ' + d.destination_country as destination,
    b.booking_budget, h.hotel_price + e.experience_price as trip_total_cost
from bookings b
    join clients c on c.client_id = b.client_id
    join hotels h on h.hotel_id = b.hotel_id
    join experiences e on e.experience_id = b.experience_id
    join destinations d on d.destination_id = b.destination_id
order by b.booking_budget desc


-----------------------------------
--Most impressive budget-travelers
-----------------------------------

select top 5 percent 
    c.client_first_name + ' ' + c.client_last_name as client_name,
    h.hotel_name, e.experience_company, 
    d.destination_city + ', ' + d.destination_country as destination,
    b.booking_budget, h.hotel_price + e.experience_price as trip_total_cost
from bookings b
    join clients c on c.client_id = b.client_id
    join hotels h on h.hotel_id = b.hotel_id
    join experiences e on e.experience_id = b.experience_id
    join destinations d on d.destination_id = b.destination_id
order by b.booking_budget asc


----------------------------------------------------------------------------------------------------------
--What is the difference between what they had their max budget as compared to the trip price they booked
----------------------------------------------------------------------------------------------------------

select c.client_first_name + ' ' + c.client_last_name as client_name,
    h.hotel_name, e.experience_company, 
    d.destination_city + ', ' + d.destination_country as destination,
    b.booking_budget, h.hotel_price + e.experience_price as trip_total_cost,
    b.booking_budget - (h.hotel_price + e.experience_price) as budget_difference,
    cast((b.booking_budget -(h.hotel_price + e.experience_price)) * 100.0 / b.booking_budget as decimal(5,2)) as percent_difference
from bookings b
    join clients c on c.client_id = b.client_id
    join hotels h on h.hotel_id = b.hotel_id
    join experiences e on e.experience_id = b.experience_id
    join destinations d on d.destination_id = b.destination_id


---------------------------------------------------------------------
--What is the average percent difference between the booking choices
---------------------------------------------------------------------

select h.hotel_rating,
    cast(avg((b.booking_budget - (h.hotel_price + e.experience_price)) * 100.0 / b.booking_budget) as decimal(5,2)) as avg_percent_diff
from bookings b
    join hotels h on h.hotel_id = b.hotel_id
    join experiences e on e.experience_id = b.experience_id
group by h.hotel_rating
having h.hotel_rating in (3, 4, 5)

select e.experience_tier,
    cast(avg((b.booking_budget - (h.hotel_price + e.experience_price)) * 100.0 / b.booking_budget) as decimal(5,2)) as avg_percent_diff
from bookings b
    join hotels h on h.hotel_id = b.hotel_id
    join experiences e on e.experience_id = b.experience_id
group by e.experience_tier
having e.experience_tier in ('High-End', 'Mid-Tier', 'Budget-Friendly')


----------------------------------------------------------------------------------------------------------------
--With a 20% commission off of hotel and experience bookings, what was the total commission off the first month
----------------------------------------------------------------------------------------------------------------

select h.hotel_rating, e.experience_tier,
    cast(sum(h.hotel_price * 0.20) as decimal(8,2)) as hotel_commission,
    cast(sum(e.experience_price * 0.20) as decimal(8,2)) as experience_commission,
    cast(sum((h.hotel_price * 0.20) + (e.experience_price * 0.20)) as decimal(10,2)) as total_commission
from bookings b
    join hotels h on b.hotel_id = h.hotel_id
    join experiences e on b.experience_id = e.experience_id
group by h.hotel_rating, e.experience_tier
order by total_commission desc


------------------------------------------
--Stored Procedure for Inserting Clients
------------------------------------------
drop procedure if exists p_add_client
go

create procedure p_add_client 
(
    @client_email varchar(100),
    @client_phone varchar(20),
    @client_first_name varchar(50),
    @client_last_name varchar(50),
    @client_city varchar(100) = null,
    @client_state varchar(100) = null,
    @client_country varchar(20) = null
) as begin
    begin try
        begin transaction
            insert into clients (client_email, client_phone, client_first_name, client_last_name, client_city,
                client_state, client_country)
            values (@client_email, @client_phone, @client_first_name, @client_last_name,         
                @client_city, @client_state, @client_country)
        commit
    end try
    begin catch
        rollback;
    end catch
end
go

exec p_add_client
    @client_email = 'student.example@syr.edu',
    @client_phone = '(987) 654-3210',
    @client_first_name = 'Stu',
    @client_last_name = 'Dent',
    @client_city = 'Syracuse',
    @client_state = 'NY',
    @client_country = 'Unites States'

select * from clients
    where client_id = 27

delete from clients
where client_email = 'student.example@syr.edu'
    and client_phone = '987-654-3210'
    and client_first_name = 'Stu'
    and client_last_name = 'Dent'
    and client_city = 'Syracuse'
    and client_state = 'NY'
    and client_country = 'Unites States';


-------------------------------------------
--Stored Procedure for Destination options
-------------------------------------------
drop procedure if exists p_WanderLuxe_options;
go

create procedure p_WanderLuxe_options (
    @hotel_star_rating int,
    @experience_tier varchar(50),
    @max_budget decimal(10, 2)
) as
begin
    select 
        h.hotel_name as hotel_name,
        d.destination_city as city,
        d.destination_country as country,
        e.experience_company as experience_company,
        (h.hotel_price + e.experience_price) as trip_cost
    from hotels h
        join experiences e on h.destination_id = e.destination_id
        join destinations d on h.destination_id = d.destination_id
    where h.hotel_rating = @hotel_star_rating
        and e.experience_tier = @experience_tier
        and (h.hotel_price + e.experience_price) <= @max_budget
    order by trip_cost desc;
end;
go

exec p_WanderLuxe_options
    @hotel_star_rating = 5,
    @experience_tier = 'Mid-Tier',
    @max_budget = 3500


------------------------------------------
--Stored Procedure for Inserting Bookings 
------------------------------------------

drop procedure if exists p_insert_booking;
go

create procedure p_insert_booking 
(
    @client_id int,
    @hotel_id int,
    @experience_id int,
    @destination_id int,
    @booking_date date,
    @booking_budget decimal(10, 2),
    @booking_hotel_star int,
    @booking_experience_tier varchar(100),
    @booking_arrival_date date,
    @booking_departure_date date
) as begin
    begin try
        begin transaction
            insert into bookings (client_id, hotel_id, experience_id, destination_id, booking_date, booking_budget, 
                booking_hotel_star, booking_experience_tier, booking_arrival_date, booking_departure_date)
            values (@client_id, @hotel_id, @experience_id, @destination_id, @booking_date, @booking_budget, 
                @booking_hotel_star, @booking_experience_tier, @booking_arrival_date, @booking_departure_date)
        commit
    end try
    begin catch
        rollback;
    end catch
end
go

exec p_insert_booking
    @client_id = 27,
    @hotel_id = 13,
    @experience_id = 14,
    @destination_id = 5,
    @booking_date = '2024-12-06',
    @booking_budget = 3500,
    @booking_hotel_star = 5,
    @booking_experience_tier = 'Mid-Tier',
    @booking_arrival_date = '2025-02-28',
    @booking_departure_date = '2025-03-07';

select * from bookings
    where client_id = 27

---------------------------------------------
--Client payments with transaction integrity
---------------------------------------------
drop procedure if exists p_payment
go 

create procedure p_payment (
    @ClientID int,
    @BookingID int, 
    @PaymentAmount decimal(10, 2),
    @PaymentMethod varchar(50)
) as begin
    begin transaction
    if not exists (select 1 from bookings where booking_id = @BookingID)
    begin
        raiserror ('Booking does not exist or is invalid.', 16, 1)
        rollback transaction
        return
    end
    if exists (select 1 from payments where client_id = @ClientID and payment_date = cast(getdate() as date))
    begin
        raiserror ('Payment already exists for this client on the given date.', 16, 1)
        rollback transaction
        return
    end
insert into payments (client_id, payment_amount, payment_method, payment_date, payment_time)
values (@ClientID, @PaymentAmount, @PaymentMethod, cast(getdate() as date), cast(getdate() as time))
    commit transaction
end
go

exec p_payment 
    @ClientID = 27, 
    @BookingID = 28, 
    @PaymentAmount = 3416.00, 
    @PaymentMethod = 'Credit Card'

select * from payments  
    where client_id = 27

delete from payments
where client_id = 101 
  and payment_amount = 500.00
  and payment_method = 'Credit Card'
  and payment_date = CAST(GETDATE() AS DATE)



---------------------------------------------------------
--Stored Procedure for Destination options for power app
---------------------------------------------------------
drop procedure if exists p_WanderLuxe_options_powerapp
go

create procedure p_WanderLuxe_options_powerapp (
    @hotel_star_rating int,
    @experience_tier varchar(50),
    @max_budget decimal(10, 2)
) as begin
    if not exists (select 1 from hotels h
                                join experiences e on h.destination_id = e.destination_id
                                join destinations d on h.destination_id = d.destination_id
                            where h.hotel_rating = @hotel_star_rating
                            and e.experience_tier = @experience_tier
                            and (h.hotel_price + e.experience_price) <= @max_budget)
    begin
        raiserror ('No destinations match the given criteria.', 16, 1)
        return
    end
    select 
        d.destination_city as city,
        d.destination_country as country,
        h.hotel_name as hotel_name,
        e.experience_company as experience_company,
        e.experience_tier as experience_tier,
        (h.hotel_price + e.experience_price) as trip_cost
    from hotels h
        join experiences e on h.destination_id = e.destination_id
        join destinations d on h.destination_id = d.destination_id
    where h.hotel_rating = @hotel_star_rating
        and e.experience_tier = @experience_tier
        and (h.hotel_price + e.experience_price) <= @max_budget
    order by trip_cost desc
end
go

exec p_WanderLuxe_options_powerapp 
    @hotel_star_rating = 5,
    @experience_tier = 'High-End',
    @max_budget = 300.00;


