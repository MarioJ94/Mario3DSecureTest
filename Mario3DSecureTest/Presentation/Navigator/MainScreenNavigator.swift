import SwiftUI

protocol MainScreenNavigatorProtocol {
    func getSecondScreen() -> any View
}

final class MainScreenNavigator: MainScreenNavigatorProtocol {
    func getSecondScreen() -> any View {
        EmptyView()
    }
}
