-- =====================================================================
-- CSC 370 Group 47 - Restaurant Management Database (Sprint 2)
-- menu_query.sql: Menu and Inventory queries 
-- =====================================================================

USE restaurant_ops;

-- Q18: Current stock of every ingredient, including ingredients with no stock movements
-- RA: γ[inventory_item_id, name, unit, COALESCE(SUM(quantity_delta), 0) → current_stock](σ[restaurant_id = 2](InventoryItem) ⟕ StockMovement)
SELECT i.inventory_item_id, i.name, i.unit, COALESCE(SUM(s.quantity_delta), 0) AS current_stock
FROM InventoryItem AS i
LEFT JOIN StockMovement AS s ON (i.inventory_item_id = s.inventory_item_id)
WHERE i.restaurant_id = 2
GROUP BY i.inventory_item_id, i.name, i.unit
ORDER BY i.inventory_item_id;

-- Q19: Ingredients whose current stock is below their par level
-- RA: σ[current_stock < par_level](γ[inventory_item_id, name, par_level, SUM(quantity_delta) → current_stock](σ[restaurant_id = 1](InventoryItem) ⋈ StockMovement))
SELECT i.inventory_item_id, i.name, i.par_level, SUM(s.quantity_delta) AS current_stock
FROM InventoryItem AS i
JOIN StockMovement AS s ON (i.inventory_item_id = s.inventory_item_id)
WHERE i.restaurant_id = 1
GROUP BY i.inventory_item_id, i.name, i.par_level
HAVING SUM(s.quantity_delta) < i.par_level
ORDER BY i.name;

-- Q20: Total cost of wasted stock for each ingredient last month, highest first
-- RA: τ[waste_cost ↓](γ[name, SUM(−quantity_delta × unit_cost) → waste_cost](σ[restaurant_id = 1 ∧ movement_type = 'WASTE' ∧ occurred_at ≥ '2026-10-01' ∧ occurred_at < '2026-11-01'](StockMovement ⋈ InventoryItem)))
SELECT i.name, ROUND(SUM(-s.quantity_delta * s.unit_cost), 2) AS waste_cost
FROM StockMovement AS s
JOIN InventoryItem AS i ON (s.inventory_item_id = i.inventory_item_id)
WHERE i.restaurant_id = 1 AND s.movement_type = 'WASTE'
  AND s.occurred_at >= '2026-10-01' AND s.occurred_at < '2026-11-01'
GROUP BY i.name
ORDER BY waste_cost DESC;

-- Q21: Menu items that do not have a recipe yet
-- RA: π[menu_item_id, name]((π[menu_item_id](MenuItem) ∖ π[menu_item_id](RecipeLine)) ⋈ MenuItem)
SELECT m.menu_item_id, m.name
FROM MenuItem AS m
WHERE m.menu_item_id NOT IN (SELECT menu_item_id FROM RecipeLine);

-- Q22: Menu items that are hidden from customers
-- RA: π[category, name, price](σ[restaurant_id = 1 ∧ is_available = FALSE](MenuCategory ⋈ MenuItem))
SELECT c.name AS category, m.name, m.price
FROM MenuItem AS m
JOIN MenuCategory AS c ON (m.category_id = c.category_id)
WHERE c.restaurant_id = 1 AND m.is_available = FALSE;

-- Q23: Supplier deliveries of the last 7 days with the total cost of each one
-- RA: τ[occurred_at](π[occurred_at, name, quantity_delta, unit_cost, quantity_delta × unit_cost → total_cost](σ[restaurant_id = 1 ∧ movement_type = 'RECEIVE' ∧ occurred_at ≥ '2026-11-01' ∧ occurred_at < '2026-11-08'](StockMovement ⋈ InventoryItem)))
SELECT s.occurred_at, i.name, s.quantity_delta, s.unit_cost,
       ROUND(s.quantity_delta * s.unit_cost, 2) AS total_cost
FROM StockMovement AS s
JOIN InventoryItem AS i ON (s.inventory_item_id = i.inventory_item_id)
WHERE i.restaurant_id = 1 AND s.movement_type = 'RECEIVE'
  AND s.occurred_at >= '2026-11-01' AND s.occurred_at < '2026-11-08'
ORDER BY s.occurred_at;

-- Q24: Profit margin of each dish (price minus ingredient cost), lowest margin first
-- RA: C ← γ[menu_item_id, SUM(qty_per_serving × avg_cost) → ingredient_cost](RecipeLine ⋈ γ[inventory_item_id, AVG(unit_cost) → avg_cost](σ[movement_type = 'RECEIVE'](StockMovement))); τ[margin](π[name, price, ingredient_cost, price − ingredient_cost → margin](σ[restaurant_id = 1](MenuCategory ⋈ MenuItem ⋈ C)))
SELECT m.name, m.price, ROUND(cost.ingredient_cost, 2) AS ingredient_cost,
       ROUND(m.price - cost.ingredient_cost, 2) AS margin
FROM MenuItem AS m
JOIN MenuCategory AS c ON (m.category_id = c.category_id)
JOIN (SELECT r.menu_item_id, SUM(r.qty_per_serving * a.avg_cost) AS ingredient_cost
      FROM RecipeLine AS r
      JOIN (SELECT inventory_item_id, AVG(unit_cost) AS avg_cost
            FROM StockMovement
            WHERE movement_type = 'RECEIVE'
            GROUP BY inventory_item_id) AS a ON (r.inventory_item_id = a.inventory_item_id)
      GROUP BY r.menu_item_id) AS cost ON (m.menu_item_id = cost.menu_item_id)
WHERE c.restaurant_id = 1
ORDER BY margin;

-- Q25: The 5 best-selling menu items of the last 30 days by quantity sold
-- RA: τ[total_sold ↓](γ[menu_item_id, name, SUM(quantity) → total_sold](σ[restaurant_id = 1 ∧ created_at ≥ '2026-10-09' ∧ created_at < '2026-11-08'](CustomerOrder) ⋈ OrderItem ⋈ MenuItem)), first 5 rows
SELECT m.menu_item_id, m.name, SUM(oi.quantity) AS total_sold
FROM OrderItem AS oi
JOIN CustomerOrder AS o ON (oi.order_id = o.order_id)
JOIN MenuItem AS m ON (oi.menu_item_id = m.menu_item_id)
WHERE o.restaurant_id = 1
  AND o.created_at >= '2026-10-09' AND o.created_at < '2026-11-08'
GROUP BY m.menu_item_id, m.name
ORDER BY total_sold DESC, m.name
LIMIT 5;

-- Q26: Menu items that nobody ordered in the last 30 days
-- RA: π[menu_item_id, name](σ[restaurant_id = 1](MenuCategory ⋈ MenuItem)) ∖ π[menu_item_id, name](MenuItem ⋈ OrderItem ⋈ σ[created_at ≥ '2026-10-09' ∧ created_at < '2026-11-08'](CustomerOrder))
SELECT m.menu_item_id, m.name
FROM MenuItem AS m
JOIN MenuCategory AS c ON (m.category_id = c.category_id)
WHERE c.restaurant_id = 1
  AND NOT EXISTS (
      SELECT *
      FROM OrderItem AS oi
      JOIN CustomerOrder AS o ON (oi.order_id = o.order_id)
      WHERE oi.menu_item_id = m.menu_item_id
        AND o.created_at >= '2026-10-09' AND o.created_at < '2026-11-08'
  );

-- Q27: The best-selling menu item in each category
-- RA: T ← γ[category_id, menu_item_id, name, SUM(quantity) → total_sold](MenuItem ⋈ OrderItem); π[category_id, name, total_sold](T ⋈ γ[category_id, MAX(total_sold) → total_sold](T))
SELECT c.name AS category, m.name, SUM(oi.quantity) AS total_sold
FROM MenuItem AS m
JOIN MenuCategory AS c ON (m.category_id = c.category_id)
JOIN OrderItem AS oi ON (m.menu_item_id = oi.menu_item_id)
GROUP BY c.category_id, c.name, m.menu_item_id, m.name
HAVING SUM(oi.quantity) >= ALL (
    SELECT SUM(oi2.quantity)
    FROM MenuItem AS m2
    JOIN OrderItem AS oi2 ON (m2.menu_item_id = oi2.menu_item_id)
    WHERE m2.category_id = c.category_id
    GROUP BY m2.menu_item_id
)
ORDER BY c.category_id;

-- Q28: Order lines sold at a different price than the item's current price
-- RA: π[order_id, line_no, menu_item_id, unit_price](OrderItem ⋈ (π[menu_item_id, unit_price](OrderItem) ∖ ρ[menu_item_id, unit_price](π[menu_item_id, price](MenuItem))))
SELECT oi.order_id, oi.line_no, oi.menu_item_id, oi.unit_price
FROM OrderItem AS oi
WHERE (oi.menu_item_id, oi.unit_price) NOT IN (
    SELECT menu_item_id, price
    FROM MenuItem
);