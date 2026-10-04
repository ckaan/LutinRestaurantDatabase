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
