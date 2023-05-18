import SwiftUI
import UIKit

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search..."
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }
}

extension SearchBar {
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(_ text: Binding<String>) {
            self._text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchBar.showsCancelButton = true
            text = searchText
        }
        
        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.showsCancelButton = true
            return true
        }
        
        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            return true
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            endEditing(searchBar: searchBar, text: searchBar.text ?? "")
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            endEditing(searchBar: searchBar, text: "")
        }
        
        private func endEditing(searchBar: UISearchBar, text searchText: String) {
            text = searchText
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
            searchBar.endEditing(true)
        }
    }
    
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
    }
}
