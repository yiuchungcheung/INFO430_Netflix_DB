USE INFO_430_Proj_02A;

-- count of the various ratings received by movies

-- 1 STAR
GO
ALTER FUNCTION ratulj_fn_RatingCount_1(@PK INT)
RETURNS INTEGER
AS
BEGIN
	DECLARE @RET INT = (SELECT COUNT(*)
						FROM tblCONTENT C
						JOIN tblSTREAMING S ON S.ContentID = C.ContentID
						JOIN tblRATING RT ON RT.RatingID = S.RatingID
						WHERE RT.NumRating = 1
						AND C.ContentID = @PK)
	RETURN @RET
END

GO
ALTER TABLE tblCONTENT
ADD TotalRating_1 AS (dbo.ratulj_fn_RatingCount_1(ContentID))

-- 2 STARS

GO
ALTER FUNCTION ratulj_fn_RatingCount_2(@PK INT)
RETURNS INTEGER
AS
BEGIN
	DECLARE @RET INT = (SELECT COUNT(*)
						FROM tblCONTENT C
						JOIN tblSTREAMING S ON S.ContentID = C.ContentID
						JOIN tblRATING RT ON RT.RatingID = S.RatingID
						WHERE RT.NumRating = 2
						AND C.ContentID = @PK)
	RETURN @RET
END

GO
ALTER TABLE tblCONTENT
ADD TotalRating_2 AS (dbo.ratulj_fn_RatingCount_2(ContentID))

-- 3 STARS
GO
ALTER FUNCTION ratulj_fn_RatingCount_3(@PK INT)
RETURNS INTEGER
AS
BEGIN
	DECLARE @RET INT = (SELECT COUNT(*)
						FROM tblCONTENT C
						JOIN tblSTREAMING S ON S.ContentID = C.ContentID
						JOIN tblRATING RT ON RT.RatingID = S.RatingID
						WHERE RT.NumRating = 3
						AND C.ContentID = @PK)
	RETURN @RET
END

GO
ALTER TABLE tblCONTENT
ADD TotalRating_3 AS (dbo.ratulj_fn_RatingCount_3(ContentID))

-- 4 STARS
GO
ALTER FUNCTION ratulj_fn_RatingCount_4(@PK INT)
RETURNS INTEGER
AS
BEGIN
	DECLARE @RET INT = (SELECT COUNT(*)
						FROM tblCONTENT C
						JOIN tblSTREAMING S ON S.ContentID = C.ContentID
						JOIN tblRATING RT ON RT.RatingID = S.RatingID
						WHERE RT.NumRating = 4
						AND C.ContentID = @PK)
	RETURN @RET
END

GO
ALTER TABLE tblCONTENT
ADD TotalRating_4 AS (dbo.ratulj_fn_RatingCount_4(ContentID))

-- 5 STARS
GO
ALTER FUNCTION ratulj_fn_RatingCount_5(@PK INT)
RETURNS INTEGER
AS
BEGIN
	DECLARE @RET INT = (SELECT COUNT(*)
						FROM tblCONTENT C
						JOIN tblSTREAMING S ON S.ContentID = C.ContentID
						JOIN tblRATING RT ON RT.RatingID = S.RatingID
						WHERE RT.NumRating = 5
						AND C.ContentID = @PK)
	RETURN @RET
END

GO
ALTER TABLE tblCONTENT
ADD TotalRating_5 AS (dbo.ratulj_fn_RatingCount_5(ContentID))

GO
CREATE FUNCTION ratulj_fn_AvgRating_Audience(@PK INT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @RET FLOAT = (SELECT AVG(NumRating)		
						FROM tblContent C 
						 JOIN tblAUDIENCE A ON A.AudienceID = C.AudienceID
						 JOIN tblSTREAMING S ON S.ContentID = C.ContentID
						 JOIN tblRATING R ON R.RatingID = S.RatingID
						 WHERE A.AudienceID = @PK)
	RETURN @RET
END

GO
ALTER TABLE tblAUDIENCE
ADD AvgRating AS (dbo.ratulj_fn_AvgRating_Audience(AudienceID))

SELECT * FROM tblAUDIENCE