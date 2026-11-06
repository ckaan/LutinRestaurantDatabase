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
| 2.0 | Sprint 1 | October 18, 2026 | see Brightspace submission | Complete ERD (29 entity sets, 35 relationships, (min, max)), inheritance and weak entity sets, 31 relations, decompositions D1–D8, 3NF/4NF checks, projected FDs and minimal bases, schema.sql with foreign keys and NOT NULL |
| 3.0 | Sprint 2 | November 8, 2026 | | |
| 4.0 | Final Submission | November 29, 2026 | | |

<div style="page-break-after: always;"></div>

---

## Table of Contents

- [1. Project Background]
- [2. Sprint 1 Goals]
  - [2.1 Goals and Success Criteria]
  - [2.2 Missed or Partially Met Goals]
  - [2.3 Competency Mapping]
  - [2.4 Previous Sprint (Kickoff) Recap]
  - [2.5 Kickoff Feedback and Fixes]
  - [2.6 Kickoff Questions]
- [3. Requirements]
- [4. Entity-Relationship Diagram]
  - [4.1 Staff and Labour]
  - [4.2 Menu and Inventory]
  - [4.3 Front of House]
  - [4.4 Marketing and Analytics]
  - [4.5 Requirement ↔ ERD Checklist]
- [5. Relational Schema]
- [6. Keys]
- [7. Functional Dependencies and BCNF]
  - [7.1 Functional Dependencies]
  - [7.2 BCNF Decompositions]
  - [7.3 BCNF Verification]
  - [7.5 Third Normal Form and Dependency Preservation]
  - [7.6 Fourth Normal Form and Multivalued Dependencies]
  - [7.7 Projecting FDs and Minimal Bases]
- [8. SQL Queries as Requirements]
- [9. Implementation]
- [10. Known Limitations]
- [11. Next Sprint Goals]
- [12. Use of Generative AI and Prior Work]
- [13. References]

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

The original application has about 35 Prisma models. This sprint completes the design for all parts of the system; the next sprints focus on querying the database (see Section 10).

## 2. Sprint 1 Goals

**Sprint 1: Advanced Relational Design.** Course-level targets: **Data Modelling, Level 3** (design), **Data Modelling, Level 1** (SQL implementation), and **Back-end Engineering, Level 1** (consistency).

These goals were planned at the end of the Kickoff (version 1.0, Section 10). In addition, `schema.sql` in the Kickoff translated the redesigned tables into SQL, starting from the tables of my co-op project. The Kickoff focused on the design (ERD, keys, FDs, BCNF), so constraints such as NOT NULL were not covered yet; they are part of this sprint (G8).

## 2. Sprint 2 Goals

**Sprint 2: Querying the Database.** Course-level targets: **DA** (writing queries from requirements, in relational algebra and SQL), **Data Modelling, Level 3** (constraints and design checks), and **Back-end Engineering, Level 1** (consistency).

These goals were planned at the end of Sprint 1 (version 2.0, Section 11). They also include every goal that Sprint 1 did not fully meet: G6 (cross-restaurant check), G8 (CHECK constraints), and G9 (Kickoff questions 3 and 4).

### 2.1 Goals and Success Criteria

| Goal | From | Limitation it fixes | Competency | Success criterion (measurable) | Status | Evidence |
|---|---|---|---|---|---|---|
| **S2-G1.** Turn the features in Section 3 into query requirements | New (Sprint 1 plan) | Section 3 says what the app shows, but I have not written or tested any query for it yet | DA: translates requirements into queries | I write at least **15** query requirements, each one linked to a feature in Section 3, with at least 3 for every part (Staff and Labour, Menu and Inventory, Front of House, Marketing and Analytics) | *[Met / Not met]* | *[ ]* |
| **S2-G2.** Write each query in relational algebra first, then in SQL | New (Sprint 1 plan) | So far I have only used RA for constraints, not to answer questions about the data | DA: relational algebra; DM L3: constraints in RA | All **15/15** queries have an RA version and an SQL version, and both return the same rows on the sample data | *[Met / Not met]* | *[ ]* |
| **S2-G3.** Create `seed.sql` with realistic data for two restaurants | New (Sprint 1 plan) | I cannot test queries on an empty database | DA; BE L1 | `seed.sql` loads with **0** errors, every query returns at least 1 row, and the expected output of each query is written in the document and matches what the query really returns | *[Met / Not met]* | *[ ]* |
| **S2-G4.** Use advanced SQL where a requirement needs it | New (Sprint 1 plan) | Right now I can only show simple SELECTs | DA: joins, aggregation, subqueries, set operations | Each of these is used in at least one query, with a short reason why it is needed: inner join, outer join, GROUP BY + HAVING, a subquery (IN / EXISTS / NOT EXISTS), a set operation (UNION / set difference), and ORDER BY + LIMIT; every part has at least one aggregate | *[Met / Not met]* | *[ ]* |
| **S2-G5.** Add views for the four dashboards (Owner, Employee, Order-system, Kitchen Display) | New (Sprint 1 plan) | Without views, the app would repeat the same long queries in many places | DA; BE L1 | `schema.sql` has at least **4** views, one for each dashboard, and each one is built from an S2-G1 query | *[Met / Not met]* | *[ ]* |
| **S2-G6.** Finish the constraints: CHECK constraints, the cross-restaurant trigger (G6), the "at least one" triggers (Section 4), and the RA version of each rule | **Sprint 1, G6** (not met), **Sprint 1, G8** (partially met: CHECK constraints), Sprint 1, G5 (test file planned) | The business rules, the cross-restaurant rule, and three (1,n) minimums are not enforced yet (Sections 2.2, 4, 9) | DM L3: constraints in RA; BE L1: database never enters an inconsistent state | At least **20** CHECK constraints for the business rules in Section 3; every key, foreign key, CHECK, and trigger rule written in RA as "query = ∅"; each CHECK and trigger has a test that breaks it, and `tests.sql` shows **0** unexpected results | *[Met / Not met]* | *[ ]* |
| **S2-G7.** Finish the design checks from this sprint's lectures | New (Sprint 1 plan) | I have not checked the FDs implied by every ERD relationship, compared isa styles, or rated the ERD's quality formally | DM L2, DM L3: ERDs to FDs, inheritance, improving conceptual designs | All **35/35** relationships are matched to the FD they imply; both isa hierarchies are compared in 3 styles; the ERD is rated on all 8 Batini criteria with evidence; any new relation added in Sprint 2 is checked for BCNF/3NF | *[Met / Not met]* | *[ ]* |
| **S2-G8.** Answer the last two Kickoff questions: FDs that do not hold, and anomalies of the original schema | **Sprint 1, G9** (partially met: Kickoff questions 3 and 4) | Kickoff questions 3 and 4 are still open (Section 2.6) | DM L2: identifies dependencies and keys; eliminates data anomalies | For every relation with a composite or second key, at least 1 FD that does **not** hold is listed with the reason; update, insertion, and deletion anomalies are shown for at least **3** original models (e.g., D1, D5, D7); all **4/4** Kickoff questions are answered | *[Met / Not met]* | *[ ]* |

*DM = Data Modelling, BE = Back-end Engineering.*

**Note:** Sprint goals are subject to change; about 80% of them are aimed to be met in this sprint.
### 2.2 Goals Carried Over from Sprint 1

| Sprint 1 goal | What was not finished | Sprint 2 goal |
|---|---|---|
| G6 (not met) | The cross-restaurant check | S2-G7 (trigger), checked with Q58 |
| G8 (partially met) | CHECK constraints for business rules | S2-G6 |
| G9 (partially met) | Kickoff questions 3 and 4 | S2-G9 |
| G5 (met, with a follow-up) | A test file for all constraints | S2-G8 |

### 2.3 Competency Mapping

| Competency bullet | Covered by |
|---|---|
| DM L1: Selects appropriate data types for tables | [Section 5](#5-relational-schema), G8 |
| DM L1: Writes SQL code that implements a relational design | [Section 8](#8-implementation) (`schema.sql`: 31 tables, 41 foreign keys), G5, G8 |
| DM L1: Documents relationships with correct ERDs | [Section 4](#4-entity-relationship-diagram), G2 |
| DM L2: Identifies dependencies among attributes and appropriate keys | [Section 6](#6-keys), [Section 7.1](#71-functional-dependencies), [Section 7.5](#75-third-normal-form-and-dependency-preservation) (FDs read from the ERD) |
| DM L2: Eliminates data anomalies with effective normalisation | [Section 7.2](#72-bcnf-decompositions), G4 |
| DM L2: Justifies the quality of a schema through a theoretical lens | [Section 7.3](#73-bcnf-verification), [Section 7.5](#75-third-normal-form-and-dependency-preservation), [Section 7.6](#76-fourth-normal-form-and-multivalued-dependencies), G9 |
| DM L2: Maps requirements onto schemata and vice versa | [Section 3](#3-requirements), [Section 4](#4-entity-relationship-diagram), G1, G2 |
| DM L3: Uses inheritance and weak entity sets when they are more expressive | G3, [Section 4](#4-entity-relationship-diagram), [Section 5](#5-relational-schema) |
| DM L3: Considers the impact of NULL values and inheritance on FDs | G3, [Section 7.2](#72-bcnf-decompositions) (D7), [Section 7.5](#75-third-normal-form-and-dependency-preservation) (N2: clock-ins without a shift) |
| DM L3: Assesses incongruity between conceptual and relational schemata | G6, [Section 7.2](#72-bcnf-decompositions) (D4, D7), [Section 7.5](#75-third-normal-form-and-dependency-preservation) (N1–N3: hidden FDs from ERD relationships) |
| DM L3: Applies alternative normal forms (3NF, 4NF) | G4, [Section 7.5](#75-third-normal-form-and-dependency-preservation) (N1–N3), [Section 7.6](#76-fourth-normal-form-and-multivalued-dependencies) (M1–M2) |
| DM L3: Projects FDs onto sub-relations and finds minimal bases | G4, [Section 7.7](#77-projecting-fds-and-minimal-bases), [Section 7.5](#75-third-normal-form-and-dependency-preservation) (N3: 3NF synthesis) |
| DM L3: Systematically evaluates strengths and weaknesses of a schema | G2, G9, [Section 7.5](#75-third-normal-form-and-dependency-preservation) (BCNF vs. 3NF decisions) |
| BE L1: Ensures a database never enters an inconsistent state | G5 (foreign keys reject invalid references, [Section 8](#8-implementation)), G8 |


### 2.4 Previous Sprint (Kickoff) Recap

The Kickoff (version 1.0) delivered the requirements, the first ERD, the relational schema, keys, FDs, two BCNF decompositions, and `schema.sql`. Three things were not fully met:
- (min, max) participation on the ERD (now G2)
- the remaining decompositions (now G4)
- **success criterion S6 ("the schema rejects invalid data") was not met**: `schema.sql` represented relationships with ID columns (e.g., OrderItem.order_id) but did not declare FOREIGN KEY constraints, so an order item for a non-existent order was accepted. This was missed in the Kickoff's list of partially met goals. It is fixed in this sprint (G5).

The full Kickoff version can be seen at the commit linked in the Version History.

### 2.5 Kickoff Feedback and Fixes

| # | Feedback | Fix | Where |
|---|---|---|---|
| 1 | The plan did not name minimal bases, projecting FDs, or 4NF | Added to G4; projected FDs and minimal bases for every decomposition; 3NF and 4NF checks | G4, Sections 7.5–7.7 |
| 2 | The missing foreign keys were not acknowledged as an unmet goal | Acknowledged in the Kickoff recap as S6 not met | Section 2.4 |
| 3 | No FOREIGN KEY constraints, so invalid data was accepted (S6 not met) | Every relationship column now has FOREIGN KEY ... REFERENCES, so the database rejects a row that points to a non-existent row | G5, `schema.sql` |

### 2.6 Kickoff Questions

| # | Question (Kickoff, Section 10.1) | Status | Answer |
|---|---|---|---|
| 1 | Are the superkeys and candidate keys of DiningTable and Review correct? | Answered | Yes. DiningTable: {table_id}⁺ and {restaurant_id, label}⁺ are all attributes, and neither restaurant_id nor label alone is a superkey, so both are candidate keys. Review: *About* is one-one, so order_id → review_id and {order_id} is a second candidate key, enforced with UNIQUE (order_id) (Sections 6, 7.3) |
| 2 | Is the SwapRequest decomposition (D2) correct? | Answered | Yes, after correcting the FD to shift_id → requester_id. The requester is always the owner of the shift, so it is removed from SwapRequest and comes from Shift.staff_id. The decomposition is dependency preserving (Sections 7.2, 7.5) |
| 3 | Should we also list functional dependencies that do not hold? | Moved to Sprint 2 (S2-G8) | Waiting for the TA-client |
| 4 | Should we document the anomalies of the original schema in more detail? | Moved to Sprint 2 (S2-G8) | Partly done: each decomposition D1–D8 names the violating FD; the full update / insertion / deletion examples wait for the TA-client |


---
## 3. Requirements

The requirements are grouped into the four parts of the system. For each part, the left column lists what the system must let people do, and the right column lists the data the database must store to support it. The ERD in Section 4 shows the entity sets and relationships those data requirements produced.

### 3.1 Staff and Labour

<table>
<tr><th>Requirements / Features</th><th>Corresponding Data Requirements</th></tr>
<tr>
<td valign="top">
<ul>
<li>Several restaurants use the same system, each seeing only its own data</li>
<li>Managers create roles (Server, Line Cook, …) and assign each to a department</li>
<li>Managers add, edit, and deactivate staff</li>
<li>Show which department each staff member works in</li>
<li>Staff are paid either hourly or with a monthly salary</li>
<li>Staff log in to the app; new accounts must reset their password</li>
<li>Managers schedule shifts</li>
<li>Staff view their own schedule</li>
<li>Staff offer a shift for a swap</li>
<li>A coworker volunteers to cover an offered shift</li>
<li>Managers approve or deny swaps</li>
<li>Staff clock in and out of their shifts and log their breaks</li>
<li>Staff request time off; managers approve or reject it</li>
<li>Calculate each staff member's pay for a pay period, including bonuses and deductions</li>
<li>Managers set how many staff each department needs for a time slot</li>
<li>Warn when a shift has fewer staff than needed</li>
</ul>
</td>
<td valign="top">
<ul>
<li>Restaurants with id's</li>
<li>Roles of each restaurant, with their department</li>
<li>Staff with id's, contact details, hire date, and active status</li>
<li>Hourly staff with their hourly rate; salaried staff with their monthly salary</li>
<li>Login credentials for staff who use the app</li>
<li>Shifts: who works, start and end time</li>
<li>Swap requests: which shift, who covers, who decided, status</li>
<li>Time clock events: who, which shift, event type, time</li>
<li>Time-off requests: who, dates, hours, reason, who decided, status</li>
<li>Pay records: who, pay period, hours worked, rate at that time, bonus, deductions</li>
<li>Staffing requirements: date, time slot, department, number of staff needed</li>
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
<li>Send orders to the kitchen display as tickets, in one or more batches</li>
<li>Mark a ticket as priority and track it from new to ready</li>
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
<li>Orders: restaurant, channel, status, payment, tip, timestamps</li>
<li>Dine-in details: table, server, party size</li>
<li>Delivery details: address, notes, courier, external reference</li>
<li>Kitchen tickets: which order, batch number, status, priority, timestamps</li>
<li>Order lines: dish, quantity, price at time of sale, notes, which ticket</li>
<li>Reviews: rating and comment, at most one per order</li>
</ul>
</td>
</tr>
</table>

### 3.4 Marketing and Analytics

<table>
<tr><th>Requirements / Features</th><th>Corresponding Data Requirements</th></tr>
<tr>
<td valign="top">
<ul>
<li>Managers create marketing campaigns with a budget and dates</li>
<li>A campaign promotes one or more menu items</li>
<li>Managers post announcements (info, warning, promo) to the staff dashboard</li>
<li>Hide announcements that are no longer active</li>
<li>Store the daily weather for each restaurant</li>
<li>Use sales, labour, and weather data to generate recommendations for the owner/manager</li>
<li>Show recommendations until they expire</li>
</ul>
</td>
<td valign="top">
<ul>
<li>Campaigns: restaurant, name, start and end date, budget</li>
<li>Which menu items each campaign promotes</li>
<li>Announcements: author (the restaurant comes from the author), message, type, active status, time</li>
<li>Weather observations: restaurant, date, max and min temperature, condition, precipitation</li>
<li>Insights: restaurant, title, message, type, created and expiry time</li>
</ul>
</td>
</tr>
</table>

### 3.5 Out of Scope

**Not covered this sprint:** the cross-restaurant check (moved to Sprint 2, see Section 2.2, G6), and CHECK constraints (Sprint 2, G8). Payment processing itself (card transactions) is handled by an outside provider, so the database only stores the payment type.


---

## 4. Entity-Relationship Diagram

![Full ERD](figures/full_erd.jpg)

| Symbol | Meaning |
|---|---|
| Rectangle | Entity set |
| Ellipse | Attribute; an **underlined** attribute is the entity set's identifier |
| Diamond | Relationship; an ellipse attached to a diamond is a relationship attribute |
| Triangle (ISA) | Inheritance; the subclass gets the superclass identifier and adds its own attributes |
| "Weak Entity" label on a diamond | Identifying relationship of a weak entity set |
| Arrowhead into an entity set | "At most one" on that side of the relationship |
| No arrowhead | "Many" on that side |
| Arrowheads on both sides | One-one relationship |

The ERD figure shows multiplicity with arrowheads; the (min, max) participation of every relationship is given in the tables below. The values follow the requirements in Section 3 and match `schema.sql`:
- a foreign key that is NOT NULL gives **(1,1)** on that side
- a foreign key that can be NULL gives **(0,1)**
- the other side is **(0,n)**, unless a requirement says "at least one", which gives **(1,n)**

The diagram has **29 entity sets** (16 from the Kickoff + 13 new), **35 relationships**, and **2 isa hierarchies**. The two many-many relationships (*Uses* and *Promotes*) become the mapping relations RecipeLine and CampaignItem, so the ERD maps to the **31 relations** in Section 5.

### 4.1 Staff and Labour

**Requirements covered:** [Section 3.1]

**Entity sets**

| Entity set | Identifier | Represents |
|---|---|---|
| Restaurant | restaurant_id | A restaurant using the system |
| Role *(weak)* | restaurant_id + role_name | A job title defined by a restaurant, such as Server or Line Cook |
| Staff | staff_id | An employee of a restaurant |
| HourlyStaff *(isa Staff)* | staff_id (inherited) | A staff member paid by the hour |
| SalariedStaff *(isa Staff)* | staff_id (inherited) | A staff member paid a monthly salary |
| StaffCredential | username | The login details of a staff member who uses the app |
| Shift | shift_id | A scheduled block of work for one staff member |
| SwapRequest | swap_id | An offer to give away a shift, possibly covered by someone else |
| TimeClockEvent | event_id | One clock-in, clock-out, or break punch |
| TimeOffRequest | request_id | A staff member's request for days off |
| PayRecord | pay_record_id | The pay of one staff member for one pay period |
| StaffingRequirement | requirement_id | How many staff a department needs for a time slot on a date |

**Relationships**

| Relationship | Reads as | Multiplicity | (min, max) |
|---|---|---|---|
| Defines *(weak entity)* | A restaurant defines roles | many-one | Role (1,1) · Restaurant (0,n) |
| Holds | A staff member holds a role | many-one | Staff (1,1) · Role (0,n) |
| isa | A staff member is either hourly or salaried | isa | — |
| HasLogin | A staff member has a login | one-one | StaffCredential (1,1) · Staff (0,1) |
| Works | A shift is worked by a staff member | many-one | Shift (1,1) · Staff (0,n) |
| Offers | A swap request offers a shift | many-one | SwapRequest (1,1) · Shift (0,n) |
| Covers | A staff member covers a swap request | many-one | SwapRequest (0,1) · Staff (0,n) |
| DecidesSwap | A manager approves or denies a swap request | many-one | SwapRequest (0,1) · Staff (0,n) |
| Clocks | A staff member logs time clock events | many-one | TimeClockEvent (1,1) · Staff (0,n) |
| Punches | A time clock event is punched for a shift | many-one | TimeClockEvent (0,1) · Shift (0,n) |
| Requests | A staff member makes time-off requests | many-one | TimeOffRequest (1,1) · Staff (0,n) |
| DecidesTimeOff | A manager approves or rejects a time-off request | many-one | TimeOffRequest (0,1) · Staff (0,n) |
| PaidTo | A pay record is paid to a staff member | many-one | PayRecord (1,1) · Staff (0,n) |
| Needs | A restaurant needs staffing requirements | many-one | StaffingRequirement (1,1) · Restaurant (0,n) |

### 4.2 Menu and Inventory

**Requirements covered:** [Section 3.2]

**Entity sets**

| Entity set | Identifier | Represents |
|---|---|---|
| MenuCategory | category_id | A section of a restaurant's menu, such as Mains or Drinks |
| MenuItem | menu_item_id | A dish or drink that can be ordered |
| InventoryItem | inventory_item_id | An ingredient or supply the restaurant keeps in stock |
| StockMovement | movement_id | One logged change to the quantity of an inventory item |

**Relationships**

| Relationship | Reads as | Multiplicity | (min, max) |
|---|---|---|---|
| HasMenu | A restaurant has menu categories | many-one | MenuCategory (1,1) · Restaurant (0,n) |
| InCategory | A menu item is in a category | many-one | MenuItem (1,1) · MenuCategory (0,n) |
| HasInventory | A restaurant has inventory items | many-one | InventoryItem (1,1) · Restaurant (0,n) |
| Uses | A menu item uses inventory items (attribute: `qty_per_serving`) | many-many | MenuItem (0,n) · InventoryItem (0,n) |
| Moves | A stock movement changes an inventory item | many-one | StockMovement (1,1) · InventoryItem (0,n) |

### 4.3 Front of House

**Requirements covered:** [Section 3.3]

**Entity sets**

| Entity set | Identifier | Represents |
|---|---|---|
| DiningTable | table_id | A physical table in a restaurant |
| Customer | customer_id | A person who orders or reserves |
| Reservation | reservation_id | A booking of a table for a date, time, and name |
| CustomerOrder | order_id | An order placed at a restaurant |
| DineInOrder *(isa CustomerOrder)* | order_id (inherited) | An order eaten at a table |
| DeliveryOrder *(isa CustomerOrder)* | order_id (inherited) | An order delivered to an address, in-house or by Uber Eats |
| KitchenTicket | ticket_id | One batch of an order sent to the kitchen display |
| OrderItem *(weak)* | order_id + line_no | One line of an order |
| Review | review_id | A customer's rating of an order |

**Relationships**

| Relationship | Reads as | Multiplicity | (min, max) |
|---|---|---|---|
| HasTable | A restaurant has tables | many-one | DiningTable (1,1) · Restaurant (0,n) |
| BookedBy | A reservation is booked by a customer | many-one | Reservation (1,1) · Customer (0,n) |
| BookedAt | A reservation is booked at a table | many-one | Reservation (1,1) · DiningTable (0,n) |
| Receives | A restaurant receives orders | many-one | CustomerOrder (1,1) · Restaurant (0,n) |
| Orders | A customer places an order | many-one | CustomerOrder (0,1) · Customer (0,n) |
| isa | An order can be a dine-in order or a delivery order (pickup orders need no extra attributes) | isa | — |
| SeatedAt | A dine-in order is seated at a table (attribute: `party_size`) | many-one | DineInOrder (1,1) · DiningTable (0,n) |
| ServedBy | A dine-in order is served by a staff member | many-one | DineInOrder (0,1) · Staff (0,n) |
| Contains *(weak entity)* | An order contains order items | many-one | OrderItem (1,1) · CustomerOrder (1,n) |
| OfItem | An order item is of a menu item | many-one | OrderItem (1,1) · MenuItem (0,n) |
| ForOrder | A kitchen ticket is for an order | many-one | KitchenTicket (1,1) · CustomerOrder (0,n) |
| OnTicket | An order item is on a kitchen ticket | many-one | OrderItem (0,1) · KitchenTicket (1,n) |
| About | A review is about an order | one-one | Review (1,1) · CustomerOrder (0,1) |

### 4.4 Marketing and Analytics

**Requirements covered:** [Section 3.4]

**Entity sets**

| Entity set | Identifier | Represents |
|---|---|---|
| Campaign | campaign_id | A marketing campaign run by a restaurant |
| Announcement | announcement_id | A message posted to the staff dashboard |
| WeatherObservation *(weak)* | restaurant_id + observed_date | The weather at a restaurant on one day, used by the recommendation features |
| Insight | insight_id | A recommendation generated for the owner/manager |

**Relationships**

| Relationship | Reads as | Multiplicity | (min, max) |
|---|---|---|---|
| Runs | A restaurant runs campaigns | many-one | Campaign (1,1) · Restaurant (0,n) |
| Promotes | A campaign promotes menu items | many-many | Campaign (1,n) · MenuItem (0,n) |
| PostedBy | An announcement is posted by a staff member | many-one | Announcement (1,1) · Staff (0,n) |
| RecordedFor *(weak entity)* | A weather observation is recorded for a restaurant | many-one | WeatherObservation (1,1) · Restaurant (0,n) |
| Generates | Insights are generated for a restaurant | many-one | Insight (1,1) · Restaurant (0,n) |

**Design decisions**

- **Inheritance (isa).** Staff is split into HourlyStaff and SalariedStaff, and CustomerOrder into DineInOrder and DeliveryOrder. Each subclass only holds its own attributes, so the 6 attributes that had to be NULL for some rows are gone (G3). Pickup orders have no extra attributes, so they stay as plain CustomerOrder rows.
- **SeatedAt and ServedBy** belong to DineInOrder, because only dine-in orders have a table and a server.
- **Weak entity sets.** A role name (Server) is only unique inside one restaurant, an order line number is only unique inside one order, and there is one weather observation per restaurant per day. So Role, OrderItem, and WeatherObservation are identified through their owner.
- **Staff in two roles.** SwapRequest is connected to Staff twice (*Covers* and *DecidesSwap*), so the foreign keys get different names: cover_staff_id and decided_by.
- **Derived values are not stored.** Stock levels, order totals, and gross pay are calculated from other data instead of being stored.
- **Kitchen tickets.** An order can be sent to the kitchen in more than one batch, so KitchenTicket is its own entity set and each order item points to the ticket it is on.
- **Analytics data.** WeatherObservation and Insight store the data the machine learning features in the backend already use, so the database now matches the backend.
- **No *Posts* relationship.** An announcement is connected to its restaurant through its author (*PostedBy* → Staff → Restaurant). A direct *Posts* relationship would store the same fact twice and was a 3NF violation, so it was removed.
- **Participation that SQL cannot enforce.** Contains (an order has at least one item), OnTicket (a ticket has at least one item), and Promotes (a campaign promotes at least one menu item) have a minimum of 1 that `schema.sql` cannot enforce, because the parent row is inserted before its children. They are planned as triggers in Sprint 2 (S2-G6).


### 4.5 Requirement ↔ ERD Checklist

Every data requirement in Section 3 is matched to the ERD, and every entity set and relationship is used by at least one requirement.

| Section | Data requirement | Entity sets | Relationships |
|---|---|---|---|
| 3.1 | Restaurants with id's | Restaurant | — |
| 3.1 | Roles of each restaurant, with their department | Role | Defines |
| 3.1 | Staff with id's, contact details, hire date, and active status | Staff | Holds |
| 3.1 | Hourly staff with their hourly rate; salaried staff with their monthly salary | HourlyStaff, SalariedStaff | isa |
| 3.1 | Login credentials for staff who use the app | StaffCredential | HasLogin |
| 3.1 | Shifts: who works, start and end time | Shift | Works |
| 3.1 | Swap requests: which shift, who covers, who decided, status | SwapRequest | Offers, Covers, DecidesSwap |
| 3.1 | Time clock events: who, which shift, event type, time | TimeClockEvent | Clocks, Punches |
| 3.1 | Time-off requests: who, dates, hours, reason, who decided, status | TimeOffRequest | Requests, DecidesTimeOff |
| 3.1 | Pay records: who, pay period, hours worked, rate at that time, bonus, deductions | PayRecord | PaidTo |
| 3.1 | Staffing requirements: date, time slot, department, number of staff needed | StaffingRequirement | Needs |
| 3.2 | Menu categories with display order | MenuCategory | HasMenu |
| 3.2 | Menu items with price and availability | MenuItem | InCategory |
| 3.2 | Inventory items with unit, par level, and lead time | InventoryItem | HasInventory |
| 3.2 | Recipes: quantity of each ingredient per dish | — | Uses (`qty_per_serving`) |
| 3.2 | Stock movements: type, amount, cost, reason, time | StockMovement | Moves |
| 3.3 | Dining tables with label, seats, and section | DiningTable | HasTable |
| 3.3 | Customers with id's and a unique phone number | Customer | — |
| 3.3 | Reservations: who, which table, when, party size | Reservation | BookedBy, BookedAt |
| 3.3 | Orders: restaurant, channel, status, payment, tip, timestamps | CustomerOrder | Receives, Orders |
| 3.3 | Dine-in details: table, server, party size | DineInOrder | isa, SeatedAt, ServedBy |
| 3.3 | Delivery details: address, notes, courier, external reference | DeliveryOrder | isa |
| 3.3 | Kitchen tickets: which order, batch number, status, priority, timestamps | KitchenTicket | ForOrder |
| 3.3 | Order lines: dish, quantity, price at time of sale, notes, which ticket | OrderItem | Contains, OfItem, OnTicket |
| 3.3 | Reviews: rating and comment, at most one per order | Review | About |
| 3.4 | Campaigns: restaurant, name, start and end date, budget | Campaign | Runs |
| 3.4 | Which menu items each campaign promotes | — | Promotes |
| 3.4 | Announcements: author (the restaurant comes from the author), message, type, active status, time | Announcement | PostedBy |
| 3.4 | Weather observations: restaurant, date, max and min temperature, condition, precipitation | WeatherObservation | RecordedFor |
| 3.4 | Insights: restaurant, title, message, type, created and expiry time | Insight | Generates |

**Result:** 30/30 data requirements matched; 29/29 entity sets and 35/35 relationships used by at least one requirement.

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
- Announcement(<ins>announcement_id</ins>: INT, author_id: INT → Staff, message: TEXT, announcement_type: ENUM('INFO', 'WARNING', 'PROMO'), is_active: BOOLEAN, created_at: DATETIME)
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
| TimeClockEvent | {event_id}, {staff_id, occurred_at} | event_id | any set containing event_id, *or* containing both staff_id and occurred_at | shift_id, event_type, note |
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
| Announcement | {announcement_id} | announcement_id | any set containing announcement_id | author_id, message, announcement_type, is_active, created_at |
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
| Announcement | announcement_id → author_id, message, announcement_type, is_active, created_at |
| WeatherObservation | restaurant_id, observed_date → temp_max, temp_min, condition, precipitation_mm |
| Insight | insight_id → restaurant_id, title, message, insight_type, created_at, expires_at |

FDs that do not hold and the anomalies of the original schema are planned for Sprint 2 (Section 2.6, S2-G8).

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
| TimeClockEvent | {event_id}⁺ = all attributes<br>{staff_id, occurred_at}⁺ = all attributes<br>{shift_id}⁺ = {shift_id, staff_id} | 3NF |
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
| OrderItem | {order_id, line_no}⁺ = all attributes<br>{ticket_id}⁺ = {ticket_id, order_id} (hidden FD from the ERD) | 3NF  |
| Review | {review_id}⁺ = all attributes<br>{order_id}⁺ = all attributes | ✓ |

**Marketing and Analytics**

| Relation | Closures of FD left sides | BCNF |
|---|---|---|
| Campaign | {campaign_id}⁺ = all attributes | ✓ |
| CampaignItem | no non-trivial FDs (all attributes form the key) | ✓ |
| Announcement | {announcement_id}⁺ = all attributes | ✓ |
| WeatherObservation | {restaurant_id, observed_date}⁺ = all attributes | ✓ |
| Insight | {insight_id}⁺ = all attributes | ✓ |

### 7.5 Third Normal Form and Dependency Preservation

**Definitions**

- **Prime attribute:** an attribute that is part of some candidate key (a key, not just a superkey).
- **3NF:** an FD X → Y is in 3NF if X is a superkey, *or* every attribute in Y is prime. A relation is in 3NF if all of its FDs are in 3NF.
- **Dependency preserving:** after a decomposition, every original FD can still be checked inside one relation, without a join.

Every relation in BCNF is also in 3NF. All decompositions D1–D8 are dependency preserving: in each one, the violating FD goes into R1, where its left side becomes the key, and the original key stays in R2 with everything it determines. So no FD was lost.

**FDs read from the ERD.** Every many-one relationship from E to F gives the FD E's identifier → F's identifier. When a relation holds both E's identifier and F's identifier but is not E itself, this FD can be a hidden BCNF violation. Checking every relation this way found three FDs that are not in 7.1:

| Relation | Hidden FD | Comes from | Result |
|---|---|---|---|
| OrderItem | ticket_id → order_id | *ForOrder* | In 3NF (N1) |
| TimeClockEvent | shift_id → staff_id | *Works* | In 3NF (N2) |
| Announcement | author_id → restaurant_id | Staff → Restaurant | Not in 3NF, fixed |

#### N1: OrderItem (kept in 3NF)

| Letter | A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|---|
| Attribute | order_id | line_no | menu_item_id | ticket_id | quantity | unit_price | notes |

- **FDs:** A, B → C, D, E, F, G and D → A (a kitchen ticket belongs to one order)
- **Closures:**
  - {A, B}⁺ = {A, B, C, D, E, F, G}, so {A, B} is a key
  - {D}⁺ = {D, A}, not all attributes, so **D → A is a BCNF violation**
- **3NF check:** A (order_id) is part of the key {A, B}, so A is prime. So **D → A is in 3NF**.
- **What BCNF decomposition would do:**
  - R1 = {D}⁺ = {D, A}
  - R2 = {B, C, D, E, F, G}
  - The FD A, B → C, D, E, F, G is lost, because A and B are no longer in the same relation. The rule "a line number is unique inside an order" could then only be checked with a join.
- **Decision:** keep OrderItem in 3NF. The redundancy is small (order_id is repeated once per line, and it is already part of the key), and the key stays enforceable with a PRIMARY KEY.

#### N2: TimeClockEvent (kept in 3NF)

| Letter | A | B | C | D | E | F |
|---|---|---|---|---|---|---|
| Attribute | event_id | staff_id | shift_id | event_type | occurred_at | note |

- **FDs:** A → B, C, D, E, F and C → B (a shift is worked by one staff member) and B, E → A (a staff member cannot punch twice at the same moment)
- **Closures:**
  - {A}⁺ = {A, B, C, D, E, F}, so A is a key
  - {B, E}⁺ = {B, E, A, C, D, F}, so {B, E} is also a key
  - {C}⁺ = {C, B}, not all attributes, so **C → B is a BCNF violation**
- **3NF check:** B (staff_id) is part of the key {B, E}, so B is prime. So **C → B is in 3NF**.
- **What BCNF decomposition would do:**
  - R1 = {C}⁺ = {C, B}, which is already in Shift
  - R2 = {A, C, D, E, F}
  - The FD B, E → A is lost, and so is staff_id. A staff member who clocks in without a scheduled shift (shift_id is empty) could not be recorded at all.
- **Decision:** keep TimeClockEvent in 3NF, because unscheduled clock-ins are a real case in the restaurant.

#### N3: Announcement (3NF synthesis, fixed)

| Letter | A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|---|
| Attribute | announcement_id | restaurant_id | author_id | message | announcement_type | is_active | created_at |

- **FDs:** A → B, C, D, E, F, G and C → B (a staff member works at one restaurant)
- **Closures:**
  - {A}⁺ = {A, B, C, D, E, F, G}, so A is the only key
  - {C}⁺ = {C, B}, not all attributes, so **C → B is a BCNF violation**
- **3NF check:** B (restaurant_id) is not part of any key, so B is not prime. So **C → B is a 3NF violation too**.
- **3NF synthesis:**
  1. **Minimal basis:** split the right sides into single attributes: A → B, A → C, A → D, A → E, A → F, A → G, C → B. A → B can be removed, because A → C and C → B already give it. Minimal basis G = {A → C, A → D, A → E, A → F, A → G, C → B}.
  2. **One relation per left side:** R1 = {A, C, D, E, F, G} and R2 = {C, B}.
  3. **Key check:** R1 contains the key A, so no extra relation is needed.
  4. R2 = {author_id, restaurant_id} is already in Staff (staff_id → restaurant_id).
- **After:** **Announcement**(announcement_id, author_id, message, announcement_type, is_active, created_at). restaurant_id and the *Posts* relationship are removed, because the restaurant comes from the author. Done in Sprint 1.

**Summary:** 29 relations in BCNF and 2 relations (OrderItem, TimeClockEvent) in 3NF on purpose. All 31 relations are at least in 3NF.

### 7.6 Fourth Normal Form and Multivalued Dependencies

**Definitions**

- **Multivalued dependency (MVD):** X ↠ Y means that for one value of X, the set of Y values does not depend on the other attributes.
- **4NF:** for every non-trivial MVD X ↠ Y, X is a superkey. A relation in 4NF is also in BCNF.

#### M1: Uses + Promotes in one table (4NF violation avoided)

If the two many-many relationships *Uses* and *Promotes* were stored in one table:

| menu_item_id | inventory_item_id | campaign_id |
|---|---|---|
| 1 (Burger) | 10 (Beef) | 100 (Summer) |
| 1 (Burger) | 10 (Beef) | 101 (Student) |
| 1 (Burger) | 11 (Bun) | 100 (Summer) |
| 1 (Burger) | 11 (Bun) | 101 (Student) |

- There are no non-trivial FDs, so the table is in BCNF, but **menu_item_id ↠ inventory_item_id** and **menu_item_id ↠ campaign_id**.
- Every ingredient has to be repeated for every campaign (2 × 2 = 4 rows). Adding a third campaign adds 2 rows instead of 1.
- **4NF decomposition on menu_item_id ↠ inventory_item_id:**
  - R1 = {menu_item_id, inventory_item_id}, which becomes RecipeLine
  - R2 = {menu_item_id, campaign_id}, which becomes CampaignItem
- **After:** **RecipeLine**(menu_item_id, inventory_item_id, qty_per_serving) and **CampaignItem**(campaign_id, menu_item_id), the design in Section 5.

#### M2: Order items and prep batches (looks like an MVD, but is not)

| order_id | menu_item_id | batch_no |
|---|---|---|
| 50 | Burger | 1 |
| 50 | Fries | 1 |
| 50 | Dessert | 2 |

- An order has many items and many batches, so it looks like order_id ↠ menu_item_id and order_id ↠ batch_no.
- **But this is not an MVD.** For an MVD, every item would have to appear with every batch (Dessert in batch 1 *and* 2). In a real kitchen, each item is cooked in **one specific** batch, so the two facts are not independent.
- So the correct model is an FD, not an MVD: each order line points to its ticket, order_id, line_no → ticket_id (*OnTicket*). This is why KitchenTicket is its own entity set instead of a list inside the order.

**4NF check:** apart from the case avoided in M1, no relation in Section 5 stores two independent multi-valued facts about the same key, so there are no non-trivial MVDs. Every relation in BCNF is therefore also in 4NF.

### 7.7 Projecting FDs and Minimal Bases

**Definitions**

- **Projecting FDs:** after splitting R into R1 and R2, the FDs of each Ri are found by computing the closure of every subset of Ri's attributes (using *all* the original FDs), keeping only the attributes that are in Ri, and removing trivial FDs.
- **Minimal basis:** a set of FDs where (1) every right side is a single attribute, (2) no FD can be removed, and (3) no attribute can be removed from a left side, without changing the closures.

#### Worked example: D4 PayRecord

R(A, B, C, D, E, F, G, H) with FDs A → B, C, D, E, F, G, H and C, D → E and E, F, G → H.

**Step 1: decompose on C, D → E**
- R1 = {C, D}⁺ = {C, D, E}
- R2 = {A, B, C, D, F, G, H}

**Step 2: project the FDs onto R2**
- {A}⁺ = all attributes → A → B, C, D, F, G, H
- {C, D}⁺ = {C, D, E} → only {C, D} is in R2, so it is trivial
- {C, D, F, G}⁺ = {C, D, E, F, G, H} → in R2 this gives **C, D, F, G → H**
- No smaller set determines H ({C, D, F}⁺, {D, F, G}⁺, … do not contain E, so H cannot be reached)

This FD is easy to miss: E, F, G → H cannot be used directly in R2 because E is gone, but projecting finds it through C, D → E.

**Step 3: minimal basis of R2**
- Split: A → B, A → C, A → D, A → F, A → G, A → H, C, D, F, G → H
- A → H can be removed, because A → C, A → D, A → F, A → G and C, D, F, G → H already give it
- F2 = {A → B, A → C, A → D, A → F, A → G, C, D, F, G → H}

**Step 4: check R2 again**
- {C, D, F, G}⁺ in R2 = {C, D, F, G, H}, not all attributes, so it is a BCNF violation
- Decompose: R21 = {C, D, F, G, H} (total pay is arithmetic, so it is not stored) and R22 = {A, B, C, D, F, G}
- R22 is the final **PayRecord**. R1 (gross pay) is also arithmetic and is not stored.
  
#### Minimal bases of all relations


**Staff and Labour**

| Relation | Letters | Minimal basis | Removed as redundant | Left sides reduced? |
|---|---|---|---|---|
| Restaurant | A = restaurant_id, B = name, C = address, D = phone, E = currency | A → B, C, D, E | none | single attribute |
| Role | A = restaurant_id, B = role_name, C = department | A, B → C | none | A or B alone does not determine C |
| Staff | A = staff_id, B = restaurant_id, C = role_name, D = name, E = email, F = phone, G = hire_date, H = is_active | A → B, C, D, E, F, G, H | none | single attribute |
| HourlyStaff | A = staff_id, B = hourly_rate | A → B | none | single attribute |
| SalariedStaff | A = staff_id, B = monthly_salary | A → B | none | single attribute |
| StaffCredential | A = staff_id, B = username, C = password_hash, D = force_reset, E = last_login_at | A → B, C, D, E<br>B → A | B → C, D, E (given by B → A and A → C, D, E) | single attributes |
| Shift | A = shift_id, B = staff_id, C = start_at, D = end_at, E = notes | A → B, C, D, E | none | single attribute |
| SwapRequest | A = swap_id, B = shift_id, C = cover_staff_id, D = decided_by, E = status, F = created_at | A → B, C, D, E, F | none | single attribute |
| TimeClockEvent | A = event_id, B = staff_id, C = shift_id, D = event_type, E = occurred_at, F = note | A → C, D, E, F<br>C → B<br>B, E → A | A → B (given by A → C and C → B) | B or E alone does not determine A |
| TimeOffRequest | A = request_id, B = staff_id, C = decided_by, D = start_date, E = end_date, F = hours, G = reason, H = status, I = created_at | A → B, C, D, E, F, G, H, I | none | single attribute |
| PayRecord | A = pay_record_id, B = staff_id, C = period_start, D = period_end, E = hours_worked, F = rate_snapshot, G = bonus, H = deductions | A → B, C, D, E, F, G, H<br>B, C → A | B, C → D, E, F, G, H (given by B, C → A) | B or C alone does not determine A |
| StaffingRequirement | A = requirement_id, B = restaurant_id, C = work_date, D = start_time, E = end_time, F = department, G = required_count | A → B, C, D, E, F, G<br>B, C, D, F → A | B, C, D, F → E, G (given by B, C, D, F → A) | no subset of {B, C, D, F} determines A |

**Menu and Inventory**

| Relation | Letters | Minimal basis | Removed as redundant | Left sides reduced? |
|---|---|---|---|---|
| MenuCategory | A = category_id, B = restaurant_id, C = name, D = sort_order | A → B, C, D<br>B, C → A | B, C → D (given by B, C → A) | B or C alone does not determine A |
| MenuItem | A = menu_item_id, B = category_id, C = name, D = price, E = is_available | A → B, C, D, E<br>B, C → A | B, C → D, E (given by B, C → A) | B or C alone does not determine A |
| InventoryItem | A = inventory_item_id, B = restaurant_id, C = name, D = unit, E = par_level, F = lead_time_days | A → B, C, D, E, F<br>B, C → A | B, C → D, E, F (given by B, C → A) | B or C alone does not determine A |
| RecipeLine | A = menu_item_id, B = inventory_item_id, C = qty_per_serving | A, B → C | none | A or B alone does not determine C (the quantity depends on both the dish and the ingredient) |
| StockMovement | A = movement_id, B = inventory_item_id, C = movement_type, D = quantity_delta, E = unit_cost, F = reason, G = occurred_at | A → B, C, D, E, F, G | none | single attribute |

**Front of House**

| Relation | Letters | Minimal basis | Removed as redundant | Left sides reduced? |
|---|---|---|---|---|
| DiningTable | A = table_id, B = restaurant_id, C = label, D = seats, E = section | A → B, C, D, E<br>B, C → A | B, C → D, E (given by B, C → A) | B or C alone does not determine A |
| Customer | A = customer_id, B = name, C = phone, D = email | A → B, C, D<br>C → A | C → B, D (given by C → A) | single attributes |
| Reservation | A = reservation_id, B = table_id, C = customer_id, D = reserved_for, E = party_size, F = status | A → B, C, D, E, F<br>B, D → A | B, D → C, E, F (given by B, D → A) | B or D alone does not determine A |
| CustomerOrder | A = order_id, B = restaurant_id, C = customer_id, D = channel, E = status, F = payment_type, G = tip, H = created_at, I = started_at, J = finished_at | A → B, C, D, E, F, G, H, I, J | none | single attribute |
| DineInOrder | A = order_id, B = table_id, C = server_id, D = party_size | A → B, C, D | none | single attribute |
| DeliveryOrder | A = order_id, B = delivery_address, C = delivery_notes, D = courier, E = external_order_ref | A → B, C, D, E | none | single attribute |
| KitchenTicket | A = ticket_id, B = order_id, C = batch_no, D = status, E = is_priority, F = created_at, G = completed_at | A → B, C, D, E, F, G<br>B, C → A | B, C → D, E, F, G (given by B, C → A) | B or C alone does not determine A |
| OrderItem | A = order_id, B = line_no, C = menu_item_id, D = ticket_id, E = quantity, F = unit_price, G = notes | A, B → C, D, E, F, G<br>D → A | none | A or B alone does not determine the line |
| Review | A = review_id, B = order_id, C = rating, D = comment, E = created_at | A → B, C, D, E<br>B → A | B → C, D, E (given by B → A) | single attributes |

**Marketing and Analytics**

| Relation | Letters | Minimal basis | Removed as redundant | Left sides reduced? |
|---|---|---|---|---|
| Campaign | A = campaign_id, B = restaurant_id, C = name, D = start_date, E = end_date, F = budget | A → B, C, D, E, F | none | single attribute |
| CampaignItem | A = campaign_id, B = menu_item_id | ∅ (no non-trivial FDs) | — | — |
| Announcement | A = announcement_id, B = author_id, C = message, D = announcement_type, E = is_active, F = created_at | A → B, C, D, E, F | none (restaurant_id was removed in Section 7.5, N3) | single attribute |
| WeatherObservation | A = restaurant_id, B = observed_date, C = temp_max, D = temp_min, E = condition, F = precipitation_mm | A, B → C, D, E, F | none | A or B alone does not determine C, D, E, F (the weather depends on both the restaurant and the date) |
| Insight | A = insight_id, B = restaurant_id, C = title, D = message, E = insight_type, F = created_at, G = expires_at | A → B, C, D, E, F, G | none | single attribute |

---


---

### 8. SQL Queries as Requirements

### Query Requirements (S2-G1)

Each query requirement is written as a sentence and linked to the feature in Section 3 that needs it. To turn a requirement into a query, I follow the What / Where / How steps from the lectures: **what** the output should show (SELECT / π), **where** the data comes from (FROM / JOIN / ⋈), and **how** the rows are chosen and grouped (WHERE / HAVING / σ, GROUP BY / γ). The last column names the technique from the lectures that the query needs.

#### Staff and Labour

| # | Query requirement | Feature (Section 3.1) | Tables | Technique |
|---|---|---|---|---|
| Q1 | List every active staff member of a restaurant with their role and department. | Show which department each staff member works in | Staff, Role | Join on (restaurant_id, role_name) (⋈), WHERE (σ) |
| Q2 | Find the active staff members who have no shift scheduled next week. | Managers schedule shifts | Staff, Shift | Correlated NOT EXISTS (set difference ∖) |
| Q3 | Show one staff member's shifts for the coming week, earliest first. | Staff view their own schedule | Shift | WHERE on a date range (σ), ORDER BY |
| Q4 | List the pending swap requests with the shift time, the staff member who offered it, and the coworker who volunteered to cover it (if anyone has). | Managers approve or deny swaps | SwapRequest, Shift, Staff (twice) | Staff joined twice with renaming (ρ / AS), LEFT JOIN for requests with no cover yet |
| Q5 | Show the time-off requests that are still pending, oldest first, with the staff member's name. | Staff request time off; managers approve or reject it | TimeOffRequest, Staff | Join (⋈), WHERE (σ), ORDER BY |
| Q6 | Calculate the pay of each staff member for a pay period (hours worked × rate + bonus − deductions). | Calculate each staff member's pay for a pay period | PayRecord, Staff | Arithmetic expression in SELECT (π) |
| Q7 | For each department and time slot on a given date, compare how many staff are needed with how many are scheduled, and show only the slots that are short. | Warn when a shift has fewer staff than needed | StaffingRequirement, Shift, Staff, Role | Join on overlapping times, GROUP BY + COUNT (γ), HAVING (σ on groups) |
| Q8 | For each staff member, calculate the hours they actually worked in a week from their clock-in and clock-out times. | Staff clock in and out of their shifts and log their breaks | TimeClockEvent | TimeClockEvent joined with itself (renaming), correlated subquery to find the next clock-out, SUM (γ) |
| Q9 | Find the staff members who clocked in more than 10 minutes after their shift started. | Staff clock in and out of their shifts | TimeClockEvent, Shift, Staff | Join (⋈), WHERE with a time difference (σ) |
| Q10 | List the clock-ins that are not linked to any scheduled shift. | Staff clock in and out of their shifts | TimeClockEvent, Staff | WHERE shift_id IS NULL (the unscheduled case from Section 7.5, N2) |
| Q11 | Show the staff members who still have to reset their password, and those who have never logged in. | Staff log in to the app; new accounts must reset their password | StaffCredential, Staff | Join (⋈), WHERE with OR and IS NULL |
| Q12 | Find the active staff members who do not have a login account. | Staff log in to the app | Staff, StaffCredential | NOT IN subquery (set difference ∖) |
| Q13 | Show a restaurant's labour cost for a month, split into hourly staff and salaried staff. | Staff are paid either hourly or with a monthly salary | PayRecord, HourlyStaff, SalariedStaff, Staff | Two SUMs (γ) combined with UNION (∪); uses both isa subclasses |
| Q14 | List the roles of a restaurant that no staff member holds. | Managers create roles and assign each to a department | Role, Staff | Tuple NOT IN: (restaurant_id, role_name) NOT IN (subquery) |
| Q15 | Find the pairs of staff members whose shifts overlap on the same day. | Managers schedule shifts | Shift (twice), Staff (twice) | Self-join with renaming; s1.shift_id < s2.shift_id so each pair appears once (like h.id < a.id in the lecture) |
| Q16 | Find the swap requests that are still waiting for a coworker to cover them. | A coworker volunteers to cover an offered shift | SwapRequest, Shift, Staff | Join (⋈), WHERE cover_staff_id IS NULL |
| Q17 | Find the staff member who worked the most hours last month. | Calculate each staff member's pay for a pay period | PayRecord, Staff | GROUP BY, HAVING SUM(hours_worked) >= ALL (subquery) |

#### Menu and Inventory

| # | Query requirement | Feature (Section 3.2) | Tables | Technique |
|---|---|---|---|---|
| Q18 | Show a restaurant's menu grouped by category, in display order, with only the items that are available. | Show the menu grouped by category, in a chosen order | MenuCategory, MenuItem | Join (⋈), WHERE (σ), ORDER BY two attributes |
| Q19 | Calculate the ingredient cost of each dish, using the average delivery cost of each ingredient. | Calculate the ingredient cost of a dish | MenuItem, RecipeLine, StockMovement | Subquery in FROM (average cost per ingredient), join, SUM (γ) |
| Q20 | Show the current stock of every ingredient, including ingredients that have never had a stock movement. | Show the current stock of each ingredient | InventoryItem, StockMovement | LEFT JOIN, SUM (γ), COALESCE for items with no rows |
| Q21 | List the ingredients whose current stock is below their par level. | Warn when stock falls below the par level | InventoryItem, StockMovement | GROUP BY (γ), HAVING SUM(quantity_delta) < par_level |
| Q22 | Show the total cost of wasted stock for each ingredient last month, from the highest to the lowest. | Log waste and stock-count adjustments | StockMovement, InventoryItem | WHERE movement_type = 'WASTE' (σ), SUM (γ), ORDER BY |
| Q23 | Find the menu items that do not have a recipe yet. | Define a recipe for each dish | MenuItem, RecipeLine | NOT IN subquery (set difference ∖) |
| Q24 | Show the menu items that are currently hidden from customers. | Managers add, edit, and hide menu items | MenuItem, MenuCategory | Join (⋈), WHERE is_available = FALSE |
| Q25 | List the supplier deliveries of the last 7 days with the total cost of each one. | Log supplier deliveries with their cost | StockMovement, InventoryItem | WHERE on type and date (σ), arithmetic in SELECT |
| Q26 | For each ingredient, compare how much should have been used based on the dishes sold with how much was logged as consumed. | Deduct ingredients when dishes are sold | OrderItem, RecipeLine, StockMovement | Two subqueries in FROM joined together, SUM (γ) |
| Q27 | Suggest which ingredients to reorder: those that will run out before a new delivery can arrive (days of stock left ≤ lead time), using the average daily use of the last 14 days. | Suggest when to reorder, using the supplier's lead time | InventoryItem, StockMovement | Subquery in FROM (daily use), arithmetic, WHERE on the derived columns |
| Q28 | Show the profit margin of each dish (price minus ingredient cost), lowest margin first. | Calculate the ingredient cost of a dish | MenuItem, RecipeLine, StockMovement | Subquery in FROM (Q19 as a table), arithmetic, ORDER BY |
| Q29 | Find the 5 best-selling menu items of the last 30 days by quantity sold. | Show the menu grouped by category | OrderItem, CustomerOrder, MenuItem | GROUP BY, SUM (γ), ORDER BY + LIMIT |
| Q30 | Find the menu items that nobody ordered in the last 30 days. | Managers add, edit, and hide menu items | MenuItem, OrderItem, CustomerOrder | Correlated NOT EXISTS |
| Q31 | Find the best-selling menu item in each category. | Show the menu grouped by category | MenuItem, OrderItem | Correlated subquery with >= ALL (each item is only compared with items in its own category) |
| Q32 | Find the menu items whose name contains a given word (e.g., "vegan"). | Show the menu grouped by category | MenuItem, MenuCategory | LIKE '%vegan%' (σ) |
| Q33 | Count how many different customers ordered each menu item last month. | Show the menu grouped by category | OrderItem, CustomerOrder, MenuItem | COUNT(DISTINCT customer_id) (γ) |
| Q34 | Find the order lines that were sold at a different price than the item's current price (the price changed since). | Managers change prices | OrderItem, MenuItem | Tuple NOT IN: (menu_item_id, unit_price) NOT IN (SELECT menu_item_id, price …) |

#### Front of House

| # | Query requirement | Feature (Section 3.3) | Tables | Technique |
|---|---|---|---|---|
| Q35 | Show a restaurant's tables grouped by section, with the number of tables and seats in each section. | Show the restaurant's tables by section | DiningTable | GROUP BY, COUNT, SUM (γ) |
| Q36 | Find the tables of a restaurant that are free at a given date and time and have enough seats for the party. | Customers reserve a table; prevent double-booking a table | DiningTable, Reservation | WHERE seats ≥ party size (σ), NOT IN subquery (∖) |
| Q37 | List the sections that have at least one booked table tonight. | Show the restaurant's tables by section | DiningTable, Reservation | Join (⋈), DISTINCT (δ) |
| Q38 | Calculate the total of each order (quantity × price of every line, plus the tip). | Calculate order totals | CustomerOrder, OrderItem | GROUP BY, SUM (γ), arithmetic |
| Q39 | Show the orders that are still not fulfilled more than 30 minutes after they were created. | Track order status from pending to fulfilled | CustomerOrder | WHERE with date arithmetic (σ) |
| Q40 | Count the orders and the revenue for each channel (in person, phone, online) on each day of the last week. | Take orders in person, by phone, or online | CustomerOrder, OrderItem | GROUP BY two attributes (γ), COUNT, SUM |
| Q41 | Show the average tip for each payment type. | Record the payment type and tip | CustomerOrder | GROUP BY, AVG (γ) |
| Q42 | List the order lines with special notes (e.g., "no onions") on the tickets that are cooking right now. | Add dishes to an order with notes | OrderItem, KitchenTicket, MenuItem | Join (⋈), WHERE notes IS NOT NULL |
| Q43 | Show the average preparation time (from start to finish) for each order channel. | Measure how long orders take to prepare | CustomerOrder | AVG of a time difference, GROUP BY (γ) |
| Q44 | Compare the average time from ticket creation to completion for priority tickets and normal tickets. | Mark a ticket as priority and track it from new to ready | KitchenTicket | GROUP BY is_priority, AVG (γ) |
| Q45 | Find the orders that were sent to the kitchen in more than one batch. | Send orders to the kitchen display as tickets, in one or more batches | KitchenTicket | GROUP BY order_id, HAVING COUNT(*) > 1 |
| Q46 | Show the kitchen tickets that are not ready yet with their order items, priority tickets first and then the oldest. | Mark a ticket as priority and track it from new to ready | KitchenTicket, OrderItem, MenuItem | Join (⋈), WHERE (σ), ORDER BY two attributes |
| Q47 | Show the order history of a returning customer, found by their phone number, newest first. | Look up a returning customer's order history | Customer, CustomerOrder | Scalar subquery (phone is a key, so it returns exactly one customer_id), ORDER BY |
| Q48 | Find the customers whose name contains a given text. | Look up a returning customer's order history | Customer | LIKE (σ) |
| Q49 | Show the 10 customers who spent the most in total. | Look up a returning customer's order history | Customer, CustomerOrder, OrderItem | GROUP BY, SUM (γ), ORDER BY + LIMIT |
| Q50 | Find the customers who did not show up for 2 or more reservations. | Customers reserve a table for a date and time | Reservation, Customer | WHERE status = 'NO_SHOW', GROUP BY, HAVING COUNT(*) >= 2 |
| Q51 | Find the customers who have both reserved a table and placed a delivery order. | Customers reserve a table; handle delivery orders | Reservation, CustomerOrder, DeliveryOrder | IN subquery (intersection ∩) |
| Q52 | Find the customers whose orders were all deliveries. | Handle pickup and delivery orders | Customer, CustomerOrder, DeliveryOrder | Correlated NOT EXISTS ("for all": no order of theirs is outside DeliveryOrder) |
| Q53 | Find the customers who have ordered every item in a category (e.g., tried all the desserts). | Look up a returning customer's order history | Customer, CustomerOrder, OrderItem, MenuItem | Relational division: NOT EXISTS inside NOT EXISTS |
| Q54 | Count the orders of each type: dine-in, delivery, and pickup (an order that is in neither subclass). | Handle pickup and delivery orders | CustomerOrder, DineInOrder, DeliveryOrder | Three counts combined with UNION (∪); pickup found with NOT EXISTS in both subclasses |
| Q55 | Compare Uber Eats and in-house deliveries: number of orders and average preparation time. | Handle pickup and delivery orders, including Uber Eats | DeliveryOrder, CustomerOrder | Join (⋈), GROUP BY courier, COUNT, AVG |
| Q56 | Rank the servers by the average rating of the dine-in orders they served, only for servers with at least 5 reviews. | Seat dine-in orders and assign a server; customers review an order | Review, DineInOrder, Staff | GROUP BY, HAVING COUNT(*) >= 5, AVG, ORDER BY |
| Q57 | List last week's reviews with a rating of 2 or less, with the order and, for dine-in orders, the server. | Customers review an order | Review, CustomerOrder, DineInOrder, Staff | LEFT JOIN (not every order is dine-in) |
| Q58 | Find the order lines whose menu item belongs to a different restaurant than the order (should return 0 rows). | Several restaurants use the same system, each seeing only its own data | OrderItem, CustomerOrder, MenuItem, MenuCategory | Joins with renaming, WHERE o.restaurant_id <> c.restaurant_id (the same check as the G6 trigger) |

#### Marketing and Analytics

| # | Query requirement | Feature (Section 3.4) | Tables | Technique |
|---|---|---|---|---|
| Q59 | List the campaigns that are running today with the menu items each one promotes. | A campaign promotes one or more menu items | Campaign, CampaignItem, MenuItem | Join (⋈), WHERE on a date range (end_date can be NULL) |
| Q60 | Show how much revenue each promoted menu item made during its campaign's dates. | Managers create marketing campaigns with a budget and dates | Campaign, CampaignItem, OrderItem, CustomerOrder | Join with a date range, SUM (γ) |
| Q61 | For each campaign, compare the revenue of its promoted items during the campaign with its budget. | Managers create marketing campaigns with a budget and dates | Campaign, CampaignItem, OrderItem, CustomerOrder | GROUP BY, SUM (γ), arithmetic |
| Q62 | Find the menu items that were never promoted in any campaign. | A campaign promotes one or more menu items | MenuItem, CampaignItem | NOT IN subquery (∖) |
| Q63 | Find the orders that include any item promoted by a campaign running today. | A campaign promotes one or more menu items | OrderItem, CampaignItem, Campaign | = ANY (subquery) |
| Q64 | Show the active announcements for a restaurant, newest first (the restaurant comes from the author). | Managers post announcements; hide announcements that are no longer active | Announcement, Staff | Join (⋈), WHERE (σ), ORDER BY |
| Q65 | Show which staff members posted the most announcements. | Managers post announcements to the staff dashboard | Announcement, Staff | GROUP BY, COUNT (γ), ORDER BY |
| Q66 | Show the average daily revenue for each weather condition. | Use sales and weather data to generate recommendations | WeatherObservation, CustomerOrder, OrderItem | Subquery in FROM (daily revenue), join, AVG (γ) |
| Q67 | For each weather condition, show what share of the orders were deliveries. | Use sales and weather data to generate recommendations | WeatherObservation, CustomerOrder, DeliveryOrder | LEFT JOIN, COUNT with a condition |
| Q68 | Count the orders for each hour of the day over the last 30 days to find the busiest hours. | Use sales and labour data to generate recommendations | CustomerOrder | GROUP BY HOUR(created_at), COUNT (γ), ORDER BY + LIMIT |
| Q69 | For each hour of a day, compare the number of staff on shift with the number of orders, to spot hours with too many or too few staff. | Use sales and labour data to generate recommendations | Shift, CustomerOrder | Two subqueries in FROM joined, GROUP BY |
| Q70 | Show the recommendations for a restaurant that have not expired yet, newest first. | Show recommendations until they expire | Insight | WHERE expires_at > NOW() OR expires_at IS NULL |
| Q71 | Count the recommendations of each type that were created last month. | Use sales, labour, and weather data to generate recommendations | Insight | GROUP BY, COUNT (γ) |
| Q72 | For every restaurant, show its name with last month's revenue, number of orders, and average review rating. | Several restaurants use the same system | Restaurant, CustomerOrder, OrderItem, Review | Several joins, LEFT JOIN, GROUP BY (γ) |
| Q73 | Find the restaurants that had more orders last month than the average restaurant. | Several restaurants use the same system | Restaurant, CustomerOrder | HAVING COUNT(*) > scalar subquery (AVG over a subquery in FROM) |

---

## 9. Implementation

Note: Might get revised!

| File | Contents |
|---|---|
| `sql/schema.sql` | DDL for the 31 relations with 41 foreign key and required NULL columns |
| `sql/seed.sql` | Sample data for two restaurants (Possibly in the next sprint) |
| `sql/demo.sql` | to test to meet with the rubric (Possibly in the next sprint) |

---

## 10. Known Limitations

1. **Cross-restaurant consistency.** Every row belongs to one restaurant, so each restaurant's data stays separate. However, the database does not check that connected data belongs to the *same* restaurant. For example, an order from Harbour Grill could contain a menu item from Kebab Corner, because OrderItem only checks that the menu item exists.
   - **How it is handled now:** the application always filters by the logged-in restaurant, so users only ever see and select their own restaurant's menu items, tables, and staff.
   - **How we will fix it:** two options were compared. Adding restaurant_id to the connecting tables breaks BCNF, so the tables stay in BCNF and the check is added as a **trigger** in Sprint 2 (S2-G6).


Note: The Limitations will be updated in the next sprints. 

---

## 11. Next Sprint Goals

### 11.1 Sprint 2 (November 8): Querying the database

The design is complete (31 relations, every relation at least in 3NF). Sprint 2 uses it: every feature in Section 3 that reads data gets a query requirement, a relational algebra expression, and an SQL query, tested on sample data.

| Goal | Limitation it fixes | Competency | Success criterion (measurable) |
|---|---|---|---|
| **S2-G1.** Turn the features in Section 3 into query requirements | Section 3 says what the app shows, but I have not written or tested any query for it yet | DA: translates requirements into queries | I write at least **15** query requirements, each one linked to a feature in Section 3, with at least 3 for every part (Staff and Labour, Menu and Inventory, Front of House, Marketing and Analytics) |
| **S2-G2.** Write each query in relational algebra first, then in SQL | So far I have only used RA for constraints, not to answer questions about the data | DA: relational algebra; DM L3: constraints in RA | All **15/15** queries have an RA version and an SQL version, and both return the same rows on the sample data |
| **S2-G3.** Create `seed.sql` with realistic data for two restaurants | I cannot test queries on an empty database | DA; BE L1 | `seed.sql` loads with **0** errors, every query returns at least 1 row, and the expected output of each query is written in the document and matches what the query really returns |
| **S2-G4.** Use advanced SQL where a requirement needs it | Right now I can only show simple SELECTs | DA: joins, aggregation, subqueries, set operations | Each of these is used in at least one query, with a short reason why it is needed: inner join, outer join, GROUP BY + HAVING, a subquery (IN / EXISTS / NOT EXISTS), a set operation (UNION / set difference), and ORDER BY + LIMIT; every part has at least one aggregate |
| **S2-G5.** Add views for the four dashboards (Owner, Employee, Order-system, Kitchen Display) | Without views, the app would repeat the same long queries in many places | DA; BE L1 | `schema.sql` has at least **4** views, one for each dashboard, and each one is built from an S2-G1 query |
| **S2-G6.** Finish the constraints: CHECK constraints, the cross-restaurant trigger (G6), the "at least one" triggers (Section 4), and the RA version of each rule | The business rules, the cross-restaurant rule, and three (1,n) minimums are not enforced yet (Sections 2.2, 4, 9) | DM L3: constraints in RA; BE L1: database never enters an inconsistent state | At least **20** CHECK constraints for the business rules in Section 3; every key, foreign key, CHECK, and trigger rule written in RA as "query = ∅"; each CHECK and trigger has a test that breaks it, and `tests.sql` shows **0** unexpected results |
| **S2-G7.** Finish the design checks from this sprint's lectures | I have not checked the FDs implied by every ERD relationship, compared isa styles, or rated the ERD's quality formally | DM L2, DM L3: ERDs to FDs, inheritance, improving conceptual designs | All **35/35** relationships are matched to the FD they imply; both isa hierarchies are compared in 3 styles; the ERD is rated on all 8 Batini criteria with evidence; any new relation added in Sprint 2 is checked for BCNF/3NF |
| **S2-G8.** Answer the last two Kickoff questions: FDs that do not hold, and anomalies of the original schema | Kickoff questions 3 and 4 are still open (Section 2.6) | DM L2: identifies dependencies and keys; eliminates data anomalies | For every relation with a composite or second key, at least 1 FD that does **not** hold is listed with the reason; update, insertion, and deletion anomalies are shown for at least **3** original models (e.g., D1, D5, D7); all **4/4** Kickoff questions are answered |


**Module coverage.** Each module competency from Sprint 1 is developed further in Sprint 2:

| Module | Sprint 2 goal |
|---|---|
| Constraints in Relational Algebra | S2-G2, S2-G6 |
| Weak Entity Sets & Inheritance | S2-G7 (isa comparison); queries over subclasses in S2-G1 |
| Improving Conceptual Designs | S2-G7  |
| ERDs to FDs | S2-G7 (35/35) |
| Projecting FDs and minimal bases | S2-G7  |
| 3NF | S2-G7 |
| 4NF and MVDs | S2-G7  |


### 11.3 Questions for the TA-client

1. Should we also list functional dependencies that do not hold? (Kickoff question 3, S2-G8)
2. Should we document the anomalies of the original schema in more detail? (Kickoff question 4, S2-G8)
3. Which staff data is sensitive (password_hash, phone, email, pay), and should access to it be restricted in the database?

---

## 12. Use of Generative AI and Prior Work

**Prior work.** The original Prisma schema and application were written organically by Caner Kaan Balseven during an entrepreneurship co-op term, before this course. Everything in this document and repository is a redesign done for CSC 370. In Addition, 'schema.sql' was kind of already implemented in my co-op work term; I only converted the tables Prisma ORM to SQL and did not focus on NULL values at first; NOT NULL / NULL were added in Sprint 1. 

**Generative AI.**

- **Claude (Anthropic)** was used to review the original schema for unseen relations, and draft this document (wording, structure idea and confirming the logic). Additionally, asked to AI how to meet better with course rubric to match with A+ as well as BCNF Verification is generated by AI. Also, AI is used to guide me to do the assignment step by step in the most meaningful and the fastest way; so I used it for planning also did not follow blindly I did other things before what I should do according to AI. Moreover, even though I mapped competencies to what i did, I also got help from AI to match them in a perfect way and actually understood what i did in a level-wise category. 

**How the team verified the work.** Because the team worked through the functional dependencies and decompositions ourselves, using AI did not replace developing the course competencies. However, I still believe there will be problems about them especially after implementing the whole data entities. I will need to confirm them with TA. Additionally, because it is my idea, technically there is no right or wrong way to do it explicitly; I might need to reestablish the relationships etc. based on what we are going to implement as a functionality to the project. 

---

## 13. References

- Chester, S. (2026). *CSC 370 lecture slides:* Storing Data with SQL; Retrieving Data with SQL; Conceptual Design; Multiplicity; FDs and Keys; BCNF Decomposition; Constraints in Relational Algebra; Weak Entity Sets & Inheritance; Improving Conceptual Designs; ERDs to FDs; Projecting FDs; Third Normal Form; 4NF & Multivalued Dependencies. University of Victoria.

  **Videos**

- making IT simple. (4 years ago - current year 2026). *Functional Dependency in DBMS* [Video]. YouTube. https://youtu.be/fZ41WtisQgo
- making IT simple. (5 years ago - current year 2026). *Normalization in DBMS | Insertion, Updation & Deletion Anomalies* [Video]. YouTube. https://youtu.be/UF0UHCX-z0E
- Decomplexify. (4 years ago - current year 2026). *Learn Database Normalization - 1NF, 2NF, 3NF, 4NF, 5NF* [Video]. YouTube. https://youtu.be/GFQaEYEc8_8
- Decomplexify. (4 years ago - current year 2026). *Learn Boyce-Codd Normal Form (BCNF)* [Video]. YouTube. https://youtu.be/VWnKUKH4tLg

   
