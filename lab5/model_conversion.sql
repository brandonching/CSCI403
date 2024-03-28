/*
 Lab 5 - ERD to SQL conversion script
 Name: Brandon Ching
 */
-- Set your search path to include your username and public,
-- but *not* in this script.
-- Windows psql needs the following line uncommented
-- \encoding utf-8
-- Add other environment changes here (pager, etc.)
-- Add the SQL for each step that needs SQL after the appropriate comment
-- below. You may not need to do every single step, depending on your
-- model.
/*
 Step 1: Regular entities
 */
CREATE TABLE IF NOT EXISTS service_provider (
    UPID SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
CREATE TABLE IF NOT EXISTS service (
    USID SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    capacity INT NOT NULL
);
CREATE TABLE IF NOT EXISTS location (
    ULID SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
CREATE TABLE IF NOT EXISTS review (
    URID SERIAL PRIMARY KEY,
    rating INT NOT NULL,
    comment TEXT
);
CREATE TABLE IF NOT EXISTS client (
    UUID SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
CREATE TABLE IF NOT EXISTS contract (
    UCoID SERIAL PRIMARY KEY,
    creation_time DATE NOT NULL,
    description TEXT,
    date_of_service DATERANGE NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    confirmation_code VARCHAR(10) NOT NULL
);
-- add the amount_due = total - amount_paid column to the contract table
ALTER TABLE contract
ADD COLUMN amount_due DECIMAL(10, 2) GENERATED ALWAYS AS (total_cost - amount_paid) STORED;
CREATE TABLE IF NOT EXISTS merchandise (
    SKU SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL
);
/*
 Step 2: Weak entities
 */
/*
 Step 3: 1:1 Relationships
 */
/*
 Step 4: 1:N Relationships
 */
-- Service Provider to Review relationship
ALTER TABLE review
ADD COLUMN provider_id INT REFERENCES service_provider(UPID);
-- Client to review relationship
ALTER TABLE review
ADD COLUMN client_id INT REFERENCES client(UUID);
-- Service Provider to contract relationship
ALTER TABLE contract
ADD COLUMN provider_id INT REFERENCES service_provider(UPID);
-- Client to contract relationship
ALTER TABLE contract
ADD COLUMN client_id INT REFERENCES client(UUID);
/*
 Step 5: N:M Relationships
 */
-- Service to Location relationship
CREATE TABLE IF NOT EXISTS location_service_xref (
    USID INT REFERENCES service(USID),
    ULID INT REFERENCES location(ULID),
    PRIMARY KEY (USID, ULID)
);
-- Service provider to service relationship
CREATE TABLE IF NOT EXISTS provider_service_xref (
    UPID INT REFERENCES service_provider(UPID),
    USID INT REFERENCES service(USID),
    PRIMARY KEY (UPID, USID)
);
-- client to merchandise relationship
CREATE TABLE IF NOT EXISTS client_merchandise_xref (
    UUID INT REFERENCES client(UUID),
    SKU INT REFERENCES merchandise(SKU),
    PRIMARY KEY (UUID, SKU)
);
-- merchandise to provider relationship
CREATE TABLE IF NOT EXISTS provider_merchandise_xref (
    UPID INT REFERENCES service_provider(UPID),
    SKU INT REFERENCES merchandise(SKU),
    PRIMARY KEY (UPID, SKU)
);
/*
 Step 6: Multi-valued attributes
 */
CREATE TABLE IF NOT EXISTS contact_info (
    info_id SERIAL PRIMARY KEY,
    provider_id INT REFERENCES service_provider(UPID),
    client_id INT REFERENCES client(UUID),
    info_type VARCHAR(50),
    info_value VARCHAR(255)
);
/*
 Step 7: N-ary Relationships
 */
/*
 TEST DATA
 */
-- Clients
INSERT INTO client (name)
VALUES ('Isabell Bird');
INSERT INTO contact_info (client_id, info_type, info_value)
VALUES (1, 'email', 'frgsisabella@gmail.com');
INSERT INTO contact_info (client_id, info_type, info_value)
VALUES (1, 'phone', '303-555-1234');
INSERT INTO client (name)
VALUES ('John Doe');
INSERT INTO contact_info (client_id, info_type, info_value)
VALUES (2, 'email', 'johndoe1@gmail.com');
INSERT INTO contact_info (client_id, info_type, info_value)
VALUES (2, 'email', 'johndoe2@gmail.com');
INSERT INTO contact_info (client_id, info_type, info_value)
VALUES (2, 'phone', '303-555-5678');
-- Service Providers
INSERT INTO service_provider (name)
VALUES ('Rocky Mountain Xplorers');
INSERT INTO contact_info (provider_id, info_type, info_value)
VALUES (1, 'email', 'contact@rmx.com');
INSERT INTO contact_info (provider_id, info_type, info_value)
VALUES (1, 'phone', '303-555-9876');
INSERT INTO service_provider (name)
VALUES ('Adventure Tours');
INSERT INTO contact_info (provider_id, info_type, info_value)
VALUES (2, 'email', 'hi@adventuretours.com');
INSERT INTO contact_info (provider_id, info_type, info_value)
VALUES (2, 'phone', '303-555-4321');
-- Services
INSERT INTO service (name, price, capacity)
VALUES ('Hiking', 50.00, 10);
INSERT INTO service (name, price, capacity)
VALUES ('Rafting', 100.00, 5);
INSERT INTO service (name, price, capacity)
VALUES ('Provisioning', 75.00, 15);
INSERT INTO service (name, price, capacity)
VALUES ('Outfitting', 25.00, 20);
INSERT INTO service (name, price, capacity)
VALUES ('Guides', 150.00, 10);
-- Locations
INSERT INTO location (name)
VALUES ('Rocky Mountain National Park');
INSERT INTO location (name)
VALUES ('Grand Canyon National Park');
INSERT INTO location (name)
VALUES ('Yellowstone National Park');
INSERT INTO location (name)
VALUES ('Collegiate Peaks');
INSERT INTO location (name)
VALUES ('Pike''s Peak');
INSERT INTO location (name)
VALUES ('San Juan Mountains');
-- Contracts
INSERT INTO contract (
        creation_time,
        description,
        date_of_service,
        total_cost,
        amount_paid,
        confirmation_code
    )
VALUES (
        '2022-04-18 13:17:00',
        'Provisions, outfitting, and guide services for an expedition to the San Juan mountains.',
        '[2022-07-09,2022-07-23]',
        10500.00,
        2000.00,
        'C41301998'
    );
-- Reviews
INSERT INTO review (rating, comment, provider_id, client_id)
VALUES (5, 'Great service, would recommend.', 1, 2);
-- Merchandise
INSERT INTO merchandise (name, description, price)
VALUES (
        'Backpack',
        'A sturdy backpack for hiking.',
        50.00
    );
INSERT INTO merchandise (name, description, price)
VALUES ('Tent', 'A 2-person tent for camping.', 100.00);
INSERT INTO merchandise (name, description, price)
VALUES (
        'Sleeping Bag',
        'A warm sleeping bag for camping.',
        75.00
    );
-- Cross-reference tables
INSERT INTO location_service_xref (USID, ULID)
VALUES (1, 1);
INSERT INTO location_service_xref (USID, ULID)
VALUES (2, 2);
INSERT INTO provider_service_xref (UPID, USID)
VALUES (1, 1);
INSERT INTO provider_service_xref (UPID, USID)
VALUES (1, 2);
INSERT INTO client_merchandise_xref (UUID, SKU)
VALUES (1, 1);
INSERT INTO client_merchandise_xref (UUID, SKU)
VALUES (1, 2);
INSERT INTO provider_merchandise_xref (UPID, SKU)
VALUES (1, 1);
INSERT INTO provider_merchandise_xref (UPID, SKU)
VALUES (1, 2);