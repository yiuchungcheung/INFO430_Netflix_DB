
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

-- (stored procedure) get customer id
GO
alter procedure proj_02_getcustID
@custFname Varchar(100),
@custLname varchar(100),
@cust_ID INT output
as 
Begin
SET @cust_ID = (SELECT customerID from tblCustomer where CustomerFName = @custFname and CustomerLname = @custLname)
IF @cust_ID IS NULL 
  BEGIN;
    THROW 54352, 'cust_ID is null, terminating', 1;
  END 
END

-- (stored procedure) get content id
go
Alter procedure proj_02_getcontentID
@contentName Varchar(500),
@content_ID INT output
as 
Begin
SET @content_ID = (SELECT contentID from tblContent where Contentname = @contentname)
IF @content_ID IS NULL 
  BEGIN;
    THROW 54352, 'content_ID is null, terminating', 1;
  END 
END



SELECT * FROM tblCUSTOMER

DELETE FROM tblCUSTOMER;


-- populating tblCustomer with a synthetic transaction
GO
CREATE PROCEDURE cheuny_synth_tran_customer_info430
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

insert into tblcustomer(CustomerFName, CustomerLname, CustomerDOB, CustomerStreetAddress, CustomerCity, CustomerState, CustomerZipCode, CustomerTypeID)
select top 5000 CustomerFname, CustomerLname, CustomerDOB, CustomerStreetAddress, CustomerCity, CustomerState, CustomerZIPcode, (select (floor(rand()*3)+1))
from [INFO_430_Proj_02].dbo.[tblCUSTOMER]

-- create 5000 customer transactions
EXEC cheuny_synth_tran_customer_info430 @run = 5000

EXEC sp_fkeys 'tblContent_Type'


-- Throws error
DROP TABLE dbo.tblContent

-- find which table has that Foreign Key Constraint that is referencing to this table.
SELECT Schema_Name(Schema_id) as TableSchemaName,
  object_name(FK.parent_object_id) ParentTableName,
  object_name(FK.referenced_object_id) ReferenceTableName
       FROM sys.foreign_keys AS FK
       WHERE object_name(FK.referenced_object_id)='tblContent'
       and Schema_Name(Schema_id)='dbo'

-- Find the constraint 
;With CTE_FK AS (
SELECT Schema_Name(Schema_id) as TableSchemaName,
  object_name(FK.parent_object_id) ParentTableName,
  object_name(FK.referenced_object_id) ReferenceTableName,
  FK.name AS ForeignKeyConstraintName,c.name as ReferencedColumnList,
  cf.name as ParentColumnName 
       FROM sys.foreign_keys AS FK
       INNER JOIN sys.foreign_key_columns AS FKC
               ON FK.OBJECT_ID = FKC.constraint_object_id
               INNER JOIN sys.columns c
          on  c.OBJECT_ID = FKC.referenced_object_id
                 AND c.column_id = FKC.referenced_column_id
                 INNER JOIN sys.columns cf
          on  cf.OBJECT_ID = FKC.parent_object_id
                 AND cf.column_id = FKC.parent_column_id
                 )
                 Select TableSchemaName,
                 ParentTableName,
                 ReferenceTableName,
                 ForeignKeyConstraintName,stuff((
                 Select ','+ParentColumnName
                 from CTE_FK i
                 where i.ForeignKeyConstraintName=o.ForeignKeyConstraintName
                 and i.TableSchemaName=o.TableSchemaName
                 and i.ParentTableName=o.ParentTableName
                 and i.ReferenceTableName=o.ReferenceTableName
                 for xml path('')), 1, 1, '') ParentColumnList
                 ,stuff((
                 Select ','+ReferencedColumnList
                 from CTE_FK i
                 where i.ForeignKeyConstraintName=o.ForeignKeyConstraintName
                 and i.TableSchemaName=o.TableSchemaName
                 and i.ParentTableName=o.ParentTableName
                 and i.ReferenceTableName=o.ReferenceTableName
                 for xml path('')), 1, 1, '') RefColumnList
                 from CTE_FK o
                 group by 
                 tableSchemaName,
                 ParentTableName,
                 ReferenceTableName,
                 ForeignKeyConstraintName


-- drop the constraint
ALTER TABLE tblContent 
DROP CONSTRAINT FK__tblCONTEN__Conte__5812160E

-- drop the column 
ALTER TABLE tblContent
DROP COLUMN ContentTypeID


SELECT * FROM tblRATING
-- (Computed Column) Find the average rating for each audience
GO
Create FUNCTION fn_avg_aud_rating (@pk int)
RETURNS FLOAT
AS
    BEGIN
        DECLARE @RET FLOAT = (SELECT (SUM(r.NumRating)/COUNT(r.NumRating))
                            FROM tblCUSTOMER C
                            JOIN tblStreaming S ON C.CUSTOMERID = S.CUSTOMERID
                            JOIN tblRATING R on S.RatingID = R.RatingID
                            WHERE C.CUSTOMERID = @pk)
        RETURN @ret
	END
GO


ALTER TABLE tblCUSTOMER
ADD AVG_Customer_rating AS (dbo.fn_avg_aud_rating(CUSTOMERID))

-- use when still null 
ALTER TABLE tblCustomer
DROP COLUMN AVG_Customer_rating;

select * from tblcustomer where AVG_Customer_rating IS NULL


-- (Computed Column) Get the average rating of each movie genre

GO
CREATE FUNCTION fn_avg_genre_rating (@pk int)
RETURNS FLOAT
AS
    BEGIN
        DECLARE @RET FLOAT = (SELECT (SUM(r.NumRating)/COUNT(r.NumRating))
                            FROM tblRating R
                            JOIN tblSTREAMING S on R.ratingID = S.ratingID
                            JOIN tblCONTENT C on S.ContentID = C.ContentID
                            JOIN tblGENRE_CONTENT GC ON C.ContentID = GC.ContentID
                            JOIN tblGENRE G on GC.GenreID = G.GenreID
                            WHERE G.GENREID = @pk)
        RETURN @ret
	END
GO
ALTER TABLE tblGENRE
ADD AVG_genre_rating AS (dbo.fn_avg_genre_rating(GenreID))

-- use when still null 
ALTER TABLE tblGenre
DROP COLUMN AVG_genre_rating;


-- (business rule) Movie ratings must be over 3 Stars to be available for customers

GO 
CREATE FUNCTION fn_goodqualitymoviesonly()
RETURNS INT 
AS
BEGIN 
	DECLARE @RET INT = 0
	IF EXISTS
	(SELECT *
  FROM tblRating R
  JOIN tblSTREAMING S on R.RatingID = S.ratingID
  JOIN tblCONTENT C on S.ContentID = C.ContentID
	WHERE r.numrating > 3
	)
	SET @RET = 1
	RETURN @RET 
	END 
	GO

	ALTER TABLE tblContent WITH NOCHECK
	ADD CONSTRAINT goodmoviesonly
	CHECK (dbo.fn_goodqualitymoviesonly() = 0)

-- (business rule) No personnel under the age of 18 can work on an R rated movie

GO 
CREATE FUNCTION fn_underageWorkerRestriction()
RETURNS INT 
AS
BEGIN 
	DECLARE @RET INT = 0
	IF EXISTS
	(SELECT *
  FROM tblAudience A 
  JOIN tblCONTENT C on A.AudienceID = c.AudienceID
  JOIN tblCREDIT CR on C.ContentID = CR.ContentID
  JOIN tblPERSONNEL P on CR.PersonnelID = P.PersonnelID
	WHERE P.PersonnelDOB > DATEADD(YEAR, -18, GETDATE())
	)
	SET @RET = 1
	RETURN @RET 
	END 
	GO

	ALTER TABLE tblContent WITH NOCHECK
	ADD CONSTRAINT peopleUnder18NoRatedR
	CHECK (dbo.fn_underageWorkerRestriction() = 0)


SELECT * FROM tblAUDIENCE
-- (business rule) Netflix can only have 50 R rated movies 

GO 
CREATE FUNCTION fn_limitsusmovies()
RETURNS INT 
AS
BEGIN 
	DECLARE @RET INT = 0
	IF EXISTS
	(SELECT A.AudienceType, COUNT(C.ContentName) as movies
  FROM tblAUDIENCE A
  JOIN tblCONTENT C on A.AudienceID = c.AudienceID
  WHERE A.AudienceType = 'R'
	GROUP BY A.AudienceType
  HAVING COUNT(C.ContentName) > 50
	)
	SET @RET = 1
	RETURN @RET 
	END 
	GO

	ALTER TABLE tblContent WITH NOCHECK
	ADD CONSTRAINT limitsusmovies
	CHECK (dbo.fn_limitsusmovies() = 0)

-- (Case) Group and count customers in the categories: under 26, between 26 and 35, over 35 
-- (no outputs, get rid) under English movies with the Comedy genre that are produced by Warner Bros

SELECT ( CASE
        WHEN ageGroup < 26
        THEN 'Millennials'
        WHEN ageGroup BETWEEN 26 and 35
        THEN 'between 25 and 35'
        ELSE 'Boomers'
end) as bucket, COUNT(*) as numberOfPeeps
FROM ( select c.customerID, datediff(year, c.customerdob, getdate()) as ageGroup
        FROM tblCustomer C 
        -- JOIN tblstreaming S on c.CustomerID = s.CustomerID 
        -- JOIN tblContent CO on s.ContentID = co.ContentID
        -- JOIN tblLanguage_Content LC on Co.ContentID = LC.ContentID
        -- JOIN tblLanguage L on lc.LanguageID = l.LanguageID
        -- JOIN tblGenre_Content GC on co.ContentID = gc.ContentID
        -- JOIN tblGenre G on gc.GenreID = G.GenreID
        -- JOIN tblCredit CR on co.ContentID = cr.ContentID 
        -- JOIN tblPRODUCTION P on CR.ProductionID = p.ProductionID

        -- WHERE L.LanguageShortName = 'en'
        -- AND g.GenreName = 'Comedy'
        -- AND p.ProductionName = 'Warner Bros. Pictures'
        GROUP BY c.customerID, datediff(year, c.customerdob, getdate())
) as A GROUP BY ( CASE
        WHEN ageGroup < 26
        THEN 'Millennials'
        WHEN ageGroup BETWEEN 26 and 35
        THEN 'between 25 and 35'
        ELSE 'Boomers'
end)

ORDER BY numberofpeeps DESC



SELECT * FROM tblPRODUCTION

-- Get the average rating of movies that have a status of ‘Inactive’ and ‘Active’ (to compare later) (not sure what our statuses will be named)

SELECT s.statusname, (SUM(r.NumRating)/COUNT(r.NumRating)) AS avg_rating
FROM tblStatus s
JOIN tblHISTORY H on s.StatusID = h.StatusID
JOIN tblContent C On h.ContentID = c.ContentID
JOIN tblSTREAMING st on c.ContentID = st.ContentID
JOIN tblRATING r on st.RatingID = r.RatingID
WHERE s.StatusName = 'released' OR s.statusname = 'canceled'
GROUP BY s.statusname

SELECT * FROM tblStreaming s JOIN tblCustomer c on s.customerid = c.CustomerID


-- create view for streams with 5 star ratings and through Ultra HD 
GO
ALTER VIEW ultraHD_5Star_streams AS
SELECT s.streamingID, CO.ContentName, StreamingQuality, r.NumRating
FROM tblSTREAMING S 
JOIN tblCustomer C ON s.CustomerID = C.CustomerID
JOIN tblRATING R on s.RatingID = r.RatingID
JOIN tblContent CO on s.ContentID = CO.ContentID
WHERE s.StreamingQuality = 'Ultra HD'
AND r.NumRating = 5

GO
SELECT * FROM ultraHD_5star_streams

-- create view for customers with average ratings above a 3 star
GO
CREATE VIEW above_3_customer_ratings AS
SELECT c.customerID, c.customerFname, C.customerLname, c.avg_customer_rating
FROM tblCustomer C
JOIN tblSTREAMING S on C.CustomerID = S.CustomerID
JOIN tblRATING R on S.RatingID = R.ratingID
WHERE c.AVG_Customer_rating > 3

GO

SELECT * FROM above_3_customer_ratings

