USE ASSIGNMENT
GO


-- UNIT TEST
PRINT 'Running Test 1.1: Check Row Counts...';

IF (SELECT COUNT(*) FROM PhoneNumbers) = 5
    PRINT '  [PASS] PhoneNumbers row count is 5.';
ELSE
    PRINT '  [FAIL] PhoneNumbers row count is NOT 5.';

IF (SELECT COUNT(*) FROM Reactions) = 5
    PRINT '  [PASS] Reactions row count is 5.';
ELSE
    PRINT '  [FAIL] Reactions row count is NOT 5.';

IF (SELECT COUNT(*) FROM Replies) = 5
    PRINT '  [PASS] Replies row count is 5.';
ELSE
    PRINT '  [FAIL] Replies row count is NOT 5.';

IF (SELECT COUNT(*) FROM Pay) = 5
    PRINT '  [PASS] Pay row count is 5.';
ELSE
    PRINT '  [FAIL] Pay row count is NOT 5.';

IF (SELECT COUNT(*) FROM Deliver) = 5
    PRINT '  [PASS] Deliver row count is 5.';
ELSE
    PRINT '  [FAIL] Deliver row count is NOT 5.';


PRINT 'Running Test 1.2: Check Specific Data Integrity...';

IF EXISTS (
    SELECT 1
    FROM Pay
    WHERE BuyerID = 1 AND OrderID = 1001 AND TransactionID = 2001
)
    PRINT '  [PASS] Pay record for Order 1001 is correct.';
ELSE
    PRINT '  [FAIL] Pay record for Order 1001 is missing or incorrect.';

PRINT 'Running Test 2.1: Primary Key Violation (PhoneNumbers)...';
BEGIN TRANSACTION;
BEGIN TRY
    -- Try to insert a duplicate phone number
    INSERT INTO PhoneNumbers (userID, aPhoneNum) VALUES (1, '0909111222');

    -- If we get here, the constraint failed
    PRINT '  [FAIL] Duplicate PK was allowed in PhoneNumbers.';
END TRY
BEGIN CATCH
    -- This is the success path!
    PRINT '  [PASS] PK constraint correctly blocked duplicate in PhoneNumbers.';
    PRINT '         Error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 2.2: Foreign Key Violation (Pay)...';
BEGIN TRANSACTION;
BEGIN TRY
    -- Try to insert an orphaned record
    INSERT INTO Pay (BuyerID, OrderID, TransactionID) VALUES (1, 9999, 2001);

    PRINT '  [FAIL] Orphaned record (non-existent OrderID) was allowed in Pay.';
END TRY
BEGIN CATCH
    PRINT '  [PASS] FK constraint correctly blocked orphaned record in Pay.';
    PRINT '         Error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 2.3: NOT NULL Violation (Deliver)...';
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO Deliver (ShiperID, OrderID, VehicleID) VALUES (3, NULL, 401);

    PRINT '  [FAIL] NULL value was allowed in Deliver.OrderID.';
END TRY
BEGIN CATCH
    PRINT '  [PASS] NOT NULL constraint correctly blocked NULL in Deliver.OrderID.';
    PRINT '         Error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 3.1: CHECK Violation (Reactions.Type)...';
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO Reactions (ReviewID, Type, Author) VALUES (3001, 'Boring', 'TestUser');

    PRINT '  [FAIL] Invalid value ''Boring'' was allowed in Reactions.Type.';
END TRY
BEGIN CATCH
    PRINT '  [PASS] CHECK constraint correctly blocked invalid value in Reactions.Type.';
    PRINT '         Error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 3.2: CHECK Boundary Violation (Deliver.Distance)...';
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO Deliver (ShiperID, OrderID, VehicleID, Distance) 
    VALUES (3, 1001, 401, 0);

    PRINT '  [FAIL] Value 0 was allowed in Deliver.Distance.';
END TRY
BEGIN CATCH
    PRINT '  [PASS] CHECK constraint (Distance > 0) correctly blocked 0.';
    PRINT '         Error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 3.3: CHECK Happy Path (Deliver.Distance)...';
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO Deliver (ShiperID, OrderID, VehicleID, Distance) 
    VALUES (4, 1001, 402, 0.1);

    -- Check if the row was actually inserted
    IF EXISTS (SELECT 1 FROM Deliver WHERE OrderID = 1001 AND Distance = 0.1)
        PRINT '  [PASS] Valid boundary value (0.1) was correctly inserted.';
    ELSE
        PRINT '  [FAIL] Valid boundary value was NOT inserted.';

END TRY
BEGIN CATCH
    PRINT '  [FAIL] CHECK constraint incorrectly blocked a valid value (0.1).';
    PRINT '         Error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;


SELECT * FROM Cart;

/*
* PART 2 
*/

PRINT 'Running Test 1.1: Happy Path - Create new Buyer...';
BEGIN TRANSACTION;

INSERT Cart (ID) VALUES (999); -- Why insert Cart before insert user?
GO

EXEC sp_CreateUser
    @ID = 99, @Email = 'newbuyer@example.com', @Address = 'Test Address', 
    @FullName = 'Test Buyer', @Rank = 'Bronze', @Gender = 'Female', 
    @DateOfBirth = '2000-01-01', @UserType = 'Buyer', @CartID = 999;

IF EXISTS (SELECT 1 FROM [User] WHERE ID = 99) AND EXISTS (SELECT 1 FROM Buyer WHERE userID = 99)
    PRINT '  [PASS] User 99 created in [User] and [Buyer] tables.';
ELSE
    PRINT '  [FAIL] User 99 was NOT created correctly.';

ROLLBACK TRANSACTION;


PRINT 'Running Test 2.1: Error Condition - Delete Seller with Products...';
BEGIN TRANSACTION;
BEGIN TRY
    EXEC sp_DeleteUser @UserID = 10; -- Seller 10
    PRINT '  [FAIL] Procedure did NOT block deletion of Seller with products.';
END TRY
BEGIN CATCH
    IF ERROR_MESSAGE() LIKE 'Cannot delete user.%'
        PRINT '  [PASS] Procedure correctly blocked deletion of Seller with products.';
    ELSE
        PRINT '  [FAIL] Procedure raised an unexpected error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 2.2: Error Condition - Delete Buyer with Orders...';
BEGIN TRANSACTION;
BEGIN TRY
    EXEC sp_DeleteUser @UserID = 11; -- Buyer 11
    PRINT '  [FAIL] Procedure did NOT block deletion of Buyer with orders.';
END TRY
BEGIN CATCH
    IF ERROR_MESSAGE() LIKE 'Cannot delete user.%'
        PRINT '  [PASS] Procedure correctly blocked deletion of Buyer with orders.';
    ELSE
        PRINT '  [FAIL] Procedure raised an unexpected error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 2.3: Happy Path - Delete User with No Dependencies...';
BEGIN TRANSACTION;

INSERT Cart (ID) VALUES (999); -- Why insert Cart before insert user?
GO

-- 1. Create the new user
EXEC sp_CreateUser
    @ID = 99, @Email = 'newbuyer@example.com', @Address = 'Test', 
    @FullName = 'Test', @Rank = 'Bronze', @Gender = 'Male', 
    @DateOfBirth = '2000-01-01', @UserType = 'Buyer', @CartID = 999;

-- 2. Run the procedure to delete them
EXEC sp_DeleteUser @UserID = 99;

-- 3. Assert
IF NOT EXISTS (SELECT 1 FROM [User] WHERE ID = 99)
    PRINT '  [PASS] Procedure successfully deleted user with no dependencies.';
ELSE
    PRINT '  [FAIL] Procedure failed to delete the user.';

ROLLBACK TRANSACTION;

PRINT 'Running Test 3.1: Error Condition - Seller Reviews Own Product...';
BEGIN TRANSACTION;
BEGIN TRY
    -- First, add a new Review record to reference
    INSERT INTO Review (ID, Type) VALUES (2006, 'Product Review');

    -- This is the insert that should fail. User 10 (Seller) reviews Order_Item 5001.
    -- Order_Item 5001 is for Product 'TSHIRT-BLU-L', which is sold by User 10.
    INSERT INTO Write_review (ReviewID, UserID, Order_itemID, OrderID)
    VALUES (2006, 10, 5001, 1011); 

    PRINT '  [FAIL] Trigger did NOT block seller from reviewing own product.';
END TRY
BEGIN CATCH
    IF ERROR_MESSAGE() LIKE 'Sellers are not permitted to review their own products.%'
        PRINT '  [PASS] Trigger correctly blocked seller from reviewing own product.';
    ELSE
        PRINT '  [FAIL] Trigger raised an unexpected error: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 3.2: Happy Path - Buyer Reviews Product...';
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO Review (ID, Type) VALUES (2006, 'Product Review');

    -- Buyer 13 reviews Order_Item 5002
    INSERT INTO Write_review (ReviewID, UserID, Order_itemID, OrderID)
    VALUES (2006, 13, 5002, 1012); 

    IF EXISTS (SELECT 1 FROM Write_review WHERE ReviewID = 2006 AND UserID = 13)
        PRINT '  [PASS] Trigger correctly allowed Buyer to write review.';
    ELSE
        PRINT '  [FAIL] Trigger failed, Buyer review was not inserted.';
END TRY
BEGIN CATCH
    PRINT '  [FAIL] Trigger incorrectly blocked Buyer review: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;

PRINT 'Running Test 3.3: Edge Case - Seller Reviews Another Seller''s Product...';
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO Review (ID, Type) VALUES (2006, 'Product Review');

    -- Seller 14 reviews Order_Item 5001 (sold by Seller 10). This is allowed.
    INSERT INTO Write_review (ReviewID, UserID, Order_itemID, OrderID)
    VALUES (2006, 14, 5001, 1011); 

    IF EXISTS (SELECT 1 FROM Write_review WHERE ReviewID = 2006 AND UserID = 14)
        PRINT '  [PASS] Trigger correctly allowed Seller to review another Seller''s product.';
    ELSE
        PRINT '  [FAIL] Trigger failed, Seller review was not inserted.';
END TRY
BEGIN CATCH
    PRINT '  [FAIL] Trigger incorrectly blocked Seller review: ' + ERROR_MESSAGE();
END CATCH
ROLLBACK TRANSACTION;


PRINT 'Running Test 4.1: Query - sp_SearchUsers...';

-- Create a temp table to hold results
CREATE TABLE #TestResults (ID INT, FullName VARCHAR(100), Email VARCHAR(100), Address VARCHAR(255), Rank VARCHAR(50), LoyaltyPoint INT);

-- Test 4.1a: Find specific user
INSERT INTO #TestResults EXEC sp_SearchUsers @SearchName = 'Huynh Nhat Huy';
IF (SELECT COUNT(*) FROM #TestResults) = 2
    PRINT '  [PASS] Found 2 user for "Huynh Nhat Huy". Note: One for Part 1, One for Part 2'; -- One for Part 1, One for Part 2
ELSE
    PRINT '  [FAIL] Did not find 2 user for "Huynh Nhat Huy".';
TRUNCATE TABLE #TestResults;

-- Test 4.1b: Find partial name
INSERT INTO #TestResults EXEC sp_SearchUsers @SearchName = 'Hu';
IF (SELECT COUNT(*) FROM #TestResults) = 5 -- Huy, Hung
    PRINT '  [PASS] Found 5 users for "Hu". Note: Three for Part 1, Two for Part 2';
ELSE
    PRINT '  [FAIL] Did not find 5 users for "Hu".';
TRUNCATE TABLE #TestResults;

-- Test 4.1c: Find no user
INSERT INTO #TestResults EXEC sp_SearchUsers @SearchName = 'zzxxyy';
IF (SELECT COUNT(*) FROM #TestResults) = 0
    PRINT '  [PASS] Found 0 users for "zzxxyy".';
ELSE
    PRINT '  [FAIL] Did not find 0 users for "zzxxyy".';

DROP TABLE #TestResults;

PRINT 'Running Test 4.2: Query - sp_GetUserActivityReport...';

CREATE TABLE #ReportResults (FullName VARCHAR(100), Email VARCHAR(100), TotalOrders INT, TotalSpent DECIMAL(10,2));

-- Test 4.2a: Boundary Value (Min 3 orders). User 11 has 3 orders.
INSERT INTO #ReportResults EXEC sp_GetUserActivityReport @MinOrderCount = 3, @StartDate = '2000-01-01';
IF (SELECT COUNT(*) FROM #ReportResults) = 2
    PRINT '  [PASS] Found 2 user with >= 3 orders. Note: One from Part 1, One from Part 2';
ELSE
    PRINT '  [FAIL] Did not find 2 user with >= 3 orders.';
TRUNCATE TABLE #ReportResults;

-- Test 4.2b: Boundary Value (Min 4 orders).
INSERT INTO #ReportResults EXEC sp_GetUserActivityReport @MinOrderCount = 4, @StartDate = '2000-01-01';
IF (SELECT COUNT(*) FROM #ReportResults) = 0
    PRINT '  [PASS] Found 0 users with >= 4 orders.';
ELSE
    PRINT '  [FAIL] Did not find 0 users with >= 4 orders.';
TRUNCATE TABLE #ReportResults;

-- Test 4.2c: Date Filter. Filter out all orders.
INSERT INTO #ReportResults EXEC sp_GetUserActivityReport @MinOrderCount = 1, @StartDate = '2026-01-01';
IF (SELECT COUNT(*) FROM #ReportResults) = 0
    PRINT '  [PASS] Found 0 users with orders after 2026.';
ELSE
    PRINT '  [FAIL] Did not find 0 users with orders after 2026.';

DROP TABLE #ReportResults;
