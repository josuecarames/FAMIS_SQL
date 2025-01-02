--Primary Author Justys Renegado
--Last Reviewed and Approved by Peer: Josue Carames 2025.01.06 (timestamp should not be less than the last Change Log timestamp)
--Purpose: this query extacts FAMIS data using [Users] as the primary table
SELECT DISTINCT
    CASE WHEN SubQuery2.CountUsersId > 1 THEN 'Yes' ELSE 'No' END AS DuplicateStatusUsers,
    SubQuery2.*
FROM 
--SubQuery2
(SELECT DISTINCT
    CASE WHEN SubQuery1.[Count Check: Source] = SubQuery1.[Count Check: Final] THEN 'Yes' ELSE 'No' END "Count Check Status",
    COUNT(*) OVER (PARTITION BY SubQuery1.[User ID]) AS CountUsersId,
    SubQuery1.*
FROM 
--SubQuery1
(SELECT DISTINCT 
     --STANDARD CUSTOM FIELDS
    'Users' AS "Source.Name",
    (SELECT COUNT(*) FROM [Users]) AS "Count Check: Source",
    COUNT(*) OVER () AS "Count Check: Final",
    1 AS Row_Count,
    --FIELDS FROM THE USER SUMMARY REPORT
    Users.Id AS "User ID",
    Users.Name AS "Name",
    --[REMOVED] AS "Address1",
    --[REMOVED] AS "Address2",
    --[REMOVED] AS "City",
    --[REMOVED] AS "State",
    --[REMOVED] AS "Zip",
    --[REMOVED] AS "Country",
    --[REMOVED] AS "Company",
    --[REMOVED] AS "Phone",
    --[REMOVED] AS "Mobile",
    --[REMOVED] AS "Sign Out",
    --[REMOVED] AS "Fax",
    Users.Email AS "E-Mail",
    --[REMOVED] AS "Mobile E-Mail",
    --[REMOVED] AS "Security Profile",
    --[REMOVED] AS "Admin",
    --[REMOVED] AS "Username",
    --[REMOVED] AS "PW Last Updated",
    --[REMOVED] AS "Micron Cost Center",
    --[REMOVED] AS "Title",
    --[REMOVED] AS "Ext Emp ID",
    --[REMOVED] AS "Ext Payroll ID",
    --[REMOVED] AS "Last Login",
    --[REMOVED] AS "REG Rate",
    --[REMOVED] AS "OT Rate",
    --[REMOVED] AS "DT Rate",
    --[REMOVED] AS "Default Property",
    --[REMOVED] AS "Default Space",
    --[REMOVED] AS "Restricted",
    --[REMOVED] AS "Email Group",
    --[REMOVED] AS "Language",
    Users.WorkStatusFlag AS "Status"
FROM Users
) AS SubQuery1
) AS SubQuery2
ORDER BY DuplicateStatusUsers DESC
--CHANGE LOG
--Justys Renegado (2024.12.26): this query was modeled after the FAMIS User_Summary_Report report within the Export Folder
    --(cont.) Export Folder https://microncorp.sharepoint.com/:f:/r/sites/GWREF-BIZOPS/BizOps/Reporting%20%26%20Analytics/1.1%20Business%20Intelligence%20Team/Exported%20Reports/FAMIS?csf=1&web=1&e=BqIz7U
    --(cont.) [REMOVED] indicates this column was part of the original FAMIS export report but excluded from this API query
