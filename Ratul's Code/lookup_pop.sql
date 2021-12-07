USE INFO_430_Proj_02a;

SELECT * 
FROM tblLanguage_working 

INSERT INTO tblLanguage (LanguageShortName, LanguageDesc)
SELECT LanguageCode, LanguageName
FROM tblLanguage_working