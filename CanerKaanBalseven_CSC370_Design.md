<!-- ===================== COVER PAGE ===================== -->

<p align="center">
  <br><br>
  <b>CSC 370: Database Systems</b><br>
  University of Victoria · Fall 2026
  <br><br><br>
</p>

<h1 align="center">Restaurant Management Database</h1>
<h3 align="center">Conceptual and Relational Design: Kickoff Sprint</h3>

<p align="center">
  <br><br>
  <b>Group 47</b><br>
  Caner Kaan Balseven V01074078<br>
  <br><br>
  <b>TA-Client:</b> Nikhil Partap Singh Dhillon <br>
  <b>Instructor:</b> Sean Chester
  <br><br>
  <b>Submission:</b> Project Kickoff · October 4, 2026<br>
  <b>Commit:</b>
  <br><br>
</p>

<div style="page-break-after: always;"></div>

---
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

## 2. Kickoff Sprint Goals

The goals for this sprint, as set by the assignment:

> **G1.** Demonstrate the course-level competency of developing conceptual and relational schemata for a set of requirements that we come up with, reaching at least partway through **Level 2 of the Data Modelling (Data Architecture) competency**.
>
> **G2.** Build a complete ERD and implement it as a normalized relational database with SQL DDL code.

To make these goals measurable, we broke them into the following success criteria:

| # | Success criterion | Evidence |
|---|---|---|
| S1 | Requirements are written down, numbered, and the out-of-scope parts are listed explicitly | Section 3
| S2 | The ERD is complete: every requirement maps to at least one entity set or relationship, and every entity set has an identifier | Section 4
| S3 | The ERD is mapped to relations using the rules from the course (many-one → foreign key, many-many → mapping table) | Section 5
| S4 | Every relation has its keys and functional dependencies documented | Section 6 & Section 7.1
| S5 | The flawed relations of the original schema are decomposed with the BCNF algorithm, and every final relation is verified to be in BCNF | Section 7.3 & 7.4
| S6 | The DDL runs on MySQL with zero errors, and the schema rejects invalid data | Section 8

These criteria map to the Data Modelling competency bullets:

| Competency bullet | Covered by |
|---|---|
| L1: Selects appropriate data types for tables | Section 6 |
| L1: Writes SQL code that implements a relational design | Section 6 |
| L1: Documents relationships with correct ERDs | Section 2 |
| L2: Identifies dependencies among attributes and appropriate keys | Section 4 |
| L2: Eliminates data anomalies with effective normalisation | Section 5 |
| L2: Justifies the quality of a schema through a theoretical lens | Section 5 |
| L2: Maps requirements onto schemata and vice versa | Section 1, Section 2 |

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

Note: Sensitive personal fields from the original staff model, such as national ID, bank account (IBAN), and blood type, are left out on purpose. No current requirement needs them, and storing personal data without a purpose is poor data governance.


---

## 4. Entity-Relationship Diagram

![Full ERD](erd/erd.png)

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

![ERD: Staff part](erd/erd_staff.png)

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

![ERD: Menu and Inventory part](erd/erd_menu_inventory.png)

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

![ERD: Front of House part](erd/erd_front_of_house.png)

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

The result is 18 relations. Primary keys are <ins>underlined</ins>.

- Restaurant(<ins>restaurant_id</ins>: INT, name: VARCHAR(100), address: VARCHAR(255), phone: VARCHAR(20), currency: CHAR(3))
- Role(<ins>role_id</ins>: INT, restaurant_id: INT, role_name: VARCHAR(50), department: ENUM('FRONT_OF_HOUSE', 'KITCHEN', 'MANAGEMENT'))
- Staff(<ins>staff_id</ins>: INT, role_id: INT, name: VARCHAR(100), email: VARCHAR(255), phone: VARCHAR(20), hire_date: DATE, pay_type: ENUM('HOURLY', 'SALARY'), hourly_rate: DECIMAL(8,2), monthly_salary: DECIMAL(10,2), is_active: BOOLEAN)
- StaffCredential(<ins>staff_id</ins>: INT, username: VARCHAR(50), password_hash: CHAR(60), force_reset: BOOLEAN, last_login_at: DATETIME)
- Shift(<ins>shift_id</ins>: INT, staff_id: INT, start_at: DATETIME, end_at: DATETIME, notes: VARCHAR(255))
- SwapRequest(<ins>swap_id</ins>: INT, shift_id: INT, cover_staff_id: INT, status: ENUM('PENDING', 'APPROVED', 'DENIED'), created_at: DATETIME)
- MenuCategory(<ins>category_id</ins>: INT, restaurant_id: INT, name: VARCHAR(50), sort_order: INT)
- MenuItem(<ins>menu_item_id</ins>: INT, category_id: INT, name: VARCHAR(100), price: DECIMAL(8,2), is_available: BOOLEAN)
- InventoryItem(<ins>inventory_item_id</ins>: INT, restaurant_id: INT, name: VARCHAR(100), unit: ENUM('g', 'kg', 'ml', 'l', 'unit'), par_level: DECIMAL(10,3), lead_time_days: INT)
- RecipeLine(<ins>menu_item_id</ins>: INT, <ins>inventory_item_id</ins>: INT, qty_per_serving: DECIMAL(10,3))
- StockMovement(<ins>movement_id</ins>: INT, inventory_item_id: INT, movement_type: ENUM('RECEIVE', 'CONSUME', 'WASTE', 'ADJUST'), quantity_delta: DECIMAL(10,3), unit_cost: DECIMAL(10,2), reason: VARCHAR(255), occurred_at: DATETIME)
- DiningTable(<ins>table_id</ins>: INT, restaurant_id: INT, label: VARCHAR(10), seats: INT, section: VARCHAR(30))
- Customer(<ins>customer_id</ins>: INT, name: VARCHAR(100), phone: VARCHAR(20), email: VARCHAR(255))
- Reservation(<ins>reservation_id</ins>: INT, table_id: INT, customer_id: INT, reserved_for: DATETIME, party_size: INT, status: ENUM('BOOKED', 'SEATED', 'CANCELLED', 'NO_SHOW'))
- CustomerOrder(<ins>order_id</ins>: INT, restaurant_id: INT, customer_id: INT, channel: ENUM('IN_PERSON', 'PHONE', 'ONLINE'), fulfillment: ENUM('DINE_IN', 'PICKUP', 'DELIVERY'), status: ENUM('PENDING', 'CONFIRMED', 'FULFILLED', 'CANCELLED'), payment_type: ENUM('CASH', 'CARD', 'ONLINE', 'THIRD_PARTY), tip: DECIMAL(8,2), created_at: DATETIME, started_at: DATETIME, finished_at: DATETIME, delivery_address: VARCHAR(255), delivery_notes: VARCHAR(255), courier: ENUM('IN_HOUSE', 'UBER_EATS'), external_order_ref: VARCHAR(64))
- DineInDetail(<ins>order_id</ins>: INT, table_id: INT, server_id: INT, party_size: INT)
- OrderItem(<ins>order_item_id</ins>: INT, order_id: INT, menu_item_id: INT, quantity: INT, unit_price: DECIMAL(8,2), notes: VARCHAR(255))
- Review(<ins>review_id</ins>: INT, order_id: INT, rating: INT, comment: TEXT, created_at: DATETIME)

---

## 6. Keys

**Definitions**

- **Superkey:** any set of attributes whose closure is the whole relation.
- **Candidate key:** a column, or a minimal set of columns, that can uniquely identify any row in a database table.
- **Primary key:** a constraint that uniquely identifies each record in a database table
- **Non-prime attribute:** an attribute that is not part of any candidate key.

### Staff

| Relation | Candidate keys | Primary key | Superkeys | Non-prime attributes |
|---|---|---|---|---|
| Restaurant | {restaurant_id} | restaurant_id | any set containing restaurant_id | name, address, phone, currency |
| Role | {role_id}, {restaurant_id, role_name} | role_id | any set containing both restaurant_id and role_name | department |
| Staff | {staff_id} | staff_id | any set containing staff_id | role_id, name, email, phone, hire_date, pay_type, hourly_rate, monthly_salary, is_active |
| StaffCredential | {staff_id}, {username} | staff_id | any set containing staff_id or username | password_hash, force_reset, last_login_at |
| Shift | {shift_id} | shift_id | any set containing shift_id | staff_id, start_at, end_at, notes |
| SwapRequest | {swap_id} | swap_id | any set containing swap_id | shift_id, cover_staff_id, status, created_at |

### Menu and Inventory

| Relation | Candidate keys | Primary key | Superkeys | Non-prime attributes |
|---|---|---|---|---|
| MenuCategory | {category_id}, {restaurant_id, name} | category_id | any set containing both restaurant_id and name | sort_order |
| MenuItem | {menu_item_id}, {category_id, name} | menu_item_id | any set containing containing both category_id and name | price, is_available |
| InventoryItem | {inventory_item_id}, {restaurant_id, name} | inventory_item_id | any set containing inventory_item_id, *or* containing both restaurant_id and name | unit, par_level, lead_time_days |
| RecipeLine (comes from "Uses" relationship) | {menu_item_id, inventory_item_id} | (menu_item_id, inventory_item_id) | the key itself | qty_per_serving |
| StockMovement | {movement_id} | movement_id | any set containing movement_id | inventory_item_id, movement_type, quantity_delta, unit_cost, reason, occurred_at |

### Front of House

| Relation | Candidate keys | Primary key | Superkeys | Non-prime attributes |
|---|---|---|---|---|
| DiningTable | {table_id}, {restaurant_id, label} | table_id | any set containing both restaurant_id and table_id | seats, section | # ASK THIS LINE FOR NEXT SPRINT
| Customer | {customer_id}, {phone} | customer_id | any set containing customer_id  | name, email |
| Reservation | {reservation_id}, {table_id, reserved_for} | reservation_id | any set containing reservation_id | customer_id, party_size, status |
| CustomerOrder | {order_id} | order_id | any set containing order_id | all other attributes |
| DineInDetail | {order_id} | order_id | any set containing order_id | table_id, server_id, party_size |
| OrderItem | {order_item_id} | order_item_id | any set containing order_item_id | order_id, menu_item_id, quantity, unit_price, notes |
| Review | {review_id}, {order_id} | review_id | any set containing review_id *or* order_id | rating, comment, created_at | #ASK THIS LINE FOR NEXT SPRINT

---

## 7. Functional Dependencies and BCNF

### 7.1 Functional Dependencies


**Staff**

| Relation | Functional dependencies |
|---|---|
| Restaurant | restaurant_id → name, address, phone, currency |
| Role | role_id → restaurant_id, role_name, department<br>restaurant_id, role_name → role_id, department |
| Staff | staff_id → role_id, name, email, phone, hire_date, pay_type, hourly_rate, monthly_salary, is_active |
| StaffCredential | staff_id → username, password_hash, force_reset, last_login_at<br>username → staff_id, password_hash, force_reset, last_login_at |
| Shift | shift_id → staff_id, start_at, end_at, notes |
| SwapRequest | swap_id → shift_id, cover_staff_id, status, created_at |

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
| CustomerOrder | order_id → restaurant_id, customer_id, channel, fulfillment, status, payment_type, tip, created_at, started_at, finished_at, delivery_address, delivery_notes, courier, external_order_ref |
| DineInDetail (from *SeatedAt* and *ServedBy*) | order_id → table_id, server_id, party_size |
| OrderItem | order_item_id → order_id, menu_item_id, quantity, unit_price, notes |
| Review | review_id → order_id, rating, comment, created_at<br>order_id → review_id, rating, comment, created_at |

ASK FOR NEXT SPRINT: Do we need dependencies that do not hold?

ASK FOR NEXT SPRINT: Do we need to identify anomalies in the Original Schema?

#### Staff

##### D1: Staff → Role + Staff

- **Before (original app):** Staff(staff_id, restaurant_id, name, role_name, department, …)
- **FDs:**
  - staff_id → restaurant_id, name, role_name, department, …
  - **restaurant_id, role_name → department** 
- **Problem:** the department was repeated for every employee with the same role.
- **Closures:**
  - {staff_id} = all attributes, so staff_id is a key.
  - {restaurant_id, role_name} = {restaurant_id, role_name, department}, so this is a **BCNF violation**.
- **Decomposition:**
  - A = {restaurant_id, role_name, department}
  - B = {staff_id, restaurant_id, role_name, name, …}
- **After (our ERD):** **Role**(role_id, restaurant_id, role_name, department) and **Staff**(staff_id, role_id, name, …). Since role_id → restaurant_id, Staff does not need restaurant_id anymore. Staff and Role are now connected by the **Holds** relationship.

##### D2: SwapRequest  #ASK THIS FOR THE NEXT SPRINT 

- **Before (original app):** SwapRequest(swap_id, shift_id, staff_id, status, created_at)
- **FDs:**
  - swap_id → shift_id, staff_id, status, created_at
  - **shift_id → staff_id** 
- **Problem:** the staff was stored twice, so the two could disagree.
- **Violation:** {shift_id} = {shift_id, staff_id} 
- **Decomposition:**
  - A = {shift_id, staff_id}, which is already in Shift(shift_id, staff_id)
  - B = {swap_id, shift_id, status, created_at}
- **After (our ERD):** **SwapRequest**(swap_id, shift_id, staff_id, status, created_at). The staff is found through the **Offers** relationship; also added the **Covers** relationship (staff_id) to record who covers the shift.

Note: There are more normalization for this 18 entity sets which ERD reflects them; however, the rest will be completed in this document in the next spring along with left out entity sets.
---


## 8. Implementation

Note: Might get revised!

| File | Contents |
|---|---|
| `sql/schema.sql` | DDL for the 18 relations |
| `sql/seed.sql` | Sample data for two restaurants |
| `sql/demo.sql` | to test to meet with the rubric |

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

| Goal | Current limitation | Success criterion |
|---|---|---|
| **G1.** Complete the ERD: add the out-of-scope part and the data needed by the recommendation (machine learning) features that already exist in the backend | These parts are not in the ERD yet and the database was never adjusted for the machine learning features | Every new requirement appears in the ERD |
| **G2.** Double-check the whole ERD and add (min, max) participation to every relationship | The ERD is not final
| **G3.** Apply Level 3 design techniques
| **G4.** Complete the normalisation: keys, FDs, and BCNF check for the new relations, plus the remaining decompositions of the original schema 
| **G5.** Write the SQL DDL for the new relations and revise the implementation
| **G6.** Fix the cross-restaurant limitation .

### Questions for the TA-client

1. Are the superkeys and candidate keys of DiningTable and Review
2. SwapRequest decomposition (D2) 
3. Should we also list functional dependencies that do not hold?
4. Should we document the anomalies of the original schema in more detail?

---

## 11. Use of Generative AI and Prior Work

**Prior work.** The original Prisma schema and application were written organically by Caner Kaan Balseven during an entrepreneurship co-op term, before this course. Everything in this document and repository is a redesign done for CSC 370.

**Generative AI.**

- **Claude (Anthropic)** was used to review the original schema for anomalies, relations, and draft this document (wording, structure idea and confirming the logic) and the seed.sql and demo.sql. 

**How the team verified the work.** Because the team worked through the functional dependencies and decompositions ourselves, using AI did not replace developing the course competencies. However, I still believe there will be problems about them especially after implementing the whole data entities. I will need to confirm them with TA. Additionally, because it is my idea, technically there is no right or wrong way to do it explicitly; I might need to reestablish the relationships etc. based on what we are going to implement as a functionality to the project. I focused on what we did instead of what we are going to do in this sprint. If there is no time until Sprint 1 for functionality confirmation; I am planning to do it at least until Sprint 2. I believe ERD should not supposed to take this much time in this course but my project is data project at the end of the day so that it will get revised in any time. 

---

## 12. References

- Chester, S. (2026). *CSC 370 lecture slides:* Storing Data with SQL; Retrieving Data with SQL; Conceptual Design; Multiplicity; FDs and Keys; BCNF Decomposition. University of Victoria.

  **Videos**

- making IT simple. (4 years ago - current year 2026). *Functional Dependency in DBMS* [Video]. YouTube. https://youtu.be/fZ41WtisQgo
- making IT simple. (5 years ago - current year 2026). *Normalization in DBMS | Insertion, Updation & Deletion Anomalies* [Video]. YouTube. https://youtu.be/UF0UHCX-z0E
- Decomplexify. (4 years ago - current year 2026). *Learn Database Normalization - 1NF, 2NF, 3NF, 4NF, 5NF* [Video]. YouTube. https://youtu.be/GFQaEYEc8_8
- Decomplexify. (4 years ago - current year 2026). *Learn Boyce-Codd Normal Form (BCNF)* [Video]. YouTube. https://youtu.be/VWnKUKH4tLg

   
