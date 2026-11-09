-- =====================================================================
-- CSC 370 Group 47 - Restaurant Management Database (Sprint 2)
-- foh_query.sql: Front of House queries 
-- =====================================================================

USE restaurant_ops;

-- Q29: A restaurant's tables grouped by section, with the number of tables and seats
-- RA: γ[section, COUNT(table_id) → tables, SUM(seats) → seats](σ[restaurant_id = 1](DiningTable))
SELECT section, COUNT(table_id) AS tables, SUM(seats) AS seats
FROM DiningTable
WHERE restaurant_id = 1
GROUP BY section
ORDER BY section;

-- Q30: Tables that are free at 2026-11-08 19:00 (no booking within 2 hours) and have enough seats for 4
-- RA: B ← π[table_id](σ[status ∈ {'BOOKED', 'SEATED'} ∧ reserved_for > '2026-11-08 17:00' ∧ reserved_for < '2026-11-08 21:00'](Reservation)); π[table_id, label, seats, section](σ[restaurant_id = 1 ∧ seats ≥ 4](DiningTable) ⋈ (π[table_id](DiningTable) ∖ B))
SELECT t.table_id, t.label, t.seats, t.section
FROM DiningTable AS t
WHERE t.restaurant_id = 1 AND t.seats >= 4
  AND t.table_id NOT IN (
      SELECT r.table_id
      FROM Reservation AS r
      WHERE r.status IN ('BOOKED', 'SEATED')
        AND r.reserved_for > '2026-11-08 19:00:00' - INTERVAL 2 HOUR
        AND r.reserved_for < '2026-11-08 19:00:00' + INTERVAL 2 HOUR
  )
ORDER BY t.seats, t.label;

-- Q31: Orders still not fulfilled more than 30 minutes after they were created
-- RA: π[order_id, channel, status, created_at](σ[restaurant_id = 1 ∧ status ∉ {'FULFILLED', 'CANCELLED'} ∧ created_at < '2026-11-08 12:30' − 30 min](CustomerOrder))
SELECT order_id, channel, status, created_at
FROM CustomerOrder
WHERE restaurant_id = 1
  AND status NOT IN ('FULFILLED', 'CANCELLED')
  AND created_at < '2026-11-08 12:30:00' - INTERVAL 30 MINUTE;

-- Q32: Orders and revenue for each channel on each day of last week
-- RA: γ[DATE(created_at) → day, channel, COUNT(DISTINCT order_id) → orders, SUM(quantity × unit_price) → revenue](σ[restaurant_id = 1 ∧ created_at ≥ '2026-11-01' ∧ created_at < '2026-11-08'](CustomerOrder) ⋈ OrderItem)
SELECT DATE(o.created_at) AS day, o.channel,
       COUNT(DISTINCT o.order_id) AS orders, SUM(oi.quantity * oi.unit_price) AS revenue
FROM CustomerOrder AS o
JOIN OrderItem AS oi ON (o.order_id = oi.order_id)
WHERE o.restaurant_id = 1
  AND o.created_at >= '2026-11-01' AND o.created_at < '2026-11-08'
GROUP BY DATE(o.created_at), o.channel
ORDER BY day, o.channel;

-- Q33: Average tip for each payment type
-- RA: γ[payment_type, COUNT(order_id) → orders, AVG(tip) → avg_tip](σ[restaurant_id = 1 ∧ status = 'FULFILLED'](CustomerOrder))
SELECT payment_type, COUNT(order_id) AS orders, ROUND(AVG(tip), 2) AS avg_tip
FROM CustomerOrder
WHERE restaurant_id = 1 AND status = 'FULFILLED'
GROUP BY payment_type
ORDER BY avg_tip DESC;

-- Q34: Average preparation time (start to finish, in minutes) for each order channel
-- RA: γ[channel, COUNT(order_id) → orders, AVG(finished_at − started_at) → avg_prep_minutes](σ[restaurant_id = 1 ∧ finished_at IS NOT NULL](CustomerOrder))
SELECT channel, COUNT(order_id) AS orders,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, started_at, finished_at)), 1) AS avg_prep_minutes
FROM CustomerOrder
WHERE restaurant_id = 1 AND finished_at IS NOT NULL
GROUP BY channel
ORDER BY channel;

-- Q35: Order history of a returning customer, found by phone number, newest first
-- RA: C ← π[customer_id](σ[phone = '250-555-3001'](Customer)); τ[created_at ↓](π[order_id, restaurant_id, channel, status, created_at](CustomerOrder ⋈ C))
SELECT o.order_id, o.restaurant_id, o.channel, o.status, o.created_at
FROM CustomerOrder AS o
WHERE o.customer_id = (
    SELECT customer_id
    FROM Customer
    WHERE phone = '250-555-3001'
)
ORDER BY o.created_at DESC;

-- Q36: Customers whose name contains a given text ("Lee")
-- RA: π[customer_id, name, phone](σ[name LIKE '%Lee%'](Customer))
SELECT customer_id, name, phone
FROM Customer
WHERE name LIKE '%Lee%';

-- Q37: The 10 customers who spent the most in total in a specified time (last month)
-- RA: τ[total_spent ↓](γ[customer_id, name, SUM(quantity × unit_price) → total_spent](Customer ⋈ σ[created_at ≥ '2026-10-01' ∧ created_at < '2026-11-01'](CustomerOrder) ⋈ OrderItem)), first 10 rows
SELECT c.customer_id, c.name, SUM(oi.quantity * oi.unit_price) AS total_spent
FROM Customer AS c
JOIN CustomerOrder AS o ON (c.customer_id = o.customer_id)
JOIN OrderItem AS oi ON (o.order_id = oi.order_id)
WHERE o.created_at >= '2026-10-01' AND o.created_at < '2026-11-01'
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC, c.name
LIMIT 10;

-- Q38: Customers who did not show up for 2 or more reservations
-- RA: σ[no_shows ≥ 2](γ[customer_id, name, COUNT(reservation_id) → no_shows](σ[status = 'NO_SHOW'](Reservation) ⋈ Customer))
SELECT c.customer_id, c.name, COUNT(r.reservation_id) AS no_shows
FROM Reservation AS r
JOIN Customer AS c ON (r.customer_id = c.customer_id)
WHERE r.status = 'NO_SHOW'
GROUP BY c.customer_id, c.name
HAVING COUNT(r.reservation_id) >= 2;

-- Q39: Customers who have ordered every item in a category (all the desserts, category 3)
-- RA: P ← π[customer_id, menu_item_id](σ[customer_id IS NOT NULL](CustomerOrder) ⋈ OrderItem); D ← π[menu_item_id](σ[category_id = 3](MenuItem)); π[customer_id, name]((P ÷ D) ⋈ Customer)
SELECT c.customer_id, c.name
FROM Customer AS c
WHERE NOT EXISTS (
    SELECT *
    FROM MenuItem AS m
    WHERE m.category_id = 3
      AND NOT EXISTS (
          SELECT *
          FROM CustomerOrder AS o
          JOIN OrderItem AS oi ON (o.order_id = oi.order_id)
          WHERE o.customer_id = c.customer_id
            AND oi.menu_item_id = m.menu_item_id
      )
);

-- Q40: Number of orders of each type: dine-in, delivery, and pickup (in neither subclass)
-- RA: O ← σ[restaurant_id = 1](CustomerOrder); π['DINE_IN' → order_type, orders](γ[COUNT(order_id) → orders](O ⋈ DineInOrder)) ∪ π['DELIVERY' → order_type, orders](γ[COUNT(order_id) → orders](O ⋈ DeliveryOrder)) ∪ π['PICKUP' → order_type, orders](γ[COUNT(order_id) → orders]((π[order_id](O) ∖ π[order_id](DineInOrder) ∖ π[order_id](DeliveryOrder))))
SELECT 'DINE_IN' AS order_type, COUNT(*) AS orders
FROM CustomerOrder AS o
JOIN DineInOrder AS di ON (o.order_id = di.order_id)
WHERE o.restaurant_id = 1
UNION
SELECT 'DELIVERY' AS order_type, COUNT(*) AS orders
FROM CustomerOrder AS o
JOIN DeliveryOrder AS d ON (o.order_id = d.order_id)
WHERE o.restaurant_id = 1
UNION
SELECT 'PICKUP' AS order_type, COUNT(*) AS orders
FROM CustomerOrder AS o
WHERE o.restaurant_id = 1
  AND NOT EXISTS (SELECT * FROM DineInOrder AS di WHERE di.order_id = o.order_id)
  AND NOT EXISTS (SELECT * FROM DeliveryOrder AS d WHERE d.order_id = o.order_id);

-- Q41: Servers ranked by the average rating of the dine-in orders they served (at least 5 reviews)
-- RA: τ[avg_rating ↓](σ[reviews ≥ 5](γ[staff_id, name, COUNT(review_id) → reviews, AVG(rating) → avg_rating](Review ⋈ DineInOrder ⋈[server_id = staff_id] Staff)))
SELECT s.staff_id, s.name, COUNT(r.review_id) AS reviews, ROUND(AVG(r.rating), 2) AS avg_rating
FROM Review AS r
JOIN DineInOrder AS di ON (r.order_id = di.order_id)
JOIN Staff AS s ON (di.server_id = s.staff_id)
GROUP BY s.staff_id, s.name
HAVING COUNT(r.review_id) >= 5
ORDER BY avg_rating DESC;