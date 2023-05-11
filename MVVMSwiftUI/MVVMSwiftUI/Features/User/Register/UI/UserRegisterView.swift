//
//  UserRegisterView.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import SwiftUI

struct UserRegisterView: View {
    @ObservedObject var viewModel: UserRegisterViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Create an account")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .padding(.bottom, 30)
                
                makeUsernameField()
                
                makePasswordField()
                
                makeRepeatPasswordField()
                
                Spacer(minLength: 50)
                
                GradientButton(
                    text: "Sign Up",
                    disabled: !viewModel.isSignUpEnabled
                ) { print("action!") }
                
                Spacer(minLength: 50)
                
                makeSignInMessage()
                
                Spacer()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func makeUsernameField() -> some View {
        FormField(fieldValue: $viewModel.username, fieldName: "Username", isSecure: false)
        
        VStack(spacing: 2) {
            RequiredText(
                text: "A minimum of 4 characters",
                isStrikeThrough: viewModel.isUsernameLengthValid)
            
            RequiredText(
                text: "Username available",
                isStrikeThrough: viewModel.isUsernameAvailable)
        }
        .padding()
    }
    
    @ViewBuilder
    private func makePasswordField() -> some View {
        FormField(fieldValue: $viewModel.password, fieldName: "Password", isSecure: true)
        
        VStack(spacing: 2) {
            RequiredText(
                iconName: viewModel.isPasswordLengthValid ? "lock" : "lock.open",
                text: "A minimum of 8 characters",
                isStrikeThrough: viewModel.isPasswordLengthValid)
            
            RequiredText(
                iconName: viewModel.isPasswordCapitalLetterValid ? "lock" : "lock.open",
                text: "One uppercase letter",
                isStrikeThrough: viewModel.isPasswordCapitalLetterValid)
                
        }
        .padding()
    }
    
    @ViewBuilder
    private func makeRepeatPasswordField() -> some View {
        FormField(fieldValue: $viewModel.repeatPassword, fieldName: "Repeat password", isSecure: true)
        
        VStack {
            RequiredText(
                text: "Your repeat password should be the same as password",
                isStrikeThrough: viewModel.isPasswordConfirmValid)
        }
        .padding()
    }
    
    @ViewBuilder
    private func makeSignInMessage() -> some View {
        HStack {
            Text("Already have an account?")
                .font(.system(.body, design: .rounded))
                .bold()
            TextButton(text: "Sign in") {
                print("-> Sign In")
            }
        }
    }
}

struct UserRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        let userAvailabilityService = MockUsernameAvailabilityService()
        let viewModel = UserRegisterViewModel(usernameAvailabilityService: userAvailabilityService)
        UserRegisterView(viewModel: viewModel)
    }
}
