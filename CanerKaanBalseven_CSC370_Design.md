<!-- ===================== COVER PAGE ===================== -->

<p align="center">
  <br><br>
  <b>CSC 370: Database Systems</b><br>
  University of Victoria · Fall 2026
  <br><br><br>
</p>

<h1 align="center">Restaurant Operations Database</h1>
<h3 align="center">Conceptual and Relational Design: Kickoff Sprint</h3>

<p align="center">
  <br><br>
  <b>Group 47</b><br>
  Caner Kaan Balseven<br>
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
