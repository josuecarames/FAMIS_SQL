SELECT 
    Assets.Name AS "Asset Name", 
    Assets.AssetNumber AS "Asset#",
    Assets.SerialNumber AS "Serial#",
    [Asset Classes].Description AS "Class",
    [Asset Ranks].Description AS "Rank",
    Assets.InServiceDate AS "In-Service Date",
    [Asset Makes].Description AS "Manufacturer",
    [Asset Models].Description AS "Model",
    [Asset Statuses].Name AS "Status",
    Assets.StatusComment AS "Comments",
    Assets.Description AS "Description",
    Assets.WarrantyEffectiveDate AS "Warranty Effective Date",
    Assets.WarrantyExpirationDate AS "Warranty Expiration Date",
    [Properties].[Name] AS "Property",
    Spaces.Name AS "Floor",
    Assets.Room AS "Room",
    Assets.EmployeeName AS "Employee",
    Assets.PurchaseDate AS "Purchase Date",
    Assets.PurchaseAmount AS "Purchase Amount",
    Assets.Comments AS "Asset Comments",
    [Work Orders].DateScheduled AS "Scheduled?", -- review this
    Assets.UpdateDate AS "Last Update",
    Users.Name AS "Updated By",
    Assets.AssetSafetyComments AS "Asset Safety Comments",
    Assets.EstimatedLifeInYears AS "Estimated Life(yrs)"
FROM Assets
LEFT JOIN [Asset Classes] ON [Asset Classes].Id = Assets.AssetClassId
LEFT JOIN [Asset Ranks] ON [Asset Ranks].Id = Assets.AssetRankId
LEFT JOIN [Asset Makes] ON [Asset Makes].Id = Assets.MakeId
LEFT JOIN [Asset Models] ON [Asset Models].Id = Assets.ModelId
LEFT JOIN [Asset Statuses] ON [Asset Statuses].Id = Assets.AssetStatusId
LEFT JOIN Properties ON Properties.Id = Assets.PropertyId
LEFT JOIN Spaces ON Spaces.Id = Assets.SpaceId
LEFT JOIN [Inspections] ON Inspections.AssetId = Assets.Id
LEFT JOIN [Work Orders] ON [Work Orders].Id = Inspections.WorkOrderId
LEFT JOIN Users ON Users.UpdatedById = Assets.UpdatedById
;
