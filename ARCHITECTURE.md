# Dube App — Architecture & Implementation Notes

This document captures the recommended, simplified layered + feature-based architecture for the Dube mobile app (credit-management example) and an implementation checklist for the team.

High-level architecture
- UI (Screens / Widgets)
- State (Provider)
- Services (API + business logic)
- Models (data structures)
- Backend (Django REST API)

Key rules
- UI must not call APIs directly — always use services
- Group code by feature (features/customers, features/transactions)

Project structure (core parts)
- `lib/main.dart` — app entry, provider registration
- `lib/core/` — constants, utils, theme
- `lib/shared/services/` — ApiService, AuthService
- `lib/features/<feature>/` — each feature owns its models, services, presentation, provider
- `lib/routes/app_router.dart` — route generator or `go_router` setup

Feature example (`features/customers`)
- `data/models/customer_model.dart`
- `data/services/customer_service.dart`
- `presentation/screens/customers_list_screen.dart`
- `provider/customer_provider.dart`

State management
- Use `provider` with `ChangeNotifier` for simplicity and speed

Networking
- Centralize HTTP in `ApiService` (attach token, parse JSON)
- Use `http` or `dio` depending on team preference

Authentication
- Save token in `shared_preferences`
- `AuthService` handles login/logout and token retrieval for `ApiService`

Essential screens (MVP)
- Login
- Dashboard (summary: total credit, paid, outstanding)
- Customers (list, detail)
- Transactions (add: CREDIT or PAYMENT)
- Reports (customers with balances)

SDLC mapping (course requirements)
- Phase 1: Deep study & interviews — capture 3–5 real scenarios
- Phase 2: Requirements — functional and non-functional
- Phase 3: Design — architecture diagram, ERD, wireframes
- Phase 4: Development — implement features, tests
- Phase 5: Testing — unit, integration, UAT

Next steps (implementation)
1. Add core/shared skeleton (constants, ApiService, AuthService)
2. Implement `Customer` and `Transaction` models
3. Scaffold `customers` and `transactions` features (services, providers, screens)
4. Wire `main.dart` with providers and routing
5. Integrate with Django API and validate flows

Notes
- Keep UI simple: lists, forms, cards
- Avoid heavy patterns (Bloc) and complex animations for MVP
- Add reminders/notifications and offline sync only after core flows are stable
