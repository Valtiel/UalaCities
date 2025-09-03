# UalaCities

A SwiftUI-based iOS application for searching and exploring cities with a focus on performance, user experience, and clean architecture.

## 🏗️ Architecture Overview

UalaCities follows the **MVVM (Model-View-ViewModel)** architecture pattern combined with **Coordinator pattern** for navigation management. The app is designed with a modular, testable structure that separates concerns and promotes code reusability.

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │    Views    │  │ ViewModels  │  │    Coordinators     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                     Business Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Services  │  │  Strategies │  │    Data Providers   │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │    Models   │  │ Local Files │  │   UserDefaults      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🏛️ Core Classes & Components

### Models

#### `City`
- **Purpose**: Core data model representing a city
- **Properties**: `id`, `name`, `country`, `coordinates`
- **Features**: 
  - Conforms to `Identifiable`, `Codable`, `Equatable`, `Hashable`
  - Custom coding keys for JSON parsing

## 🎨 View Architecture & State Management

### View Architecture Overview

UalaCities implements a **Protocol-Oriented View Architecture** that separates view logic from state management through clear protocols and action-based communication. This architecture ensures:

- **Separation of Concerns**: Views are purely presentational, ViewModels handle business logic
- **Testability**: ViewStates and ViewActions can be easily mocked for testing
- **Reusability**: Views can work with any ViewModel that conforms to their state protocol
- **Type Safety**: Compile-time guarantees for view state and action handling

### View State Protocols

Each view defines a protocol that specifies the exact state it requires to function:

#### `CitySearchViewState`
```swift
protocol CitySearchViewState {
    var cityList: [City] { get }
    var filteredCityList: [City] { get }
    var isLoading: Bool { get }
    var currentPage: Int { get }
    var hasMorePages: Bool { get }
    var isLoadingMore: Bool { get }
    var favoritesCount: Int { get }
    func perform(_ action: CitySearchViewAction)
    func isFavorite(_ city: City) -> Bool
    func onViewAppear()
}
```

#### `CitySearchDetailViewState`
```swift
protocol CitySearchDetailViewState {
    // Inherits all search properties from CitySearchViewState
    var selectedCity: City? { get }
    var isDetailFavorite: Bool { get }
    func perform(_ action: CitySearchDetailViewAction)
    func isFavorite(_ city: City) -> Bool
    func onViewAppear()
}
```

#### `CityDetailViewState`
```swift
protocol CityDetailViewState {
    var city: City { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    var isFavorite: Bool { get }
    func perform(_ action: CityDetailViewAction)
}
```

#### `FavoritesViewState`
```swift
protocol FavoritesViewState {
    var favoriteCities: [City] { get }
    var isLoading: Bool { get }
    func perform(_ action: FavoritesViewAction)
}
```

### View Action Enums

Actions are defined as enums that represent all possible user interactions:

#### `CitySearchViewAction`
```swift
enum CitySearchViewAction {
    case searchQuery(String)      // User types in search field
    case selectCity(City)         // User taps on a city
    case loadMore                 // User scrolls to bottom
    case toggleFavorite(City)     // User taps favorite button
    case showFavorites            // User taps favorites button
}
```

#### `CitySearchDetailViewAction`
```swift
enum CitySearchDetailViewAction {
    case searchQuery(String)      // User types in search field
    case selectCity(City)         // User selects city from list
    case loadMore                 // User scrolls to bottom
    case toggleFavorite(City)     // User toggles favorite in list
    case toggleDetailFavorite     // User toggles favorite in detail
    case showFavorites            // User taps favorites button
}
```

#### `CityDetailViewAction`
```swift
enum CityDetailViewAction {
    case toggleFavorite           // User toggles favorite status
}
```

#### `FavoritesViewAction`
```swift
enum FavoritesViewAction {
    case selectCity(City)         // User selects a favorite city
    case toggleFavorite(City)     // User removes from favorites
}
```

### View Implementation Pattern

Views are implemented as generic structs that accept any ViewState conforming to their protocol:

```swift
struct CitySearchView<ViewState: ObservableObject & CitySearchViewState>: View {
    @ObservedObject var viewState: ViewState
    
    var body: some View {
        // View implementation that only accesses state through protocol
    }
}
```

### State Management Flow

#### 1. **Unidirectional Data Flow**
```
User Action → View → ViewModel.perform(action) → State Update → UI Update
```

#### 2. **State Binding**
- Views observe ViewModels through `@ObservedObject`
- ViewModels publish state changes through `@Published` properties
- Combine framework handles automatic UI updates

#### 3. **Action Handling**
- Views call `viewState.perform(action)` for all user interactions
- ViewModels implement action handling logic
- Actions trigger business logic and state updates

### Why This Architecture?

#### **1. Protocol-Oriented Design**
- **Flexibility**: Views can work with any ViewModel conforming to their protocol
- **Testing**: Easy to create mock ViewStates for isolated view testing
- **Dependency Inversion**: Views depend on abstractions, not concrete implementations

#### **2. Action-Based Communication**
- **Clear Intent**: Each action represents a specific user intention
- **Predictable Flow**: All user interactions follow the same pattern
- **Debugging**: Easy to trace user actions through the system

#### **3. Generic View Implementation**
- **Reusability**: Same view can work with different ViewModels

#### **4. Separation of Concerns**
- **Views**: Pure presentation, no business logic
- **ViewModels**: Business logic and state management
- **Protocols**: Clear contracts between layers

### State Synchronization

#### **Coordinator-Based State Management**
- `AppCoordinator` maintains global state (selected city, navigation path)
- ViewModels sync with coordinator for cross-view state
- State persists across orientation changes and navigation

#### **Service-Based State Updates**
- `FavoritesService` publishes favorite changes
- `CityDataService` publishes data loading states
- ViewModels bind to service publishers for automatic updates

### Benefits of This Architecture

1. **Testability**: Each component can be tested in isolation
2. **Maintainability**: Clear separation of responsibilities
3. **Scalability**: Easy to add new views and ViewModels
4. **Performance**: Efficient state updates through Combine
5. **Debugging**: Clear action flow and state changes
6. **Reusability**: Views can be reused with different ViewModels

### Views

#### `MainView`
- **Purpose**: Root view that manages orientation changes and view switching
- **Features**:
  - Portrait mode: Shows `CitySearchView` with navigation stack
  - Landscape mode: Shows `CitySearchDetailView` with split layout
  - Smooth transitions between orientations

#### `CitySearchView`
- **Purpose**: City search interface for portrait mode
- **Features**: Search bar, city list, pagination, favorites management

#### `CitySearchDetailView`
- **Purpose**: Combined search and detail view for landscape mode
- **Features**: Split layout with search section and city detail section

#### `CityDetailView`
- **Purpose**: Detailed city information display
- **Features**: City details, favorite toggle

### ViewModels

#### `CitySearchViewModel`
- **Purpose**: Manages city search state and business logic
- **Responsibilities**:
  - Search query processing
  - Pagination management
  - Favorites integration
  - Coordinator communication

#### `CitySearchDetailViewModel`
- **Purpose**: Manages combined search and detail state
- **Responsibilities**:
  - Search functionality
  - Selected city management
  - State persistence across orientation changes
  - Coordinator synchronization

#### `CityDetailViewModel`
- **Purpose**: Manages individual city detail state
- **Responsibilities**:
  - City data presentation
  - Favorite status management
  - Action handling

### Services

#### `CitySearchService`
- **Purpose**: Abstract search service with strategy pattern
- **Features**:
  - Strategy-based search implementation
  - Easy switching between search algorithms
  - Async search operations
  - Indexing management

#### `CityDataService`
- **Purpose**: Manages city data loading and access
- **Features**:
  - Async data loading
  - Data provider abstraction
  - Loading state management
  - Error handling

#### `FavoritesService`
- **Purpose**: Manages user's favorite cities
- **Features**:
  - CRUD operations for favorites
  - Persistent storage
  - Observable state updates

#### `ServicesManager`
- **Purpose**: Central service coordinator
- **Features**:
  - Service lifecycle management
  - Dependency injection
  - Shared service instances

### Coordinators

#### `AppCoordinator`
- **Purpose**: Main navigation coordinator
- **Features**:
  - Navigation path management
  - Sheet presentation
  - State persistence across views
  - Selected city management

## 🔍 Search Problem Solution

### Problem Statement
The app needed to provide fast, responsive city search with the following requirements:
- Support for large datasets (hundreds of thousands of cities)
- Real-time search as user types
- Efficient memory usage
- Smooth user experience without UI blocking

### Solution Approach

#### 1. Strategy Pattern Implementation
The search functionality is implemented using the **Strategy Pattern**, allowing easy switching between different search algorithms:

```swift
protocol CitySearchStrategy {
    func index(cities: [City])
    func search(query: String) async -> [City]
    func clear()
    var indexedCityCount: Int { get }
}
```

#### 2. Multiple Search Strategies

##### TrieSearchStrategy (Default)
- **Algorithm**: Trie data structure for incremental search
- **Benefits**:
  - O(m) search complexity where m is query length
  - Efficient for incremental typing
  - Maintains search state between queries
  - Excellent for autocomplete scenarios
- **Implementation Details**:
  - Incremental search updates (add/remove characters)
  - Search state caching for performance
  - Async search with cancellation support

##### BinarySearchStrategy (Alternative)
- **Algorithm**: Binary search on sorted arrays
- **Benefits**:
  - O(log n) search complexity
  - Memory efficient
  - Good for prefix-based searches
- **Implementation Details**:
  - Maintains separate sorted arrays for different fields
  - Binary search for prefix matching
  - Relevance scoring for result ranking

#### 3. Performance Optimizations
- **Async Search**: Non-blocking UI operations
- **Task Cancellation**: Prevents unnecessary work for outdated queries
- **Incremental Updates**: Efficient updates for character-by-character typing
- **Memory Management**: Efficient data structures and cleanup

#### 4. User Experience Enhancements
- **Debouncing**: Prevents excessive API calls during typing
- **Loading States**: Visual feedback during search operations
- **Pagination**: Efficient handling of large result sets

## 🎯 Key Design Decisions & Assumptions

### 1. Architecture Decisions

#### MVVM + Coordinator Pattern
- **Decision**: Combined MVVM with Coordinator pattern
- **Rationale**: 
  - MVVM provides clean separation of concerns
  - Coordinator handles complex navigation logic
  - Better testability and maintainability
- **Benefits**: Clear responsibilities, easy testing, scalable navigation

#### Protocol-Oriented Design
- **Decision**: Use of protocols for abstraction
- **Rationale**: 
  - Enables easy mocking for testing
  - Supports dependency injection
  - Allows for flexible implementations
- **Examples**: `CitySearchStrategy`, `CityDataProvider`, `CitySearchViewState`

### 2. Search Implementation Decisions

#### Strategy Pattern for Search
- **Decision**: Multiple search strategies instead of single algorithm
- **Rationale**:
  - Different algorithms excel at different scenarios
  - Easy to benchmark and optimize
  - Future extensibility for new search methods
- **Implementation**: Service can switch strategies at runtime

#### Async Search Operations
- **Decision**: All search operations are async
- **Rationale**:
  - Prevents UI blocking
  - Enables cancellation of outdated searches
  - Better user experience
- **Implementation**: Uses Swift's async/await with Task management

### 3. Data Management Decisions

#### Local Data Storage
- **Decision**: Cities data stored locally in JSON format
- **Rationale**:
  - Fast access without network dependencies
  - Offline functionality
  - Consistent performance
- **Implementation**: `CityDataProvider` abstraction for data sources

#### Observable State Management
- **Decision**: Heavy use of `@Published` properties
- **Rationale**:
  - Automatic UI updates
  - Reactive programming model
  - SwiftUI integration
- **Implementation**: Combine framework integration throughout

### 4. User Experience Decisions

#### Orientation-Aware Layout
- **Decision**: Different views for portrait vs landscape
- **Rationale**:
  - Better space utilization on different orientations
  - Tailored user experience for each mode
  - Follows iOS design guidelines
- **Implementation**: Dynamic view switching with smooth transitions

#### Split Navigation Approach
- **Decision**: Custom split view implementation instead of SplitNavigationView
- **Rationale**:
  - SplitNavigationView would be ideal for landscape mode on iPhone
  - Provides master-detail layout with navigation capabilities
  - Better user experience for browsing and selecting cities
- **Implementation Challenges**:
  - SplitNavigationView has limited support on iPhone in landscape mode
  - iOS 16+ SplitNavigationView doesn't work consistently on iPhone landscape
  - Custom implementation provides better control over layout and behavior
- **Current Solution**: Custom HStack-based split layout with manual navigation management

#### State Persistence
- **Decision**: Maintain state across orientation changes
- **Rationale**:
  - Seamless user experience
  - No data loss during device rotation
  - Consistent behavior
- **Implementation**: Coordinator-based state management

### 5. Performance Assumptions

#### Dataset Size
- **Assumption**: Cities dataset is typically < 200,000 entries
- **Rationale**: Most countries have limited major cities
- **Impact**: Memory-efficient algorithms chosen over disk-based solutions

#### Search Frequency
- **Assumption**: Users type continuously during search
- **Rationale**: Typical search behavior in mobile apps
- **Impact**: Incremental search optimization prioritized

#### Device Capabilities
- **Assumption**: Modern iOS devices with sufficient memory
- **Rationale**: iOS 15+ target with good hardware support
- **Impact**: In-memory data structures and algorithms

## 🧪 Testing Strategy

### Unit Testing
- **ViewModels**: Business logic and state management
- **Services**: Search algorithms and data operations
- **Models**: Data validation and transformations

### Mock Objects
- **MockCoordinator**: Navigation testing
- **MockServices**: Isolated component testing
- **MockDataProviders**: Data loading scenarios

### Test Coverage
- **Search Algorithms**: Performance and accuracy
- **State Management**: UI state consistency
- **Navigation**: Coordinator behavior
- **Data Operations**: CRUD operations and error handling

## 🚀 Future Enhancements

### Potential Improvements
1. **Advanced Filtering**: Population, timezone, language filters
2. **Search Analytics**: User behavior tracking
3. **Machine Learning**: Personalized search results

### Scalability Considerations
- **Lazy Loading**: For very large datasets
- **Caching**: Redis or Core Data for frequently accessed data
- **Background Processing**: Async indexing and updates

## ⚠️ Known Issues & Remaining Work

### Remaining Implementation Work
- **View Model Management**: Implement proper view model lifecycle management
- **Error Handling**: Add comprehensive error handling for search failures and data loading issues
- **Loading States**: Improve loading state management and user feedback
- **Performance Optimization**: Fine-tune search algorithms for better performance with large datasets
- **Search Algorithm Benchmarking**: Add more search strategies for performance comparison:
  - **Linear Search**: Baseline implementation for comparison
  - **Hash Table Search**: O(1) lookup for exact matches
  - **Suffix Array Search**: Efficient substring and fuzzy matching
  - **Bloom Filter**: Fast negative result filtering for large datasets

### Time Constraints
- **Development Timeline**: Limited time available for complete implementation
- **Priority**: Focus was on core architecture and search functionality
- **Scope**: Basic functionality implemented, advanced features deferred
- **Testing**: Limited testing coverage due to time constraints

## 📱 Requirements

- **iOS**: 15.0+
- **Swift**: 5.5+
- **Xcode**: 14.0+
- **Dependencies**: SwiftUI, Combine, Foundation

## 🏃‍♂️ Getting Started

1. Clone the repository
2. Open `UalaCities.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

## 📄 License

This project is proprietary and confidential. All rights reserved.
