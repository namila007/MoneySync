# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure with Clean Architecture
- Two build flavors: `privateFull` (SMS-capable) and `playManual` (permission-free)
- Encrypted SQLCipher database with Android Keystore-backed key wrapping
- SMS ingestion and parsing for Sri Lankan banks
- Wallet connection and transaction review workflow
- Activity log for user-facing actions
- Onboarding flow with SMS access disclosure
- App lock with biometric/device authentication
- Background SMS scanning with WorkManager
- Share intent handler for manual message import
- Notification permission handling
- Mapping rule editor for transaction parsing

### Security
- No cleartext traffic allowed
- Read-only SMS access (no SEND_SMS or WRITE_SMS)
- Encrypted database at rest with SQLCipher
- Wallet tokens stored in Android Keystore-backed secure storage
- Source hygiene checks to prevent secrets in codebase
- APK permission audit in CI pipeline
