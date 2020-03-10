## Architecture high level overview

The app is built in a Redux-like architecture with the following key components:

- _view model_ responsible for implementation of business logic, powered by a state machine
- _view controller_ that manages the view state, rendering of UI elements and delivering UI events to the view model
- _flow controller_ that manages navigation between and in the flows
- _factory_ that creates all the mentioned components and wires them together

### View model

The state machine that powers view models is implemented with recursive application of reducer function that accepts current state and event, mutates the state accordingly and returns side effects appropriate for the event. Each side effect produces a new event that is then recursively passed to the reducer function and so on. This approach allows to define clear inputs (events) and outputs (observers of the state) for the view model.

Unlike Redux there is no global state (store) and it is not passed around to be able to dispatch events into it. Instead each user story (or feature) has its own isolated and private state which is only exposed to external components via observing APIs and which requires any external inputs specified explicitly and injected into the view model via initialiser. On practice such global state is rarely needed as most of the time features are only concerned about their local state. 

### View controller

Every time when view model's state changes the new state value is passed to the view controller via observer closure. The responsibility of the view controller then is to create a representation of the UI appropriate for this state in it's `render` method. This representation is effectively a "virtual UI tree", conceptually similar to React and SwiftUI.  Each component describes a particular view with all its properties that can be configured. Component is responsible for creating the view and rendering it by passing its configuration properties to the view (typically via view's `configure` function). This is also when UI action callbacks are set on the view which result in the events sent back to the view model.

To be able to compose different components together as they are implemented as generic types type erasure pattern is used. Same patter is applied to implement component modifiers, i.e. accessibility modifier. This comes with some additional code complexity but results in a more flexible APIs, i.e. accessibility modifier can be applied on any component without changing APIs of these components.

### Flow controller

When UI action happens, i.e. the button is pressed, the specific event with a specific payload (if needed) is created and passed to the view model's state machine reducers. As a result the state may change which will render a new UI. Events can also trigger new flows. For that flow controller is observing the state of the view model and when it changes to a particular state the flow controller performs a presentation of a new view controller (backed by a view model and a flow controller as well), i.e. push or modal presentation. 

When the primary action of a new flow is complete it is responsible for providing a result value to the view model that invoked it. This is done either as a callback (when the result can be produced multiple times) or via `Future`. This value is then packed into the event that is again passed to the view models reducer and a new state and new UI is produced.

### Side effects

All side effects are implemented as a `Future` which is an abstraction over asynchronous operation and represents the value that is not yet known but will be known at a later point, or as callbacks when the side effect can produce a result multiple times. This is because `Future` can produce value only once and then caches it as soon as it is produced. Alternatively to callbacks `Observable` (RxSwift) or `Signal`/`SignalProducer` (ReactiveSwift) patterns could be used.

## Modules structure

The app is built off the following modules:

- _Future_ implements `Future` and `StateMachine` types
- _Domain_ defines basic data types and services interfaces
- _DataAccess_ implements domain service interfaces
- _DesignLibrary_ implements UI components agnostic of domain types
- _ConverterFeature_ implements actual converter feature with view models, controllers and flow controllers (could be broken down into two modules for exchange rates list and for selection of currencies but that's left out of scope). 
- App itself that wires domain access layer with feature

ConverterFeature only depends on the Domain and DesignLibrary modules as it needs them to build a feature. In some sense DesignLibrary can be compared with UIKit and Domain with Foundation. Unless we need to write a cross platform app that is supposed to render UI on different platforms using different underlying UI libraries (UIKit vs AppKit) it does not make much sense to abstract it (and with SwiftUI and Catalyst apps it's not needed either). Domain layer is something that is a fundamental building block of the app and can already be made cross platform as it does not depend on any platform specific types (i.e. URLSession).

The app is responsible for "wiring" things together by providing ConverterFeature with concrete implementations of services from DataAccess module. This way we can test layers in isolation and then have an integration/end-to-end tests (UI tests) to ensure things are wired properly.

As an experiment all modules are implemented as a local SPM packages. This comes with a tradeoff of not being able to use resources in these packages, but they are only needed by tests - in the actual app localisation and assets are stored in the app bundle and bundle reference is injected to other modules (specifically DesignLibrary) to access those resources. The huge benefit of using SPM packages for that is being able to describe modules and their dependencies without project files which are much harder to reason about.

## Design Library

DesignLibrary provides a collection of views and `Component`s used by the feature. It is domain agnostic (does not depend on Domain). Each design library primitive is implemented as a `Component` and corresponding `View`. 

Besides the actual views design library implements some essential "container" components, like `HostViewComponent` that can render any other component in a host view and `TableViewComponent` that uses a `TableViewAdapter` to implement UITableView delegate and data source methods.

DesignLibraryPreview is a separate framework implemented to provide SwiftUI previews for design library views (as it requires assets and localisation resources). To see previews select `DesignLibraryPreview` scheme and one of the preview swift files. It can take some time to render the first time as it may need to build all the packages, but after that it would rebuild only DesignLibrary (and its tests as SwiftUI previews seem to compile all the targets they find in the packages they depend on).

## Testing

Various types of tests are implemented:

- unit tests for testing view models and view controllers, and other components
- UI tests for end-to-end testing

In reality it would be a good idea to implement UI tests in a way that they won't depend on a real network, i.e. by serving the app with a set of predefined stubbed responses, or via a localhost web server running from a UI test process that would receive application network calls instead of a real remote service (i.e. based on SwiftNIO).

## Considerations

As this architecture results in rendering new UI on each state change few optimisations were put in place to ensure a better UX:

 - views are being reused when possible instead of being recreated on each state change
 - updates to the currencies are implemented not as a side effect inside the state machine but as a separate observer that updates the labels in the cells directly. The reason for that is that if each update to the rates every second will result in updating UI and the table view used to render the list of the exchange rates will need to refresh its rows, which will reset their states. So for example if user is in a process of deleting a currency pair the new exchange rate for this currency pair will result in refreshing the state of the cell and so will hide the "delete" button. This could be probably worked around with tracking of internal table view and cells state but this sounds tricky and error prone, having as little stateful components as possible is a better practice.
 
 Other tradeoffs of this architecture and its implementation:
 
 - animations can be challenging as state changes result in UI updates which can interrupt animations
 - refreshing UI can be costly so it's better to not refresh things that are not supposed to be refreshed, i.e. not to reload whole table view content but instead use diffing algorithms to determine what cells need to be refreshed/moved/deleted/inserted (this is left out scope also because builtin APIs for that are iOS 13 only)
- the implementation of UI components is naive and probably can be optimised from types system point of view
 
 In production app I'd use SwiftUI (when it's ready for wide production use), which has a similar approach to representing UI via virtual tree, but better implemented (and richer) APIs and a different approach to the data flow.
 
 The benefit of this architecture is that it defines much stricter patterns on implementing features than vanilla UIKit which results in a higher global code consistency. This makes the code easier to reason about (of course if the implementation of this architecture comes with a sensible and easy to understand APIs), easier to test (most of UI can be tested in unit tests by inspecting its virtual representation without actually creating any views).

There are some additional improvements that could be made to the implementation but left out of scope:

- cancelation of networking requests when new request comes in while previous haven't yet finished
- exponential backoff for network errors
- asserting view model states via reflection to improve error messages (show only relevant differences instead of full values descriptions)
- BDD style unit tests to improve readability and structure of unit tests
- function builders for Components APIs

