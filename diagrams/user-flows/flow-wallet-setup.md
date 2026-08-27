# Wallet Setup Flow

```mermaid
flowchart TD
    Start([Home Screen]) --> Settings[Tap Settings Gear]
    Settings --> WalletConnection[Wallet Connection Page]

    WalletConnection --> CheckConnected{Already Connected?}
    CheckConnected -->|Yes| ValidateAccount[Validate TEST_ACCOUNT]
    CheckConnected -->|No| EnterToken[Enter API Token]

    EnterToken --> TapSave[Tap Save & Connect]
    TapSave --> Connecting[Connecting...]
    Connecting --> Connected[Connected]

    Connected --> ValidateAccount

    ValidateAccount --> AccountExists{TEST_ACCOUNT Found?}
    AccountExists -->|Yes| Success([Wallet Ready])
    AccountExists -->|No| Missing[Account Missing]

    Missing --> Action[Action Required: Create TEST_ACCOUNT in BudgetBakers]
    Action --> Stop([Stop E2E - User Must Create Account])

    style Start fill:#e8f5e9
    style Success fill:#c8e6c9
    style Stop fill:#ffcdd2
    style Missing fill:#fff3e0
    style ValidateAccount fill:#e3f2fd
```

## Step Details

| Step | Script | Action | Output |
|------|--------|--------|--------|
| 1 | `step_nav_wallet.sh` | Navigate to wallet | `screen=wallet_connection` |
| 2 | `step_wallet_setup.sh [token]` | Enter token | `wallet_status=connected` |
| 3 | `step_wallet_check.sh` | Validate | `test_account=found\|missing` |

## TEST_ACCOUNT Validation

After wallet connects, `step_wallet_check.sh` automatically:
1. Checks if `TEST_ACCOUNT` exists in the account list
2. Scrolls up to 5 times to find it
3. If missing: outputs `test_account=missing` and exits with error
4. Agent must ask user to create the account before proceeding
