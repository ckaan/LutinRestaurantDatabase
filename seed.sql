-- =====================================================================
-- CSC 370 Group 47 - Restaurant Management Database (Sprint 2)
-- seed.sql: sample data for two restaurants
-- Run after schema.sql
-- =====================================================================

USE restaurant_ops;

-- ---------------------------------------------------------------------
-- Restaurants
-- ---------------------------------------------------------------------

INSERT INTO Restaurant (restaurant_id, name, address, phone, currency) VALUES
(1, 'Harbour Grill', '12 Wharf St, Victoria', '250-555-0101', 'CAD'),
(2, 'Kebab Corner', '880 Fort St, Victoria', '250-555-0202', 'CAD');

-- ---------------------------------------------------------------------
-- Staff and Labour
-- ---------------------------------------------------------------------

INSERT INTO Role (restaurant_id, role_name, department) VALUES
(1, 'Manager',   'MANAGEMENT'),
(1, 'Server',    'FRONT_OF_HOUSE'),
(1, 'Host',      'FRONT_OF_HOUSE'),
(1, 'Line Cook', 'KITCHEN'),
(2, 'Manager',   'MANAGEMENT'),
(2, 'Server',    'FRONT_OF_HOUSE'),
(2, 'Chef',      'KITCHEN');

INSERT INTO Staff (staff_id, restaurant_id, role_name, name, email, phone, hire_date, is_active) VALUES
(1, 1, 'Manager',   'Alice Martin',  'alice@harbourgrill.ca',  '250-555-1001', '2023-03-01', TRUE),
(2, 1, 'Server',    'Ben Clarke',    'ben@harbourgrill.ca',    '250-555-1002', '2024-05-15', TRUE),
(3, 1, 'Server',    'Chloe Nguyen',  'chloe@harbourgrill.ca',  '250-555-1003', '2025-01-10', TRUE),
(4, 1, 'Line Cook', 'Daniel Brown',  'daniel@harbourgrill.ca', NULL,           '2024-09-01', TRUE),
(5, 1, 'Line Cook', 'Emma Wilson',   NULL,                     '250-555-1005', '2026-08-20', TRUE),
(6, 1, 'Server',    'Frank Lee',     NULL,                     NULL,           '2022-06-01', FALSE),
(7, 2, 'Manager',   'Gul Yilmaz',    'gul@kebabcorner.ca',     '250-555-2001', '2021-02-01', TRUE),
(8, 2, 'Chef',      'Hasan Demir',   'hasan@kebabcorner.ca',   '250-555-2002', '2022-11-01', TRUE),
(9, 2, 'Server',    'Ilyas Kaya',    NULL,                     '250-555-2003', '2026-07-01', TRUE);

INSERT INTO HourlyStaff (staff_id, hourly_rate) VALUES
(2, 18.50), (3, 18.50), (4, 21.00), (5, 19.00), (6, 17.50), (8, 22.00), (9, 18.00);

INSERT INTO SalariedStaff (staff_id, monthly_salary) VALUES
(1, 4500.00), (7, 4800.00);

INSERT INTO StaffCredential (staff_id, username, password_hash, force_reset, last_login_at) VALUES
(1, 'alice', '$2b$12$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', FALSE, '2026-11-04 08:55:00'),
(2, 'ben',   '$2b$12$bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', TRUE,  NULL),
(3, 'chloe', '$2b$12$ccccccccccccccccccccccccccccccccccccccccccccccccccccc', FALSE, '2026-11-03 16:50:00'),
(4, 'daniel','$2b$12$ddddddddddddddddddddddddddddddddddddddddddddddddddddd', FALSE, '2026-11-02 09:58:00'),
(7, 'gul',   '$2b$12$ggggggggggggggggggggggggggggggggggggggggggggggggggggg', FALSE, '2026-11-04 10:10:00'),
(8, 'hasan', '$2b$12$hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh', FALSE, NULL);

-- Shifts 1-7: next week (Nov 9-15, 2026); shifts 101-103: last week (worked)
INSERT INTO Shift (shift_id, staff_id, start_at, end_at, notes) VALUES
(1,   2, '2026-11-09 11:00:00', '2026-11-09 19:00:00', NULL),
(2,   3, '2026-11-09 17:00:00', '2026-11-09 23:00:00', 'Closing shift'),
(3,   4, '2026-11-09 10:00:00', '2026-11-09 18:00:00', NULL),
(4,   1, '2026-11-10 09:00:00', '2026-11-10 17:00:00', NULL),
(5,   2, '2026-11-11 11:00:00', '2026-11-11 19:00:00', NULL),
(6,   3, '2026-11-12 18:00:00', '2026-11-12 23:00:00', NULL),
(7,   8, '2026-11-09 12:00:00', '2026-11-09 20:00:00', NULL),
(101, 2, '2026-11-02 11:00:00', '2026-11-02 19:00:00', NULL),
(102, 4, '2026-11-02 10:00:00', '2026-11-02 18:00:00', NULL),
(103, 3, '2026-11-03 17:00:00', '2026-11-03 23:00:00', NULL);

INSERT INTO SwapRequest (swap_id, shift_id, cover_staff_id, decided_by, status, created_at) VALUES
(1, 5, 3,    NULL, 'PENDING',  '2026-11-04 09:00:00'),
(2, 3, NULL, NULL, 'PENDING',  '2026-11-04 12:30:00'),
(3, 6, 2,    1,    'APPROVED', '2026-11-03 14:00:00');

INSERT INTO TimeClockEvent (event_id, staff_id, shift_id, event_type, occurred_at, note) VALUES
(1,  2, 101,  'CLOCK_IN',    '2026-11-02 11:02:00', NULL),
(2,  2, 101,  'BREAK_START', '2026-11-02 15:00:00', NULL),
(3,  2, 101,  'BREAK_END',   '2026-11-02 15:30:00', NULL),
(4,  2, 101,  'CLOCK_OUT',   '2026-11-02 19:05:00', NULL),
(5,  4, 102,  'CLOCK_IN',    '2026-11-02 10:15:00', 'Bus was late'),
(6,  4, 102,  'CLOCK_OUT',   '2026-11-02 18:00:00', NULL),
(7,  3, 103,  'CLOCK_IN',    '2026-11-03 17:00:00', NULL),
(8,  3, 103,  'CLOCK_OUT',   '2026-11-03 23:10:00', NULL),
(9,  5, NULL, 'CLOCK_IN',    '2026-11-04 12:00:00', 'Called in to help with a large party'),
(10, 5, NULL, 'CLOCK_OUT',   '2026-11-04 16:00:00', NULL);


INSERT INTO TimeOffRequest (request_id, staff_id, decided_by, start_date, end_date, hours, reason, status, created_at) VALUES
(1, 3, NULL, '2026-12-20', '2026-12-24', 30.00, 'Family visit',  'PENDING',  '2026-11-01 10:00:00'),
(2, 4, NULL, '2026-11-25', '2026-11-25',  8.00, 'Appointment',   'PENDING',  '2026-10-30 18:20:00'),
(3, 2, 1,    '2026-11-20', '2026-11-21', 16.00, NULL,            'APPROVED', '2026-10-25 11:00:00');

INSERT INTO PayRecord (pay_record_id, staff_id, period_start, period_end, hours_worked, rate_snapshot, bonus, deductions) VALUES
(1, 1, '2026-10-01', '2026-10-31', 160.00, 4500.00, 200.00,  0.00),
(2, 2, '2026-10-01', '2026-10-31', 120.00,   18.50,  50.00, 30.00),
(3, 3, '2026-10-01', '2026-10-31',  96.00,   18.50,   0.00,  0.00),
(4, 4, '2026-10-01', '2026-10-31', 140.00,   21.00, 100.00, 40.00),
(5, 5, '2026-10-01', '2026-10-31',  80.00,   19.00,   0.00,  0.00),
(6, 7, '2026-10-01', '2026-10-31', 165.00, 4800.00,   0.00,  0.00),
(7, 8, '2026-10-01', '2026-10-31', 150.00,   22.00,   0.00, 25.00);

INSERT INTO StaffingRequirement (requirement_id, restaurant_id, work_date, start_time, end_time, department, required_count) VALUES
(1, 1, '2026-11-09', '12:00:00', '15:00:00', 'FRONT_OF_HOUSE', 1),
(2, 1, '2026-11-09', '17:00:00', '19:00:00', 'FRONT_OF_HOUSE', 3),
(3, 1, '2026-11-09', '11:00:00', '17:00:00', 'KITCHEN',        2),
(4, 1, '2026-11-10', '09:00:00', '17:00:00', 'MANAGEMENT',     1),
(5, 2, '2026-11-09', '12:00:00', '20:00:00', 'KITCHEN',        1);

-- ---------------------------------------------------------------------
-- Menu and Inventory
-- ---------------------------------------------------------------------

INSERT INTO MenuCategory (category_id, restaurant_id, name, sort_order) VALUES
(1, 1, 'Starters', 1),
(2, 1, 'Mains',    2),
(3, 1, 'Desserts', 3),
(4, 2, 'Wraps',    1),
(5, 2, 'Drinks',   2);

-- Seasonal Soup has no recipe and was never ordered; Lobster Roll is hidden
INSERT INTO MenuItem (menu_item_id, category_id, name, price, is_available) VALUES
(1,  1, 'Garlic Bread',       7.00, TRUE),
(2,  1, 'Vegan Soup',         8.50, TRUE),
(3,  2, 'Burger',            18.00, TRUE),
(4,  2, 'Fish and Chips',    22.00, TRUE),
(5,  2, 'Vegan Bowl',        17.00, TRUE),
(6,  3, 'Cheesecake',         9.00, TRUE),
(7,  3, 'Brownie',            8.00, TRUE),
(8,  2, 'Lobster Roll',      32.00, FALSE),
(9,  4, 'Chicken Doner Wrap', 13.00, TRUE),
(10, 4, 'Falafel Wrap',      12.00, TRUE),
(11, 5, 'Ayran',              3.50, TRUE),
(12, 1, 'Seasonal Soup',      9.50, TRUE);

-- Sumac has no par level, no lead time, and no stock movements
INSERT INTO InventoryItem (inventory_item_id, restaurant_id, name, unit, par_level, lead_time_days) VALUES
(1,  1, 'Beef Patty',      'unit', 20.00, 2),
(2,  1, 'Burger Bun',      'unit', 30.00, 1),
(3,  1, 'Potatoes',        'kg',   10.00, 2),
(4,  1, 'Cod',             'kg',    2.00, 3),
(5,  1, 'Cream Cheese',    'kg',    1.50, 4),
(6,  1, 'Vegetable Stock', 'l',     2.00, 2),
(7,  1, 'Chocolate',       'kg',    0.50, 5),
(8,  1, 'Bread',           'unit',  8.00, 1),
(9,  2, 'Chicken',         'kg',    3.00, 2),
(10, 2, 'Falafel Mix',     'kg',    1.00, 3),
(11, 2, 'Tortilla',        'unit', 20.00, 2),
(12, 2, 'Yogurt',          'l',     2.00, 2),
(13, 2, 'Sumac',           'kg',   NULL, NULL);

INSERT INTO RecipeLine (menu_item_id, inventory_item_id, qty_per_serving) VALUES
(1, 8, 1.00),
(2, 6, 0.30), (2, 3, 0.10),
(3, 1, 1.00), (3, 2, 1.00), (3, 3, 0.25),
(4, 4, 0.20), (4, 3, 0.30),
(5, 3, 0.20), (5, 6, 0.10),
(6, 5, 0.10),
(7, 7, 0.08),
(8, 2, 1.00),
(9, 9, 0.15), (9, 11, 1.00),
(10, 10, 0.12), (10, 11, 1.00),
(11, 12, 0.25);

-- RECEIVE > 0, CONSUME and WASTE < 0, ADJUST can be either sign
-- CONSUME rows log the use of October (Oct 31) and of the first week of November (Nov 7)
INSERT INTO StockMovement (movement_id, inventory_item_id, movement_type, quantity_delta, unit_cost, reason, occurred_at) VALUES
(1,  1,  'RECEIVE',  40.00,  4.00, NULL,               '2026-10-01 08:00:00'),
(2,  1,  'WASTE',    -3.00,  4.00, 'Fridge too warm',  '2026-10-15 22:00:00'),
(3,  1,  'CONSUME', -13.00,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(4,  1,  'RECEIVE',  10.00,  4.40, NULL,               '2026-11-03 08:00:00'),
(5,  1,  'CONSUME',  -9.00,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(6,  2,  'RECEIVE',  60.00,  0.50, NULL,               '2026-10-01 08:00:00'),
(7,  2,  'CONSUME', -13.00,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(8,  2,  'CONSUME',  -8.00,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(9,  3,  'RECEIVE',  20.00,  1.20, NULL,               '2026-10-01 08:00:00'),
(10, 3,  'WASTE',    -2.00,  1.20, 'Gone soft',        '2026-10-28 22:00:00'),
(11, 3,  'CONSUME',  -7.00,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(12, 3,  'RECEIVE',   5.00,  1.10, NULL,               '2026-11-04 08:00:00'),
(13, 3,  'ADJUST',   -1.00,  NULL, 'Stock count',      '2026-11-05 22:00:00'),
(14, 3,  'CONSUME',  -4.00,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(15, 4,  'RECEIVE',   3.00, 12.00, NULL,               '2026-10-01 08:00:00'),
(16, 4,  'WASTE',    -1.00, 12.00, 'Past use-by date', '2026-10-20 22:00:00'),
(17, 4,  'CONSUME',  -1.20,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(18, 4,  'CONSUME',  -0.60,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(19, 5,  'RECEIVE',   2.00,  9.00, NULL,               '2026-10-01 08:00:00'),
(20, 5,  'CONSUME',  -0.50,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(21, 5,  'CONSUME',  -0.40,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(22, 6,  'RECEIVE',   6.00,  2.50, NULL,               '2026-10-01 08:00:00'),
(23, 6,  'CONSUME',  -2.00,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(24, 6,  'CONSUME',  -1.00,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(25, 7,  'RECEIVE',   0.60, 15.00, NULL,               '2026-10-01 08:00:00'),
(26, 7,  'CONSUME',  -0.20,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(27, 7,  'CONSUME',  -0.30,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(28, 8,  'RECEIVE',  10.00,  0.80, NULL,               '2026-10-01 08:00:00'),
(29, 8,  'WASTE',    -4.00,  0.80, 'Stale',            '2026-10-10 22:00:00'),
(30, 8,  'CONSUME',  -2.00,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(31, 8,  'RECEIVE',   5.00,  0.80, NULL,               '2026-11-06 08:00:00'),
(32, 8,  'CONSUME',  -2.00,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(33, 9,  'RECEIVE',   5.00,  7.00, NULL,               '2026-10-01 08:00:00'),
(34, 9,  'CONSUME',  -0.20,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(35, 9,  'RECEIVE',   2.00,  7.50, NULL,               '2026-11-05 08:00:00'),
(36, 9,  'CONSUME',  -0.40,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(37, 10, 'RECEIVE',   2.00,  5.00, NULL,               '2026-10-01 08:00:00'),
(38, 10, 'CONSUME',  -0.24,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(39, 10, 'CONSUME',  -0.12,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(40, 11, 'RECEIVE',  50.00,  0.30, NULL,               '2026-10-01 08:00:00'),
(41, 11, 'CONSUME',  -3.00,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(42, 11, 'CONSUME',  -4.00,  NULL, 'Week sales',       '2026-11-07 23:00:00'),
(43, 12, 'RECEIVE',   5.00,  2.00, NULL,               '2026-10-01 08:00:00'),
(44, 12, 'WASTE',    -1.00,  2.00, 'Spilled',          '2026-10-12 22:00:00'),
(45, 12, 'CONSUME',  -0.50,  NULL, 'October sales',    '2026-10-31 23:00:00'),
(46, 12, 'CONSUME',  -0.50,  NULL, 'Week sales',       '2026-11-07 23:00:00');

-- ---------------------------------------------------------------------
-- Front of House
-- ---------------------------------------------------------------------

INSERT INTO DiningTable (table_id, restaurant_id, label, seats, section) VALUES
(1, 1, 'T1', 2, 'Patio'),
(2, 1, 'T2', 4, 'Patio'),
(3, 1, 'T3', 4, 'Main'),
(4, 1, 'T4', 6, 'Main'),
(5, 1, 'T5', 8, 'Main'),
(6, 1, 'B1', 2, 'Bar'),
(7, 2, 'K1', 4, 'Main'),
(8, 2, 'K2', 4, 'Main'),
(9, 2, 'K3', 2, NULL);

INSERT INTO Customer (customer_id, name, phone, email) VALUES
(1, 'Sam Lee',     '250-555-3001', 'sam@mail.ca'),
(2, 'Priya Shah',  '250-555-3002', 'priya@mail.ca'),
(3, 'Tom Baker',   '250-555-3003', NULL),
(4, 'Maria Lopez', '250-555-3004', 'maria@mail.ca'),
(5, 'Jordan Kim',  '250-555-3005', NULL),
(6, 'Aisha Khan',  '250-555-3006', 'aisha@mail.ca'),
(7, 'Leo Chen',    '250-555-3007', NULL);

-- "Today" in the sample data is 2026-11-08
INSERT INTO Reservation (reservation_id, table_id, customer_id, reserved_for, party_size, status) VALUES
(1, 3, 1, '2026-11-08 19:00:00', 4, 'BOOKED'),
(2, 6, 2, '2026-11-08 20:00:00', 2, 'BOOKED'),
(3, 2, 3, '2026-10-10 18:00:00', 3, 'NO_SHOW'),
(4, 3, 3, '2026-10-24 19:00:00', 4, 'NO_SHOW'),
(5, 4, 4, '2026-10-17 19:30:00', 5, 'SEATED'),
(6, 5, 5, '2026-11-08 19:00:00', 7, 'CANCELLED'),
(7, 7, 6, '2026-11-01 18:00:00', 3, 'SEATED');

-- Orders 1-21, 26-27: Harbour Grill; 22-25: Kebab Corner; 19-21 are from today and not finished
INSERT INTO CustomerOrder (order_id, restaurant_id, customer_id, channel, status, payment_type, tip, created_at, started_at, finished_at) VALUES
(1,  1, 1,    'IN_PERSON', 'FULFILLED', 'CARD',         8.00, '2026-10-03 18:00:00', '2026-10-03 18:05:00', '2026-10-03 18:35:00'),
(2,  1, 2,    'IN_PERSON', 'FULFILLED', 'CASH',         5.00, '2026-10-05 19:00:00', '2026-10-05 19:03:00', '2026-10-05 19:30:00'),
(3,  1, NULL, 'IN_PERSON', 'FULFILLED', 'CARD',        10.00, '2026-10-10 12:30:00', '2026-10-10 12:32:00', '2026-10-10 12:55:00'),
(4,  1, 4,    'IN_PERSON', 'FULFILLED', 'CARD',        12.00, '2026-10-17 19:30:00', '2026-10-17 19:35:00', '2026-10-17 20:10:00'),
(5,  1, 5,    'IN_PERSON', 'FULFILLED', 'CARD',         6.00, '2026-10-18 13:00:00', '2026-10-18 13:02:00', '2026-10-18 13:28:00'),
(6,  1, 1,    'PHONE',     'FULFILLED', 'CARD',         0.00, '2026-10-20 17:30:00', '2026-10-20 17:35:00', '2026-10-20 18:00:00'),
(7,  1, 3,    'ONLINE',    'FULFILLED', 'ONLINE',       3.00, '2026-10-22 18:15:00', '2026-10-22 18:20:00', '2026-10-22 18:50:00'),
(8,  1, 6,    'ONLINE',    'FULFILLED', 'THIRD_PARTY',  0.00, '2026-10-24 19:00:00', '2026-10-24 19:05:00', '2026-10-24 19:40:00'),
(9,  1, 2,    'IN_PERSON', 'FULFILLED', 'CARD',         7.00, '2026-10-25 18:30:00', '2026-10-25 18:33:00', '2026-10-25 19:05:00'),
(10, 1, 5,    'ONLINE',    'FULFILLED', 'THIRD_PARTY',  0.00, '2026-10-28 20:00:00', '2026-10-28 20:04:00', '2026-10-28 20:30:00'),
(11, 1, 4,    'IN_PERSON', 'FULFILLED', 'CASH',         4.00, '2026-10-30 12:00:00', '2026-10-30 12:02:00', '2026-10-30 12:20:00'),
(12, 1, 1,    'IN_PERSON', 'FULFILLED', 'CARD',         9.00, '2026-11-01 18:00:00', '2026-11-01 18:04:00', '2026-11-01 18:40:00'),
(13, 1, 6,    'ONLINE',    'FULFILLED', 'THIRD_PARTY',  0.00, '2026-11-02 19:30:00', '2026-11-02 19:33:00', '2026-11-02 20:05:00'),
(14, 1, 3,    'PHONE',     'FULFILLED', 'CASH',         2.00, '2026-11-03 12:15:00', '2026-11-03 12:20:00', '2026-11-03 12:40:00'),
(15, 1, NULL, 'IN_PERSON', 'FULFILLED', 'CARD',         5.00, '2026-11-04 13:00:00', '2026-11-04 13:01:00', '2026-11-04 13:25:00'),
(16, 1, 7,    'ONLINE',    'FULFILLED', 'ONLINE',       4.00, '2026-11-05 18:45:00', '2026-11-05 18:50:00', '2026-11-05 19:20:00'),
(17, 1, 2,    'IN_PERSON', 'FULFILLED', 'CARD',         6.00, '2026-11-06 19:00:00', '2026-11-06 19:02:00', '2026-11-06 19:35:00'),
(18, 1, 5,    'PHONE',     'FULFILLED', 'CARD',         0.00, '2026-11-07 12:30:00', '2026-11-07 12:31:00', '2026-11-07 12:50:00'),
(19, 1, 4,    'IN_PERSON', 'CONFIRMED', 'CARD',         0.00, '2026-11-08 12:00:00', '2026-11-08 12:05:00', NULL),
(20, 1, 7,    'ONLINE',    'PENDING',   'ONLINE',       0.00, '2026-11-08 11:20:00', NULL,                  NULL),
(21, 1, NULL, 'PHONE',     'CONFIRMED', 'CASH',         0.00, '2026-11-08 12:10:00', '2026-11-08 12:15:00', NULL),
(22, 2, 6,    'IN_PERSON', 'FULFILLED', 'CARD',         3.00, '2026-11-01 18:00:00', '2026-11-01 18:03:00', '2026-11-01 18:25:00'),
(23, 2, 7,    'ONLINE',    'FULFILLED', 'THIRD_PARTY',  0.00, '2026-10-15 19:00:00', '2026-10-15 19:02:00', '2026-10-15 19:20:00'),
(24, 2, NULL, 'IN_PERSON', 'FULFILLED', 'CASH',         1.00, '2026-10-21 13:00:00', '2026-10-21 13:01:00', '2026-10-21 13:12:00'),
(25, 2, 3,    'PHONE',     'FULFILLED', 'CASH',         0.00, '2026-11-05 12:00:00', '2026-11-05 12:02:00', '2026-11-05 12:15:00'),
(26, 1, NULL, 'IN_PERSON', 'FULFILLED', 'CARD',         3.00, '2026-11-02 12:30:00', '2026-11-02 12:32:00', '2026-11-02 12:55:00'),
(27, 1, 5,    'PHONE',     'FULFILLED', 'CARD',         0.00, '2026-11-02 13:10:00', '2026-11-02 13:12:00', '2026-11-02 13:30:00');

-- Servers: Ben (2) and Chloe (3) at Harbour Grill, Ilyas (9) at Kebab Corner
INSERT INTO DineInOrder (order_id, table_id, server_id, party_size) VALUES
(1,  3, 2, 2),
(2,  2, 2, 2),
(3,  4, 2, 4),
(4,  4, 3, 5),
(5,  1, 2, 2),
(9,  3, 3, 2),
(11, 2, 2, 3),
(12, 5, 2, 6),
(15, 6, 3, 1),
(17, 3, 2, 2),
(19, 4, 3, 4),
(22, 7, 9, 3),
(26, 1, 2, 2);

INSERT INTO DeliveryOrder (order_id, delivery_address, delivery_notes, courier, external_order_ref) VALUES
(7,  '45 Cook St, Victoria',    'Ring the bell', 'IN_HOUSE',  NULL),
(8,  '102 Fort St, Victoria',   NULL,            'UBER_EATS', 'UE-2001'),
(10, '9 Pandora Ave, Victoria', NULL,            'UBER_EATS', 'UE-2002'),
(13, '102 Fort St, Victoria',   'Leave at door', 'UBER_EATS', 'UE-2003'),
(16, '77 Oak Bay Ave, Victoria', NULL,           'IN_HOUSE',  NULL),
(20, '77 Oak Bay Ave, Victoria', NULL,           'IN_HOUSE',  NULL),
(23, '77 Oak Bay Ave, Victoria', NULL,           'UBER_EATS', 'UE-3001');

-- Orders 3, 12, and 19 were sent to the kitchen in two batches
INSERT INTO KitchenTicket (ticket_id, order_id, batch_no, status, is_priority, created_at, completed_at) VALUES
(1,  1,  1, 'READY',   FALSE, '2026-10-03 18:06:00', '2026-10-03 18:25:00'),
(2,  3,  1, 'READY',   TRUE,  '2026-10-10 12:33:00', '2026-10-10 12:45:00'),
(3,  3,  2, 'READY',   FALSE, '2026-10-10 12:40:00', '2026-10-10 12:52:00'),
(4,  4,  1, 'READY',   FALSE, '2026-10-17 19:36:00', '2026-10-17 20:00:00'),
(5,  12, 1, 'READY',   TRUE,  '2026-11-01 18:05:00', '2026-11-01 18:20:00'),
(6,  12, 2, 'READY',   FALSE, '2026-11-01 18:20:00', '2026-11-01 18:38:00'),
(7,  13, 1, 'READY',   FALSE, '2026-11-02 19:34:00', '2026-11-02 19:58:00'),
(8,  19, 1, 'COOKING', TRUE,  '2026-11-08 12:06:00', NULL),
(9,  19, 2, 'NEW',     FALSE, '2026-11-08 12:20:00', NULL),
(10, 21, 1, 'COOKING', FALSE, '2026-11-08 12:16:00', NULL),
(11, 22, 1, 'READY',   FALSE, '2026-11-01 18:04:00', '2026-11-01 18:20:00');

-- Burger was 17.00 in early October (orders 1 and 3), now 18.00
INSERT INTO OrderItem (order_id, line_no, menu_item_id, ticket_id, quantity, unit_price, notes) VALUES
(1,  1, 3,  1,    2, 17.00, NULL),
(1,  2, 1,  1,    1,  7.00, NULL),
(2,  1, 4,  NULL, 1, 22.00, NULL),
(2,  2, 6,  NULL, 1,  9.00, NULL),
(3,  1, 3,  2,    3, 17.00, 'No onions'),
(3,  2, 2,  2,    1,  8.50, NULL),
(3,  3, 7,  3,    2,  8.00, NULL),
(4,  1, 4,  4,    2, 22.00, NULL),
(4,  2, 3,  4,    2, 18.00, NULL),
(4,  3, 6,  4,    1,  9.00, NULL),
(5,  1, 5,  NULL, 2, 17.00, NULL),
(5,  2, 1,  NULL, 1,  7.00, NULL),
(6,  1, 3,  NULL, 2, 18.00, NULL),
(7,  1, 4,  NULL, 2, 22.00, NULL),
(7,  2, 2,  NULL, 2,  8.50, NULL),
(8,  1, 3,  NULL, 3, 18.00, NULL),
(9,  1, 5,  NULL, 1, 17.00, NULL),
(9,  2, 7,  NULL, 2,  8.00, NULL),
(10, 1, 5,  NULL, 1, 17.00, NULL),
(10, 2, 7,  NULL, 1,  8.00, NULL),
(11, 1, 2,  NULL, 3,  8.50, NULL),
(11, 2, 3,  NULL, 1, 18.00, NULL),
(12, 1, 3,  5,    4, 18.00, 'Two medium rare'),
(12, 2, 4,  5,    2, 22.00, NULL),
(12, 3, 6,  6,    3,  9.00, NULL),
(13, 1, 4,  7,    2, 22.00, NULL),
(14, 1, 3,  NULL, 1, 18.00, NULL),
(14, 2, 1,  NULL, 2,  7.00, NULL),
(15, 1, 2,  NULL, 1,  8.50, NULL),
(16, 1, 5,  NULL, 2, 17.00, NULL),
(17, 1, 3,  NULL, 2, 18.00, NULL),
(17, 2, 6,  NULL, 2,  9.00, NULL),
(18, 1, 4,  NULL, 1, 22.00, NULL),
(19, 1, 3,  8,    2, 18.00, 'No onions'),
(19, 2, 4,  8,    1, 22.00, NULL),
(19, 3, 7,  9,    2,  8.00, 'Extra sauce'),
(19, 4, 5,  8,    1, 17.00, NULL),
(20, 1, 3,  NULL, 1, 18.00, NULL),
(21, 1, 1,  10,   1,  7.00, 'Well done'),
(21, 2, 2,  10,   1,  8.50, NULL),
(22, 1, 9,  11,   2, 13.00, NULL),
(22, 2, 11, 11,   3,  3.50, NULL),
(23, 1, 10, NULL, 2, 12.00, NULL),
(24, 1, 9,  NULL, 1, 13.00, NULL),
(24, 2, 11, NULL, 1,  3.50, NULL),
(25, 1, 10, NULL, 1, 12.00, NULL),
(25, 2, 9,  NULL, 1, 13.00, NULL),
(26, 1, 3,  NULL, 1, 18.00, NULL),
(26, 2, 6,  NULL, 1,  9.00, NULL),
(27, 1, 5,  NULL, 1, 17.00, NULL);

INSERT INTO Review (review_id, order_id, rating, comment, created_at) VALUES
(1,  1,  5, 'Great burger',          '2026-10-03 20:00:00'),
(2,  2,  4, NULL,                    '2026-10-05 21:00:00'),
(3,  3,  2, 'Burger was cold',       '2026-10-10 14:00:00'),
(4,  5,  5, NULL,                    '2026-10-18 15:00:00'),
(5,  11, 4, NULL,                    '2026-10-30 13:00:00'),
(6,  12, 5, 'Lovely evening',        '2026-11-01 21:00:00'),
(7,  17, 1, 'Slow service',          '2026-11-06 20:00:00'),
(8,  4,  3, NULL,                    '2026-10-17 21:00:00'),
(9,  9,  5, 'Best brownie in town',  '2026-10-25 20:00:00'),
(10, 7,  2, 'Late delivery',         '2026-10-22 20:00:00'),
(11, 13, 2, 'Food arrived cold',     '2026-11-02 21:00:00'),
(12, 22, 4, NULL,                    '2026-11-01 20:00:00');

-- ---------------------------------------------------------------------
-- Marketing and Analytics
-- ---------------------------------------------------------------------

INSERT INTO Campaign (campaign_id, restaurant_id, name, start_date, end_date, budget) VALUES
(1, 1, 'Fall Burger Week', '2026-10-20', '2026-10-31', 300.00),
(2, 1, 'Dessert Month',    '2026-11-01', '2026-11-30', 150.00),
(3, 1, 'Vegan November',   '2026-11-01', NULL,         NULL),
(4, 2, 'Wrap Deal',        '2026-10-10', '2026-10-25', 100.00);

INSERT INTO CampaignItem (campaign_id, menu_item_id) VALUES
(1, 3),
(2, 6), (2, 7),
(3, 2), (3, 5),
(4, 9), (4, 10);

-- The restaurant of an announcement comes from its author
INSERT INTO Announcement (announcement_id, author_id, message, announcement_type, is_active, created_at) VALUES
(1, 1, 'Staff meeting on Monday at 9am',       'INFO',    TRUE,  '2026-11-02 09:00:00'),
(2, 1, 'New dessert menu starts this month',   'PROMO',   TRUE,  '2026-11-01 10:00:00'),
(3, 1, 'Patio is closed for the winter',       'WARNING', FALSE, '2026-10-15 10:00:00'),
(4, 3, 'The lost and found box has moved',     'INFO',    TRUE,  '2026-11-05 16:00:00'),
(5, 7, 'Holiday opening hours are posted',     'INFO',    TRUE,  '2026-11-03 11:00:00');

INSERT INTO WeatherObservation (restaurant_id, observed_date, temp_max, temp_min, `condition`, precipitation_mm) VALUES
(1, '2026-10-03', 16.00, 9.00, 'SUNNY',  0.00),
(1, '2026-10-05', 14.00, 8.00, 'CLOUDY', 0.00),
(1, '2026-10-10', 12.00, 7.00, 'RAIN',   8.50),
(1, '2026-10-17', 13.00, 6.00, 'SUNNY',  0.00),
(1, '2026-10-18', 12.00, 6.00, 'CLOUDY', 0.00),
(1, '2026-10-20', 11.00, 6.00, 'RAIN',  12.00),
(1, '2026-10-22', 10.00, 5.00, 'RAIN',   6.00),
(1, '2026-10-24', 10.00, 4.00, 'RAIN',   9.50),
(1, '2026-10-25', 11.00, 5.00, 'CLOUDY', 0.00),
(1, '2026-10-28',  9.00, 4.00, 'RAIN',  15.00),
(1, '2026-10-30', 12.00, 5.00, 'SUNNY',  0.00),
(1, '2026-11-01', 10.00, 4.00, 'CLOUDY', 0.00),
(1, '2026-11-02',  9.00, 3.00, 'RAIN',  11.00),
(1, '2026-11-03',  8.00, 3.00, 'RAIN',   4.00),
(1, '2026-11-04', 10.00, 2.00, 'SUNNY',  0.00),
(1, '2026-11-05',  8.00, 3.00, 'RAIN',   7.00),
(1, '2026-11-06',  9.00, 2.00, 'CLOUDY', 0.00),
(1, '2026-11-07',  2.00, -2.00, 'SNOW',  3.00),
(1, '2026-11-08',  6.00, 1.00, 'CLOUDY', NULL),
(2, '2026-10-15', 12.00, 6.00, 'RAIN',   5.00),
(2, '2026-10-21', 13.00, 6.00, 'SUNNY',  0.00),
(2, '2026-11-01', 10.00, 4.00, 'CLOUDY', 0.00),
(2, '2026-11-05',  8.00, 3.00, 'RAIN',   7.00);

INSERT INTO Insight (insight_id, restaurant_id, title, message, insight_type, created_at, expires_at) VALUES
(1, 1, 'Rain brings deliveries', 'Rainy evenings have more delivery orders; plan an extra driver', 'INFO',    '2026-10-29 09:00:00', '2026-11-30 00:00:00'),
(2, 1, 'Cod is running low',     'Cod will run out before the next delivery can arrive',           'ALERT',   '2026-11-07 09:00:00', '2026-11-10 00:00:00'),
(3, 1, 'Dessert promo works',    'Dessert sales are up since Dessert Month started',               'SUCCESS', '2026-11-06 09:00:00', NULL),
(4, 1, 'Short staffed Friday',   'Friday evening needs one more server',                           'ALERT',   '2026-10-20 09:00:00', '2026-10-25 00:00:00'),
(5, 1, 'Burger Week result',     'Burger sales doubled during Fall Burger Week',                   'SUCCESS', '2026-10-31 09:00:00', '2026-11-07 00:00:00'),
(6, 2, 'Wrap Deal finished',     'The Wrap Deal campaign brought 12 new customers',                'SUCCESS', '2026-10-26 09:00:00', NULL);


-- ---------------------------------------------------------------------
-- Rule check on the sample data (S2-G6): every count must be 0
-- (a trigger cannot stop a new order, ticket, or campaign from being empty
--  for a moment, because the parent row is inserted before its children)
-- ---------------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM CustomerOrder AS o
     WHERE o.status <> 'CANCELLED'
       AND NOT EXISTS (SELECT * FROM OrderItem AS oi WHERE oi.order_id = o.order_id)) AS empty_orders,
    (SELECT COUNT(*) FROM KitchenTicket AS kt
     WHERE NOT EXISTS (SELECT * FROM OrderItem AS oi WHERE oi.ticket_id = kt.ticket_id)) AS empty_tickets,
    (SELECT COUNT(*) FROM Campaign AS c
     WHERE NOT EXISTS (SELECT * FROM CampaignItem AS ci WHERE ci.campaign_id = c.campaign_id)) AS empty_campaigns,
    (SELECT COUNT(*) FROM OrderItem AS oi
     JOIN CustomerOrder AS o ON (oi.order_id = o.order_id)
     JOIN MenuItem AS m ON (oi.menu_item_id = m.menu_item_id)
     JOIN MenuCategory AS c ON (m.category_id = c.category_id)
     WHERE o.restaurant_id <> c.restaurant_id) AS cross_restaurant_lines;

-- =====================================================================
-- Constraint tests (S2-G6)
-- Every BAD statement breaks one constraint and must be rejected.
-- Run this file with --force so it keeps going after each error:
--   mysql -u root -t --force < seed.sql
-- Expected: 62 errors (42 main tests + 12 edge cases + 8 trigger tests), then four rows of counts.
-- Everything here is inside a transaction and ROLLBACK at the end removes it,
-- so the sample data above stays the same.
-- Test rows use ids 901+ so they do not clash with the sample data.
-- =====================================================================

START TRANSACTION;

-- ---------------------------------------------------------------------
-- Valid test rows (the tests below need them)
-- ---------------------------------------------------------------------

INSERT INTO MenuCategory (category_id, restaurant_id, name, sort_order) VALUES (901, 1, 'Test Mains', 99);
INSERT INTO MenuItem (menu_item_id, category_id, name, price) VALUES (901, 901, 'Test Burger', 15.00);
INSERT INTO InventoryItem (inventory_item_id, restaurant_id, name, unit) VALUES (901, 1, 'Test Beef', 'kg');
INSERT INTO DiningTable (table_id, restaurant_id, label, seats) VALUES (901, 1, 'T901', 4);
INSERT INTO Customer (customer_id, name, phone) VALUES (901, 'Test Customer', '250-555-9901');
INSERT INTO CustomerOrder (order_id, restaurant_id, channel) VALUES (901, 1, 'IN_PERSON');
INSERT INTO CustomerOrder (order_id, restaurant_id, channel) VALUES (902, 1, 'ONLINE');
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (901, 1, 901, 2, 15.00);

-- ---------------------------------------------------------------------
-- Foreign keys (error 1452 / 1451)
-- ---------------------------------------------------------------------

-- BAD: order item for an order that does not exist
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (999, 1, 901, 1, 15.00);
-- BAD: order item for a menu item that does not exist
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (901, 2, 999, 1, 15.00);
-- BAD: staff member with a role the restaurant never defined
INSERT INTO Staff (restaurant_id, role_name, name, hire_date) VALUES (1, 'Pilot', 'Bob', '2026-02-01');
-- BAD: shift for a staff member that does not exist
INSERT INTO Shift (staff_id, start_at, end_at) VALUES (999, '2026-11-09 09:00', '2026-11-09 17:00');
-- BAD: hourly pay for a staff member that does not exist
INSERT INTO HourlyStaff VALUES (999, 18.50);
-- BAD: deleting a restaurant that still has staff, menus, and orders
DELETE FROM Restaurant WHERE restaurant_id = 1;

-- ---------------------------------------------------------------------
-- NOT NULL (error 1048)
-- ---------------------------------------------------------------------

-- BAD: staff member with no name
INSERT INTO Staff (restaurant_id, role_name, name, hire_date) VALUES (1, 'Server', NULL, '2026-02-01');
-- BAD: menu item with no price
INSERT INTO MenuItem (category_id, name, price) VALUES (901, 'Test Fries', NULL);

-- ---------------------------------------------------------------------
-- CHECK constraints (MySQL error 3819, MariaDB error 4025)
-- ---------------------------------------------------------------------

-- BAD: chk_hourly_rate (hourly rate of 0) - Alice is salaried, so she is not in HourlyStaff yet
INSERT INTO HourlyStaff VALUES (1, 0.00);
-- BAD: chk_monthly_salary (negative salary) - Ben is hourly, so he is not in SalariedStaff yet
INSERT INTO SalariedStaff VALUES (2, -100.00);
-- BAD: chk_shift_time (shift ends before it starts)
INSERT INTO Shift (staff_id, start_at, end_at) VALUES (1, '2026-11-10 17:00', '2026-11-10 09:00');
-- BAD: chk_swap_decided (denied, but no manager decided)
INSERT INTO SwapRequest (shift_id, status) VALUES (1, 'DENIED');
-- BAD: chk_swap_cover (approved, but nobody covers)
INSERT INTO SwapRequest (shift_id, decided_by, status) VALUES (1, 1, 'APPROVED');
-- BAD: chk_timeoff_dates (ends before it starts)
INSERT INTO TimeOffRequest (staff_id, start_date, end_date, hours) VALUES (1, '2026-12-10', '2026-12-05', 8.00);
-- BAD: chk_timeoff_hours (0 hours)
INSERT INTO TimeOffRequest (staff_id, start_date, end_date, hours) VALUES (1, '2026-12-10', '2026-12-10', 0.00);
-- BAD: chk_timeoff_decided (approved, but no manager decided)
INSERT INTO TimeOffRequest (staff_id, start_date, end_date, hours, status) VALUES (1, '2026-12-10', '2026-12-10', 8.00, 'APPROVED');
-- BAD: chk_pay_period (period ends before it starts)
INSERT INTO PayRecord (staff_id, period_start, period_end, hours_worked, rate_snapshot) VALUES (1, '2026-11-30', '2026-11-01', 100.00, 18.50);
-- BAD: chk_pay_amounts (negative hours)
INSERT INTO PayRecord (staff_id, period_start, period_end, hours_worked, rate_snapshot) VALUES (1, '2026-11-01', '2026-11-30', -5.00, 18.50);
-- BAD: chk_staffing_time (slot ends before it starts)
INSERT INTO StaffingRequirement (restaurant_id, work_date, start_time, end_time, department, required_count) VALUES (1, '2026-12-01', '17:00', '12:00', 'KITCHEN', 2);
-- BAD: chk_staffing_count (0 staff needed)
INSERT INTO StaffingRequirement (restaurant_id, work_date, start_time, end_time, department, required_count) VALUES (1, '2026-12-01', '12:00', '17:00', 'KITCHEN', 0);
-- BAD: chk_menu_price (negative price)
INSERT INTO MenuItem (category_id, name, price) VALUES (901, 'Test Free Fries', -2.00);
-- BAD: chk_inventory_levels (negative par level)
INSERT INTO InventoryItem (restaurant_id, name, unit, par_level) VALUES (1, 'Test Buns', 'unit', -1.00);
-- BAD: chk_recipe_qty (0 per serving)
INSERT INTO RecipeLine VALUES (901, 901, 0.00);
-- BAD: chk_movement_sign (waste logged as a positive quantity)
INSERT INTO StockMovement (inventory_item_id, movement_type, quantity_delta) VALUES (901, 'WASTE', 3.00);
-- BAD: chk_movement_cost (negative cost)
INSERT INTO StockMovement (inventory_item_id, movement_type, quantity_delta, unit_cost) VALUES (901, 'RECEIVE', 5.00, -1.00);
-- BAD: chk_table_seats (table with 0 seats)
INSERT INTO DiningTable (restaurant_id, label, seats) VALUES (1, 'T902', 0);
-- BAD: chk_reservation_party (party of 0)
INSERT INTO Reservation (table_id, customer_id, reserved_for, party_size) VALUES (901, 901, '2026-11-09 19:00', 0);
-- BAD: chk_order_tip (negative tip)
INSERT INTO CustomerOrder (restaurant_id, channel, tip) VALUES (1, 'IN_PERSON', -1.00);
-- BAD: chk_order_times (started before it was created)
INSERT INTO CustomerOrder (restaurant_id, channel, created_at, started_at) VALUES (1, 'IN_PERSON', '2026-11-05 12:00', '2026-11-05 11:00');
-- BAD: chk_dinein_party (party of 0)
INSERT INTO DineInOrder (order_id, table_id, party_size) VALUES (901, 901, 0);
-- BAD: chk_delivery_ref (Uber Eats without the Uber Eats reference)
INSERT INTO DeliveryOrder (order_id, delivery_address, courier) VALUES (902, '12 Main St', 'UBER_EATS');
-- BAD: chk_ticket_batch (batch 0)
INSERT INTO KitchenTicket (order_id, batch_no) VALUES (901, 0);
-- BAD: chk_ticket_times (completed before it was created)
INSERT INTO KitchenTicket (order_id, batch_no, created_at, completed_at) VALUES (901, 1, '2026-11-05 12:00', '2026-11-05 11:00');
-- BAD: chk_item_line (line number 0)
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (901, 0, 901, 1, 15.00);
-- BAD: chk_item_quantity (quantity 0)
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (901, 2, 901, 0, 15.00);
-- BAD: chk_item_price (negative price)
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (901, 3, 901, 1, -15.00);
-- BAD: chk_review_rating (rating 6)
INSERT INTO Review (order_id, rating) VALUES (901, 6);
-- BAD: chk_campaign_dates (ends before it starts)
INSERT INTO Campaign (restaurant_id, name, start_date, end_date) VALUES (1, 'Test Summer', '2026-08-31', '2026-06-01');
-- BAD: chk_campaign_budget (negative budget)
INSERT INTO Campaign (restaurant_id, name, start_date, budget) VALUES (1, 'Test Winter', '2026-12-01', -50.00);
-- BAD: chk_weather_temp (max lower than min)
INSERT INTO WeatherObservation (restaurant_id, observed_date, temp_max, temp_min, `condition`) VALUES (1, '2025-01-01', 4.00, 9.00, 'RAIN');
-- BAD: chk_weather_precip (negative rain)
INSERT INTO WeatherObservation (restaurant_id, observed_date, temp_max, temp_min, `condition`, precipitation_mm) VALUES (1, '2025-01-01', 9.00, 4.00, 'RAIN', -1.00);
-- BAD: chk_insight_expiry (expires before it was created)
INSERT INTO Insight (restaurant_id, title, message, insight_type, created_at, expires_at) VALUES (1, 'Test Insight', 'Add a server', 'ALERT', '2026-11-05 12:00', '2026-11-04 12:00');

-- ---------------------------------------------------------------------
-- OK: the same kinds of rows with valid values are accepted
-- ---------------------------------------------------------------------

INSERT INTO CustomerOrder (order_id, restaurant_id, customer_id, channel, payment_type) VALUES (903, 1, NULL, 'IN_PERSON', NULL);
INSERT INTO Review (order_id, rating) VALUES (901, 5);
INSERT INTO DeliveryOrder (order_id, delivery_address, courier, external_order_ref) VALUES (902, '12 Main St', 'UBER_EATS', 'UE-1001');
INSERT INTO StockMovement (inventory_item_id, movement_type, quantity_delta) VALUES (901, 'WASTE', -3.00);

-- ---------------------------------------------------------------------
-- Check: only valid rows are stored (expected values on the right)
-- ---------------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM Restaurant)                                AS restaurants,  -- 2
    (SELECT COUNT(*) FROM Staff)                                     AS staff,        -- 9
    (SELECT COUNT(*) FROM Shift)                                     AS shifts,       -- 10
    (SELECT COUNT(*) FROM SwapRequest)                               AS swaps,        -- 3
    (SELECT COUNT(*) FROM CustomerOrder WHERE order_id >= 901)       AS test_orders,  -- 3
    (SELECT COUNT(*) FROM OrderItem WHERE order_id >= 901)           AS test_items,   -- 1
    (SELECT COUNT(*) FROM Review WHERE order_id >= 901)              AS test_reviews, -- 1
    (SELECT COUNT(*) FROM DeliveryOrder WHERE order_id >= 901)       AS test_deliv,   -- 1
    (SELECT COUNT(*) FROM StockMovement WHERE inventory_item_id = 901) AS test_moves, -- 1
    (SELECT COUNT(*) FROM Campaign WHERE name LIKE 'Test%')          AS test_camps,   -- 0
    (SELECT COUNT(*) FROM Insight WHERE title LIKE 'Test%')          AS test_insights; -- 0

-- =====================================================================
-- Edge cases: values right at the limit of each rule
-- =====================================================================

-- ---------------------------------------------------------------------
-- BAD edge cases: just past the limit, must be rejected
-- ---------------------------------------------------------------------

-- BAD: chk_review_rating (rating 0, one below the lowest)
INSERT INTO Review (order_id, rating) VALUES (902, 0);
-- BAD: chk_menu_price (price -0.01, one cent below 0)
INSERT INTO MenuItem (category_id, name, price) VALUES (901, 'Test Minus Cent', -0.01);
-- BAD: chk_shift_time (shift ends at the same time it starts)
INSERT INTO Shift (staff_id, start_at, end_at) VALUES (1, '2026-11-10 09:00', '2026-11-10 09:00');
-- BAD: chk_movement_sign (ADJUST of 0 changes nothing)
INSERT INTO StockMovement (inventory_item_id, movement_type, quantity_delta) VALUES (901, 'ADJUST', 0.00);
-- BAD: chk_movement_sign (RECEIVE with a negative quantity)
INSERT INTO StockMovement (inventory_item_id, movement_type, quantity_delta) VALUES (901, 'RECEIVE', -5.00);
-- BAD: chk_insight_expiry (expires at the same moment it is created)
INSERT INTO Insight (restaurant_id, title, message, insight_type, created_at, expires_at) VALUES (1, 'Test Same Time', 'x', 'INFO', '2026-11-05 12:00', '2026-11-05 12:00');
-- BAD: primary key (same order and line number twice, error 1062)
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (901, 1, 901, 1, 15.00);
-- BAD: UNIQUE phone (two customers with the same phone, error 1062)
INSERT INTO Customer (customer_id, name, phone) VALUES (905, 'Test Copy', '250-555-9901');
-- BAD: UNIQUE username (Ilyas tries to take Alice's username, error 1062)
INSERT INTO StaffCredential (staff_id, username, password_hash) VALUES (9, 'alice', '$2b$12$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
-- BAD: UNIQUE (staff_id, occurred_at) (Ben clocks in twice at the same second, error 1062)
INSERT INTO TimeClockEvent (staff_id, shift_id, event_type, occurred_at) VALUES (2, 101, 'CLOCK_IN', '2026-11-02 11:02:00');
-- BAD: UNIQUE order_id in Review (second review for the same order, error 1062)
INSERT INTO Review (order_id, rating) VALUES (901, 4);
-- BAD: ENUM (channel 'FAX' is not in the list, error 1265)
INSERT INTO CustomerOrder (restaurant_id, channel) VALUES (1, 'FAX');

-- ---------------------------------------------------------------------
-- OK edge cases: exactly on the limit, or NULL, must be accepted
-- ---------------------------------------------------------------------

-- OK: rating 1, the lowest allowed
INSERT INTO Review (order_id, rating) VALUES (902, 1);
-- OK: price 0.00 (free item)
INSERT INTO MenuItem (category_id, name, price) VALUES (901, 'Test Free Water', 0.00);
-- OK: one-day time off (start date = end date)
INSERT INTO TimeOffRequest (staff_id, start_date, end_date, hours) VALUES (9, '2026-12-01', '2026-12-01', 0.50);
-- OK: pay record of all zeros for a one-day period
INSERT INTO PayRecord (staff_id, period_start, period_end, hours_worked, rate_snapshot, bonus, deductions) VALUES (9, '2026-11-01', '2026-11-01', 0.00, 0.00, 0.00, 0.00);
-- OK: ADJUST can go down (stock count was lower than expected)
INSERT INTO StockMovement (inventory_item_id, movement_type, quantity_delta) VALUES (901, 'ADJUST', -2.00);
-- OK: campaign with no end date and no budget (CHECK passes on NULL)
INSERT INTO Campaign (restaurant_id, name, start_date, end_date, budget) VALUES (1, 'Test Open Ended', '2026-12-01', NULL, NULL);
-- OK: insight that never expires (expires_at NULL)
INSERT INTO Insight (restaurant_id, title, message, insight_type, expires_at) VALUES (1, 'Test No Expiry', 'x', 'INFO', NULL);
-- OK: weather with max = min and 0 mm of rain
INSERT INTO WeatherObservation (restaurant_id, observed_date, temp_max, temp_min, `condition`, precipitation_mm) VALUES (1, '2025-01-01', 5.00, 5.00, 'CLOUDY', 0.00);
-- OK: batch 1, completed at the same moment it was created
INSERT INTO KitchenTicket (order_id, batch_no, created_at, completed_at) VALUES (901, 1, '2026-11-05 12:00', '2026-11-05 12:00');
-- OK: order created, started, and finished at the same moment
INSERT INTO CustomerOrder (order_id, restaurant_id, channel, created_at, started_at, finished_at) VALUES (904, 1, 'IN_PERSON', '2026-11-05 12:00', '2026-11-05 12:00', '2026-11-05 12:00');
-- OK: in-house delivery does not need an Uber Eats reference
INSERT INTO DeliveryOrder (order_id, delivery_address, courier, external_order_ref) VALUES (903, '5 Oak St', 'IN_HOUSE', NULL);
-- OK: denied swap with a manager but no cover
INSERT INTO SwapRequest (shift_id, cover_staff_id, decided_by, status) VALUES (1, NULL, 1, 'DENIED');
-- OK: reservation for a party of 1
INSERT INTO Reservation (table_id, customer_id, reserved_for, party_size) VALUES (901, 901, '2026-11-09 19:00', 1);

-- ---------------------------------------------------------------------
-- Check: edge cases (expected values on the right)
-- ---------------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM Review WHERE order_id >= 901)                AS test_reviews,
    (SELECT COUNT(*) FROM MenuItem WHERE category_id = 901)            AS test_items,
    (SELECT COUNT(*) FROM TimeOffRequest)                              AS timeoffs,
    (SELECT COUNT(*) FROM PayRecord)                                   AS pay_records,
    (SELECT COUNT(*) FROM StockMovement WHERE inventory_item_id = 901) AS test_moves,
    (SELECT COUNT(*) FROM Campaign WHERE name LIKE 'Test%')            AS test_camps,
    (SELECT COUNT(*) FROM Insight WHERE title LIKE 'Test%')            AS test_insights,
    (SELECT COUNT(*) FROM WeatherObservation WHERE observed_date = '2025-01-01') AS weather,
    (SELECT COUNT(*) FROM KitchenTicket WHERE order_id >= 901)          AS tickets,
    (SELECT COUNT(*) FROM CustomerOrder WHERE order_id >= 901)         AS test_orders,
    (SELECT COUNT(*) FROM DeliveryOrder WHERE order_id >= 901)         AS test_deliv,
    (SELECT COUNT(*) FROM SwapRequest)                                 AS swaps,
    (SELECT COUNT(*) FROM Customer WHERE customer_id >= 901)           AS test_custs,
    (SELECT COUNT(*) FROM Reservation WHERE table_id = 901)             AS reservations;

-- Expected: 2 2 4 8 2 1 1 1 1 4 2 4 1 1

-- =====================================================================
-- Trigger tests (S2-G6): 8 BAD statements (error 1644), then the OK ones
-- =====================================================================

-- Valid test rows for the trigger tests
INSERT INTO CustomerOrder (order_id, restaurant_id, channel) VALUES (905, 1, 'IN_PERSON');
INSERT INTO Campaign (campaign_id, restaurant_id, name, start_date) VALUES (905, 1, 'Test Promo', '2026-11-01');
INSERT INTO CampaignItem (campaign_id, menu_item_id) VALUES (905, 901);

-- BAD: T1 (a Harbour Grill order with a Kebab Corner menu item)
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (905, 1, 9, 1, 13.00);
-- BAD: T2 (change an order line to a Kebab Corner menu item)
UPDATE OrderItem SET menu_item_id = 9 WHERE order_id = 901 AND line_no = 1;
-- BAD: T3 (a Harbour Grill order at a Kebab Corner table)
INSERT INTO DineInOrder (order_id, table_id, server_id, party_size) VALUES (905, 7, NULL, 2);
-- BAD: T3 (a Harbour Grill order served by a Kebab Corner server)
INSERT INTO DineInOrder (order_id, table_id, server_id, party_size) VALUES (905, 901, 9, 2);
-- BAD: T4 (move dine-in order 1 to a Kebab Corner table)
UPDATE DineInOrder SET table_id = 7 WHERE order_id = 1;
-- BAD: T5 (delete the only line of order 901)
DELETE FROM OrderItem WHERE order_id = 901 AND line_no = 1;
-- BAD: T5 (delete the only line on kitchen ticket 3; order 3 still has other lines)
DELETE FROM OrderItem WHERE order_id = 3 AND line_no = 3;
-- BAD: T6 (delete the only menu item of campaign 905)
DELETE FROM CampaignItem WHERE campaign_id = 905 AND menu_item_id = 901;

-- OK: an order line with a menu item of the same restaurant
INSERT INTO OrderItem (order_id, line_no, menu_item_id, quantity, unit_price) VALUES (905, 1, 1, 1, 7.00);
-- OK: a dine-in order with a table and a server of the same restaurant
INSERT INTO DineInOrder (order_id, table_id, server_id, party_size) VALUES (905, 901, 2, 2);
-- OK: delete one line of order 1 (the order and ticket 1 still have another line)
DELETE FROM OrderItem WHERE order_id = 1 AND line_no = 2;
-- OK: delete a campaign item when the campaign still has another one
INSERT INTO CampaignItem (campaign_id, menu_item_id) VALUES (905, 1);
DELETE FROM CampaignItem WHERE campaign_id = 905 AND menu_item_id = 901;

-- Check: trigger tests (expected: 1 1 1 1 3 3)
SELECT
    (SELECT COUNT(*) FROM OrderItem WHERE order_id = 905)       AS o905_items,
    (SELECT COUNT(*) FROM OrderItem WHERE order_id = 1)         AS o1_items,
    (SELECT COUNT(*) FROM DineInOrder WHERE order_id = 905)     AS o905_dinein,
    (SELECT COUNT(*) FROM CampaignItem WHERE campaign_id = 905) AS c905_items,
    (SELECT table_id FROM DineInOrder WHERE order_id = 1)       AS o1_table,
    (SELECT COUNT(*) FROM OrderItem WHERE order_id = 3)         AS o3_items;

-- Remove all test rows, so only the sample data is left
ROLLBACK;