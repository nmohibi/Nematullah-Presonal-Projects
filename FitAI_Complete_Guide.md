# FitAI — Complete Build Guide
### Every file, every concept, explained night by night

---

## The Big Picture Before Any Code

Before writing a single line, answer three questions:

**1. What does the app need to store?**
- A user (name, age, weight, height, goal, gym days, diet preference)
- A workout plan (7 days, each with exercises that have sets/reps)
- A diet plan (7 days, each with meals the user can check off)

**2. Where does data live?**
- Firebase Authentication → handles login/register/logout
- Cloud Firestore → cloud database, stores user profile + plans
- Google Gemini AI → generates the actual plan content
- Provider (in-memory) → fast local state while the app is running

**3. What order do I build things?**

There is a strict order that makes sense. Each layer depends on the one below it:

```
LAYER 4: Screens (what users see)
           ↓ uses
LAYER 3: Providers (in-memory state, business logic)
           ↓ uses
LAYER 2: Services (talks to Firebase / Gemini)
           ↓ uses
LAYER 1: Models (plain Dart classes that describe the shape of data)
```

**You always build bottom-up. Models first. Screens last.**
You only add to a model, service, or provider when a screen actually needs it. Never write code for something you haven't started building yet.

---

## Where the Project Stands Right Now

| File | Status |
|---|---|
| `pubspec.yaml` | ✅ Done |
| `lib/screens/about.dart` | ✅ Done — animated splash screen |
| `lib/screens/login.dart` | ✅ Done — login/register tabs, form, validation |
| `lib/main.dart` | ✅ Done — Firebase init, routes, route guarding |
| `lib/services/auth_service.dart` | ✅ Done — login, register, logout, auth stream |
| `lib/providers/user_provider.dart` | ✅ Done — auth state, login/register methods |
| `lib/models/user_model.dart` | ✅ Minimal — uid + email + hasCompletedOnboarding |
| `lib/providers/workout_provider.dart` | 🔲 Empty stub |
| `lib/providers/diet_provider.dart` | 🔲 Empty stub |
| `lib/services/firestore_service.dart` | 🔲 Empty — to be built Night 3 |
| `lib/services/ai_service.dart` | 🔲 Empty — to be built Night 4 |
| `lib/models/workout_models.dart` | 🔲 Empty — to be built Night 4 |
| `lib/models/diet_model.dart` | 🔲 Empty — to be built Night 4 |
| `lib/screens/questions.dart` | 🔲 Stub — to be built Night 3 |
| `lib/screens/dashboard.dart` | 🔲 Stub — to be built Night 5 |
| `lib/screens/workout.dart` | 🔲 Stub — to be built Night 5 |
| `lib/screens/diet.dart` | 🔲 Stub — to be built Night 5 |

---

## NIGHT 1 — Already Done ✅

**What was built:** `pubspec.yaml`, `about.dart`

### pubspec.yaml — Declaring Dependencies

This is Flutter's package manifest — like a shopping list. You write down every external library your app needs, then run `flutter pub get` to download them.

```yaml
dependencies:
  firebase_core: ^4.4.0     # ALWAYS first — initializes the Firebase connection
  firebase_auth: ^6.1.4     # Handles login/register/logout
  cloud_firestore: ^6.1.2   # The cloud database (stores user data, plans)
  provider: ^6.1.5+1        # State management (same as instructor's demo)
  google_generative_ai: ^0.4.6  # Calls Google Gemini AI

dev_dependencies:
  mockito: ^5.4.4       # Creates fake objects for unit testing
  build_runner: ^2.4.13 # Auto-generates mockito code
```

Why provider? Your instructor taught Provider + ChangeNotifier. Always match your instructor's pattern.

`^4.4.0` means "4.4.0 or higher, but not 5.0.0 or above." The `^` gives you bug fixes but protects you from breaking changes.

### about.dart — Animations

We need `StatefulWidget` because `AnimationController` requires `initState()` to set up, `dispose()` to clean up, and `SingleTickerProviderStateMixin` for vsync.

**vsync** means "only animate when the screen is actually refreshing." Without it, animations run at full CPU speed and drain the battery.

The animation works by driving two tweens off one controller. The controller goes 0.0 → 1.0 over 1.2 seconds. Each tween maps that progress to a real value (opacity 0→1, slide offset 40→0). `AnimatedBuilder` rebuilds the widget on every tick. The `child` parameter is passed in separately so it doesn't get rebuilt every tick — only the `Opacity` and `Transform` wrappers rebuild.

---

## NIGHT 2 — Already Done ✅

**What was built:** `auth_service.dart`, `user_provider.dart` (auth only), `user_model.dart` (minimal), `main.dart`, `login.dart`

### auth_service.dart

Wraps Firebase Auth. One responsibility only — talk to Firebase. All Firebase Auth calls go here, not in providers.

`authStateChanges` is a `Stream<User?>` — a river of events. When the user logs in → stream emits a `User`. When they log out → stream emits `null`. `UserProvider` listens to this stream continuously, so the app always knows the current auth state automatically.

### user_model.dart (minimal)

Right now it only holds what the existing screens need. We expand it on Night 3 when QuestionsScreen needs the extra fields.

### user_provider.dart

Extends `ChangeNotifier` — the same pattern from the instructor's demo (`ApplicationState extends ChangeNotifier`). The constructor calls `_init()` which starts listening to the auth stream immediately. When data changes, call `notifyListeners()` to tell watching widgets to rebuild.

`context.read<T>()` — use in callbacks/methods (read once, don't subscribe).
`context.watch<T>()` — use in `build()` (subscribe and rebuild when data changes).

### main.dart

`WidgetsFlutterBinding.ensureInitialized()` must be called before any async work in `main()`. `MultiProvider` at the root of the widget tree makes all providers available to every widget below. Protected routes live in `onGenerateRoute` — Flutter checks `routes:` first, so anything in `routes:` never reaches `onGenerateRoute`.

### login.dart

`TabController` manages the Login/Register tabs. `GlobalKey<FormState>` lets you call `.validate()` on all form fields at once. `TextEditingController` reads what the user typed. Always `dispose()` controllers to prevent memory leaks. Check `mounted` after any `await` before calling `Navigator` — the widget might have been removed from the tree while waiting.

---

## NIGHT 3 — Up Next 👈

**Goal:** User profile collection, Firestore persistence, QuestionsScreen

**Files to write tonight, in this order:**
1. `lib/models/user_model.dart` — expand with full profile fields
2. `lib/services/firestore_service.dart` — saveUser, getUser
3. `lib/providers/user_provider.dart` — update \_init() and add saveUserProfile
4. `lib/screens/questions.dart` — multi-step onboarding form

Do not start step 2 until step 1 is done. `FirestoreService` imports `UserModel` — it won't compile without it.

---

### Step 3.1 — lib/models/user_model.dart

We expand the model now because QuestionsScreen is about to collect all these fields. The `fromFirestore()` and `toMap()` methods are needed because Firestore only stores `Map<String, dynamic>` — it does not know what a `UserModel` is. `copyWith()` is needed because all fields are `final` (immutable), so the only way to "update" a model is to create a new one with one field changed.

```dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final double weightKg;
  final double heightCm;
  final String goal;
  final List<String> gymDays;
  final String dietPreference;
  final String healthNotes;
  final bool hasCompletedOnboarding;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.goal,
    required this.gymDays,
    required this.dietPreference,
    required this.healthNotes,
    this.hasCompletedOnboarding = false,
  });

  // factory constructor to convert from Firestore to UserModel
  // mirrors the same pattern as Todo.fromFirestore() in the instructor demo
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      age: (data['age'] ?? 0) as int,
      weightKg: (data['weightKg'] ?? 0.0).toDouble(),
      heightCm: (data['heightCm'] ?? 0.0).toDouble(),
      goal: data['goal'] ?? 'general_health',
      gymDays: List<String>.from(data['gymDays'] ?? []),
      dietPreference: data['dietPreference'] ?? 'none',
      healthNotes: data['healthNotes'] ?? '',
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
    );
  }

  // toMap function for Firestore inserts
  // mirrors the same pattern as Todo.toMap() in the instructor demo
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'goal': goal,
      'gymDays': gymDays,
      'dietPreference': dietPreference,
      'healthNotes': healthNotes,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  // Creates a copy of this UserModel with some fields replaced
  // Used in QuestionsScreen to build the model step by step
  UserModel copyWith({
    String? name,
    int? age,
    double? weightKg,
    double? heightCm,
    String? goal,
    List<String>? gymDays,
    String? dietPreference,
    String? healthNotes,
    bool? hasCompletedOnboarding,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      goal: goal ?? this.goal,
      gymDays: gymDays ?? this.gymDays,
      dietPreference: dietPreference ?? this.dietPreference,
      healthNotes: healthNotes ?? this.healthNotes,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
```

---

### Step 3.2 — lib/services/firestore_service.dart

Services are "phone calls" to external systems. They don't hold state — they just make one-off requests. Keeping Firebase calls here, out of providers, means providers stay clean and testable. This is the same separation the instructor demo uses with `ApplicationState` calling `FirebaseFirestore.instance` directly.

Firestore is organized like folders and files:
```
/users/{uid}        → one document per user (tonight)
/workoutPlans/{uid} → one document per user (Night 4)
/dietPlans/{uid}    → one document per user (Night 4)
```

Using `uid` as the document ID means we go directly to `/users/abc123` instead of searching — instant lookup.

Tonight only write `saveUser` and `getUser`. The plan methods come Night 4 when those models exist.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  // Access the Firestore instance — same pattern as the instructor demo
  final _db = FirebaseFirestore.instance;

  // Save a user profile to Firestore
  // .set() creates the document if it doesn't exist, or overwrites it if it does
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // Load a user profile from Firestore
  // Returns null if no document found — means the user is new (hasn't done onboarding)
  Future<UserModel?> getUser(String uid) async {
    // Get the document
    final doc = await _db.collection('users').doc(uid).get();

    // Check if the document actually exists
    if (!doc.exists || doc.data() == null) return null;

    // Convert the map back into a UserModel
    return UserModel.fromFirestore(doc.data()!, uid);
  }
}
```

---

### Step 3.3 — lib/providers/user_provider.dart

Now that `FirestoreService` exists, fill in the empty `if (user != null)` branch in `_init()` and add `saveUserProfile`. The rest of the file stays the same.

The key concept: when the auth stream fires with a user, we immediately fetch their profile from Firestore. If `getUser()` returns `null`, the user is new — `hasCompletedOnboarding` stays false and `login.dart` will redirect them to QuestionsScreen.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// Extends ChangeNotifier — same pattern as ApplicationState in the instructor demo
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;
  // Reads hasCompletedOnboarding from the loaded UserModel
  // Returns false if no model loaded yet (new user)
  bool get hasCompletedOnboarding => _userModel?.hasCompletedOnboarding ?? false;

  UserProvider() {
    _init();
  }

  // Start listening to Firebase auth as soon as the provider is created
  // Mirrors the pattern in ApplicationState.init() from the instructor demo
  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;

      if (user != null) {
        // User logged in — load their profile from Firestore
        _userModel = await _firestoreService.getUser(user.uid);
      } else {
        // User logged out — clear the profile
        _userModel = null;
      }

      // Notify all listening widgets to rebuild
      notifyListeners();
    });
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _authService.login(email: email, password: password);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.register(email: email, password: password);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  // Called at the end of QuestionsScreen once the user fills in their profile
  // Updates local state and saves to Firestore
  Future<void> saveUserProfile(UserModel user) async {
    // Update local state immediately so the UI responds
    _userModel = user;
    // Save to Firestore in the background
    await _firestoreService.saveUser(user);
    // Notify listeners so any watching widget rebuilds
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Converts Firebase error codes into readable messages
  String _friendlyError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with that email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'email-already-in-use' => 'An account with that email already exists.',
      'weak-password' => 'Password must be at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
```

---

### Step 3.4 — lib/screens/questions.dart

A 7-step onboarding form. One integer `_step` tracks which step we're on. `setState(() => _step++)` advances to the next step and triggers a rebuild. On the last step, `_submit()` saves the profile and navigates to Dashboard.

`setState()` is the same concept as the instructor demo — it tells Flutter "I changed local state, please rebuild this widget."

`pushReplacementNamed` instead of `pushNamed` — replaces the current screen in the navigation stack so the user cannot press Back to return to the questions screen.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  // Tracks which step we're on (0–6)
  int _step = 0;

  // Collected answers — built up across steps
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _healthNotesCtrl = TextEditingController();

  var _goal = 'general_health';
  var _dietPreference = 'none';
  final List<String> _gymDays = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _healthNotesCtrl.dispose();
    super.dispose();
  }

  // Advance to the next step, or submit on the last step
  void _next() {
    if (_step < 6) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    final userProvider = context.read<UserProvider>();

    // Build the UserModel from all the collected answers
    final user = UserModel(
      uid: userProvider.firebaseUser!.uid,
      email: userProvider.firebaseUser!.email ?? '',
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      weightKg: double.tryParse(_weightCtrl.text.trim()) ?? 0.0,
      heightCm: double.tryParse(_heightCtrl.text.trim()) ?? 0.0,
      goal: _goal,
      gymDays: List.from(_gymDays),
      dietPreference: _dietPreference,
      healthNotes: _healthNotesCtrl.text.trim(),
      hasCompletedOnboarding: true,
    );

    // Save profile to Firestore via the provider
    await userProvider.saveUserProfile(user);

    // AI + plan generation will be added here on Night 4

    if (!mounted) return;

    // Replace the questions screen with the dashboard
    // pushReplacementNamed so the user can't press Back to return here
    Navigator.of(context).pushReplacementNamed(Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_step + 1} of 7'),
        leading: _step > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back)
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show the current step's content
            Expanded(child: _buildStep()),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_step < 6 ? 'Next' : 'Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Returns the widget for the current step
  Widget _buildStep() {
    return switch (_step) {
      0 => _stepName(),
      1 => _stepAge(),
      2 => _stepBody(),
      3 => _stepGoal(),
      4 => _stepGymDays(),
      5 => _stepDiet(),
      _ => _stepHealthNotes(),
    };
  }

  // Step 0 — Name
  Widget _stepName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What is your name?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Full name'),
          autofocus: true,
        ),
      ],
    );
  }

  // Step 1 — Age
  Widget _stepAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How old are you?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ageCtrl,
          decoration: const InputDecoration(labelText: 'Age'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // Step 2 — Weight and Height
  Widget _stepBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your body stats',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weightCtrl,
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _heightCtrl,
          decoration: const InputDecoration(labelText: 'Height (cm)'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // Step 3 — Goal
  // Uses Dart records as a convenient way to store (key, label, icon) together
  Widget _stepGoal() {
    // A Dart record holds multiple values without needing a class
    // Access them with .$1, .$2, .$3
    final goals = [
      ('lose_weight', 'Lose Weight', Icons.trending_down),
      ('build_muscle', 'Build Muscle', Icons.fitness_center),
      ('general_health', 'General Health', Icons.favorite),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What is your goal?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...goals.map((g) {
          final isSelected = _goal == g.$1;
          return ListTile(
            leading: Icon(g.$3),
            title: Text(g.$2),
            // Highlight the selected option
            tileColor: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            onTap: () => setState(() => _goal = g.$1),
          );
        }),
      ],
    );
  }

  // Step 4 — Gym Days
  Widget _stepGymDays() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Which days do you go to the gym?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: days.map((day) {
              final isSelected = _gymDays.contains(day);
              return CheckboxListTile(
                title: Text(day),
                value: isSelected,
                // setState updates the local _gymDays list and triggers a rebuild
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _gymDays.add(day);
                  } else {
                    _gymDays.remove(day);
                  }
                }),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Step 5 — Diet Preference
  Widget _stepDiet() {
    final options = [
      ('none', 'No preference'),
      ('vegetarian', 'Vegetarian'),
      ('vegan', 'Vegan'),
      ('keto', 'Keto'),
      ('high_protein', 'High Protein'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Any diet preference?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...options.map((o) {
          final isSelected = _dietPreference == o.$1;
          return ListTile(
            title: Text(o.$2),
            tileColor: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            onTap: () => setState(() => _dietPreference = o.$1),
          );
        }),
      ],
    );
  }

  // Step 6 — Health Notes
  Widget _stepHealthNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Any injuries or health notes?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Leave blank if none.',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _healthNotesCtrl,
          decoration: const InputDecoration(
            labelText: 'Health notes (optional)',
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
      ],
    );
  }
}
```

**How to verify Night 3 is working:**
Register → fill in QuestionsScreen → land on the Dashboard stub. Open Firebase Console → Firestore → `/users/{uid}` — a document with all your profile fields should be there.

---

## NIGHT 4 — Coming Up

**Goal:** Workout models, diet models, Firestore plan methods, AI service, both plan providers, update QuestionsScreen \_submit()

**Files to work on tonight, in this order:**
1. `lib/models/workout_models.dart`
2. `lib/models/diet_model.dart`
3. `lib/services/firestore_service.dart` — add plan methods
4. `lib/services/ai_service.dart`
5. `lib/providers/workout_provider.dart`
6. `lib/providers/diet_provider.dart`
7. `lib/screens/questions.dart` — update `_submit()`

Models before services. Services before providers. Providers before the screen update that calls them.

---

### Step 4.1 — lib/models/workout_models.dart

Three classes nested inside each other. Same `fromMap()` / `toMap()` pattern as `UserModel` and `Todo` from the instructor demo.

```dart
class Exercise {
  final String name;
  final int sets;
  final int reps;
  final String restTime;
  final String instructions;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.instructions,
  });

  factory Exercise.fromMap(Map<String, dynamic> data) {
    return Exercise(
      name: data['name'] ?? '',
      sets: (data['sets'] ?? 0) as int,
      reps: (data['reps'] ?? 0) as int,
      restTime: data['restTime'] ?? '',
      instructions: data['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'sets': sets,
    'reps': reps,
    'restTime': restTime,
    'instructions': instructions,
  };
}

class WorkoutDay {
  final String day;
  final bool isRestDay;
  final List<Exercise> exercises;

  const WorkoutDay({
    required this.day,
    required this.isRestDay,
    required this.exercises,
  });

  factory WorkoutDay.fromMap(Map<String, dynamic> data) {
    final rest = data['isRestDay'] as bool? ?? false;
    return WorkoutDay(
      day: data['day'] ?? '',
      isRestDay: rest,
      // If it's a rest day, skip parsing the exercises list entirely
      // This prevents crashes when the AI returns an empty exercises array
      exercises: rest
          ? []
          : (data['exercises'] as List<dynamic>? ?? [])
                .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
                .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'day': day,
    'isRestDay': isRestDay,
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };
}

class WorkoutPlan {
  final String userId;
  final List<WorkoutDay> days;

  const WorkoutPlan({required this.userId, required this.days});

  // factory constructor to convert from Firestore to WorkoutPlan
  factory WorkoutPlan.fromFirestore(Map<String, dynamic> data) {
    return WorkoutPlan(
      userId: data['userId'] ?? '',
      days: (data['days'] as List<dynamic>? ?? [])
          .map((d) => WorkoutDay.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }

  // toMap for Firestore inserts
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'days': days.map((d) => d.toMap()).toList(),
  };
}
```

---

### Step 4.2 — lib/models/diet_model.dart

Same structure as workout but for meals. The key addition here is `Meal.copyWith()`, which is used by `DietProvider.toggleMeal()` to update one meal without mutating the rest.

```dart
class Meal {
  final String type;
  final String time;
  final String description;
  final bool isCompleted;

  const Meal({
    required this.type,
    required this.time,
    required this.description,
    this.isCompleted = false,
  });

  factory Meal.fromMap(Map<String, dynamic> data) {
    return Meal(
      type: data['type'] ?? '',
      time: data['time'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'time': time,
    'description': description,
    'isCompleted': isCompleted,
  };

  // Creates a copy of this Meal with isCompleted changed
  // Used when the user checks/unchecks a meal — can't mutate because fields are final
  Meal copyWith({bool? isCompleted}) => Meal(
    type: type,
    time: time,
    description: description,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class DietDay {
  final String day;
  final bool isRestDay;
  final List<Meal> meals;

  const DietDay({
    required this.day,
    required this.isRestDay,
    required this.meals,
  });

  factory DietDay.fromMap(Map<String, dynamic> data) {
    final rest = data['isRestDay'] as bool? ?? false;
    return DietDay(
      day: data['day'] ?? '',
      isRestDay: rest,
      meals: rest
          ? []
          : (data['meals'] as List<dynamic>? ?? [])
                .map((m) => Meal.fromMap(m as Map<String, dynamic>))
                .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'day': day,
    'isRestDay': isRestDay,
    'meals': meals.map((m) => m.toMap()).toList(),
  };
}

class DietPlan {
  final String userId;
  final List<DietDay> days;

  const DietPlan({required this.userId, required this.days});

  // factory constructor to convert from Firestore to DietPlan
  factory DietPlan.fromFirestore(Map<String, dynamic> data) {
    return DietPlan(
      userId: data['userId'] ?? '',
      days: (data['days'] as List<dynamic>? ?? [])
          .map((d) => DietDay.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }

  // toMap for Firestore inserts
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'days': days.map((d) => d.toMap()).toList(),
  };
}
```

---

### Step 4.3 — lib/services/firestore_service.dart (add plan methods)

Add these methods to the existing `FirestoreService` class below `getUser`. Do not rewrite the file — just add to it.

```dart
  // --- Workout Plan ---

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    await _db.collection('workoutPlans').doc(plan.userId).set(plan.toMap());
  }

  Future<WorkoutPlan?> getWorkoutPlan(String uid) async {
    final doc = await _db.collection('workoutPlans').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return WorkoutPlan.fromFirestore(doc.data()!);
  }

  // --- Diet Plan ---

  Future<void> saveDietPlan(DietPlan plan) async {
    await _db.collection('dietPlans').doc(plan.userId).set(plan.toMap());
  }

  Future<DietPlan?> getDietPlan(String uid) async {
    final doc = await _db.collection('dietPlans').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return DietPlan.fromFirestore(doc.data()!);
  }

  // Update a single meal's completion status
  // Firestore doesn't cleanly support updating one item deep inside a nested array,
  // so we load the whole plan, change the one meal using copyWith, then save it back
  Future<void> updateMealCompletion({
    required String uid,
    required int dayIndex,
    required int mealIndex,
    required bool isCompleted,
  }) async {
    // Load the full plan from Firestore
    final plan = await getDietPlan(uid);
    if (plan == null) return;

    // Rebuild the plan with one meal changed
    final updatedDays = List<DietDay>.from(plan.days);
    final day = updatedDays[dayIndex];
    final updatedMeals = List<Meal>.from(day.meals);
    // copyWith creates a new Meal with only isCompleted changed
    updatedMeals[mealIndex] = updatedMeals[mealIndex].copyWith(
      isCompleted: isCompleted,
    );
    updatedDays[dayIndex] = DietDay(
      day: day.day,
      isRestDay: day.isRestDay,
      meals: updatedMeals,
    );

    // Save the whole updated plan back to Firestore
    await saveDietPlan(DietPlan(userId: uid, days: updatedDays));
  }
```

The full `firestore_service.dart` file after adding these methods:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/workout_models.dart';
import '../models/diet_model.dart';

class FirestoreService {
  // Access the Firestore instance — same pattern as the instructor demo
  final _db = FirebaseFirestore.instance;

  // Save a user profile to Firestore
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // Load a user profile from Firestore
  // Returns null if no document found — means the user hasn't done onboarding
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromFirestore(doc.data()!, uid);
  }

  // --- Workout Plan ---

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    await _db.collection('workoutPlans').doc(plan.userId).set(plan.toMap());
  }

  Future<WorkoutPlan?> getWorkoutPlan(String uid) async {
    final doc = await _db.collection('workoutPlans').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return WorkoutPlan.fromFirestore(doc.data()!);
  }

  // --- Diet Plan ---

  Future<void> saveDietPlan(DietPlan plan) async {
    await _db.collection('dietPlans').doc(plan.userId).set(plan.toMap());
  }

  Future<DietPlan?> getDietPlan(String uid) async {
    final doc = await _db.collection('dietPlans').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return DietPlan.fromFirestore(doc.data()!);
  }

  // Update a single meal's completion status
  Future<void> updateMealCompletion({
    required String uid,
    required int dayIndex,
    required int mealIndex,
    required bool isCompleted,
  }) async {
    final plan = await getDietPlan(uid);
    if (plan == null) return;

    final updatedDays = List<DietDay>.from(plan.days);
    final day = updatedDays[dayIndex];
    final updatedMeals = List<Meal>.from(day.meals);
    updatedMeals[mealIndex] = updatedMeals[mealIndex].copyWith(
      isCompleted: isCompleted,
    );
    updatedDays[dayIndex] = DietDay(
      day: day.day,
      isRestDay: day.isRestDay,
      meals: updatedMeals,
    );

    await saveDietPlan(DietPlan(userId: uid, days: updatedDays));
  }
}
```

---

### Step 4.4 — lib/services/ai_service.dart

Sends the user's profile to Gemini and parses the JSON response into a WorkoutPlan and DietPlan.

The return type uses a Dart record `({WorkoutPlan workout, DietPlan diet})` — a lightweight way to return two values at once without making a separate class. Access them as `plans.workout` and `plans.diet`.

Sometimes Gemini wraps its response in markdown code fences (` ```json ... ``` `). Strip those before calling `jsonDecode()`.

```dart
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_model.dart';
import '../models/workout_models.dart';
import '../models/diet_model.dart';

class AiService {
  // Replace with your Gemini API key
  // In production this should come from a config file, not be hardcoded
  static const _apiKey = 'YOUR_GEMINI_API_KEY';

  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  // Sends user profile to Gemini and returns a workout plan + diet plan
  // Uses a Dart record to return two values at once: (workout: ..., diet: ...)
  Future<({WorkoutPlan workout, DietPlan diet})> generatePlans(
    UserModel user,
  ) async {
    // Build a prompt that includes the user's stats and the exact JSON format we want
    final prompt = '''
You are a certified personal trainer and nutritionist.
Generate a 7-day workout and diet plan for this user:

Name: ${user.name}
Age: ${user.age}
Weight: ${user.weightKg} kg
Height: ${user.heightCm} cm
Goal: ${user.goal}
Gym days: ${user.gymDays.join(', ')}
Diet preference: ${user.dietPreference}
Health notes: ${user.healthNotes.isEmpty ? 'None' : user.healthNotes}

Rules:
- Only assign exercises on the user's gym days. All other days are rest days.
- Each gym day should have 4–6 exercises with sets, reps, rest time, and brief instructions.
- Each day should have 3–4 meals.

Return ONLY valid JSON in exactly this format with no extra text:
{
  "workout": {
    "userId": "${user.uid}",
    "days": [
      {
        "day": "Monday",
        "isRestDay": false,
        "exercises": [
          {
            "name": "Bench Press",
            "sets": 3,
            "reps": 10,
            "restTime": "90 seconds",
            "instructions": "Keep your back flat on the bench."
          }
        ]
      },
      {
        "day": "Tuesday",
        "isRestDay": true,
        "exercises": []
      }
    ]
  },
  "diet": {
    "userId": "${user.uid}",
    "days": [
      {
        "day": "Monday",
        "isRestDay": false,
        "meals": [
          {
            "type": "Breakfast",
            "time": "8:00 AM",
            "description": "Oats with banana and protein powder",
            "isCompleted": false
          }
        ]
      }
    ]
  }
}
''';

    // Send the prompt to Gemini and get the response
    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';

    // Gemini sometimes wraps its response in markdown code fences like ```json ... ```
    // Strip those before parsing
    String cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll(RegExp(r'```\w*'), '').trim();
    }

    // Parse the JSON string into a Map
    final Map<String, dynamic> json = jsonDecode(cleaned);

    // Convert the maps into our model classes
    final workout = WorkoutPlan.fromFirestore(
      json['workout'] as Map<String, dynamic>,
    );
    final diet = DietPlan.fromFirestore(
      json['diet'] as Map<String, dynamic>,
    );

    // Return both plans as a Dart record
    return (workout: workout, diet: diet);
  }
}
```

---

### Step 4.5 — lib/providers/workout_provider.dart

Same ChangeNotifier pattern as `UserProvider`. Private fields, public getters, methods that call `notifyListeners()`. `selectedDay` is a computed getter — it calculates its value on the fly from `_workoutPlan` and `_selectedDayIndex`.

```dart
import 'package:flutter/material.dart';
import '../models/workout_models.dart';
import '../services/firestore_service.dart';

// Extends ChangeNotifier — same pattern as UserProvider and ApplicationState in the demo
class WorkoutProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  WorkoutPlan? _workoutPlan;
  int _selectedDayIndex = 0;

  WorkoutPlan? get workoutPlan => _workoutPlan;
  int get selectedDayIndex => _selectedDayIndex;

  // Computed getter — calculates the selected day on the fly
  // When the user taps day 3: selectDay(2) → _selectedDayIndex = 2
  //   → notifyListeners() → WorkoutScreen rebuilds → reads selectedDay → gets day 3
  WorkoutDay? get selectedDay {
    if (_workoutPlan == null) return null;
    if (_selectedDayIndex >= _workoutPlan!.days.length) return null;
    return _workoutPlan!.days[_selectedDayIndex];
  }

  // Store a plan in memory (called from QuestionsScreen after AI generates it)
  void setWorkoutPlan(WorkoutPlan plan) {
    _workoutPlan = plan;
    _selectedDayIndex = 0;
    notifyListeners();
  }

  // Load a plan from Firestore (called from DashboardScreen on app launch)
  Future<void> loadWorkoutPlan(String uid) async {
    // Fetch from Firestore
    final plan = await _firestoreService.getWorkoutPlan(uid);
    if (plan != null) {
      // Update local state and notify listeners to rebuild
      _workoutPlan = plan;
      _selectedDayIndex = 0;
      notifyListeners();
    }
  }

  // Called when the user taps a day tab in WorkoutScreen
  void selectDay(int index) {
    _selectedDayIndex = index;
    notifyListeners();
  }
}
```

---

### Step 4.6 — lib/providers/diet_provider.dart

Same structure as `WorkoutProvider`. The key addition is `toggleMeal()`, which uses the optimistic update pattern: update local state immediately so the checkbox flips instantly, then save to Firestore in the background. If you waited for Firestore first, the checkbox would feel slow (500ms+ delay).

```dart
import 'package:flutter/material.dart';
import '../models/diet_model.dart';
import '../services/firestore_service.dart';

// Extends ChangeNotifier — same pattern as WorkoutProvider
class DietProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  DietPlan? _dietPlan;
  int _selectedDayIndex = 0;

  DietPlan? get dietPlan => _dietPlan;
  int get selectedDayIndex => _selectedDayIndex;

  // Computed getter — returns the meals for the currently selected day
  DietDay? get selectedDay {
    if (_dietPlan == null) return null;
    if (_selectedDayIndex >= _dietPlan!.days.length) return null;
    return _dietPlan!.days[_selectedDayIndex];
  }

  // Store a plan in memory (called from QuestionsScreen after AI generates it)
  void setDietPlan(DietPlan plan) {
    _dietPlan = plan;
    _selectedDayIndex = 0;
    notifyListeners();
  }

  // Load a plan from Firestore (called from DashboardScreen on app launch)
  Future<void> loadDietPlan(String uid) async {
    final plan = await _firestoreService.getDietPlan(uid);
    if (plan != null) {
      _dietPlan = plan;
      _selectedDayIndex = 0;
      notifyListeners();
    }
  }

  // Called when the user taps a day tab
  void selectDay(int index) {
    _selectedDayIndex = index;
    notifyListeners();
  }

  // Toggle a meal's completion status
  // Uses the optimistic update pattern:
  // 1. Update local state immediately so the UI responds at once
  // 2. Save to Firestore in the background
  Future<void> toggleMeal({
    required String uid,
    required int mealIndex,
    required bool isCompleted,
  }) async {
    if (_dietPlan == null) return;

    // Get the current day's meals
    final day = _dietPlan!.days[_selectedDayIndex];
    final updatedMeals = List<Meal>.from(day.meals);

    // Use copyWith to create a new Meal with only isCompleted changed
    updatedMeals[mealIndex] = updatedMeals[mealIndex].copyWith(
      isCompleted: isCompleted,
    );

    // Rebuild the day and the full plan with the updated meal
    final updatedDays = List<DietDay>.from(_dietPlan!.days);
    updatedDays[_selectedDayIndex] = DietDay(
      day: day.day,
      isRestDay: day.isRestDay,
      meals: updatedMeals,
    );
    _dietPlan = DietPlan(userId: _dietPlan!.userId, days: updatedDays);

    // Notify listeners immediately — UI updates without waiting for Firestore
    notifyListeners();

    // Save the updated plan to Firestore in the background
    await _firestoreService.updateMealCompletion(
      uid: uid,
      dayIndex: _selectedDayIndex,
      mealIndex: mealIndex,
      isCompleted: isCompleted,
    );
  }
}
```

---

### Step 4.7 — Update lib/screens/questions.dart \_submit()

Replace the existing `_submit()` method with this version that calls the AI and saves the plans. Everything else in the file stays the same.

```dart
  Future<void> _submit() async {
    final userProvider = context.read<UserProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final dietProvider = context.read<DietProvider>();
    final firestoreService = FirestoreService();
    final aiService = AiService();

    // Build the UserModel from all the collected answers
    final user = UserModel(
      uid: userProvider.firebaseUser!.uid,
      email: userProvider.firebaseUser!.email ?? '',
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      weightKg: double.tryParse(_weightCtrl.text.trim()) ?? 0.0,
      heightCm: double.tryParse(_heightCtrl.text.trim()) ?? 0.0,
      goal: _goal,
      gymDays: List.from(_gymDays),
      dietPreference: _dietPreference,
      healthNotes: _healthNotesCtrl.text.trim(),
      hasCompletedOnboarding: true,
    );

    // Call AI — sends user stats to Gemini, gets workout + diet plans back
    final plans = await aiService.generatePlans(user);

    // Save user profile to Firestore via the provider
    await userProvider.saveUserProfile(user);

    // Store plans in providers (fast in-memory state so screens show data immediately)
    workoutProvider.setWorkoutPlan(plans.workout);
    dietProvider.setDietPlan(plans.diet);

    // Save plans to Firestore so they persist across app restarts
    await firestoreService.saveWorkoutPlan(plans.workout);
    await firestoreService.saveDietPlan(plans.diet);

    if (!mounted) return;

    // Replace the questions screen with the dashboard
    Navigator.of(context).pushReplacementNamed(Routes.dashboard);
  }
```

Also add the imports at the top of `questions.dart`:
```dart
import '../providers/workout_provider.dart';
import '../providers/diet_provider.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
```

**How to verify Night 4 is working:**
Complete the QuestionsScreen → check Firebase Console → `/workoutPlans/{uid}` and `/dietPlans/{uid}` should exist with real AI-generated content inside.

---

## NIGHT 5 — Coming Up

**Goal:** DashboardScreen, WorkoutScreen, DietScreen

**Files to work on:**
1. `lib/screens/dashboard.dart`
2. `lib/screens/workout.dart`
3. `lib/screens/diet.dart`

Dashboard first — it loads the plans into providers on app launch. Once plans are in providers, WorkoutScreen and DietScreen can read and display them.

---

### Step 5.1 — lib/screens/dashboard.dart

`addPostFrameCallback` — Flutter does not allow you to trigger provider updates during a `build()` call. This schedules the load to run after the current frame finishes. Check `workoutPlan == null` first to avoid re-fetching on every rebuild.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/diet_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final dietProvider = context.watch<DietProvider>();

    final uid = userProvider.firebaseUser?.uid;

    // Schedule plan loading after the current build frame finishes
    // Can't call provider methods during build — this defers it safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only load if we have a user and the plan isn't already loaded
      if (uid != null && workoutProvider.workoutPlan == null) {
        workoutProvider.loadWorkoutPlan(uid);
      }
      if (uid != null && dietProvider.dietPlan == null) {
        dietProvider.loadDietPlan(uid);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${userProvider.userModel?.name ?? 'there'}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              userProvider.logout();
              // Navigate back to the about screen after logout
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.workout),
              child: const Text('My Workout Plan'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.diet),
              child: const Text('My Diet Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Step 5.2 — lib/screens/workout.dart

Needs `StatefulWidget` for the `TabController`, even though `WorkoutProvider` holds the plan data. The `TabController` length must match the number of days — but the plan loads asynchronously, so we create/recreate the controller once the plan arrives. `indexIsChanging` prevents the listener firing multiple times during a swipe animation.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  // TabController length must match the number of days in the plan
  // We don't know the length until the plan loads, so we start with null
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider — rebuild whenever the plan or selected day changes
    final workoutProvider = context.watch<WorkoutProvider>();
    final plan = workoutProvider.workoutPlan;

    // Show a loading spinner while the plan is still being fetched
    if (plan == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Create or recreate the TabController once we know how many days there are
    if (_tabController == null || _tabController!.length != plan.days.length) {
      _tabController?.dispose();
      _tabController = TabController(length: plan.days.length, vsync: this);
      _tabController!.addListener(() {
        // indexIsChanging is true while the user is mid-swipe
        // Only fire when the swipe is fully complete
        if (!_tabController!.indexIsChanging) {
          workoutProvider.selectDay(_tabController!.index);
        }
      });
    }

    final selectedDay = workoutProvider.selectedDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: plan.days
              .map((d) => Tab(text: d.day.substring(0, 3)))
              .toList(),
        ),
      ),
      body: selectedDay == null
          ? const Center(child: Text('No day selected'))
          : selectedDay.isRestDay
              ? const Center(
                  child: Text('Rest Day 🛋️',
                      style: TextStyle(fontSize: 24)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: selectedDay.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = selectedDay.exercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(exercise.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${exercise.sets} sets × ${exercise.reps} reps  •  Rest: ${exercise.restTime}\n${exercise.instructions}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
```

---

### Step 5.3 — lib/screens/diet.dart

The diet screen uses `context.watch<DietProvider>()` so it rebuilds whenever `toggleMeal()` calls `notifyListeners()`. The checkbox uses a custom `GestureDetector` + `Container` with `BoxShape.circle` because Flutter's built-in `Checkbox` is square. The completed state uses `TextDecoration.lineThrough` — the same pattern from the instructor's demo `TodoPage`.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diet_model.dart';
import '../providers/diet_provider.dart';
import '../providers/user_provider.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dietProvider = context.watch<DietProvider>();
    final userProvider = context.watch<UserProvider>();
    final plan = dietProvider.dietPlan;
    final uid = userProvider.firebaseUser?.uid;

    if (plan == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Create or recreate the TabController to match the number of days
    if (_tabController == null || _tabController!.length != plan.days.length) {
      _tabController?.dispose();
      _tabController = TabController(length: plan.days.length, vsync: this);
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          dietProvider.selectDay(_tabController!.index);
        }
      });
    }

    final selectedDay = dietProvider.selectedDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: plan.days
              .map((d) => Tab(text: d.day.substring(0, 3)))
              .toList(),
        ),
      ),
      body: selectedDay == null
          ? const Center(child: Text('No day selected'))
          : selectedDay.isRestDay
              ? const Center(
                  child: Text('Rest Day 🥗',
                      style: TextStyle(fontSize: 24)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: selectedDay.meals.length,
                  itemBuilder: (context, index) {
                    final meal = selectedDay.meals[index];
                    return _MealCard(
                      meal: meal,
                      onToggle: (isCompleted) {
                        if (uid == null) return;
                        // Toggle the meal — updates local state immediately,
                        // saves to Firestore in the background
                        dietProvider.toggleMeal(
                          uid: uid,
                          mealIndex: index,
                          isCompleted: isCompleted,
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// Separate widget for each meal card — keeps build() clean
class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onToggle});

  final Meal meal;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom circle checkbox — Flutter's built-in Checkbox is square
            GestureDetector(
              onTap: () => onToggle(!meal.isCompleted),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: meal.isCompleted ? accent : Colors.transparent,
                  border: Border.all(
                    color: meal.isCompleted ? accent : Colors.white38,
                    width: 2,
                  ),
                ),
                child: meal.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
        title: Text(
          '${meal.type}  •  ${meal.time}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          meal.description,
          style: TextStyle(
            // Strikethrough when completed — same pattern as TodoPage in the demo
            decoration:
                meal.isCompleted ? TextDecoration.lineThrough : null,
            color: meal.isCompleted ? Colors.white38 : null,
          ),
        ),
      ),
    );
  }
}
```

---

## NIGHT 6 — Tests

**Goal:** Write tests for models and providers. Leave until everything else is working.

Tests force you to write better, more modular code. If something is hard to test, it usually means it's doing too many things at once.

**Three model tests** (`test/models/user_model_test.dart`, `workout_models_test.dart`, `diet_model_test.dart`)
Test `fromMap()` → do all fields parse correctly? Test `toMap()` → does round-tripping (save then reload) give back the same values? Test `copyWith()` → does only the specified field change?

**Two provider tests** (`test/providers/workout_provider_test.dart`, `diet_provider_test.dart`)
Mock `FirestoreService` with mockito so tests don't hit the real database. Test: does `setWorkoutPlan()` store the plan? Does `selectDay(2)` set `selectedDayIndex` to 2? Does `notifyListeners()` get called?

**One widget test** (`test/screens/about_test.dart`)
Test the UI: does "UghFine" appear on screen? Does "Get Started" appear? Does tapping "Get Started" navigate to `/login`?

---

## Quick Reference: How Data Flows Through the App

```
App launches
  → UserProvider._init() starts listening to auth stream
  → If user was logged in: stream fires immediately with their User
    → FirestoreService.getUser(uid) → UserModel loaded
    → hasCompletedOnboarding = true → login.dart sends to /dashboard
    → DashboardScreen loads workout + diet plans from Firestore

New user registers
  → login.dart → hasCompletedOnboarding = false → /questions
  → QuestionsScreen collects profile answers
  → _submit():
      → AiService.generatePlans(user) → Gemini → WorkoutPlan + DietPlan
      → UserProvider.saveUserProfile(user) → Firestore /users/{uid}
      → WorkoutProvider.setWorkoutPlan(plan) → notifyListeners()
      → FirestoreService.saveWorkoutPlan(plan) → Firestore /workoutPlans/{uid}
      → FirestoreService.saveDietPlan(plan) → Firestore /dietPlans/{uid}
      → Navigate to /dashboard

User checks off a meal
  → DietScreen calls dietProvider.toggleMeal(...)
  → DietProvider updates _dietPlan in memory → notifyListeners() → UI rebuilds
  → FirestoreService.updateMealCompletion(...) saves to Firestore in background
```

---

## Dart Concepts Reference

| Concept | Where Used | What It Means |
|---|---|---|
| `final` | All models | Value set once, can't change |
| `async / await` | All services | Wait for network call to complete |
| `Future<T>` | All services | A value that will arrive later |
| `Stream<T>` | AuthService | A river of values over time |
| `ChangeNotifier` | All providers | Base class that can notify listeners |
| `notifyListeners()` | All providers | Tells watching widgets to rebuild |
| `context.watch<T>()` | All screens | Subscribe to provider changes |
| `context.read<T>()` | In callbacks | Read provider once, no subscription |
| `setState()` | StatefulWidgets | Trigger a local UI rebuild |
| `initState()` | StatefulWidgets | Runs once when widget is created |
| `dispose()` | StatefulWidgets | Runs once when widget is destroyed |
| `mounted` | After async calls | Is the widget still in the tree? |
| `factory` constructor | All models | Named constructor returning an instance |
| Records `(a, b)` | QuestionsScreen, AiService | Lightweight tuple — multiple values without a class |
