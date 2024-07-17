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
//    @ObservedObject var vm = UserAuthModel
//    @State var vm: UserAuthModel
    @Environment(UserAuthModel.self) var userAuthModel: UserAuthModel
    @Environment(TimesheetModel.self) var timesheetModel: TimesheetModel
    
    @AppStorage("username") var userName: String = "Tutor Name"
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
                .onChange(of: userinput) {
                    self.userName = userinput
                }
                .onAppear {
                    userinput = userName
                    print("Loaded: \(userName)")
                }
            Spacer()
            
            GoogleSignInButton(action: {
                userAuthModel.signIn()} )
            .accessibilityIdentifier("GoogleSignInButton")
            .accessibility(hint: Text("Sign in with Google button."))
            .padding()
            
           #if os(iOS)
            .pickerStyle(.segmented)
          #endif
        }
      }
      Spacer()
    }
  }
    

}


