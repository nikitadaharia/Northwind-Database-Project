

--*************************************************************************--
-- Title: Assignment07
-- Author: Nikita Daharia
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2022-03-03, NDaharia, Answered questions 1-8
-- 2022-03-03, NDaharia,Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name
From SysDatabases
Where Name = 'Assignment07DB_NikitaDaharia')
	 Begin
    Alter Database [Assignment07DB_NikitaDaharia] set Single_user With Rollback Immediate;
    Drop Database Assignment07DB_NikitaDaharia;
End
	Create Database Assignment07DB_NikitaDaharia;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_NikitaDaharia;

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

Create Table Employees -- New Table
(
    [EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,
    [EmployeeFirstName] [nvarchar](100) NOT NULL
,
    [EmployeeLastName] [nvarchar](100) NOT NULL 
,
    [ManagerID] [int] NULL
);
go

Create Table Inventories
(
    [InventoryID] [int] IDENTITY(1,1) NOT NULL
,
    [InventoryDate] [Date] NOT NULL
,
    [EmployeeID] [int] NOT NULL
,
    [ProductID] [int] NOT NULL
,
    [ReorderLevel] int NOT NULL -- New Column 
,
    [Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin
    -- Categories
    Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

    Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go

Begin
    -- Products
    Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

    Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

    Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

    Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin
    -- Employees
    Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

    Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin
    -- Inventories
    Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

    Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

    Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

    Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

    Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories
    (CategoryName)
Select CategoryName
From Northwind.dbo.Categories
Order By CategoryID;
go

Insert Into Products
    (ProductName, CategoryID, UnitPrice)
Select ProductName, CategoryID, UnitPrice
From Northwind.dbo.Products
Order By ProductID;
go

Insert Into Employees
    (EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID)
From Northwind.dbo.Employees as E
Order By E.EmployeeID;
go

Insert Into Inventories
    (InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel])
-- New column added this week
    Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
    From Northwind.dbo.Products
UNIOn
    Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel
    -- Using this is to create a made up value
    From Northwind.dbo.Products
UNIOn
    Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel
    -- Using this is to create a made up value
    From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories
With
    SchemaBinding
AS
    Select CategoryID, CategoryName
    From dbo.Categories;
go
Create View vProducts
With
    SchemaBinding
AS
    Select ProductID, ProductName, CategoryID, UnitPrice
    From dbo.Products;
go
Create View vEmployees
With
    SchemaBinding
AS
    Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
    From dbo.Employees;
go
Create View vInventories
With
    SchemaBinding
AS
    Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count]
    From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select *
From vCategories;
go
Select *
From vProducts;
go
Select *
From vEmployees;
go
Select *
From vInventories;
go

/********************************* Questions and Answers *********************************/
Print

-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- Select data from vProducts
-- Pull columns ProductName and UnitPrice
-- Use Format on UnitPrice
-- Order by ProductName

Select
    ProductName,
    Format(UnitPrice, 'C', 'en-US') as 'UnitPrice'
From
    vProducts
Order By ProductName;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- Select data from vCategories and vProducts
-- Pull columns Category, ProductName and UnitPrice
-- Use Format on UnitPrice
-- Create a left join on vProducts on CategoryID
-- Order By Category and ProductName

Select
    CategoryName,
    ProductName,
    Format(UnitPrice, 'C', 'en-US') as 'UnitPrice'
From
    vCategories Left Join vProducts
    on vCategories.CategoryID = vProducts.CategoryID
Order By CategoryName,
		   ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Select data from vProducts and vInventories
-- Pull columns ProductName, InventoryDate and [Count]
-- Create a left  to join on vProducts and vInventories on ProductID
-- Order By ProductName and InventoryDate
-- Execute query

Select
    ProductName,
    InventoryDate = DateName(MM, InventoryDate) + ', ' + DateName(YY, InventoryDate),
    [Count]
From
    vProducts Left Join vInventories
    on vProducts.ProductID = vInventories.ProductID
Order By ProductName,
		    Month(InventoryDate);
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Create a view and name it vProductInventories
-- In order to order results, after Select, add Top 10000
-- Select data from vProducts and vInventories 
-- Create left join on ProductID
-- Order by Product Name and month function for InventoryDate
-- Check that it works by selecting * From vProductInventories under the check instructions

Create View vProductInventories
As
    Select Top 10000
        ProductName,
        InventoryDate = DateName(MM, InventoryDate) + ', ' + DateName(YY, InventoryDate),
        [Count] as 'InventoryCount'
    From vProducts Left Join vInventories
        on vProducts.ProductID = vInventories.ProductID
    Order By ProductName,
               Month(InventoryDate);
go

-- Check that it works: Select * From vProductInventories;
Select *
From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Create View  and name it vCategoryInventories
-- Select data from vCategories, vProducts and vInventories
-- Created left joins on CategoryID and ProductID
-- Add columns CategoryName
-- Add Sum function to [Count] and give it alias InventoryCountbyCategory
-- Group by InventoryDate and CategoryDate
-- Check that it works by selecting * From vCategoryInventories under the check instructions

Create View vCategoryInventories
As
    Select Top 10000
        C.CategoryName,
        InventoryDate = DateName(MM, I.InventoryDate) + ', ' + DateName(YY, I.InventoryDate),
        Sum(I.[Count]) as InventoryCountByCategory
    From vCategories as C Left Join vProducts as P
        on C.CategoryID = P.CategoryID
        Left Join vInventories as I
        on P.ProductID = I.ProductID
    Group By C.CategoryName, I.InventoryDate
    Order By C.CategoryName, Month(I.InventoryDate), InventoryCountByCategory;
go

-- Check that it works: Select * From vCategoryInventories;
Select *
From vCategoryInventories;
go


-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- Create View and name it vProductInventoriesWithPreviouMonthCounts
-- Select data from vProducts and vInventories 
-- Create left join on ProductID
-- Add columns ProductName
-- Add Sum function to [Count] and give it alias InventoryCount
-- Add new column and name it PreviousMonthCount 
-- Add Immediate IF function and Lag function
-- Order by ProductName and month function for InventoryDate
-- Group by ProductName and InventoryDate
-- Check that it works by selecting * From vProductInventoriesWithPreviousMonthCounts under the check instructions

Create View vProductInventoriesWithPreviouMonthCounts
As
    Select Top 10000
        ProductName,
        InventoryDate,
        InventoryCount,
        [PreviousMonthCount] = 
			IIF(InventoryDate Like ('January%'), 0, IsNull(Lag(InventoryCount) Over (Order By ProductName, Year(InventoryDate)), 0) )
    From vProductInventories
    Order By ProductName, Month(InventoryDate);

go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
Select *
From vProductInventoriesWithPreviouMonthCounts
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- Create View statement and named it vProductInventoriesWithPreviousMonthCountsWithKPIs
-- Select data from vProductInventoriesWithPreviouMonthCounts
-- Add columns ProductName, InventoryDate, InventoryCount, PreviousMonthCount
-- Add new column name CountVsPerviousCountKPI and added a Case statement to list 3 KPIs
-- Check that it works by selecting * From vProductInventoriesWithPreviousMonthCountsWithKPIs under the check instructions

Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
    Select Top 10000
        ProductName,
        InventoryDate,
        InventoryCount,
        PreviousMonthCount,
        [CountVsPreviousCountKPI] = IsNull(Case
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount = PreviousMonthCount Then 0
		When InventoryCount < PreviousMonthCount Then -1
		End,0)
    From vProductInventoriesWithPreviouMonthCounts
    Order By ProductName, Month(InventoryDate);
  go


-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Select *
From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- Create a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- Steps:
-- Use UDF statement and name it fProductInventoriesWithPreviousMonthCountsWithKPIs
-- Select data from dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
-- Use Where clause to equal the parameter to CountVsPreviousCountKPI 
-- Copy the Select * From statements in the check instructions 
-- Paste it below section

Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs
(
	@CountVsPreviousCountKPI Int
)
Returns Table
As
Return
	Select
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountVsPreviousCountKPI
From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
Where CountVsPreviousCountKPI = @CountVsPreviousCountKPI
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/

Select *
From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select *
From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select *
From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/
