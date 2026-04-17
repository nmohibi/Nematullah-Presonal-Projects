# UghFine — Test Suite Summary

## Overview

This document describes the complete test suite for the UghFine (FitAI) Flutter application. The tests follow the instructor's demo patterns using `flutter_test` and `mockito`.

## Test Files Created

### 1. Model Tests (Unit Tests)

#### `test/models/user_model_test.dart`

Tests for the `UserModel` class covering:

- Property accessors
- `toMap()` serialization
- `fromFirestore()` deserialization
- Handling missing fields with defaults
- `copyWith()` immutable updates
- Round-trip serialization/deserialization

**Test count:** 8 tests
**Pattern:** Arrange-Act-Assert with setUp/tearDown

---

#### `test/models/workout_models_test.dart`

Tests for `Exercise`, `WorkoutDay`, and `WorkoutPlan` classes:

**Exercise tests (4 tests):**

- Property accessors
- `toMap()` conversion
- `fromMap()` parsing
- Defaults for missing fields

**WorkoutDay tests (4 tests):**

- Property accessors
- Rest day handling
- Exercise list management
- Round-trip serialization

**WorkoutPlan tests (3 tests):**

- Property accessors
- Firestore conversion
- Round-trip serialization

**Test count:** 11 tests

---

#### `test/models/diet_model_test.dart`

Tests for `Meal`, `DietDay`, and `DietPlan` classes:

**Meal tests (6 tests):**

- Property accessors
- `toMap()` conversion
- `fromMap()` parsing
- `copyWith()` for completion toggle
- Default values

**DietDay tests (4 tests):**

- Property accessors
- Rest day with empty meals
- Firestore conversion
- Meal list management

**DietPlan tests (3 tests):**

- Property accessors
- Firestore conversion
- Round-trip serialization

**Test count:** 13 tests

---

### 2. Provider Tests (State Management Tests)

#### `test/providers/workout_provider_test.dart`

Tests for `WorkoutProvider` ChangeNotifier:

- Initialization state
- `setWorkoutPlan()` storage and notification
- `selectedDay` getter
- `selectDay()` navigation
- Boundary checking
- Listener notifications

**Test count:** 8 tests
**Pattern:** Mock listeners, test state changes, verify notifications

---

#### `test/providers/diet_provider_test.dart`

Tests for `DietProvider` ChangeNotifier:

- Initialization state
- `setDietPlan()` storage and notification
- `selectedDay` getter
- `selectDay()` with bounds validation
- `toggleMeal()` with async Firestore call
- Data preservation during updates
- Listener notifications

**Test count:** 11 tests
**Pattern:** Mock FirestoreService, test async operations, verify state updates

---

### 3. Widget Tests (UI Tests)

#### `test/screens/about_widget_test.dart`

Tests for `AboutScreen`:

- Title display
- Subtitle display
- Description text
- Get Started button
- Fitness center icon
- Animation completion
- Opacity after animation
- Gradient background
- Button tappability

**Test count:** 10 tests
**Pattern:** `testWidgets()`, `pumpWidget()`, `pumpAndSettle()`, Finders and Matchers

---

#### `test/screens/login_widget_test.dart`

Tests for `LoginScreen`:

- AppBar title
- Tab navigation (Login/Register)
- Input fields (email, password)
- Continue button
- Error message display
- Loading spinner
- Button disabled state during loading
- Text input acceptance
- Form validation

**Test count:** 11 tests
**Pattern:** Mock UserProvider, test interactive elements, verify UI state changes

---

## Test Organization

### Folder Structure

```
test/
├── models/
│   ├── user_model_test.dart
│   ├── workout_models_test.dart
│   └── diet_model_test.dart
├── providers/
│   ├── workout_provider_test.dart
│   └── diet_provider_test.dart
└── screens/
    ├── about_widget_test.dart
    └── login_widget_test.dart
```

## Running the Tests

### Run all tests

```bash
flutter test
```

### Run with expanded output

```bash
flutter test -r expanded
```

### Run a specific test file

```bash
flutter test test/models/user_model_test.dart
```

### Run tests matching a pattern

```bash
flutter test --name "should have readable"
```

## Test Statistics

| Category        | Count  |
| --------------- | ------ |
| Model Tests     | 32     |
| Provider Tests  | 19     |
| Widget Tests    | 21     |
| **Total Tests** | **72** |

## Testing Patterns Used

### 1. Unit Tests (Models)

- **setUp():** Create fresh instances before each test
- **Arrange-Act-Assert:** Clear test structure
- **Mocking:** FirestoreService with mockito
- **Assertions:** expect() for exact matches

### 2. Provider Tests

- **ChangeNotifier listeners:** Count notifications
- **Mock services:** Prevent actual Firebase calls
- **State verification:** Check fields after operations
- **Async testing:** await for Future operations

### 3. Widget Tests

- **testWidgets():** Access to WidgetTester
- **MaterialApp wrapper:** Proper test environment
- **Finders:** find.text(), find.byType(), find.byIcon()
- **Matchers:** findsOneWidget, findsWidgets, findsNothing
- **User interactions:** tester.tap(), tester.enterText()
- **Frame pumping:** pumpWidget(), pumpAndSettle()

## Coverage Areas

✅ **Models:** All CRUD-like operations, serialization, defaults, immutability
✅ **Providers:** State initialization, updates, listeners, async operations
✅ **Screens:** Display, user input, navigation, loading states, errors

## Notes for Junior Developer

These tests follow the exact patterns from the instructor's `test_example` demo:

1. **Use groups** to organize related tests
2. **Use descriptive test names** with "should" verbs
3. **Use setUp/tearDown** to manage test state
4. **Mock external dependencies** (Firebase, services)
5. **Test behaviors, not implementation** — focus on what the code does, not how
6. **Keep tests simple** — each test should verify one thing
7. **Use matchers** to make assertions readable

## Dependencies

These tests require:

- `flutter_test` (built-in)
- `mockito: ^5.4.4` (already in pubspec.yaml)
- `build_runner: ^2.4.13` (already in pubspec.yaml)

To generate mockito code:

```bash
flutter pub run build_runner build
```

## Future Test Additions

Night 6 could be expanded to include:

- Integration tests for full user flows (register → questions → dashboard)
- Widget tests for WorkoutScreen and DietScreen
- Service tests for FirestoreService and AiService
- Performance tests for large workout/diet plans
