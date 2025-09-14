# README.md

# Memora App

A modern, offline-first notes application built with Flutter and FastAPI, featuring clean architecture, state management with BLoC, and Firebase integration.

## 🌟 Features

### Core Functionality
- **Authentication**: Secure user registration and login with Firebase Auth
- **CRUD Operations**: Create, read, update, and delete notes
- **Search & Filter**: Real-time search through notes by title and content
- **Pin/Favorite**: Pin important notes to the top of the list
- **Undo Delete**: Safety feature with snackbar undo action

### Architecture & Technical Features
- **Clean Architecture**: Domain, Data, and Presentation layers
- **Offline-First**: Works seamlessly offline with automatic sync
- **State Management**: BLoC/Cubit pattern for predictable state management
- **Local Caching**: Hive database for fast offline access
- **Responsive UI**: Modern Material 3 design with light/dark theme support
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Loading States**: Smooth loading indicators and optimistic updates

### User Experience
- **Intuitive Navigation**: Clean, modern interface
- **Search Integration**: Instant search with query highlighting
- **Connectivity Status**: Visual indicator for online/offline status
- **Gesture Support**: Swipe actions and touch-friendly interactions
- **Accessibility**: Screen reader support and high contrast modes

## 🏗️ Architecture

### Frontend (Flutter)
```
lib/
├── core/
│   ├── theme/           # App theming and styling
│   ├── services/        # Dependency injection and utilities
│   └── constants/       # App constants and configurations
├── features/
│   ├── auth/
│   │   ├── domain/      # Entities, repositories, use cases
│   │   ├── data/        # Models, data sources, repository impl
│   │   └── presentation/ # BLoC, pages, widgets
│   └── notes/
│       ├── domain/      # Business logic and entities
│       ├── data/        # Data layer implementation
│       └── presentation/ # UI components and state management
└── main.dart           # App entry point
```

### Backend (FastAPI)
```
backend/
├── main.py             # FastAPI application
├── models/             # Pydantic models
├── routes/             # API route handlers
├── services/           # Business logic services
├── middleware/         # Custom middleware
└── requirements.txt    # Python dependencies
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Python 3.11+
- Firebase Project
- Node.js (for additional tooling)

### Firebase Setup
1. Create a new Firebase project at https://console.firebase.google.com
2. Enable Authentication with Email/Password
3. Create a Firestore database
4. Download the configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
   - `firebase-admin-sdk.json` for backend

### Flutter App Setup

1. **Clone and navigate to the project**:
```bash
git clone <repository-url>
cd professional_notes
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Configure environment variables**:
```bash
cp .env.example .env
# Edit .env with your Firebase configuration
```

4. **Add Firebase configuration files**:
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

5. **Generate code (if needed)**:
```bash
flutter packages pub run build_runner build
```

6. **Run the app**:
```bash
flutter run
```

### Backend Setup

1. **Navigate to backend directory**:
```bash
cd backend
```

2. **Create virtual environment**:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**:
```bash
pip install -r requirements.txt
```

4. **Configure environment**:
```bash
cp .env.example .env
# Edit .env with your configuration
```

5. **Add Firebase Admin SDK**:
   - Place `firebase-admin-sdk.json` in the backend directory

6. **Run the server**:
```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`
API documentation: `http://localhost:8000/docs`

## 📱 Demo Instructions

### Test Data Generation
To test with 50+ notes as required, use the following approach:

1. **Register/Login** to the app
2. **Use the demo data generator** (if implemented) or create notes manually
3. **Test Features**:
   - Create, edit, and delete notes
   - Search functionality with various queries
   - Pin/unpin notes
   - Test offline functionality (disable network)
   - Test sync when coming back online

### Key Demo Scenarios
1. **Authentication Flow**: Register → Login → Logout
2. **CRUD Operations**: Create → Edit → Delete → Undo Delete
3. **Search & Filter**: Search by title and content
4. **Pin Management**: Pin important notes, verify they stay at top
5. **Offline Mode**: Create/edit notes offline, verify sync when online
6. **Error Handling**: Test with network issues, invalid data

## 🔧 Configuration

### Environment Variables

**Flutter (.env)**:
```env
BACKEND_API_URL=http://localhost:8000
FIREBASE_WEB_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

**Backend (.env)**:
```env
GOOGLE_APPLICATION_CREDENTIALS=firebase-admin-sdk.json
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
```

### Customization
- **Theme**: Modify `lib/core/theme/app_theme.dart`
- **API Endpoints**: Update `lib/core/constants/api_constants.dart`
- **Local Storage**: Configure Hive boxes in `lib/core/services/storage_service.dart`

## 🧪 Testing

### Running Tests
```bash
# Flutter tests
flutter test

# Backend tests
python -m pytest

# Integration tests
flutter drive --target=test_driver/app.dart
```

### Test Coverage
```bash
# Flutter coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Backend coverage
pytest --cov=main --cov-report=html
```

## 🚢 Deployment

### Flutter Deployment
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Backend Deployment
```bash
# Docker
docker build -t notes-api .
docker run -p 8000:8000 notes-api

# Direct deployment
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

## 🤖 AI Features (Bonus Implementation Ideas)

### Potential AI Integrations
1. **Smart Categorization**: Auto-categorize notes by content
2. **Content Suggestions**: AI-powered writing suggestions
3. **Summary Generation**: Auto-generate note summaries
4. **Smart Search**: Semantic search using embeddings
5. **Voice-to-Text**: Convert voice recordings to notes
6. **Language Translation**: Multi-language note support
7. **Mood Analysis**: Detect and tag emotional content
8. **Related Notes**: Suggest related notes based on content similarity

### Implementation Approach
- Integrate with OpenAI API or Google AI services
- Use local ML models for privacy-sensitive features
- Implement gradual AI feature rollout with user consent
- Cache AI results for offline availability

## 📊 Performance Considerations

### Optimization Strategies
- **Lazy Loading**: Load notes progressively
- **Image Optimization**: Compress and cache images
- **Database Indexing**: Optimize search queries
- **Caching Strategy**: Multi-level caching (memory, disk, network)
- **Bundle Size**: Code splitting and tree shaking

### Monitoring
- Performance metrics tracking
- Crash reporting with Firebase Crashlytics
- User analytics with Firebase Analytics
- API response time monitoring

## 🔒 Security

### Implementation
- Firebase Authentication for user management
- JWT token validation on backend
- Input sanitization and validation
- Rate limiting on API endpoints
- HTTPS encryption in production
- Secure storage of sensitive data

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Flutter style guide
- Use meaningful commit messages
- Add tests for new features
- Update documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Firebase for backend services
- FastAPI for the clean API framework
- BLoC library for state management
- Material Design for UI guidelines

---

## 📞 Support

For questions or issues:
- Create an issue in the GitHub repository
- Email: info@connectinno.com
- Documentation: Check the `/docs` folder for detailed guides

---

**Built with ❤️ using Flutter & FastAPI**