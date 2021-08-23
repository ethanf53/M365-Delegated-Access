# I do not think it is the best option to run all the commands in one script.
# I will create separate scripts for each command
Connect-MsolService
$token = New-PartnerAccessToken -Module ExchangeOnline
#define the $customers variable
$customers = Get-MsolPartnerContract
$upn = "ethan@macatawatechnologies.com"
Write-Host "Found $($customers.Count) customers for $((Get-MsolCompanyInformation).displayname)."

foreach ($customer in $customers) {
    Write-Host "Running command on $($customer.Name)" -ForegroundColor Green
    $eachToken = New-PartnerAccessToken -RefreshToken $token.RefreshToken -Scopes 'https://outlook.office365.com/.default' -Tenant $customer.TenantId -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716'
    $tokenValue = ConvertTo-SecureString "Bearer $($eachToken.AccessToken)" -AsPlainText -Force
    $eachCredential = New-Object System.Management.Automation.PSCredential($upn, $tokenValue)
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid?DelegatedOrg=$($customer.Name)&BasicAuthToOAuthConversion=true" -Credential $eachCredential -Authentication Basic -AllowRedirection
    Import-PSSession $session -CommandName Set-AdminAuditLogConfig, Enable-OrganizationCustomization, Get-AdminAuditLogConfig, Get-OrganizationConfig -AllowClobber

    #enable organization customization
    $organizationCustomizationStatus = Get-OrganizationConfig
    if($organizationCustomizationStatus.IsDehydrated -eq 'false') {
        Write-Host "Enabling Organization Customization"
        Enable-OrganizationCustomization
     }else {
        Write-Host "Organization Customization already enabled"
     }

    #audit log
    $auditLogStatus = Get-AdminAuditLogConfig
    if($auditLogStatus.UnifiedAuditLogIngestionEnabled -eq 'true') {
        Write-Host "Audit log already enabled"
     }else {
        Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
        Write-Host "Enabling audit log"
     }
    #alerting


    Remove-PSSession $session
}