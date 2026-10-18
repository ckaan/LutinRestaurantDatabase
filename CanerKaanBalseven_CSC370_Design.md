<!-- ===================== COVER PAGE ===================== -->

<p align="center">
  <br><br>
  <b>CSC 370: Database Systems</b><br>
  University of Victoria · Fall 2026
  <br><br><br>
</p>

<h1 align="center">Restaurant Management Database</h1>
<h3 align="center">Design Document: Sprint 1 (Advanced Relational Design)</h3>

<p align="center">
  <br><br>
  <b>Group 47</b><br>
  Caner Kaan Balseven V01074078<br>
  <br><br>
  <b>TA-Client:</b> Nikhil Partap Singh Dhillon <br>
  <b>Instructor:</b> Sean Chester
  <br><br>
  <b>Current version:</b> 2.0 · Sprint 1 · October 20, 2026
  <br><br>
</p>

### Version History

| Version | Sprint | Date | Commit | Summary |
|---|---|---|---|---|
| 1.0 | Project Kickoff | October 4, 2026 | [3e80d50](https://github.com/ckaan/LutinRestaurantDatabase/tree/3e80d5078ac2d8ac66e3346d299b412badb4e019) | Requirements, first ERD (16 entity sets, 21 relationships), relational schema (18 relations), keys, FDs, BCNF decompositions D1–D2, `schema.sql` |
| 2.0 | Sprint 1 | October 18, 2026 | see Brightspace submission |  |
| 3.0 | Sprint 2 | November 8, 2026 | | |
| 4.0 | Final Submission | November 29, 2026 | | |

<div style="page-break-after: always;"></div>

---

## Table of Contents

- [1. Project Background]
- [2. Kickoff Sprint Goals]
- [3. Requirements]
- [4. Entity-Relationship Diagram]
  - [4.1 Staff]
  - [4.2 Menu and Inventory]
  - [4.3 Front of House]
- [5. Relational Schema]
- [6. Keys]
- [7. Functional Dependencies and BCNF]
  - [7.1 Functional Dependencies]
  - [7.2 Anomalies in the Original Schema]
  - [7.3 BCNF Decompositions]
  - [7.4 BCNF Verification]
- [8. Implementation]
- [9. Known Limitations]
- [10. Next Sprint Goals]
- [11. Use of Generative AI and Prior Work]
- [12. References]

---

---

## 1. Project Background

During an entrepreneurship co-op term, I built a restaurant management platform. It has 4 dashboard (Owner, Employee, Order-system, Kitchen Display). It ran on PostgreSQL through Prisma ORM, and its schema grew organically while we built features quickly. As a result, the original schema has several design problems: attributes copied between tables, derived values stored as data, JSON blobs instead of relations, missing foreign keys, and money stored as floating-point numbers. The main idea of the project is having meaningful data points which will be used to calculate some statistical or meaningful data/result to improve small and mid size restaurants by inserting recommendations to manager/owner. However, applying those recommendations are up to the owner/manager. 

This project redesigns that database properly, the way it should be done in industry, using the methods of CSC 370:

1. Write the requirements.
2. Build a conceptual schema as an ERD with identifiers and multiplicities.
3. Map the ERD to a relational schema.
4. Identify the functional dependencies and keys.
5. Normalize to BCNF.
6. Implement the result in MySQL with hand-written DDL.

The original application has about 35 Prisma models. This sprint covers the operational core of the system; the remaining subsystems are planned for later sprints (see Section 10).

## 2. Sprint 1 Goals

**Sprint 1: Advanced Relational Design.** Course-level targets: **Data Modelling, Level 3** (design), **Data Modelling, Level 1** (SQL implementation), and **Back-end Engineering, Level 1** (consistency).

These goals were planned at the end of the Kickoff (version 1.0, Section 10). In addition, `schema.sql` in the Kickoff translated the redesigned tables into SQL, starting from the tables of my co-op project. The Kickoff focused on the design (ERD, keys, FDs, BCNF), so constraints such as NOT NULL were not covered yet; they are part of this sprint (G8).

### 2.1 Goals and Success Criteria

| Goal | Limitation it fixes | Competency | Success criterion (measurable) | Status | Evidence |
|---|---|---|---|---|---|
| **G1.** Complete the ERD: add the out-of-scope part and the data needed by the recommendation (machine learning) features that already exist in the backend | These parts were not in the ERD and the database was never adjusted for the machine learning features | DM L2: maps requirements onto schemata; DM L4: designs for extensibility | Every out-of-scope part in Section 3.4 has requirements in Section 3 and appears in the ERD; every new relation passes the BCNF check | *[Met / Partially met / Not met]* | *[Section]* |
| **G2.** Double-check the whole ERD and add (min, max) participation to every relationship | The ERD was not final and relationships only showed arrowheads | DM L2: minimal and complete design; DM L3: systematically evaluates a schema | 100% of relationships have (min, max) labels; a requirement ↔ ERD checklist with 0 unmatched items | | |
| **G3.** Apply Level 3 design techniques: inheritance for CustomerOrder (dine-in, pickup, delivery) and Staff (hourly, salaried); weak entity sets for Role and OrderItem | Attributes that are NULL by design (Section 9, item 2) | DM L3: uses inheritance and weak entity sets; considers the impact of NULL values on FDs | Attributes that must be NULL for some rows go from **6** (4 delivery columns + 2 pay columns) to **0**; Role and OrderItem drawn as weak entity sets | | Role done (Sections 5–7) |
| **G4.** Complete the normalisation: keys, FDs, and BCNF check for the new relations, plus the remaining decompositions of the original schema | Only D1 and D2 were written up | DM L2: eliminates anomalies; DM L3: applies alternative normal forms | All five decompositions (D1–D5) written with closures; **100%** of relations in the BCNF verification table | | Section 7.2 (D1–D5 done) |
| **G5.** Write the SQL DDL for the new relations and revise the implementation | The DDL covered only 18 relations | DM L1: writes SQL that implements a relational design | `schema.sql` runs with **0** errors and creates every relation in Section 5 | | |
| **G6.** Fix the cross-restaurant limitation | Mixed-restaurant rows are accepted (Section 9, item 1) | DM L3: assesses incongruity between conceptual and relational schemata | Both options compared and one chosen; a test adding another restaurant's menu item to an order is **rejected** (or scheduled for Sprint 2 if a trigger is chosen) | | |
| **G7.** Fix the problems obtained via feedback | Feedback from the TA-client on the Kickoff | All of the above | Every feedback item is listed with its fix; 100% resolved or explained | | |
| **G8.** Improve the SQL implementation: add NOT NULL to required columns, add CHECK constraints for business rules, and review the data types | Required columns can be left empty (Section 9, item 4) | DM L1: writes SQL that implements a relational design, selects appropriate data types; BE L1: database never enters an inconsistent state | Every required column is NOT NULL; inserting a row with a missing required value is **rejected** | | |
| **G9.** Review and fix the Kickoff deliverables | Parts of the Kickoff work still needed to be confirmed | DM L2: justifies the quality of a schema through a theoretical lens; maps requirements onto schemata | A consistency check between the ERD, Section 5, and `schema.sql` with **0** mismatches; every question in Section 10.1 answered | | Sections 5–7 updated |

*DM = Data Modelling, BE = Back-end Engineering.*

**Note:** Sprint goals are subject to change; about 80% of them are aimed to be met in this sprint.

### 2.2 Missed or Partially Met Goals

*[Fill in at the end of Sprint 1*

| Goal | What is not finished | Technical reason | Effect on learning goals | Plan |
|---|---|---|---|---|
| | | | | |

### 2.3 Competency Mapping

| Competency bullet | Covered by |
|---|---|
| DM L1: Selects appropriate data types for tables | [Section 5](#5-relational-schema), G8 |
| DM L1: Writes SQL code that implements a relational design | [Section 8](#8-implementation), G5, G8 |
| DM L1: Documents relationships with correct ERDs | [Section 4](#4-entity-relationship-diagram), G2 |
| DM L2: Identifies dependencies among attributes and appropriate keys | [Section 6](#6-keys), [Section 7.1](#71-functional-dependencies) |
| DM L2: Eliminates data anomalies with effective normalisation | [Section 7.2](#72-bcnf-decompositions), G4 |
| DM L2: Justifies the quality of a schema through a theoretical lens | [Section 7.3](#73-bcnf-verification), G9 |
| DM L2: Maps requirements onto schemata and vice versa | [Section 3](#3-requirements), [Section 4](#4-entity-relationship-diagram), G1, G2 |
| DM L3: Uses inheritance and weak entity sets when they are more expressive | G3 |
| DM L3: Considers the impact of NULL values and inheritance on FDs | G3, [Section 7.2](#72-bcnf-decompositions) (D5) |
| DM L3: Assesses incongruity between conceptual and relational schemata | G6 |
| DM L3: Systematically evaluates strengths and weaknesses of a schema | G2, G9 |
| BE L1: Ensures a database never enters an inconsistent state | G8 |

### 2.4 Previous Sprint (Kickoff) Recap

The Kickoff (version 1.0) delivered the requirements, the first ERD, the relational schema, keys, FDs, two BCNF decompositions, and `schema.sql`. Two things were only partially met: (min, max) participation on the ERD (now G2) and the remaining decompositions (now G4). The full Kickoff version can be seen at the commit linked in the Version History.

---

## 3. Requirements

The requirements are grouped into the three parts of the system. For each part, the left column lists what the system must let people do, and the right column lists the data the database must store to support it. The ERD excerpt below each part shows the entity sets and relationships those data requirements produced.

### 3.1 Staff

<table>
<tr><th>Requirements / Features</th><th>Corresponding Data Requirements</th></tr>
<tr>
<td valign="top">
<ul>
<li>Several restaurants use the same system, each seeing only its own data</li>
<li>Managers create roles (Server, Line Cook, …) and assign each to a department</li>
<li>Managers add, edit, and deactivate staff</li>
<li>Show which department each staff member works in</li>
<li>Staff log in to the app; new accounts must reset their password</li>
<li>Managers schedule shifts</li>
<li>Staff view their own schedule</li>
<li>Staff offer a shift for a swap</li>
<li>A coworker volunteers to cover an offered shift</li>
<li>Managers approve or deny swaps</li>
</ul>
</td>
<td valign="top">
<ul>
<li>Restaurants with id's</li>
<li>Roles of each restaurant, with their department</li>
<li>Staff with id's, contact details, hire date, pay type, and pay rate</li>
<li>Login credentials for staff who use the app</li>
<li>Shifts: who works, start and end time</li>
<li>Swap requests: which shift, who covers, status</li>
</ul>
</td>
</tr>
</table>



### 3.2 Menu and Inventory

<table>
<tr><th>Requirements / Features</th><th>Corresponding Data Requirements</th></tr>
<tr>
<td valign="top">
<ul>
<li>Show the menu grouped by category, in a chosen order</li>
<li>Managers add, edit, and hide menu items and change prices</li>
<li>Define a recipe for each dish</li>
<li>Calculate the ingredient cost of a dish</li>
<li>Log supplier deliveries with their cost</li>
<li>Log waste and stock-count adjustments</li>
<li>Deduct ingredients when dishes are sold</li>
<li>Show the current stock of each ingredient</li>
<li>Warn when stock falls below the par level</li>
<li>Suggest when to reorder, using the supplier's lead time</li>
</ul>
</td>
<td valign="top">
<ul>
<li>Menu categories with display order</li>
<li>Menu items with price and availability</li>
<li>Inventory items with unit, par level, and lead time</li>
<li>Recipes: quantity of each ingredient per dish</li>
<li>Stock movements: type, amount, cost, reason, time</li>
</ul>
</td>
</tr>
</table>



### 3.3 Front of House

<table>
<tr><th>Requirements / Features</th><th>Corresponding Data Requirements</th></tr>
<tr>
<td valign="top">
<ul>
<li>Show the restaurant's tables by section</li>
<li>Customers reserve a table for a date and time</li>
<li>Prevent double-booking a table</li>
<li>Take orders in person, by phone, or online</li>
<li>Seat dine-in orders at a table and assign a server</li>
<li>Handle pickup and delivery orders, including Uber Eats</li>
<li>Add dishes to an order with notes ("no onions")</li>
<li>Track order status from pending to fulfilled</li>
<li>Record the payment type and tip</li>
<li>Calculate order totals</li>
<li>Measure how long orders take to prepare</li>
<li>Look up a returning customer's order history</li>
<li>Customers review an order</li>
</ul>
</td>
<td valign="top">
<ul>
<li>Dining tables with label, seats, and section</li>
<li>Customers with id's and a unique phone number</li>
<li>Reservations: who, which table, when, party size</li>
<li>Orders: restaurant, channel, fulfilment type, status, payment, tip, timestamps</li>
<li>Dine-in details: table, server, party size</li>
<li>Delivery details: address, notes, courier, external reference</li>
<li>Order lines: dish, quantity, price at time of sale, notes</li>
<li>Reviews: rating and comment, at most one per order</li>
</ul>
</td>
</tr>
</table>


### 3.4 Out of Scope

**Not covered this sprint:** payroll, attendance and time clock, time-off requests, kitchen display tickets, labour and operations analytics, marketing campaigns, announcements, weather logs, and AI insights.

NEXT SPRINT: ASK ABOUT SENSITIVE DATA TO TA 


---

## 4. Entity-Relationship Diagram

![Full ERD](figures/full_erd.jpg)

| Symbol | Meaning |
|---|---|
| Rectangle | Entity set |
| Ellipse | Attribute; an **underlined** attribute is the entity set's identifier |
| Diamond | Relationship; an ellipse attached to a diamond is a relationship attribute |
| Arrowhead into an entity set | "At most one" on that side of the relationship |
| No arrowhead | "Many" on that side |
| Arrowheads on both sides | One-one relationship |

Each relationship will also described with its (min, max) participation in the next sprint. 

The diagram has **16 entity sets** and **21 relationships**.
### 4.1 Staff

**Requirements covered:** [Section 3.1]

**Entity sets**

| Entity set | Identifier | Represents |
|---|---|---|
| Restaurant | restaurant_id | A restaurant using the system ) |
| Role | role_id | A job title defined by a restaurant, such as Server or Line Cook |
| Staff | staff_id | An employee of a restaurant |
| StaffCredential | username | The login details of a staff member who uses the app |
| Shift | shift_id | A scheduled block of work for one staff member) |
| SwapRequest | swap_id | An offer to give away a shift, possibly covered by someone else |

**Relationships**

| Relationship | Reads as | Multiplicity |
|---|---|---|
| Defines | A restaurant defines roles | many-one |
| Holds | A staff member holds a role | many-one |
| HasLogin | A staff member has a login | one-one |
| Works | A shift is worked by a staff member | many-one |
| Offers | A swap request offers a shift | many-one |
| Covers | A staff member covers a swap request | many-one |


### 4.2 Menu and Inventory

**Requirements covered:** [Section 3.2]

**Entity sets**

| Entity set | Identifier | Represents |
|---|---|---|
| MenuCategory | category_id | A section of a restaurant's menu, such as Mains or Drink |
| MenuItem | menu_item_id | A dish or drink that can be ordered |
| InventoryItem | inventory_item_id | An ingredient or supply the restaurant keeps in stock |
| StockMovement | movement_id | One logged change to the quantity of an inventory item |

**Relationships**

| Relationship | Reads as | Multiplicity |
|---|---|---|
| HasMenu | A restaurant has menu categories | many-one |
| InCategory | A menu item is in a category | many-one |
| HasInventory | A restaurant has inventory items | many-one |
| Uses | A menu item uses inventory items (attribute: `qty_per_serving`) | many-many |
| Moves | A stock movement changes an inventory item | many-one |

### 4.3 Front of House

**Requirements covered:** [Section 3.3]

**Entity sets**

| Entity set | Identifier | Represents |
|---|---|---|
| DiningTable | table_id | A physical table in a restaurant |
| Customer | customer_id | A person who orders or reserves |
| Reservation | reservation_id | A booking of a table for a date and time and name |
| CustomerOrder | order_id | An order placed at a restaurant |
| OrderItem | order_item_id | One line of an order |
| Review | review_id | A customer's rating of an order |

**Relationships**

| Relationship | Reads as | Multiplicity |
|---|---|---|
| HasTable | A restaurant has tables | many-one |
| BookedBy | A reservation is booked by a customer | many-one |
| BookedAt | A reservation is booked at a table | many-one |
| Receives | A restaurant receives orders | many-one |
| Orders | A customer orders an order | many-one |
| SeatedAt | A dine-in order is seated at a table (attribute: `party_size`) | many-one |
| ServedBy | A dine-in order is served by a staff member | many-one |
| Contains | An order contains order items | many-one |
| OfItem | An order item is of a menu item | many-one |
| About | A review is about an order | one-one |

**Design decisions**

For all entities, relationships, and attributes this is not the final version of it. When we finalize our whole ERD in the next sprint, all of them will be double-checked and we will create new logic (attributes, relationships, etc) to meet with machine learning aspect of this project, which was already implemented in the backend but the database was not adjusted. 

---

## 5. Relational Schema

The ERD in Section 4 maps to **31 relations**. 

| ERD construct | Mapping | Example |
|---|---|---|
| Entity set | One relation; its identifier becomes the primary key | Customer |
| Many-one relationship | Foreign key on the "many" side | *Works* → Shift.staff_id |
| Many-many relationship | Mapping relation whose key combines both identifiers | *Uses* → RecipeLine, *Promotes* → CampaignItem |
| One-one relationship | The key of one side is also the foreign key | *HasLogin* → StaffCredential.staff_id |
| Weak entity set | Owner's key + partial key form the primary key | Role(restaurant_id, role_name) |
| Inheritance (isa), E/R style | One relation per subclass, holding the superclass key and only the subclass's own attributes | HourlyStaff(staff_id, hourly_rate) |
| Role labels | Become the foreign key's column name | *Covers* (cover) → cover_staff_id |

### Staff and Labour

- Restaurant(<ins>restaurant_id</ins>: INT, name: VARCHAR(100), address: VARCHAR(255), phone: VARCHAR(20), currency: CHAR(3))
- Role(<ins>restaurant_id</ins>: INT → Restaurant, <ins>role_name</ins>: VARCHAR(50), department: ENUM('FRONT_OF_HOUSE', 'KITCHEN', 'MANAGEMENT'))
- Staff(<ins>staff_id</ins>: INT, (restaurant_id: INT, role_name: VARCHAR(50)) → Role, name: VARCHAR(100), email: VARCHAR(255), phone: VARCHAR(20), hire_date: DATE, is_active: BOOLEAN)
- HourlyStaff(<ins>staff_id</ins>: INT → Staff, hourly_rate: DECIMAL(10,2))
- SalariedStaff(<ins>staff_id</ins>: INT → Staff, monthly_salary: DECIMAL(10,2))
- StaffCredential(<ins>staff_id</ins>: INT → Staff, username: VARCHAR(50), password_hash: CHAR(60), force_reset: BOOLEAN, last_login_at: DATETIME)
- Shift(<ins>shift_id</ins>: INT, staff_id: INT → Staff, start_at: DATETIME, end_at: DATETIME, notes: VARCHAR(255))
- SwapRequest(<ins>swap_id</ins>: INT, shift_id: INT → Shift, cover_staff_id: INT → Staff, decided_by: INT → Staff, status: ENUM('PENDING', 'APPROVED', 'DENIED'), created_at: DATETIME)
- TimeClockEvent(<ins>event_id</ins>: INT, staff_id: INT → Staff, shift_id: INT → Shift, event_type: ENUM('CLOCK_IN', 'CLOCK_OUT', 'BREAK_START', 'BREAK_END'), occurred_at: DATETIME, note: VARCHAR(255))
- TimeOffRequest(<ins>request_id</ins>: INT, staff_id: INT → Staff, decided_by: INT → Staff, start_date: DATE, end_date: DATE, hours: DECIMAL(10,2), reason: VARCHAR(255), status: ENUM('PENDING', 'APPROVED', 'REJECTED'), created_at: DATETIME)
- PayRecord(<ins>pay_record_id</ins>: INT, staff_id: INT → Staff, period_start: DATE, period_end: DATE, hours_worked: DECIMAL(10,2), rate_snapshot: DECIMAL(10,2), bonus: DECIMAL(10,2), deductions: DECIMAL(10,2))
- StaffingRequirement(<ins>requirement_id</ins>: INT, restaurant_id: INT → Restaurant, work_date: DATE, start_time: TIME, end_time: TIME, department: ENUM('FRONT_OF_HOUSE', 'KITCHEN', 'MANAGEMENT'), required_count: INT)

### Menu and Inventory

- MenuCategory(<ins>category_id</ins>: INT, restaurant_id: INT → Restaurant, name: VARCHAR(50), sort_order: INT)
- MenuItem(<ins>menu_item_id</ins>: INT, category_id: INT → MenuCategory, name: VARCHAR(100), price: DECIMAL(10,2), is_available: BOOLEAN)
- InventoryItem(<ins>inventory_item_id</ins>: INT, restaurant_id: INT → Restaurant, name: VARCHAR(100), unit: ENUM('g', 'kg', 'ml', 'l', 'unit'), par_level: DECIMAL(10,2), lead_time_days: INT)
- RecipeLine(<ins>menu_item_id</ins>: INT → MenuItem, <ins>inventory_item_id</ins>: INT → InventoryItem, qty_per_serving: DECIMAL(10,2))
- StockMovement(<ins>movement_id</ins>: INT, inventory_item_id: INT → InventoryItem, movement_type: ENUM('RECEIVE', 'CONSUME', 'WASTE', 'ADJUST'), quantity_delta: DECIMAL(10,2), unit_cost: DECIMAL(10,2), reason: VARCHAR(255), occurred_at: DATETIME)

### Front of House

- DiningTable(<ins>table_id</ins>: INT, restaurant_id: INT → Restaurant, label: VARCHAR(10), seats: INT, section: VARCHAR(30))
- Customer(<ins>customer_id</ins>: INT, name: VARCHAR(100), phone: VARCHAR(20), email: VARCHAR(255))
- Reservation(<ins>reservation_id</ins>: INT, table_id: INT → DiningTable, customer_id: INT → Customer, reserved_for: DATETIME, party_size: INT, status: ENUM('BOOKED', 'SEATED', 'CANCELLED', 'NO_SHOW'))
- CustomerOrder(<ins>order_id</ins>: INT, restaurant_id: INT → Restaurant, customer_id: INT → Customer, channel: ENUM('IN_PERSON', 'PHONE', 'ONLINE'), status: ENUM('PENDING', 'CONFIRMED', 'FULFILLED', 'CANCELLED'), payment_type: ENUM('CASH', 'CARD', 'ONLINE', 'THIRD_PARTY'), tip: DECIMAL(10,2), created_at: DATETIME, started_at: DATETIME, finished_at: DATETIME)
- DineInOrder(<ins>order_id</ins>: INT → CustomerOrder, table_id: INT → DiningTable, server_id: INT → Staff, party_size: INT)
- DeliveryOrder(<ins>order_id</ins>: INT → CustomerOrder, delivery_address: VARCHAR(255), delivery_notes: VARCHAR(255), courier: ENUM('IN_HOUSE', 'UBER_EATS'), external_order_ref: VARCHAR(64))
- KitchenTicket(<ins>ticket_id</ins>: INT, order_id: INT → CustomerOrder, batch_no: INT, status: ENUM('NEW', 'COOKING', 'READY'), is_priority: BOOLEAN, created_at: DATETIME, completed_at: DATETIME)
- OrderItem(<ins>order_id</ins>: INT → CustomerOrder, <ins>line_no</ins>: INT, menu_item_id: INT → MenuItem, ticket_id: INT → KitchenTicket, quantity: INT, unit_price: DECIMAL(10,2), notes: VARCHAR(255))
- Review(<ins>review_id</ins>: INT, order_id: INT → CustomerOrder, rating: INT, comment: TEXT, created_at: DATETIME)

### Marketing and Analytics

- Campaign(<ins>campaign_id</ins>: INT, restaurant_id: INT → Restaurant, name: VARCHAR(100), start_date: DATE, end_date: DATE, budget: DECIMAL(10,2))
- CampaignItem(<ins>campaign_id</ins>: INT → Campaign, <ins>menu_item_id</ins>: INT → MenuItem)
- Announcement(<ins>announcement_id</ins>: INT, restaurant_id: INT → Restaurant, author_id: INT → Staff, message: TEXT, announcement_type: ENUM('INFO', 'WARNING', 'PROMO'), is_active: BOOLEAN, created_at: DATETIME)
- WeatherObservation(<ins>restaurant_id</ins>: INT → Restaurant, <ins>observed_date</ins>: DATE, temp_max: DECIMAL(10,2), temp_min: DECIMAL(10,2), condition: ENUM('SUNNY', 'CLOUDY', 'RAIN', 'SNOW'), precipitation_mm: DECIMAL(10,2))
- Insight(<ins>insight_id</ins>: INT, restaurant_id: INT → Restaurant, title: VARCHAR(100), message: TEXT, insight_type: ENUM('INFO', 'ALERT', 'SUCCESS'), created_at: DATETIME, expires_at: DATETIME)

---

## 6. Keys

**Definitions**

- **Superkey:** any set of attributes whose closure is the whole relation.
- **Candidate key:** a column, or a minimal set of columns, that can uniquely identify any row in a database table.
- **Primary key:** a constraint that uniquely identifies each record in a database table
- **Non-prime attribute:** an attribute that is not part of any candidate key.

### Staff and Labour

| Relation | Candidate keys | Primary key | Superkeys | Non-prime attributes |
|---|---|---|---|---|
| Restaurant | {restaurant_id} | restaurant_id | any set containing restaurant_id | name, address, phone, currency |
| Role | {restaurant_id, role_name} | (restaurant_id, role_name) | any set containing both restaurant_id and role_name | department |
| Staff | {staff_id} | staff_id | any set containing staff_id | restaurant_id, role_name, name, email, phone, hire_date, is_active |
| HourlyStaff | {staff_id} | staff_id | any set containing staff_id | hourly_rate |
| SalariedStaff | {staff_id} | staff_id | any set containing staff_id | monthly_salary |
| StaffCredential | {staff_id}, {username} | staff_id | any set containing staff_id *or* username | password_hash, force_reset, last_login_at |
| Shift | {shift_id} | shift_id | any set containing shift_id | staff_id, start_at, end_at, notes |
| SwapRequest | {swap_id} | swap_id | any set containing swap_id | shift_id, cover_staff_id, decided_by, status, created_at |
| TimeClockEvent | {event_id} | event_id | any set containing event_id | staff_id, shift_id, event_type, occurred_at, note |
| TimeOffRequest | {request_id} | request_id | any set containing request_id | staff_id, decided_by, start_date, end_date, hours, reason, status, created_at |
| PayRecord | {pay_record_id}, {staff_id, period_start} | pay_record_id | any set containing pay_record_id, *or* containing both staff_id and period_start | period_end, hours_worked, rate_snapshot, bonus, deductions |
| StaffingRequirement | {requirement_id}, {restaurant_id, work_date, department, start_time} | requirement_id | any set containing requirement_id, *or* containing all of restaurant_id, work_date, department, and start_time | end_time, required_count |

### Menu and Inventory

| Relation | Candidate keys | Primary key | Superkeys | Non-prime attributes |
|---|---|---|---|---|
| MenuCategory | {category_id}, {restaurant_id, name} | category_id | any set containing category_id, *or* containing both restaurant_id and name | sort_order |
| MenuItem | {menu_item_id}, {category_id, name} | menu_item_id | any set containing menu_item_id, *or* containing both category_id and name | price, is_available |
| InventoryItem | {inventory_item_id}, {restaurant_id, name} | inventory_item_id | any set containing inventory_item_id, *or* containing both restaurant_id and name | unit, par_level, lead_time_days |
| RecipeLine (from the "Uses" relationship) | {menu_item_id, inventory_item_id} | (menu_item_id, inventory_item_id) | the key itself, or the key plus qty_per_serving | qty_per_serving |
| StockMovement | {movement_id} | movement_id | any set containing movement_id | inventory_item_id, movement_type, quantity_delta, unit_cost, reason, occurred_at |

### Front of House

| Relation | Candidate keys | Primary key | Superkeys | Non-prime attributes |
|---|---|---|---|---|
| DiningTable | {table_id}, {restaurant_id, label} | table_id | any set containing table_id, *or* containing both restaurant_id and label | seats, section |
| Customer | {customer_id}, {phone} | customer_id | any set containing customer_id *or* phone | name, email |
| Reservation | {reservation_id}, {table_id, reserved_for} | reservation_id | any set containing reservation_id, *or* containing both table_id and reserved_for | customer_id, party_size, status |
| CustomerOrder | {order_id} | order_id | any set containing order_id | restaurant_id, customer_id, channel, status, payment_type, tip, created_at, started_at, finished_at |
| DineInOrder | {order_id} | order_id | any set containing order_id | table_id, server_id, party_size |
| DeliveryOrder | {order_id} | order_id | any set containing order_id | delivery_address, delivery_notes, courier, external_order_ref |
| KitchenTicket | {ticket_id}, {order_id, batch_no} | ticket_id | any set containing ticket_id, *or* containing both order_id and batch_no | status, is_priority, created_at, completed_at |
| OrderItem | {order_id, line_no} | (order_id, line_no) | any set containing both order_id and line_no | menu_item_id, ticket_id, quantity, unit_price, notes |
| Review | {review_id}, {order_id} | review_id | any set containing review_id *or* order_id | rating, comment, created_at |

### Marketing and Analytics

| Relation | Candidate keys | Primary key | Superkeys | Non-prime attributes |
|---|---|---|---|---|
| Campaign | {campaign_id} | campaign_id | any set containing campaign_id | restaurant_id, name, start_date, end_date, budget |
| CampaignItem (from the "Promotes" relationship) | {campaign_id, menu_item_id} | (campaign_id, menu_item_id) | the key itself | none |
| Announcement | {announcement_id} | announcement_id | any set containing announcement_id | restaurant_id, author_id, message, announcement_type, is_active, created_at |
| WeatherObservation | {restaurant_id, observed_date} | (restaurant_id, observed_date) | any set containing both restaurant_id and observed_date | temp_max, temp_min, condition, precipitation_mm |
| Insight | {insight_id} | insight_id | any set containing insight_id | restaurant_id, title, message, insight_type, created_at, expires_at |
---

## 7. Functional Dependencies and BCNF

### 7.1 Functional Dependencies

The non-trivial functional dependencies of each relation, in the notation X → Y. When several attributes appear on the left side, they determine the right side *together*.

**Staff and Labour**

| Relation | Functional dependencies |
|---|---|
| Restaurant | restaurant_id → name, address, phone, currency |
| Role | restaurant_id, role_name → department |
| Staff | staff_id → restaurant_id, role_name, name, email, phone, hire_date, is_active |
| HourlyStaff | staff_id → hourly_rate |
| SalariedStaff | staff_id → monthly_salary |
| StaffCredential | staff_id → username, password_hash, force_reset, last_login_at<br>username → staff_id, password_hash, force_reset, last_login_at |
| Shift | shift_id → staff_id, start_at, end_at, notes |
| SwapRequest | swap_id → shift_id, cover_staff_id, decided_by, status, created_at |
| TimeClockEvent | event_id → staff_id, shift_id, event_type, occurred_at, note |
| TimeOffRequest | request_id → staff_id, decided_by, start_date, end_date, hours, reason, status, created_at |
| PayRecord | pay_record_id → staff_id, period_start, period_end, hours_worked, rate_snapshot, bonus, deductions<br>staff_id, period_start → pay_record_id, period_end, hours_worked, rate_snapshot, bonus, deductions |
| StaffingRequirement | requirement_id → restaurant_id, work_date, start_time, end_time, department, required_count<br>restaurant_id, work_date, department, start_time → requirement_id, end_time, required_count |

**Menu and Inventory**

| Relation | Functional dependencies |
|---|---|
| MenuCategory | category_id → restaurant_id, name, sort_order<br>restaurant_id, name → category_id, sort_order |
| MenuItem | menu_item_id → category_id, name, price, is_available<br>category_id, name → menu_item_id, price, is_available |
| InventoryItem | inventory_item_id → restaurant_id, name, unit, par_level, lead_time_days<br>restaurant_id, name → inventory_item_id, unit, par_level, lead_time_days |
| RecipeLine (from the "Uses" relationship) | menu_item_id, inventory_item_id → qty_per_serving |
| StockMovement | movement_id → inventory_item_id, movement_type, quantity_delta, unit_cost, reason, occurred_at |

**Front of House**

| Relation | Functional dependencies |
|---|---|
| DiningTable | table_id → restaurant_id, label, seats, section<br>restaurant_id, label → table_id, seats, section |
| Customer | customer_id → name, phone, email<br>phone → customer_id, name, email |
| Reservation | reservation_id → table_id, customer_id, reserved_for, party_size, status<br>table_id, reserved_for → reservation_id, customer_id, party_size, status |
| CustomerOrder | order_id → restaurant_id, customer_id, channel, status, payment_type, tip, created_at, started_at, finished_at |
| DineInOrder | order_id → table_id, server_id, party_size |
| DeliveryOrder | order_id → delivery_address, delivery_notes, courier, external_order_ref |
| KitchenTicket | ticket_id → order_id, batch_no, status, is_priority, created_at, completed_at<br>order_id, batch_no → ticket_id, status, is_priority, created_at, completed_at |
| OrderItem | order_id, line_no → menu_item_id, ticket_id, quantity, unit_price, notes |
| Review | review_id → order_id, rating, comment, created_at<br>order_id → review_id, rating, comment, created_at |

**Marketing and Analytics**

| Relation | Functional dependencies |
|---|---|
| Campaign | campaign_id → restaurant_id, name, start_date, end_date, budget |
| CampaignItem (from the "Promotes" relationship) | none (only the trivial FD campaign_id, menu_item_id → campaign_id, menu_item_id) |
| Announcement | announcement_id → restaurant_id, author_id, message, announcement_type, is_active, created_at |
| WeatherObservation | restaurant_id, observed_date → temp_max, temp_min, condition, precipitation_mm |
| Insight | insight_id → restaurant_id, title, message, insight_type, created_at, expires_at |

ASK FOR NEXT SPRINT: Do we need dependencies that do not hold?

ASK FOR NEXT SPRINT: Do we need to identify anomalies in the Original Schema?

### 7.2 BCNF Decompositions

**Example of the method.** With A → B, B → C, and AB → D:
- {A}⁺: start with A; A → B adds B; B → C adds C; now A and B are both in, so AB → D adds D. {A}⁺ = {A, B, C, D}, so A is a key.
- {B}⁺: start with B; B → C adds C. {B}⁺ = {B, C}, not all attributes, so B → C is a BCNF violation.

#### Staff and Labour

##### D1: Staff → Role + Staff

| Letter | A | B | C | D | E |
|---|---|---|---|---|---|
| Attribute | staff_id | restaurant_id | role_name | department | name |

- **FDs:** A → B, C, D, E and B, C → D (a role is always in the same department)
- **Closures:**
  - {A}⁺ = {A, B, C, D, E}, so A is a key
  - {B, C}⁺ = {B, C, D}, not all attributes, so **B, C → D is a BCNF violation**
- **Decomposition on B, C → D:**
  - R1 = {B, C, D}
  - R2 = {A, B, C, E}
- **After:** **Role**(restaurant_id, role_name, department) and **Staff**(staff_id, restaurant_id, role_name, name, …)

##### D2: SwapRequest

| Letter | A | B | C | D | E |
|---|---|---|---|---|---|
| Attribute | swap_id | shift_id | requester_id | status | created_at |

- **FDs:** A → B, C, D, E and B → C (only the owner of a shift can offer it)
- **Closures:**
  - {A}⁺ = {A, B, C, D, E}, so A is a key
  - {B}⁺ = {B, C}, not all attributes, so **B → C is a BCNF violation**
- **Decomposition on B → C:**
  - R1 = {B}⁺ = {B, C}
  - R2 = {A, B, D, E}
- **After:** **SwapRequest**(swap_id, shift_id, cover_staff_id, decided_by, status, created_at).

##### D3: TimeOffRequest

| Letter | A | B | C | D | E | F |
|---|---|---|---|---|---|---|
| Attribute | request_id | staff_id | staff_name | restaurant_id | start_date | status |

- **FDs:** A → B, C, D, E, F and B → C, D (a staff member always has the same name and restaurant)
- **Closures:**
  - {A}⁺ = {A, B, C, D, E, F}, so A is a key
  - {B}⁺ = {B, C, D}, not all attributes, so **B → C, D is a BCNF violation**
- **Decomposition on B → C, D:**
  - R1 = {B}⁺ = {B, C, D}, which is already in Staff
  - R2 = {A, B, E, F}
- **After:** **TimeOffRequest**(request_id, staff_id, decided_by, start_date, end_date, hours, reason, status, created_at). 

##### D4: PayRecord

| Letter | A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|---|
| Attribute | pay_record_id | staff_id | hours_worked | rate | gross_pay | bonus | deductions | total_pay |

- **FDs:** A → B, C, D, E, F, G, H and C, D → E (gross pay = hours × rate) and E, F, G → H (total pay = gross + bonus − deductions)
- **Closures:**
  - {A}⁺ = all attributes, so A is a key
  - {C, D}⁺ = {C, D, E}, not all attributes, so **C, D → E is a BCNF violation**
  - {E, F, G}⁺ = {E, F, G, H}, not all attributes, so **E, F, G → H is a BCNF violation**
- **Decomposition:** R1 = {C, D, E}
- **After:** **PayRecord**(pay_record_id, staff_id, period_start, period_end, hours_worked, rate_snapshot, bonus, deductions).

#### Menu and Inventory

##### D5: MenuItemIngredient → RecipeLine

| Letter | A | B | C | D |
|---|---|---|---|---|
| Attribute | menu_item_id | inventory_item_id | qty_per_serving | unit |

- **FDs:** A, B → C and B → D (an ingredient always has the same unit)
- **Closures:**
  - {A}⁺ = {A}
  - {B}⁺ = {B, D}, not all attributes, so **B → D is a BCNF violation**
  - {A, B}⁺ = {A, B, C, D}, so {A, B} is a key
- **Decomposition on B → D:**
  - R1 = {B}⁺ = {B, D}, which moves into InventoryItem
  - R2 = {A, B, C}
- **After:** **RecipeLine**(menu_item_id, inventory_item_id, qty_per_serving).

##### D6: Purchase → StockMovement

| Letter | A | B | C | D | E | F |
|---|---|---|---|---|---|---|
| Attribute | purchase_id | inventory_item_id | restaurant_id | quantity | unit_cost | date |

- **FDs:** A → B, C, D, E, F and B → C (an ingredient belongs to one restaurant)
- **Closures:**
  - {A}⁺ = {A, B, C, D, E, F}, so A is a key
  - {B}⁺ = {B, C}, not all attributes, so **B → C is a BCNF violation**
- **Decomposition on B → C:**
  - R1 = {B}⁺ = {B, C}, which is already in InventoryItem
  - R2 = {A, B, D, E, F}
- **After:** **StockMovement**.

#### Front of House

##### D7: Order → CustomerOrder + DineInOrder + Customer

| Letter | A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|---|
| Attribute | order_id | table_id | table_label | table_section | restaurant_id | customer_phone | customer_name |

- **FDs:** A → B, C, D, E, F, G and B → C, D, E and F → G
- **Closures:**
  - {A}⁺ = {A, B, C, D, E, F, G}, so A is a key
  - {B}⁺ = {B, C, D, E}, not all attributes, so **B → C, D, E is a BCNF violation**
  - {F}⁺ = {F, G}, not all attributes, so **F → G is a BCNF violation**
- **Decomposition on F → G:**
  - R1 = {F}⁺ = {F, G}, which becomes Customer
  - R2 = {A, B, C, D, E, F}
- **After:** **CustomerOrder**(order_id, restaurant_id, customer_id, …), **DineInOrder**(order_id, table_id, server_id, party_size), and **Customer**(customer_id, name, phone, email).

##### D8: KitchenTicket

| Letter | A | B | C | D | E | F |
|---|---|---|---|---|---|---|
| Attribute | ticket_id | order_id | table_label | server_name | restaurant_id | status |

- **FDs:** A → B, C, D, E, F and B → C, D, E (an order always has the same table, server, and restaurant)
- **Closures:**
  - {A}⁺ = {A, B, C, D, E, F}, so A is a key
  - {B}⁺ = {B, C, D, E}, not all attributes, so **B → C, D, E is a BCNF violation**
- **Decomposition on B → C, D, E:**
  - R1 = {B}⁺ = {B, C, D, E}, which is already in CustomerOrder and DineInOrder
  - R2 = {A, B, F}
- **After:** **KitchenTicket**(ticket_id, order_id, batch_no, status, is_priority, created_at, completed_at).

---

### 7.3 BCNF Verification

**Staff and Labour**

| Relation | Closures of FD left sides | BCNF |
|---|---|---|
| Restaurant | {restaurant_id}⁺ = all attributes | ✓ |
| Role | {restaurant_id, role_name}⁺ = all attributes | ✓ |
| Staff | {staff_id}⁺ = all attributes | ✓ |
| HourlyStaff | {staff_id}⁺ = all attributes | ✓ |
| SalariedStaff | {staff_id}⁺ = all attributes | ✓ |
| StaffCredential | {staff_id}⁺ = all attributes<br>{username}⁺ = all attributes | ✓ |
| Shift | {shift_id}⁺ = all attributes | ✓ |
| SwapRequest | {swap_id}⁺ = all attributes | ✓ |
| TimeClockEvent | {event_id}⁺ = all attributes | ✓ |
| TimeOffRequest | {request_id}⁺ = all attributes | ✓ |
| PayRecord | {pay_record_id}⁺ = all attributes<br>{staff_id, period_start}⁺ = all attributes | ✓ |
| StaffingRequirement | {requirement_id}⁺ = all attributes<br>{restaurant_id, work_date, department, start_time}⁺ = all attributes | ✓ |

**Menu and Inventory**

| Relation | Closures of FD left sides | BCNF |
|---|---|---|
| MenuCategory | {category_id}⁺ = all attributes<br>{restaurant_id, name}⁺ = all attributes | ✓ |
| MenuItem | {menu_item_id}⁺ = all attributes<br>{category_id, name}⁺ = all attributes | ✓ |
| InventoryItem | {inventory_item_id}⁺ = all attributes<br>{restaurant_id, name}⁺ = all attributes | ✓ |
| RecipeLine | {menu_item_id, inventory_item_id}⁺ = all attributes | ✓ |
| StockMovement | {movement_id}⁺ = all attributes | ✓ |

**Front of House**

| Relation | Closures of FD left sides | BCNF |
|---|---|---|
| DiningTable | {table_id}⁺ = all attributes<br>{restaurant_id, label}⁺ = all attributes | ✓ |
| Customer | {customer_id}⁺ = all attributes<br>{phone}⁺ = all attributes | ✓ |
| Reservation | {reservation_id}⁺ = all attributes<br>{table_id, reserved_for}⁺ = all attributes | ✓ |
| CustomerOrder | {order_id}⁺ = all attributes | ✓ |
| DineInOrder | {order_id}⁺ = all attributes | ✓ |
| DeliveryOrder | {order_id}⁺ = all attributes | ✓ |
| KitchenTicket | {ticket_id}⁺ = all attributes<br>{order_id, batch_no}⁺ = all attributes | ✓ |
| OrderItem | {order_id, line_no}⁺ = all attributes | ✓ |
| Review | {review_id}⁺ = all attributes<br>{order_id}⁺ = all attributes | ✓ |

**Marketing and Analytics**

| Relation | Closures of FD left sides | BCNF |
|---|---|---|
| Campaign | {campaign_id}⁺ = all attributes | ✓ |
| CampaignItem | no non-trivial FDs (all attributes form the key) | ✓ |
| Announcement | {announcement_id}⁺ = all attributes | ✓ |
| WeatherObservation | {restaurant_id, observed_date}⁺ = all attributes | ✓ |
| Insight | {insight_id}⁺ = all attributes | ✓ |


---


## 8. Implementation

Note: Might get revised!

| File | Contents |
|---|---|
| `sql/schema.sql` | DDL for the 18 relations |
| `sql/seed.sql` | Sample data for two restaurants (Possibly in the next sprint) |
| `sql/demo.sql` | to test to meet with the rubric (Possibly in the next sprint) |

---

## 9. Known Limitations

#ASK TO TA FOR THE NEXT SPRINT

1. **Cross-restaurant consistency.** Every row belongs to one restaurant, so each restaurant's data stays separate. However, the database does not check that connected data belongs to the *same* restaurant. For example, an order from Harbour Grill could contain a menu item from Kebab Corner, because OrderItem only checks that the menu item exists.
   - **How it is handled now:** the application always filters by the logged-in restaurant, so users only ever see and select their own restaurant's menu items, tables, and staff.
   - **How we will fix it:** next sprint we will compare two options:
     - **Add restaurant_id to the connecting tables** 
     - **Keep the tables in BCNF and add a check** 


Note: The Limitations will be updated in the next sprints. 

---

## 10. Next Sprint Goals


**Note: Sprint Goals are subject to change even though %80 of them aimed to meet in the next sprint.**

### Questions for the TA-client

1. Are the superkeys and candidate keys of DiningTable and Review
2. SwapRequest decomposition (D2) 
3. Should we also list functional dependencies that do not hold?
4. Should we document the anomalies of the original schema in more detail? ... Look notes for more

---

## 11. Use of Generative AI and Prior Work

**Prior work.** The original Prisma schema and application were written organically by Caner Kaan Balseven during an entrepreneurship co-op term, before this course. Everything in this document and repository is a redesign done for CSC 370. In Addition, 'schema.sql' was kind of already implemented in my co-op work term; I only converted the tables Prisma ORM to SQL also did not focus on NULL values, etc. in this sprint. I will be focusing on these in the next sprint. 

**Generative AI.**

- **Claude (Anthropic)** was used to review the original schema for unseen relations, and draft this document (wording, structure idea and confirming the logic). Additionally, asked to AI how to meet better with course rubric to match with A+ as well as BCNF Verification is generated by AI but understood and need to confirm the logic with TA. Also, AI is used to guide me to do the assignment step by step in the most meaningful and the fastest way; so I used it for planning also did not follow blindly I did other things before what I should do according to AI. Moreover, even though I mapped competencies to what i did, I also got help from AI to match them in a perfect way and actually understood what i did in a level-wise category. 

**How the team verified the work.** Because the team worked through the functional dependencies and decompositions ourselves, using AI did not replace developing the course competencies. However, I still believe there will be problems about them especially after implementing the whole data entities. I will need to confirm them with TA. Additionally, because it is my idea, technically there is no right or wrong way to do it explicitly; I might need to reestablish the relationships etc. based on what we are going to implement as a functionality to the project. I focused on what we did instead of what we are going to do in this sprint. If there is no time until Sprint 1 for functionality confirmation; I am planning to do it at least until Sprint 2. I believe ERD should not supposed to take this much time in this course but my project is data project at the end of the day so that it will get revised in any time. 

---

## 12. References

- Chester, S. (2026). *CSC 370 lecture slides:* Storing Data with SQL; Retrieving Data with SQL; Conceptual Design; Multiplicity; FDs and Keys; BCNF Decomposition. University of Victoria.

  **Videos**

- making IT simple. (4 years ago - current year 2026). *Functional Dependency in DBMS* [Video]. YouTube. https://youtu.be/fZ41WtisQgo
- making IT simple. (5 years ago - current year 2026). *Normalization in DBMS | Insertion, Updation & Deletion Anomalies* [Video]. YouTube. https://youtu.be/UF0UHCX-z0E
- Decomplexify. (4 years ago - current year 2026). *Learn Database Normalization - 1NF, 2NF, 3NF, 4NF, 5NF* [Video]. YouTube. https://youtu.be/GFQaEYEc8_8
- Decomplexify. (4 years ago - current year 2026). *Learn Boyce-Codd Normal Form (BCNF)* [Video]. YouTube. https://youtu.be/VWnKUKH4tLg

   
