# Larry iOS Native App

A native iOS vocabulary learning app built with SwiftUI that integrates with the Larry Node.js backend API.

## 📱 Features

- **Native Authentication**: Sign in with Apple and Google Sign In
- **Daily Vocabulary**: Personalized word delivery with spaced repetition
- **AI Chat**: Interactive vocabulary learning with Larry AI coach
- **Wordbank**: Track learning progress and manage favorite words
- **Interests Management**: Customize topic weights for personalized learning
- **Secure Storage**: JWT tokens and user data stored securely in Keychain

## 🏗️ Architecture

### Project Structure

```
Larry/
├── App/                          # App entry point and main views
│   ├── LarryApp.swift           # Main app file with Google Sign In configuration
│   └── ContentView.swift       # Root content view with authentication state
│
├── Core/                        # Core functionality and shared components
│   ├── Models/                  # Data models matching backend API
│   │   ├── User.swift          # User model with authentication
│   │   ├── Topic.swift         # Topic model for interests
│   │   ├── Term.swift          # Vocabulary term model
│   │   ├── Fact.swift          # Interesting facts about terms
│   │   └── DailyWord.swift     # Daily word delivery model
│   │
│   ├── Services/               # Core services
│   │   ├── APIService.swift    # Main API client with Alamofire
│   │   ├── AuthenticationManager.swift # Auth flow management
│   │   └── KeychainService.swift # Secure token storage
│   │
│   └── Views/                  # Shared UI components
│       └── LoadingView.swift   # Loading state view
│
├── Features/                   # Feature-specific views
│   ├── Authentication/
│   │   └── LoginView.swift     # Sign in with Apple/Google
│   │
│   ├── Home/
│   │   ├── MainTabView.swift   # Main tab navigation
│   │   └── HomeView.swift      # Daily words display
│   │
│   ├── Chat/
│   │   └── ChatView.swift      # AI chat interface
│   │
│   ├── Wordbank/
│   │   └── WordbankView.swift  # Word history and favorites
│   │
│   ├── Interests/
│   │   └── InterestsView.swift # Topic weight management
│   │
│   └── Profile/
│       └── ProfileView.swift   # User profile and settings
│
└── Resources/
    └── Info.plist             # App configuration and permissions
```

## 🔧 Technical Stack

- **UI Framework**: SwiftUI with iOS 16+ deployment target
- **Architecture**: MVVM with ObservableObject state management
- **Networking**: Alamofire for HTTP requests
- **Authentication**: AuthenticationServices (Sign in with Apple) + GoogleSignIn SDK
- **Security**: KeychainAccess for secure token storage
- **State Management**: Combine with @Published properties

## 🚀 Setup Instructions

### Prerequisites

1. Xcode 15.0 or later
2. iOS 16.0 or later deployment target
3. Larry backend API running on localhost:4000

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd larry-ios-native
   ```

2. **Install dependencies**
   The project uses Swift Package Manager. Dependencies will be automatically resolved when you open the project in Xcode.

3. **Configure Google Sign In**
   - Add your `GoogleService-Info.plist` file to the project
   - Update the URL scheme in `Info.plist` with your Google OAuth client ID

4. **Configure Info.plist**
   - Replace placeholder values with your actual configuration
   - Update associated domains for universal links
   - Ensure all required permissions are properly configured

5. **Build and run**
   - Open `Larry.xcodeproj` in Xcode
   - Select your target device or simulator
   - Build and run the project

## 🔐 Authentication Flow

### Sign in with Apple
1. User taps "Continue with Apple"
2. iOS presents native Sign in with Apple interface
3. App receives identity token and authorization code
4. Credentials are sent to backend `/auth-direct/apple` endpoint
5. Backend returns JWT tokens and user data
6. Tokens stored securely in Keychain

### Google Sign In
1. User taps "Continue with Google"
2. Google Sign In SDK handles OAuth flow
3. App receives Google ID token
4. Token processing with backend (implementation needed)
5. JWT tokens stored in Keychain

## 🌐 API Integration

### Base Configuration
- **Development**: `http://localhost:4000`
- **Production**: Configure in APIService.swift

### Key Endpoints
- `POST /auth-direct/apple` - Apple authentication
- `POST /auth-direct/google/start` - Google OAuth initiation
- `POST /auth-direct/refresh` - Token refresh
- `GET /auth-direct/profile` - User profile
- `GET /daily` - Daily word delivery
- `GET /topics` - User interests/topics
- `POST /topics/weights` - Update topic weights

### Error Handling
- Network errors with automatic retry logic
- Authentication errors with automatic token refresh
- User-friendly error messages throughout the app

## 🔒 Security Features

### Keychain Storage
- Access tokens stored with `.whenUnlockedThisDeviceOnly` accessibility
- Automatic token expiration checking with 5-minute buffer
- Secure deletion on sign out

### Network Security
- HTTPS enforcement in production
- Certificate pinning ready (implement in APIService)
- Localhost exception for development only

## 🎨 UI/UX Features

### Design System
- Native iOS design patterns
- Dynamic Type support
- Dark mode compatibility
- Accessibility labels and hints

### User Experience
- Smooth loading states
- Pull-to-refresh functionality
- Offline error handling
- Intuitive navigation patterns

## 🧪 Testing

### Unit Tests
- Model serialization/deserialization
- Keychain service operations
- API service error handling

### UI Tests
- Authentication flow
- Navigation between tabs
- Critical user journeys

## 📋 TODO / Known Issues

1. **Google Sign In**: Complete backend integration flow
2. **Push Notifications**: Implement APNs for daily word reminders
3. **Offline Support**: Cache critical data for offline viewing
4. **Widget Support**: iOS 17+ widgets for daily words
5. **Universal Links**: Complete deep linking implementation

## 🤝 Contributing

1. Follow Swift style guidelines
2. Use SwiftLint for code formatting
3. Write comprehensive tests for new features
4. Update documentation for API changes

## 📄 License

[Your license information]

---

For backend API documentation, see the main Larry project repository.
