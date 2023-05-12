//
//  UserLoginView.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import SwiftUI

struct UserLoginView: View {
    @ObservedObject var viewModel: UserLoginViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Create an account")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .padding(.bottom, 30)
                
                FormField(fieldValue: $viewModel.username, fieldName: "Username", isSecure: false)
                    .padding()
                
                FormField(fieldValue: $viewModel.password, fieldName: "Password", isSecure: true)
                    .padding()
                
                Spacer(minLength: 50)
                
                ProgressButton(
                    text: "Sign In",
                    disabled: !viewModel.isSignInEnabled,
                    inProgress: viewModel.loginState == .progress,
                    action: viewModel.signIn)
                
                Spacer(minLength: 50)
                
                HStack {
                    Text("Don't have an account?")
                        .font(.system(.body, design: .rounded))
                        .bold()
                    
                    TextButton(text: "Sign up") {
                        print("-> Sign Up")
                    }
                }
            }
            .padding()
        }
    }
}

struct UserLoginView_Previews: PreviewProvider {
    static var previews: some View {
        let userLoginService = MockUserLoginService()
        let viewModel = UserLoginViewModel(userLoginService: userLoginService)
        UserLoginView(viewModel: viewModel)
    }
}
