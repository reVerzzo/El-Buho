import Foundation
import Observation

@Observable
class BookListViewModel {
    var isProfilePresented: Bool = false
    
    func toggleProfilePresentation() {
        isProfilePresented.toggle()
    }
}