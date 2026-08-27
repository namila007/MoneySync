# Save for Later Flow

```mermaid
flowchart TD
    Start([Inbox]) --> TapMessage[Tap Message]
    TapMessage --> ReviewPanel[Review Transaction Panel]

    ReviewPanel --> ReadFields[Read Dropdown Values]
    ReadFields --> FixKind[Set Kind from SMS]
    FixKind --> FixDirection[Set Direction from SMS]
    FixDirection --> SelectAccount[Select TEST_ACCOUNT]
    SelectAccount --> EnterAmount[Enter Amount]
    EnterAmount --> SelectCategory[Select Category]
    SelectCategory --> PickDate[Pick Date]
    PickDate --> AddNote[Add Note]

    AddNote --> TapSave[Tap Save for Later]
    TapSave --> Queued[Mutation Queued]

    Queued --> VerifyHome[Verify Waiting=1]
    VerifyHome --> WaitingView[Open Waiting Queue]
    WaitingView --> TapMutation[Tap Mutation]
    TapMutation --> DetailPage[Waiting Detail Page]

    DetailPage --> VerifyFields{Fields Correct?}
    VerifyFields -->|No| EditFields[Edit Fields]
    VerifyFields -->|Yes| TapApprove[Tap Approve]
    EditFields --> TapApprove

    TapApprove --> Approving[Approving...]
    Approving --> Success{HTTP 200 OK?}

    Success -->|Yes| VerifyLogs[Verify Logs]
    Success -->|No| Error[Error: Approve Failed]

    VerifyLogs --> VerifyCounts[Verify Home Counts]
    VerifyCounts --> Done([Save for Later Complete])

    style Start fill:#e8f5e9
    style Done fill:#c8e6c9
    style Error fill:#ffcdd2
    style Queued fill:#fff3e0
    style WaitingView fill:#e3f2fd
    style DetailPage fill:#e3f2fd
```

## Step Details

| Step | Script | Action | Output |
|------|--------|--------|--------|
| 1 | `step_inbox_tap_message.sh [text]` | Open message | `screen=review_panel` |
| 2 | `step_read_dropdowns.sh` | Read fields | `dropdown=kind` |
| 3 | `step_select_dropdown.sh kind income` | Set kind | `status=selected` |
| 4 | `step_select_dropdown.sh direction credit` | Set direction | `status=selected` |
| 5 | `step_review_select_account.sh` | Pick TEST_ACCOUNT | `account=TEST_ACCOUNT` |
| 6 | Type amount | Enter value | — |
| 7 | `step_select_dropdown.sh category "All Income"` | Pick category | `status=selected` |
| 8 | `step_select_dropdown.sh date` | Pick date | `status=selected` |
| 9 | `step_review_save_for_later.sh` | Save for later | `result=queued` |
| 10 | `step_home_counts.sh` | Verify waiting | `{"waiting":1}` |
| 11 | `step_waiting_approve.sh` | Approve | `result=success` |
| 12 | `step_home_counts.sh` | Verify counts | `{"success":N}` |
| 13 | `step_log_check.sh` | Verify logs | `found=true` |

## Waiting Queue States

```mermaid
stateDiagram-v2
    [*] --> Queued: Save for Later
    Queued --> Syncing: Approve tapped
    Syncing --> Succeeded: HTTP 200 OK
    Syncing --> Failed: HTTP error
    Failed --> Queued: Retry (not in E2E)
    Succeeded --> [*]
```
