-- Name: Caner Kaan Balseven V01070478 CSC370 FALL 2026 - PROJECT KICK-OFF

DROP DATABASE IF EXISTS restaurant_ops;
CREATE DATABASE restaurant_ops;
USE restaurant_ops;

-- Note: I already had this in my project I only converted Prisma ORM to SQL.

-- ---------------------------------------------------------------------
-- Staff
-- ---------------------------------------------------------------------

CREATE TABLE Restaurant (
    restaurant_id  INT,
    name           VARCHAR(100),
    address        VARCHAR(255),
    phone          VARCHAR(20),
    currency       CHAR(3),
    PRIMARY KEY (restaurant_id)
);

CREATE TABLE Role (
    role_id        INT,
    restaurant_id  INT,
    role_name      VARCHAR(50),
    department     ENUM('FRONT_OF_HOUSE', 'KITCHEN', 'MANAGEMENT'),
    PRIMARY KEY (role_id)
);

CREATE TABLE Staff (
    staff_id        INT,
    role_id         INT,
    name            VARCHAR(100),
    email           VARCHAR(255),
    phone           VARCHAR(20),
    hire_date       DATE,
    pay_type        ENUM('HOURLY', 'SALARY'),
    hourly_rate     DECIMAL(10,2),
    monthly_salary  DECIMAL(10,2),
    is_active       BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (staff_id)
);

CREATE TABLE StaffCredential (
    staff_id       INT,
    username       VARCHAR(50),
    password_hash  CHAR(60),
    force_reset    BOOLEAN,
    last_login_at  DATETIME,
    PRIMARY KEY (staff_id)
);

CREATE TABLE Shift (
    shift_id   INT,
    staff_id   INT,
    start_at   DATETIME,
    end_at     DATETIME,
    notes      VARCHAR(255),
    PRIMARY KEY (shift_id)
);

CREATE TABLE SwapRequest (
    swap_id         INT,
    shift_id        INT,
    cover_staff_id  INT,
    status          ENUM('PENDING', 'APPROVED', 'DENIED') DEFAULT 'PENDING',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (swap_id)
);

-- ---------------------------------------------------------------------
-- Menu and Inventory
-- ---------------------------------------------------------------------

CREATE TABLE MenuCategory (
    category_id    INT,
    restaurant_id  INT,
    name           VARCHAR(50),
    sort_order     INT,
    PRIMARY KEY (category_id)
);

CREATE TABLE MenuItem (
    menu_item_id  INT,
    category_id   INT,
    name          VARCHAR(100),
    price         DECIMAL(10,2),
    is_available  BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (menu_item_id)

);

CREATE TABLE InventoryItem (
    inventory_item_id  INT,
    restaurant_id      INT,
    name               VARCHAR(100),
    unit               ENUM('g', 'kg', 'ml', 'l', 'unit'),
    par_level          DECIMAL(10,2),
    lead_time_days     INT,
    PRIMARY KEY (inventory_item_id)
);

CREATE TABLE RecipeLine (
    menu_item_id       INT,
    inventory_item_id  INT,
    qty_per_serving    DECIMAL(10,2),
    PRIMARY KEY (menu_item_id, inventory_item_id)
);

CREATE TABLE StockMovement (
    movement_id        INT,
    inventory_item_id  INT,
    movement_type      ENUM('RECEIVE', 'CONSUME', 'WASTE', 'ADJUST'),
    quantity_delta     DECIMAL(10,2),
    unit_cost          DECIMAL(10,2),
    reason             VARCHAR(255),
    occurred_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (movement_id)
);

-- ---------------------------------------------------------------------
-- Front of House
-- ---------------------------------------------------------------------

CREATE TABLE DiningTable (
    table_id       INT,
    restaurant_id  INT,
    label          VARCHAR(10),
    seats          INT,
    section        VARCHAR(30),
    PRIMARY KEY (table_id)
);

CREATE TABLE Customer (
    customer_id  INT,
    name         VARCHAR(100),
    phone        VARCHAR(20),
    email        VARCHAR(255),
    PRIMARY KEY (customer_id)
);

CREATE TABLE Reservation (
    reservation_id  INT,
    table_id        INT,
    customer_id     INT,
    reserved_for    DATETIME,
    party_size      INT,
    status          ENUM('BOOKED', 'SEATED', 'CANCELLED', 'NO_SHOW') DEFAULT 'BOOKED',
    PRIMARY KEY (reservation_id)
);

CREATE TABLE CustomerOrder (
    order_id            INT,
    restaurant_id       INT,
    customer_id         INT,
    channel             ENUM('IN_PERSON', 'PHONE', 'ONLINE'),
    fulfillment         ENUM('DINE_IN', 'PICKUP', 'DELIVERY'),
    status              ENUM('PENDING', 'CONFIRMED', 'FULFILLED', 'CANCELLED') DEFAULT 'PENDING',
    payment_type        ENUM('CASH', 'CARD', 'ONLINE', 'THIRD_PARTY'),
    tip                 DECIMAL(10,2) DEFAULT 0,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    started_at          DATETIME,
    finished_at         DATETIME,
    delivery_address    VARCHAR(255),
    delivery_notes      VARCHAR(255),
    courier             ENUM('IN_HOUSE', 'UBER_EATS'),
    external_order_ref  VARCHAR(64),
    PRIMARY KEY (order_id)
);

CREATE TABLE DineInDetail (
    order_id    INT,
    table_id    INT,
    server_id   INT,
    party_size  INT,
    PRIMARY KEY (order_id)
);

CREATE TABLE OrderItem (
    order_item_id  INT,
    order_id       INT,
    menu_item_id   INT,
    quantity       INT,
    unit_price     DECIMAL(10,2),
    notes          VARCHAR(255),
    PRIMARY KEY (order_item_id)
);

CREATE TABLE Review (
    review_id   INT,
    order_id    INT,
    rating      INT,
    comment     TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id)
);