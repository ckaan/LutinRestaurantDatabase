
-- CSC 370 Group 47 | Caner Kaan Balseven V01074078 - Restaurant Management Database (Sprint 1)
-- schema.sql: DDL for the 31 relations in Section 5
-- =====================================================================

DROP DATABASE IF EXISTS restaurant_ops;
CREATE DATABASE restaurant_ops;
USE restaurant_ops;

-- ---------------------------------------------------------------------
-- Staff and Labour
-- ---------------------------------------------------------------------

CREATE TABLE Restaurant (
    restaurant_id  INT AUTO_INCREMENT,
    name           VARCHAR(100) NOT NULL,
    address        VARCHAR(255) NULL,
    phone          VARCHAR(20) NULL,
    currency       CHAR(3) NOT NULL DEFAULT 'CAD',
    PRIMARY KEY (restaurant_id)
);

CREATE TABLE Role (
    restaurant_id  INT,
    role_name      VARCHAR(50),
    department     ENUM('FRONT_OF_HOUSE', 'KITCHEN', 'MANAGEMENT') NOT NULL,
    PRIMARY KEY (restaurant_id, role_name),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id)
);

CREATE TABLE Staff (
    staff_id       INT AUTO_INCREMENT,
    restaurant_id  INT NOT NULL,
    role_name      VARCHAR(50) NOT NULL,
    name           VARCHAR(100) NOT NULL,
    email          VARCHAR(255) NULL,
    phone          VARCHAR(20) NULL,
    hire_date      DATE NOT NULL,
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (staff_id),
    FOREIGN KEY (restaurant_id, role_name) REFERENCES Role (restaurant_id, role_name)
);

CREATE TABLE HourlyStaff (
    staff_id     INT,
    hourly_rate  DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (staff_id),
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id)
);

CREATE TABLE SalariedStaff (
    staff_id        INT,
    monthly_salary  DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (staff_id),
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id)
);

CREATE TABLE StaffCredential (
    staff_id       INT,
    username       VARCHAR(50) NOT NULL,
    password_hash  CHAR(60) NOT NULL,
    force_reset    BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at  DATETIME NULL,
    PRIMARY KEY (staff_id),
    UNIQUE (username),
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id)
);

CREATE TABLE Shift (
    shift_id  INT AUTO_INCREMENT,
    staff_id  INT NOT NULL,
    start_at  DATETIME NOT NULL,
    end_at    DATETIME NOT NULL,
    notes     VARCHAR(255) NULL,
    PRIMARY KEY (shift_id),
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id)
);

CREATE TABLE SwapRequest (
    swap_id         INT AUTO_INCREMENT,
    shift_id        INT NOT NULL,
    cover_staff_id  INT NULL,
    decided_by      INT NULL,
    status          ENUM('PENDING', 'APPROVED', 'DENIED') NOT NULL DEFAULT 'PENDING',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (swap_id),
    FOREIGN KEY (shift_id) REFERENCES Shift (shift_id),
    FOREIGN KEY (cover_staff_id) REFERENCES Staff (staff_id),
    FOREIGN KEY (decided_by) REFERENCES Staff (staff_id)
);

CREATE TABLE TimeClockEvent (
    event_id     INT AUTO_INCREMENT,
    staff_id     INT NOT NULL,
    shift_id     INT NULL,
    event_type   ENUM('CLOCK_IN', 'CLOCK_OUT', 'BREAK_START', 'BREAK_END') NOT NULL,
    occurred_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note         VARCHAR(255) NULL,
    PRIMARY KEY (event_id),
    UNIQUE (staff_id, occurred_at),
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id),
    FOREIGN KEY (shift_id) REFERENCES Shift (shift_id)
);

CREATE TABLE TimeOffRequest (
    request_id  INT AUTO_INCREMENT,
    staff_id    INT NOT NULL,
    decided_by  INT NULL,
    start_date  DATE NOT NULL,
    end_date    DATE NOT NULL,
    hours       DECIMAL(10,2) NOT NULL,
    reason      VARCHAR(255) NULL,
    status      ENUM('PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (request_id),
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id),
    FOREIGN KEY (decided_by) REFERENCES Staff (staff_id)
);

CREATE TABLE PayRecord (
    pay_record_id  INT AUTO_INCREMENT,
    staff_id       INT NOT NULL,
    period_start   DATE NOT NULL,
    period_end     DATE NOT NULL,
    hours_worked   DECIMAL(10,2) NOT NULL,
    rate_snapshot  DECIMAL(10,2) NOT NULL,
    bonus          DECIMAL(10,2) NOT NULL DEFAULT 0,
    deductions     DECIMAL(10,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (pay_record_id),
    UNIQUE (staff_id, period_start),
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id)
);

CREATE TABLE StaffingRequirement (
    requirement_id  INT AUTO_INCREMENT,
    restaurant_id   INT NOT NULL,
    work_date       DATE NOT NULL,
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    department      ENUM('FRONT_OF_HOUSE', 'KITCHEN', 'MANAGEMENT') NOT NULL,
    required_count  INT NOT NULL,
    PRIMARY KEY (requirement_id),
    UNIQUE (restaurant_id, work_date, department, start_time),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id)
);

-- ---------------------------------------------------------------------
-- Menu and Inventory
-- ---------------------------------------------------------------------

CREATE TABLE MenuCategory (
    category_id    INT AUTO_INCREMENT,
    restaurant_id  INT NOT NULL,
    name           VARCHAR(50) NOT NULL,
    sort_order     INT NOT NULL,
    PRIMARY KEY (category_id),
    UNIQUE (restaurant_id, name),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id)
);

CREATE TABLE MenuItem (
    menu_item_id  INT AUTO_INCREMENT,
    category_id   INT NOT NULL,
    name          VARCHAR(100) NOT NULL,
    price         DECIMAL(10,2) NOT NULL,
    is_available  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (menu_item_id),
    UNIQUE (category_id, name),
    FOREIGN KEY (category_id) REFERENCES MenuCategory (category_id)
);

CREATE TABLE InventoryItem (
    inventory_item_id  INT AUTO_INCREMENT,
    restaurant_id      INT NOT NULL,
    name               VARCHAR(100) NOT NULL,
    unit               ENUM('g', 'kg', 'ml', 'l', 'unit') NOT NULL,
    par_level          DECIMAL(10,2) NULL,
    lead_time_days     INT NULL,
    PRIMARY KEY (inventory_item_id),
    UNIQUE (restaurant_id, name),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id)
);

CREATE TABLE RecipeLine (
    menu_item_id       INT,
    inventory_item_id  INT,
    qty_per_serving    DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (menu_item_id, inventory_item_id),
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem (menu_item_id),
    FOREIGN KEY (inventory_item_id) REFERENCES InventoryItem (inventory_item_id)
);

CREATE TABLE StockMovement (
    movement_id        INT AUTO_INCREMENT,
    inventory_item_id  INT NOT NULL,
    movement_type      ENUM('RECEIVE', 'CONSUME', 'WASTE', 'ADJUST') NOT NULL,
    quantity_delta     DECIMAL(10,2) NOT NULL,
    unit_cost          DECIMAL(10,2) NULL,
    reason             VARCHAR(255) NULL,
    occurred_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (movement_id),
    FOREIGN KEY (inventory_item_id) REFERENCES InventoryItem (inventory_item_id)
);

-- ---------------------------------------------------------------------
-- Front of House
-- ---------------------------------------------------------------------

CREATE TABLE DiningTable (
    table_id       INT AUTO_INCREMENT,
    restaurant_id  INT NOT NULL,
    label          VARCHAR(10) NOT NULL,
    seats          INT NOT NULL,
    section        VARCHAR(30) NULL,
    PRIMARY KEY (table_id),
    UNIQUE (restaurant_id, label),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id)
);

CREATE TABLE Customer (
    customer_id  INT AUTO_INCREMENT,
    name         VARCHAR(100) NOT NULL,
    phone        VARCHAR(20) NOT NULL,
    email        VARCHAR(255) NULL,
    PRIMARY KEY (customer_id),
    UNIQUE (phone)
);

CREATE TABLE Reservation (
    reservation_id  INT AUTO_INCREMENT,
    table_id        INT NOT NULL,
    customer_id     INT NOT NULL,
    reserved_for    DATETIME NOT NULL,
    party_size      INT NOT NULL,
    status          ENUM('BOOKED', 'SEATED', 'CANCELLED', 'NO_SHOW') NOT NULL DEFAULT 'BOOKED',
    PRIMARY KEY (reservation_id),
    UNIQUE (table_id, reserved_for),
    FOREIGN KEY (table_id) REFERENCES DiningTable (table_id),
    FOREIGN KEY (customer_id) REFERENCES Customer (customer_id)
);

CREATE TABLE CustomerOrder (
    order_id       INT AUTO_INCREMENT,
    restaurant_id  INT NOT NULL,
    customer_id    INT NULL,
    channel        ENUM('IN_PERSON', 'PHONE', 'ONLINE') NOT NULL,
    status         ENUM('PENDING', 'CONFIRMED', 'FULFILLED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    payment_type   ENUM('CASH', 'CARD', 'ONLINE', 'THIRD_PARTY') NULL,
    tip            DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at     DATETIME NULL,
    finished_at    DATETIME NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id),
    FOREIGN KEY (customer_id) REFERENCES Customer (customer_id)
);

CREATE TABLE DineInOrder (
    order_id    INT,
    table_id    INT NOT NULL,
    server_id   INT NULL,
    party_size  INT NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id),
    FOREIGN KEY (table_id) REFERENCES DiningTable (table_id),
    FOREIGN KEY (server_id) REFERENCES Staff (staff_id)
);

CREATE TABLE DeliveryOrder (
    order_id            INT,
    delivery_address    VARCHAR(255) NOT NULL,
    delivery_notes      VARCHAR(255) NULL,
    courier             ENUM('IN_HOUSE', 'UBER_EATS') NOT NULL,
    external_order_ref  VARCHAR(64) NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id)
);

CREATE TABLE KitchenTicket (
    ticket_id     INT AUTO_INCREMENT,
    order_id      INT NOT NULL,
    batch_no      INT NOT NULL,
    status        ENUM('NEW', 'COOKING', 'READY') NOT NULL DEFAULT 'NEW',
    is_priority   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at  DATETIME NULL,
    PRIMARY KEY (ticket_id),
    UNIQUE (order_id, batch_no),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id)
);

CREATE TABLE OrderItem (
    order_id      INT,
    line_no       INT,
    menu_item_id  INT NOT NULL,
    ticket_id     INT NULL,
    quantity      INT NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    notes         VARCHAR(255) NULL,
    PRIMARY KEY (order_id, line_no),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id),
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem (menu_item_id),
    FOREIGN KEY (ticket_id) REFERENCES KitchenTicket (ticket_id)
);

CREATE TABLE Review (
    review_id   INT AUTO_INCREMENT,
    order_id    INT NOT NULL,
    rating      INT NOT NULL,
    comment     TEXT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    UNIQUE (order_id),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id)
);

-- ---------------------------------------------------------------------
-- Marketing and Analytics
-- ---------------------------------------------------------------------

CREATE TABLE Campaign (
    campaign_id    INT AUTO_INCREMENT,
    restaurant_id  INT NOT NULL,
    name           VARCHAR(100) NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NULL,
    budget         DECIMAL(10,2) NULL,
    PRIMARY KEY (campaign_id),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id)
);

CREATE TABLE CampaignItem (
    campaign_id   INT,
    menu_item_id  INT,
    PRIMARY KEY (campaign_id, menu_item_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaign (campaign_id),
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem (menu_item_id)
);

CREATE TABLE Announcement (
    announcement_id    INT AUTO_INCREMENT,
    author_id          INT NOT NULL,
    message            TEXT NOT NULL,
    announcement_type  ENUM('INFO', 'WARNING', 'PROMO') NOT NULL DEFAULT 'INFO',
    is_active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (announcement_id),
    FOREIGN KEY (author_id) REFERENCES Staff (staff_id)
);

CREATE TABLE WeatherObservation (
    restaurant_id     INT,
    observed_date     DATE,
    temp_max          DECIMAL(10,2) NOT NULL,
    temp_min          DECIMAL(10,2) NOT NULL,
    `condition`       ENUM('SUNNY', 'CLOUDY', 'RAIN', 'SNOW') NOT NULL,
    precipitation_mm  DECIMAL(10,2) NULL,
    PRIMARY KEY (restaurant_id, observed_date),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id)
);

CREATE TABLE Insight (
    insight_id     INT AUTO_INCREMENT,
    restaurant_id  INT NOT NULL,
    title          VARCHAR(100) NOT NULL,
    message        TEXT NOT NULL,
    insight_type   ENUM('INFO', 'ALERT', 'SUCCESS') NOT NULL,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at     DATETIME NULL,
    PRIMARY KEY (insight_id),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id)
);