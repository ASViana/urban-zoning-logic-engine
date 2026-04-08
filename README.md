# Urban Zoning & Business Compliance Logic Engine

## Overview
This repository contains a high-level SQL Logic Engine designed to automate complex decision-making processes for urban zoning and business licensing. Originally developed for municipal government applications in Brazil and now generalized for portfolio purposes, the engine evaluates business activities against geographic and legal constraints to provide automated verdicts.

Developed to streamline the integration of business environments and public policy, this script demonstrates how to translate intricate legislation into a functional, data-driven weighted risk-assessment motor.

## Key Features
* **Weighted Risk Assessment:** Converts law classifications into standardized risk scores (0 to 5) to determine the complexity of a business permit request.
* **Legal Pathway Identification:** Automatically identifies "Grandfathered Rights" (Direito Adquirido) based on activity history, ensuring legal compliance and stability for established businesses.
* **Automated Decision Output:** Generates clear final verdicts ranging from "Automatic Approval" to "Board Review Required," reducing manual administrative bottlenecks.
* **Scalable Business Logic:** Uses a modular `CASE` structure that can be easily adapted to different municipal zoning laws or regulatory requirements.

## Technical Stack
* **Language:** SQL (T-SQL / SQL Server) 
* **Concepts:** ETL Logic, Business Rule Automation, Data Governance, Regulatory Compliance].

## System Logic (Weight Matrix)
The engine processes inputs like activity codes, total area, and zoning rules to assign a risk weight:

| Weight | Risk Level | Assignment Logic |
| :--- | :--- | :--- |
| **0** | **Free** | Classif. 1 (Permitted Use)  |
| **1** | **Conditional** | Classif. 3 OR Admin Offices (Requires terms acceptance)  |
| **2** | **Tolerated** | Classif. 5 (Requires proof of prior installation)  |
| **3** | **Incompatible** | Classif. 6 (Tolerated use without expansion possibility)  |
| **4** | **Analysis** | Classif. 2, 4 or area excess with Board Review path  |
| **5** | **Blocked** | Classif. 7, lack of terms acceptance or area excess  |

## Data Dictionary (Technical Specifications)

### System Inputs
* **@Event**: Type of request (Ex: 'New_Business', 'Registration_Change').
* **@Address_Change**: Indicates if there is a location change (0 or 1).
* **@Qty_Inclusions**: Number of new activities being added.
* **@Qty_Exclusions**: Number of activities being removed.
* **@Classification**: Normalized Zoning Classification (Ex: '1', '1*', '2', '3', '3*', '4', '5', '6', '7').
* **@Board_Review_Possible**: Indicates if the classification allows a Board Review appeal (0 or 1).
* **@Total_Area**: Total area informed in the protocol.
* **@Area_Limit**: Maximum area allowed for specific classifications.
* **@Ritual**: Legal path defined in Module 1 (Ex: 'GRANDFATHERED_RIGHTS').
* **@Administrative_Office**: Identifies if the profile is administrative (0 or 1).
* **@Terms_Acceptance**: Response to conditional requirements (0 or 1).

### Final Outputs (Verdicts)
* **0**: AUTOMATICALLY APPROVED (Immediate release) 
* **1**: CONDITIONALLY APPROVED (Released under terms of acceptance) 
* **2**: PROOF OF RIGHTS REQUIRED (Attach old permits and licenses) 
* **3**: INCOMPATIBLE USE (Expansion or activity change forbidden) 
* **4**: SEND TO BOARD REVIEW (Requires technical analysis) 
* **5**: DENIED (PROHIBITED) (Activity forbidden for the location) 
