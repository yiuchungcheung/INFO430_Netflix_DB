USE INFO_430_Proj_02a

--- GET ID FOR RATINGID
CREATE PROCEDURE alycin_getRatingID
@g_RN varchar(50),
@g_RSN varchar(30),
@g_R_ID INT OUTPUT
AS 
SET @g_R_ID = (SELECT RatingID FROM tblRATING WHERE RatingName = @g_RN AND RatingShortName = @g_RSN)
GO

--- BASE INSERT PROCEDURE: INSERT ROW TO TBL STREAMING
CREATE PROCEDURE alycin_INSERT_Streaming
@CusFname varchar(100),
@CusLname varchar(100),
@ContentName varchar(50),
@StreamDate DATE, 
@StreamQual VARCHAR(50),
@RN varchar(50),
@RSN varchar(30)
AS 
BEGIN
    DECLARE @Cont_ID INT, @Cust_ID INT, @Rate_ID INT

    EXEC proj_02_getcontentID
    @contentName = @ContentName,
    @content_ID = @Cont_ID OUTPUT
    IF @Cont_ID IS NULL
    BEGIN;
		THROW 53001, '@Cont_ID cannot be null', 1;
	END

    EXEC proj_02_getcustID
    @custFname = @CusFname,
    @custLname = @CusLname,
    @cust_ID = @Cust_ID OUTPUT
    IF @Cust_ID IS NULL
	BEGIN;
		THROW 53001, '@Cust_ID cannot be null', 1;
	END

    EXEC alycin_getRatingID
    @g_RN = @RN,
    @g_RSN = @RSN,
    @g_R_ID = @Rate_ID OUTPUT
    IF @Rate_ID IS NULL
	BEGIN;
		THROW 53001, '@Rate_ID cannot be null', 1;
	END

    BEGIN TRAN T1
	INSERT INTO tblSTREAMING(CustomerID, ContentID, RatingID, StreamingDate, StreamingQuality)
	values(@Cust_ID, @Cont_ID, @Rate_ID, @StreamDate, @StreamQual)

	IF @@ERROR <> 0 or @@TRANCOUNT <> 1
	BEGIN
		ROLLBACK TRAN T1
	END
	ELSE
		COMMIT TRAN T1
END
GO

--- SYNTHETIC TRANSACTION TO INSERT ROWS INTO STREAMING
ALTER PROCEDURE alycin_Wrapper_INSERT_tblSTREAMING
@RUN INT
AS
DECLARE @CustPK INT, @ContPK INT, @RatePK INT
DECLARE @CustCount INT = (SELECT COUNT(*) FROM tblCUSTOMER)
DECLARE @ContCount INT = (SELECT COUNT(*) FROM tblCONTENT)
DECLARE @RateCount INT = (SELECT COUNT(*) FROM tblRATING)
DECLARE @test_F varchar(50), @test_L varchar(50), @test_CN varchar(50), @test_RN varchar(50), @test_RSN VARCHAR(30), @test_SQ varchar(50), @test_SD DATE, @start DATE, @end DATE
DECLARE @rand_SQ INT

WHILE @RUN > 0
BEGIN
    SET @CustPK = (SELECT RAND() * @CustCount + (SELECT MIN(CustomerID) FROM tblCustomer))
    PRINT(@CustPK)
    SET @test_F = (SELECT CustomerFName FROM tblCUSTOMER WHERE CustomerID = @CustPK)
    WHILE @test_F IS NULL
        BEGIN
            SET @CustPK = (SELECT RAND() * @CustCount + (SELECT MIN(CustomerID) FROM tblCustomer))
            SET @test_F = (SELECT CustomerFName FROM tblCUSTOMER WHERE CustomerID = @CustPK)
            BREAK
        END

    PRINT(@test_F)
    SET @test_L = (SELECT CustomerLName FROM tblCUSTOMER WHERE CustomerID = @CustPK)
    PRINT(@test_L)

    SET @ContPK = (SELECT RAND() * @ContCount + (SELECT MIN(ContentID) FROM tblContent))
    SET @test_CN = (SELECT ContentName from tblCONTENT WHERE ContentID = @ContPK)

    SET @RatePK = (SELECT RAND() * @RateCount + 1)
    SET @test_RN = (SELECT RatingName from tblRATING WHERE RatingID = @RatePK)
    SET @test_RSN = (SELECT RatingShortName from tblRATING WHERE RatingID = @RatePK)

    SET @start = '1980-01-01'
    SET @end = '2020-12-31'
    SET @test_SD = (SELECT DATEADD(DAY,ABS(CHECKSUM(NEWID())) % ( 1 + DATEDIFF(DAY,@start,@end)),@start)) -- generating random date between this random date range

    SET @rand_SQ = (SELECT FLOOR(RAND()*3 +1))
    IF @rand_SQ = 1
        BEGIN
            SET @test_SQ = 'Standard'
        END
    ELSE IF @rand_SQ = 2
        BEGIN
            SET @test_SQ = 'HD'
        END
    ELSE
        BEGIN
            SET @test_SQ = 'Ultra HD'
        END

    PRINT(@test_SQ)

    EXEC alycin_INSERT_Streaming
    @CusFname = @test_F,
    @CusLname = @test_L,
    @ContentName = @test_CN,
    @StreamDate = @test_SD, 
    @StreamQual = @test_SQ,
    @RN = @test_RN,
    @RSN = @test_RSN

    SET @RUN = @RUN - 1
END
GO 

--- EXECUTE SYNTHETIC TRANSACTION TO INSERT INTO STREAMING
EXEC alycin_Wrapper_INSERT_tblSTREAMING
@RUN = 1000


--- GET ID FOR STATUS ID
CREATE PROCEDURE alycin_getStatusID
@g_SN VARCHAR(30),
@g_S_ID INT OUTPUT
AS 
SET @g_S_ID = (SELECT StatusID FROM tblSTATUS WHERE StatusName = @g_SN)
GO
CREATE PROCEDURE alycin_getStreamingID 
@g_SD DATE,
@g_STM_ID INT OUTPUT
AS 
SET @g_STM_ID = (SELECT StreamingID FROM tblSTREAMING WHERE StreamingDate = @g_SD)
GO

--- BASE PROCEDURE TO INSERT ROW INTO HISTORY
ALTER PROCEDURE alycin_INSERT_tblHISTORY
@SN VARCHAR(30),
@CN VARCHAR(500),
@HD DATE
AS
BEGIN
    DECLARE @C_ID INT, @STAT_ID INT

    EXEC alycin_getStatusID
    @g_SN = @SN,
    @g_S_ID = @STAT_ID OUTPUT
    IF @STAT_ID IS NULL
    BEGIN;
		THROW 53001, '@STAT_ID cannot be null', 1;
	END

    EXEC proj_02_getcontentID
    @contentName = @CN,
    @content_ID = @C_ID OUTPUT
    IF @C_ID IS NULL
    BEGIN;
		THROW 53001, '@Cont_ID cannot be null', 1;
	END

    BEGIN TRAN T1
	INSERT INTO tblHISTORY(StatusID, ContentID, HistoryDate)
	VALUES(@STAT_ID, @C_ID, @HD)

	IF @@ERROR <> 0 or @@TRANCOUNT <> 1
	BEGIN
		ROLLBACK TRAN T1
	END
	ELSE
		COMMIT TRAN T1
END
GO 

--- SYNTHETIC TRANSACTION TO INSERT ROWS INTO HISTORY
ALTER PROCEDURE alycin_Wrapper_INSERT_tblHISTORY
@RUN INT
AS
DECLARE @StatPK INT, @ContPK INT
DECLARE @StatCount INT = (SELECT COUNT(*) FROM tblSTATUS)
DECLARE @ContCount INT = (SELECT COUNT(*) FROM tblCONTENT)
DECLARE @test_SN varchar(30), @test_CN varchar(500), @test_HD date, @start DATE, @end DATE

WHILE @RUN > 0
BEGIN
    SET @StatPK = (SELECT RAND() * @StatCount + 1)
    SET @test_SN = (SELECT StatusName FROM tblSTATUS WHERE StatusID = @StatPK)

    SET @ContPK = (SELECT RAND() * @ContCount + (SELECT MIN(ContentID) FROM tblContent))
    SET @test_CN = (SELECT ContentName FROM tblCONTENT WHERE ContentID = @ContPK)
    SET @start = '1980-01-01'
    SET @end = '2020-12-31'
    SET @test_HD = (SELECT DATEADD(DAY,ABS(CHECKSUM(NEWID())) % ( 1 + DATEDIFF(DAY,@start,@end)),@start)) -- generating random date between this random date range

    EXEC alycin_INSERT_tblHISTORY 
    @SN = @test_SN,
    @CN = @test_CN,
    @HD = @test_HD

    SET @RUN = @RUN - 1
END
GO 

--- EXECUTE SYNTHETIC TRANSACTION TO INSERT INTO HISTORY
EXEC alycin_Wrapper_INSERT_tblHISTORY
@RUN = 5000

---- Computed column 1: Find the count of streams for each customer
CREATE FUNCTION alycin_fn_CountStreamsPerCustomer (@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(StreamingID) 
        FROM tblSTREAMING S 
            JOIN tblCUSTOMER C ON S.CustomerID = C.CustomerID
        WHERE C.CustomerID = @PK)
    RETURN @RET
END
GO

ALTER TABLE tblCUSTOMER
ADD CustTotalStreams AS (dbo.alycin_fn_CountStreamsPerCustomer(CustomerID))

---- Computed column 2: Find the distinct number of content per production
CREATE FUNCTION alycin_fn_CountDistinctContentPerProduction (@PK INT)
RETURNS INT
AS 
BEGIN 
    DECLARE @RET INT = (SELECT COUNT(DISTINCT ContentName)
        FROM tblContent C 
            JOIN tblCredit CR ON C.ContentID = CR.ContentID
            JOIN tblPRODUCTION P ON CR.ProductionID = P.ProductionID
        WHERE P.ProductionID = @PK)
    RETURN @RET
END
GO

ALTER TABLE tblPRODUCTION
ADD UniqueCountContentPerProduction AS (dbo.alycin_fn_CountDistinctContentPerProduction(ProductionID))

---- Computed column 3: Find the distinct number of content per personnel
CREATE FUNCTION alycin_fn_CountDistinctContentPerPersonnel (@PK INT)
RETURNS INT
AS 
BEGIN 
    DECLARE @RET INT = (SELECT COUNT(DISTINCT ContentName)
        FROM tblContent C 
            JOIN tblCredit CR ON C.ContentID = CR.ContentID
            JOIN tblPERSONNEL P ON CR.PersonnelID = P.PersonnelID
        WHERE P.PersonnelID = @PK)
    RETURN @RET
END
GO

ALTER TABLE tblPERSONNEL
ADD UniqueCountContentPerPersonnel AS (dbo.alycin_fn_CountDistinctContentPerPersonnel(PersonnelID))

--- COMPLEX QUERY 1: 
---- Find the number of movie genres that fit the following criteria:
-------- Average rating < 1160: "not great"
-------- Average rating  > 1160 and 1230: “average”
-------- Average rating  > 1230: “excellent”
--- and 5 star rating
SELECT ( CASE
    WHEN rate5Count < 1160
            THEN 'Not Great'
        WHEN rate5Count BETWEEN 1160 AND 1230
            THEN 'Average'
        ELSE 'Excellent'
    END) AS RatingByCategories, COUNT(*) as NumberOfGenres
FROM (SELECT GenreName, count(*) as rate5Count
    from tblGENRE G
        JOIN tblGenre_Content GC ON G.GenreID = GC.GenreID
        JOIN tblContent C ON GC.ContentID = C.ContentID
        JOIN tblSTREAMING ST ON C.ContentID = ST.ContentID
        JOIN tblRATING RAT ON ST.RatingID = RAT.RatingID
    where RAT.NumRating = 5
    GROUP BY GenreName
) as A 
GROUP BY (CASE
        WHEN rate5Count < 1160
            THEN 'Not Great'
        WHEN rate5Count BETWEEN 1160 AND 1230
            THEN 'Average'
        ELSE 'Excellent'
    END)
ORDER BY NumberOfGenres DESC

select min(rate1Count) as minCount, max(rate1Count) as maxCount, avg(rate5Count) as middleCount
from (
SELECT GenreName,  count(*) as rate1Count 
    from tblGENRE G
        JOIN tblGenre_Content GC ON G.GenreID = GC.GenreID
        JOIN tblContent C ON GC.ContentID = C.ContentID
        JOIN tblSTREAMING ST ON C.ContentID = ST.ContentID
        JOIN tblRATING RAT ON ST.RatingID = RAT.RatingID
    where RAT.NumRating = 5
    GROUP BY GenreName
) as A

--- COMPLEX QUERY 2:
-- List all the Drama movie(s) that Fonda Bornmann has appeared in with an average rating of 3 or greater.
SELECT distinct ContentName
FROM tblPERSONNEL PER 
    JOIN tblCredit CRED ON PER.PersonnelID = CRED.PersonnelID
    JOIN tblPRODUCTION PROD ON CRED.ProductionID = PROD.ProductionID
    JOIN tblContent CON ON CRED.ContentID = CON.ContentID
    JOIN tblSTREAMING ST ON CON.ContentID = ST.ContentID
    JOIN tblRATING RAT ON ST.RatingID = RAT.RatingID
    JOIN tblGenre_Content GC ON CON.ContentID = GC.ContentID
    JOIN tblGENRE G ON GC.GenreID = G.GenreID
    JOIN tblLanguage_Content LC ON CON.ContentID = LC.ContentID
    JOIN tblLanguage L ON LC.LanguageID = L.LanguageID
WHERE (PER.PersonnelFname = 'Fonda') 
    AND (PER.PersonnelLname = 'Bornmann') 
    AND (GenreName = 'Drama')  
    AND (RAT.NumRating >= 3)

--- COMPLEX QUERY 3:
-- List all the movies in the Comedy genre where the GenrePerc for the movie is over 80% and the audience is over 17
SELECT ContentName
FROM tblGENRE G
    JOIN tblGenre_Content GC ON G.GenreID = GC.GenreID
    JOIN tblContent CON ON GC.ContentID = CON.ContentID
    JOIN tblAUDIENCE A ON CON.AudienceID = A.AudienceID
    JOIN tblSTREAMING ST ON CON.ContentID = ST.ContentID
    JOIN tblRATING RAT ON ST.RatingID = RAT.RatingID
WHERE (G.GenreName = 'Comedy')
    AND (GC.GenreContentPerc > 80)
    AND (A.AudienceType IN ('R', 'NC-17'))


--- View for number one star ratings per genre
CREATE VIEW oneStarRatingsPerGenre
AS
(SELECT GenreName, count(*) as rate1Count
    from tblGENRE G
        JOIN tblGenre_Content GC ON G.GenreID = GC.GenreID
        JOIN tblContent C ON GC.ContentID = C.ContentID
        JOIN tblSTREAMING ST ON C.ContentID = ST.ContentID
        JOIN tblRATING RAT ON ST.RatingID = RAT.RatingID
    where RAT.NumRating = 1
    GROUP BY GenreName
)

--- View for number action or adventure content per production company
CREATE VIEW actionAdventurePerProductionCompany
AS
(SELECT ProductionName, count(*) as ActionAdventureContentPerProduction
    from tblPRODUCTION P 
        JOIN tblCredit CR ON P.ProductionID = CR.ProductionID
        JOIN tblContent C ON CR.ContentID = C.ContentID
        JOIN tblGenre_Content GC ON C.ContentID = GC.ContentID
        JOIN tblGENRE G ON GC.GenreID = G.GenreID
    WHERE GenreName IN ('Action', 'Adventure')
    GROUP BY ProductionName
)

--- BUSINESS RULE 1: No customer with the Basic subscription type may stream HD content
CREATE FUNCTION alycin_fn_noHDContentBasicSub()
RETURNS INT
AS 
BEGIN
    DECLARE @RET INTEGER = 0
    IF EXISTS(SELECT *
        FROM tblCustomer_Type CT 
            JOIN tblCustomer C ON CT.CustomerTypeID = C.CustomerTypeID
            JOIN tblSTREAMING S ON C.CustomerID = S.CustomerID
        WHERE CT.CustomerTypeName = 'Basic'
            AND S.StreamingQuality = 'HD'
    )
    BEGIN 
        SET @RET = 1
    END
    RETURN @RET
END
GO

ALTER TABLE tblSTREAMING WITH NOCHECK
ADD CONSTRAINT CK_noHDContentWithBasicSub
CHECK(dbo.alycin_fn_noHDContentBasicSub() = 0)

--- BUSINESS RULE 2: No customer with the Basic subscription type may stream Ultra HD content
CREATE FUNCTION alycin_fn_noUltraHDContentBasicSub()
RETURNS INT
AS 
BEGIN
    DECLARE @RET INTEGER = 0
    IF EXISTS(SELECT *
        FROM tblCustomer_Type CT 
            JOIN tblCustomer C ON CT.CustomerTypeID = C.CustomerTypeID
            JOIN tblSTREAMING S ON C.CustomerID = S.CustomerID
        WHERE CT.CustomerTypeName = 'Basic'
            AND S.StreamingQuality = 'Ultra HD'
    )
    BEGIN 
        SET @RET = 1
    END
    RETURN @RET
END
GO

ALTER TABLE tblSTREAMING WITH NOCHECK
ADD CONSTRAINT CK_noUltraHDContentWithBasicSub
CHECK(dbo.alycin_fn_noUltraHDContentBasicSub() = 0)

--- BUSINESS RULE 3: No customer with the Standard subscription type may stream Ultra HD content 
CREATE FUNCTION alycin_fn_noUltraHDContentStandardSub()
RETURNS INT
AS 
BEGIN
    DECLARE @RET INTEGER = 0
    IF EXISTS(SELECT *
        FROM tblCustomer_Type CT 
            JOIN tblCustomer C ON CT.CustomerTypeID = C.CustomerTypeID
            JOIN tblSTREAMING S ON C.CustomerID = S.CustomerID
        WHERE CT.CustomerTypeName = 'Standard'
            AND S.StreamingQuality = 'Ultra HD'
    )
    BEGIN 
        SET @RET = 1
    END
    RETURN @RET
END
GO

ALTER TABLE tblSTREAMING WITH NOCHECK
ADD CONSTRAINT CK_noUltraHDContentWithStandardSub
CHECK(dbo.alycin_fn_noUltraHDContentStandardSub() = 0)


