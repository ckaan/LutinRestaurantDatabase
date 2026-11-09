-- CSC 370 Group 47 | Caner Kaan Balseven V01074078 - Restaurant Management Database (Sprint 2)
-- schema.sql
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
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id),
    CONSTRAINT chk_hourly_rate CHECK (hourly_rate > 0)
);

CREATE TABLE SalariedStaff (
    staff_id        INT,
    monthly_salary  DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (staff_id),
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id),
    CONSTRAINT chk_monthly_salary CHECK (monthly_salary > 0)
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
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id),
    CONSTRAINT chk_shift_time CHECK (end_at > start_at)
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
    FOREIGN KEY (decided_by) REFERENCES Staff (staff_id),
    CONSTRAINT chk_swap_decided CHECK (status = 'PENDING' OR decided_by IS NOT NULL),
    CONSTRAINT chk_swap_cover CHECK (status <> 'APPROVED' OR cover_staff_id IS NOT NULL)
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
    FOREIGN KEY (decided_by) REFERENCES Staff (staff_id),
    CONSTRAINT chk_timeoff_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_timeoff_hours CHECK (hours > 0),
    CONSTRAINT chk_timeoff_decided CHECK (status = 'PENDING' OR decided_by IS NOT NULL)
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
    FOREIGN KEY (staff_id) REFERENCES Staff (staff_id),
    CONSTRAINT chk_pay_period CHECK (period_end >= period_start),
    CONSTRAINT chk_pay_amounts CHECK (hours_worked >= 0 AND rate_snapshot >= 0 AND bonus >= 0 AND deductions >= 0)
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
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id),
    CONSTRAINT chk_staffing_time CHECK (end_time > start_time),
    CONSTRAINT chk_staffing_count CHECK (required_count > 0)
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
    FOREIGN KEY (category_id) REFERENCES MenuCategory (category_id),
    CONSTRAINT chk_menu_price CHECK (price >= 0)
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
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id),
    CONSTRAINT chk_inventory_levels CHECK (par_level >= 0 AND lead_time_days >= 0)
);

CREATE TABLE RecipeLine (
    menu_item_id       INT,
    inventory_item_id  INT,
    qty_per_serving    DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (menu_item_id, inventory_item_id),
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem (menu_item_id),
    FOREIGN KEY (inventory_item_id) REFERENCES InventoryItem (inventory_item_id),
    CONSTRAINT chk_recipe_qty CHECK (qty_per_serving > 0)
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
    FOREIGN KEY (inventory_item_id) REFERENCES InventoryItem (inventory_item_id),
    CONSTRAINT chk_movement_sign CHECK ((movement_type = 'RECEIVE' AND quantity_delta > 0) OR (movement_type IN ('CONSUME', 'WASTE') AND quantity_delta < 0) OR (movement_type = 'ADJUST' AND quantity_delta <> 0)),
    CONSTRAINT chk_movement_cost CHECK (unit_cost >= 0)
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
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id),
    CONSTRAINT chk_table_seats CHECK (seats > 0)
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
    FOREIGN KEY (customer_id) REFERENCES Customer (customer_id),
    CONSTRAINT chk_reservation_party CHECK (party_size > 0)
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
    FOREIGN KEY (customer_id) REFERENCES Customer (customer_id),
    CONSTRAINT chk_order_tip CHECK (tip >= 0),
    CONSTRAINT chk_order_times CHECK (started_at >= created_at AND finished_at >= started_at)
);

CREATE TABLE DineInOrder (
    order_id    INT,
    table_id    INT NOT NULL,
    server_id   INT NULL,
    party_size  INT NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id),
    FOREIGN KEY (table_id) REFERENCES DiningTable (table_id),
    FOREIGN KEY (server_id) REFERENCES Staff (staff_id),
    CONSTRAINT chk_dinein_party CHECK (party_size > 0)
);

CREATE TABLE DeliveryOrder (
    order_id            INT,
    delivery_address    VARCHAR(255) NOT NULL,
    delivery_notes      VARCHAR(255) NULL,
    courier             ENUM('IN_HOUSE', 'UBER_EATS') NOT NULL,
    external_order_ref  VARCHAR(64) NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id),
    CONSTRAINT chk_delivery_ref CHECK (courier <> 'UBER_EATS' OR external_order_ref IS NOT NULL)
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
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id),
    CONSTRAINT chk_ticket_batch CHECK (batch_no >= 1),
    CONSTRAINT chk_ticket_times CHECK (completed_at >= created_at)
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
    FOREIGN KEY (ticket_id) REFERENCES KitchenTicket (ticket_id),
    CONSTRAINT chk_item_line CHECK (line_no >= 1),
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (unit_price >= 0)
);

CREATE TABLE Review (
    review_id   INT AUTO_INCREMENT,
    order_id    INT NOT NULL,
    rating      INT NOT NULL,
    comment     TEXT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    UNIQUE (order_id),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder (order_id),
    CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5)
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
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id),
    CONSTRAINT chk_campaign_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_campaign_budget CHECK (budget >= 0)
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
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id),
    CONSTRAINT chk_weather_temp CHECK (temp_max >= temp_min),
    CONSTRAINT chk_weather_precip CHECK (precipitation_mm >= 0)
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
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant (restaurant_id),
    CONSTRAINT chk_insight_expiry CHECK (expires_at > created_at)
);


-- ---------------------------------------------------------------------
-- Views for the four dashboards (S2-G5)
-- ---------------------------------------------------------------------

-- Owner dashboard: orders and revenue per restaurant, day, and channel 
-- RA: OwnerSales ← γ[restaurant_id, DATE(created_at) → day, channel, COUNT(DISTINCT order_id) → orders, SUM(quantity × unit_price) → revenue](CustomerOrder ⋈ OrderItem)
CREATE VIEW OwnerSales AS
SELECT o.restaurant_id, DATE(o.created_at) AS day, o.channel,
       COUNT(DISTINCT o.order_id) AS orders, SUM(oi.quantity * oi.unit_price) AS revenue
FROM CustomerOrder AS o
JOIN OrderItem AS oi ON (o.order_id = oi.order_id)
GROUP BY o.restaurant_id, DATE(o.created_at), o.channel;

-- Employee dashboard: every staff member's shifts
-- RA: EmployeeSchedule ← π[restaurant_id, staff_id, name, shift_id, start_at, end_at, notes](Staff ⋈ Shift)
CREATE VIEW EmployeeSchedule AS
SELECT s.restaurant_id, s.staff_id, s.name, sh.shift_id, sh.start_at, sh.end_at, sh.notes
FROM Staff AS s
JOIN Shift AS sh ON (s.staff_id = sh.staff_id);

-- Order-system dashboard: orders that are not fulfilled or cancelled yet 
-- RA: OpenOrders ← π[restaurant_id, order_id, channel, status, created_at](σ[status ∉ {'FULFILLED', 'CANCELLED'}](CustomerOrder))
CREATE VIEW OpenOrders AS
SELECT restaurant_id, order_id, channel, status, created_at
FROM CustomerOrder
WHERE status NOT IN ('FULFILLED', 'CANCELLED');

-- Kitchen Display: current stock of every ingredient with its par level 
-- RA: KitchenStock ← γ[restaurant_id, inventory_item_id, name, unit, par_level, COALESCE(SUM(quantity_delta), 0) → current_stock](InventoryItem ⟕ StockMovement)
CREATE VIEW KitchenStock AS
SELECT i.restaurant_id, i.inventory_item_id, i.name, i.unit, i.par_level,
       COALESCE(SUM(s.quantity_delta), 0) AS current_stock
FROM InventoryItem AS i
LEFT JOIN StockMovement AS s ON (i.inventory_item_id = s.inventory_item_id)
GROUP BY i.restaurant_id, i.inventory_item_id, i.name, i.unit, i.par_level;



-- ---------------------------------------------------------------------
-- Triggers (S2-G6)
-- ---------------------------------------------------------------------

DELIMITER //

-- T1: when an order line is added, its menu item must be from the order's restaurant
CREATE TRIGGER check_orderitem_insert
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE order_restaurant INT;
    DECLARE item_restaurant INT;

    SELECT restaurant_id INTO order_restaurant
    FROM CustomerOrder
    WHERE order_id = NEW.order_id;

    SELECT c.restaurant_id INTO item_restaurant
    FROM MenuItem AS m
    JOIN MenuCategory AS c ON (m.category_id = c.category_id)
    WHERE m.menu_item_id = NEW.menu_item_id;

    IF order_restaurant <> item_restaurant THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot add a menu item from another restaurant to this order';
    END IF;
END//

-- T2: the same check when an order line is changed
CREATE TRIGGER check_orderitem_update
BEFORE UPDATE ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE order_restaurant INT;
    DECLARE item_restaurant INT;

    SELECT restaurant_id INTO order_restaurant
    FROM CustomerOrder
    WHERE order_id = NEW.order_id;

    SELECT c.restaurant_id INTO item_restaurant
    FROM MenuItem AS m
    JOIN MenuCategory AS c ON (m.category_id = c.category_id)
    WHERE m.menu_item_id = NEW.menu_item_id;

    IF order_restaurant <> item_restaurant THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot add a menu item from another restaurant to this order';
    END IF;
END//

-- T3: when a dine-in order is added, its table and server must be from the order's restaurant
CREATE TRIGGER check_dinein_insert
BEFORE INSERT ON DineInOrder
FOR EACH ROW
BEGIN
    DECLARE order_restaurant INT;
    DECLARE table_restaurant INT;
    DECLARE server_restaurant INT;

    SELECT restaurant_id INTO order_restaurant
    FROM CustomerOrder
    WHERE order_id = NEW.order_id;

    SELECT restaurant_id INTO table_restaurant
    FROM DiningTable
    WHERE table_id = NEW.table_id;

    SELECT restaurant_id INTO server_restaurant
    FROM Staff
    WHERE staff_id = NEW.server_id;

    IF order_restaurant <> table_restaurant THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This table is in a different restaurant';
    END IF;

    IF order_restaurant <> server_restaurant THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This server works at a different restaurant';
    END IF;
END//

-- T4: the same checks when a dine-in order is changed
CREATE TRIGGER check_dinein_update
BEFORE UPDATE ON DineInOrder
FOR EACH ROW
BEGIN
    DECLARE order_restaurant INT;
    DECLARE table_restaurant INT;
    DECLARE server_restaurant INT;

    SELECT restaurant_id INTO order_restaurant
    FROM CustomerOrder
    WHERE order_id = NEW.order_id;

    SELECT restaurant_id INTO table_restaurant
    FROM DiningTable
    WHERE table_id = NEW.table_id;

    SELECT restaurant_id INTO server_restaurant
    FROM Staff
    WHERE staff_id = NEW.server_id;

    IF order_restaurant <> table_restaurant THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This table is in a different restaurant';
    END IF;

    IF order_restaurant <> server_restaurant THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This server works at a different restaurant';
    END IF;
END//

-- T5: Contains and OnTicket: the last line of an order, or of a kitchen ticket, cannot be deleted
CREATE TRIGGER check_orderitem_delete
BEFORE DELETE ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE lines_in_order INT;
    DECLARE lines_on_ticket INT;

    SELECT COUNT(*) INTO lines_in_order
    FROM OrderItem
    WHERE order_id = OLD.order_id;

    SELECT COUNT(*) INTO lines_on_ticket
    FROM OrderItem
    WHERE ticket_id = OLD.ticket_id;

    IF lines_in_order = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot delete the last item of an order';
    END IF;

    IF OLD.ticket_id IS NOT NULL AND lines_on_ticket = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot delete the last item on a kitchen ticket';
    END IF;
END//

-- T6: Promotes: the last menu item of a campaign cannot be deleted
CREATE TRIGGER check_campaignitem_delete
BEFORE DELETE ON CampaignItem
FOR EACH ROW
BEGIN
    DECLARE items_in_campaign INT;

    SELECT COUNT(*) INTO items_in_campaign
    FROM CampaignItem
    WHERE campaign_id = OLD.campaign_id;

    IF items_in_campaign = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot remove the last menu item from a campaign';
    END IF;
END//

DELIMITER ;