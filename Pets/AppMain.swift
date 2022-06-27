import SwiftUI

@available(iOS 16.0, *)
class AppState: ObservableObject {
	@Published var navigationPath = NavigationPath()

	func popToRoot() {
		navigationPath.removeLast(navigationPath.count)
	}
}

@main
struct AppMain: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
			PetsListView()
        .environment(\.managedObjectContext, CoreDataStack.shared.context)
//				.environmentObject(AppState())
    }
  }
}

