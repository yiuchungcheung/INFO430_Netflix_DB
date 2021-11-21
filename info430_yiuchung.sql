
-- populating tblcustomer_type
BEGIN TRAN populate_tblCustomer_Type

INSERT INTO tblCUSTOMER_TYPE(CustomerTypeName, CustomerTypeDesc)
VALUES('Basic', '$8.99/month, you can watch on 1 screen at the same time, you can have 1 phone/tablet to have downloads on, Unlimited movies, TV shows and mobile games, Watch on your laptop, TV, phone and tablet')

INSERT INTO tblCUSTOMER_TYPE(CustomerTypeName, CustomerTypeDesc)
VALUES('Standard', '$13.99/month, you can watch on 2 screens at the same time, you can have 2 phones/tablets to have downloads on, Unlimited movies, TV shows and mobile games, Watch on your laptop, TV, phone and tablet, HD available')

INSERT INTO tblCUSTOMER_TYPE(CustomerTypeName, CustomerTypeDesc)
VALUES('Premium', '$17.99/month, you can watch on 4 screens at the same time, you can have 4 phones/tablets to have downloads on, Unlimited movies, TV shows and mobile games, Watch on your laptop, TV, phone and tablet, HD available, Ultra HD available')


COMMIT TRAN populate_tblCustomer_Type

SELECT * FROM tblCUSTOMER_TYPE


SELECT * FROM tblCUSTOMER

DELETE FROM tblCUSTOMER;


-- populating tblCustomer with a synthetic transaction
GO
CREATE PROCEDURE cheuny_synth_tran_customer
@RUN INT

AS 

DECLARE @customerTypePK INT, @customerPK INT
DECLARE @cusFirstname VARCHAR(50), @cusLastname VARCHAR(50), @custAddy VARCHAR(100), @custyCity VARCHAR(50), @custState VARCHAR(50), @custZip INT, @custDOB DATE
DECLARE @cust_count INT = (SELECT COUNT(*) FROM [PEEPS].dbo.[tblCUSTOMER])
DECLARE @cust_type_count INT = (SELECT COUNT(*) FROM [tblCUSTOMER_TYPE])

WHILE @RUN > 0 
BEGIN 
    SET @customerTypePK = (SELECT RAND()*@cust_type_count + 1)
    SET @customerPK = (SELECT RAND()*@cust_count + 1)
    SET @cusFirstname = (SELECT CustomerFname FROM [PEEPS].dbo.[tblCUSTOMER] WHERE CustomerID = @customerPK)
    SET @cusLastname = (SELECT CustomerLname FROM [PEEPS].dbo.[tblCUSTOMER] WHERE CustomerID = @customerPK)
    SET @custDOB = (SELECT DateOfBirth FROM [PEEPS].dbo.[tblCUSTOMER] WHERE CustomerID = @customerPK)
    SET @custAddy = (SELECT CustomerAddress FROM [PEEPS].dbo.[tblCUSTOMER] WHERE CustomerID = @customerPK)
    SET @custyCity = (SELECT CustomerCity FROM [PEEPS].dbo.[tblCUSTOMER] WHERE CustomerID = @customerPK)
    SET @custState = (SELECT CustomerState FROM [PEEPS].dbo.[tblCUSTOMER] WHERE CustomerID = @customerPK)
    SET @custZip = (SELECT CustomerZIP FROM [PEEPS].dbo.[tblCUSTOMER] WHERE CustomerID = @customerPK)

    INSERT INTO tblCustomer (CustomerTypeID, CustomerFname, CustomerLName, CustomerDOB, CustomerStreetAddress, CustomerCity, CustomerState, CustomerZipCode)
    VALUES(@customerTypePK, @cusFirstname, @cusLastname, @custDOB, @custAddy, @custyCity, @custState, @custZip)

    SET @RUN = @RUN - 1
END

-- create 5000 customer transactions
EXEC cheuny_synth_tran_customer @run = 5000






