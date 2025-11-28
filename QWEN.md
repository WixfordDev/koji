## Qwen Added Memories
- Koji-1 Flutter Application - Code Structure Analysis:

## Overall Architecture:
- **Architecture Pattern:** MVVM/MVC with GetX for state management
- **Navigation:** GoRouter for navigation with centralized routing
- **State Management:** GetX (Get) for controllers and reactive state
- **API Communication:** Custom ApiClient with http package
- **Dependency Injection:** Get lazyPut with DependencyInjection class

## Project Structure:
```
lib/
├── constants/           # App constants (colors)
├── controller/          # GetX Controllers (auth, admin)
├── core/               # Core app constants and exceptions
├── features/           # Feature-based modules (auth, admin, employee)
├── global/             # Global assets
├── helpers/            # Utility functions (prefs, toast, DI)
├── models/             # Data models (admin, attendance)
├── routes/             # Routing configuration
├── services/           # API services and business logic
├── shared_services/    # Shared services (theme)
└── shared_widgets/     # Reusable UI components
```

## Key Features:
1. **Authentication System:**
   - Complete auth flow: sign up, login, verify email, forgot/reset password
   - JWT token management with shared preferences
   - Role-based navigation (admin/employee)

2. **Admin Dashboard:**
   - Attendance management with summary statistics
   - Task creation system with departments, categories, services
   - Employee assignment for tasks

3. **Attendance System:**
   - Clock-in/clock-out functionality
   - Attendance tracking and reporting

4. **Task Management:**
   - Create, assign, and track tasks
   - Service selection with quantity and pricing
   - Priority and difficulty levels

## Technical Implementation:
- **API Client:** Comprehensive HTTP client with multipart support
- **Models:** JSON serialization/deserialization for data mapping
- **Controllers:** Reactive state management with Rx observables
- **UI:** ScreenUtil for responsive design, reusable widgets
- **Storage:** SharedPreferences for local persistence
- **Real-time:** Socket.IO for live communication
- **Notifications:** FCM integration

## UI Components:
- Custom reusable widgets (buttons, text fields, dropdowns)
- Responsive design with Flutter ScreenUtil
- Material Design components with custom theming

The app is well-structured with separation of concerns, proper state management, and follows Flutter best practices.
