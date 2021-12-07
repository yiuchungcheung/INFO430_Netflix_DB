USE INFO_430_Proj_02a;

GO
ALTER VIEW TotalHorror_Rated4
AS
SELECT DISTINCT C.ContentName, G.GenreName, R.NumRating
FROM tblCONTENT C 
 JOIN tblGENRE_CONTENT GC ON GC.ContentID = C.ContentID
 JOIN tblGENRE G ON G.GenreID = GC.GenreID
 JOIN tblLANGUAGE_CONTENT LC ON LC.ContentID = C.ContentID
 JOIN tblLANGUAGE L ON L.LanguageID = LC.LanguageID
 JOIN tblSTREAMING S ON S.ContentID = C.ContentID
 JOIN tblRATING R ON R.RatingID = S.RatingID
 WHERE G.GenreName = 'Horror'
	AND L.LanguageShortName != 'en'
	AND R.NumRating = 4

GO
ALTER VIEW SciFi_en_rated3
AS
SELECT C.ContentName, G.GenreName, R.NumRating
FROM tblCONTENT C 
 JOIN tblGENRE_CONTENT GC ON GC.ContentID = C.ContentID
 JOIN tblGENRE G ON G.GenreID = GC.GenreID
 JOIN tblLANGUAGE_CONTENT LC ON LC.ContentID = C.ContentID
 JOIN tblLANGUAGE L ON L.LanguageID = LC.LanguageID
 JOIN tblSTREAMING S ON S.ContentID = C.ContentID
 JOIN tblRATING R ON R.RatingID = S.RatingID
 WHERE G.GenreName = 'Sci-Fi'
	AND L.LanguageShortName = 'en'
	AND R.NumRating = 3





