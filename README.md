# Unmanaged-Logistics-Management-System
Project on Unmanaged scenario with Logistics Management System
# Unmanaged Logistics Management System

## Overview
This repository contains a comprehensive **Freight Order Management System** developed using **SAP ABAP Cloud** and the **RESTful Application Programming Model (RAP)**. 

The project demonstrates an **Unmanaged Scenario with Draft Capabilities**, effectively managing complex Header-Item hierarchies, custom early numbering, and robust transactional buffer handling to ensure data integrity and prevent database conflicts.

## Key Features
* **Unmanaged RAP with Draft:** Full implementation of Draft persistency to allow users to pause, edit, and resume work safely without committing directly to the active database tables.
* **Custom Early Numbering:** Intelligent, auto-incrementing ID generation for both Freight Orders and Items that seamlessly handles transitions between Draft and Active states without ID collisions.
* **Dynamic Side Effects:** Real-time Fiori UI updates, such as automatically calculating and refreshing the **Total Weight** of an order on the header whenever a Freight Item is created, modified, or deleted.
* **Custom Transactional Actions:** Application-specific actions like **Mark Delivered** and **Cancel Order** (with a mandatory pop-up for cancellation reasoning) that drive logical state transitions.
* **Status Criticality:** Visual UI indicators (e.g., Green for Delivered, Red for Canceled, Yellow for New) powered by ABAP behavior determinations and UI annotations.
* **Fiori Elements UI:** A fully responsive, metadata-driven user interface architected via CDS Views and exposed through **OData V4** services.

## Tech Stack
* **Backend:** SAP ABAP Cloud, SAP Business Technology Platform (BTP)
* **Framework:** ABAP RESTful Application Programming Model (RAP - Unmanaged)
* **Data Modeling:** Core Data Services (CDS)
* **Frontend:** SAP Fiori Elements 
* **IDE:** Eclipse with ABAP Development Tools (ADT)

## Application Screenshots

**Freight Order Overview & Management**
<br>
<img width="1920" height="1020" alt="Freight Order Overview" src="https://github.com/user-attachments/assets/2f25ba66-34e3-42d3-b8a8-44ea0f3ee789" />

**Real-Time Calculations & Draft Handling**
<br>
<img width="1920" height="1020" alt="Freight Order Details" src="https://github.com/user-attachments/assets/d9e2f4b3-da41-40ba-9a62-e56f18cf99b1" />
