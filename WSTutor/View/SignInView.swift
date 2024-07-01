//
//  SignInView.swift
//  WriteSeattleTimesheet
//
//  Created by Russell Kernaghan on 2024-06-14.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignInView: View {
//  @EnvironmentObject var authViewModel: AuthenticationViewModel
  @ObservedObject var vm = GoogleSignInButtonViewModel()
    @AppStorage("username") var username: String = "Tutor Name"
    @State var userinput = " "

  var body: some View {
    VStack {
      HStack {
        VStack {
            Spacer()
            
                TextField("Enter your username", text: $userinput)
                .textFieldStyle(.roundedBorder)
                .font(.title)
                .background(.yellow)
                .disableAutocorrection(true)
                .onChange(of: userinput) {text in
                    self.username = userinput
                }
                .onAppear {
                    userinput = username
                    print("Loaded: \(username)")
                }
            Spacer()
            
 //         GoogleSignInButton(action: handleSignInButton)
 //           .accessibilityIdentifier("GoogleSignInButton")
 //           .accessibility(hint: Text("Sign in with Google button."))
 //           .padding()
            
          VStack {
            HStack {
              Text("Button style:")
                .padding(.leading)
              Picker("", selection: $vm.style) {
                ForEach(GoogleSignInButtonStyle.allCases) { style in
                  Text(style.rawValue.capitalized)
                    .tag(GoogleSignInButtonStyle(rawValue: style.rawValue)!)
                }
              }
              Spacer()
            }
            HStack {
              Text("Button color:")
                .padding(.leading)
              Picker("", selection: $vm.scheme) {
                ForEach(GoogleSignInButtonColorScheme.allCases) { scheme in
                  Text(scheme.rawValue.capitalized)
                    .tag(GoogleSignInButtonColorScheme(rawValue: scheme.rawValue)!)
                }
              }
              Spacer()
            }
            HStack {
              Text("Button state:")
                .padding(.leading)
              Picker("", selection: $vm.state) {
                ForEach(GoogleSignInButtonState.allCases) { state in
                  Text(state.rawValue.capitalized)
                    .tag(GoogleSignInButtonState(rawValue: state.rawValue)!)
                }
              }
              Spacer()
            }
          }
          #if os(iOS)
            .pickerStyle(.segmented)
          #endif
        }
      }
      Spacer()
    }
  }
    

}


