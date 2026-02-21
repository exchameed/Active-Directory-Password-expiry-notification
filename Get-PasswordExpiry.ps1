Import-Module ActiveDirectory

# =========================
# CONFIGURATION
# =========================

$DaysBeforeExpire = 7 # Specific the days to filter accounts which password going to expire in mentioned no. of days
$Today = (Get-Date)
$EndDate = $Today.AddDays($DaysBeforeExpire)

# Your OU
$OUs = @(
    <"OU1">,<"OU2"> # Specify 1 or more OU's distinguish name
)

# SMTP Settings
$SmtpServer = <"Your SMTP Host Name / IP">   # Change if needed
$From = <"Your prefered SMTP address">   # Change if needed

# =========================
# SCRIPT
# =========================

foreach ($OU in $OUs) {

    Write-Host "Checking OU: $OU"

    $Users = Get-ADUser -SearchBase $OU `
        -Filter {
            Enabled -eq $true -and
            PasswordNeverExpires -eq $false
        } `
        -Properties DisplayName,
                    EmailAddress,
                    msDS-UserPasswordExpiryTimeComputed,
                    AccountExpirationDate

    foreach ($User in $Users) {

        # Skip if account expiration date exists AND already passed
        if ($User.AccountExpirationDate -and 
            $User.AccountExpirationDate -lt $Today) {
            continue
        }

        # Get computed password expiry date
        if ($User.'msDS-UserPasswordExpiryTimeComputed') {

            $ExpiryDate = [datetime]::FromFileTime(
                $User.'msDS-UserPasswordExpiryTimeComputed'
            )

            # Check if password expires within next 15 days
            if ($ExpiryDate -ge $Today -and $ExpiryDate -le $EndDate) {

                # Skip if no email address
                if (-not [string]::IsNullOrWhiteSpace($User.EmailAddress)) {

                    $DaysLeft = ($ExpiryDate.Date - $Today.Date).Days

$Body = @"
Dear $($User.DisplayName),

Your domain password will expire in $DaysLeft day(s).

Password Expiration Date: $($ExpiryDate.ToString("dddd, dd MMMM yyyy"))

Please change your password before it expires to avoid login issues.

If you need assistance, please contact IT Support.

Regards,
Service Desk
"@

                    try {
                        Send-MailMessage `
                            -To $User.EmailAddress `
                            -From $From `
                            -Subject "Password Expiry Notification – $DaysLeft Day(s) Remaining" `
                            -Body $Body `
                            -SmtpServer $SmtpServer

                        Write-Host "Email sent to $($User.EmailAddress)"
                    }
                    catch {
                        Write-Warning "Failed to send email to $($User.EmailAddress)"
                    }
                }
            }
        }
    }
}

Write-Host "Password expiry check completed."
