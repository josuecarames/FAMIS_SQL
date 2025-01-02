--Primary Author Justys Renegado
--Last Reviewed and Approved by Peer: Josue Carames 2025.01.06 (timestamp should not be less than the last Change Log timestamp)
--Purpose: this query extacts FAMIS data using [Properties] as the primary table
SELECT DISTINCT
    CASE WHEN SubQuery2.CountProperty > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusProperties,
    SubQuery2.*
FROM 
--SubQuery2
(SELECT DISTINCT
    CASE WHEN SubQuery1.[Count Check: Source] = SubQuery1.[Count Check: Final] THEN 'Yes' ELSE 'No' END "Count Check Status",
    COUNT(*) OVER (PARTITION BY SubQuery1.[Property]) AS CountProperty,
    SubQuery1.*
FROM 
--SubQuery1
(SELECT DISTINCT 
     --STANDARD CUSTOM FIELDS
    'Properties' AS "Source.Name",
    (SELECT COUNT(*) FROM [Properties]) AS "Count Check: Source",
    COUNT(*) OVER () AS "Count Check: Final",
    1 AS Row_Count,
    --FIELDS FROM THE PROPERTY MASTER LISTING REPORT
    --[REMOVED] AS "Region 1",
    --[REMOVED] AS "Region 2",
    --[REMOVED] AS "Region 3",
    Properties.Name AS "Property",
    --[REMOVED] AS "Ext Property ID",
    --[REMOVED] AS "Ext Property ID 2",
    --[REMOVED] AS "Address 1",
    --[REMOVED] AS "Address 2",
    --[REMOVED] AS "City",
    --[REMOVED] AS "State/Province",
    --[REMOVED] AS "State/Province Name",
    --[REMOVED] AS "Zip Code",
    --[REMOVED] AS "Country",
    [Property Types].Name AS "Property Type",
    --[REMOVED] AS "Create Date",
    --[REMOVED] AS "Last Updated",
    --[REMOVED] AS "Inactivate Date",
    --[REMOVED] AS "Status",
    Properties.SqFt AS "Size",
    --[REMOVED] AS "COA Primary",
    --[REMOVED] AS "COA Customer",
    --[REMOVED] AS "Sales Tax Group",
    --[REMOVED] AS "Remit To",
    --[REMOVED] AS "Default Contact",
    --[REMOVED] AS "Default Contact Phone",
    --[REMOVED] AS "Default Contact Mobile",
    --[REMOVED] AS "Default Contact Email",
    --[REMOVED] AS "Manager 1",
    --[REMOVED] AS "Manager 1 Phone",
    --[REMOVED] AS "Manager 1 Mobile",
    --[REMOVED] AS "Manager 1 Email",
    --[REMOVED] AS "Manager 2",
    --[REMOVED] AS "Manager 2 Phone",
    --[REMOVED] AS "Manager 2 Mobile",
    --[REMOVED] AS "Manager 2 Email",
    Properties.ExternalId,
    Properties.ExternalId2
FROM Properties
    LEFT JOIN [Property Types] ON [Property Types].Id = Properties.TypeId
) AS SubQuery1
) AS SubQuery2
ORDER BY DuplicateStatusProperties DESC
--CHANGE LOG
--Justys Renegado (2024.12.26): this query was modeled after the FAMIS Property Master Listing report within the Export Folder
    --(cont.) Export Folder https://microncorp.sharepoint.com/:f:/r/sites/GWREF-BIZOPS/BizOps/Reporting%20%26%20Analytics/1.1%20Business%20Intelligence%20Team/Exported%20Reports/FAMIS?csf=1&web=1&e=BqIz7U
    --(cont.) [REMOVED] indicates this column was part of the original FAMIS export report but excluded from this API query
