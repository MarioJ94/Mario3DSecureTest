import SwiftUI

@main
struct Mario3DSecureTestApp: App {
    var body: some Scene {
        WindowGroup {
//            MainScreen(viewModel: MainScreenViewModel(),
//                       navigator: MainScreenNavigator())
            SecondScreen(url: URL(string: "www.google.es")!)
        }
    }
}
