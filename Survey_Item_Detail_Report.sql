--Primary Author Justys Renegado
--Last Reviewed and Approved by Peer: Josue Carames 2025.01.06 (timestamp should not be less than the last Change Log timestamp)
--Purpose: this query extacts FAMIS data using [Inspections] as the primary table
SELECT DISTINCT
    CASE WHEN SubQuery2.CountSurveyId > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusSurveys,
    SubQuery2.*
FROM 
--SubQuery2
(SELECT DISTINCT
    CASE WHEN SubQuery1.[Count Check: Source] = SubQuery1.[Count Check: Final] THEN 'Yes' ELSE 'No' END "Count Check Status",
    COUNT(*) OVER (PARTITION BY SubQuery1.[Inspection ID]) AS CountSurveyId,
    SubQuery1.*
FROM 
--SubQuery1
(SELECT DISTINCT 
     --STANDARD CUSTOM FIELDS
    'Inspections (CSAT)' AS "Source.Name",
    (SELECT COUNT(*) FROM [Inspections]) AS "Count Check: Source",
    COUNT(*) OVER () AS "Count Check: Final",
    1 AS Row_Count,
    --FIELDS FROM THE INSPECTION SUMMARY REPORT
    --[REMOVED] AS "Region 1",
    --[REMOVED] AS "Region 2",
    CAST(Inspections.CreateDate AS DATE) AS "Survey Date",
    --[REMOVED] AS "Month/Year",
    Inspections.Id AS "Inspection ID",
    Inspections.WorkOrderId AS "Request ID",
    [Work Orders].Type,
    [Work Orders].[Sub Type],
    [Work Orders].[Initial Request Comment],
    --[REMOVED] AS "Service Type",
    Inspections.InspectionClassId,
/*
    CASE WHEN [Inspection Items].Description = 'Overall, the level of service I received met or exceeded my expectations?' THEN 'Overall'
        WHEN [Inspection Items].Description = 'Facilities responded to my request in a timely and effective manner?' THEN 'Communication'
        WHEN [Inspection Items].Description = 'The technician arrived on-site in a timely manner?' THEN 'Response'
        WHEN [Inspection Items].Description = 'The technician that arrived on-site was professional and competent?' THEN 'Professional' 
        WHEN [Inspection Items].Description = 'The work was completed to my satisfaction?' THEN 'Completion'
        WHEN [Inspection Items].Description = 'NA' THEN NULL
        ELSE [Inspection Items].Description END 
*/
    'PENDING' AS "Item",
    Inspections.Score AS "Item Score",
    [Inspection Conditions].Description AS "Condition",
    Inspections.Comments AS "Item Comment",
    [Properties].Name AS "Property",
    --[REMOVED] AS "External Property ID",
    --[REMOVED] AS "Property Type",
    --[REMOVED] AS "Property Status",
    LOWER(RTRIM(LTRIM(Spaces.FloorName))) AS "Floor",
    LOWER(RTRIM(LTRIM(Spaces.Name))) AS "Space",
    --[REMOVED] AS "Sub-Space",
    [Inspection Classes].Description AS "Inspection Class",
    'CSAT Survey' AS "Inspection Type",
    Users.Name AS "Inspector",
    [Work Orders].Requestor,
    Inspections.Occupant AS "Occupant",
    [Work Orders].[General Comment],
    'Pending' AS "Overall Survey Score",
    [Work Orders].Proactive,
    --CUSTOM FIELDS
    FORMAT(CONVERT(date, Inspections.CreateDate), 'yyyy-MM') AS "Date Year Month",
    CONCAT([Work Orders].Type, ' ', [Work Orders].[Sub Type]) AS "Ticket Item",
    CONCAT('https://micron.famis360.com/Inspection_Update.asp?InspectionID=',Inspections.Id) AS "FAMIS Survey URL", 
    CONCAT('https://micron.famis360.com/LB_Request_Update.asp?RequestID=',[Work Orders].[Request ID]) AS "FAMIS WO URL"
FROM Inspections
    LEFT JOIN [Inspection Conditions] ON [Inspection Conditions].Id = Inspections.Id
    LEFT JOIN Procedures ON Procedures.Id = Inspections.InspectionTypeId
    LEFT JOIN [Inspection Classes] ON [Inspection Classes].Id = Inspections.InspectionClassId    
    LEFT JOIN Properties ON Properties.Id = Inspections.PropertyId
    LEFT JOIN Spaces ON Spaces.Id = Inspections.SpaceId
    LEFT JOIN Users ON Users.Id = Inspections.InspectorId
    LEFT JOIN --custom subquery for [Work Orders]
(SELECT DISTINCT
    [Work Orders].Id AS "Request ID",
    [Request Types].Description AS "Type",
    [Request SubTypes].Description AS "Sub Type",
    LOWER(RTRIM(LTRIM([Work Orders].InternalComments))) AS "Initial Request Comment",
    [Work Orders].RequestorName AS "Requestor",
    LOWER(RTRIM(LTRIM([Work Orders].GeneralComments))) AS "General Comment",
    CASE WHEN [Origination Codes].Description = 'Inspection' OR [Origination Codes].Description = 'Internal Team' OR [Origination Codes].Description = 'Scheduled - PPM' THEN 'Proactive'
        WHEN [Origination Codes].Description = 'Behalf of Customer - Email' OR [Origination Codes].Description = 'Behalf of Customer - Phone' OR [Origination Codes].Description = 'Behalf of Customer - Verbal' OR [Origination Codes].Description = 'Self Service' THEN 'Reactive'
        ELSE 'Ignore' END AS "Proactive"    
FROM [Work Orders]
    LEFT JOIN [Request Types] ON [Request Types].Id = [Work Orders].RequestTypeId
    LEFT JOIN [Request SubTypes] ON [Request SubTypes].Id = [Work Orders].RequestSubTypeId
    LEFT JOIN [Origination Codes] ON [Origination Codes].Id = [Work Orders].OriginationCodeId
) AS [Work Orders] ON [Work Orders].[Request ID] = Inspections.WorkOrderId
) AS SubQuery1
) AS SubQuery2
--WHERE InspectionClassId = 7
ORDER BY [Request ID] DESC
--CHANGE LOG
--Justys Renegado (2024.12.26): this query was modeled after the FAMIS Inspection_Summary report within the Export Folder
    --(cont.) Export Folder https://microncorp.sharepoint.com/:f:/r/sites/GWREF-BIZOPS/BizOps/Reporting%20%26%20Analytics/1.1%20Business%20Intelligence%20Team/Exported%20Reports/FAMIS?csf=1&web=1&e=BqIz7U
    --(cont.) [REMOVED] indicates this column was part of the original FAMIS export report but excluded from this API query
