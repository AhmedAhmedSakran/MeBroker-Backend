--UserRoles
--(1)---->Admin
--(2)---->Broker
--(3)---->Client
--(4)---->Driver
--(5)---->ShopOwner
--(6)---->ScrapShopOwner
--(7)---->GarageShopOwner
--------------------------------------------------------------
--Mostafa will provide the sccript related to that part ""auth
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: UserRoles  
-- This table stores different user roles in the system Like 'Client', 'Broker', 'ShopOwner', 'Driver', 'Admin'  
-- Each role is unique and can be activated or deactivated.

CREATE TABLE UserRoles (
    UserRoleID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique identifier for each role
    Role NVARCHAR(50) UNIQUE NOT NULL CHECK (Role IN ('Client', 'Broker', 'ShopOwner', 'Driver', 'Admin','ScrapShopOwner','GarageShopOwner')), -- Role name, must be unique
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
    (NEWID(), 'Admin', 1),
    (NEWID(), 'Broker', 1),
    (NEWID(), 'Client', 1),
    (NEWID(), 'Driver', 1),
    (NEWID(), 'ShopOwner', 1),
    (NEWID(), 'ScrapShopOwner', 1),
    (NEWID(), 'GarageShopOwner', 1);
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
-- Table: ServicesTranslations 
-- Purpose: Stores service names in different languages, linking them to ServiceMaster.

CREATE TABLE ServicesTranslations (
    ServiceID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to ServiceMaster
    LanguageID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to Languages
    ServiceName NVARCHAR(255) NOT NULL, -- Translated service name
    isActive BIT DEFAULT 1, -- Indicates if the field is active (1 = Active, 0 = Inactive)
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY (ServiceID, LanguageID), -- Composite key ensures unique translations
    FOREIGN KEY (ServiceID) REFERENCES ServiceMaster(ServiceID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE,
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

CREATE TABLE AdditionalServicesTranslations (
    AdditionalServiceID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to AdditionalServiceMaster
    LanguageID UNIQUEIDENTIFIER NOT NULL, -- Foreign key to Languages
    AdditionalServiceName NVARCHAR(255) NOT NULL, -- Translated additional service name
    PRIMARY KEY (AdditionalServiceID, LanguageID), -- Composite key ensures unique translations
    FOREIGN KEY (AdditionalServiceID) REFERENCES AdditionalServiceMaster(AdditionalServiceID) ON DELETE CASCADE,
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID) ON DELETE CASCADE
);
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Table: Providers  
-- This table stores information about service providers who are registered to offer specific services.  
-- Each provider is linked to a user account and a specific service they offer. This allows the system  
-- to identify which providers should be notified when a new order related to their service is placed.  

CREATE TABLE Providers (
    ProviderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL, -- The user who is a registered service provider  
    ServiceID INT NOT NULL, -- The service that the provider offers  
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the provider was registered  
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Last update timestamp  
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID) ON DELETE CASCADE
);
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
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
-- Table: Orders  
-- This table stores customer orders and their pricing breakdowns. It includes order details such as the client, 
-- assigned driver, locations, pricing, discounts, and the final calculated price.
-- Foreign key relationships are established to Users, Services, Locations, and Coupons tables for data integrity.

CREATE TABLE Orders (
    OrderID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- Unique order identifier, automatically generated
    UserID UNIQUEIDENTIFIER NOT NULL, -- The client placing the order, references Users table
    ServiceID UNIQUEIDENTIFIER NOT NULL, -- The selected main service, references Services table
    
    HaveBroker BIT DEFAULT 0, -- Indicates whether the broker is exist (1 = HaveBroker, 0 = HaveNoBroker)
    BrokerID UNIQUEIDENTIFIER NULL,--If there is a broker recommend the client to use the services
    BrokerPercentage DECIMAL(5,2) NULL; -- Percentage commission for the broker (e.g., 10.00 for 10%)

    HaveAdditionalServices BIT DEFAULT 0, -- Indicates whether the client have select extra Additional Services is Yes (1 = Have, 0 = NoHave)
    
    -- furniture move service & Car breakdown
    PickupLocationID UNIQUEIDENTIFIER NULL, -- Pickup location, references Locations table
    DropoffLocationID UNIQUEIDENTIFIER NULL, -- Drop-off location, references Locations table
    DistanceInKm DECIMAL(10,2) NOT NULL, -- Distance for the service in kilometers (calculated)
    
    -- spare part request service
    SparePartPhoto TEXT NULL,
    SparePartDescription TEXT NULL,
    
    OrderStatusID INT NOT NULL, -- Foreign key to reference OrderStatuses table (stores the current order status)
    OrderDate DATETIME DEFAULT GETDATE(), -- Date and time when the order was placed, defaults to current date/time
    -- Foreign key relationships
    FOREIGN KEY (UserID) REFERENCES Users(UserID), -- Reference to Users table (client)
    FOREIGN KEY (BrokerID) REFERENCES Users(UserID), -- Reference to Users table (broker)
    FOREIGN KEY (ServiceID) REFERENCES ServiceMaster(ServiceID), -- Reference to ServiceMaster table (main service)
    FOREIGN KEY (PickupLocationID) REFERENCES Locations(LocationID), -- Reference to Locations table (pickup)
    FOREIGN KEY (DropoffLocationID) REFERENCES Locations(LocationID), -- Reference to Locations table (dropoff)
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
    -- Foreign key relationships
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID), -- Links to the Orders table (the main order)
    FOREIGN KEY (AdditionalServiceID) REFERENCES AdditionalServiceMaster(AdditionalServiceID) -- Links to the AdditionalServiceMaster table (the service applied)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Table: Offers  
-- This table allows users who provide services (Providers) to submit offers in response to new orders  
-- related to their services. When a new order is placed, relevant Providers are notified. Each Provider  
-- can then submit an offer with their proposed price. The status of the offer is tracked to indicate  
-- whether it is pending, accepted, or rejected.  

CREATE TABLE Offers (
    OfferID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID UNIQUEIDENTIFIER NOT NULL, -- Reference to the Order table to link this additional service to a specific order
    ProviderID UNIQUEIDENTIFIER NOT NULL, -- The Provider submitting the offer
    
    ServicePrice DECIMAL(10,2) NOT NULL, -- The price proposed by the provider related to selected service
    AdditionalServicesPrice DECIMAL(10,2) NOT NULL, -- Cost for the additional service (e.g., maintenance, cleaning)
    TotalPrice DECIMAL(10,2) NOT NULL,-- The totalprice proposed by the provider related to selected service and selected extra Additional Services

    OfferStatus ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending', -- Offer status  
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the offer was created  
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Last update timestamp  
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE, -- Links to the Orders table (the main order)
    FOREIGN KEY (ProviderID) REFERENCES Providers(ProviderID) ON DELETE CASCADE
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
    MessageGroup NVARCHAR(255) NOT NULL,    -- Classification of the message (e.g., 'Error', 'Notification', 'Alert')  
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