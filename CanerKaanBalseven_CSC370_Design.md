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
  <b>Commit:</b> [commit hash]
  <br><br>
</p>

<div style="page-break-after: always;"></div>

---
---

## Table of Contents

- [1. Project Background]
- [2. Kickoff Sprint Goals]
- [3. Requirements](#3-requirements)
- [4. Entity-Relationship Diagram]
  - [4.1 Staff]
  - [4.2 Menu and Inventory]
  - [4.3 Front of House]
- [5. Relational Schema]
- [6. Keys](#6-keys)
- [7. Functional Dependencies and BCNF]
  - [7.1 Functional Dependencies]
  - [7.2 Anomalies in the Original Schema]
  - [7.3 BCNF Decompositions]
  - [7.4 BCNF Verification]
- [8. Implementation]
- [9. Known Limitations]
- [10. Next Sprint Goals]
- [11. Use of Generative AI and Prior Work](#11-use-of-generative-ai-and-prior-work)
- [12. References](#12-references)

---

---

## 1. Project Background

During an entrepreneurship co-op term, I built a restaurant management platform. It has 4 dashboard (Owner, Employee, Order-system, Kitchen Display). It ran on PostgreSQL through Prisma ORM, and its schema grew organically while we built features quickly. As a result, the original schema has several design problems: attributes copied between tables, derived values stored as data, JSON blobs instead of relations, missing foreign keys, and money stored as floating-point numbers. The main idea of the project is having meaningful data points which will be used to calculate some statistical or meaningful data/result to improve small and mid size restaurants by inserting recommendations to manager/owner. However, applying those recommendations are up to the owner/manager. 

This project redesigns that database properly, the way it should be done in industry, using the methods of CSC 370:

1. Write the requirements.
2. Build a conceptual schema as an ERD with identifiers and multiplicities.
3. Map the ERD to a relational schema.
4. Identify the functional dependencies and keys.
5. Normalise to BCNF.
6. Implement the result in MySQL with hand-written DDL.

The original application has about 35 Prisma models. This sprint covers the operational core of the system; the remaining subsystems are planned for later sprints (see Section 10).

---
