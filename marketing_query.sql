-- =====================================================================
-- CSC 370 Group 47 - Restaurant Management Database (Sprint 2)
-- marketing_query.sql: Marketing and Analytics queries 
-- =====================================================================

USE restaurant_ops;

-- Q42: Campaigns running today with the menu items each one promotes
-- RA: π[campaign, start_date, end_date, item](σ[restaurant_id = 1 ∧ start_date ≤ '2026-11-08' ∧ (end_date IS NULL ∨ end_date ≥ '2026-11-08')](Campaign) ⋈ CampaignItem ⋈ MenuItem)
SELECT c.name AS campaign, c.start_date, c.end_date, m.name AS item
FROM Campaign AS c
JOIN CampaignItem AS ci ON (c.campaign_id = ci.campaign_id)
JOIN MenuItem AS m ON (ci.menu_item_id = m.menu_item_id)
WHERE c.restaurant_id = 1
  AND c.start_date <= '2026-11-08'
  AND (c.end_date IS NULL OR c.end_date >= '2026-11-08')
ORDER BY c.name, m.name;

-- Q43: Revenue of each promoted menu item during its campaign's dates
-- RA: γ[campaign, item, SUM(quantity × unit_price) → revenue](σ[DATE(created_at) ≥ start_date ∧ (end_date IS NULL ∨ DATE(created_at) ≤ end_date)](Campaign ⋈ CampaignItem ⋈ MenuItem ⋈ OrderItem ⋈ CustomerOrder))
SELECT c.name AS campaign, m.name AS item, SUM(oi.quantity * oi.unit_price) AS revenue
FROM Campaign AS c
JOIN CampaignItem AS ci ON (c.campaign_id = ci.campaign_id)
JOIN MenuItem AS m ON (ci.menu_item_id = m.menu_item_id)
JOIN OrderItem AS oi ON (ci.menu_item_id = oi.menu_item_id)
JOIN CustomerOrder AS o ON (oi.order_id = o.order_id)
WHERE DATE(o.created_at) >= c.start_date
  AND (c.end_date IS NULL OR DATE(o.created_at) <= c.end_date)
GROUP BY c.campaign_id, c.name, m.menu_item_id, m.name
ORDER BY c.campaign_id, revenue DESC;

-- Q44: Menu items that were never promoted in any campaign
-- RA: π[menu_item_id, name]((π[menu_item_id](MenuItem) ∖ π[menu_item_id](CampaignItem)) ⋈ MenuItem)
SELECT m.menu_item_id, m.name
FROM MenuItem AS m
WHERE m.menu_item_id NOT IN (SELECT menu_item_id FROM CampaignItem)
ORDER BY m.menu_item_id;

-- Q45: Active announcements for a restaurant, newest first (the restaurant comes from the author)
-- RA: τ[created_at ↓](π[announcement_id, announcement_type, message, author, created_at](σ[restaurant_id = 1 ∧ is_active = TRUE](Announcement ⋈[author_id = staff_id] Staff)))
SELECT a.announcement_id, a.announcement_type, a.message, s.name AS author, a.created_at
FROM Announcement AS a
JOIN Staff AS s ON (a.author_id = s.staff_id)
WHERE s.restaurant_id = 1 AND a.is_active = TRUE
ORDER BY a.created_at DESC;

-- Q46: Average daily revenue for each weather condition
-- RA: D ← γ[restaurant_id, DATE(created_at) → day, SUM(quantity × unit_price) → revenue](σ[restaurant_id = 1](CustomerOrder) ⋈ OrderItem); γ[condition, COUNT(day) → days, AVG(revenue) → avg_daily_revenue](WeatherObservation ⋈[restaurant_id = D.restaurant_id ∧ observed_date = D.day] D)
SELECT w.`condition`, COUNT(d.day) AS days, ROUND(AVG(d.revenue), 2) AS avg_daily_revenue
FROM WeatherObservation AS w
JOIN (SELECT o.restaurant_id, DATE(o.created_at) AS day, SUM(oi.quantity * oi.unit_price) AS revenue
      FROM CustomerOrder AS o
      JOIN OrderItem AS oi ON (o.order_id = oi.order_id)
      WHERE o.restaurant_id = 1
      GROUP BY o.restaurant_id, DATE(o.created_at)) AS d
     ON (w.restaurant_id = d.restaurant_id AND w.observed_date = d.day)
GROUP BY w.`condition`
ORDER BY avg_daily_revenue DESC;

-- Q47: For each weather condition, the share of orders that were deliveries
-- RA: γ[condition, COUNT(order_id) → orders, COUNT(d.order_id) → deliveries, COUNT(d.order_id) / COUNT(order_id) → delivery_share](WeatherObservation ⋈[restaurant_id = o.restaurant_id ∧ observed_date = DATE(created_at)] ρ[o](σ[restaurant_id = 1](CustomerOrder)) ⟕ ρ[d](DeliveryOrder))
SELECT w.`condition`, COUNT(o.order_id) AS orders, COUNT(d.order_id) AS deliveries,
       ROUND(COUNT(d.order_id) / COUNT(o.order_id), 2) AS delivery_share
FROM WeatherObservation AS w
JOIN CustomerOrder AS o ON (w.restaurant_id = o.restaurant_id AND w.observed_date = DATE(o.created_at))
LEFT JOIN DeliveryOrder AS d ON (o.order_id = d.order_id)
WHERE w.restaurant_id = 1
GROUP BY w.`condition`
ORDER BY delivery_share DESC;

-- Q48: The 3 busiest hours of the day over the last 30 days
-- RA: τ[orders ↓](γ[HOUR(created_at) → hour, COUNT(order_id) → orders](σ[restaurant_id = 1 ∧ created_at ≥ '2026-10-09' ∧ created_at < '2026-11-08'](CustomerOrder))), first 3 rows
SELECT HOUR(created_at) AS hour, COUNT(order_id) AS orders
FROM CustomerOrder
WHERE restaurant_id = 1
  AND created_at >= '2026-10-09' AND created_at < '2026-11-08'
GROUP BY HOUR(created_at)
ORDER BY orders DESC, hour
LIMIT 3;

-- Q49: For each hour with orders on a day (2026-11-02), the number of staff on shift vs. the number of orders
-- RA: O ← γ[HOUR(created_at) → hour, COUNT(order_id) → orders](σ[restaurant_id = 1 ∧ DATE(created_at) = '2026-11-02'](CustomerOrder)); S ← π[shift_id, start_at, end_at](σ[restaurant_id = 1 ∧ DATE(start_at) = '2026-11-02'](Shift ⋈ Staff)); γ[hour, orders, COUNT(shift_id) → staff_on_shift](O ⟕[HOUR(start_at) ≤ hour ∧ hour < HOUR(end_at)] S)
SELECT o.hour, o.orders, COUNT(sh.shift_id) AS staff_on_shift
FROM (SELECT HOUR(created_at) AS hour, COUNT(order_id) AS orders
      FROM CustomerOrder
      WHERE restaurant_id = 1 AND DATE(created_at) = '2026-11-02'
      GROUP BY HOUR(created_at)) AS o
LEFT JOIN (SELECT sh.shift_id, sh.start_at, sh.end_at
           FROM Shift AS sh
           JOIN Staff AS s ON (sh.staff_id = s.staff_id)
           WHERE s.restaurant_id = 1 AND DATE(sh.start_at) = '2026-11-02') AS sh
       ON (HOUR(sh.start_at) <= o.hour AND o.hour < HOUR(sh.end_at))
GROUP BY o.hour, o.orders
ORDER BY o.hour;

-- Q50: Recommendations for a restaurant that have not expired yet, newest first
-- RA: τ[created_at ↓](π[insight_id, insight_type, title, created_at, expires_at](σ[restaurant_id = 1 ∧ (expires_at > '2026-11-08 12:00' ∨ expires_at IS NULL)](Insight)))
SELECT insight_id, insight_type, title, created_at, expires_at
FROM Insight
WHERE restaurant_id = 1
  AND (expires_at > '2026-11-08 12:00:00' OR expires_at IS NULL)
ORDER BY created_at DESC;

-- Q51: Every restaurant with last month's revenue, number of orders, and average review rating
-- RA: M ← σ[created_at ≥ '2026-10-01' ∧ created_at < '2026-11-01'](CustomerOrder); R ← γ[restaurant_id, SUM(quantity × unit_price) → revenue](M ⋈ OrderItem); N ← γ[restaurant_id, COUNT(order_id) → orders](M); A ← γ[restaurant_id, AVG(rating) → avg_rating](M ⋈ Review); π[name, revenue, orders, avg_rating](Restaurant ⟕ R ⟕ N ⟕ A)
SELECT r.name, rev.revenue, n.orders, a.avg_rating
FROM Restaurant AS r
LEFT JOIN (SELECT o.restaurant_id, SUM(oi.quantity * oi.unit_price) AS revenue
           FROM CustomerOrder AS o
           JOIN OrderItem AS oi ON (o.order_id = oi.order_id)
           WHERE o.created_at >= '2026-10-01' AND o.created_at < '2026-11-01'
           GROUP BY o.restaurant_id) AS rev ON (r.restaurant_id = rev.restaurant_id)
LEFT JOIN (SELECT restaurant_id, COUNT(order_id) AS orders
           FROM CustomerOrder
           WHERE created_at >= '2026-10-01' AND created_at < '2026-11-01'
           GROUP BY restaurant_id) AS n ON (r.restaurant_id = n.restaurant_id)
LEFT JOIN (SELECT o.restaurant_id, ROUND(AVG(rv.rating), 2) AS avg_rating
           FROM CustomerOrder AS o
           JOIN Review AS rv ON (o.order_id = rv.order_id)
           WHERE o.created_at >= '2026-10-01' AND o.created_at < '2026-11-01'
           GROUP BY o.restaurant_id) AS a ON (r.restaurant_id = a.restaurant_id)
ORDER BY r.restaurant_id;