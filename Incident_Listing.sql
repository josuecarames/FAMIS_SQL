--Primary Author Justys Renegado
--Last Reviewed and Approved by Peer: Josue Carames 2025.01.06 (timestamp should not be less than the last Change Log timestamp)
--Purpose: this query extacts FAMIS data using [Incident] as the primary table
SELECT DISTINCT
    CASE WHEN SubQuery2.CountIncidentId > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusIncidents,
    SubQuery2.*
FROM 
--SubQuery2
(SELECT DISTINCT
    CASE WHEN SubQuery1.[Count Check: Source] = SubQuery1.[Count Check: Final] THEN 'Yes' ELSE 'No' END "Count Check Status",
    COUNT(*) OVER (PARTITION BY SubQuery1.[Incident ID]) AS CountIncidentId,
    SubQuery1.*
FROM 
--SubQuery1
(SELECT DISTINCT 
     --STANDARD CUSTOM FIELDS
    'Incidents' AS "Source.Name",
    (SELECT COUNT(*) FROM [Incidents]) AS "Count Check: Source",
    COUNT(*) OVER () AS "Count Check: Final",
    1 AS Row_Count,
    --FIELDS FROM THE INCIDENT LISTING REPORT
    Incidents.Id AS "Incident ID",
    CAST(Incidents.CreateDate AS DATE) AS "Create Date",
    --[REMOVED] AS "Create Time",
    [Properties].Name AS "Property",
    --[REMOVED] AS "Address 1",
    --[REMOVED] AS "Address 2",
    --[REMOVED] AS "City",
    --[REMOVED] AS "State/Province",
    --[REMOVED] AS "Country",
    --[REMOVED] AS "Zip Code",
    'IncidentTypeId' AS "Type",
    'IncidentSubtypeId' AS "SubType",
    'CONCAT(IncidentTypeId : IncidentSubtypeId)' AS "Ticket Item",
    CAST(Incidents.IncidentDate AS DATE) AS "Start Date",
    --[REMOVED] AS "Time",
    CAST(Incidents.IncidentEndDate AS DATE) AS "End Date",
    --[REMOVED] AS "Time",
    'Pending' AS "Duration",
    'RootCauseId' AS "Root Cause",
    Incidents.Other AS "Other",
    LTRIM(RTRIM(CONCAT('Description 1: ', Incidents.IncidentDescription1))) AS "Incident Description I",
    LTRIM(RTRIM(CONCAT('Description 2: ', Incidents.IncidentDescription2))) AS "Incident Description II",
    LTRIM(RTRIM(CONCAT('Description 3: ', Incidents.IncidentDescription3))) AS "Incident Description III",
    CONCAT(LTRIM(RTRIM(CONCAT('Description 1: ', Incidents.IncidentDescription1))),' // ',LTRIM(RTRIM(CONCAT('Description 2: ', Incidents.IncidentDescription2))),' // ',LTRIM(RTRIM(CONCAT('Description 3: ', Incidents.IncidentDescription3)))) AS "Description",   
    Incidents.RootCauseInvestigation AS "Root Cause Investigation",
    Incidents.ExternalIncidentId AS "External Incident ID",
    'StatusId' AS "Incident Status",
    Incidents.AssetId,
    --CUSTOM FIELDS
    FORMAT(CONVERT(date, Incidents.IncidentDate), 'yyyy-MM') AS "Date Year Month",
    CONCAT('https://micron.famis360.com/Incident_Update.asp?IncidentID=',Incidents.Id) AS "FAMIS Incident URL",    
    CONCAT('https://micron.famis360.com/LB_Request_Update.asp?RequestID=',Incidents.ExternalIncidentId) AS "FAMIS WO URL"
FROM Incidents
    LEFT JOIN Properties ON Properties.Id = Incidents.PropertyId
) AS SubQuery1
) AS SubQuery2
ORDER BY DuplicateStatusIncidents DESC
--CHANGE LOG
--Justys Renegado (2024.12.26): this query was modeled after the FAMIS Incident_Listing report within the Export Folder
    --(cont.) Export Folder https://microncorp.sharepoint.com/:f:/r/sites/GWREF-BIZOPS/BizOps/Reporting%20%26%20Analytics/1.1%20Business%20Intelligence%20Team/Exported%20Reports/FAMIS?csf=1&web=1&e=BqIz7U
    --(cont.) [REMOVED] indicates this column was part of the original FAMIS export report but excluded from this API query
