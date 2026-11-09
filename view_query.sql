-- =====================================================================
-- CSC 370 Group 47 - Restaurant Management Database (Sprint 2)
-- view_query.sql: reading the four dashboard views (S2-G5)
-- =====================================================================

USE restaurant_ops;

-- V1: Owner dashboard, last week at Harbour Grill 
SELECT day, channel, orders, revenue
FROM OwnerSales
WHERE restaurant_id = 1 AND day >= '2026-11-01' AND day < '2026-11-08'
ORDER BY day, channel;

-- V2: Employee dashboard, Ben's shifts for the coming week 
SELECT shift_id, start_at, end_at, notes
FROM EmployeeSchedule
WHERE staff_id = 2 AND start_at >= '2026-11-09' AND start_at < '2026-11-16'
ORDER BY start_at;

-- V3: Order-system dashboard, open orders older than 30 minutes
SELECT order_id, channel, status, created_at
FROM OpenOrders
WHERE restaurant_id = 1 AND created_at < '2026-11-08 12:30:00' - INTERVAL 30 MINUTE;

-- V4: Kitchen Display, ingredients below their par level
SELECT inventory_item_id, name, par_level, current_stock
FROM KitchenStock
WHERE restaurant_id = 1 AND current_stock < par_level
ORDER BY name;