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

	@Environment(UserAuthVM.self) var userAuthVM: UserAuthVM
	@Environment(TimesheetVM.self) var timesheetVM: TimesheetVM
	
	@AppStorage("username") var userName: String = "Tutor Name"
	@State var userinput = " "
	@State private var showAlert = false
	
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
							print("SignInView-OnAppear: User Name: \(userName)")
						}
					Spacer()
					
					GoogleSignInButton(action: {
//						Task {
							userAuthVM.signIn()
//							if userAuthVM.isLoggedIn {
//						Task {
//								let tutorNameFlag = await timesheetVM.checkTutorName(tutorName: userName)
//								if !tutorNameFlag {
//									showAlert = true
//								}
//							}
//						}
					})
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
		.alert("Invalid Tutor Name", isPresented: $showAlert) {
			Button("OK", role: .cancel) { }
		}
	}
	
	
}

#Preview {
	SignInView()
}

