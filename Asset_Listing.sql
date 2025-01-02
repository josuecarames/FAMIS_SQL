--Primary Author Josue Carames
--Last Reviewed and Approved by Peer: Justys Renegado 2024.26.24 (timestamp should not be less than the last Change Log timestamp)
--Purpose: this query extacts FAMIS data using [Assets] as the primary table
SELECT DISTINCT
    CASE WHEN SubQuery2.CountAssetId > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusAssets,
    SubQuery2.*
FROM 
--SubQuery2
(SELECT DISTINCT
    CASE WHEN SubQuery1.[Count Check: Source] = SubQuery1.[Count Check: Final] THEN 'Yes' ELSE 'No' END "Count Check Status",
    COUNT(*) OVER (PARTITION BY SubQuery1.AssetId) AS CountAssetId,
    SubQuery1.*
FROM 
--SubQuery1
(SELECT DISTINCT 
     --STANDARD CUSTOM FIELDS
    'Assets' AS "Source.Name",
    (SELECT COUNT(*) FROM [Assets]) AS "Count Check: Source",
    COUNT(*) OVER () AS "Count Check: Final",
    1 AS Row_Count,
    --FIELDS FROM THE ASSET LISTING REPORT
    Assets.Id AS "AssetId", 
    --[REMOVED] AS Region",
    --[REMOVED] AS "Sub-Region",
    Assets.Name AS "Asset Name", 
    Assets.AssetNumber AS "Asset#",
    --[REMOVED] AS "Financial System ID",
    --[REMOVED] AS "Barcode Number",    
    Assets.SerialNumber AS "Serial#",
    [Asset Classes].Description AS "Asset Class",
    [Asset Ranks].Description AS "Asset Rank",
    CAST(Assets.InServiceDate AS DATE) AS "In-Service Date",
    [Asset Makes].Description AS "Manufacturer",
    [Asset Models].Description AS "Model",
    [Asset Statuses].Name AS "Asset Status",
    Assets.StatusComment AS "Status Comments",
    Assets.Description AS "Asset Description",
    CAST(Assets.WarrantyEffectiveDate AS DATE) AS "Warranty Effective Date",
    CAST(Assets.WarrantyExpirationDate AS DATE) AS "Warranty Expiration Date",
    [Properties].Name AS "Property",
    Spaces.Name AS "Space",
    Assets.Room AS "Room/Area",
    Assets.EmployeeName AS "Employee",
    CAST(Assets.PurchaseDate AS DATE) AS "Purchase Date",
    Assets.PurchaseAmount AS "Purchase Amount",
    Assets.Comments AS "Asset Comments",
    CASE WHEN [Work Orders].[PM Tickets] = 'PM' THEN 'Y' ELSE 'N' END AS "Scheduled?",
    Assets.UpdateDate AS "Last Update",
    Users.Name AS "Updated By",
    Assets.AssetSafetyComments AS "Asset Safety Comments",
    --[REMOVED] AS "# of Documents",   
    --[REMOVED] AS "FCA Rank",
    --[REMOVED] AS "Status",
    --[REMOVED] AS "External Property ID",
    Assets.EstimatedLifeInYears AS "Estimated Life(yrs)",
    --[REMOVED] AS "Warranty Vendor",
    --[REMOVED] AS "Warranty PO#",
    --[REMOVED] AS "Purchase PO#",
    --[REMOVED] AS "Purchase PO Date",    
    --CUSTOM FIELDS
    CASE WHEN [Asset Classes].Description LIKE '%-%' THEN LTRIM(RTRIM(LEFT([Asset Classes].Description, CHARINDEX('-', [Asset Classes].Description) - 1)))
        ELSE [Asset Classes].Description END AS "Group",
    FORMAT(CONVERT(date, Assets.InServiceDate), 'yyyy-MM') AS "Date Year Month"
FROM Assets
    LEFT JOIN [Asset Classes] ON [Asset Classes].Id = Assets.AssetClassId
    LEFT JOIN [Asset Ranks] ON [Asset Ranks].Id = Assets.AssetRankId
    LEFT JOIN [Asset Makes] ON [Asset Makes].Id = Assets.MakeId
    LEFT JOIN [Asset Models] ON [Asset Models].Id = Assets.ModelId
    LEFT JOIN [Asset Statuses] ON [Asset Statuses].Id = Assets.AssetStatusId
    LEFT JOIN Properties ON Properties.Id = Assets.PropertyId
    LEFT JOIN Spaces ON Spaces.Id = Assets.SpaceId
    LEFT JOIN Users ON Users.Id = Assets.UpdatedById
    LEFT JOIN --this subquery is used to identify PM tickets from [Work Orders] and determine the Scheduled? field
(SELECT DISTINCT 
    [Work Orders].AssetId,
    'PM' AS "PM Tickets"
FROM [Work Orders]
    LEFT JOIN [Request Priorities] ON [Request Priorities].Id = [Work Orders].RequestPriorityId
WHERE [Request Priorities].Name LIKE 'Scheduled (end of%'
) AS [Work Orders] ON [Work Orders].AssetId = Assets.Id
) AS SubQuery1
) AS SubQuery2
ORDER BY DuplicateStatusAssets DESC
--CHANGE LOG
--Justys Renegado (2024.12.26): this query was modeled after the FAMIS Asset_Listing report within the Export Folder
    --(cont.) Export Folder https://microncorp.sharepoint.com/:f:/r/sites/GWREF-BIZOPS/BizOps/Reporting%20%26%20Analytics/1.1%20Business%20Intelligence%20Team/Exported%20Reports/FAMIS?csf=1&web=1&e=BqIz7U
    --(cont.) [REMOVED] indicates this column was part of the original FAMIS export report but excluded from this API query
