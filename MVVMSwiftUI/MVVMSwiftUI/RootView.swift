//
//  RootView.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationView {
//            UserRegisterView()
        }
        .navigationViewStyle(.stack)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
