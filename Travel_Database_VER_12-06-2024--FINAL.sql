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
---------------------------------------------------
--UP Script
---------------------------------------------------
--Database creation
---------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'travel_db')
BEGIN
    CREATE DATABASE travel_db;
    PRINT 'Created travel_db database.';
END
ELSE
    PRINT 'Database already exists, moving on...';
GO

USE travel_db;
GO
-- -------------------------------------------------
-- Down Script 
-- -------------------------------------------------

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_bookings_payment_id')
    alter table bookings drop constraint fk_bookings_payment_id
if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_bookings_experience_id')
    alter table bookings drop constraint fk_bookings_experience_id
if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_bookings_hotel_id')
    alter table bookings drop constraint fk_bookings_hotel_id
if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_bookings_client_id')
    alter table bookings drop constraint fk_bookings_client_id
drop table if exists bookings

drop table if exists payments

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_experiences_destination_id')
    alter table experiences drop constraint fk_experiences_destination_id
drop table if exists experiences
if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_hotels_destination_id')
    alter table hotels drop constraint fk_hotels_destination_id
drop table if exists hotels

drop table if exists destinations
drop table if exists clients 

-- -------------------------------------------------
-- UP Metadata
-- -------------------------------------------------
-- Define Clients table
-- -------------------------------------------------
CREATE TABLE clients (
    client_id INT IDENTITY NOT NULL,
    client_email VARCHAR(100) UNIQUE,
    client_phone VARCHAR(20) UNIQUE,
    client_first_name VARCHAR(50) NOT NULL,
    client_last_name VARCHAR(50) NOT NULL,
    client_city VARCHAR(100),
    client_state VARCHAR(100),
    client_country VARCHAR(20),
    constraint pk_clients_client_id primary key(client_id),
    constraint u_clients_client_email unique(client_email),
    constraint u_clients_client_phone unique (client_phone)
)
PRINT 'Clients table created.';
GO

-- -------------------------------------------------
-- Define Destinations table
-- -------------------------------------------------
CREATE TABLE destinations (
    destination_id INT IDENTITY NOT NULL,
    destination_country VARCHAR(100) NOT NULL,
    destination_city VARCHAR(100) NOT NULL,
    destination_local_airport VARCHAR(100) NOT NULL
    constraint pk_destinations_destination_id primary key(destination_id)
)
PRINT 'Destinations table created.';
GO

-- -------------------------------------------------
-- Define Hotels table
-- -------------------------------------------------
CREATE TABLE hotels (
    hotel_id INT IDENTITY NOT NULL,
    destination_id INT NOT NULL,
    hotel_name VARCHAR(100) NOT NULL,
    hotel_price DECIMAL(10, 2) NOT NULL,
    hotel_rating INT NOT NULL
    constraint pk_hotels_hotel_id primary key (hotel_id),
    constraint u_hotels_hotel_name unique (hotel_name)
)
alter table hotels
    add constraint fk_hotels_destination_id foreign key (destination_id)
        references destinations(destination_id)
PRINT 'Hotels table created.';
GO

-- -------------------------------------------------
-- Define Experiences table
-- -------------------------------------------------
CREATE TABLE experiences (
    experience_id INT IDENTITY NOT NULL,
    destination_id INT NOT NULL, 
    experience_company VARCHAR(100) NOT NULL,
    experience_tier VARCHAR(50) NOT NULL,
    experience_price DECIMAL(10, 2) NOT NULL
    constraint pk_experiences_experience_id primary key(experience_id)
)
alter table experiences
    add constraint fk_experiences_destination_id foreign key (destination_id)
        references destinations(destination_id)
PRINT 'Experiences table created.';
GO

-- -------------------------------------------------
-- Define Payments table
-- -------------------------------------------------
CREATE TABLE payments (
    payment_id INT IDENTITY NOT NULL,
    client_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_time TIME NOT NULL,
    payment_method VARCHAR(50),
    payment_amount DECIMAL(10, 2) NOT NULL
    constraint pk_payments_payment_id primary key (payment_id)
)
PRINT 'Payments table created.';
GO

-- -------------------------------------------------
-- Define Bookings table
-- -------------------------------------------------
CREATE TABLE bookings (
    booking_id INT IDENTITY NOT NULL,
    client_id INT NOT NULL,
    payment_id INT,
    hotel_id INT NOT NULL,
    experience_id INT NOT NULL,
    destination_id INT NOT NULL,
    booking_date DATE NOT NULL,
    booking_budget DECIMAL(10, 2) NOT NULL,
    booking_hotel_star INT NOT NULL,
    booking_experience_tier VARCHAR(100) NOT NULL,
    booking_arrival_date DATE,
    booking_departure_date DATE
    constraint pk_bookings_booking_id primary key (booking_id),
    constraint ck_bookings_booking_budget check (booking_budget > 0),
    constraint ck_bookings_booking_arrival_date check(booking_arrival_date <= booking_departure_date) 
)
alter table bookings
    add constraint fk_bookings_client_id foreign key (client_id)
        references clients(client_id)
alter table bookings  
    add constraint fk_bookings_hotel_id foreign key (hotel_id)
        references hotels(hotel_id)
alter table bookings
    add constraint fk_bookings_experience_id foreign key (experience_id)
        references experiences(experience_id)
alter table bookings
    add constraint fk_bookings_payment_id foreign key (payment_id)
    references payments(payment_id)
alter table bookings
    add constraint fk_bookings_destination_id foreign key (destination_id)
        references destinations(destination_id)
PRINT 'Bookings table created.';
GO

--select * from clients
--select * from destinations
--select * from experiences
--select * from hotels
--select * from payments
--select * from bookings

-- ------------------------------------------------
-- UP Data
---------------------------------------------------

insert into clients (
    client_email, 
    client_phone,
    client_first_name,
    client_last_name,
    client_city,
    client_state,
    client_country
)
    values
        ('emma.thompson_92@outlook.com', '(212)468-9274', 'Emma', 'Thompson', 'New York', 'NY', 'United States'),
        ('liam.henderson88@gmail.com', '(323)781-6043', 'Liam', 'Henderson', 'Los Angeles', 'CA', 'United States'),
        ('olivia.carter_mail@yahoo.com', '(312)926-3418', 'Olivia', 'Carter', 'Chicago', 'IL', 'United States'),
        ('noah.baker_01@protonmail.com', '(713)847-2951', 'Noah', 'Baker', 'Houston', 'TX', 'United States'),
        ('ava.scott.direct@icloud.com', '(602)375-8126', 'Ava', 'Scott', 'Phoenix', 'AZ', 'United States'),
        ('sophia.collins_live@aol.com', '(267)584-3092', 'Sophia', 'Collins', 'Philadelphia', 'PA', 'United States'),
        ('lucas.fisher.connect@gmail.com', '(210)694-2187', 'Lucas', 'Fisher', 'San Antonio', 'TX', 'United States'),
        ('isabella.grant_57@example.com', '(619) 742-3981', 'Isabella', 'Grant', 'San Diego', 'CA', 'United States'),
        ('ethan.hughes_now@example.com', '(972) 613-4509', 'Ethan', 'Hughes', 'Dallas', 'TX', 'United States'),
        ('mia.peterson_23@example.com', '(408) 337-1928', 'Mia', 'Peterson', 'San Jose', 'CA', 'United States'),
        ('james.evans88@example.com', '(512) 980-3641', 'James', 'Evans', 'Austin', 'TX', 'United States'),
        ('amelia.clark.personal@example.com', '(904) 674-2183', 'Amelia', 'Clark', 'Jacksonville', 'FL', 'United States'),
        ('benjamin.martin.email@example.com', '(817) 519-2756', 'Benjamin', 'Martin', 'Fort Worth', 'TX', 'United States'),
        ('charlotte.white_76@example.com', '(614) 743-1628', 'Charlotte', 'White', 'Columbus', 'OH', 'United States'),
        ('alex.rivera_network@example.com', '(704) 845-7219', 'Alexander', 'Rivera', 'Charlotte', 'NC', 'United States'),
        ('harper.mitchell_04@example.com', '(317) 641-9724', 'Harper', 'Mitchell', 'Indianapolis', 'IN', 'United States'),
        ('daniel.reed.contact@example.com', '(415) 390-7842', 'Daniel', 'Reed', 'San Francisco', 'CA', 'United States'),
        ('ella.simmons_box@example.com', '(206) 853-4716', 'Ella', 'Simmons', 'Seattle', 'WA', 'United States'),
        ('matthew.cooper92@example.com', '(303) 467-8159', 'Matthew', 'Cooper', 'Denver', 'CO', 'United States'),
        ('evelyn.wright_world@example.com', '(202) 931-4867', 'Evelyn', 'Wright', 'Washington', 'DC', 'United States'),
        ('samuel.turner_real@example.com', '(617) 724-3098', 'Samuel', 'Turner', 'Boston', 'MA', 'United States'),
        ('abigail.parker01@example.com', '(615) 847-3602', 'Abigail', 'Parker', 'Nashville', 'TN', 'United States'),
        ('henry.rogers_live@example.com', '(313) 892-7541', 'Henry', 'Rodgers', 'Detroit', 'MI', 'United States'),
        ('grace.kelly95@example.com', '(503) 741-2098', 'Grace', 'Kelly', 'Portland', 'OR', 'United States'),
        ('mason.brooks2000@zoho.com', '(702) 681-2374', 'Mason', 'Brooks', 'Las Vegas', 'NV', 'United States')


    

---------------------------------------------------

insert into destinations (
    destination_country,
    destination_city,
    destination_local_airport
)
    values 
        ('USA', 'New York City', 'JFK'),
        ('USA', 'Los Angeles', 'LAX'),
        ('UK', 'London', 'LHR'),
        ('France', 'Paris', 'CDG'),
        ('Germany', 'Berlin', 'BER'),
        ('Italy', 'Rome', 'FCO'),
        ('Spain', 'Barcelona', 'BCN'),
        ('Japan', 'Tokyo', 'HND'),
        ('China', 'Shanghai', 'PVG'),
        ('China', 'Beijing', 'PEK'),
        ('India', 'Mumbai', 'BOM'),
        ('UAE', 'Dubai', 'DXB'),
        ('Australia', 'Sydney', 'SYD'),
        ('Canada', 'Toronto', 'YYZ'),
        ('Argentina', 'Buenos Aires', 'EZE'),
        ('Brazil', 'Rio de Janeiro', 'GIG'),
        ('South Africa', 'Cape Town', 'CPT'),
        ('Kenya', 'Nairobi', 'NBO'),
        ('Singapore', 'Singapore', 'SIN'),
        ('Thailand', 'Bangkok', 'BKK'),
        ('Turkey', 'Istanbul', 'IST'),
        ('Mexico', 'Mexico City', 'MEX'),
        ('Egypt', 'Cairo', 'CAI'),
        ('Phillipines', 'Manila', 'MNL'),
        ('Peru', 'Lima', 'LIM')



---------------------------------------------------

insert into hotels (
    destination_id,
    hotel_name,
    hotel_price,
    hotel_rating
    )
    values 
        (1, 'Four Seasons', 7830, 5),
        (1, 'Marriott Marquis', 1998, 4),
        (1, '45 Times Square', 1116, 3),
        (2, 'The Ritz-Cartlon', 3030, 5),
        (2, 'Millennium Biltmore', 924, 4),
        (2, 'Double Tree', 618, 3),
        (3, 'The Savoy', 4548, 5),
        (3, 'The Harrison', 1068, 4),
        (3, 'The Abbey', 744, 3),
        (4, 'Demeure Montaigne', 2172, 5),
        (4, 'Pullman', 2004, 4),
        (4, 'Hotel Mistral', 402, 3),
        (5, 'Hotel Adlon Kempinski', 2166, 5),
        (5, 'Myer’s Hotel', 1020, 4),
        (5, 'Hotel Ludwig Van Beethoven', 468, 3),
        (6, 'Rome Cavalieri', 2094, 5),
        (6, 'Hotel Artemide', 798, 4),
        (6, 'Domus Sessoriana', 402, 3),
        (7, 'El Palauet Barcelona', 4290, 5),
        (7, 'Axel Hotel Barcelona', 810, 4),
        (7, 'Hotel Sagrada Family', 570, 3),
        (8, 'Aman Tokyo', 10980, 5),
        (8, 'The Blossom Hibiya', 1062, 4),
        (8, 'Pearl Hotel Ryogoku', 342, 3),
        (9, 'Amanyangyun', 5052, 5),
        (9, 'Shanghai InterContinental', 1440, 4),
        (9, 'Shanghai Fish Inn', 306, 3),
        (10, 'Mandarin Oriental Wangfujing', 3858, 5),
        (10, 'Novotel Beijing Xin Qiao', 402, 4),
        (10, 'Dong Fang', 348, 3),
        (11, 'The Oberoi', 1446, 5),
        (11, 'The Ambassador', 600, 4),
        (11, 'T24 Retro', 216, 3),
        (12, 'Burj Al Arab', 9396, 5),
        (12, 'Millennium Central', 594, 4),
        (12, 'Rove Expo City', 978, 3),
        (13, 'Pier One Sydney Harbour', 1146, 5),
        (13, 'Harbour Rocks Hotel', 972, 4),
        (13, 'Hotel Challis Potts Point', 576, 3),
        (14, 'The Hazelton Hotel', 3804, 5),
        (14, 'Westlake Boutique Hotel', 666, 4),
        (14, 'Hotel Victoria', 636, 3),
        (15, 'Palacio Duhau', 3528, 5),
        (15, 'Cyan Recoleta Hotel', 312, 4),
        (15, 'Bisonte Palace Hotel', 264, 3),
        (16, 'Janeiro Hotel', 2856, 5),
        (16, 'Orla Copacabana', 582, 4),
        (16, 'Mirante do Arvrao', 324, 3),
        (17, 'The Silo Hotel', 8538, 5),
        (17, 'The Vineyard', 1572, 4),
        (17, 'Mojo Hotel', 192, 3),
        (18, 'Nairobi Serena Hotel', 1212, 5),
        (18, 'The Drexel House', 780, 4),
        (18, 'Fair Acres Boutique Hotel', 588, 3),
        (19, 'Raffles Singapore', 5706, 5),
        (19, 'Siloso Beach Resort', 678, 4),
        (19, 'Hotel Time Permas', 78, 3),
        (20, 'Avani Riverside Hotel', 624, 5),
        (20, 'The Davis Bangkok', 258, 4),
        (20, 'Nature Boutique Hotel', 66, 3),
        (21, 'Movenpick Hotel Golden Horn', 486, 5),
        (21, 'Skalion Hotel & Spa', 342, 4),
        (21, 'Galata Dream Hotel', 294, 3),
        (22, 'The Ritz-Cartlon Mexico City', 2604, 5),
        (22, 'Stanza Hotel', 384, 4),
        (22, 'Hotel Marbella', 234, 3),
        (23, 'The St Regis Cairo', 1620, 5),
        (23, 'Steigenberger Hotel El Tahrir', 738, 4),
        (23, 'Cleopatra Hotel', 396, 3),
        (24, 'Diamond Hotel', 612, 5),
        (24, 'Rizal Park Hotel', 396, 4),
        (24, 'Privato Hotel Makati', 156, 3),
        (25, 'Miraflores Park', 2802, 5),
        (25, 'Villa Barranco', 840, 4),
        (25, 'Llaqta Hotel', 90, 3);


---------------------------------------------------

insert into experiences (
    destination_id,
    experience_company,
    experience_tier,
    experience_price
)
    values     
        (1, 'Empire Elite Tours', 'High-End', 3000),
        (1, 'Urban Explorer', 'Mid-Tier', 1500),
        (1, 'City Adventurer', 'Budget-Friendly', 500),
        (2, 'Hollywood Luxe', 'High-End', 2500),
        (2, 'City Explorer Tours', 'Mid-Tier', 1250),
        (2, 'LA Adventurer', 'Budget-Friendly', 400),
        (3, 'Crown Expeditions', 'High-End', 3000),
        (3, 'London Legacy', 'Mid-Tier', 1500),
        (3, 'Thames Treks', 'Budget-Friendly', 500),
        (4, 'Parisian Prestige', 'High-End', 3300),
        (4, 'Paris Explorer', 'Mid-Tier', 1500),
        (4, 'Paris Discoverer', 'Budget-Friendly', 525),
        (5, 'Berlin Bespoke', 'High-End', 2400),
        (5, 'Capital Cultural', 'Mid-Tier', 1250),
        (5, 'Berlin Budget Explorer', 'Budget-Friendly', 400),
        (6, 'Roman Reverie', 'High-End', 2400),
        (6, 'Eternal Journeys', 'Mid-Tier', 1250),
        (6, 'Ancient Pathways', 'Budget-Friendly', 400),
        (7, 'La Vida Luxe', 'High-End', 1625),
        (7, 'Urban Explorer Tours', 'Mid-Tier', 800),
        (7, 'Traveler’s Gem', 'Budget-Friendly', 250),
        (8, 'Sakura Elite Tours', 'High-End', 3750),
        (8, 'Urban Harmony', 'Mid-Tier', 2000),
        (8, 'Shogun’s Path', 'Budget-Friendly', 800),
        (9, 'Jade Horizon', 'High-End', 1750),
        (9, 'Silk Road Discovery', 'Mid-Tier', 1000),
        (9, 'Lantern Trails', 'Budget-Friendly', 400),
        (10, 'Golden Dynasty', 'High-End', 2400),
        (10, 'Red Pavilion Trails', 'Mid-Tier', 1250),
        (10, 'Dragon Gate Discoveries', 'Budget-Friendly', 400),
        (11, 'Mumbai Majesty', 'High-End', 2000),
        (11, 'Cultural Kaleidoscope', 'Mid-Tier', 1000),
        (11, 'Mumbai Explorer', 'Budget-Friendly', 400),
        (12, 'Arabian Opulence', 'High-End', 3750),
        (12, 'Desert Pearl Yours', 'Mid-Tier', 2000),
        (12, 'Oasis Explorer', 'Budget-Friendly', 800),
        (13, 'Harbour Luxe Experience', 'High-End', 3000),
        (13, 'Coastal Explorer', 'Mid-Tier', 1500),
        (13, 'Sydney Highlights', 'Budget-Friendly', 500),
        (14, 'Maple Leaf Majesty', 'High-End', 2400),
        (14, 'Urban Explorer', 'Mid-Tier', 1250),
        (14, 'City Highlights', 'Budget-Friendly', 400),
        (15, 'Tango Elegance', 'High-End', 2150),
        (15, 'Buenos Aires Mosaic', 'Mid-Tier', 1150),
        (15, 'Streets of the City', 'Budget-Friendly', 400),
        (16, 'Rio Royalty Tours', 'High-End', 1850),
        (16, 'Carnival Vibes', 'Mid-Tier', 1000),
        (16, 'Carioca Trails', 'Budget-Friendly', 325),
        (17, 'Cape Town Grandeur', 'High-End', 2150),
        (17, 'Mother City Explorer', 'Mid-Tier', 1150),
        (17, 'Table Bay Trails', 'Budget-Friendly', 400),
        (18, 'Nairobi Elite Safari', 'High-End', 1500),
        (18, 'Savanna Explorer', 'Mid-Tier', 750),
        (18, 'Nairobi Highlights', 'Budget-Friendly', 400),
        (19, 'Jewel of the Bay', 'High-End', 2150),
        (19, 'Lion City Legacy', 'Mid-Tier', 1150),
        (19, 'Merlion’s Path', 'Budget-Friendly', 400),
        (20, 'Siam Splendor', 'High-End', 750),
        (20, 'Bangkok Explorer', 'Mid-Tier', 375),
        (20, 'Thai Trails', 'Budget-Friendly', 125),
        (21, 'Ottoman Opulence', 'High-End', 1500),
        (21, 'Bosphorus Breeze', 'Mid-Tier', 750),
        (21, 'Golden Horn Highlights', 'Budget-Friendly', 250),
        (22, 'Aztec Luxury Retreat', 'High-End', 1850),
        (22, 'Frida’s Footsteps', 'Mid-Tier', 1000),
        (22, 'Mexico City Tours', 'Budget-Friendly', 400),
        (23, 'Royal Sands Journey', 'High-End', 1500),
        (23, 'Crescent Horizons', 'Mid-Tier', 750),
        (23, 'Desert Echoes Tours', 'Budget-Friendly', 250),
        (24, 'Pearl of the Orient Luxe Tour', 'High-End', 1750),
        (24, 'Manila Heritage Explorer', 'Mid-Tier', 1000),
        (24, 'Manila City Highlights', 'Budget-Friendly', 500),
        (25, 'Lima Luxury Experience', 'High-End', 2150),
        (25, 'Lima Cultural Discovery', 'Mid-Tier', 1250),
        (25, 'Lima Essentials', 'Budget-Friendly', 360)




---------------------------------------------------

insert into payments (
    client_id,
    payment_date,
    payment_time,
    payment_method,
    payment_amount
)
    values 
        (1, '2024-11-01', '12:16:42', 'Venmo', 191),
        (2, '2024-11-02', '00:37:22', 'Venmo', 450),
        (3, '2024-11-03', '12:09:49', 'Credit Card', 592),
        (4, '2024-11-06', '00:51:21', 'Credit Card', 646),
        (5, '2024-11-07', '00:28:23', 'Venmo', 712),
        (6, '2024-11-09', '08:42:31', 'Venmo', 736),
        (7, '2024-11-11', '20:11:32', 'Zelle', 1146),
        (8, '2024-11-12', '05:51:27', 'Zelle', 1156),
        (9, '2024-11-13', '07:52:48', 'Zelle', 2048),
        (10, '2024-11-14', '13:14:18', 'Zelle', 2076),
        (11, '2024-11-16', '23:55:31', 'Venmo', 2440),
        (12, '2024-11-17', '21:26:01', 'Zelle', 2722),
        (13, '2024-11-18', '11:24:28', 'Credit Card', 3062),
        (14, '2024-11-19', '09:14:34', 'Zelle', 2446),
        (15, '2024-11-20', '23:45:17', 'Zelle', 5090),
        (16, '2024-11-26', '10:51:44', 'Venmo', 5108),
        (17, '2024-11-30', '20:24:57', 'Venmo', 6856),
        (18, '2024-12-02', '06:29:04', 'Credit Card', 4068),
        (19, '2024-12-03', '08:13:33', 'Venmo', 4998),
        (20, '2024-12-04', '13:12:43', 'Zelle', 5304),
        (21, '2024-12-06', '08:39:29', 'Credit Card', 7856),
        (22, '2024-12-07', '08:52:31', 'Zelle', 10688),
        (23, '2024-12-09', '15:43:47', 'Zelle', 10830),
        (24, '2024-12-10', '07:41:07', 'Credit Card', 13146),
        (25, '2024-12-11', '11:08:26', 'Credit Card', 14730)

---------------------------------------------------

insert into bookings (
    client_id,
    payment_id,
    hotel_id,
    experience_id,
    destination_id,
    booking_date,
    booking_budget,
    booking_hotel_star,
    booking_experience_tier,
    booking_arrival_date,
    booking_departure_date   
)
    values 
        (1, 1, 60, 60, 20, '2024-11-01', 200, 3, 'Budget-Friendly', '2025-12-07', '2025-12-13'),
        (2, 2, 75, 75, 25, '2024-11-02', 500, 3, 'Budget-Friendly', '2025-01-19', '2025-01-25'),
        (3, 3, 62, 63, 21, '2024-11-03', 625, 4, 'Budget-Friendly', '2025-10-18', '2025-10-24'),
        (4, 4, 69, 69, 23, '2024-11-06', 750, 3, 'Budget-Friendly', '2025-10-31', '2025-11-06'),
        (5, 5, 44, 45, 15, '2024-11-07', 800, 4, 'Budget-Friendly', '2025-12-21', '2025-12-27'),
        (6, 6, 61, 63, 21, '2024-11-09', 975, 5, 'Budget-Friendly', '2025-02-10', '2025-02-16'),
        (7, 7, 69, 68, 23, '2024-11-11', 1150, 3, 'Mid-Tier', '2025-10-29', '2025-11-04'),
        (8, 8, 72, 71, 24, '2024-11-12', 1200, 3, 'Mid-Tier', '2025-07-12', '2025-07-18'),
        (9, 9, 17, 17, 6, '2024-11-13', 2200, 4, 'Mid-Tier', '2025-03-13', '2025-03-19'),
        (10, 10, 39, 38, 13, '2024-11-14', 2500, 3, 'Mid-Tier', '2025-03-31', '2025-04-06'),
        (11, 11, 26, 26, 9, '2024-11-16', 3750, 4, 'Mid-Tier', '2025-02-09', '2025-02-15'),
        (12, 12, 50, 50, 17, '2024-11-17', 3895, 4, 'Mid-Tier', '2025-04-16', '2025-04-22'),
        (13, 13, 23, 23, 8, '2024-11-18', 4075, 4, 'Mid-Tier', '2025-04-25', '2025-05-01'),
        (14, 14, 31, 32, 11, '2024-11-19', 4500, 5, 'Mid-Tier', '2025-11-04', '2025-11-10'),
        (15, 15, 19, 20, 7, '2024-11-20', 5525, 5, 'Mid-Tier', '2025-06-11', '2025-06-17'),
        (16, 16, 28, 29, 10, '2024-11-26', 6750, 5, 'Mid-Tier', '2025-06-16', '2025-06-22'),
        (17, 17, 55, 56, 19, '2024-11-30', 7250, 5, 'Mid-Tier', '2025-11-15', '2025-11-21'),
        (18, 18, 8, 7, 3, '2024-12-02', 8000, 4, 'High-End', '2025-07-07', '2025-07-13'),
        (19, 19, 2, 1, 1, '2024-12-03', 9500, 4, 'High-End', '2025-04-08', '2025-04-14'),
        (20, 20, 11, 10, 4, '2024-12-04', 10050, 4, 'High-End', '2025-11-22', '2025-11-28'),
        (21, 21, 55, 55, 19, '2024-12-06', 11000, 5, 'High-End', '2025-11-15', '2025-11-21'),
        (22, 22, 49, 49, 17, '2024-12-07', 12500, 5, 'High-End', '2025-06-17', '2025-06-23'),
        (23, 23, 1, 1, 1, '2024-12-09', 13650, 5, 'High-End', '2025-03-05', '2025-03-11'),
        (24, 24, 34, 34, 12, '2024-12-10', 14000, 5, 'High-End', '2025-11-10', '2025-11-16'),
        (25, 25, 22, 22, 8, '2024-12-11', 15000, 5, 'High-End', '2025-01-05', '2025-01-11');

---------------------------------------------------



-- Optional: To drop the entire database
-- IF EXISTS (SELECT * FROM sys.databases WHERE name = 'travel_db')
-- BEGIN
--     DROP DATABASE travel_db;
--     PRINT 'Database travel_db dropped.';
-- END;
-- GO
