--Primary Author Justys Renegado
--Last Reviewed and Approved by Peer: Josue Carames 2025.01.06 (timestamp should not be less than the last Change Log timestamp)
--Purpose: this query extacts FAMIS data using [Work Orders] as the primary table
SELECT DISTINCT
    CASE WHEN SubQuery2.CountRequestID > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusworkOrders,
    SubQuery2.*
FROM 
 --SubQuery2
(SELECT DISTINCT
    CASE WHEN SubQuery1.[Count Check: Source] = SubQuery1.[Count Check: Final] THEN 'Yes' ELSE 'No' END "Count Check Status",
    COUNT(*) OVER (PARTITION BY SubQuery1.[Request ID]) AS CountRequestID,
    SubQuery1.*,
    --CUSTOM FIELDS
    SubQuery1.[Proactive Count] / 1 AS "Proactivity %",
    SubQuery1.[Response On Time Count] / 1 AS "Response %",
    SubQuery1.[Completion On Time Count] / 1 AS "Completion %",
    SubQuery1.[Survey Count] / 1 AS "Survey Response %",
    CASE WHEN SubQuery1.[Response Compliance] = 'On Time' THEN 'Display' 
        WHEN SubQuery1.[Response Compliance] = 'Overdue' THEN 'Display' 
        WHEN SubQuery1.[Completion Compliance] = 'On Time' THEN 'Display' 
        WHEN SubQuery1.[Completion Compliance] = 'Overdue' THEN 'Display'
        ELSE 'Ignore' END AS "Display Compliances",
    CASE WHEN SubQuery1.Date <= CAST(GETDATE() AS DATE) THEN 'Yes' 
        ELSE 'No' END AS "Less Than or Equal to Today"
FROM 
 --SubQuery1
(SELECT DISTINCT
    --STANDARD CUSTOM FIELDS
    'Work Orders' AS "Source.Name",
    (SELECT COUNT(*) FROM [Work Orders]) AS "Count Check: Source",
    COUNT(*) OVER () AS "Count Check: Final",
    1 AS Row_Count,
    --FIELDS FROM THE REQUEST SUMMARY REPORT
    CAST([Work Orders].CreateDate AS DATE) AS "Date",
    --[REMOVED] AS "Time",
    [Work Orders].Id AS "Request ID",
    [Purchase Order Lines].PONumberList AS "PO#",
    [Purchase Order Lines].DuplicateStatusPurchaseOrderLines,
    [Work Orders].RequestorName AS "Requested By",
    [Work Orders].RequestorEmail AS "Requestor Email",
    UsersC.Name AS "Created By",
    Properties.Name AS "Property Name",
    --[REMOVED] AS "Property Timezone",
    --[REMOVED] AS "Property Currency",
    LOWER(RTRIM(LTRIM(Spaces.Name))) AS "Space/Floor",
    LOWER(RTRIM(LTRIM([Work Orders].RoomCube))) AS "Room/Cube/Lab",
    Departments.Description AS "Department#",
    --[REMOVED] AS "Micron Cost Center",
    [Request Types].Description AS "Request Type",
    [Request SubTypes].Description AS "Sub Type",
    [Request Statuses].Name AS "Status",
    [Request Priorities].Name AS "Priority",
    UsersA.Name AS "Assigned To",
    --[REMOVED] AS "Date Closed",
    --[REMOVED] AS "Closed By",
    LOWER(RTRIM(LTRIM([Work Orders].GeneralComments))) AS "Original Message",
    [Origination Codes].Description AS "Origination Code",
    Assets.AssetNumber AS "Asset#",
    LOWER(RTRIM(LTRIM(Assets.Description))) AS "Asset Name",
    [Failure Codes].Name AS "Failure Code",
    LOWER(RTRIM(LTRIM([Work Orders].StatementOfWork))) AS "Statement of Work",
    CAST([Work Orders].CompleteByDate AS DATETIME) AS "Complete By",
    [Labor Costs].DuplicateStatusLaborCosts,
    --[REMOVED] AS "AP Invoice #",
    [Labor Costs].[Labor Hours] AS "Labor Hours",    
    SUM(TRY_CAST([Work Orders].TotalLaborCost AS DECIMAL(10, 2))) OVER() AS "Labor",
    SUM(TRY_CAST([Work Orders].TotalMaterialCost AS DECIMAL(10, 2))) OVER() AS "Materials",
    SUM(TRY_CAST([Work Orders].TotalOtherCost AS DECIMAL(10, 2))) OVER() AS "Other Costs",
    [Labor Costs].[AP Tax] AS "AP Tax",
    [Labor Costs].[AP S&H] AS "AP S&H",
    [Labor Costs].[Total Amount] AS "Total Amount",
    --[REMOVED] AS "Customer PO Number",
    --[REMOVED] AS "Top Level",
    --[REMOVED] AS "Parent WO",
    --[REMOVED] AS "Child WO",
    --[REMOVED] AS "Signature Added?",
    --[REMOVED] AS "Signee Description",
    --[REMOVED] AS "Signature Captured Date",
    [Work Orders].ExportFlag AS "Export Flag",
    --[REMOVED] AS "External Property Id 1",
    --[REMOVED] AS "External Request Type Id",
    --[REMOVED] AS "External Sub Type Id",
    --[REMOVED] AS "Initial Work Complete Date",                                    
    LOWER(RTRIM(LTRIM([Work Orders].InternalComments))) AS "Initial Work Complete Comment",
    [Work Orders].AssetId,
    --SLA RELATED FIELDS
    CAST([Work Orders].SlaEstimatedResponseDate AS DATETIME) AS "Est Response Date",
    CAST([Work Orders].SlaActualResponseDate AS DATETIME) AS "Act Response Date",
    CASE WHEN [Work Orders].SlaResponsePastDue = 'True' THEN 'Overdue' 
        WHEN [Work Orders].SlaResponsePastDue = 'False' THEN 'On Time' 
        ELSE NULL END AS "Response Compliance",
    CAST([Work Orders].SlaEstimatedCompletionDate AS DATETIME) AS "Est Completion Date",
    CAST([Work Orders].SlaActualCompletionDate AS DATETIME) AS "Act Completion Date",
    CASE WHEN [Work Orders].SlaCompeletionPastDue = 'True' THEN 'Overdue' 
        WHEN [Work Orders].SlaCompeletionPastDue = 'False' THEN 'On Time' 
        ELSE NULL END AS "Completion Compliance",
    CASE WHEN [Work Orders].SlaResponsePastDue IS NULL OR [Work Orders].SlaCompeletionPastDue IS NULL THEN NULL 
        WHEN [Work Orders].SlaResponsePastDue = 'True' OR [Work Orders].SlaCompeletionPastDue = 'True' THEN 'Overdue' 
        WHEN [Work Orders].SlaResponsePastDue = 'False' AND [Work Orders].SlaCompeletionPastDue = 'False' THEN 'On Time' 
        ELSE NULL END AS "Overall Compliance",
    CASE WHEN [Work Orders].SlaResponsePastDue = 'True' THEN 0 
        WHEN [Work Orders].SlaResponsePastDue = 'False' THEN 1 
        ELSE NULL END AS "Response On Time Count",
    CASE WHEN [Work Orders].SlaCompeletionPastDue = 'True' THEN 0 
        WHEN [Work Orders].SlaCompeletionPastDue = 'False' THEN 1 
        ELSE NULL END AS "Completion On Time Count",
    --[Inspections]/CSAT RELATED FIELDS
    Surveys.DuplicateStatusSurveys,
    Surveys.[Survey ID], 
    CASE WHEN Survey_Count = 1 THEN 'Has Survey' ELSE 'No Survey' END AS "Survey Status",
    CASE WHEN Survey_Count = 1 THEN 1 ELSE 0 END AS "Survey Count",
    CONCAT('https://micron.famis360.com/Inspection_Update.asp?InspectionID=',Surveys.[Survey ID]) AS "FAMIS Survey URL",    
    --[Work Order Comments] RELATED FIELDS
    [Work Order Comments].DuplicateStatusLastComment,
    [Work Order Comments].[Last Comment Datetime],
    [Work Order Comments].[Last Comment],   
    --CUSTOM FIELDS        
    FORMAT(CONVERT(date, [Work Orders].CreateDate), 'yyyy-MM') AS "Date Year Month",
    CASE WHEN [Work Orders].SlaEstimatedCompletionDate = null THEN CAST([Work Orders].CompleteByDate AS DATETIME)
        WHEN [Work Orders].CompleteByDate > [Work Orders].SlaEstimatedCompletionDate THEN CAST([Work Orders].SlaEstimatedCompletionDate AS DATETIME)
        ELSE CAST([Work Orders].CompleteByDate AS DATETIME) END AS ECD,
    CONCAT([Request Types].Description, ' - ', [Request SubTypes].Description) AS "Ticket Item",
    CASE WHEN [Origination Codes].Description = 'Inspection' OR [Origination Codes].Description = 'Internal Team' OR [Origination Codes].Description = 'Scheduled - PPM' THEN 'Proactive'
        WHEN [Origination Codes].Description = 'Behalf of Customer - Email' OR [Origination Codes].Description = 'Behalf of Customer - Phone' OR [Origination Codes].Description = 'Behalf of Customer - Verbal' OR [Origination Codes].Description = 'Self Service' THEN 'Reactive'
        ELSE 'Ignore' END AS "Proactive",
    CASE WHEN [Origination Codes].Description = 'Inspection' OR [Origination Codes].Description = 'Internal Team' OR [Origination Codes].Description = 'Scheduled - PPM' THEN 1
        WHEN [Origination Codes].Description = 'Behalf of Customer - Email' OR [Origination Codes].Description = 'Behalf of Customer - Phone' OR [Origination Codes].Description = 'Behalf of Customer - Verbal' OR [Origination Codes].Description = 'Self Service' THEN 0
        ELSE NULL END AS "Proactive Count",        
    CASE WHEN LOWER(RTRIM(LTRIM(Spaces.Name))) LIKE '%cwe%' THEN 'Critical'
        WHEN LOWER(RTRIM(LTRIM(Spaces.Name))) LIKE '%gel%' THEN 'Critical'
        WHEN LOWER(RTRIM(LTRIM(Assets.Description))) LIKE '%cwe%' THEN 'Critical'
        ELSE 'Non-Critical' END AS "Critical Workspaces",
    CASE WHEN [Request Priorities].Name LIKE 'Scheduled (end of%' THEN 'PM'
        ELSE 'Non-PM' END AS "PM Tickets",
    CONCAT('https://micron.famis360.com/LB_Request_Update.asp?RequestID=',[Work Orders].Id) AS "FAMIS WO URL"                    
FROM [Work Orders]
    LEFT JOIN Properties ON Properties.Id = [Work Orders].PropertyId
    LEFT JOIN Spaces ON Spaces.Id = [Work Orders].SpaceId
    LEFT JOIN Departments ON Departments.Id = [Work Orders].DepartmentId
    LEFT JOIN Assets ON Assets.Id = [Work Orders].AssetId
    LEFT JOIN [Failure Codes] ON [Failure Codes].Id = [Work Orders].FailureCodeId
    LEFT JOIN [Request Types] ON [Request Types].Id = [Work Orders].RequestTypeId
    LEFT JOIN [Request SubTypes] ON [Request SubTypes].Id = [Work Orders].RequestSubTypeId
    LEFT JOIN [Request Priorities] ON [Request Priorities].Id = [Work Orders].RequestPriorityId
    LEFT JOIN [Request Statuses] ON [Request Statuses].Id = [Work Orders].StatusId
    LEFT JOIN Users AS UsersA ON UsersA.Id = [Work Orders].AssignedToId
    LEFT JOIN Users AS UsersC ON UsersC.Id = [Work Orders].CreatedById
    LEFT JOIN [Origination Codes] ON [Origination Codes].Id = [Work Orders].OriginationCodeId
    LEFT JOIN --custom subquery for [Work Ofder Comments] prone to RequestId duplicates
(SELECT DISTINCT
    CASE WHEN Subquery4.CountRequestId > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusLastComment,
    Subquery4.*
FROM 
(SELECT DISTINCT
    COUNT(*) OVER (PARTITION BY SubQuery3.RequestId) AS CountRequestId,
    Subquery3.*
FROM
--Subquery3
(SELECT DISTINCT 
    Subquery2.RequestId,
    SubQuery1.UpdateDate AS "Last Comment Datetime",
    STRING_AGG(Subquery2.RequestDetailDescription, ' :: ') AS "Last Comment"
FROM [Work Order Comments] AS Subquery2
LEFT JOIN 
--SubQuery1
(SELECT DISTINCT
    RequestId, 
    MAX(UpdateDate) AS "UpdateDate"
FROM [Work Order Comments]
GROUP BY RequestId) 
AS SubQuery1
ON Subquery2.RequestId = SubQuery1.RequestId AND Subquery2.UpdateDate = SubQuery1.UpdateDate
WHERE SubQuery1.UpdateDate IS NOT NULL
GROUP BY Subquery2.RequestId, SubQuery1.UpdateDate)
AS Subquery3)
AS Subquery4)
AS [Work Order Comments] ON [Work Order Comments].RequestId = [Work Orders].Id
    LEFT JOIN --custom subquery for [Inspections] prone to RequestId duplicates
(SELECT
    CASE WHEN SubQuery1.CountRequestId > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusSurveys,
    SubQuery1.*
FROM 
--SubQuery1
(SELECT DISTINCT
    COUNT(*) OVER (PARTITION BY WorkOrderId) AS CountRequestId,
    1 AS Survey_Count,
    STRING_AGG(Id, ', ') AS "Survey ID",
    WorkOrderId
FROM Inspections
WHERE InspectionClassId = 7
GROUP BY WorkOrderId)
AS SubQuery1)
AS Surveys ON Surveys.WorkOrderId = [Work Orders].Id
    LEFT JOIN --custom subquery for [Purchase Order Lines] prone to RequestId duplicates
(SELECT
    CASE WHEN SubQueryPOL2.CountRequestId > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusPurchaseOrderLines,
    SubQueryPOL2.*
FROM
--SubQueryPOL2
(SELECT
    COUNT(*) OVER (PARTITION BY SubQueryPOL1.RequestId) AS CountRequestId,
    SubQueryPOL1.*
FROM 
--SubQueryPOL1
(SELECT 
    RequestId,
    STRING_AGG(PONumber, ', ') AS PONumberList
    FROM [Purchase Order Lines]
    GROUP BY RequestId) 
AS SubQueryPOL1)
AS SubQueryPOL2) 
AS [Purchase Order Lines] ON [Purchase Order Lines].RequestId = [Work Orders].Id      
    LEFT JOIN --custom subquery for [Labor Costs] prone to Request ID duplicates
(SELECT DISTINCT
    CASE WHEN SubQueryLC2.CountRequestID > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusLaborCosts,
    SubQueryLC2.*
FROM
--SubQueryLC2
(SELECT DISTINCT
    COUNT(*) OVER (PARTITION BY SubQueryLC1.RequestId) AS CountRequestID,
    SubQueryLC1.*
FROM 
--SubQueryLC1
(SELECT DISTINCT
    RequestID,
    SUM(TRY_CAST([Labor Costs].Hours AS DECIMAL(10, 2))) OVER() AS "Labor Hours",
    SUM(TRY_CAST([Labor Costs].ApTaxAmount AS DECIMAL(10, 2))) OVER() AS "AP Tax",
    SUM(TRY_CAST([Labor Costs].ApShippingHandlingAmount AS DECIMAL(10, 2))) OVER() AS "AP S&H",
    SUM(TRY_CAST([Labor Costs].TotalAmount AS DECIMAL(10, 2))) OVER() AS "Total Amount"
FROM [Labor Costs]) 
AS SubQueryLC1)
AS SubQueryLC2) 
AS [Labor Costs] ON [Labor Costs].RequestId = [Work Orders].Id
) AS SubQuery1
) AS SubQuery2 
--WHERE SubQuery2.[Survey ID] IS NOT NULL
ORDER BY DuplicateStatusworkOrders DESC
--CHANGE LOG
--Justys Renegado (2024.12.26): added AssetId field
--Justys Renegado (2024.12.23): added fields: [Inspections]/CSAT RELATED FIELDS and [Work Order Comments] RELATED FIELDS
--Justys Renegado (2024.12.18): this query was modeled after the FAMIS Request Summary report within the Export Folder
    --(cont.) Export Folder https://microncorp.sharepoint.com/:f:/r/sites/GWREF-BIZOPS/BizOps/Reporting%20%26%20Analytics/1.1%20Business%20Intelligence%20Team/Exported%20Reports/FAMIS?csf=1&web=1&e=BqIz7U
    --(cont.) [REMOVED] indicates this column was part of the original FAMIS export report but excluded from this API query
