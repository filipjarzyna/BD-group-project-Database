
--wyświetlanie zagrożonych uczniów 
EXEC [dbo].[Notification about failing] 

--wyświetlanie osób z wyróznieniem 
EXEC [dbo].[Students with honours] 

SELECT * FROM [dbo].[ClassesAvg] 

SELECT * FROM [dbo].[Number of DR for classes] 

--lista obecności klasy 4a 
SELECT * FROM [dbo].[Attendance List](‘4A’) 

--znajdz zastepstwo dla klasy 1a na drugą godzine lekcyjną w tygodniu 
SELECT * FROM [dbo].[Find Replacement]('1A',2)
