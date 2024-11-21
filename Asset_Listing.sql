SELECT 
    Regions.Name AS "Region", 
    -- Sub-Region, 
    Assets.Name AS "Asset Name", 
    Assets.AssetNumber AS "Asset#",
    Assets.FinancialSystemId AS "Financial System ID",
    Assets.BarcodeNumber AS "Barcode Number",
    [Asset Classes].Description AS "Asset Class",
    [Asset Ranks].Description AS "Asset Rank",
    Assets.InServiceDate AS "In-Service Date",
    -- Manufacturer,
    [Asset Models].Description AS "Model",
    [Asset Statuses].Name AS "Asset Status",
    Assets.StatusComment AS "Asset Comments",
    Assets.Description AS "Asset Description",
    Assets.WarrantyEffectiveDate AS "Warranty Effective Date",
    Assets.WarrantyExpirationDate AS "Warranty Expiration Date",
    [Properties].[Name] AS "Property",
    Spaces.Name AS "Space",
    Assets.Room AS "Room/Area",
    -- Employee,
    Assets.PurchaseDate AS "Purchase Date",
    Assets.PurchaseAmount AS "Purchase Amount",
    Assets.Comments AS "Asset Comments",
    -- Scheduled?
    -- Updated By?
    Assets.AssetSafetyComments AS "Asset Safety Comments",
    -- # Documents,
    [FCA Rank].Name AS "FCA Rank", -- review data matching
    [Asset Statuses].[Value] AS "Status" -- review data matching
    -- ExternalPropertyID?
    -- Estimated Life(yrs)
    -- WarrantyVendor?
    -- Warranty PO#
    -- Purchase PO#
    -- Purchase PO Date
FROM Assets
LEFT JOIN [Asset Classes] ON [Asset Classes].Id = Assets.AssetClassId
LEFT JOIN [Asset Ranks] ON [Asset Ranks].Id = Assets.AssetRankId
-- LEFT JOIN [ECRI Codes] ON [ECRI Codes].Id = Assets.EcriCodeId     "Message": "Insufficient Configuration: Asset module and Healthcare functionality must be on and ECRI Codes must be enabled. "
LEFT JOIN [Asset Makes] ON [Asset Makes].Id = Assets.MakeId
LEFT JOIN [Asset Models] ON [Asset Models].Id = Assets.ModelId
LEFT JOIN [Asset Statuses] ON [Asset Statuses].Id = Assets.AssetStatusId
-- FinancialSystemId?
-- LEFT JOIN [Assets Keywords] ON [Assets Keywords].Id = Assets.AssetKeywordId     "Message": "Exception: Insufficient Configuration: Asset configuration must be set to display asset keyword and type. "
-- ExternalId?
-- LEFT JOIN [Assets Types] ON [Assets Types].Id = Assets.AssetTypeId     "Message": "Exception: Insufficient Configuration: Display Asset Keyword and Type Flag needs to be on. "
LEFT JOIN [External Systems] ON [External Systems].Id = Assets.ExternalSystemId
LEFT JOIN Properties ON Properties.Id = Assets.PropertyId
LEFT JOIN [Property Region Associations] ON [Property Region Associations].PropertyId = Properties.Id
LEFT JOIN Regions ON Regions.Id = [Property Region Associations].RegionId
LEFT JOIN Spaces ON Spaces.Id = Assets.SpaceId
-- EmployeeId?
-- LEFT JOIN Floors ON Floors.Id = Assets.FloorId     "Message": "Exception: Installation settings do not allow access of the floor module. "
-- LEFT JOIN SubSpaces ON SubSpaces.Id = Assets.SubSpaceId     "Message": "Exception: Installation settings do not allow access of the subspace module. "
-- WarrantyVendorId?
-- WarrantyPoNumberId?
-- ExternalCostCenterId?     "Message": "Exception: Insufficient Configuration: Asset Module, Healthcare Module, and External Cost Center Validation must be on to access external cost centers.  "
LEFT JOIN UOMs ON UOMs.Id = Assets.UomId
-- UtilityId?
-- MeterSiteId?     "Message": "Exception: Installation settings do not allow access of the Utility module. "
-- UpdatedById?
LEFT JOIN [FCA Rank] ON [FCA Rank].Id = Assets.FcaRankId
-- PropertyExternalId?
-- SpaceExternalId?
-- EmployeeExternalId?
-- WarrantyVendorExternalId?
-- MaintenanceContractVendorExternalId?
-- UpdatedByExternalId?
-- FloorExternalId?
-- SubSpaceExternalId?
-- AutoAssignedToExternalId?
WHERE 
    1 = 1
    -- AND Region IS NOT NULL
    -- AND [FCA Rank].Name LIKE '%Priority%'
    -- OR [FCA Rank].Name IS NOT null
;
