--Primary Author Justys Renegado
--Last Reviewed and Approved by Peer: Josue Carames 2025.01.06 (timestamp should not be less than the last Change Log timestamp)
--Purpose: this query extacts FAMIS data using [Schedule_List] as the primary table
SELECT DISTINCT
    CASE WHEN SubQuery2.CountSchedules > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusSchedules,
    SubQuery2.*
FROM 
--SubQuery2
(SELECT DISTINCT
    CASE WHEN SubQuery1.[Count Check: Source] = SubQuery1.[Count Check: Final] THEN 'Yes' ELSE 'No' END "Count Check Status",
    COUNT(*) OVER (PARTITION BY SubQuery1.[Schedule ID]) AS CountSchedules,
    SubQuery1.*,
    --CUSTOM FIELD
    CASE WHEN SubQuery1.Reoccurence = '0 Seasonal' THEN 'Seasonally'
        WHEN SubQuery1.Reoccurence = '1 Yearly' THEN 'Annually'
        WHEN SubQuery1.Reoccurence = '1 Monthly' THEN 'Monthly'
        WHEN SubQuery1.Reoccurence = '1 Weekly' THEN 'Weekly'
        WHEN SubQuery1.Reoccurence = '1 Daily' THEN 'Daily'
        WHEN SubQuery1.Reoccurence = '2 Monthly' THEN '2 Months'
        WHEN SubQuery1.Reoccurence = '2 Yearly' THEN '2 Years'
        WHEN SubQuery1.Reoccurence = '2 Weekly' THEN '2 Weeks'
        WHEN SubQuery1.Reoccurence = '3 Monthly' THEN 'Quarterly'
        WHEN SubQuery1.Reoccurence = '3 Yearly' THEN 'Years'
        WHEN SubQuery1.Reoccurence = '4 Monthly' THEN '4 Months'
        WHEN SubQuery1.Reoccurence = '4 Weekly' THEN '4 Weeks'
        WHEN SubQuery1.Reoccurence = '5 Yearly' THEN '5 Years'
        WHEN SubQuery1.Reoccurence = '6 Monthly' THEN 'Semi-Annual'
        WHEN SubQuery1.Reoccurence = '10 Yearly' THEN '10 Years'
        WHEN SubQuery1.Reoccurence = '12 Monthly' THEN 'Annually'
        ELSE SubQuery1.Reoccurence END AS "Schedule"
FROM 
--SubQuery1
(SELECT DISTINCT 
     --STANDARD CUSTOM FIELDS
    'Schedules' AS "Source.Name",
    (SELECT COUNT(*) FROM [Schedules]) AS "Count Check: Source",
    COUNT(*) OVER () AS "Count Check: Final",
    1 AS Row_Count,
    --FIELDS FROM THE PROPERTY MASTER LISTING REPORT
    Schedules.ScheduleName AS "Schedule Name",
    Schedules.Id AS "Schedule ID",
    Schedules.RecurrencePatternDesc AS "Recurs",
    --[REMOVED] AS "Status",
    Schedules.Frequency AS "Frequency",
    Procedures.Name AS "Procedure",
    CAST(Schedules.StartDate AS DATE) AS "Start Date",
    CAST(Schedules.EndDate AS DATE) AS "End Date",
    --[REMOVED] AS "Start Time",
    --[REMOVED] AS "End Time",
    Properties.Name AS "Property",
    LOWER(RTRIM(LTRIM(Spaces.FloorName))) AS "Floor",
    LOWER(RTRIM(LTRIM(Spaces.Name))) AS "Space",
    --[REMOVED] AS "Sub-Space",
    [Request Types].Description AS "Type",
    [Request SubTypes].Description AS "SubType",
    [Request Priorities].Name AS "Priority",
    UsersC.Name AS "Created By",
    UsersA.Name AS "Assigned To",
    Schedules.AssetId,
    Assets.Name AS "Asset Name",
    Schedules.StatementOfWork AS "Statement of Work",
    --[REMOVED] AS "Est Hours",
    --[REMOVED] AS "Billable?",
    Schedules.EstimatedLaborHours AS "Labor Hours",
    TRY_CAST(Schedules.TotalLabor AS DECIMAL(10, 2)) AS "Labor",
    TRY_CAST(Schedules.TotalMaterials AS DECIMAL(10, 2)) AS "Materials",
    TRY_CAST(Schedules.TotalOtherCosts AS DECIMAL(10, 2)) AS "Other Costs",
    TRY_CAST(Schedules.TotalMarkup AS DECIMAL(10, 2)) AS "Markup",
    SUM(TRY_CAST(Schedules.TotalLabor AS DECIMAL(10, 2)) + TRY_CAST(Schedules.TotalMaterials AS DECIMAL(10, 2)) + TRY_CAST(Schedules.TotalOtherCosts AS DECIMAL(10, 2)) + TRY_CAST(Schedules.TotalMarkup AS DECIMAL(10, 2))) OVER() AS "Total Cost",
    Schedules.EstimatedTotalAmount AS "Total Amount",
    --CUSTOM FIELDS
    CONCAT(Schedules.Frequency,' ', Schedules.RecurrencePatternDesc) AS "Reoccurence"
FROM Schedules
    LEFT JOIN Properties ON Properties.Id = Schedules.PropertyId
    LEFT JOIN Spaces ON Spaces.Id = Schedules.SpaceId
    LEFT JOIN [Request Types] ON [Request Types].Id = Schedules.RequestTypeId
    LEFT JOIN [Request SubTypes] ON [Request SubTypes].Id = Schedules.RequestSubTypeId
    LEFT JOIN [Request Priorities] ON [Request Priorities].Id = Schedules.RequestPriorityId
    LEFT JOIN Assets ON Assets.Id = Schedules.AssetId
    LEFT JOIN Users AS UsersA ON UsersA.Id = Schedules.AssignedToId
    LEFT JOIN Users AS UsersC ON UsersC.Id = Schedules.CreatedById
    LEFT JOIN Procedures ON Procedures.Id = Schedules.ProcedureId   
) AS SubQuery1
) AS SubQuery2
ORDER BY DuplicateStatusSchedules DESC
--CHANGE LOG
--Justys Renegado (2024.12.26): this query was modeled after the FAMIS Schedule_List report within the Export Folder
    --(cont.) Export Folder https://microncorp.sharepoint.com/:f:/r/sites/GWREF-BIZOPS/BizOps/Reporting%20%26%20Analytics/1.1%20Business%20Intelligence%20Team/Exported%20Reports/FAMIS?csf=1&web=1&e=BqIz7U
    --(cont.) [REMOVED] indicates this column was part of the original FAMIS export report but excluded from this API query
