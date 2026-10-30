/* ============================================================
  COMPANY EMPLOYEES DATABASE

   Purpose:
   Creates a sample employee database and demonstrates how
   employee information and job assignments can be separated
   into related tables.
   Data source: ALX Data Analytics Tranining

   SQL concepts:
   CREATE DATABASE, CREATE TABLE, INSERT, DISTINCT,
   primary keys and ALTER TABLE.

   Database system: MySQL
   ============================================================ */


/*1: Database Setup
   The first statement is to delete the database if it exists.
   The second creates the database, and the third selects it.*/
DROP DATABASE IF EXISTS company_data;

CREATE DATABASE `company_data`;
USE company_data;

/*2: Creating a Company Employee Table (the original employee table) containing employee details and job assignments.*/
CREATE TABLE `Company_employees` (
  `Employee_id` varchar(10) NOT NULL,
  `Name` varchar(45) DEFAULT NULL,
  `Job_code` varchar(45) NOT NULL,
  `Job_title` varchar(45) DEFAULT NULL,
  `State_code` int DEFAULT NULL,
  `Home_state` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Employee_id`,`Job_code`)
);

/* 3: Inserting Sample Employee Records*/
INSERT INTO `Company_employees` (`Employee_id`,`Name`,`Job_code`,`Job_title`,`State_code`,`Home_state`) VALUES ('E001','Carmel','J01','Chef',26,'Cape Town');
INSERT INTO `Company_employees` (`Employee_id`,`Name`,`Job_code`,`Job_title`,`State_code`,`Home_state`) VALUES ('E001','Carmel','J02','Waiter',26,'Cape Town');
INSERT INTO `Company_employees` (`Employee_id`,`Name`,`Job_code`,`Job_title`,`State_code`,`Home_state`) VALUES ('E002','Stefanie','J02','Waiter',56,'Joburg');
INSERT INTO `Company_employees` (`Employee_id`,`Name`,`Job_code`,`Job_title`,`State_code`,`Home_state`) VALUES ('E002','Stefanie','J03','Bartender',56,'Joburg');
INSERT INTO `Company_employees` (`Employee_id`,`Name`,`Job_code`,`Job_title`,`State_code`,`Home_state`) VALUES ('E003','Lisa','J01','Chef',5,'Nairobi');

/* 4: Viewing the employees' Table
   Retrieves all columns and records from Company_employees. Also check for the inserted sample data.*/
SELECT * 
FROM company_data.company_employees;

/* 5: Creating the Employees Table
  Creates a separate table for employee details. Selects distinct combinations of employee ID, name, state code
  and home state from the original table. Employee_id is the primary key in the new table. */
CREATE TABLE Employees (PRIMARY KEY (Employee_id)) AS
SELECT
	Distinct Employee_id,
    Name,
    State_code,
    Home_state
FROM Company_employees;

/* 6: Creating the Jobs Table
   Extracts distinct job codes and job titles into a separate table.
   Job_code is the primary key- each job code identifies with one job record. */
CREATE TABLE Jobs (PRIMARY KEY (Job_code)) AS
SELECT
	Distinct Job_code,
    Job_title
FROM Company_employees;

/* 7: Creating the Employee_roles Table. 
   Stores employee IDs alongside their assigned job codes.
   The composite primary key ensures each employee-job combination
   is unique while allowing employees to hold multiple roles.*/

CREATE TABLE Employee_roles (PRIMARY KEY (Employee_id, Job_code)) AS
SELECT
	Employee_id,
    Job_code
FROM Company_employees;

/*8: Altering the Table
Removing the Home_state Column from the Employees table.*/
ALTER TABLE Employees
DROP COLUMN Home_state;
