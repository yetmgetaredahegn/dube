# Dube Credit Management App — SDLC Deliverables

## 1. Problem Analysis & User Study
### Context
Local shopkeepers and mini-markets in the region often provide goods on credit to regular customers. This "informal credit" is traditionally managed in physical notebooks (Kiray/Dube books), leading to several pain points:
- **Data Loss:** Notebooks can be lost, damaged, or stolen.
- **Inaccuracy:** Errors in manual calculations.
- **Limited Visibility:** Difficult to see total outstanding debt or aging analysis at a glance.
- **Dispute Potential:** Lack of transparent transaction history leads to disagreements with customers.

### User Behaviors & Informal Workflows
- **Small, Frequent Transactions:** Customers often take items worth 5–100 ETB multiple times a day.
- **Partial Payments:** Customers rarely clear the full balance at once; they make small payments whenever they have cash.
- **Trust-Based:** The system is built on personal relationships, but credit limits are informally enforced based on "vibe."

---

## 2. Technical Architecture
### Ledger-First Design (Critical)
To ensure 100% data integrity, the app **does not store a 'balance' field** in Firestore. 
- The balance is a **derived value** calculated by the `LedgerService` from the transaction history.
- This prevents "race conditions" where the balance might be updated but the transaction fails to log.

### Pluggable Integration Layer
The architecture is designed to be vendor-neutral:
- **Auth:** Supports Firebase Auth, extensible to Clerk or custom providers.
- **Notifications:** Interface-driven (`NotificationService`), currently using FCM but ready for Twilio (SMS) or SendGrid (Email).

---

## 3. Edge Cases & Constraints
### Handling Credit Limits
- The app enforces strict credit limits at the service layer (`LedgerService.addCredit`).
- If a shopkeeper tries to add credit that exceeds the limit, the transaction is blocked with a clear UI error message.

### Offline Resilience
- Firestore's local persistence allows shopkeepers to record transactions even with spotty internet. Data syncs automatically once the connection is restored.

---

## 4. Implementation Status (Phase A–E)
- **Phase A (Foundation):** Auth and Navigation Shell completed.
- **Phase B (Customers):** Real-time customer management with search and balance badges.
- **Phase C (Transactions):** Credit/Payment ledger with utilization tracking.
- **Phase D (Insights):** Dashboard stats and Aging Analysis reports.
- **Phase E (Polish & Test):** FCM notifications, unit tests for ledger logic, and E2E integration tests.

---

## 5. Verification & Testing Results
- **Unit Tests:** `LedgerService` verified for balance accuracy and aging categorization.
- **Integration Tests:** End-to-end flow (Register → Add Customer → Add Transaction) verified using `integration_test`.
- **Physical Device:** Tested on Samsung M127G for performance and layout responsiveness.
