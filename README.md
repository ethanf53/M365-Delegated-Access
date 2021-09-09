# M365 Delegated Access
## Completed
### All Tenants
### Specific Licensing
## In Progress
### All Tenants
- Enable MT as technical contact (I don't belive this is possible)
- Alerting
- Disable TNEF to fix WINMAIL.DAT issues
- Disable Focused Inbox
- Exchange Online Protection Setup (EOP)
- Remove contacts as trusted senders
- Disable RTF ( `Set-RemoteDomain -Identity Default -TNEFEnabled $false`)
### Specific licensing
- Encrypted e-mails setup (OME) OME Encryption Info
- Defender for 365 Setup (For Tenants Opting In for Advanced Spam Protection)
- Information Governance Retention Policies  (For Tenants Requiring Mail Archiving)
## Known issues
- No Security and Compliance Center with current permissions (no auditing)
