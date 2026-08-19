-- ----------------------------------------------------------------------------
-- 1. DATABASE CREATION AND CLEANUP
-- ----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RaceDayDB')
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

-- Drop existing tables in reverse dependency order for clean re-runs
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.EventOrganisers', 'U') IS NOT NULL DROP TABLE dbo.EventOrganisers;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

-- ----------------------------------------------------------------------------
-- 2. TABLE CREATION WITH CONSTRAINTS
-- ----------------------------------------------------------------------------

-- Entity 1: Users Table
CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) NOT NULL,
    Email NVARCHAR(150) NOT NULL,
    PasswordHash NVARCHAR(256) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    Role NVARCHAR(20) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CHK_Users_Role CHECK (Role IN ('Organiser', 'Participant'))
);

-- Entity 2: EventOrganisers Table
CREATE TABLE dbo.EventOrganisers (
    OrganiserID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    OrganizationName NVARCHAR(150) NOT NULL,
    ContactEmail NVARCHAR(150) NOT NULL,
    WebsiteURL NVARCHAR(255) NULL,

    CONSTRAINT PK_EventOrganisers PRIMARY KEY (OrganiserID),
    CONSTRAINT UQ_EventOrganisers_UserID UNIQUE (UserID),
    CONSTRAINT FK_EventOrganisers_Users FOREIGN KEY (UserID) 
        REFERENCES dbo.Users(UserID) ON DELETE CASCADE
);

-- Entity 3: Events Table
CREATE TABLE dbo.Events (
    EventID INT IDENTITY(1,1) NOT NULL,
    OrganiserID INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    EventType NVARCHAR(50) NOT NULL, -- e.g. Road Running, Cycling, Walking
    Location NVARCHAR(200) NOT NULL,
    EventDate DATETIME2 NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Events PRIMARY KEY (EventID),
    CONSTRAINT FK_Events_Organisers FOREIGN KEY (OrganiserID) 
        REFERENCES dbo.EventOrganisers(OrganiserID),
    CONSTRAINT CHK_Events_Type CHECK (EventType IN ('Road Running', 'Cycling', 'Walking', 'Multi-Sport'))
);

-- Entity 4: Categories Table
CREATE TABLE dbo.Categories (
    CategoryID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL, -- e.g. 21km Half Marathon, 105km Cycle
    DistanceKM DECIMAL(5,2) NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    MaxCapacity INT NOT NULL,

    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) 
        REFERENCES dbo.Events(EventID) ON DELETE CASCADE,
    CONSTRAINT CHK_Categories_Capacity CHECK (MaxCapacity > 0),
    CONSTRAINT CHK_Categories_Fee CHECK (EntryFee >= 0.00)
);

-- Entity 5: Enrolments Table
CREATE TABLE dbo.Enrolments (
    EnrolmentID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL, -- Participant User ID
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(30) NOT NULL DEFAULT 'Confirmed',

    CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentID),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (UserID) 
        REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryID) 
        REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT UQ_User_Category_Enrolment UNIQUE (UserID, CategoryID),
    CONSTRAINT CHK_Enrolments_Status CHECK (Status IN ('Confirmed', 'Cancelled', 'Pending'))
);

-- Entity 6: Results Table
CREATE TABLE dbo.Results (
    ResultID INT IDENTITY(1,1) NOT NULL,
    EnrolmentID INT NOT NULL,
    FinishTimeFormatted NVARCHAR(20) NOT NULL, -- Format: HH:MM:SS
    FinishTimeSeconds INT NOT NULL,
    OverallPosition INT NULL,
    CategoryPosition INT NULL,
    RecordedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Results PRIMARY KEY (ResultID),
    CONSTRAINT UQ_Results_EnrolmentID UNIQUE (EnrolmentID),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID) 
        REFERENCES dbo.Enrolments(EnrolmentID) ON DELETE CASCADE,
    CONSTRAINT CHK_Results_FinishTime CHECK (FinishTimeSeconds > 0)
);
GO

-- ----------------------------------------------------------------------------
-- 3. SEED DATA INSERTION
-- ----------------------------------------------------------------------------

-- A. Insert Users (2 Organisers, 2 Participants)
INSERT INTO dbo.Users (Email, PasswordHash, FirstName, LastName, PhoneNumber, Role)
VALUES 
('organizer.gauteng@raceday.co.za', 'AQAAAAEAACcQAAAAEH8z...Hash1', 'Sipho', 'Ndlovu', '0821234567', 'Organiser'),
('info@capeevents.co.za', 'AQAAAAEAACcQAAAAEH8z...Hash2', 'Anika', 'Van Der Merwe', '0839876543', 'Organiser'),
('thabo.mokoena@gmail.com', 'AQAAAAEAACcQAAAAEH8z...Hash3', 'Thabo', 'Mokoena', '0711112222', 'Participant'),
('sarah.jenkins@yahoo.com', 'AQAAAAEAACcQAAAAEH8z...Hash4', 'Sarah', 'Jenkins', '0723334444', 'Participant');

-- B. Insert Event Organisers
INSERT INTO dbo.EventOrganisers (UserID, OrganizationName, ContactEmail, WebsiteURL)
VALUES 
(1, 'Gauteng Athletic Events', 'contact@gautengathletics.co.za', 'https://www.gautengathletics.co.za'),
(2, 'Cape Endurance Sports', 'support@capeendurance.co.za', 'https://www.capeendurance.co.za');

-- C. Insert Events (3 Events)
INSERT INTO dbo.Events (OrganiserID, Title, Description, EventType, Location, EventDate)
VALUES 
(1, 'Pretoria Capital Classic Run', 'Annual scenic city road run taking participants through historic landmarks.', 'Road Running', 'Pretoria, Gauteng', '2026-10-15 06:00:00'),
(2, 'Cape Peninsula Cycle Challenge', 'Premier coastal cycling event with breath-taking ocean views.', 'Cycling', 'Cape Town, Western Cape', '2026-11-20 07:00:00'),
(1, 'Soweto Community Charity Walk', 'A vibrant community walking event focused on raising health awareness and charity funds.', 'Walking', 'Soweto, Gauteng', '2026-12-05 08:00:00');

-- D. Insert Categories (Categories per Event)
INSERT INTO dbo.Categories (EventID, CategoryName, DistanceKM, EntryFee, MaxCapacity)
VALUES 
-- Categories for Event 1 (Pretoria Capital Classic)
(1, '21.1km Half Marathon', 21.10, 250.00, 1500),
(1, '10km City Dash', 10.00, 150.00, 2000),
-- Categories for Event 2 (Cape Peninsula Cycle)
(2, '105km Coastal Challenge', 105.00, 550.00, 3000),
(2, '45km Short Route', 45.00, 350.00, 1500),
-- Categories for Event 3 (Soweto Charity Walk)
(3, '5km Fun Walk', 5.00, 50.00, 5000);

-- E. Insert Enrolments (Sample Registrations)
INSERT INTO dbo.Enrolments (UserID, CategoryID, Status)
VALUES 
(3, 1, 'Confirmed'), -- Thabo enrolled in 21.1km Half Marathon
(4, 2, 'Confirmed'), -- Sarah enrolled in 10km City Dash
(3, 3, 'Confirmed'); -- Thabo enrolled in 105km Coastal Challenge

-- F. Insert Results
INSERT INTO dbo.Results (EnrolmentID, FinishTimeFormatted, FinishTimeSeconds, OverallPosition, CategoryPosition)
VALUES 
(1, '01:42:15', 6135, 14, 5),  -- Thabo's Result for 21.1km
(2, '00:54:30', 3270, 42, 12); -- Sarah's Result for 10km

GO

-- ----------------------------------------------------------------------------
-- 4. VERIFICATION QUERIES (Optional Check)
-- ----------------------------------------------------------------------------
SELECT 'Users' AS TableName, COUNT(*) AS TotalRecords FROM dbo.Users
UNION ALL
SELECT 'EventOrganisers', COUNT(*) FROM dbo.EventOrganisers
UNION ALL
SELECT 'Events', COUNT(*) FROM dbo.Events
UNION ALL
SELECT 'Categories', COUNT(*) FROM dbo.Categories
UNION ALL
SELECT 'Enrolments', COUNT(*) FROM dbo.Enrolments
UNION ALL
SELECT 'Results', COUNT(*) FROM dbo.Results;
GO