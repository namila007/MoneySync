# Create Now Flow

```mermaid
flowchart TD
    Start([Inbox]) --> TapMessage[Tap Message]
    TapMessage --> ReviewPanel[Review Transaction Panel]

    ReviewPanel --> ReadFields[Read Dropdown Values]
    ReadFields --> CheckKind{Kind Correct?}
    CheckKind -->|No| FixKind[Set Kind from SMS]
    CheckKind -->|Yes| CheckDirection{Direction Correct?}
    FixKind --> CheckDirection

    CheckDirection -->|No| FixDirection[Set Direction from SMS]
    CheckDirection -->|Yes| CheckAccount{Account Selected?}
    FixDirection --> CheckAccount

    CheckAccount -->|No| SelectAccount[Select TEST_ACCOUNT]
    CheckAccount -->|Yes| EnterAmount[Enter Amount]
    SelectAccount --> EnterAmount

    EnterAmount --> SelectCategory[Select Category]
    SelectCategory --> PickDate[Pick Date]
    PickDate --> AddNote[Add Note]

    AddNote --> TapCreate[Tap Create Record]
    TapCreate --> Submitting[Creating...]
    Submitting --> Success{HTTP 200 OK?}

    Success -->|Yes| VerifyLogs[Verify Logs]
    Success -->|No| Error[Error: Create Failed]

    VerifyLogs --> VerifyCounts[Verify Home Counts]
    VerifyCounts --> Done([Create Now Complete])

    style Start fill:#e8f5e9
    style Done fill:#c8e6c9
    style Error fill:#ffcdd2
    style Submitting fill:#fff3e0
    style ReviewPanel fill:#e3f2fd
```

## Step Details

| Step | Script | Action | Output |
|------|--------|--------|--------|
| 1 | `step_inbox_tap_message.sh [text]` | Open message | `screen=review_panel` |
| 2 | `step_read_dropdowns.sh` | Read fields | `dropdown=kind`, `current_value=` |
| 3 | `step_select_dropdown.sh kind income` | Set kind | `status=selected` |
| 4 | `step_select_dropdown.sh direction credit` | Set direction | `status=selected` |
| 5 | `step_review_select_account.sh` | Pick TEST_ACCOUNT | `account=TEST_ACCOUNT` |
| 6 | Type amount | Enter value | — |
| 7 | `step_select_dropdown.sh category "All Income"` | Pick category | `status=selected` |
| 8 | `step_select_dropdown.sh date` | Pick date | `status=selected` |
| 9 | `step_review_create_now.sh` | Create record | `result=success` |
| 10 | `step_home_counts.sh` | Verify counts | `{"success":N}` |
| 11 | `step_log_check.sh` | Verify logs | `found=true` |

## SMS to Field Mapping

| SMS Pattern | Kind | Direction |
|-------------|------|-----------|
| "credited with" | income | credit |
| "debited from" | expense | debit |
| "transferred" | transfer | neutral |
