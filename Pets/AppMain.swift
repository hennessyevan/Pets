import SwiftUI

@main
struct AppMain: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      HomeView()
        .environment(\.managedObjectContext, CoreDataStack.shared.context)
    }
  }
}
