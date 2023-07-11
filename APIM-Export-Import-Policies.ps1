$apimServiceName = "XXXX"
$resourceGroupName = "XXXX"

# Create APIM context
$context = New-AzApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $apimServiceName


$allAPIs = Get-AzApiManagementApi -Context $context
$exportPath = './apis/'
mkdir $exportPath

foreach ($API in $allAPIs)
{
    Write-Host $API
    
    
    $APIPath = $exportPath + $API.Name + '/'
    mkdir $APIPath

    $APIExportPath = $APIPath + $API.Name + '.json'

    Export-AzApiManagementApi -Context $context -ApiId $API.ApiId -SpecificationFormat OpenApiJson -SaveAs $APIExportPath

    #save API level inbound policy 
    $API_policy =[xml]@(Get-AzApiManagementPolicy -Context $context -ApiId $API.ApiId)
    $inBoundPolicyContent = $API_policy.policies.inbound.OuterXml
    New-Item -Path $APIPath -Name 'inbound.xml' -value $inBoundPolicyContent 
    #save API level inbound policy end
    $allOpers = Get-AzApiManagementOperation  -Context $context -ApiId $API.ApiId
    foreach($oper in $allOpers){
        $operPath  =  $APIPath +$oper.Method + '-' + $oper.Name
        mkdir $operPath
        $policies =[xml]@(Get-AzApiManagementPolicy -Context $context -ApiId $oper.ApiId -OperationId $oper.OperationId)

        New-Item -Path $operPath -Name 'api-policy.xml' -value $policies.OuterXml

        <#
        foreach ($policy in $policies.policies)
        {
            Write-Host $policy.OuterXml
        }        

        $inBoundPolicyContent = $policy.policies.inbound.OuterXml
        New-Item -Path $operPath -Name 'inbound.xml' -value $inBoundPolicyContent 

        $backendPolicyContent = $policy.policies.backend.OuterXml
        New-Item -Path $operPath -Name 'backend.xml' -value $backendPolicyContent 

        $outboundPolicyContent = $policy.policies.outbound.OuterXml
        New-Item -Path $operPath -Name 'outbound.xml' -value $outboundPolicyContent 

        $onerrorPolicyContent = $policy.policies.onerror.OuterXml
        New-Item -Path $operPath -Name 'onerror.xml' -value $onerrorPolicyContent  #>

        <#
        New-AzApiManagementApi -Context $context -Name "Test api" -ServiceUrl "<<api-url>>" -Protocols @("http", "https") -Path "testapi"

        Import-AzApiManagementApi -Context $context -ApiId "<<api-id>>" -SpecificationFormat "OpenApiJson" -SpecificationPath "<<Pathy-To-OpenAI-JSON>>" -Path "testapi"

        Set-AzApiManagementPolicy -Context $context -ApiId "<<api-id>>" -OperationId "<<operation-id>>" -PolicyFilePath "<<Pathy-To-API-Operation-Policy-xml>>"
        #>
    }
}

