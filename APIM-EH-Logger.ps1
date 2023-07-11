$apimServiceName = "XXXX"
$resourceGroupName = "XXXX"
$ehNameSpace = "XXXX"
$ehName = "XXXX"


# Create APIM context
$context = New-AzApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $apimServiceName

$ehAccessKey = Get-AzEventHubKey -ResourceGroupName $resourceGroupName -NamespaceName $ehNameSpace -AuthorizationRuleName RootManageSharedAccessKey

New-AzApiManagementLogger -Context $context -LoggerId "APIM-EH-Logger" -Name $ehName -ConnectionString $ehAccessKey.PrimaryConnectionString -Description "Event hub logger with connection string"

<# SELECT BusinessUnitName,SUM(TotalTokens) AS TotalConsumedTokens, System.Timestamp() AS WinEndTime, COUNT(*) AS TotalCallsMade, OpenAIInstanceInvoked
INTO
    [OutputAlias]
FROM [openaichargebackeh] TIMESTAMP BY EventTime  
where businessunitname is not null and OpenAIInstanceInvoked is not null
GROUP BY TumblingWindow( day , 7 ) , BusinessUnitName,  OpenAIInstanceInvoked   #>