--*************************************************************************--
-- Title: Assignment08
-- Author: Nikita Daharia
-- Desc: This file demonstrates how to use Stored Procedures
-- Change Log: When,Who,What
-- 2022-03-08, NDaharia,Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name
From SysDatabases
Where Name = 'Assignment08DB_NikitaDaharia')
	 Begin
    Alter Database [Assignment08DB_NikitaDaharia] set Single_user With Rollback Immediate;
    Drop Database Assignment08DB_NikitaDaharia;
End
	Create Database Assignment08DB_NikitaDaharia;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment08DB_NikitaDaharia;

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
    [EmployeeID] [int] NOT NULL -- New Column
,
    [ProductID] [int] NOT NULL
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
-- NOTE: We are starting without data this time!

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
    Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
    From dbo.Inventories;
go

/********************************* Questions and Answers *********************************/
/* NOTE:Use the following template to create your stored procedures and plan on this taking ~2-3 hours

Create Procedure <pTrnTableName>
 (<@P1 int = 0>)
 -- Author: <YourNameHere>
 -- Desc: Processes <Desc text>
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Your Name Here>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	-- Transaction Code --
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
*/

-- Question 1 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Categories table?

-- Create Procedure pInsCategories
Create Procedure pInsCategories
    (@CategoryName nvarchar(100))
-- Author: Nikita Daharia
-- Desc: Processes inserts into the Categories table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Insert Transaction Code --
   Insert Into [dbo].[Categories]
        (CategoryName)
    Values
        (@CategoryName)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

--Create Procedure pUpdCategories
Create Procedure pUpdCategories
    (@CategoryID int,
    @CategoryName nvarchar(100))
-- Author: Nikita Daharia
-- Desc: Processes updates data in the Categories table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Transaction Code --
    Update [dbo].[Categories]
    Set CategoryName = @CategoryName
    Where CategoryID = @CategoryID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

--Create Procedure pDelCategories
Create Procedure pDelCategories
    (@CategoryID int)
-- Author: Nikita Daharia
-- Desc: Processes deletes data from the Categories table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Transaction Code --
   Delete from [dbo].[Categories]
    Where CategoryID = @CategoryID;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

-- Question 2 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Products table?
--Create Procedure pInsProducts
Create Procedure pInsProducts
    (@ProductName nvarchar(100),
    @CategoryID int,
    @UnitPrice money)
-- Author: Nikita Daharia
-- Desc: Processes inserts into the Products table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Insert Transaction Code --
   Insert Into [dbo].[Products]
        (ProductName, CategoryID, UnitPrice)
    Values
        (@ProductName, @CategoryID, @UnitPrice)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

--Create Procedure pUpdProducts
Create Procedure pUpdProducts
    (@ProductID int,
    @ProductName nvarchar(100),
    @CategoryId int,
    @UnitPrice money)
-- Author: Nikita Daharia
-- Desc: Processes updates data in the Products table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Transaction Code --
    Update [dbo].[Products]
    Set ProductName = @ProductName,
    CategoryID = @CategoryID,
    UnitPrice = @UnitPrice
    Where  ProductID = @ProductID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

--Create Procedure pDelProducts
Create Procedure pDelProducts
    (@ProductID int,
    @ProductName nvarchar(100),
    @CategoryId int,
    @UnitPrice money)
-- Author: Nikita Daharia
-- Desc: Processes deletes data from the Products table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Transaction Code --
   Delete from [dbo].[Products]
    Where ProductID = @ProductID;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

-- Question 3 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Employees table?
--Create Procedure pInsEmployees
Create Procedure pInsEmployees
    (@EmployeeFirstName nvarchar(100),
    @EmployeeLastName nvarchar(100),
    @ManagerID int)
-- Author: Nikita Daharia
-- Desc: Processes inserts into the Employees table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Insert Transaction Code --
   Insert Into [dbo].[Employees]
        (EmployeeFirstName, EmployeeLastName, ManagerID)
    Values
        (@EmployeeFirstName, @EmployeeLastName, @ManagerID);
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

--Create Procedure pUpdEmployees
Create Procedure pUpdEmployees
    (@EmployeeID int,
    @EmployeeFirstName nvarchar(100),
    @EmployeeLastName nvarchar(100),
    @ManagerID int)
-- Author: Nikita Daharia
-- Desc: Processes updates data in the Employees table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Insert Transaction Code --
 Update [dbo].[Employees]
    Set EmployeeFirstName = @EmployeeFirstName,
     EmployeeLastName = @EmployeeLastName,
      ManagerID = @ManagerID
      Where EmployeeID = @EmployeeID;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go


--Create Procedure pDelEmployees
Create Procedure pDelEmployees
    (@EmployeeID int)
-- Author: Nikita Daharia
-- Desc: Processes deletes data from the Employees table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Insert Transaction Code --
Delete from [dbo].[Employees]
      Where EmployeeID = @EmployeeID;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

-- Question 4 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Inventories table?
--Create Procedure pInsInventories
Create Procedure pInsInventories
    (@InventoryDate Date,
    @EmployeeID int,
    @ProductID int,
    @Count int)
-- Author: Nikita Daharia
-- Desc: Processes inserts into the Inventories table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Insert Transaction Code --
   Insert Into [dbo].[Inventories]
        (InventoryDate, ProductID, EmployeeID, [Count])
    Values
        (@InventoryDate, @ProductID, @EmployeeID, @Count);
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

--Create Procedure pUpdInventories
Create Procedure pUpdInventories
    (@InventoryID int,
    @InventoryDate Date,
    @EmployeeID int,
    @ProductID int,
    @Count int)
-- Author: Nikita Daharia
-- Desc: Processes updates data in the Inventories table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Insert Transaction Code --
 Update [dbo].[Inventories]
    Set InventoryDate = @InventoryDate,
     EmployeeID = @EmployeeID,
      ProductID = @ProductID,
      [Count] = @Count
      Where @InventoryID = @InventoryID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

--Create Procedure pDelInventories
Create Procedure pDelInventories
    (@InventoryID int)
-- Author: Nikita Daharia
-- Desc: Processes deletes data from the Inventories table
-- Change Log: When,Who,What
-- 2022-03-08,Nikita Daharia,Created Sproc.
AS
Begin
    Declare @RC int = 0;
    Begin Try
   Begin Transaction 
	-- Insert Transaction Code --
Delete from [dbo].[Inventories]
      Where InventoryID = @InventoryID;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
    Return @RC;
End
go

-- Question 5 (20 pts): How can you Execute each of your Insert, Update, and Delete stored procedures? 
-- Include custom messages to indicate the status of each sproc's execution.

-- Here is template to help you get started:
/*
Declare @Status int;
Exec @Status = <SprocName>
                @ParameterName = 'A'
Select Case @Status
  When +1 Then '<TableName> Insert was successful!'
  When -1 Then '<TableName> Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From <ViewName> Where ColID = 1;
go
*/


--< Test Insert Sprocs >--
-- Test [dbo].[pInsCategories]
Declare @Status int;
Exec @Status = [dbo].[pInsCategories]
                @CategoryName = 'A'
Select Case @Status 
  When +1 Then 'Categories Insert was successful!'
  When -1 Then 'Categories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select *
From vCategories
Where CategoryID = 1;
go

-- Test [dbo].[pInsProducts]
Declare @Status int;
Exec @Status = [dbo].[pInsProducts]
                @ProductName = 'A',
                @CategoryID = 1,
                @UnitPrice = $9.99;
Select Case @Status 
  When +1 Then 'Products Insert was successful!'
  When -1 Then 'Products Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select *
From vProducts
Where ProductID = 1;
go

-- Test [dbo].[pInsEmployees]
Declare @Status int;
Exec @Status = [dbo].[pInsEmployees]
                @EmployeeFirstName = 'Abe',
                @EmployeeLastName = 'Archer',
                @ManagerID = 1;
Select Case @Status 
  When +1 Then 'Employees Insert was successful!'
  When -1 Then 'Employees Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select *
From vEmployees
Where EmployeeID = 1;
go

-- Test [dbo].[pInsInventories]
Declare @Status int;
Exec @Status = [dbo].[pInsInventories]
                @InventoryDate = '2017-01-01',
                @EmployeeID = 1,
                @ProductID = 1,
                @Count = 42;
Select Case @Status 
  When +1 Then 'Inventories Insert was successful!'
  When -1 Then 'Inventories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select *
From vInventories
Where InventoryID = 1;
go

--< Test Update Sprocs >--
-- Test Update [dbo].[pUpdCategories]
Declare @Status int;
Exec @Status = [dbo].[pUpdCategories]
                @CategoryID = @@Identity,
                @CategoryName = 'A'
Select Case @Status 
  When +1 Then 'Categories Update was successful!'
  When -1 Then 'Categories Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select *
From vCategories
Where CategoryID = @@Identity;
go

-- Test [dbo].[pUpdProducts]
Declare @Status int;
Exec @Status = [dbo].[pUpdProducts]
                @ProductID = @@Identity,
                @ProductName = 'A',
                @CategoryID = 1,
                @UnitPrice = $9.99;
Select Case @Status 
  When +1 Then 'Products Update was successful!'
  When -1 Then 'Products Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select *
From vProducts
Where ProductID = @@Identity;
go

-- Test [dbo].[pUpdEmployees]
Declare @Status int;
Exec @Status = [dbo].[pUpdEmployees]
                @EmployeeId = @@identity,
                @EmployeeFirstName = 'Abe',
                @EmployeeLastName = 'Archer',
                @ManagerID = 1;
Select Case @Status 
  When +1 Then 'Employees Update was successful!'
  When -1 Then 'Employees Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select *
From vEmployees
Where EmployeeID = @@Identity;
go

-- Test [dbo].[pUpdInventories]
Declare @Status int;
Exec @Status = [dbo].[pUpdInventories]
                @InventoryID = @@identity,
                @InventoryDate = '2017-01-01',
                @EmployeeID = 1,
                @ProductID = 1,
                @Count = 42;
Select Case @Status 
  When +1 Then 'Inventories Update was successful!'
  When -1 Then 'Inventories Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select *
From vInventories
Where InventoryID = @@identity;
go

--< Test Delete Sprocs >--
-- Test [dbo].[pDelInventories]
Declare @Status int;
Exec @Status = [dbo].[pdelInventories]
                @InventoryID = @@identity
Select Case @Status 
  When +1 Then 'Inventories Delete was successful!'
  When -1 Then 'Inventories Delete failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select *
From vInventories
Where InventoryID = @@identity;
go

-- Test [dbo].[pDelEmployees]
Declare @Status int;
Exec @Status = [dbo].[pdelEmployees]
                @EmployeeID = @@identity
Select Case @Status 
  When +1 Then 'Employees Delete was successful!'
  When -1 Then 'Employees Delete failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select *
From vEmployees
Where EmployeeID = @@Identity;
go

-- Test [dbo].[pDelProducts]
Declare @Status int;
Exec @Status = [dbo].[pdelProducts]
                @ProductID = @@Identity
Select Case @Status 
  When +1 Then 'Products Delete was successful!'
  When -1 Then 'Products Delete failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select *
From vProducts
Where ProductID = @@Identity;
go

-- Test [dbo].[pDelCategories]
Declare @Status int;
Exec @Status = [dbo].[pdelCategories]
                @CategoryID = @@Identity
Select Case @Status 
  When +1 Then 'Categories Delete was successful!'
  When -1 Then 'Categories Delete failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select *
From vCategories
Where CategoryID = @@Identity;
go


/***************************************************************************************/