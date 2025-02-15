------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: UserRoles  
-- This table stores different user roles in the system Like 'Client', 'Broker', 'ShopOwner', 'Driver', 'Admin'  
-- Each role is unique and can be activated or deactivated.

CREATE TABLE UserRoles (
    UserRoleID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each role
    Role NVARCHAR(50) UNIQUE NOT NULL CHECK (Role IN ('Client', 'Broker', 'ShopOwner', 'Driver', 'Admin')), -- Role name, must be unique
    isActive BIT DEFAULT 1, -- Indicates whether the role is active (1 = Active, 0 = Inactive)
    CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for when the language record was created
    CreatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID of the creator of the language record
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update to the language record
    UpdatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID of the person who last updated the language record
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID), -- Reference to the Users table for the creator
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID) -- Reference to the Users table for the last updater
);
INSERT INTO UserRoles (UserRoleID, Role, isActive)
VALUES 
    (NEWID(), 'Client', 1),
    (NEWID(), 'Broker', 1),
    (NEWID(), 'ShopOwner', 1),
    (NEWID(), 'Driver', 1),
    (NEWID(), 'Admin', 1);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- This table stores allowed file types for uploads, ensuring security and size restrictions.
-- It categorizes files (e.g., Images, Documents, Videos) and enforces size limits.
-- The 'isActive' flag helps in disabling unwanted file types dynamically.

CREATE TABLE FileTypes (
    FileTypeID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),  -- Unique ID for the file type
    FileExtension NVARCHAR(10) NOT NULL UNIQUE,  -- File extension (e.g., .jpg, .png, .pdf)
    MIMEType NVARCHAR(100) NOT NULL UNIQUE,  -- MIME type (e.g., image/jpeg, application/pdf)
    MaxSizeMB INT NOT NULL,  -- Maximum file size allowed (in MB)
    Category NVARCHAR(50) NOT NULL,  -- Category (e.g., "Image", "Document", "Video", "Audio")
    isActive BIT DEFAULT 1  -- Indicates if the file type is allowed (1 = Allowed, 0 = Blocked)
);
INSERT INTO FileTypes (FileTypeID, FileExtension, MIMEType, MaxSizeMB, Category, Description, isActive, CreatedAt, UpdatedAt)  
VALUES  
    (NEWID(), '.jpg', 'image/jpeg', 5, 'Image', 'High-quality user profile photos', 1, GETDATE(), GETDATE()),  
    (NEWID(), '.png', 'image/png', 5, 'Image', 'Supports transparency', 1, GETDATE(), GETDATE()),  
    (NEWID(), '.pdf', 'application/pdf', 10, 'Document', 'Official documents & invoices', 1, GETDATE(), GETDATE()),  
    (NEWID(), '.mp4', 'video/mp4', 50, 'Video', 'Marketing & promotional videos', 1, GETDATE(), GETDATE()),  
    (NEWID(), '.exe', 'application/x-msdownload', 0, 'Executable', 'Blocked due to security risks', 0, GETDATE(), GETDATE());
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Users  
-- This table stores user information, including login credentials and account status.  
-- Each user has a unique email and can be active or inactive.  

CREATE TABLE Users (
    UserID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each user
    UserName NVARCHAR(100) NOT NULL, -- User's display name
    Email NVARCHAR(255) NOT NULL UNIQUE, -- Unique email for authentication
    PasswordHash NVARCHAR(500) NOT NULL, -- Hashed password for security
    Phone NVARCHAR(20) NOT NULL UNIQUE, -- User's phone number for contact and verification
    UserRoleID UNIQUEIDENTIFIER NOT NULL, -- Foreign key referencing UserRoles table
	LicenseNumber NVARCHAR(50) UNIQUE NULL, -- Driver's license number (NULL for non-drivers)
    ProfilePhoto NVARCHAR(500) NULL, -- URL or file path of the user's profile photo
    LastUse DATETIME NULL, -- Timestamp of the last time the user accessed the system
    LastOrder DATETIME NULL, -- Timestamp of the user's last order activity
    isActive BIT DEFAULT 1, -- Indicates whether the user account is active (1 = Active, 0 = Inactive)
    FOREIGN KEY (UserRoleID) REFERENCES UserRoles(UserRoleID) ON DELETE CASCADE
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: UserSessions  
-- Purpose: Stores authentication sessions for users, allowing multiple active logins.  
-- Each session is linked to a user and contains an auth token with an expiration time.  
-- The token is used for authentication and session management.  

CREATE TABLE UserSessions (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),  -- Generates a random UUID  
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE,  
    auth_token NVARCHAR(255) NOT NULL,  -- Store a hashed token for security  
    expires_at DATETIME NOT NULL,  -- Expiration time for the session  
    created_at DATETIME DEFAULT GETDATE(),  -- Gets the current timestamp  
    updated_at DATETIME DEFAULT GETDATE()  -- Gets the current timestamp  
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Verifications 
-- Stores user verification records
CREATE TABLE Verifications (
    VerificationID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL, -- The user being verified
    VerificationCode NVARCHAR(255) NOT NULL, -- Code sent for verification (if applicable)
    VerificationStatus NVARCHAR(50) CHECK (VerificationStatus IN ('Pending', 'Verified', 'Failed', 'Expired')) NOT NULL DEFAULT 'Pending',
    ExpiryDate DATETIME NULL, -- Expiration time for verification codes
    CreatedDate DATETIME DEFAULT GETDATE(),
    VerifiedDate DATETIME NULL, -- The date the verification was completed
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Languages
-- This table stores information about languages, including the language code, full name, and whether the language is active.
-- It is no longer directly linked to a single country. The relationship between languages and countries is managed by the LanguageCountry table.

CREATE TABLE Languages (
    LanguageID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),  -- Unique identifier for each language
    LanguageCode NVARCHAR(10) NOT NULL, -- A short code for the language (e.g., 'en', 'fr', 'ar')
    LanguageName NVARCHAR(100) NOT NULL, -- Full name of the language (e.g., English, French, Arabic)
    IsActive BIT NOT NULL DEFAULT 1, -- Whether the language is active (1 = active, 0 = inactive)
    CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for when the language record was created
    CreatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID of the creator of the language record
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update to the language record
    UpdatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID of the person who last updated the language record
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID), -- Reference to the Users table for the creator
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID) -- Reference to the Users table for the last updater
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: VehicleTypesMaster
-- Purpose: Stores vehicle types but without direct TypeName values.
CREATE TABLE VehicleTypesMaster (
    VehicleTypeID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	ColumnTitle NVARCHAR(100) NOT NULL, -- for clarification only
    CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for record creation
    CreatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who created the record
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update
    UpdatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who last updated the record
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: VehicleTypeTranslations
-- Purpose: Stores localized names for vehicle types in different languages.
CREATE TABLE VehicleTypeTranslations (
    TranslationID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    VehicleTypeID UNIQUEIDENTIFIER NOT NULL REFERENCES VehicleTypesMaster(VehicleTypeID) ON DELETE CASCADE,
    LanguageID UNIQUEIDENTIFIER NOT NULL REFERENCES Languages(LanguageID) ON DELETE CASCADE,
    TypeName NVARCHAR(100) NOT NULL, -- The translated name
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    UNIQUE (VehicleTypeID, LanguageID) -- Ensures no duplicate translations for the same type
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: VehicleBrandsMaster
-- Purpose: Stores only brand IDs without names. Names are stored in the translation table for multi-language support.
CREATE TABLE VehicleBrandsMaster (
    BrandID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), 
	ColumnTitle NVARCHAR(100) NOT NULL, -- for clarification only
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL, 
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: VehicleBrandTranslations
-- Purpose: Links each brand to a language and stores the translated brand name.
CREATE TABLE VehicleBrandTranslations (
    TranslationID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    BrandID UNIQUEIDENTIFIER NOT NULL,
    LanguageID UNIQUEIDENTIFIER NOT NULL,
    BrandName NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (BrandID) REFERENCES VehicleBrandsMaster(BrandID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: VehicleModelsMaster
-- Purpose: Stores unique model IDs without language-specific names.

CREATE TABLE VehicleModelsMaster (
    ModelID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique Model ID
    BrandID UNIQUEIDENTIFIER NOT NULL REFERENCES VehicleBrandsMaster(BrandID) ON DELETE CASCADE,
    ColumnTitle NVARCHAR(100) NOT NULL, -- Conceptual category title for clarification
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------
-- Table: VehicleModelTranslations
-- Purpose: Stores model names in different languages.

CREATE TABLE VehicleModelTranslations (
    ModelID UNIQUEIDENTIFIER NOT NULL, -- Links to VehicleModelsMaster
    LanguageID UNIQUEIDENTIFIER NOT NULL, -- Links to Languages
    ModelName NVARCHAR(100) NOT NULL, -- Translated model name
    PRIMARY KEY (ModelID, LanguageID), -- Composite key ensures unique translations
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (ModelID) REFERENCES VehicleModelsMaster(ModelID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Vehicles
-- Purpose: Stores vehicle details and links vehicles to drivers.

CREATE TABLE Vehicles (
    VehicleID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE, -- only for Driver role
    PlateNumber NVARCHAR(20) UNIQUE NOT NULL,
    VehicleTypeID UNIQUEIDENTIFIER NOT NULL REFERENCES VehicleTypesMaster(VehicleTypeID) ON DELETE CASCADE,
    ModelID UNIQUEIDENTIFIER NOT NULL REFERENCES VehicleModelsMaster(ModelID) ON DELETE CASCADE, -- Only ModelID
    Year INT CHECK (Year >= 1900 AND Year <= YEAR(GETDATE())),
    Color NVARCHAR(50),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Locations  
-- Stores user-defined locations with latitude and longitude.  
-- This table helps in identifying specific places with geolocation data.  

CREATE TABLE Locations (
    LocationID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each location
    LocationName NVARCHAR(255) NOT NULL, -- Name of the location
    Latitude DECIMAL(9,6) NOT NULL, -- GeoDef (Latitude)
    Longitude DECIMAL(9,6) NOT NULL, -- GeoDef (Longitude)
    isDeleted BIT DEFAULT 0, -- Indicates whether the location is deleted (1 = Deleted, 0 = Active)
	CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for record creation
    CreatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who created the record
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID) -- Reference to the Users table
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Countries  
-- Stores all available countries with their name, code, and flag.  
-- Also tracks who created and last updated each record.  

CREATE TABLE Countries (
    CountryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each country
    CountryName NVARCHAR(100) NOT NULL UNIQUE, -- Name of the country
    CountryCode NVARCHAR(10) NOT NULL, -- Example: '+20' for Egypt
    CountryFlagImage NVARCHAR(MAX) NULL, -- URL for country flag
    IsActive BIT DEFAULT 0, -- Indicates if the country is active (1 = Active, 0 = Inactive)
    CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for record creation
    CreatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who created the record
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update
    UpdatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who last updated the record
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID), -- Reference to the Users table
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID) -- Reference to the Users table
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: UserByCountries  
-- Stores the history of users' associated countries.  
-- Tracks when the country was assigned and when it was last updated.  

CREATE TABLE UserByCountries (
    UserCountryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each record
    UserID UNIQUEIDENTIFIER NOT NULL, -- Reference to the user
    CountryID UNIQUEIDENTIFIER NOT NULL, -- Reference to the country
    AssignedAt DATETIME DEFAULT GETDATE(), -- Timestamp when the country was assigned to the user
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update
    IsActive BIT DEFAULT 1, -- Indicates if the record is active (1 = Active, 0 = Inactive)
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE, -- Links to Users table
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID) ON DELETE CASCADE -- Links to Countries table
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Shops  
-- Stores registered shops (used for coupons, not orders).  
-- Contains details about the shop owner, contact information, and registration details.  

CREATE TABLE Shops (
    ShopID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each shop
    OwnerID UNIQUEIDENTIFIER NOT NULL, -- Reference to the shop owner (UserID)
    ShopName NVARCHAR(255) NOT NULL, -- Name of the shop
    CR_Number NVARCHAR(50) NULL, -- Commercial registration number (if applicable)
    TelephoneLandline NVARCHAR(50) NULL, -- Landline contact number
    Mobile NVARCHAR(50) NULL, -- Mobile contact number
    FocalPointName NVARCHAR(100) NULL, -- Name of the main contact person
    FocalPointPhone NVARCHAR(50) NULL, -- Phone number of the main contact person
    isActive BIT DEFAULT 1, -- Indicates if the shop is active (1 = Active, 0 = Inactive)
    FOREIGN KEY (OwnerID) REFERENCES Users(UserID) ON DELETE CASCADE -- Links to Users table
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: ServiceMaster
-- Purpose: Stores unique service IDs without language-specific names.
-- Stores all available services (e.g., furniture moving, towing).

CREATE TABLE ServiceMaster (
    ServiceID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique Service ID
    ColumnTitle NVARCHAR(255) NOT NULL, -- Conceptual category title for clarification
    isActive BIT DEFAULT 1, -- Indicates if the service is active (1 = Active, 0 = Inactive)
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Services
-- Purpose: Stores service names in different languages, linking them to ServiceMaster.

CREATE TABLE Services (
    ServiceID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to ServiceMaster
    LanguageID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to Languages
    ServiceName NVARCHAR(255) NOT NULL, -- Translated service name
    PRIMARY KEY (ServiceID, LanguageID), -- Composite key ensures unique translations
    FOREIGN KEY (ServiceID) REFERENCES ServiceMaster(ServiceID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: ServicePricing
-- Purpose: Stores pricing details for services without linking to language translations.

CREATE TABLE ServicePricing (
    PricingID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ServiceID UNIQUEIDENTIFIER NOT NULL, -- Links to ServiceMaster, NOT Services
    CountryID UNIQUEIDENTIFIER NOT NULL, -- Links to Countries
    BasePrice DECIMAL(10,2) NOT NULL,
    PricePerKm DECIMAL(10,2) NOT NULL,
    isActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (ServiceID) REFERENCES ServiceMaster(ServiceID) ON DELETE CASCADE,
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: AdditionalServiceMaster
-- Purpose: Stores unique additional service IDs without language-specific names.
-- This structure ensures that AdditionalServicePricing is NOT dependent on language translations.

CREATE TABLE AdditionalServiceMaster (
    AdditionalServiceID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique Additional Service ID
    ColumnTitle NVARCHAR(255) NOT NULL, -- Conceptual category title for clarification
    isActive BIT DEFAULT 1, -- Indicates if the additional service is active (1 = Active, 0 = Inactive)
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Table: AdditionalServices
-- Purpose: Stores additional service names in different languages, linking them to AdditionalServiceMaster.

CREATE TABLE AdditionalServices (
    AdditionalServiceID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to AdditionalServiceMaster
    LanguageID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to Languages
    AdditionalServiceName NVARCHAR(255) NOT NULL, -- Translated additional service name
    PRIMARY KEY (AdditionalServiceID, LanguageID), -- Composite key ensures unique translations
    FOREIGN KEY (AdditionalServiceID) REFERENCES AdditionalServiceMaster(AdditionalServiceID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE
);
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Table: AdditionalServicePricing
-- Purpose: Stores additional service pricing for different countries and main services.

CREATE TABLE AdditionalServicePricing (
    AdditionalPricingID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    AdditionalServiceID UNIQUEIDENTIFIER NOT NULL, -- Links to AdditionalServiceMaster
    ServiceID UNIQUEIDENTIFIER NOT NULL, -- Links to ServiceMaster (not the translated table)
    CountryID UNIQUEIDENTIFIER NOT NULL, -- Links to Countries
    ExtraCost DECIMAL(10,2) NOT NULL, -- Extra cost for the additional service
    isActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (AdditionalServiceID) REFERENCES AdditionalServiceMaster(AdditionalServiceID) ON DELETE CASCADE,
    FOREIGN KEY (ServiceID) REFERENCES ServiceMaster(ServiceID) ON DELETE CASCADE,
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Coupons  
-- Stores available coupons for discounts  
-- Each coupon record includes details like the shop, discount value, and validity period.

CREATE TABLE Coupons (
    CouponID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each coupon
    startdate DATE NOT NULL, -- Start date of the coupon validity
    expirydate DATE NOT NULL, -- Expiry date of the coupon validity
    ShopID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to the Shops table, linking the coupon to a specific shop
    CouponCode NVARCHAR(50) NOT NULL UNIQUE, -- Unique coupon code
    QRCode NVARCHAR(MAX) NULL, -- URL or encoded data for the QR code
    DiscountType NVARCHAR(20) CHECK (DiscountType IN ('Percentage', 'Fixed')) NOT NULL, -- Type of discount (Percentage or Fixed)
    DiscountValue DECIMAL(10,2) NOT NULL, -- Discount value (either percentage or fixed amount)
    isActive BIT DEFAULT 1, -- Indicates if the coupon is active (1 = Active, 0 = Inactive)
    CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for record creation
    CreatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who created the record
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update
    UpdatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who last updated the record
    FOREIGN KEY (ShopID) REFERENCES Shops(ShopID) ON DELETE CASCADE, -- Foreign key to Shops table
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID), -- Reference to the Users table for the creator
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID) -- Reference to the Users table for the last updater
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Platforms  
-- Stores different platforms where coupons are redeemed  
-- Each platform record contains details about the platform name and the associated creator and updater.

CREATE TABLE Platforms (
    PlatformID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each platform
    PlatformName NVARCHAR(100) NOT NULL UNIQUE, -- Name of the platform (e.g., mobile app, website)
    isActive BIT DEFAULT 1, -- Indicates if the platform is active (1 = Active, 0 = Inactive)
    CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for record creation
    CreatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who created the record
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update
    UpdatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who last updated the record
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID), -- Reference to the Users table for the creator
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID) -- Reference to the Users table for the last updater
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: CouponRedemptionLogs  
-- Stores coupon redemption logs to track the redemption of coupons by users  
-- Each log entry records the coupon redemption details, including the user, platform, and QR code used for verification.

CREATE TABLE CouponRedemptionLogs (
    RedemptionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each redemption log
    CouponID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to the Coupons table, indicating which coupon was redeemed
    UserID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to the Users table, indicating which user redeemed the coupon
    RedemptionDate DATETIME DEFAULT GETDATE(), -- Timestamp when the coupon was redeemed
    QRCodeScanned NVARCHAR(MAX) NULL, -- Stores scanned QR data or verification code
    PlatformID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to the Platforms table, indicating where the coupon was redeemed
    IsRedeemed BIT DEFAULT 1, -- Indicates whether the coupon was redeemed (1 = Redeemed, 0 = Not redeemed)
    FOREIGN KEY (CouponID) REFERENCES Coupons(CouponID), -- Reference to the Coupons table
    FOREIGN KEY (UserID) REFERENCES Users(UserID), -- Reference to the Users table
    FOREIGN KEY (PlatformID) REFERENCES Platforms(PlatformID) ON DELETE CASCADE, -- Reference to the Platforms table
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: OrderStatusMaster
-- Purpose: Stores unique order status IDs without language-specific names.
-- This table stores the possible values for order statuses (e.g., Pending, Processing, Completed, Cancelled).
-- It provides a centralized way to manage order statuses and ensure data consistency.
-- The 'IsActive' column is used to track if a status is currently active (can be used in orders).

CREATE TABLE OrderStatusMaster (
    OrderStatusID INT PRIMARY KEY IDENTITY(1,1), -- Unique Order Status ID
    ColumnTitle NVARCHAR(100) NOT NULL, -- Conceptual category title for clarification
    IsActive BIT NOT NULL DEFAULT 1, -- Flag to indicate whether the status is active
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: OrderStatusTranslations
-- Purpose: Stores order status names in different languages.

CREATE TABLE OrderStatusTranslations (
    OrderStatusID INT NOT NULL, -- Links to OrderStatusMaster
    LanguageID UNIQUEIDENTIFIER NOT NULL, -- Links to Languages table
    StatusName NVARCHAR(50) NOT NULL, -- Translated order status name
    PRIMARY KEY (OrderStatusID, LanguageID), -- Composite key ensures unique translations
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (OrderStatusID) REFERENCES OrderStatusMaster(OrderStatusID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Table: Orders  
-- This table stores customer orders and their pricing breakdowns. It includes order details such as the client, 
-- assigned driver, locations, pricing, discounts, and the final calculated price.
-- Foreign key relationships are established to Users, Services, Locations, and Coupons tables for data integrity.

CREATE TABLE Orders (
    OrderID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique order identifier, automatically generated
    UserID UNIQUEIDENTIFIER NOT NULL, -- The client placing the order, references Users table
    ServiceID UNIQUEIDENTIFIER NOT NULL, -- The selected main service, references Services table
    AssignedDriverID UNIQUEIDENTIFIER NULL, -- The driver assigned to the order (if any), references Users table
    PickupLocationID UNIQUEIDENTIFIER NOT NULL, -- Pickup location, references Locations table
    DropoffLocationID UNIQUEIDENTIFIER NOT NULL, -- Drop-off location, references Locations table
    DistanceInKm DECIMAL(10,2) NOT NULL, -- Distance for the service in kilometers (calculated)
    BasePrice DECIMAL(10,2) NOT NULL, -- The base price of the service before any additional costs
    PricePerKm DECIMAL(10,2) NOT NULL, -- Price per kilometer for the service
    DistanceCost DECIMAL(10,2) NOT NULL, -- Total cost calculated from DistanceInKm and PricePerKm
    TotalServiceCost DECIMAL(10,2) NOT NULL, -- Sum of BasePrice and DistanceCost
    CouponID UNIQUEIDENTIFIER NULL, -- Applied coupon (if any), references Coupons table
    DiscountApplied DECIMAL(10,2) DEFAULT 0.00, -- Discount value applied to the order, defaults to 0
    AdditionalServicesCost DECIMAL(10,2) DEFAULT 0.00, -- Extra charges for additional services like maintenance
    FinalPrice DECIMAL(10,2) NOT NULL, -- Final calculated price after applying all costs, discounts, and coupons
    OrderStatusID INT NOT NULL, -- Foreign key to reference OrderStatuses table (stores the current order status)
    OrderDate DATETIME DEFAULT GETDATE(), -- Date and time when the order was placed, defaults to current date/time
    -- Foreign key relationships
    FOREIGN KEY (UserID) REFERENCES Users(UserID), -- Reference to Users table (client)
    FOREIGN KEY (ServiceID) REFERENCES ServiceMaster(ServiceID), -- Reference to ServiceMaster table (main service)
    FOREIGN KEY (AssignedDriverID) REFERENCES Users(UserID), -- Reference to Users table (driver), if any
    FOREIGN KEY (PickupLocationID) REFERENCES Locations(LocationID), -- Reference to Locations table (pickup)
    FOREIGN KEY (DropoffLocationID) REFERENCES Locations(LocationID), -- Reference to Locations table (dropoff)
    FOREIGN KEY (CouponID) REFERENCES Coupons(CouponID), -- Reference to Coupons table (discount)
    FOREIGN KEY (OrderStatusID) REFERENCES OrderStatusMaster(OrderStatusID) -- Reference to OrderStatuses table (status of the order)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: OrderAdditionalServices  
-- This table stores the additional services applied to orders.
-- It tracks the extra services associated with each order, including the cost for each additional service.
-- The 'OrderID' references the main order, and 'AdditionalServiceID' references the specific additional service being applied.
-- The 'ExtraCost' field captures the price for each additional service applied to the order.

CREATE TABLE OrderAdditionalServices (
    OrderAdditionalServiceID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each additional service applied
    OrderID UNIQUEIDENTIFIER NOT NULL, -- Reference to the Order table to link this additional service to a specific order
    AdditionalServiceID UNIQUEIDENTIFIER NOT NULL, -- Reference to the AdditionalServiceMaster table for the applied service
    ExtraCost DECIMAL(10,2) NOT NULL, -- Cost for the additional service (e.g., maintenance, cleaning)
    -- Foreign key relationships
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID), -- Links to the Orders table (the main order)
    FOREIGN KEY (AdditionalServiceID) REFERENCES AdditionalServiceMaster(AdditionalServiceID) -- Links to the AdditionalServiceMaster table (the service applied)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: PaymentMethodsMaster
-- This table stores only method IDs, while method names are stored in a separate translation table.

CREATE TABLE PaymentMethodsMaster (
    PaymentMethodID INT PRIMARY KEY IDENTITY(1,1), -- Auto-incremented unique ID
	ColumnTitle NVARCHAR(100) NOT NULL, -- for clarification only
    IsActive BIT NOT NULL DEFAULT 1, -- Whether the method is active (1 = Active, 0 = Inactive)
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: PaymentMethodTranslations
-- This table stores the possible payment methods (e.g., Credit Card, Cash, Wallet, Other).
-- This table stores method names in different languages.

CREATE TABLE PaymentMethodTranslations (
    TranslationID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PaymentMethodID INT NOT NULL,
    LanguageID UNIQUEIDENTIFIER NOT NULL,
    MethodName NVARCHAR(50) NOT NULL, -- Translated method name
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethodsMaster(PaymentMethodID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    UNIQUE (PaymentMethodID, LanguageID) -- Ensures unique translation per language
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: PaymentStatusMaster
-- Purpose: Stores unique payment status IDs without language-specific names.
-- Stores only status IDs. The status names are stored in a separate translation table for multi-language support.

CREATE TABLE PaymentStatusMaster (
    PaymentStatusID INT PRIMARY KEY IDENTITY(1,1), -- Unique Payment Status ID
    ColumnTitle NVARCHAR(100) NOT NULL, -- Conceptual category title for clarification
    IsActive BIT NOT NULL DEFAULT 1, -- Flag to indicate whether the status is active
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: PaymentStatusTranslations
-- Purpose: Stores payment status names in different languages.
-- This table stores the possible Payment Statuses (e.g., Pending, Paid, Failed, Refunded, Other).

CREATE TABLE PaymentStatusTranslations (
    PaymentStatusID INT NOT NULL, -- Links to PaymentStatusMaster
    LanguageID UNIQUEIDENTIFIER NOT NULL, -- Links to Languages table
    StatusName NVARCHAR(50) NOT NULL, -- Translated payment status name
    PRIMARY KEY (PaymentStatusID, LanguageID), -- Composite key ensures unique translations
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (PaymentStatusID) REFERENCES PaymentStatusMaster(PaymentStatusID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: OrderPayments
-- This table stores payment details for orders.
-- It tracks the payment method, status, amount, and transaction reference associated with each order.
-- The 'PaymentMethod' field stores the type of payment (Credit Card, Cash, Wallet, or Other).
-- The 'PaymentStatus' field tracks the current status of the payment (Pending, Paid, Failed, or Refunded).
-- The 'TransactionReference' holds the external payment gateway reference for tracking purposes.

CREATE TABLE OrderPayments (
    PaymentID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each payment
    OrderID UNIQUEIDENTIFIER NOT NULL, -- Reference to the Orders table, linking this payment to a specific order
    PaymentMethodID INT NOT NULL, -- Foreign key referencing the PaymentMethodsMaster table
    PaymentStatusID INT NOT NULL DEFAULT 1, -- Foreign key referencing the PaymentStatusMaster table (default is 'Pending')
    PaymentAmount DECIMAL(10,2) NOT NULL, -- The total amount paid for the order
    TransactionReference NVARCHAR(255) NULL, -- Optional external reference for payment (e.g., payment gateway reference)
    PaymentDate DATETIME DEFAULT GETDATE(), -- The date and time when the payment was made, defaults to current date/time
    -- Foreign key relationships
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID), -- Links this payment to the Orders table
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethodsMaster(PaymentMethodID), -- Links to the PaymentMethodsMaster lookup table
    FOREIGN KEY (PaymentStatusID) REFERENCES PaymentStatusMaster(PaymentStatusID) -- Links to the PaymentStatusMaster lookup table
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/*
    Table: UserCreditCards
    Purpose: Securely stores users' credit card information with encryption and masking.
    
    Security Considerations:
    - The full credit card number should be stored in an **encrypted format** (AES-256).
    - Only the **last four digits** are stored in plaintext for display purposes.
    - Ensure **PCI DSS compliance** by never storing CVV codes.
    - Card data should be accessible only by authorized processes.

	* "The Payment Card Industry Data Security Standard (PCI DSS) is a set of security requirements designed to protect 
	cardholder data and prevent fraud. Any business that stores, processes, or transmits credit card information must 
	follow these rules."
*/

CREATE TABLE UserCreditCards (
    CardID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each card
    UserID UNIQUEIDENTIFIER NOT NULL, -- Reference to the user
    CardHolderName NVARCHAR(150) NOT NULL, -- Name on the card
    CardNumber VARBINARY(256) NOT NULL, -- Encrypted credit card number
    ExpiryMonth TINYINT NOT NULL CHECK (ExpiryMonth BETWEEN 1 AND 12), -- Card expiration month
    ExpiryYear SMALLINT NOT NULL CHECK (ExpiryYear >= YEAR(GETDATE())), -- Card expiration year
    CardType NVARCHAR(50) NOT NULL, -- Example: Visa, MasterCard, AMEX
    LastFourDigits NVARCHAR(4) NOT NULL, -- Store only the last 4 digits for display
    CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for when the card was added
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update
    IsActive BIT DEFAULT 1, -- Whether the card is active (1 = Active, 0 = Inactive)    
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: DriverRatings
-- This table stores ratings and comments given to drivers after completing an order.
-- It links to the Users table (to reference the driver) and the Orders table (to associate the rating with a specific order).
-- The rating score is stored as a decimal, and comments are optional.

CREATE TABLE DriverRatings (
    RatingID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each rating
    OrderID UNIQUEIDENTIFIER NOT NULL, -- Reference to the Orders table, linking this rating to a specific order
    DriverID UNIQUEIDENTIFIER NOT NULL, -- Reference to the Users table (driver being rated)
    Rating DECIMAL(3, 2) CHECK (Rating >= 0 AND Rating <= 5) NOT NULL, -- Rating score (0 to 5 scale)
    Comment NVARCHAR(500) NULL, -- Optional comment left by the user regarding their experience with the driver
    RatingDate DATETIME DEFAULT GETDATE(), -- Date and time when the rating was given
    -- Foreign key relationships
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID), -- Links to the Orders table (specific order)
    FOREIGN KEY (DriverID) REFERENCES Users(UserID) -- Links to the Users table (driver being rated)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Notifications
-- This table stores notifications that will be sent to users.
-- The 'NotificationType' defines the category of the notification (e.g., Order Status, Coupon, General, Promotion, Alert).
-- 'NotificationTitle' contains the title of the notification, while 'NotificationContent' contains the detailed message.
-- 'NotificationImage' stores the URL or path to an image related to the notification (optional).
-- 'CreatedDate' is the timestamp when the notification was created, and 'ExpiryDate' defines when the notification expires (if applicable).
-- 'isActive' indicates whether the notification is currently active and should be displayed to users.

CREATE TABLE Notifications (
    NotificationID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each notification
    NotificationType NVARCHAR(50) CHECK (NotificationType IN ('OrderStatus', 'Coupon', 'General', 'Promotion', 'Alert')) NOT NULL, -- Type of notification
    NotificationTitle NVARCHAR(255) NOT NULL, -- Title of the notification
    NotificationContent NVARCHAR(MAX) NOT NULL, -- Content of the notification
    NotificationImage NVARCHAR(MAX) NULL, -- Optional field for the image related to the notification (URL or path)
    CreatedDate DATETIME DEFAULT GETDATE(), -- Date and time when the notification was created
    ExpiryDate DATETIME NULL, -- Optional expiry date for time-sensitive notifications
    isActive BIT DEFAULT 1 -- Flag indicating if the notification is currently active
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: UserNotifications
-- This table links users to notifications and tracks whether they have been seen.
-- 'UserID' refers to the user who is receiving the notification, and 'NotificationID' refers to the notification being sent.
-- The 'Seen' field tracks whether the user has seen the notification (0 = Not Seen, 1 = Seen).
-- 'ReadDate' is the date when the notification was actually read by the user, and 'isActive' indicates whether the notification is still active for the user.

CREATE TABLE UserNotifications (
    UserNotificationID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each user notification record
    UserID UNIQUEIDENTIFIER NOT NULL, -- Reference to the user receiving the notification
    NotificationID UNIQUEIDENTIFIER NOT NULL, -- Reference to the notification being sent to the user
    Seen BIT DEFAULT 0, -- 0 = Not Seen, 1 = Seen
    ReadDate DATETIME NULL, -- Date when the notification was read by the user
    isActive BIT DEFAULT 1, -- Flag indicating if the notification is still active for the user
    -- Foreign key relationships
    FOREIGN KEY (UserID) REFERENCES Users(UserID), -- Links to the Users table (the user receiving the notification)
    FOREIGN KEY (NotificationID) REFERENCES Notifications(NotificationID) -- Links to the Notifications table (the notification being sent)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: SystemMessages
-- This table stores system messages for different languages.
-- Each message can have multiple translations, one for each language, identified by 'LanguageID'.
-- The composite primary key ('MessageID', 'LanguageID') ensures that each language version of a message is unique.
-- 'IsActive' indicates whether the message is currently active, and 'CreatedAt' and 'UpdatedAt' track when the message was created or last modified.

CREATE TABLE SystemMessages (
    MessageID UNIQUEIDENTIFIER NOT NULL,    -- Shared across all translations of a message
    LanguageID UNIQUEIDENTIFIER NOT NULL,   -- The language in which the message is written
    MessageText NVARCHAR(MAX) NOT NULL,     -- The translated system message
    IsActive BIT NOT NULL DEFAULT 1,        -- Flag indicating whether the message is active or not
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(), -- Timestamp for message creation
    CreatedBy UNIQUEIDENTIFIER NOT NULL,    -- User who created the message
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(), -- Timestamp for last update
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,    -- User who last updated the message
    PRIMARY KEY (MessageID, LanguageID),    -- Composite primary key to ensure uniqueness for each language
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE, -- Maintain referential integrity
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID), -- Track creator
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID)  -- Track last updater
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Countries
-- This table links languages and countries together.
-- One language can be spoken in multiple countries, and each country can have multiple languages.
-- The LanguageID and CountryID combination ensures that each language-country relationship is unique.

CREATE TABLE LanguageCountry (
    LanguageCountryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each language-country record
    LanguageID UNIQUEIDENTIFIER NOT NULL, -- Reference to the language
    CountryID UNIQUEIDENTIFIER NOT NULL, -- Reference to the country
    IsActive BIT DEFAULT 1, -- Whether the language-country relationship is active (1 = active, 0 = inactive)
    CreatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for when the record was created
    CreatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID of the creator of the record
    UpdatedAt DATETIME DEFAULT GETDATE(), -- Timestamp for the last update
    UpdatedBy UNIQUEIDENTIFIER NOT NULL, -- UserID who last updated the record
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID), -- Links to the Languages table
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID), -- Links to the Countries table
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID), -- Reference to the Users table for the creator
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID) -- Reference to the Users table for the last updater
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------