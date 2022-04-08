--*************************************************************************--
-- Title: Assignment04
-- Author: NikitaDaharia
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2022-02-08,NikitaDaharia,Assignment04.sql
--**************************************************************************--

Use Master;
go

If Exists(Select Name
from SysDatabases
Where Name = 'Assignment04DB_NikitaDaharia')
 Begin
    Alter Database [Assignment04DB_NikitaDaharia] set Single_user With Rollback Immediate;
    Drop Database Assignment04DB_NikitaDaharia;
End
go

Create Database Assignment04DB_NikitaDaharia;
go

Use Assignment04DB_NikitaDaharia;
go

-- Create Tables (Module 01)-- 
Create Table Categories
(
    [CategoryID] [int] IDENTITY(1,1) NOT NULL 
,
    [CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
(
    [ProductID] [int] IDENTITY(1,1) NOT NULL 
,
    [ProductName] [nvarchar](100) NOT NULL 
,
    [CategoryID] [int] NULL  
,
    [UnitPrice] [money] NOT NULL
);
go

Create Table Inventories
(
    [InventoryID] [int] IDENTITY(1,1) NOT NULL
,
    [InventoryDate] [Date] NOT NULL
,
    [ProductID] [int] NOT NULL
,
    [Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Alter Table Categories 
 Add Constraint pkCategories 
  Primary Key (CategoryId);
go

Alter Table Categories 
 Add Constraint ukCategories 
  Unique (CategoryName);
go

Alter Table Products 
 Add Constraint pkProducts 
  Primary Key (ProductId);
go

Alter Table Products 
 Add Constraint ukProducts 
  Unique (ProductName);
go

Alter Table Products 
 Add Constraint fkProductsToCategories 
  Foreign Key (CategoryId) References Categories(CategoryId);
go

Alter Table Products 
 Add Constraint ckProductUnitPriceZeroOrHigher 
  Check (UnitPrice >= 0);
go

Alter Table Inventories 
 Add Constraint pkInventories 
  Primary Key (InventoryId);
go

Alter Table Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
go

Alter Table Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
go

Alter Table Inventories 
 Add Constraint ckInventoryCountZeroOrHigher 
  Check ([Count] >= 0);
go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select *
from Categories;
go
Select *
from Products;
go
Select *
from Inventories;
go

/********************************* TASKS *********************************/

-- Add the following data to this database.
-- All answers must include the Begin Tran, Commit Tran, and Rollback Tran transaction statements. 
-- All answers must include the Try/Catch blocks around your transaction processing code.
-- Display the Error message if the catch block is invoked.

/* Add the following data to this database:
Beverages	Chai	18.00	2017-01-01	61
Beverages	Chang	19.00	2017-01-01	87
Condiments	Aniseed Syrup	10.00	2017-01-01	19
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-01-01	81
Beverages	Chai	18.00	2017-02-01	13
Beverages	Chang	19.00	2017-02-01	2
Condiments	Aniseed Syrup	10.00	2017-02-01	1
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-02-01	79
Beverages	Chai	18.00	2017-03-02	18
Beverages	Chang	19.00	2017-03-02	12
Condiments	Aniseed Syrup	10.00	2017-03-02	84
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-03-02	72
*/

-- Task 1 (20 pts): Add data to the Categories table

-- Insert data into Categories table
BEGIN TRY
BEGIN TRAN;
-- All Categories
INSERT INTO Categories
    (CategoryName)
VALUES
    ('Beverages'),
    ('Condiments');	
COMMIT TRAN;
END TRY
BEGIN CATCH
ROLLBACK TRAN;
PRINT Error_Message()
END CATCH
GO
SELECT *
FROM Categories
ORDER BY 1, 2
GO

-- Task 2 (20 pts): Add data to the Products table

-- Insert data into Products table
BEGIN TRY
BEGIN TRAN;
-- All products
INSERT INTO Products
    (ProductName, CategoryID, UnitPrice)
VALUES
    ('Chai', 1, 18),
    ('Chang', 1, 19),
    ('Aniseed Syrup', 2, 10),
    ('Chef Antons Cajun Seasoning', 2, 22);
COMMIT TRAN;
END TRY
BEGIN CATCH
  ROLLBACK TRAN;
PRINT Error_Message()
END CATCH
GO
SELECT *
FROM Products
ORDER BY 1, 2, 3
GO

-- Task 3 (20 pts): Add data to the Inventories table

-- Insert data into Inventories table
BEGIN TRY
BEGIN TRAN;
-- All Inventories
INSERT INTO Inventories
    (InventoryDate, ProductID, [Count])
VALUES
    ('2017-01-01', 1, 61),
    ('2017-01-01', 2, 87),
    ('2017-01-01', 3, 19),
    ('2017-01-01', 4, 81),
    
    ('2017-02-01', 1, 13),
    ('2017-02-01', 2, 2),
    ('2017-02-01', 3, 1),
    ('2017-02-01', 4, 79),
    
    ('2017-03-02', 1, 18),
    ('2017-03-02', 2, 12),
    ('2017-03-02', 3, 84),
    ('2017-03-02', 4, 72)
COMMIT TRAN;
END TRY
BEGIN CATCH
ROLLBACK TRAN;
PRINT Error_Message();
END CATCH
GO
SELECT *
FROM Inventories
ORDER BY 1,2,3,4;
GO

-- Task 4 (10 pts): Write code to update the Category "Beverages" to "Drinks"

-- Update Category "Beverages" to "Drinks"
BEGIN TRY
BEGIN TRAN;
UPDATE Categories
SET CategoryName = 'Drinks'
WHERE CategoryName = 'Beverages';
 COMMIT TRAN;
END TRY
BEGIN CATCH
ROLLBACK TRAN;
PRINT Error_Message()
END CATCH
GO
SELECT *
FROM Categories
ORDER BY 1,2;
GO

-- Task 5 (30 pts): Write code to delete all Condiments data from the database (in all three tables!)

-- Delete Condiments from child tables before deleting from the parent table
-- Delete Condiments from Inventories 
BEGIN TRY
BEGIN TRAN;
DELETE FROM Inventories
  WHERE ProductID in (3,4); 
COMMIT TRAN;
END TRY
BEGIN CATCH
ROLLBACK TRAN;
PRINT Error_Message();
END CATCH
GO
SELECT *
FROM Inventories
ORDER BY 1,2,3,4;
GO

-- Delete Condiments from Products
BEGIN TRY
BEGIN TRAN;
DELETE FROM Products
  WHERE CategoryID = 2; 
COMMIT TRAN;
END TRY
BEGIN CATCH
ROLLBACK TRAN;
PRINT Error_Message();
END CATCH
GO
SELECT *
FROM Products
ORDER BY 1,2,3;
GO

-- Delete Condiments from Categories
BEGIN TRY
BEGIN TRAN;
DELETE FROM Categories
  WHERE CategoryName = 'Condiments'; 
COMMIT TRAN;
END TRY
BEGIN CATCH
ROLLBACK TRAN;
PRINT Error_Message();
END CATCH
GO
SELECT *
FROM Categories
ORDER BY 1,2;
GO


/***************************************************************************************/


