# Establishing a connection to Microsoft Online
Connect-MsolService
$token = New-PartnerAccessToken -Module ExchangeOnline
$customers = Get-MsolPartnerContract
$upn = Read-Host "Please enter your email"
Write-Host "Found $($customers.Count) customers for $((Get-MsolCompanyInformation).displayname)."

# defining the commands that need to be ran per-tenant. Be sure to import the commands you will be using.
foreach ($customer in $customers) {
    Write-Host "Running command on $($customer.Name)" -ForegroundColor Green
    $eachToken = New-PartnerAccessToken -RefreshToken $token.RefreshToken -Scopes 'https://outlook.office365.com/.default' -Tenant $customer.TenantId -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716'
    $tokenValue = ConvertTo-SecureString "Bearer $($eachToken.AccessToken)" -AsPlainText -Force
    $eachCredential = New-Object System.Management.Automation.PSCredential($upn, $tokenValue)
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid?DelegatedOrg=$($customer.Name)&BasicAuthToOAuthConversion=true" -Credential $eachCredential -Authentication Basic -AllowRedirection
    Import-PSSession $session -CommandName Set-AdminAuditLogConfig, Get-AdminAuditLogConfig -AllowClobber

    #define the condition that determines whether or not the command should run
    $tenantQuery = Get-AdminAuditLogConfig

    if($tenantQuery.UnifiedAuditLogIngestionEnabled -eq 'true') {
        Write-Host "Audit log already enabled"
     }else {
        # run the command if it needs to be ran
        Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
        Write-Host "Enabling audit log"
     }
    Remove-PSSession $session
}