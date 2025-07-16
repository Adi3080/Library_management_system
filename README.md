# Library_management_system
# 📚 Library Management System using PostgreSQL and pgAdmin

## 🧾 Introduction
This project implements a digital **Library Management System** using **PostgreSQL** and **pgAdmin**. It manages books, authors, members, and book loans while providing features like overdue notifications, reporting views, and usage analytics.

## ⚙️ Tools Used
- **PostgreSQL** – SQL-based relational database
- **pgAdmin** – GUI for managing PostgreSQL
- **SQL** – Schema, views, triggers, reports

## 🏗️ How to Run
1. Open pgAdmin and create a new database.
2. Import the file `library_management_system.sql`.
3. Run the queries from `sample_queries.sql` to test features.
4. View ERD from `ERD.png`.

## 📊 Features
- Add and manage **Books, Authors, Members, Loans**
- Handle **many-to-many** relationship (Books ↔ Authors)
- Views for:
  - `BorrowedBooks`: books not returned
  - `OverdueBooks`: books overdue today
- Trigger for **due-date notifications**
- Reports using `JOIN`, `GROUP BY`, and aggregates

## 📂 Files in Repository
- `library_management_system.sql` – Full SQL dump
- `sample_queries.sql` – Output/report queries
- `ERD.png` – Entity-Relationship Diagram
- `report.pdf` – 2-page project report (final output)
- `README.md` – This file

## ✅ Author
Aditya Mundhe
