USE [master]
GO
/****** Object:  Database [School]    Script Date: 15.02.2025 18:43:19 ******/
CREATE DATABASE [School]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'School', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\School.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'School_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\School_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [School] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [School].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [School] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [School] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [School] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [School] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [School] SET ARITHABORT OFF 
GO
ALTER DATABASE [School] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [School] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [School] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [School] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [School] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [School] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [School] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [School] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [School] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [School] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [School] SET  DISABLE_BROKER 
GO
ALTER DATABASE [School] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [School] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [School] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [School] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [School] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [School] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [School] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [School] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [School] SET  MULTI_USER 
GO
ALTER DATABASE [School] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [School] SET DB_CHAINING OFF 
GO
ALTER DATABASE [School] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [School] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [School]
GO
/****** Object:  StoredProcedure [dbo].[Add nr to class register]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Add nr to class register]
AS
BEGIN

DECLARE @numer as int;
DECLARE @IDUcznia as int;
DECLARE @IDKlasy as int;
DECLARE @PrevIDklasy as int;
SET @PrevIDklasy = (Select Min([ID Class]) From Students);
SET @numer = 0;

DECLARE Uczen_cursor CURSOR FOR select [ID Student],[ID Class] from Students Order By [ID Class],[Surname],[Name],[ID Student]

OPEN Uczen_cursor;

FETCH NEXT FROM Uczen_cursor INTO @IDUcznia,@IDKlasy

WHILE @@FETCH_STATUS = 0
  BEGIN


	  IF @IDKlasy <> @PrevIDklasy
	      BEGIN
		  SET @numer = 1
		  END;
	  ELSE
	      BEGIN
		  SET @numer = @numer + 1
		  END;
	  
	  SET @PrevIDklasy = @IDKlasy
      UPDATE Students
      SET    [ClassRegisterNum] = @numer
      WHERE  [ID Student] = @IDUcznia;

      FETCH NEXT FROM Uczen_cursor INTO @IDUcznia,@IDKlasy

  END;

CLOSE Uczen_cursor;

DEALLOCATE Uczen_cursor;  


END


GO
/****** Object:  StoredProcedure [dbo].[AddNewMark]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[AddNewMark]
    @StudentID INT,
    @Mark INT,
    @Weight INT,
    @TeacherID INT,
    @SubjectID INT
AS
BEGIN
    INSERT INTO Marks ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue])
    VALUES (@StudentID, @Mark, @Weight, @TeacherID, @SubjectID, GETDATE())
END;




GO
/****** Object:  StoredProcedure [dbo].[DeleteMarkByID]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteMarkByID]
    @MarkID INT
AS
BEGIN
    DELETE FROM Marks WHERE [ID Mark] = @MarkID;
END;

GO
/****** Object:  StoredProcedure [dbo].[EditMarkByID]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[EditMarkByID]
    @MarkID INT,
    @StudentID INT,
    @Mark INT,
    @Weight INT,
    @TeacherID INT,
    @SubjectID INT
AS
BEGIN
    UPDATE Marks
    SET [ID Student] = @StudentID, [Mark] = @Mark, [Weight] = @Weight, [ID Teacher] = @TeacherID, [ID Subject] = @SubjectID
    WHERE [ID Mark] = @MarkID;
END;


GO
/****** Object:  StoredProcedure [dbo].[GetMarksWithPagination]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMarksWithPagination]
    @PageNumber INT,
    @PageSize INT
AS
BEGIN 
    DECLARE @Offset INT;
    DECLARE @TotalRecords INT;
    DECLARE @TotalPages INT;

    -- Oblicz początkowy indeks
    SET @Offset = (@PageNumber - 1) * @PageSize;

    -- Oblicz całkowitą liczbę rekordów
    SELECT @TotalRecords = COUNT(*) FROM Marks;

    -- Oblicz całkowitą liczbę stron
    SET @TotalPages = CEILING(CAST(@TotalRecords AS FLOAT) / @PageSize);

    -- Pobierz rekordy z paginacją
    SELECT *
    FROM Marks
    ORDER BY [Date of issue] DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    
    -- Zwróć dodatkowe informacje jako wynik
    SELECT @TotalRecords AS TotalRecords, @TotalPages AS TotalPages;
END;

GO
/****** Object:  StoredProcedure [dbo].[GetStudentsTeachersSubjects]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- procedura do sugerowania tresci w formularzu dodawania
CREATE PROCEDURE [dbo].[GetStudentsTeachersSubjects]
    @StudentName VARCHAR(100) = '',
    @TeacherName VARCHAR(100) = '',
    @SubjectName VARCHAR(100) = ''
AS
BEGIN
    -- Pobieranie studentów
    SELECT TOP 10 
        [ID Student], 
        [Name] + ' ' + [Surname] AS [Name]
    FROM Students
    WHERE [Name] + ' ' + [Surname] COLLATE Latin1_General_CI_AI LIKE '%' + @StudentName + '%';


    SELECT DISTINCT TOP 10
        T.[ID Teacher],
        T.[Name] + ' ' + T.[Surname] AS [Name]
    FROM Teachers T
    INNER JOIN TeacherSubjects TS ON T.[ID Teacher] = TS.[ID Teacher]
    INNER JOIN Subjects S ON TS.[ID Subject] = S.[ID Subject]
    WHERE T.[Name] + ' ' + T.[Surname] COLLATE Latin1_General_CI_AI LIKE '%' + @TeacherName + '%'
    AND S.[Subject Name] COLLATE Latin1_General_CI_AI LIKE '%' + @SubjectName + '%';

    SELECT DISTINCT TOP 10
        S.[ID Subject],
        S.[Subject Name]
    FROM Subjects S
    INNER JOIN TeacherSubjects TS ON S.[ID Subject] = TS.[ID Subject]
    INNER JOIN Teachers T ON TS.[ID Teacher] = T.[ID Teacher]
    WHERE T.[Name] + ' ' + T.[Surname] COLLATE Latin1_General_CI_AI LIKE '%' + @TeacherName + '%'
    AND S.[Subject Name] COLLATE Latin1_General_CI_AI LIKE '%' + @SubjectName + '%';
END;


GO
/****** Object:  StoredProcedure [dbo].[Notification about failing]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Notification about failing]
AS
BEGIN

DECLARE @PrevNumer nvarchar(2) = N'00';
DECLARE @Numer nvarchar(2);
DECLARE @IDUcznia int;
DECLARE @Imie nvarchar(50);
DECLARE @Nazwisko nvarchar(50);
DECLARE @Przedmiot nvarchar(50);
DECLARE @Srednia float;

DECLARE cursor_srednich CURSOR FOR 
SELECT C.[Number],
M.[ID Student],
[Name],
[Surname],
Sub.[Subject Name],
CAST(SUM(M.Mark * M.Weight) as float )/(CAST(SUM(M.Weight) as float)) as [Subject Average] FROM Marks M
INNER JOIN Students S ON M.[ID Student] = S.[ID Student]
INNER JOIN Class C ON S.[ID Class] = C.[ID Class]
INNER JOIN Subjects Sub ON Sub.[ID Subject] = M.[ID Subject]
GROUP BY C.[Number],M.[ID Student],[Name],[Surname],Sub.[Subject Name]
HAVING CAST(SUM(M.Mark * M.Weight) as float )/(CAST(SUM(M.Weight) as float)) < 2.0
ORDER BY C.Number

OPEN cursor_srednich ;

FETCH NEXT FROM cursor_srednich INTO @Numer,@IDUcznia,@Imie,@Nazwisko,@Przedmiot, @Srednia

WHILE @@FETCH_STATUS = 0
  BEGIN
	  IF @Numer <> @PrevNumer
	      BEGIN
		  PRINT N'Students failing of Class: ' + @Numer
		  END;
	  
	  PRINT CONCAT('ID : ',@IDUcznia,' Name: ',@Imie,' Surname: ', @Nazwisko,' Subject: ',@Przedmiot, ' Average: ',@Srednia)


	  SET @PrevNumer = @Numer

      FETCH NEXT FROM cursor_srednich INTO @Numer,@IDUcznia,@Imie,@Nazwisko,@Przedmiot, @Srednia

  END;

CLOSE cursor_srednich ;

DEALLOCATE cursor_srednich ;  


END


GO
/****** Object:  StoredProcedure [dbo].[Students with honours]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Students with honours]
AS
BEGIN

DECLARE @PrevNumer nvarchar(2) = N'00';
DECLARE @Numer nvarchar(2);
DECLARE @IDUcznia int;
DECLARE @Imie nvarchar(50);
DECLARE @Nazwisko nvarchar(50);
DECLARE @Srednia float;

DECLARE cursor_wyroznien CURSOR FOR 
SELECT C.[Number],
S.[ID Student],
S.[Name],
S.[Surname],
SA.[Average of Subjects]
FROM [StudentsAvg] SA
INNER JOIN Students S on S.[ID Student] = SA.[ID Student]
INNER JOIN Class C on C.[ID Class] = S.[ID Class]
WHERE SA.[Average of Subjects] >= 4.75

OPEN cursor_wyroznien ;

FETCH NEXT FROM cursor_wyroznien INTO @Numer,@IDUcznia,@Imie,@Nazwisko, @Srednia

WHILE @@FETCH_STATUS = 0
  BEGIN
	  IF @Numer <> @PrevNumer
	      BEGIN
		  PRINT N'Student Honours of class ' + @Numer
		  END;
	  
	  PRINT CONCAT('ID : ',@IDUcznia,' Name: ',@Imie,' Surname: ', @Nazwisko, ' Average: ',@Srednia)


	  SET @PrevNumer = @Numer

      FETCH NEXT FROM cursor_wyroznien INTO @Numer,@IDUcznia,@Imie,@Nazwisko, @Srednia

  END;

CLOSE cursor_wyroznien ;

DEALLOCATE cursor_wyroznien ;  


END


GO
/****** Object:  UserDefinedFunction [dbo].[Find Replacement]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Find Replacement] (@classnumber nvarchar(2),@idhour int)  
RETURNS @Wynik TABLE ([ID Teacher] int,Name nvarchar(50),Surname nvarchar(50))
AS  
BEGIN 
	INSERT INTO @WYNIK
	Select TS.[ID Teacher],T.Name,T.Surname 
	FROM TeacherSubjects TS INNER JOIN [Teachers] T on TS.[ID Teacher] = T.[ID Teacher]
	WHERE TS.[ID Teacher] NOT IN
	(Select [ID Teacher] FROM ClassSubjects CS Inner Join TimeTable T ON CS.ID = T.[ID ClassSubject] WHERE T.[ID Hour] = @idhour)
	AND TS.[ID Subject] = 
	(Select [ID Subject] FROM ClassSubjects CS 
	Inner Join TimeTable T ON CS.ID = T.[ID ClassSubject] 
	Inner Join Class C ON CS.[ID Class] = C.[ID Class]
	WHERE T.[ID Hour] = @idhour AND C.Number = @classnumber)
	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[List of free classrooms]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[List of free classrooms] (@idhour int)  
RETURNS @Wynik TABLE ([Classroom number] int)
AS  
BEGIN 
	INSERT INTO @Wynik
	Select [Classroom number] From Classrooms CR
	WHERE CR.[ID Class] NOT IN (SELECT [ID Classroom] FROM [TimeTable] T WHERE T.[ID Hour] = @idhour)
	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[StudentAVGFromSubject]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[StudentAVGFromSubject] (@StudentID INT, @SubjectID INT)
RETURNS DECIMAL(5, 2)
AS
    BEGIN
        DECLARE @Avg DECIMAL(5, 2);
        SELECT @Avg = SUM(Mark * Weight) / SUM(Weight)
        FROM Marks
        WHERE [ID Student] = @StudentID AND [ID Subject] = @SubjectID;
        RETURN @Avg;
    END;


GO
/****** Object:  Table [dbo].[Administration]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Administration](
	[Id Employee] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Surname] [nvarchar](50) NOT NULL,
	[Position] [nvarchar](50) NOT NULL,
	[Contact Number] [nvarchar](11) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Administration] PRIMARY KEY CLUSTERED 
(
	[Id Employee] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Attendence]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attendence](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID Hour] [int] NOT NULL,
	[ID ClassSubject] [int] NOT NULL,
	[ID Student] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Present] [bit] NULL,
 CONSTRAINT [pk_ID Attendence] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Book Check out]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Book Check out](
	[Id Check out] [int] IDENTITY(1,1) NOT NULL,
	[ID Book] [int] NOT NULL,
	[ID Student] [int] NOT NULL,
	[Check out date] [date] NOT NULL,
	[Return date] [date] NOT NULL,
 CONSTRAINT [PK_Book Check out] PRIMARY KEY CLUSTERED 
(
	[Id Check out] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Class]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Class](
	[ID Class] [int] IDENTITY(1,1) NOT NULL,
	[Number] [nvarchar](2) NOT NULL,
	[ID Tutor] [int] NOT NULL,
 CONSTRAINT [pk_ID Class] PRIMARY KEY CLUSTERED 
(
	[ID Class] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Classrooms]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Classrooms](
	[ID Class] [int] IDENTITY(1,1) NOT NULL,
	[Classroom number] [nvarchar](3) NOT NULL,
 CONSTRAINT [pk_ID Classroom] PRIMARY KEY CLUSTERED 
(
	[ID Class] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ClassSubjects]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClassSubjects](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID Class] [int] NOT NULL,
	[ID Teacher] [int] NOT NULL,
	[ID Subject] [int] NOT NULL,
 CONSTRAINT [pk_ID ClassSubject] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DisciplineReferrals]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DisciplineReferrals](
	[ID DR] [int] NOT NULL,
	[ID Student] [int] NOT NULL,
	[ID Teacher] [int] NOT NULL,
	[Date] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DisciplineReferralsDesc]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DisciplineReferralsDesc](
	[ID DR] [int] IDENTITY(1,1) NOT NULL,
	[Content] [nvarchar](1000) NOT NULL,
	[Weight] [int] NOT NULL,
 CONSTRAINT [pk_ID DR] PRIMARY KEY CLUSTERED 
(
	[ID DR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Library]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Library](
	[Id Book] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[Author] [nvarchar](50) NOT NULL,
	[Release Year] [nvarchar](4) NOT NULL,
	[Genre] [nvarchar](50) NOT NULL,
	[Available Copies] [int] NULL,
 CONSTRAINT [PK_Library] PRIMARY KEY CLUSTERED 
(
	[Id Book] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Marks]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Marks](
	[ID Student] [int] NOT NULL,
	[Mark] [int] NOT NULL,
	[Weight] [int] NOT NULL,
	[ID Teacher] [int] NOT NULL,
	[ID Subject] [int] NOT NULL,
	[Date of issue] [datetime] NOT NULL,
	[ID Mark] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

Create Clustered Index Idx_Marks ON Marks([ID Mark])

GO
/****** Object:  Table [dbo].[Students]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[ID Student] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Surname] [nvarchar](50) NOT NULL,
	[ClassRegisterNum] [int] NULL,
	[AddressCity] [nvarchar](50) NOT NULL,
	[AddressStreet] [nvarchar](50) NOT NULL,
	[AddressPostCode] [nvarchar](6) NOT NULL,
	[ID Class] [int] NOT NULL,
 CONSTRAINT [pk_ID Student] PRIMARY KEY CLUSTERED 
(
	[ID Student] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Subjects]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Subjects](
	[ID Subject] [int] IDENTITY(1,1) NOT NULL,
	[Subject Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [pk_ID Subject] PRIMARY KEY CLUSTERED 
(
	[ID Subject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Teachers]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Teachers](
	[ID Teacher] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Surname] [nvarchar](50) NOT NULL,
	[AddressCity] [nvarchar](50) NOT NULL,
	[AddressStreet] [nvarchar](50) NOT NULL,
	[AddressPostCode] [nvarchar](6) NOT NULL,
 CONSTRAINT [pk_ID Teacher] PRIMARY KEY CLUSTERED 
(
	[ID Teacher] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TeacherSubjects]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TeacherSubjects](
	[ID Teacher] [int] NOT NULL,
	[ID Subject] [int] NOT NULL,
 CONSTRAINT [PK_TeacherSubject] PRIMARY KEY CLUSTERED 
(
	[ID Teacher] ASC,
	[ID Subject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TeachingHours]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TeachingHours](
	[ID Hour] [int] IDENTITY(1,1) NOT NULL,
	[Start] [datetime] NOT NULL,
	[End] [datetime] NOT NULL,
	[Day of week] [nvarchar](20) NOT NULL,
 CONSTRAINT [pk_ID Hour] PRIMARY KEY CLUSTERED 
(
	[ID Hour] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TimeTable]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeTable](
	[ID Classroom] [int] NOT NULL,
	[ID Hour] [int] NOT NULL,
	[ID ClassSubject] [int] NOT NULL,
 CONSTRAINT [pk_ID TimeTable] PRIMARY KEY CLUSTERED 
(
	[ID Classroom] ASC,
	[ID Hour] ASC,
	[ID ClassSubject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[StudentsAvg]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[StudentsAvg] AS 
With AvgForEachStudent AS (
Select 
	[ID Student],
	[ID Subject],
	Sum(Cast([Mark]*[Weight] as Float))/Cast(Sum([Weight]) as Float) [Average] 
	From Marks 
	Group By [ID Student],[ID Subject]
)
Select 
	S.[ID Student] as [ID Student],
	S.[Name] as [Name],
	S.[Surname] as [Surname],
	Sum(AF.[Average])/Count(*) [Average of Subjects]
	From Students S inner join AvgForEachStudent AF
	On S.[ID Student] = AF.[ID Student]
	Group By S.[ID Student],S.[Name],S.[Surname]



GO
/****** Object:  View [dbo].[ClassesAvg]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClassesAvg] AS
SELECT Number,Avg(SA.[Average of Subjects]) AS [Class Average] FROM [StudentsAvg] SA 
 INNER JOIN Students S ON SA.[ID Student] = S.[ID Student] 
 INNER JOIN Class C ON C.[ID Class] = S.[ID Class]
 Group By C.Number


GO
/****** Object:  UserDefinedFunction [dbo].[Attendance List]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Attendance List] (@classnumber nvarchar(2))  
RETURNS TABLE  
AS  
RETURN  
    SELECT Name, Surname  
    FROM [Students] S INNER JOIN [Class] C ON S.[ID Class] = C.[ID Class]
    WHERE C.Number = @classnumber


GO
/****** Object:  View [dbo].[BestStudentsBySubjects]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BestStudentsBySubjects] AS
    SELECT
        R.[ID Student],
        R.[ID Subject],
        R.Avg
    FROM (SELECT
            [ID Student],
            [ID Subject],
            SUM(Mark * Weight) / SUM(Weight) AS Avg,
            RANK() OVER (PARTITION BY [ID Subject] ORDER BY SUM(Mark * Weight) / SUM(Weight) DESC) AS Rank
        FROM Marks
        GROUP BY [ID Student], [ID Subject]) AS R
    WHERE R.Rank = 1;


GO
/****** Object:  View [dbo].[Classes Timetable]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Classes Timetable] AS
SELECT
    [Number],
	[Classroom number],
	[Day of week],
	Cast([Start] as time) [Start Time],
	Cast([End] as time) [End Time],
	[Subject Name] From 

	[dbo].[TimeTable] T 
	INNER JOIN [dbo].[TeachingHours] TH on T.[ID Hour] = TH.[ID Hour] 
	INNER JOIN [dbo].[ClassSubjects] CS ON T.[ID ClassSubject] = CS.[ID] 
	INNER JOIN [dbo].[Subjects] S On CS.[ID Subject] = S.[ID Subject] 
	INNER JOIN [dbo].[Class] C On CS.[ID Class] = C.[ID Class]
	INNER JOIN [dbo].[Classrooms] CR On T.[ID Classroom] = CR.[ID Class]

GO
/****** Object:  View [dbo].[Number of DR for classes]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Number of DR for classes] AS
SELECT
	Number as [Class Name],
	ISNULL(T.[Number of discipline referrals],0) [Number of discipline referrals]
	From Class C OUTER APPLY
	(Select Count(*) AS [Number of discipline referrals] From DisciplineReferrals DR 
	Inner Join Students ST on DR.[ID Student] = ST.[ID Student]
	Inner Join Class Cla ON Cla.[ID Class] = ST.[ID Class]
	Where C.[ID Class] = Cla.[ID Class]
	Group By Cla.Number) T


GO
/****** Object:  View [dbo].[Teachers Timetable]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Teachers Timetable] AS
SELECT
	[Name],
	[Surname] Nazwisko,
	[Subject Name],
    [Number] KLASA,
	[Classroom number] SALA,
	[Day of week],
	Cast([Start] as time) [Start Time],
	Cast([End] as time) [End Time]
	From 
	[dbo].[TimeTable] T 
	INNER JOIN [dbo].[TeachingHours] TH on T.[ID Hour] = TH.[ID Hour] 
	INNER JOIN [dbo].[ClassSubjects] CS ON CS.[ID] = T.[ID ClassSubject] 
	INNER JOIN [dbo].[Subjects] S On CS.[ID Subject] = S.[ID Subject] 
	INNER JOIN [dbo].[Class] C On CS.[ID Class] = C.[ID Class]
	INNER JOIN [dbo].[Classrooms] CR On T.[ID Classroom] = CR.[ID Class]
	INNER JOIN [dbo].[Teachers] Tea on CS.[ID Teacher] = Tea.[ID Teacher]


GO
SET IDENTITY_INSERT [dbo].[Administration] ON 

INSERT [dbo].[Administration] ([Id Employee], [Name], [Surname], [Position], [Contact Number], [Email]) VALUES (1, N'Anna', N'Kowalska', N'Dyrektor', N'123-456-789', N'anna.kowalska@szkola.pl')
INSERT [dbo].[Administration] ([Id Employee], [Name], [Surname], [Position], [Contact Number], [Email]) VALUES (2, N'Jan', N'Nowak', N'Sekretarz', N'987-654-321', N'jan.nowak@szkola.pl')
INSERT [dbo].[Administration] ([Id Employee], [Name], [Surname], [Position], [Contact Number], [Email]) VALUES (3, N'Maria', N'Wiśniewska', N'Księgowa', N'456-123-789', N'maria.wisniewska@szkola.pl')
INSERT [dbo].[Administration] ([Id Employee], [Name], [Surname], [Position], [Contact Number], [Email]) VALUES (4, N'Tomasz', N'Zieliński', N'Administrator IT', N'321654987', N'tomasz.zielinski@szkola.pl')
INSERT [dbo].[Administration] ([Id Employee], [Name], [Surname], [Position], [Contact Number], [Email]) VALUES (5, N'Karolina', N'Nowicka', N'Kierownik ds. edukacji', N'654987321', N'karolina.nowicka@szkola.pl')
INSERT [dbo].[Administration] ([Id Employee], [Name], [Surname], [Position], [Contact Number], [Email]) VALUES (6, N'Piotr', N'Krawczyk', N'Konserwator', N'789123456', N'piotr.krawczyk@szkola.pl')
SET IDENTITY_INSERT [dbo].[Administration] OFF
SET IDENTITY_INSERT [dbo].[Attendence] ON 

INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (2, 1, 33, 1, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (3, 1, 33, 2, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (4, 1, 33, 3, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (5, 1, 33, 4, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (6, 1, 33, 5, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (7, 1, 33, 6, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (8, 1, 33, 7, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (9, 1, 33, 8, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (10, 1, 33, 9, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (11, 1, 33, 10, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (12, 1, 33, 11, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (13, 1, 33, 12, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (17, 10, 33, 1, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (18, 10, 33, 2, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (19, 10, 33, 3, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (20, 10, 33, 4, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (21, 10, 33, 5, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (22, 10, 33, 6, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (23, 10, 33, 7, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (24, 10, 33, 8, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (25, 10, 33, 9, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (26, 10, 33, 10, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (27, 10, 33, 11, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (28, 10, 33, 12, CAST(N'2024-12-31' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (29, 2, 34, 1, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (30, 2, 34, 2, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (31, 2, 34, 3, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (32, 2, 34, 4, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (33, 2, 34, 5, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (34, 2, 34, 6, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (35, 2, 34, 7, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (36, 2, 34, 8, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (37, 2, 34, 9, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (38, 2, 34, 10, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (39, 2, 34, 11, CAST(N'2024-12-30' AS Date), 1)
INSERT [dbo].[Attendence] ([ID], [ID Hour], [ID ClassSubject], [ID Student], [Date], [Present]) VALUES (40, 2, 34, 12, CAST(N'2024-12-30' AS Date), 1)
SET IDENTITY_INSERT [dbo].[Attendence] OFF
SET IDENTITY_INSERT [dbo].[Book Check out] ON 

INSERT [dbo].[Book Check out] ([Id Check out], [ID Book], [ID Student], [Check out date], [Return date]) VALUES (2, 1, 1, CAST(N'2024-12-30' AS Date), CAST(N'2024-12-31' AS Date))
INSERT [dbo].[Book Check out] ([Id Check out], [ID Book], [ID Student], [Check out date], [Return date]) VALUES (5, 16, 1, CAST(N'2024-12-30' AS Date), CAST(N'2024-12-31' AS Date))
SET IDENTITY_INSERT [dbo].[Book Check out] OFF
SET IDENTITY_INSERT [dbo].[Class] ON 

INSERT [dbo].[Class] ([ID Class], [Number], [ID Tutor]) VALUES (1, N'1A', 1)
INSERT [dbo].[Class] ([ID Class], [Number], [ID Tutor]) VALUES (4, N'2A', 4)
INSERT [dbo].[Class] ([ID Class], [Number], [ID Tutor]) VALUES (7, N'3A', 7)
INSERT [dbo].[Class] ([ID Class], [Number], [ID Tutor]) VALUES (10, N'4A', 10)
INSERT [dbo].[Class] ([ID Class], [Number], [ID Tutor]) VALUES (13, N'5A', 13)
INSERT [dbo].[Class] ([ID Class], [Number], [ID Tutor]) VALUES (16, N'6A', 16)
INSERT [dbo].[Class] ([ID Class], [Number], [ID Tutor]) VALUES (19, N'7A', 19)
INSERT [dbo].[Class] ([ID Class], [Number], [ID Tutor]) VALUES (21, N'8A', 21)
SET IDENTITY_INSERT [dbo].[Class] OFF
SET IDENTITY_INSERT [dbo].[Classrooms] ON 

INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (1, N'101')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (2, N'102')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (3, N'103')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (4, N'104')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (5, N'105')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (6, N'106')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (7, N'111')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (8, N'113')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (9, N'117')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (10, N'119')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (11, N'132')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (12, N'133')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (13, N'145')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (14, N'146')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (15, N'149')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (16, N'150')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (17, N'201')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (18, N'202')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (19, N'203')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (20, N'204')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (21, N'205')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (22, N'206')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (23, N'211')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (24, N'213')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (25, N'217')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (26, N'219')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (27, N'232')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (28, N'233')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (29, N'245')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (30, N'246')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (31, N'249')
INSERT [dbo].[Classrooms] ([ID Class], [Classroom number]) VALUES (32, N'250')
SET IDENTITY_INSERT [dbo].[Classrooms] OFF
SET IDENTITY_INSERT [dbo].[ClassSubjects] ON 

INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (33, 1, 1, 1)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (34, 1, 16, 3)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (35, 1, 18, 5)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (36, 1, 20, 7)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (37, 4, 1, 1)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (38, 4, 17, 4)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (39, 4, 5, 10)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (40, 4, 6, 12)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (41, 4, 12, 19)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (42, 7, 1, 1)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (43, 7, 3, 6)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (44, 7, 9, 16)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (45, 7, 7, 14)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (46, 7, 13, 20)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (47, 10, 13, 1)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (48, 10, 7, 13)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (49, 10, 6, 11)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (50, 10, 1, 2)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (51, 10, 4, 8)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (52, 13, 13, 1)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (53, 13, 11, 18)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (54, 13, 20, 7)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (55, 13, 2, 3)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (56, 16, 13, 1)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (57, 16, 10, 9)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (58, 16, 18, 5)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (59, 16, 1, 2)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (60, 16, 10, 17)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (61, 19, 13, 1)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (62, 19, 17, 4)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (63, 19, 13, 20)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (64, 19, 10, 9)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (65, 19, 6, 11)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (66, 21, 1, 1)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (67, 21, 6, 12)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (68, 21, 7, 14)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (69, 21, 12, 19)
INSERT [dbo].[ClassSubjects] ([ID], [ID Class], [ID Teacher], [ID Subject]) VALUES (70, 21, 6, 7)
SET IDENTITY_INSERT [dbo].[ClassSubjects] OFF
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (1, 1, 1, CAST(N'2024-01-01 09:15:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (2, 1, 1, CAST(N'2024-01-02 08:35:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (2, 4, 16, CAST(N'2024-01-01 08:55:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (4, 8, 18, CAST(N'2024-01-04 09:40:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (5, 1, 1, CAST(N'2024-01-01 09:45:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (9, 26, 6, CAST(N'2024-01-03 13:00:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (9, 27, 6, CAST(N'2024-01-03 13:00:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (9, 28, 6, CAST(N'2024-01-03 13:00:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (18, 358, 17, CAST(N'2024-01-04 08:55:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (18, 361, 17, CAST(N'2024-01-04 08:55:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (18, 12, 1, CAST(N'2024-01-08 09:20:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (21, 300, 16, CAST(N'2024-01-01 13:45:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (21, 304, 16, CAST(N'2024-01-01 13:45:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (15, 122, 3, CAST(N'2024-01-01 10:07:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (15, 124, 3, CAST(N'2024-01-01 10:07:00.000' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (1, 1, 1, CAST(N'2024-12-28 12:10:11.903' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (1, 1, 1, CAST(N'2024-12-28 12:12:46.747' AS DateTime))
INSERT [dbo].[DisciplineReferrals] ([ID DR], [ID Student], [ID Teacher], [Date]) VALUES (1, 1, 1, CAST(N'2024-12-28 12:13:09.137' AS DateTime))
SET IDENTITY_INSERT [dbo].[DisciplineReferralsDesc] ON 

INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (1, N'Nieodpowiednie zachowanie na lekcji', 2)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (2, N'Spóźnienie na zajęcia', 1)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (3, N'Nieprzestrzeganie zasad dotyczących ubioru', 1)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (4, N'Używanie telefonu komórkowego podczas lekcji', 2)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (5, N'Nieodpowiedni język używany w rozmowie z nauczycielem', 3)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (6, N'Zachowanie agresywne wobec kolegów', 4)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (7, N'Wagarowanie bez usprawiedliwienia', 3)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (8, N'Niszczenie mienia szkolnego', 4)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (9, N'Popełnianie oszustw podczas testów', 4)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (10, N'Nieuczciwe zachowanie na sprawdzianie', 4)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (11, N'Niechęć do współpracy w grupie', 2)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (12, N'Nieprzestrzeganie regulaminu szkolnej biblioteki', 2)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (13, N'Publiczne wyśmiewanie innych uczniów', 3)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (14, N'Przeciąganie lekcji i zakłócanie porządku w klasie', 2)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (15, N'Kłamstwo wobec nauczyciela', 3)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (16, N'Złośliwe żarty w stosunku do kolegów', 2)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (17, N'Skradanie się do odpowiedzi podczas zajęć', 4)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (18, N'Podrabianie podpisu rodzica', 4)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (19, N'Zgubienie lub uszkodzenie sprzętu szkolnego', 2)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (20, N'Nielegalne używanie substancji odurzających', 4)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (21, N'Zostawianie nieporządku po lekcjach', 1)
INSERT [dbo].[DisciplineReferralsDesc] ([ID DR], [Content], [Weight]) VALUES (22, N'Naruszenie regulaminu stołówki szkolnej', 1)
SET IDENTITY_INSERT [dbo].[DisciplineReferralsDesc] OFF
SET IDENTITY_INSERT [dbo].[Library] ON 

INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (1, N'Pan Tadeusz', N'Adam Mickiewicz', N'1834', N'Epopeja narodowa', 5)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (2, N'Lalka', N'Bolesław Prus', N'1890', N'Powieść', 3)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (3, N'Krzyżacy', N'Henryk Sienkiewicz', N'1900', N'Historyczna', 7)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (4, N'Ferdydurke', N'Witold Gombrowicz', N'1937', N'Modernizm', 4)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (5, N'Quo Vadis', N'Henryk Sienkiewicz', N'1896', N'Historyczna', 6)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (6, N'Władca Pierścieni: Drużyna Pierścienia', N'J.R.R. Tolkien', N'1954', N'Fantasy', 8)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (7, N'Harry Potter i Kamień Filozoficzny', N'J.K. Rowling', N'1997', N'Fantasy', 12)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (8, N'Zbrodnia i kara', N'Fiodor Dostojewski', N'1866', N'Powieść psychologiczna', 6)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (9, N'Przeminęło z wiatrem', N'Margaret Mitchell', N'1936', N'Romans', 5)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (10, N'Hobbit, czyli tam i z powrotem', N'J.R.R. Tolkien', N'1937', N'Fantasy', 10)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (11, N'Wielki Gatsby', N'F. Scott Fitzgerald', N'1925', N'Powieść', 7)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (12, N'Sto lat samotności', N'Gabriel García Márquez', N'1967', N'Realizm magiczny', 9)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (13, N'Mistrz i Małgorzata', N'Michaił Bułhakow', N'1967', N'Realizm magiczny', 4)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (14, N'Duma i uprzedzenie', N'Jane Austen', N'1813', N'Romans', 6)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (15, N'1984', N'George Orwell', N'1949', N'Dystopia', 8)
INSERT [dbo].[Library] ([Id Book], [Title], [Author], [Release Year], [Genre], [Available Copies]) VALUES (16, N'Kwiaty dla Algernona', N'Daniel Keyes', N'1959', N'Science Fiction', 0)
SET IDENTITY_INSERT [dbo].[Library] OFF
SET IDENTITY_INSERT [dbo].[Marks] ON 

INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (1, 5, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 1)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (2, 4, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 2)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (3, 2, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 3)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (4, 1, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 4)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (5, 2, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 5)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (6, 3, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 6)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (7, 4, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 7)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (8, 4, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 8)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (9, 6, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 9)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (10, 5, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 10)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (11, 3, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 11)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (12, 1, 3, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 12)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (1, 6, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 13)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (2, 3, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 14)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (3, 3, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 15)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (4, 2, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 16)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (5, 2, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 17)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (6, 2, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 18)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (7, 5, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 19)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (8, 5, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 20)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (9, 6, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 21)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (10, 4, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 22)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (11, 4, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 23)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (12, 3, 1, 1, 1, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 24)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (1, 1, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 25)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (2, 6, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 26)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (3, 6, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 27)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (4, 6, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 28)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (5, 5, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 29)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (6, 2, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 30)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (7, 2, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 31)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (8, 2, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 32)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (9, 2, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 33)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (10, 3, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 34)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (11, 3, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 35)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (12, 3, 2, 16, 3, CAST(N'2024-12-23 11:54:18.900' AS DateTime), 36)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (25, 2, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 37)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (26, 3, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 38)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (27, 4, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 39)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (28, 5, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 40)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (29, 1, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 41)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (30, 1, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 42)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (31, 2, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 43)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (32, 5, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 44)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (33, 3, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 45)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (34, 1, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 46)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (35, 1, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 47)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (36, 2, 1, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 48)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (25, 2, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 49)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (26, 2, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 50)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (27, 2, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 51)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (28, 4, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 52)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (29, 4, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 53)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (30, 4, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 54)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (31, 3, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 55)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (32, 3, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 56)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (33, 3, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 57)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (34, 3, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 58)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (35, 3, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 59)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (36, 3, 4, 7, 14, CAST(N'2024-12-23 12:11:18.067' AS DateTime), 60)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (25, 1, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 61)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (26, 2, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 62)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (27, 3, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 63)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (28, 4, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 64)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (29, 5, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 65)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (30, 1, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 66)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (31, 2, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 67)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (32, 3, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 68)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (33, 4, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 69)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (34, 5, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 70)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (35, 1, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 71)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (36, 2, 2, 6, 7, CAST(N'2024-12-23 12:12:13.717' AS DateTime), 72)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (74, 5, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 73)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (75, 3, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 74)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (76, 4, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 75)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (77, 2, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 76)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (78, 1, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 77)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (79, 4, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 78)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (80, 3, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 79)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (81, 4, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 80)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (82, 2, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 81)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (83, 2, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 82)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (84, 3, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 83)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (85, 3, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 84)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (86, 4, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 85)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (87, 5, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 86)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (88, 5, 3, 5, 10, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 87)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (74, 2, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 88)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (75, 4, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 89)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (76, 1, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 90)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (77, 5, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 91)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (78, 4, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 92)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (79, 2, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 93)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (80, 2, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 94)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (81, 3, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 95)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (82, 3, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 96)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (83, 4, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 97)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (84, 5, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 98)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (85, 1, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 99)
GO
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (86, 3, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 100)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (87, 4, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 101)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (88, 1, 3, 17, 4, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 102)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (74, 1, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 103)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (75, 3, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 104)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (76, 4, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 105)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (77, 2, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 106)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (78, 3, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 107)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (79, 5, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 108)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (80, 4, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 109)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (81, 2, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 110)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (82, 4, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 111)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (83, 2, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 112)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (84, 4, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 113)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (85, 2, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 114)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (86, 2, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 115)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (87, 5, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 116)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (88, 3, 3, 1, 1, CAST(N'2024-12-23 12:17:11.477' AS DateTime), 117)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (119, 3, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 118)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (120, 1, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 119)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (121, 3, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 120)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (122, 2, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 121)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (123, 5, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 122)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (124, 1, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 123)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (125, 4, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 124)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (126, 5, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 125)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (127, 4, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 126)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (128, 5, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 127)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (129, 2, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 128)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (130, 4, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 129)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (131, 1, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 130)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (132, 2, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 131)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (133, 5, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 132)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (134, 5, 3, 3, 6, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 133)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (119, 2, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 134)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (120, 4, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 135)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (121, 4, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 136)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (122, 3, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 137)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (123, 5, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 138)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (124, 5, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 139)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (125, 2, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 140)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (126, 4, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 141)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (127, 2, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 142)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (128, 3, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 143)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (129, 1, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 144)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (130, 3, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 145)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (131, 1, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 146)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (132, 5, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 147)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (133, 4, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 148)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (134, 5, 1, 9, 16, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 149)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (119, 4, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 150)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (120, 3, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 151)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (121, 1, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 152)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (122, 4, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 153)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (123, 1, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 154)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (124, 5, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 155)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (125, 5, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 156)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (126, 1, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 157)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (127, 1, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 158)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (128, 3, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 159)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (129, 5, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 160)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (130, 2, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 161)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (131, 4, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 162)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (132, 1, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 163)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (133, 4, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 164)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (134, 5, 3, 7, 14, CAST(N'2024-12-23 12:22:06.043' AS DateTime), 165)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (167, 2, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 166)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (168, 3, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 167)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (169, 2, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 168)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (170, 5, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 169)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (171, 3, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 170)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (172, 5, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 171)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (173, 5, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 172)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (174, 2, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 173)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (175, 1, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 174)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (176, 5, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 175)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (177, 2, 1, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 176)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (167, 5, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 177)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (168, 1, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 178)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (169, 4, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 179)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (170, 4, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 180)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (171, 4, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 181)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (172, 4, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 182)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (173, 3, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 183)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (174, 3, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 184)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (175, 2, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 185)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (176, 2, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 186)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (177, 3, 3, 7, 13, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 187)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (167, 2, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 188)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (168, 5, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 189)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (169, 3, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 190)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (170, 2, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 191)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (171, 5, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 192)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (172, 1, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 193)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (173, 5, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 194)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (174, 2, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 195)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (175, 3, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 196)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (176, 5, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 197)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (177, 5, 2, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 198)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (167, 3, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 199)
GO
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (168, 2, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 200)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (169, 2, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 201)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (170, 4, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 202)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (171, 5, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 203)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (172, 4, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 204)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (173, 3, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 205)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (174, 5, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 206)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (175, 4, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 207)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (176, 3, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 208)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (177, 5, 3, 6, 11, CAST(N'2024-12-23 12:23:57.167' AS DateTime), 209)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (353, 1, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 210)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (354, 2, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 211)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (355, 1, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 212)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (356, 2, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 213)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (357, 2, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 214)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (358, 1, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 215)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (359, 3, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 216)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (360, 2, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 217)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (361, 2, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 218)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (362, 5, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 219)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (363, 5, 1, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 220)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (353, 2, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 221)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (354, 1, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 222)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (355, 3, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 223)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (356, 2, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 224)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (357, 2, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 225)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (358, 4, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 226)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (359, 1, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 227)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (360, 3, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 228)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (361, 3, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 229)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (362, 4, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 230)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (363, 4, 2, 13, 20, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 231)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (353, 1, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 232)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (354, 1, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 233)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (355, 3, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 234)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (356, 1, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 235)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (357, 5, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 236)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (358, 4, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 237)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (359, 5, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 238)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (360, 1, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 239)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (361, 2, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 240)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (362, 1, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 241)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (363, 2, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 242)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (353, 3, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 243)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (354, 2, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 244)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (355, 3, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 245)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (356, 5, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 246)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (357, 4, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 247)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (358, 1, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 248)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (359, 1, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 249)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (360, 3, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 250)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (361, 2, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 251)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (362, 4, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 252)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (363, 5, 1, 13, 1, CAST(N'2024-12-23 12:30:53.267' AS DateTime), 253)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (253, 1, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 254)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (254, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 255)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (255, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 256)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (256, 2, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 257)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (257, 4, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 258)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (258, 4, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 259)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (259, 4, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 260)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (260, 4, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 261)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (261, 4, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 262)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (262, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 263)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (263, 2, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 264)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (264, 2, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 265)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (265, 4, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 266)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (266, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 267)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (253, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 268)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (254, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 269)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (255, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 270)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (256, 4, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 271)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (257, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 272)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (258, 1, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 273)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (259, 2, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 274)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (260, 3, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 275)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (261, 2, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 276)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (262, 3, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 277)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (263, 1, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 278)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (264, 3, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 279)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (265, 1, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 280)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (266, 5, 3, 20, 7, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 281)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (253, 3, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 282)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (254, 2, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 283)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (255, 4, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 284)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (256, 2, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 285)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (257, 5, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 286)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (258, 4, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 287)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (259, 2, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 288)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (260, 1, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 289)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (261, 4, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 290)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (262, 4, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 291)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (263, 5, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 292)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (264, 3, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 293)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (265, 5, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 294)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (266, 2, 3, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 295)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (253, 3, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 296)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (254, 2, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 297)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (255, 3, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 298)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (256, 5, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 299)
GO
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (257, 5, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 300)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (258, 3, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 301)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (259, 5, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 302)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (260, 3, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 303)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (261, 3, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 304)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (262, 4, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 305)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (263, 4, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 306)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (264, 4, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 307)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (265, 5, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 308)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (266, 2, 1, 2, 3, CAST(N'2024-12-23 12:32:17.227' AS DateTime), 309)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (295, 1, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 310)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (296, 1, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 311)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (297, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 312)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (298, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 313)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (299, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 314)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (300, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 315)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (301, 3, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 316)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (302, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 317)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (303, 2, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 318)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (304, 5, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 319)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (305, 3, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 320)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (306, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 321)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (307, 2, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 322)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (308, 1, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 323)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (295, 1, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 324)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (296, 2, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 325)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (297, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 326)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (298, 2, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 327)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (299, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 328)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (300, 5, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 329)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (301, 5, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 330)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (302, 4, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 331)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (303, 5, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 332)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (304, 1, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 333)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (305, 2, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 334)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (306, 1, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 335)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (307, 3, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 336)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (308, 2, 2, 10, 17, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 337)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (295, 3, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 338)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (296, 5, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 339)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (297, 3, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 340)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (298, 1, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 341)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (299, 3, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 342)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (300, 2, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 343)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (301, 1, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 344)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (302, 1, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 345)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (303, 1, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 346)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (304, 1, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 347)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (305, 2, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 348)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (306, 2, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 349)
INSERT [dbo].[Marks] ([ID Student], [Mark], [Weight], [ID Teacher], [ID Subject], [Date of issue], [ID Mark]) VALUES (307, 1, 2, 10, 9, CAST(N'2024-12-23 12:34:22.113' AS DateTime), 350)
SET IDENTITY_INSERT [dbo].[Marks] OFF
SET IDENTITY_INSERT [dbo].[Students] ON 

INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (1, N'Krzysztof', N'Adamski', 1, N'Warszawa', N'Nowogrodzka 12', N'00-121', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (2, N'Anna', N'Białek', 2, N'Warszawa', N'Koszykowa 5', N'00-222', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (3, N'Michał', N'Czarnecki', 3, N'Warszawa', N'Żelazna 17', N'00-323', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (4, N'Ewa', N'Dąbrowska', 4, N'Warszawa', N'Piekarska 7', N'00-424', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (5, N'Tomasz', N'Ewczak', 5, N'Warszawa', N'Belwederska 4', N'00-525', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (6, N'Joanna', N'Falkowska', 6, N'Warszawa', N'Modlińska 11', N'00-626', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (7, N'Piotr', N'Gajda', 7, N'Warszawa', N'Saska 15', N'00-727', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (8, N'Monika', N'Herman', 8, N'Warszawa', N'Grochowska 19', N'00-828', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (9, N'Kamil', N'Iwański', 9, N'Warszawa', N'Ostrobramska 20', N'00-929', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (10, N'Paulina', N'Jankowska', 10, N'Warszawa', N'Targowa 8', N'01-010', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (11, N'Jakub', N'Kamiński', 11, N'Warszawa', N'Ząbkowska 6', N'01-121', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (12, N'Alicja', N'Laskowska', 12, N'Warszawa', N'Praga 10', N'01-232', 1)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (25, N'Julia', N'Chmiel', 1, N'Warszawa', N'Nowy Świat 3', N'00-889', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (26, N'Filip', N'Dobrowolski', 2, N'Warszawa', N'Aleja Solidarności 22', N'01-202', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (27, N'Oliwia', N'Elińska', 3, N'Warszawa', N'Radzymińska 7', N'01-303', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (28, N'Konrad', N'Frąckowiak', 4, N'Warszawa', N'Grójecka 14', N'01-404', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (29, N'Zuzanna', N'Grzelak', 5, N'Warszawa', N'Opaczewska 18', N'01-505', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (30, N'Patryk', N'Hofman', 6, N'Warszawa', N'Twarda 9', N'01-606', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (31, N'Angelika', N'Ignaczak', 7, N'Warszawa', N'Szczęśliwicka 11', N'01-707', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (32, N'Wojciech', N'Jędrzejewski', 8, N'Warszawa', N'Kasprzaka 12', N'01-808', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (33, N'Izabela', N'Kamińska', 9, N'Warszawa', N'Okopowa 2', N'01-909', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (34, N'Dominika', N'Lisowska', 10, N'Warszawa', N'Wola 5', N'01-111', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (35, N'Kacper', N'Majewski', 11, N'Warszawa', N'Koło 13', N'01-212', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (36, N'Ewelina', N'Nowak', 12, N'Warszawa', N'Muranowska 8', N'01-313', 21)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (74, N'Adam', N'Nowakowski', 11, N'Warszawa', N'Sienna 5', N'00-120', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (75, N'Ewa', N'Kowalska', 8, N'Warszawa', N'Chmielna 7', N'00-223', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (76, N'Paweł', N'Zieliński', 15, N'Warszawa', N'Żelazna 10', N'00-323', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (77, N'Kinga', N'Wysocka', 14, N'Warszawa', N'Marszałkowska 12', N'00-424', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (78, N'Michał', N'Borowski', 2, N'Warszawa', N'Nowogrodzka 18', N'00-525', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (79, N'Joanna', N'Wiśniewska', 13, N'Warszawa', N'Grochowska 20', N'00-626', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (80, N'Tomasz', N'Dąbrowski', 3, N'Warszawa', N'Saska 15', N'00-727', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (81, N'Zofia', N'Kamińska', 6, N'Warszawa', N'Hoża 11', N'00-828', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (82, N'Kamil', N'Kowalczyk', 7, N'Warszawa', N'Koszykowa 6', N'00-929', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (83, N'Anna', N'Mazur', 10, N'Warszawa', N'Praga 14', N'01-010', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (84, N'Jakub', N'Szymański', 12, N'Warszawa', N'Targowa 3', N'01-121', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (85, N'Magdalena', N'Górska', 4, N'Warszawa', N'Ząbkowska 8', N'01-232', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (86, N'Filip', N'Laskowski', 9, N'Warszawa', N'Radzymińska 2', N'01-343', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (87, N'Katarzyna', N'Adamska', 1, N'Warszawa', N'Okęcie 5', N'01-454', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (88, N'Sebastian', N'Kaczmarek', 5, N'Warszawa', N'Bemowo 12', N'01-565', 4)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (119, N'Damian', N'Kowal', 4, N'Warszawa', N'Twarda 4', N'04-101', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (120, N'Patrycja', N'Król', 5, N'Warszawa', N'Nowogrodzka 6', N'04-202', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (121, N'Adrian', N'Błaszczyk', 1, N'Warszawa', N'Chmielna 12', N'04-303', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (122, N'Barbara', N'Kulesza', 6, N'Warszawa', N'Marszałkowska 5', N'04-404', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (123, N'Wojciech', N'Nowak', 11, N'Warszawa', N'Hoża 9', N'04-505', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (124, N'Anna', N'Piątek', 13, N'Warszawa', N'Foksal 3', N'04-606', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (125, N'Mateusz', N'Urban', 15, N'Warszawa', N'Koszykowa 7', N'04-707', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (126, N'Zuzanna', N'Marek', 8, N'Warszawa', N'Okopowa 10', N'04-808', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (127, N'Michał', N'Wilczyński', 16, N'Warszawa', N'Żelazna 15', N'04-909', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (128, N'Joanna', N'Orzeł', 12, N'Warszawa', N'Targowa 8', N'05-010', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (129, N'Jakub', N'Lis', 7, N'Warszawa', N'Radzymińska 18', N'05-121', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (130, N'Gabriela', N'Nowacka', 10, N'Warszawa', N'Ząbkowska 11', N'05-232', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (131, N'Kamil', N'Frączek', 3, N'Warszawa', N'Praga 14', N'05-343', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (132, N'Julia', N'Rataj', 14, N'Warszawa', N'Bemowo 16', N'05-454', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (133, N'Filip', N'Mazur', 9, N'Warszawa', N'Śródmieście 2', N'05-565', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (134, N'Alicja', N'Cieślik', 2, N'Warszawa', N'Grójecka 7', N'05-676', 7)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (167, N'Krystian', N'Nowak', 10, N'Warszawa', N'Twarda 5', N'10-101', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (168, N'Klaudia', N'Kowalczyk', 6, N'Warszawa', N'Grochowska 14', N'10-202', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (169, N'Szymon', N'Bąk', 1, N'Warszawa', N'Chmielna 18', N'10-303', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (170, N'Monika', N'Laskowska', 8, N'Warszawa', N'Marszałkowska 9', N'10-404', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (171, N'Paweł', N'Białek', 2, N'Warszawa', N'Hoża 13', N'10-505', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (172, N'Magdalena', N'Mazur', 9, N'Warszawa', N'Złota 2', N'10-606', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (173, N'Jakub', N'Frączek', 3, N'Warszawa', N'Muranowska 8', N'10-707', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (174, N'Olga', N'Jabłońska', 4, N'Warszawa', N'Nowy Świat 3', N'10-808', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (175, N'Adam', N'Kwiatkowski', 7, N'Warszawa', N'Okęcie 17', N'10-909', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (176, N'Natalia', N'Piotrowska', 11, N'Warszawa', N'Sienna 14', N'11-010', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (177, N'Michał', N'Kaczmarek', 5, N'Warszawa', N'Śródmieście 6', N'11-121', 10)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (253, N'Agnieszka', N'Sienkiewicz', 11, N'Warszawa', N'Białostocka 15', N'13-505', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (254, N'Kamil', N'Rogowski', 10, N'Warszawa', N'Wolność 22', N'13-606', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (255, N'Aleksandra', N'Stolarz', 12, N'Warszawa', N'Śródmieście 8', N'13-707', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (256, N'Piotr', N'Baran', 1, N'Warszawa', N'Łódzka 9', N'13-808', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (257, N'Monika', N'Wilkowska', 13, N'Warszawa', N'Rejowiecka 13', N'13-909', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (258, N'Weronika', N'Górska', 3, N'Warszawa', N'Królewska 7', N'14-010', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (259, N'Grzegorz', N'Majewski', 6, N'Warszawa', N'Chmielna 4', N'14-121', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (260, N'Katarzyna', N'Rogal', 9, N'Warszawa', N'Przyokopowa 10', N'14-232', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (261, N'Łukasz', N'Kowalski', 5, N'Warszawa', N'Wojciechowska 12', N'14-343', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (262, N'Julia', N'Piątek', 7, N'Warszawa', N'Grudziądzka 8', N'14-454', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (263, N'Oskar', N'Piotrowski', 8, N'Warszawa', N'Kierowa 5', N'14-565', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (264, N'Zuzanna', N'Jankowska', 4, N'Warszawa', N'Malczewska 13', N'14-676', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (265, N'Sebastian', N'Wiśniewski', 14, N'Warszawa', N'Marek 17', N'14-787', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (266, N'Natalia', N'Białek', 2, N'Warszawa', N'Nowoczesna 9', N'14-898', 13)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (295, N'Mateusz', N'Słomka', 11, N'Warszawa', N'Miejska 13', N'16-101', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (296, N'Klaudia', N'Żuraw', 14, N'Warszawa', N'Kościelna 4', N'16-202', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (297, N'Piotr', N'Niemec', 7, N'Warszawa', N'Praga 8', N'16-303', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (298, N'Agnieszka', N'Zielińska', 13, N'Warszawa', N'Krakowska 2', N'16-404', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (299, N'Michał', N'Ławniczak', 6, N'Warszawa', N'Okrężna 14', N'16-505', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (300, N'Emilia', N'Domańska', 1, N'Warszawa', N'Pięciomorgowa 17', N'16-606', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (301, N'Wojciech', N'Kucharski', 5, N'Warszawa', N'Zimowa 11', N'16-707', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (302, N'Natalia', N'Jankowska', 3, N'Warszawa', N'Odrzańska 8', N'16-808', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (303, N'Oskar', N'Wilkowski', 12, N'Warszawa', N'Radosna 3', N'16-909', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (304, N'Gabriela', N'Sikora', 10, N'Warszawa', N'Śródmieście 20', N'16-010', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (305, N'Kamil', N'Kubiak', 4, N'Warszawa', N'Sosnowa 12', N'16-121', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (306, N'Lena', N'Piotrowska', 8, N'Warszawa', N'Rynkowa 10', N'16-232', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (307, N'Łukasz', N'Róg', 9, N'Warszawa', N'Bławatna 19', N'16-343', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (308, N'Zuzanna', N'Frączek', 2, N'Warszawa', N'Czerwona 8', N'16-454', 16)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (353, N'Aleksander', N'Róg', 7, N'Warszawa', N'Wolność 8', N'19-101', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (354, N'Katarzyna', N'Jasik', 3, N'Warszawa', N'Młynarska 4', N'19-202', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (355, N'Piotr', N'Tomaszewski', 9, N'Warszawa', N'Targowa 3', N'19-303', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (356, N'Zuzanna', N'Borowska', 1, N'Warszawa', N'Kopernika 15', N'19-404', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (357, N'Marek', N'Ślusarczyk', 8, N'Warszawa', N'Krakowska 2', N'19-505', 19)
GO
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (358, N'Natalia', N'Walentowicz', 10, N'Warszawa', N'Rejowa 7', N'19-606', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (359, N'Łukasz', N'Kaczmarek', 4, N'Warszawa', N'Świętojańska 13', N'19-707', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (360, N'Ewa', N'Górska', 2, N'Warszawa', N'Słoneczna 5', N'19-808', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (361, N'Mateusz', N'Wilkowski', 11, N'Warszawa', N'Główna 11', N'19-909', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (362, N'Julia', N'Mazurek', 5, N'Warszawa', N'Pięciomorgowa 12', N'19-010', 19)
INSERT [dbo].[Students] ([ID Student], [Name], [Surname], [ClassRegisterNum], [AddressCity], [AddressStreet], [AddressPostCode], [ID Class]) VALUES (363, N'Kamil', N'Niedźwiedzki', 6, N'Warszawa', N'Przemysłowa 8', N'19-121', 19)
SET IDENTITY_INSERT [dbo].[Students] OFF
SET IDENTITY_INSERT [dbo].[Subjects] ON 

INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (3, N'Biologia')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (4, N'Chemia')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (18, N'Etyka')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (5, N'Fizyka')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (6, N'Geografia')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (7, N'Historia')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (9, N'Informatyka')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (10, N'Język angielski')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (12, N'Język francuski')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (13, N'Język hiszpański')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (11, N'Język niemiecki')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (2, N'Język polski')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (1, N'Matematyka')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (14, N'Muzyka')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (15, N'Plastyka')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (19, N'Podstawy przedsiębiorczości')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (17, N'Religia')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (20, N'Technika')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (8, N'Wiedza o społeczeństwie')
INSERT [dbo].[Subjects] ([ID Subject], [Subject Name]) VALUES (16, N'Wychowanie fizyczne')
SET IDENTITY_INSERT [dbo].[Subjects] OFF
SET IDENTITY_INSERT [dbo].[Teachers] ON 

INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (1, N'Anna', N'Kowalska', N'Warszawa', N'Mazowiecka 15', N'00-123')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (2, N'Jan', N'Nowak', N'Warszawa', N'Wawelska 10', N'00-234')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (3, N'Maria', N'Wiśniewska', N'Warszawa', N'Miodowa 5', N'00-345')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (4, N'Piotr', N'Zieliński', N'Warszawa', N'Świętokrzyska 20', N'00-456')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (5, N'Katarzyna', N'Szymczak', N'Warszawa', N'Marszałkowska 25', N'00-567')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (6, N'Tomasz', N'Kwiatkowski', N'Warszawa', N'Krucza 8', N'00-678')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (7, N'Agnieszka', N'Lewandowska', N'Warszawa', N'Puławska 12', N'00-789')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (8, N'Michał', N'Wróbel', N'Warszawa', N'Wilcza 16', N'00-890')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (9, N'Joanna', N'Dąbrowska', N'Warszawa', N'Foksal 3', N'00-901')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (10, N'Grzegorz', N'Lis', N'Warszawa', N'Tamka 22', N'00-112')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (11, N'Ewa', N'Nowicka', N'Warszawa', N'Hoża 18', N'00-223')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (12, N'Krzysztof', N'Czarnecki', N'Warszawa', N'Polna 11', N'00-334')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (13, N'Barbara', N'Kamińska', N'Warszawa', N'Chmielna 7', N'00-445')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (14, N'Andrzej', N'Sadowski', N'Warszawa', N'Emilii Plater 14', N'00-556')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (15, N'Elżbieta', N'Mazurek', N'Warszawa', N'Żurawia 6', N'00-667')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (16, N'Rafał', N'Baran', N'Warszawa', N'Sienna 21', N'00-778')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (17, N'Paulina', N'Grabowska', N'Warszawa', N'Nowy Świat 2', N'00-889')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (18, N'Marcin', N'Ostrowski', N'Warszawa', N'Aleje Jerozolimskie 18', N'00-990')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (19, N'Monika', N'Zawadzka', N'Warszawa', N'Złota 5', N'00-101')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (20, N'Wojciech', N'Górski', N'Warszawa', N'Plac Trzech Krzyży 9', N'00-212')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (21, N'Zofia', N'Malinowska', N'Warszawa', N'Nowogrodzka 11', N'00-121')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (22, N'Paweł', N'Jabłoński', N'Warszawa', N'Koszykowa 22', N'00-222')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (23, N'Dorota', N'Krzemińska', N'Warszawa', N'Żelazna 14', N'00-323')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (24, N'Łukasz', N'Gajewski', N'Warszawa', N'Piekarska 30', N'00-424')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (25, N'Aleksandra', N'Bielak', N'Warszawa', N'Belwederska 6', N'00-525')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (26, N'Karol', N'Mazur', N'Warszawa', N'Modlińska 8', N'00-626')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (27, N'Natalia', N'Kopeć', N'Warszawa', N'Saska 12', N'00-727')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (28, N'Maciej', N'Pawlik', N'Warszawa', N'Grochowska 18', N'00-828')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (29, N'Justyna', N'Urban', N'Warszawa', N'Ostrobramska 5', N'00-929')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (30, N'Wiktor', N'Borowski', N'Warszawa', N'Targowa 3', N'01-010')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (31, N'Ewelina', N'Chmielewska', N'Warszawa', N'Ząbkowska 7', N'01-121')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (32, N'Sebastian', N'Wróblewski', N'Warszawa', N'Praga 11', N'01-232')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (33, N'Adrian', N'Sikorski', N'Warszawa', N'Powstańców 4', N'01-343')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (34, N'Weronika', N'Ratajczak', N'Warszawa', N'Czynszowa 2', N'01-454')
INSERT [dbo].[Teachers] ([ID Teacher], [Name], [Surname], [AddressCity], [AddressStreet], [AddressPostCode]) VALUES (35, N'Tadeusz', N'Cieślak', N'Warszawa', N'Kijowska 9', N'01-565')
SET IDENTITY_INSERT [dbo].[Teachers] OFF
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (1, 1)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (1, 2)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (2, 3)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (2, 4)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (3, 5)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (3, 6)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (4, 7)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (4, 8)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (5, 9)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (5, 10)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (6, 7)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (6, 11)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (6, 12)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (7, 13)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (7, 14)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (8, 15)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (9, 16)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (10, 9)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (10, 10)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (10, 17)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (11, 18)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (12, 19)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (13, 1)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (13, 20)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (14, 1)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (15, 2)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (16, 3)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (17, 4)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (18, 5)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (19, 6)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (20, 7)
INSERT [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject]) VALUES (20, 8)
SET IDENTITY_INSERT [dbo].[TeachingHours] ON 

INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (1, CAST(N'2024-01-01 09:00:00.000' AS DateTime), CAST(N'2024-01-01 09:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (2, CAST(N'2024-01-01 10:00:00.000' AS DateTime), CAST(N'2024-01-01 10:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (3, CAST(N'2024-01-01 11:00:00.000' AS DateTime), CAST(N'2024-01-01 11:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (4, CAST(N'2024-01-01 12:00:00.000' AS DateTime), CAST(N'2024-01-01 12:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (5, CAST(N'2024-01-01 13:00:00.000' AS DateTime), CAST(N'2024-01-01 13:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (6, CAST(N'2024-01-01 14:00:00.000' AS DateTime), CAST(N'2024-01-01 14:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (7, CAST(N'2024-01-01 15:00:00.000' AS DateTime), CAST(N'2024-01-01 15:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (8, CAST(N'2024-01-01 16:00:00.000' AS DateTime), CAST(N'2024-01-01 16:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (9, CAST(N'2024-01-01 17:00:00.000' AS DateTime), CAST(N'2024-01-01 17:45:00.000' AS DateTime), N'Poniedzialek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (10, CAST(N'2024-01-01 08:30:00.000' AS DateTime), CAST(N'2024-01-01 09:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (11, CAST(N'2024-01-01 09:30:00.000' AS DateTime), CAST(N'2024-01-01 10:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (12, CAST(N'2024-01-01 10:30:00.000' AS DateTime), CAST(N'2024-01-01 11:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (13, CAST(N'2024-01-01 11:30:00.000' AS DateTime), CAST(N'2024-01-01 12:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (14, CAST(N'2024-01-01 12:30:00.000' AS DateTime), CAST(N'2024-01-01 13:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (15, CAST(N'2024-01-01 13:30:00.000' AS DateTime), CAST(N'2024-01-01 14:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (16, CAST(N'2024-01-01 14:30:00.000' AS DateTime), CAST(N'2024-01-01 15:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (17, CAST(N'2024-01-01 15:30:00.000' AS DateTime), CAST(N'2024-01-01 16:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (18, CAST(N'2024-01-01 16:30:00.000' AS DateTime), CAST(N'2024-01-01 17:15:00.000' AS DateTime), N'Wtorek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (19, CAST(N'2024-01-01 08:00:00.000' AS DateTime), CAST(N'2024-01-01 08:45:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (20, CAST(N'2024-01-01 08:50:00.000' AS DateTime), CAST(N'2024-01-01 09:35:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (21, CAST(N'2024-01-01 09:40:00.000' AS DateTime), CAST(N'2024-01-01 10:25:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (22, CAST(N'2024-01-01 10:30:00.000' AS DateTime), CAST(N'2024-01-01 11:15:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (23, CAST(N'2024-01-01 11:20:00.000' AS DateTime), CAST(N'2024-01-01 12:05:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (24, CAST(N'2024-01-01 12:10:00.000' AS DateTime), CAST(N'2024-01-01 12:55:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (25, CAST(N'2024-01-01 13:00:00.000' AS DateTime), CAST(N'2024-01-01 13:45:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (26, CAST(N'2024-01-01 13:50:00.000' AS DateTime), CAST(N'2024-01-01 14:35:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (27, CAST(N'2024-01-01 14:40:00.000' AS DateTime), CAST(N'2024-01-01 15:25:00.000' AS DateTime), N'Sroda')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (28, CAST(N'2024-01-01 08:00:00.000' AS DateTime), CAST(N'2024-01-01 08:45:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (29, CAST(N'2024-01-01 08:50:00.000' AS DateTime), CAST(N'2024-01-01 09:35:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (30, CAST(N'2024-01-01 09:40:00.000' AS DateTime), CAST(N'2024-01-01 10:25:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (31, CAST(N'2024-01-01 10:30:00.000' AS DateTime), CAST(N'2024-01-01 11:15:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (32, CAST(N'2024-01-01 11:20:00.000' AS DateTime), CAST(N'2024-01-01 12:05:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (33, CAST(N'2024-01-01 12:10:00.000' AS DateTime), CAST(N'2024-01-01 12:55:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (34, CAST(N'2024-01-01 13:00:00.000' AS DateTime), CAST(N'2024-01-01 13:45:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (35, CAST(N'2024-01-01 13:50:00.000' AS DateTime), CAST(N'2024-01-01 14:35:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (36, CAST(N'2024-01-01 14:40:00.000' AS DateTime), CAST(N'2024-01-01 15:25:00.000' AS DateTime), N'Czwartek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (37, CAST(N'2024-01-01 07:00:00.000' AS DateTime), CAST(N'2024-01-01 07:45:00.000' AS DateTime), N'Piatek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (38, CAST(N'2024-01-01 07:50:00.000' AS DateTime), CAST(N'2024-01-01 08:35:00.000' AS DateTime), N'Piatek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (39, CAST(N'2024-01-01 08:40:00.000' AS DateTime), CAST(N'2024-01-01 09:25:00.000' AS DateTime), N'Piatek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (40, CAST(N'2024-01-01 09:30:00.000' AS DateTime), CAST(N'2024-01-01 10:15:00.000' AS DateTime), N'Piatek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (41, CAST(N'2024-01-01 10:20:00.000' AS DateTime), CAST(N'2024-01-01 11:05:00.000' AS DateTime), N'Piatek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (42, CAST(N'2024-01-01 11:10:00.000' AS DateTime), CAST(N'2024-01-01 11:55:00.000' AS DateTime), N'Piatek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (43, CAST(N'2024-01-01 12:00:00.000' AS DateTime), CAST(N'2024-01-01 12:45:00.000' AS DateTime), N'Piatek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (44, CAST(N'2024-01-01 12:50:00.000' AS DateTime), CAST(N'2024-01-01 13:35:00.000' AS DateTime), N'Piatek')
INSERT [dbo].[TeachingHours] ([ID Hour], [Start], [End], [Day of week]) VALUES (45, CAST(N'2024-01-01 13:40:00.000' AS DateTime), CAST(N'2024-01-01 14:25:00.000' AS DateTime), N'Piatek')
SET IDENTITY_INSERT [dbo].[TeachingHours] OFF
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (1, 1, 33)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (1, 10, 33)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (1, 28, 33)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (2, 2, 34)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (2, 11, 34)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (2, 29, 34)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (3, 3, 35)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (3, 12, 37)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (3, 30, 35)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (4, 1, 37)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (4, 13, 38)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (4, 31, 37)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (5, 2, 38)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (5, 14, 42)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (5, 32, 38)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (6, 3, 39)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (6, 15, 43)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (6, 33, 39)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (7, 4, 40)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (7, 16, 47)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (7, 34, 40)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (8, 1, 42)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (8, 17, 48)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (8, 29, 42)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (9, 2, 43)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (9, 18, 52)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (9, 30, 43)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (10, 3, 44)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (10, 19, 53)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (10, 31, 44)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (11, 4, 45)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (11, 20, 56)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (11, 32, 45)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (12, 5, 46)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (12, 21, 57)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (12, 33, 46)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (13, 22, 61)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (14, 1, 47)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (14, 23, 62)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (14, 34, 47)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (15, 2, 48)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (15, 24, 66)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (15, 35, 48)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (16, 3, 49)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (16, 25, 67)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (16, 36, 49)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (17, 1, 52)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (17, 19, 35)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (17, 31, 52)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (17, 37, 33)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (18, 2, 53)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (18, 20, 36)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (18, 32, 53)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (18, 38, 33)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (19, 3, 54)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (19, 21, 39)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (19, 33, 54)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (19, 39, 41)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (20, 4, 55)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (20, 22, 40)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (20, 34, 55)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (20, 40, 41)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (21, 1, 56)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (21, 23, 46)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (21, 31, 56)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (21, 41, 46)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (22, 2, 57)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (22, 24, 45)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (22, 32, 57)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (22, 42, 46)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (23, 3, 58)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (23, 25, 49)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (23, 33, 58)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (23, 43, 51)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (24, 4, 59)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (24, 26, 50)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (24, 34, 59)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (24, 44, 51)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (25, 5, 60)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (25, 27, 54)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (25, 35, 60)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (25, 44, 55)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (26, 28, 55)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (26, 45, 55)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (27, 1, 61)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (27, 28, 61)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (27, 29, 58)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (27, 37, 60)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (28, 2, 62)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (28, 29, 62)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (28, 30, 59)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (28, 38, 60)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (29, 3, 63)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (29, 30, 63)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (29, 31, 63)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (29, 39, 65)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (30, 1, 66)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (30, 31, 66)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (30, 32, 64)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (30, 40, 65)
GO
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (31, 2, 67)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (31, 32, 67)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (31, 33, 68)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (31, 41, 70)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (32, 3, 68)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (32, 33, 68)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (32, 34, 69)
INSERT [dbo].[TimeTable] ([ID Classroom], [ID Hour], [ID ClassSubject]) VALUES (32, 42, 70)
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__Klasa__E33F95469135C6DD]    Script Date: 15.02.2025 18:43:20 ******/
ALTER TABLE [dbo].[Class] ADD UNIQUE NONCLUSTERED 
(
	[Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__Classroom__3EBF7F8091B8BA92]    Script Date: 15.02.2025 18:43:20 ******/
ALTER TABLE [dbo].[Classrooms] ADD  CONSTRAINT [UQ__Classroom__3EBF7F8091B8BA92] UNIQUE NONCLUSTERED 
(
	[Classroom number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Idx_StudentName]    Script Date: 15.02.2025 18:43:20 ******/
CREATE NONCLUSTERED INDEX [Idx_StudentName] ON [dbo].[Students]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Idx_StudentSurname]    Script Date: 15.02.2025 18:43:20 ******/
CREATE NONCLUSTERED INDEX [Idx_StudentSurname] ON [dbo].[Students]
(
	[Surname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO

/****** Object:  Index [UQ__Sub__26B4D79654F3A449]    Script Date: 15.02.2025 18:43:20 ******/
ALTER TABLE [dbo].[Subjects] ADD  CONSTRAINT [UQ__Sub__26B4D79654F3A449] UNIQUE NONCLUSTERED 
(
	[Subject Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Attendence] ADD  DEFAULT ('FALSE') FOR [Present]
GO
ALTER TABLE [dbo].[Marks] ADD  CONSTRAINT [df_Weight]  DEFAULT ((1)) FOR [Weight]
GO
ALTER TABLE [dbo].[Attendence]  WITH CHECK ADD FOREIGN KEY([ID ClassSubject])
REFERENCES [dbo].[ClassSubjects] ([ID])
GO
ALTER TABLE [dbo].[Attendence]  WITH CHECK ADD FOREIGN KEY([ID Hour])
REFERENCES [dbo].[TeachingHours] ([ID Hour])
GO
ALTER TABLE [dbo].[Attendence]  WITH CHECK ADD  CONSTRAINT [FK__Student] FOREIGN KEY([ID Student])
REFERENCES [dbo].[Students] ([ID Student])
GO
ALTER TABLE [dbo].[Attendence] CHECK CONSTRAINT [FK__Student]
GO
ALTER TABLE [dbo].[Book Check out]  WITH CHECK ADD  CONSTRAINT [FK_Book ID Book] FOREIGN KEY([ID Book])
REFERENCES [dbo].[Library] ([Id Book])
GO
ALTER TABLE [dbo].[Book Check out] CHECK CONSTRAINT [FK_Book ID Book]
GO
ALTER TABLE [dbo].[Book Check out]  WITH CHECK ADD  CONSTRAINT [FK_Book ID Student] FOREIGN KEY([ID Student])
REFERENCES [dbo].[Students] ([ID Student])
GO
ALTER TABLE [dbo].[Book Check out] CHECK CONSTRAINT [FK_Book ID Student]
GO
ALTER TABLE [dbo].[Class]  WITH CHECK ADD  CONSTRAINT [FK__Class__ID tutor__182C9B23] FOREIGN KEY([ID Tutor])
REFERENCES [dbo].[Teachers] ([ID Teacher])
GO
ALTER TABLE [dbo].[Class] CHECK CONSTRAINT [FK__Class__ID tutor__182C9B23]
GO
ALTER TABLE [dbo].[ClassSubjects]  WITH CHECK ADD  CONSTRAINT [FK__Subject__ID Kl__239E4DCF] FOREIGN KEY([ID Class])
REFERENCES [dbo].[Class] ([ID Class])
GO
ALTER TABLE [dbo].[ClassSubjects] CHECK CONSTRAINT [FK__Subject__ID Kl__239E4DCF]
GO
ALTER TABLE [dbo].[ClassSubjects]  WITH CHECK ADD  CONSTRAINT [FK__Subject__ID Na__24927208] FOREIGN KEY([ID Teacher])
REFERENCES [dbo].[Teachers] ([ID Teacher])
GO
ALTER TABLE [dbo].[ClassSubjects] CHECK CONSTRAINT [FK__Subject__ID Na__24927208]
GO
ALTER TABLE [dbo].[ClassSubjects]  WITH CHECK ADD  CONSTRAINT [FK__Subject__ID Pr__25869641] FOREIGN KEY([ID Subject])
REFERENCES [dbo].[Subjects] ([ID Subject])
GO
ALTER TABLE [dbo].[ClassSubjects] CHECK CONSTRAINT [FK__Subject__ID Pr__25869641]
GO
ALTER TABLE [dbo].[DisciplineReferrals]  WITH CHECK ADD  CONSTRAINT [FK__DR__ID Teacher__3F466844] FOREIGN KEY([ID DR])
REFERENCES [dbo].[DisciplineReferralsDesc] ([ID DR])
GO
ALTER TABLE [dbo].[DisciplineReferrals] CHECK CONSTRAINT [FK__DR__ID Teacher__3F466844]
GO
ALTER TABLE [dbo].[DisciplineReferrals]  WITH CHECK ADD  CONSTRAINT [FK__DR__ID Teacher__403A8C7D] FOREIGN KEY([ID Student])
REFERENCES [dbo].[Students] ([ID Student])
GO
ALTER TABLE [dbo].[DisciplineReferrals] CHECK CONSTRAINT [FK__DR__ID Teacher__403A8C7D]
GO
ALTER TABLE [dbo].[DisciplineReferrals]  WITH CHECK ADD  CONSTRAINT [FK__DR__ID Teacher__412EB0B6] FOREIGN KEY([ID Teacher])
REFERENCES [dbo].[Teachers] ([ID Teacher])
GO
ALTER TABLE [dbo].[DisciplineReferrals] CHECK CONSTRAINT [FK__DR__ID Teacher__412EB0B6]
GO
ALTER TABLE [dbo].[Marks]  WITH CHECK ADD  CONSTRAINT [FK__Mark__ID Student__4316F928] FOREIGN KEY([ID Student])
REFERENCES [dbo].[Students] ([ID Student])
GO
ALTER TABLE [dbo].[Marks] CHECK CONSTRAINT [FK__Mark__ID Student__4316F928]
GO
ALTER TABLE [dbo].[Marks]  WITH CHECK ADD  CONSTRAINT [FK_Mark] FOREIGN KEY([ID Teacher], [ID Subject])
REFERENCES [dbo].[TeacherSubjects] ([ID Teacher], [ID Subject])
GO
ALTER TABLE [dbo].[Marks] CHECK CONSTRAINT [FK_Mark]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [FK__Student__ID Class__20C1E124] FOREIGN KEY([ID Class])
REFERENCES [dbo].[Class] ([ID Class])
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [FK__Student__ID Class__20C1E124]
GO
ALTER TABLE [dbo].[TeacherSubjects]  WITH CHECK ADD  CONSTRAINT [FK__Subject__ID Na__1CF15040] FOREIGN KEY([ID Teacher])
REFERENCES [dbo].[Teachers] ([ID Teacher])
GO
ALTER TABLE [dbo].[TeacherSubjects] CHECK CONSTRAINT [FK__Subject__ID Na__1CF15040]
GO
ALTER TABLE [dbo].[TeacherSubjects]  WITH CHECK ADD  CONSTRAINT [FK__Subject__ID Pr__1DE57479] FOREIGN KEY([ID Subject])
REFERENCES [dbo].[Subjects] ([ID Subject])
GO
ALTER TABLE [dbo].[TeacherSubjects] CHECK CONSTRAINT [FK__Subject__ID Pr__1DE57479]
GO
ALTER TABLE [dbo].[TimeTable]  WITH CHECK ADD  CONSTRAINT [FK__TimeTable__ID Go__398D8EEE] FOREIGN KEY([ID Hour])
REFERENCES [dbo].[TeachingHours] ([ID Hour])
GO
ALTER TABLE [dbo].[TimeTable] CHECK CONSTRAINT [FK__TimeTable__ID Go__398D8EEE]
GO
ALTER TABLE [dbo].[TimeTable]  WITH CHECK ADD  CONSTRAINT [FK__TimeTable__ID Pr__3A81B327] FOREIGN KEY([ID ClassSubject])
REFERENCES [dbo].[ClassSubjects] ([ID])
GO
ALTER TABLE [dbo].[TimeTable] CHECK CONSTRAINT [FK__TimeTable__ID Pr__3A81B327]
GO
ALTER TABLE [dbo].[TimeTable]  WITH CHECK ADD  CONSTRAINT [FK__TimeTable__ID Sa__38996AB5] FOREIGN KEY([ID Classroom])
REFERENCES [dbo].[Classrooms] ([ID Class])
GO
ALTER TABLE [dbo].[TimeTable] CHECK CONSTRAINT [FK__TimeTable__ID Sa__38996AB5]
GO
ALTER TABLE [dbo].[Marks]  WITH CHECK ADD  CONSTRAINT [MarkCheck] CHECK  (([Mark]>=(1) AND [Mark]<=(6)))
GO
ALTER TABLE [dbo].[Marks] CHECK CONSTRAINT [MarkCheck]
GO
/****** Object:  Trigger [dbo].[Add book to library]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[Add book to library] 
   ON  [dbo].[Book Check out]
   AFTER DELETE
AS 
BEGIN

DECLARE @Idbook int;
DECLARE @cnt int;

DECLARE book_cursor CURSOR FOR
SELECT [ID Book], Count(*)
FROM deleted
Group By [ID Book]

OPEN book_cursor

FETCH NEXT FROM book_cursor
INTO @Idbook, @cnt

WHILE @@FETCH_STATUS = 0
BEGIN

	UPDATE Library
	Set [Available Copies] = [Available Copies] + @cnt
	Where [Id Book] = @Idbook

    FETCH NEXT FROM book_cursor
	INTO @Idbook, @cnt

END
CLOSE book_cursor;
DEALLOCATE book_cursor;
END

GO
/****** Object:  Trigger [dbo].[Library out of books]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[Library out of books] 
   ON  [dbo].[Book Check out]
   AFTER INSERT
AS 

IF EXISTS (SELECT *  
           FROM Library   
           WHERE [Available Copies] < 0  
          )  
BEGIN
RAISERROR ('Cannot lend books that are already lent.', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  

GO
/****** Object:  Trigger [dbo].[Take out book from library]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[Take out book from library] 
   ON  [dbo].[Book Check out]
   AFTER INSERT
AS 
BEGIN

DECLARE @Idbook int;
DECLARE @cnt int;

DECLARE book_cursor CURSOR FOR
SELECT [ID Book], Count(*)
FROM inserted
Group By [ID Book]

OPEN book_cursor

FETCH NEXT FROM book_cursor
INTO @Idbook, @cnt

WHILE @@FETCH_STATUS = 0
BEGIN

	UPDATE Library
	Set [Available Copies] = [Available Copies] - @cnt
	Where [Id Book] = @Idbook

    FETCH NEXT FROM book_cursor
	INTO @Idbook, @cnt

END
CLOSE book_cursor;
DEALLOCATE book_cursor;
END

GO
/****** Object:  Trigger [dbo].[Warning]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[Warning]
ON [dbo].[DisciplineReferrals]
AFTER INSERT, UPDATE   
AS 
BEGIN 
	IF EXISTS (
        SELECT 1 
        FROM inserted 
    )
	BEGIN 
	SELECT C.[Number],S.[Name],S.[Surname],SUM(DRD.Weight) AS [Liczba Punktow] FROM Students S 
	INNER JOIN DisciplineReferrals DR ON S.[ID Student] = DR.[ID Student] 
	INNER JOIN Class C ON C.[ID Class] = S.[ID Class]
	INNER JOIN DisciplineReferralsDesc DRD ON DRD.[ID DR] = DR.[ID DR]
	WHERE S.[ID Student] IN (Select [ID Student] From inserted)
	GROUP BY C.[Number],S.[ID Student],S.[Surname],S.[Name]
	HAVING (SUM(DRD.Weight)) > 6
	END
END


GO
/****** Object:  Trigger [dbo].[CheckMark]    Script Date: 15.02.2025 18:43:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[CheckMark]
ON [dbo].[Marks]
INSTEAD OF INSERT
AS
BEGIN
    -- Sprawdzenie poprawności danych
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE Mark < 1 OR Mark > 6
    )
    BEGIN
        -- Jeśli warunek jest niespełniony, rzucamy błąd
        RAISERROR ('Mark has to be from 1 to 6.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Wstawianie poprawnych danych
    INSERT INTO Marks
    SELECT *
    FROM inserted;
END;

GO
USE [master]
GO
ALTER DATABASE [School] SET  READ_WRITE 
GO
