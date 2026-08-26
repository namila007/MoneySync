# Onboarding Flow

```mermaid
flowchart TD
    Start([Launch App]) --> Welcome[Welcome Screen]
    Welcome -->|tap Next| Privacy[Privacy Explanation]
    Privacy -->|tap Next| SourceSMS[Source SMS Promise]
    SourceSMS -->|tap Next| DeviceProtection[Device Protection]
    DeviceProtection -->|tap Next| PermissionEducation[Permission Education]
    PermissionEducation -->|tap Next| Disclosure[Privacy Disclosure]
    Disclosure -->|tap Next| SMSDisclosure[SMS Access Disclosure]

    SMSDisclosure -->|tap Continue| GrantSMS[Grant SMS Permission]
    SMSDisclosure -->|tap Not Now| SkipSMS[Skip SMS Access]

    GrantSMS --> SMSDecision[SMS Access Decision]
    SkipSMS --> SMSDecision

    SMSDecision -->|tap Finish| Home([Home Screen])

    Home --> Done[Onboarding Complete]

    style Start fill:#e8f5e9
    style Home fill:#e8f5e9
    style Done fill:#c8e6c9
    style GrantSMS fill:#fff3e0
    style SkipSMS fill:#fff3e0
```

## Step Details

| Step | Script | Action | Output |
|------|--------|--------|--------|
| 1 | `step_app_launch.sh` | Launch app | `screen=onboarding` |
| 2-7 | `step_onboard_next.sh` ×6 | Tap Next | `current_step=` |
| 8 | `step_onboard_sms_grant.sh` | Grant SMS | `action=granted_via_adb` |
| 9 | `step_onboard_finish.sh` | Finish | `action=onboarding_complete` |
| 10 | `step_onboard_dismiss_review.sh` | Dismiss | `screen=home` |
