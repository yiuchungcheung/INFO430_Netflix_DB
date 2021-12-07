USE INFO_430_Proj_02a;

SELECT * FROM tblRating_working

INSERT INTO tblRATING(RatingName, RatingShortName, RatingDesc, NumRating)
SELECT RatingName, RatingShortName, RatingDesc, NumRating
FROM tblRating_working
