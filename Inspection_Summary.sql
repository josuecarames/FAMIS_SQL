--Primary Author Justys Renegado
--Last Reviewed and Approved by Peer: Josue Carames 2025.01.06 (timestamp should not be less than the last Change Log timestamp)
--Purpose: this query extacts FAMIS data using [Inspections] as the primary table
SELECT DISTINCT
    CASE WHEN SubQuery2.CountInspectionId > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusInspections,
    SubQuery2.*
FROM 
--SubQuery2
(SELECT DISTINCT
    CASE WHEN SubQuery1.[Count Check: Source] = SubQuery1.[Count Check: Final] THEN 'Yes' ELSE 'No' END "Count Check Status",
    COUNT(*) OVER (PARTITION BY SubQuery1.[Inspection ID]) AS CountInspectionId,
    SubQuery1.*
FROM 
--SubQuery1
(SELECT DISTINCT 
     --STANDARD CUSTOM FIELDS
    'Inspections' AS "Source.Name",
    (SELECT COUNT(*) FROM [Inspections]) AS "Count Check: Source",
    COUNT(*) OVER () AS "Count Check: Final",
    1 AS Row_Count,
    --FIELDS FROM THE INSPECTION SUMMARY REPORT
    CAST(Inspections.InspectionDate AS DATE) AS "Inspection Date",
    Inspections.InspectionTime AS "Inspection Time",
    --[REMOVED]  AS "Month/Year",
    Inspections.Id AS "Inspection ID",
    'PENDING' AS "Item",
    Inspections.Score AS "Score",
    [Inspection Conditions].Description AS "Condition",
    Inspections.Comments AS "Comment",
    [Properties].Name AS "Property",
    --[REMOVED] AS "External Property",
    LOWER(RTRIM(LTRIM(Spaces.FloorName))) AS "Floor",
    LOWER(RTRIM(LTRIM(Spaces.Name))) AS "Space",
    --[REMOVED] AS "Sub-Space",
    [Inspection Classes].Description AS "Inspection Class",
    Procedures.Name AS "Inspection Type",
    Users.Name AS "Inspector",
    Inspections.Room AS "Room/Area",
    Inspections.Occupant AS "Occupant",
    Inspections.AssetId,
    Assets.Name AS "Asset Name",
    Inspections.AssetNumber AS "Asset #",
    Inspections.Comments AS "General Comments",
    --[REMOVED] AS "LCAM",
    Inspections.WorkOrderId AS "Request ID",
    --CUSTOM FIELDS
    FORMAT(CONVERT(date, Inspections.InspectionDate), 'yyyy-MM') AS "Date Year Month",
    CONCAT('https://micron.famis360.com/Inspection_Update.asp?InspectionID=',Inspections.Id) AS "FAMIS Survey URL"  
FROM Inspections
    LEFT JOIN [Inspection Conditions] ON [Inspection Conditions].Id = Inspections.Id
    LEFT JOIN Procedures ON Procedures.Id = Inspections.InspectionTypeId
    LEFT JOIN [Inspection Classes] ON [Inspection Classes].Id = Inspections.InspectionClassId
    LEFT JOIN Properties ON Properties.Id = Inspections.PropertyId
    LEFT JOIN Spaces ON Spaces.Id = Inspections.SpaceId
    LEFT JOIN Assets ON Assets.Id = Inspections.AssetId
    LEFT JOIN Users ON Users.Id = Inspections.InspectorId
) AS SubQuery1
) AS SubQuery2
ORDER BY DuplicateStatusInspections DESC
--CHANGE LOG
--Justys Renegado (2024.12.26): this query was modeled after the FAMIS Inspection_Summary report within the Export Folder
    --(cont.) Export Folder https://microncorp.sharepoint.com/:f:/r/sites/GWREF-BIZOPS/BizOps/Reporting%20%26%20Analytics/1.1%20Business%20Intelligence%20Team/Exported%20Reports/FAMIS?csf=1&web=1&e=BqIz7U
    --(cont.) [REMOVED] indicates this column was part of the original FAMIS export report but excluded from this API query
