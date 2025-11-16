/*
CREATE DATABASE ASSIGNMENT
GO

USE ASSIGNMENT
GO
*/

-- CREATE PARENT TABLES FOR REFERENCE (PART 1)
USE ASSIGNMENT
GO
/* 1. Membership (referenced by User) */
CREATE TABLE Membership (
    [Rank] VARCHAR(50) NOT NULL,
    Benefit VARCHAR(255),
    [Loyalty Point] INT DEFAULT 0,
    CONSTRAINT PK_Membership PRIMARY KEY ([Rank])
);

/* 2. Cart (referenced by Buyer) */
CREATE TABLE Cart (
    ID INT NOT NULL,
    CONSTRAINT PK_Cart PRIMARY KEY (ID)
);

/* 3. User (superclass, referenced by all your tables) */
CREATE TABLE [User] (
    ID INT NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    [Full name] VARCHAR(100),
    [Rank] VARCHAR(50) NOT NULL,
    CONSTRAINT PK_User PRIMARY KEY (ID),
    CONSTRAINT UK_User_Email UNIQUE (Email),
    CONSTRAINT FK_User_Membership FOREIGN KEY ([Rank]) REFERENCES Membership([Rank])
);
GO

ALTER TABLE [User]
ADD DateOfBirth DATE NULL;

ALTER TABLE [User]
ADD Gender VARCHAR(10) NULL;
GO

ALTER TABLE [User]
ADD CONSTRAINT CHK_User_Gender 
CHECK (Gender IN ('Male', 'Female', NULL));
GO

ALTER TABLE [User]
ADD CONSTRAINT CHK_User_Age
CHECK (DATEDIFF(year, DateOfBirth, GETDATE()) >= 13);
GO

/* 4. Buyer (subclass, referenced by Pay) */
CREATE TABLE Buyer (
    userID INT NOT NULL,
    cartID INT NOT NULL,
    CONSTRAINT PK_Buyer PRIMARY KEY (userID),
    CONSTRAINT UK_Buyer_Cart UNIQUE (cartID),
    CONSTRAINT FK_Buyer_User FOREIGN KEY (userID) REFERENCES [User](ID) ON DELETE CASCADE,
    CONSTRAINT FK_Buyer_Cart FOREIGN KEY (cartID) REFERENCES Cart(ID)
);

/* 5. Shipper (subclass, referenced by Deliver) */
CREATE TABLE Shipper (
    userID INT NOT NULL,
    LicensePlate VARCHAR(15),
    Company VARCHAR(100),
    CONSTRAINT PK_Shipper PRIMARY KEY (userID),
    CONSTRAINT FK_Shipper_User FOREIGN KEY (userID) REFERENCES [User](ID) ON DELETE CASCADE
);

/* 6. Order (referenced by Pay and Deliver) */
CREATE TABLE [Order] (
    ID INT NOT NULL,
    Total DECIMAL(10, 2),
    [Address] VARCHAR(255),
    [Time] DATETIME DEFAULT GETDATE(),
    userID INT NOT NULL, -- This is the Buyer ID
    CONSTRAINT PK_Order PRIMARY KEY (ID),
    CONSTRAINT FK_Order_Buyer FOREIGN KEY (userID) REFERENCES Buyer(userID)
);

/* 7. Transaction (referenced by Pay) */
CREATE TABLE [Transaction] (
    ID INT NOT NULL,
    Time DATETIME,
    Status VARCHAR(20),
    Method VARCHAR(50),
    Amount DECIMAL(10, 2),
    CONSTRAINT PK_Transaction PRIMARY KEY (ID)
);
GO

/* 8. Review (referenced by Reactions and Replies) */
CREATE TABLE Review (
    ID INT NOT NULL,
    Time DATETIME DEFAULT GETDATE(),
    Type VARCHAR(50), -- As per your EERD
    CONSTRAINT PK_Review PRIMARY KEY (ID)
);
GO

/* 9. Vehicle (referenced by Deliver) */
CREATE TABLE Vehicle (
    ID INT NOT NULL,
    Capacity INT,
    Status VARCHAR(50),
    Maintenance DATE,
    CONSTRAINT PK_Vehicle PRIMARY KEY (ID)
);
GO



-- INSERT 5 ROWS PER SAMPLE TABLE
/* 1. Membership Data */
INSERT INTO Membership ([Rank], Benefit, [Loyalty Point]) VALUES
('Bronze', 'Basic support', 0),
('Silver', 'Free shipping voucher', 500),
('Gold', '2% cashback', 2000),
('Platinum', '5% cashback, priority support', 5000),
('Diamond', '10% cashback, personal shopper', 10000);

/* 2. Cart Data */
INSERT INTO Cart (ID) VALUES
(101), (102), (103), (104), (105);

/* 3. User Data */
-- We will create 2 Buyers, 2 Shippers, and 1 Admin for variety
INSERT INTO [User] (ID, Email, [Address], [Full name], [Rank]) VALUES
(1, 'buyer1@example.com', '123 Buyer St, HCMC', 'Huynh Nhat Huy', 'Silver'),
(2, 'buyer2@example.com', '456 Buyer Rd, HCMC', 'Le Anh Quan', 'Bronze'),
(3, 'shipper1@example.com', '789 Shipper Ave, HCMC', 'Lu Thuan Hung', 'Bronze'),
(4, 'shipper2@example.com', '101 Shipper Ln, HCMC', 'Thuong Dinh Hung', 'Bronze'),
(5, 'admin1@example.com', '1 Admin Crt, HCMC', 'Ngo Dang Hao', 'Gold');

/* 4. Buyer Subclass Data */
INSERT INTO Buyer (userID, cartID) VALUES
(1, 101),
(2, 102);

/* 5. Shipper Subclass Data */
INSERT INTO Shipper (userID, LicensePlate, Company) VALUES
(3, '51-F1 12345', 'Giaohangnhanh'),
(4, '59-X1 54321', 'ShopeeExpress');

/* 6. Order Data (Must be from Buyer IDs) */
INSERT INTO [Order] (ID, Total, [Address], [Time], userID) VALUES
(1001, 150.00, '123 Buyer St, HCMC', '2025-11-01 10:30:00', 1),
(1002, 75.50, '456 Buyer Rd, HCMC', '2025-11-02 14:00:00', 2),
(1003, 320.00, '123 Buyer St, HCMC', '2025-11-03 11:15:00', 1),
(1004, 85.00, '456 Buyer Rd, HCMC', '2025-11-04 16:45:00', 2),
(1005, 1200.00, '123 Buyer St, HCMC', '2025-11-05 09:00:00', 1);

/* 7. Transaction Data (Linking to Orders) */
INSERT INTO [Transaction] (ID, [Time], [Status], Method, Amount) VALUES
(2001, '2025-11-01 10:31:00', 'Completed', 'Credit Card', 150.00),
(2002, '2025-11-02 14:01:00', 'Completed', 'ShopeePay', 75.50),
(2003, '2025-11-03 11:16:00', 'Completed', 'COD', 320.00),
(2004, '2025-11-04 16:46:00', 'Pending', 'Bank Transfer', 85.00),
(2005, '2025-11-05 09:01:00', 'Completed', 'Credit Card', 1200.00);

/* 8. Review Data */
INSERT INTO Review (ID, [Time], [Type]) VALUES
(3001, '2025-11-03 18:00:00', 'Product Review'),
(3002, '2025-11-04 12:00:00', 'Product Review'),
(3003, '2025-11-05 19:00:00', 'Shop Review'),
(3004, '2025-11-06 20:00:00', 'Product Review'),
(3005, '2025-11-07 15:00:00', 'Shop Review');

/* 9. Vehicle Data */
INSERT INTO Vehicle (ID, Capacity, [Status], Maintenance) VALUES
(401, 50, 'Active', '2025-10-01'),
(402, 50, 'Active', '2025-10-15'),
(403, 75, 'Active', '2025-11-01'),
(404, 50, 'Maintenance', '2025-11-10'),
(405, 100, 'Active', '2025-09-01');




/*
*
*   PART 1
*
*/
--14
CREATE TABLE PhoneNumbers (
    userID INT NOT NULL,
    aPhoneNum VARCHAR(15) NOT NULL,
    
    -- Composite Primary Key
    CONSTRAINT PK_PhoneNumbers PRIMARY KEY (userID, aPhoneNum),
    
    -- Foreign Key to the User table
    CONSTRAINT FK_Phone_User FOREIGN KEY (userID) REFERENCES [User](ID)
        ON DELETE CASCADE -- If a user is deleted, remove their phone numbers
);
GO

--15
CREATE TABLE Reactions (
    ReviewID INT NOT NULL,
    [Type] VARCHAR(100) NOT NULL,
    Author VARCHAR(100) NOT NULL,
    
    -- Composite Primary Key
    CONSTRAINT PK_Reactions PRIMARY KEY (ReviewID, [Type], Author),
    
    -- Foreign Key to the Review table
    CONSTRAINT FK_Reaction_Review FOREIGN KEY (ReviewID) REFERENCES Review(ID)
        ON DELETE CASCADE -- If a review is deleted, remove its reactions
);
GO

--16: 
/* 
* Warning! The maximum key length for a clustered index is 900 bytes. The index 'PK_Replies' has maximum length of 1112 bytes. 
* For some combination of large values, the insert/update operation will fail. -> Content from 1000 to 500
*/
CREATE TABLE Replies (
    ReviewID INT NOT NULL,
    Content VARCHAR(500) NOT NULL,
    Author VARCHAR(100) NOT NULL,
    [Time] DATETIME NOT NULL DEFAULT GETDATE(),
    
    -- Composite Primary Key
    CONSTRAINT PK_Replies PRIMARY KEY (ReviewID, Content, Author, [Time]),
    
    -- Foreign Key to the Review table
    CONSTRAINT FK_Reply_Review FOREIGN KEY (ReviewID) REFERENCES Review(ID)
        ON DELETE CASCADE -- If a review is deleted, remove its replies
);
GO

--17
CREATE TABLE Pay (
    BuyerID INT NOT NULL,
    OrderID INT NOT NULL,
    TransactionID INT NOT NULL,
    
    -- Composite Primary Key (from your report)
    CONSTRAINT PK_Pay PRIMARY KEY (TransactionID, OrderID),
    
    -- Foreign Keys
    CONSTRAINT FK_Pay_Buyer FOREIGN KEY (BuyerID) REFERENCES [User](ID), -- Note: References User.ID
    CONSTRAINT FK_Pay_Order FOREIGN KEY (OrderID) REFERENCES [Order](ID),
    CONSTRAINT FK_Pay_Transaction FOREIGN KEY (TransactionID) REFERENCES [Transaction](ID)
);
GO

--18
CREATE TABLE Deliver (
    ShiperID INT NOT NULL, -- Note: 'ShiperID' matches your report 
    OrderID INT NOT NULL,
    VehicleID INT NOT NULL,
    [Finish time] DATETIME, -- Using brackets as 'Finish time' has a space
    [Departure time] DATETIME,
    Distance DECIMAL(10, 2),
    
    -- Composite Primary Key
    CONSTRAINT PK_Deliver PRIMARY KEY (ShiperID, OrderID),
    
    -- Foreign Keys
    CONSTRAINT FK_Deliver_Shipper FOREIGN KEY (ShiperID) REFERENCES Shipper(userID), -- References Shipper subclass
    CONSTRAINT FK_Deliver_Order FOREIGN KEY (OrderID) REFERENCES [Order](ID),
    CONSTRAINT FK_Deliver_Vehicle FOREIGN KEY (VehicleID) REFERENCES Vehicle(ID)
);
GO



-- Semantic Constraints
-- Reaction Type
ALTER TABLE Reactions
ADD CONSTRAINT CHK_ReactionType 
CHECK (Type IN ('Like', 'Helpful', 'Love', 'Haha', 'Sad', 'Angry'));

-- Positive Distance + Finish > Departure
ALTER TABLE Deliver
ADD CONSTRAINT CHK_DistancePositive 
CHECK (Distance > 0);

ALTER TABLE Deliver
ADD CONSTRAINT CHK_DeliveryTimes
CHECK ([Finish time] > [Departure time]);




-- SAMPLE DATA FOR NOW
/* 10. PhoneNumbers (Table 14) */
INSERT INTO PhoneNumbers (userID, aPhoneNum) VALUES
(1, '0909111222'),
(1, '0909333444'),
(2, '0912555666'),
(3, '0987123456'),
(5, '0903888999');

/* 11. Reactions (Table 15) */
INSERT INTO Reactions (ReviewID, [Type], Author) VALUES
(3001, 'Helpful', 'buyer2@example.com'),
(3001, 'Like', 'admin1@example.com'),
(3002, 'Helpful', 'buyer1@example.com'),
(3003, 'Love', 'buyer1@example.com'),
(3005, 'Sad', 'buyer2@example.com');

/* 12. Replies (Table 16) */
INSERT INTO Replies (ReviewID, Content, Author, [Time]) VALUES
(3001, 'Thank you for your feedback!', 'TheH', '2025-11-03 19:00:00'),
(3002, 'We are glad you liked the product.', 'AnotherSeller', '2025-11-04 13:00:00'),
(3003, 'We apologize for the experience.', 'ShopOwner', '2025-11-05 20:00:00'),
(3003, 'I had the same problem!', 'OtherUser', '2025-11-05 21:00:00'),
(3005, 'Thank you for the 5 stars!', 'TheSeller', '2025-11-07 16:00:00');

/* 13. Pay (Table 17) - Linking Buyer, Order, Transaction */
INSERT INTO Pay (BuyerID, OrderID, TransactionID) VALUES
(1, 1001, 2001),
(2, 1002, 2002),
(1, 1003, 2003),
(2, 1004, 2004), -- This links to a 'Pending' transaction
(1, 1005, 2005);

/* 14. Deliver (Table 18) - Linking Shipper, Order, Vehicle */
INSERT INTO Deliver (ShiperID, OrderID, VehicleID, [Departure time], [Finish time], Distance) VALUES
(3, 1001, 401, '2025-11-01 11:00:00', '2025-11-01 12:30:00', 10.5),
(4, 1002, 402, '2025-11-02 15:00:00', '2025-11-02 15:45:00', 5.2),
(3, 1003, 401, '2025-11-03 12:00:00', '2025-11-03 14:00:00', 25.0),
(4, 1004, 403, '2025-11-04 18:00:00', NULL, 7.😎, -- In progress, no finish time
(3, 1005, 405, '2025-11-05 10:00:00', '2025-11-05 11:00:00', 12.0);

/*
-- Sample Data
-- For PhoneNumbers (Table 14)
INSERT INTO PhoneNumbers (userID, aPhoneNum) 
VALUES (1, '0909123456');

-- For Reactions (Table 15)
INSERT INTO Reactions (ReviewID, Type, Author) 
VALUES (101, 'Helpful', 'toanpm26');

-- For Replies (Table 16)
INSERT INTO Replies (ReviewID, Content, Author, Time) 
VALUES (101, 'Thank you for your useful review!', 'MizunoStore', GETDATE());

-- For Pay (Table 17)
INSERT INTO Pay (BuyerID, OrderID, TransactionID) 
VALUES (1, 5001, 7001);

-- For Deliver (Table 18)
INSERT INTO Deliver (ShiperID, OrderID, VehicleID, [Departure time], [Finish time], Distance) 
VALUES (3, 5001, 201, '2025-11-12 09:00:00', '2025-11-12 11:30:00', 15.5);
*/



-- CREATE PARENT TABLE FOR REFERENCE (Part 2)
/* 5. Seller (Subclass of User) */
CREATE TABLE Seller (
    userID INT NOT NULL,
    CONSTRAINT PK_Seller PRIMARY KEY (userID),
    CONSTRAINT FK_Seller_User FOREIGN KEY (userID) REFERENCES [User](ID) ON DELETE CASCADE
);

/* 6. Admin (Subclass of User) */
CREATE TABLE Admin (
    userID INT NOT NULL,
    [Role] VARCHAR(50),
    CONSTRAINT PK_Admin PRIMARY KEY (userID),
    CONSTRAINT FK_Admin_User FOREIGN KEY (userID) REFERENCES [User](ID) ON DELETE CASCADE
);

/* 8. Promotion (Referenced by sp_DeleteUser check) */
CREATE TABLE Promotion (
    ID INT NOT NULL,
    Type VARCHAR(50),
    [Start date] DATE,
    [End date] DATE,
    AdminID INT NOT NULL,
    CONSTRAINT PK_Promotion PRIMARY KEY (ID),
    CONSTRAINT FK_Promotion_Admin FOREIGN KEY (AdminID) REFERENCES Admin(userID)
);
GO

/* 9. Product_SKU (Referenced by Trigger and sp_DeleteUser check) */
CREATE TABLE Product_SKU (
    [Bar code] VARCHAR(50) NOT NULL,
    Name VARCHAR(100),
    Stock INT DEFAULT 0,
    Price DECIMAL(10, 2),
    sellerID INT NOT NULL,
    /* Other columns from your report... */
    CONSTRAINT PK_Product_SKU PRIMARY KEY ([Bar code]),
    CONSTRAINT FK_Product_Seller FOREIGN KEY (sellerID) REFERENCES Seller(userID)
);
GO

/* 10. Order (Referenced by Trigger and sp_DeleteUser check) 
CREATE TABLE [Order] (
    ID INT NOT NULL,
    Total DECIMAL(10, 2),
    Address VARCHAR(255),
    Time DATETIME DEFAULT GETDATE(),
    userID INT NOT NULL, -- This is the Buyer ID
    CONSTRAINT PK_Order PRIMARY KEY (ID),
    CONSTRAINT FK_Order_Buyer FOREIGN KEY (userID) REFERENCES Buyer(userID)
);
*/

/* 11. Order_Item (Referenced by Trigger) */
CREATE TABLE Order_Item (
    ID INT NOT NULL,
    orderID INT NOT NULL,
    Quantity INT,
    Price DECIMAL(10, 2),
    BarCode VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Order_Item PRIMARY KEY (ID, orderID),
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (orderID) REFERENCES [Order](ID),
    CONSTRAINT FK_OrderItem_Product FOREIGN KEY (BarCode) REFERENCES Product_SKU([Bar code])
);
GO

/* 12. Review (Referenced by Write_review) 
CREATE TABLE Review (
    ID INT NOT NULL,
    Time DATETIME DEFAULT GETDATE(),
    Type VARCHAR(50),
    CONSTRAINT PK_Review PRIMARY KEY (ID)
);
*/

/* 13. Write_review (The table your trigger is on) */
CREATE TABLE Write_review (
    ReviewID INT NOT NULL,
    UserID INT NOT NULL,
    Order_itemID INT NOT NULL,
    OrderID INT NOT NULL,
    CONSTRAINT PK_Write_Review PRIMARY KEY (ReviewID, UserID),
    CONSTRAINT FK_WriteReview_Review FOREIGN KEY (ReviewID) REFERENCES Review(ID),
    CONSTRAINT FK_WriteReview_User FOREIGN KEY (UserID) REFERENCES [User](ID),
    CONSTRAINT FK_WriteReview_OrderItem FOREIGN KEY (Order_itemID, OrderID) REFERENCES Order_Item(ID, orderID)
);
GO

-- INSERT DATA FOR TESTING PART 2
/* 3. User Data */
INSERT INTO [User] (ID, Email, [Address], [Full name], [Rank], DateOfBirth, Gender) VALUES
(10, 'seller-shop@example.com', '123 Seller Ave, HCMC', 'The M-Store', 'Gold', '1990-05-15', 'Male'),
(11, 'buyer-huy@example.com', '456 Buyer St, HCMC', 'Huynh Nhat Huy', 'Silver', '2003-01-10', 'Male'),
(12, 'admin-quan@example.com', '789 Admin Crt, HCMC', 'Le Anh Quan', 'Platinum', '1995-11-20', 'Male'),
(13, 'buyer-hung@example.com', '101 Buyer Rd, HCMC', 'Thuong Dinh Hung', 'Bronze', '2004-03-22', 'Male'),
(14, 'seller-extra@example.com', '202 Seller Ln, HCMC', 'Extra Goods', 'Silver', '2000-07-07', 'Female');

/* 4. Subclass Data */
INSERT INTO Seller (userID) VALUES (10), (14);
INSERT INTO Buyer (userID, cartID) VALUES (11, 103), (13, 104);
INSERT INTO [Admin] (userID, [Role]) VALUES (12, 'Super Admin');

/* 5. Promotion Data (Created by Admin 12) */
INSERT INTO Promotion (ID, [Type], [Start date], [End date], AdminID) VALUES
(1001, 'Discount', '2025-11-01', '2025-11-15', 12),
(1002, 'Gift', '2025-11-10', '2025-11-20', 12),
(1003, 'Discount', '2025-12-01', '2025-12-15', 12),
(1004, 'Gift', '2025-12-10', '2025-12-20', 12),
(1005, 'Discount', '2026-01-01', '2026-01-15', 12);

/* 6. Product_SKU Data (Owned by Sellers 10 and 14) */
INSERT INTO Product_SKU ([Bar code], Name, Stock, Price, sellerID) VALUES
('TSHIRT-RED-M', 'Red T-Shirt (M)', 100, 15.00, 10), -- Owned by Seller 10
('TSHIRT-BLU-L', 'Blue T-Shirt (L)', 50, 17.50, 10), -- Owned by Seller 10
('JEANS-BLK-32', 'Black Jeans (32)', 75, 40.00, 14), -- Owned by Seller 14
('SOCKS-WHT-OS', 'White Socks (Pack)', 200, 5.00, 10), -- Owned by Seller 10
('HAT-RED-ADJ', 'Red Hat (Adjustable)', 60, 12.00, 14); -- Owned by Seller 14

/* 7. Order Data (Placed by Buyers 11 and 13) */
INSERT INTO [Order] (ID, Total, Address, Time, userID) VALUES
(1011, 17.50, '123 Buyer St, HCMC', '2025-11-02 10:30:00', 11),
(1012, 40.00, '456 Buyer Rd, HCMC', '2025-11-03 14:00:00', 13),
(1013, 30.00, '123 Buyer St, HCMC', '2025-11-04 11:15:00', 11),
(1014, 5.00, '456 Buyer Rd, HCMC', '2025-11-05 16:45:00', 13),
(1015, 12.00, '123 Buyer St, HCMC', '2025-11-06 09:00:00', 11);

/* 8. Order_Item Data (Linking Orders to Products) */
INSERT INTO Order_Item (ID, orderID, Quantity, Price, BarCode) VALUES
(5001, 1011, 1, 17.50, 'TSHIRT-BLU-L'), -- Buyer 11 bought Seller 10's product
(5002, 1012, 1, 40.00, 'JEANS-BLK-32'), -- Buyer 13 bought Seller 14's product
(5003, 1013, 2, 15.00, 'TSHIRT-RED-M'), -- Buyer 11 bought Seller 10's product
(5004, 1014, 1, 5.00, 'SOCKS-WHT-OS'), -- Buyer 13 bought Seller 10's product
(5005, 1015, 1, 12.00, 'HAT-RED-ADJ'); -- Buyer 11 bought Seller 14's product

/* 9. Review Data */
INSERT INTO Review (ID, Time, Type) VALUES
(2001, '2025-11-05 18:00:00', 'Product Review'),
(2002, '2025-11-05 19:00:00', 'Product Review'),
(2003, '2025-11-06 18:00:00', 'Product Review'),
(2004, '2025-11-07 18:00:00', 'Product Review'),
(2005, '2025-11-08 18:00:00', 'Product Review');

/* 10. Write_review Data (Linking Reviews to Users and OrderItems) */
INSERT INTO Write_review (ReviewID, UserID, Order_itemID, OrderID) VALUES
(2001, 11, 5001, 1011), -- TEST CASE (PASS): Buyer 11 reviews their own order
(2002, 13, 5002, 1012), -- TEST CASE (PASS): Buyer 13 reviews their own order
(2003, 11, 5003, 1013), -- TEST CASE (PASS): Buyer 11 reviews another order
(2004, 13, 5004, 1014), -- TEST CASE (PASS): Buyer 13 reviews another order
(2005, 11, 5005, 1015); -- TEST CASE (PASS): Buyer 11 reviews another order

GO





/*
*
*   PART 2
*
*/
/*
CREATE PROCEDURE sp_CreateUser
    -- Common User attributes
    @ID INT,
    @Email VARCHAR(100),
    @Address VARCHAR(255),
    @FullName VARCHAR(100),
    @Rank VARCHAR(50), -- FK to Membership [cite: 162]
    @Gender VARCHAR(10),
    @DateOfBirth DATE, 

    -- User type and subclass attributes
    @UserType VARCHAR(10), -- 'Buyer', 'Seller', 'Admin', 'Shipper'
    @Role VARCHAR(50) = NULL, -- For Admin [cite: 201]
    @LicensePlate VARCHAR(15) = NULL, -- For Shipper [cite: 198]
    @Company VARCHAR(100) = NULL, -- For Shipper [cite: 198]
    @CartID INT = NULL -- For Buyer [cite: 196]
AS
BEGIN
    SET NOCOUNT ON;

    -- === 1. Validation (Requirement 2.1) ===
    IF EXISTS (SELECT 1 FROM [User] WHERE Email = @Email)
    BEGIN
        RAISERROR('Email address is already in use.', 16, 1); 
        RETURN;
    END;

    IF DATEDIFF(year, @DateOfBirth, GETDATE()) < 13
    BEGIN
        RAISERROR('User must be at least 13 years old.', 16, 1); 
        RETURN;
    END;

    IF @Gender IS NOT NULL AND @Gender NOT IN ('Male', 'Female')
    BEGIN
        RAISERROR('Gender must be ''Male'' or ''Female''.', 16, 1);
        RETURN;
    END;

    -- === 2. Data Insertion ===
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insert into the superclass table
        INSERT INTO [User] (ID, Email, [Address], [Full name], [Rank])
        VALUES (@ID, @Email, @Address, @FullName, @Rank);

        -- Insert into the correct subclass table
        IF @UserType = 'Buyer'
            INSERT INTO Buyer (userID, cartID) VALUES (@ID, @CartID);
        ELSE IF @UserType = 'Seller'
            INSERT INTO Seller (userID) VALUES (@ID);
        ELSE IF @UserType = 'Admin'
            INSERT INTO Admin (userID, Role) VALUES (@ID, @Role);
        ELSE IF @UserType = 'Shipper'
            INSERT INTO Shipper (userID, LicensePlate, Company) VALUES (@ID, @LicensePlate, @Company);
        ELSE
            RAISERROR('Invalid user type specified.', 16, 1);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Re-throw the original error
        THROW;
    END CATCH
END;
GO
*/
CREATE PROCEDURE sp_CreateUser
    -- Common User attributes
    @ID INT,
    @Email VARCHAR(100),
    @Address VARCHAR(255),
    @FullName VARCHAR(100),
    @Rank VARCHAR(50), -- FK to Membership [cite: 162]
    @Gender VARCHAR(10),
    @DateOfBirth DATE, 

    -- User type and subclass attributes
    @UserType VARCHAR(10), -- 'Buyer', 'Seller', 'Admin', 'Shipper'
    @Role VARCHAR(50) = NULL, -- For Admin [cite: 201]
    @LicensePlate VARCHAR(15) = NULL, -- For Shipper [cite: 198]
    @Company VARCHAR(100) = NULL, -- For Shipper [cite: 198]
    @CartID INT = NULL -- For Buyer [cite: 196]
AS
BEGIN
    SET NOCOUNT ON;

    -- === 1. Validation (Requirement 2.1) ===
    IF EXISTS (SELECT 1 FROM [User] WHERE Email = @Email)
    BEGIN
        RAISERROR('Email address is already in use.', 16, 1); 
        RETURN;
    END;

    IF DATEDIFF(year, @DateOfBirth, GETDATE()) < 13
    BEGIN
        RAISERROR('User must be at least 13 years old.', 16, 1); 
        RETURN;
    END;

    IF @Gender IS NOT NULL AND @Gender NOT IN ('Male', 'Female')
    BEGIN
        RAISERROR('Gender must be ''Male'' or ''Female''.', 16, 1);
        RETURN;
    END;

    -- === 2. Data Insertion ===
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insert into the superclass table
        INSERT INTO [User] (ID, Email, [Address], [Full name], [Rank])
        VALUES (@ID, @Email, @Address, @FullName, @Rank);

        -- Insert into the correct subclass table
        IF @UserType = 'Buyer'
            INSERT INTO Buyer (userID, cartID) VALUES (@ID, @CartID);
        ELSE IF @UserType = 'Seller'
            INSERT INTO Seller (userID) VALUES (@ID);
        ELSE IF @UserType = 'Admin'
            INSERT INTO Admin (userID, Role) VALUES (@ID, @Role);
        ELSE IF @UserType = 'Shipper'
            INSERT INTO Shipper (userID, LicensePlate, Company) VALUES (@ID, @LicensePlate, @Company);
        ELSE
            RAISERROR('Invalid user type specified.', 16, 1);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Re-throw the original error
        THROW;
    END CATCH
END;
GO




CREATE PROCEDURE sp_UpdateUser
    @UserID INT,
    @Address VARCHAR(255),
    @FullName VARCHAR(100),
    @Rank VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validation
    IF NOT EXISTS (SELECT 1 FROM [User] WHERE ID = @UserID)
    BEGIN
        RAISERROR('User ID not found.', 16, 1); 
        RETURN;
    END;

    -- Update the User table
    UPDATE [User]
    SET [Address] = @Address,
        [Full name] = @FullName,
        [Rank] = @Rank
    WHERE ID = @UserID;
END;
GO




CREATE PROCEDURE sp_DeleteUser
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    /*
    == Justification (Requirement 2.1) ==
    Deletion of a User is DISALLOWED if they have associated business records. 
    This is a soft-delete policy required to maintain historical integrity.
    A user cannot be deleted if they are a:
    1. Seller with products (Product_SKU) [cite: 167]
    2. Buyer with orders (Order) [cite: 160]
    3. Admin who created promotions (Promotion) [cite: 165]
    4. Shipper with deliveries (Deliver) [cite: 188]
    5. Buyer who wrote reviews (Write_review) [cite: 190]
    
    Instead of hard deletion, an 'IsActive' flag (which you should add to your 
    User table) would be set to 0. For this assignment, we will simply 
    prevent the delete and raise an error.
    */

    -- Validation
    IF EXISTS (SELECT 1 FROM Product_SKU WHERE sellerID = @UserID) OR
       EXISTS (SELECT 1 FROM [Order] WHERE userID = @UserID) OR
       EXISTS (SELECT 1 FROM Promotion WHERE AdminID = @UserID) OR
       EXISTS (SELECT 1 FROM Deliver WHERE ShiperID = @UserID) OR
       EXISTS (SELECT 1 FROM Write_review WHERE UserID = @UserID)
    BEGIN
        RAISERROR('Cannot delete user. This user has associated products, orders, or other business records.', 16, 1);
        RETURN;
    END;

    -- If no records found, proceed with deletion from all tables
    -- (Must delete from subclass tables first)
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM Buyer WHERE userID = @UserID;
        DELETE FROM Seller WHERE userID = @UserID;
        DELETE FROM [Admin] WHERE userID = @UserID;
        DELETE FROM Shipper WHERE userID = @UserID;
        
        -- Finally, delete from the superclass table
        DELETE FROM [User] WHERE ID = @UserID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('An error occurred during deletion. No data was changed.', 16, 1);
        THROW;
    END CATCH
END;
GO


-- 2.2. TRIGGER
CREATE TRIGGER trg_CheckSellerReview
ON Write_review
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the user writing the review is the seller of the product
    IF EXISTS (
        SELECT 1
        FROM inserted i
        -- Find the product associated with the review
        JOIN Order_Item oi ON i.Order_itemID = oi.ID AND i.OrderID = oi.orderID 
        -- Find the seller of that product
        JOIN Product_SKU p ON oi.BarCode = p.[Bar code] 
        -- Check if the reviewer's ID matches the seller's ID
        WHERE i.UserID = p.sellerID 
    )
    BEGIN
        -- If a match is found, violate the rule
        RAISERROR('Sellers are not permitted to review their own products. The review has been cancelled.', 16, 1);
        ROLLBACK TRANSACTION; -- Cancel the INSERT
    END;
END;
GO




-- 2.3. Query Stored Procedures
CREATE PROCEDURE sp_SearchUsers
    @SearchName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Joins User (Table 10) and Membership (Table 5)
    SELECT 
        U.ID, 
        U.[Full name], 
        U.Email, 
        U.[Address],
        M.[Rank], 
        M.[Loyalty Point]
    FROM 
        [User] U
    JOIN 
        Membership M ON U.[Rank] = M.[Rank]
    WHERE 
        U.[Full name] LIKE '%' + @SearchName + '%' -- Input parameter in WHERE
    ORDER BY 
        U.[Full name]; -- ORDER BY clause
END;
GO



CREATE PROCEDURE sp_GetUserActivityReport
    @MinOrderCount INT,
    @StartDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Joins User (Table 10), Buyer (Table 21), and Order (Table 9)
    SELECT 
        U.[Full name],
        U.Email,
        COUNT(O.ID) AS TotalOrders, -- Aggregate function
        SUM(O.Total) AS TotalSpent -- Aggregate function
    FROM 
        [User] U
    JOIN 
        Buyer B ON U.ID = B.userID 
    JOIN 
        [Order] O ON B.userID = O.userID 
    WHERE 
        O.Time >= @StartDate -- WHERE clause
    GROUP BY 
        U.ID, U.[Full name], U.Email -- GROUP BY clause
    HAVING 
        COUNT(O.ID) >= @MinOrderCount -- HAVING clause with input parameter
    ORDER BY 
        TotalSpent DESC; -- ORDER BY clause
END;
GO


/*
*
*   PART 3
*
*/


