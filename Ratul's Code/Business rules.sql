USE INFO_430_Proj_02A;

GO
CREATE FUNCTION ratulj_fn_ProductionName_NotDisney()
RETURNS INTEGER
AS
BEGIN
	DECLARE @RET INT = 0;
	IF EXISTS (SELECT *
			   FROM tblPRODUCTION
			   WHERE ProductionName LIKE '%Disney%')
	BEGIN
		SET @RET = 1;
	END
	RETURN @RET
END

GO
ALTER TABLE tblProduction WITH NOCHECK
ADD CONSTRAINT ck_ProductionName_NotDisney 
CHECK (dbo.ratulj_fn_ProductionName_NotDisney() = 0)

GO
CREATE FUNCTION ratulj_fn_Under18_NoBasic()
RETURNS INTEGER
AS
BEGIN
	DECLARE @RET INT = 0
	IF EXISTS(SELECT *
			  FROM tblCUSTOMER C 
				JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID
			  WHERE C.CustomerDOB < DATEADD(YEAR, -18, GETDATE())
			  AND CT.CustomerTypeName = 'Basic')
	BEGIN
		SET @RET = 1;
	END
	RETURN @RET
END

GO
ALTER TABLE tblCustomer WITH NOCHECK
ADD CONSTRAINT ck_Under18_NoBasic
CHECK (dbo.ratulj_fn_Under18_NoBasic() = 0)

GO
CREATE FUNCTION ratulj_fn_GenreContentPerc_10perc()
RETURNS INTEGER
AS
BEGIN
	DECLARE @RET INT = 0
	IF EXISTS(SELECT *
			  FROM tblGENRE_CONTENT
			  WHERE GenreContentPerc < 10.0)
	BEGIN
		SET @RET = 1;
	END
	RETURN @RET
END

GO
ALTER TABLE tblGenre_Content
ADD CONSTRAINT ck_GenreContentPerc_10perc
CHECK (dbo.ratulj_fn_GenreContentPerc_10perc() = 0)
