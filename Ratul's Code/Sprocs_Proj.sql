USE INFO_430_Proj_02A;

GO
CREATE PROCEDURE ratulj_GetContentID
@CName varchar(500),
@ContentID INT OUTPUT
AS
SET @ContentID = (SELECT ContentID FROM tblCONTENT WHERE ContentName = @CName)
Go

Go
CREATE PROCEDURE ratulj_GetGenreID
@GName varchar(30),
@GenreID INT OUTPUT
AS
SET @GenreID = (SELECT GenreID FROM tblGenre WHERE GenreName = @GName)
Go

GO
-- Insert Sproc
GO
CREATE PROCEDURE ratulj_INSERT_tblGenre_Content
@ContentName varchar(500),
@GenreName varchar(30),
@GenreContentPerc FLOAT
AS

BEGIN

	IF @GenreContentPerc IS NULL
		BEGIN;
			THROW 53001, '@GenreContentPerc Parameters cannot be null', 1;
		END

	IF @GenreName IS NULL
		BEGIN;
			THROW 53001, '@GenreName Parameters cannot be null', 1;
		END
	IF @ContentName IS NULL 
		BEGIN;
			THROW 53001, '@ContentName Parameters cannot be null', 1;
		END



	IF @GenreContentPerc < 10
		BEGIN;
			THROW 53001, 'GenreContentPerc cannot be less than 10%',1;
		END
	
	DECLARE @C_ID INT, @G_ID INT

	EXEC ratulj_GetContentID
	@CName = @ContentName,
	@ContentID = @C_ID OUTPUT

	IF @C_ID IS NULL
		BEGIN;
			THROW 53001, '@C_ID cannot be null', 1;
		END

	EXEC ratulj_GetGenreID
	@GName = @GenreName,
	@GenreID = @G_ID OUTPUT

	IF @G_ID IS NULL
		BEGIN;
			THROW 53001, '@G_ID cannot be null', 1;
		END

	BEGIN TRAN T1
		INSERT INTO tblGENRE_CONTENT (ContentID, GenreID, GenreContentPerc)
		VALUES (@C_ID, @G_ID, @GenreContentPerc)

		IF @@ERROR <> 0 
		OR @@TRANCOUNT <> 1
		BEGIN
			ROLLBACK TRAN T1;
		END
		ELSE
			COMMIT TRAN T1;
END

GO
CREATE PROCEDURE ratulj_Wrapper_INSERT_tblGenre_Content
@RUN INT
AS
DECLARE @ContentPK INT, @GenrePK INT, @ContentMinPK INT, @GenreMinPK INT
DECLARE @Content_Count INT = (SELECT COUNT(*) FROM tblCONTENT)
DECLARE @Genre_Count INT = (SELECT COUNT(*) FROM tblGenre)
DECLARE @CName varchar(500), @GName varchar(30), @GCPerc FLOAT
SET @ContentMinPK = (SELECT MIN(ContentID) FROM tblCONTENT)
SET @GenreMinPK = (SELECT MIN(GenreID) FROM tblGENRE)

WHILE @RUN > 0
BEGIN 
	SET @ContentPK = (SELECT RAND() * @Content_Count + @ContentMinPK)
	SET @CName = (SELECT ContentName FROM tblCONTENT WHERE ContentID = @ContentPK)
	SET @GenrePK = (SELECT RAND() * @Genre_Count + @GenreMinPK)
	SET @GName = (SELECT GenreName FROM tblGenre WHERE GenreID = @GenrePK)
	SET @GCPerc = (SELECT RAND()*(100-10) + 10) --since we have a business rule where Perc cannot be less than 10%

	EXEC ratulj_INSERT_tblGenre_Content
	@ContentName = @CName,
	@GenreName = @GName,
	@GenreContentPerc = @GCPerc

	SET @RUN = @RUN - 1
END

EXEC ratulj_Wrapper_INSERT_tblGenre_Content 
@RUN = 5000

GO
CREATE PROCEDURE ratulj_GetProductionID
@PName varchar(100),
@ProductionID INT OUTPUT
AS
SET @ProductionID = (SELECT ProductionID FROM tblProduction WHERE ProductionName = @PName)
Go

go
CREATE PROCEDURE ratulj_GetPersonnelID
@PFName varchar(30),
@PLName varchar(30),
@PDOB DATE,
@PersonnelID INT OUTPUT
AS
SET @PersonnelID = (SELECT PersonnelID FROM tblPersonnel WHERE PersonnelFname = @PFName 
														 AND PersonnelLname = @PLName
														 AND PersonnelDOB = @PDOB)
Go

CREATE PROCEDURE ratulj_GetRoleID
@RName varchar(30),
@RoleID INT OUTPUT
AS
SET @RoleID = (SELECT RoleID FROM tblRole WHERE RoleName = @RName)
Go

CREATE PROCEDURE ratulj_GetLanguageID
@LName varchar(30),
@LanguageID INT OUTPUT
AS
SET @LanguageID = (SELECT LanguageID FROM tblLanguage WHERE LanguageShortName = @LName)
Go

CREATE PROCEDURE ratulj_INSERT_tblCREDIT
@ContentName varchar(500),
@ProductionName varchar(100),
@PFirstName varchar(30),
@PLastName varchar(30),
@PBirth DATE,
@RoleName varchar(30),
@CreditDesc varchar(100)
AS  
BEGIN
	IF @ContentName IS NULL OR @ProductionName IS NULL 
	OR @PFirstName IS NULL OR @RoleName IS NULL 
	BEGIN;
		THROW 54001, 'Params cannot be null',1;
	END

	DECLARE @C_ID INT, @P_ID INT, @PERSON_ID INT, @R_ID INT

	EXEC ratulj_GetContentID
	@CName = @ContentName,
	@ContentID = @C_ID OUTPUT

	IF @C_ID IS NULL
		BEGIN;
			THROW 53001, '@C_ID cannot be null', 1;
		END

	EXEC ratulj_GetProductionID
	@PName = @ProductionName,
	@ProductionID = @P_ID OUTPUT

	IF @P_ID IS NULL
		BEGIN;
			THROW 53001, '@P_ID cannot be null', 1;
		END

	EXEC ratulj_GetPersonnelID
	@PFName = @PFirstName,
	@PLName = @PLastName,
	@PDOB = @PBirth,
	@PersonnelID = @PERSON_ID OUTPUT

	IF @PERSON_ID IS NULL
		BEGIN;
			THROW 53001, '@PERSONNEL_ID cannot be null', 1;
		END

	EXEC ratulj_GetRoleID
	@RName = @RoleName,
	@RoleID = @R_ID OUTPUT

	IF @R_ID IS NULL
		BEGIN;
			THROW 53001, '@R_ID cannot be null', 1;
		END
	BEGIN TRAN T1

		INSERT INTO tblCREDIT (ContentID, ProductionID, PersonnelID, RoleID, CreditDesc)
		VALUES (@C_ID, @P_ID, @PERSON_ID, @R_ID, @CreditDesc)

	IF @@ERROR <>0 OR @@TRANCOUNT <> 1
		BEGIN
			ROLLBACK TRAN T1
		END
		ELSE
			COMMIT TRAN T1
END

GO
CREATE PROCEDURE ratulj_Wrapper_INSERT_tblCREDIT
@RUN INT
AS
BEGIN
	DECLARE @ContentPK INT, @ContentMinPK INT, @ProductionPK INT, @ProductionMinPK INT
	DECLARE @PersonnelPK INT, @PersonnelMinPK INT, @RolePK INT, @RoleMinPK INT
	
	DECLARE @Content_Count INT = (SELECT COUNT(*) FROM tblCONTENT)
	SET @ContentMinPK = (SELECT MIN(ContentID) FROM tblCONTENT)
	DECLARE @Production_Count INT = (SELECT COUNT(*) FROM tblProduction)
	SET @ProductionMinPK = (SELECT MIN(ProductionID) FROM tblProduction)
	DECLARE @Personnel_Count INT = (SELECT COUNT(*) FROM tblPersonnel)
	SET @PersonnelMinPK = (SELECT MIN(PersonnelID) FROM tblPersonnel)
	DECLARE @Role_Count INT = (SELECT COUNT(*) FROM tblRole)
	SET @RoleMinPK = (SELECT MIN(RoleID) FROM tblRole)

	DECLARE @CName varchar(500), @ProdName varchar(100), @PersFName varchar(30),
	@PersLName varchar(30),@PersDOB DATE, @RName varchar(30), @CDesc varchar(100)

	WHILE @RUN > 0
	BEGIN
		SET @ContentPK = (SELECT RAND() * @Content_Count + @ContentMinPK)
		SET @CName = (SELECT ContentName FROM tblCONTENT WHERE ContentID = @ContentPK)
		SET @ProductionPK = (SELECT RAND() * @Production_Count + @ProductionMinPK)
		SET @ProdName = (SELECT ProductionName FROM tblProduction WHERE ProductionID = @ProductionPK)
		SET @PersonnelPK = (SELECT RAND() * @Personnel_Count + @PersonnelMinPK)
		SET @PersFName = (SELECT PersonnelFName FROM tblPersonnel WHERE PersonnelID = @PersonnelPK)
		SET @PersLName = (SELECT PersonnelLName FROM tblPersonnel WHERE PersonnelID = @PersonnelPK)
		SET @PersDOB = (SELECT PersonnelDOB FROM tblPersonnel WHERE PersonnelID = @PersonnelPK)
		SET @RolePK = (SELECT RAND() * @Role_Count + @RoleMinPK)
		SET @RName = (SELECT RoleName FROM tblROLE WHERE RoleID = @RolePK)

		EXEC ratulj_INSERT_tblCREDIT
		@ContentName = @CName,
		@ProductionName = @ProdName,
		@PFirstName = @PersFName,
		@PLastName = @PersLName,
		@PBirth = @PersDOB,
		@RoleName = @RName,
		@CreditDesc = @CDesc

		SET @RUN = @RUN - 1
	END
END	

EXEC ratulj_Wrapper_INSERT_tblCREDIT 
@RUN = 5000

GO
ALTER PROCEDURE ratulj_INSERT_tblLanguage_Content
@ContentName varchar(500),
@LanguageShortName varchar(100)
AS
BEGIN
	IF @ContentName IS NULL OR @LanguageShortName IS NULL
	BEGIN;
		THROW 54001, 'Params cannot be null',1;
	END

	DECLARE @L_ID INT, @C_ID INT

	EXEC ratulj_GetLanguageID
	@LName = @LanguageShortName,
	@LanguageID = @L_ID OUTPUT

	IF @L_ID IS NULL
		BEGIN;
			THROW 53001, '@L_ID cannot be null', 1;
		END

	EXEC ratulj_GetContentID
	@CName = @ContentName,
	@ContentID = @C_ID OUTPUT

	IF @C_ID IS NULL
		BEGIN;
			THROW 53001, '@C_ID cannot be null', 1;
		END

	BEGIN TRAN T1
		INSERT INTO tblLANGUAGE_CONTENT (LanguageID, ContentID)
		VALUES (@L_ID, @C_ID)

	IF @@ERROR <>0 OR @@TRANCOUNT <> 1
		BEGIN
			ROLLBACK TRAN T1
		END
		ELSE
			COMMIT TRAN T1
		
END

GO
ALTER PROCEDURE ratulj_Wrapper_INSERT_tblLanguage_Content
@RUN INT
AS
BEGIN
	DECLARE @ContentPK INT, @ContentMinPK INT, @LanguagePK INT, @LanguageMinPK INT

	DECLARE @Content_Count INT = (SELECT COUNT(*) FROM tblCONTENT)
	SET @ContentMinPK = (SELECT MIN(ContentID) FROM tblCONTENT)
	DECLARE @Language_Count INT = (SELECT COUNT(*) FROM tblLanguage)
	SET @LanguageMinPK = (SELECT MIN(LanguageID) FROM tblLanguage)

	DECLARE @CName varchar(500), @LangShortName varchar(30)
	
	WHILE @RUN > 0
	BEGIN
		SET @ContentPK = (SELECT RAND() * @Content_Count + @ContentMinPK)
		SET @CName = (SELECT ContentName FROM tblCONTENT WHERE ContentID = @ContentPK)
		SET @LanguagePK = (SELECT RAND() * @Language_Count + @LanguageMinPK)
		SET @LangShortName = (SELECT LanguageShortName FROM tblLanguage WHERE LanguageID = @LanguagePK)

		EXEC ratulj_INSERT_tblLanguage_Content
		@ContentName = @CName,
		@LanguageShortName = @LangShortName

		SET @RUN = @RUN - 1
	END
END

EXEC ratulj_Wrapper_INSERT_tblLanguage_Content
@RUN = 5000
