# Import Message Flow

```mermaid
flowchart TD
    Start([Home Screen]) --> SeedSMS[Seed SMS on Emulator]
    SeedSMS --> NavigateSettings[Tap Settings Gear]
    NavigateSettings --> HistoryImport[History Import Page]

    HistoryImport --> CheckSenders{Tracked Senders?}
    CheckSenders -->|None| NeedsSenders[ERROR: No tracked senders]
    CheckSenders -->|Senders found| FindMessages[Tap Find Messages]

    FindMessages --> Scanning[Scanning...]
    Scanning --> Results[Scan Complete]

    Results --> GoBack[Go Back to Home]
    GoBack --> Inbox[Tap Inbox Tab]
    Inbox --> Messages[View Messages]

    Messages --> Done[Import Complete]

    style Start fill:#e8f5e9
    style Done fill:#c8e6c9
    style NeedsSenders fill:#ffcdd2
    style Scanning fill:#fff3e0
```

## Step Details

| Step | Script | Action | Output |
|------|--------|--------|--------|
| 1 | `step_sms_seed.sh [sender] [body]` | Seed SMS | `sender=`, `body=` |
| 2 | `step_import_ensure_sender.sh [name]` | Check senders | `status=already_listed` |
| 3 | `step_import_scan.sh` | Run scan | `action=scan_complete` |
| 4 | `step_inbox_open.sh` | Open inbox | `message_count=N` |

## Scan Results

- `stored` — new messages imported
- `not recognised` — SMS not matching any parser
- `already imported` — duplicate messages skipped
