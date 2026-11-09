-- =====================================================================
-- CSC 370 Group 47 - Restaurant Management Database (Sprint 2)
-- null_check.sql: Sprint 1, G3 
-- =====================================================================

USE restaurant_ops;

-- Old design: Staff and CustomerOrder were one table each,
-- so these rows would have had NULL in the attributes below

-- N1: staff who are not hourly (hourly_rate would be NULL)
SELECT COUNT(*) AS no_hourly_rate
FROM Staff
WHERE staff_id NOT IN (SELECT staff_id FROM HourlyStaff);

-- N2: staff who are not salaried (monthly_salary would be NULL)
SELECT COUNT(*) AS no_monthly_salary
FROM Staff
WHERE staff_id NOT IN (SELECT staff_id FROM SalariedStaff);

-- N3: orders that are not dine-in (table_id and party_size would be NULL)
SELECT COUNT(*) AS not_dine_in
FROM CustomerOrder
WHERE order_id NOT IN (SELECT order_id FROM DineInOrder);

-- N4: orders that are not deliveries (delivery_address and courier would be NULL)
SELECT COUNT(*) AS not_delivery
FROM CustomerOrder
WHERE order_id NOT IN (SELECT order_id FROM DeliveryOrder);

-- New design: the same attributes are in the subclass tables, so they are never NULL

-- N5: NULLs in HourlyStaff
SELECT COUNT(*) AS null_pay
FROM HourlyStaff
WHERE hourly_rate IS NULL;

-- N6: NULLs in SalariedStaff
SELECT COUNT(*) AS null_salary
FROM SalariedStaff
WHERE monthly_salary IS NULL;

-- N7: NULLs in DineInOrder
SELECT COUNT(*) AS null_dine_in
FROM DineInOrder
WHERE table_id IS NULL OR party_size IS NULL;

-- N8: NULLs in DeliveryOrder
SELECT COUNT(*) AS null_delivery
FROM DeliveryOrder
WHERE delivery_address IS NULL OR courier IS NULL;