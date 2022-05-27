import SwiftUI
import Helm

@main
struct AppMain: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(\.managedObjectContext, CoreDataStack.shared.context)
    }
  }
}


struct RootView: View {
  @StateObject private var _helm: Helm = try! Helm(nav: segues)
  
  var body: some View {
    HomeView()
      .environmentObject(_helm)
  }
}
