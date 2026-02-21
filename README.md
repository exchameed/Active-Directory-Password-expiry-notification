[README.md](https://github.com/user-attachments/files/25457314/README.md)
# Active Directory Password Expiry Notification Script

## Overview

This PowerShell script monitors Active Directory user accounts and
automatically sends email notifications to users whose passwords are
approaching expiration.

It is designed for on-premises Active Directory environments using the
ActiveDirectory PowerShell module.

------------------------------------------------------------------------

## Purpose

-   Prevent unexpected user lockouts\
-   Reduce password-expiry related Service Desk tickets\
-   Improve operational efficiency\
-   Strengthen password governance compliance

------------------------------------------------------------------------

## Requirements

-   Domain-joined server or management workstation\
-   ActiveDirectory PowerShell module\
-   Read permission on target OUs\
-   Internal SMTP relay access\
-   Service account for scheduled execution

------------------------------------------------------------------------

## How It Works (Technical Flow)

1.  Queries enabled users from specified OUs\
2.  Excludes:
    -   Disabled accounts\
    -   PasswordNeverExpires accounts\
    -   Accounts without email addresses\
3.  Reads attribute:
    -   msDS-UserPasswordExpiryTimeComputed\
4.  Calculates remaining days to expiration\
5.  Sends email notification if expiry is within configured threshold

------------------------------------------------------------------------

## Key Configuration Parameters

### Expiry Notification Threshold

``` powershell
$DaysBeforeExpire = 7
```

Defines how many days before expiration the notification should be
triggered.

### Target Organizational Units

``` powershell
$OUs = @(
    "OU=Information Systems Department,DC=yourdomain,DC=com"
)
```

### SMTP Configuration

``` powershell
$SmtpServer = "smtp.yourdomain.local"
$From = "ITSupport@yourdomain.com"
```

------------------------------------------------------------------------

# IMPORTANT -- Automation Requirement

This script **must be configured in Windows Task Scheduler** for
automated daily execution.

### Recommended Configuration

-   Run daily (e.g., 7:00 AM)\
-   Run whether user is logged on or not\
-   Use a dedicated service account\
-   Enable "Run with highest privileges"

**Action Configuration:**

-   Program/script: `powershell.exe`\

-   Arguments:

        -ExecutionPolicy Bypass -File "C:\Scripts\Get-PasswordExpiry.ps1"

Automation ensures:

-   Continuous monitoring\
-   Zero manual intervention\
-   Consistent password expiry reminders\
-   Reduced operational overhead

------------------------------------------------------------------------

## Security & Governance Notes

-   Read-only against Active Directory\
-   Does not expose password values\
-   Supports enterprise password policy enforcement\
-   Suitable for audit-controlled environments

------------------------------------------------------------------------
