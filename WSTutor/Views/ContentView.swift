//
//  ContentView.swift
//  WriteSeattleTimesheet
//
//  Created by Russell Kernaghan on 2024-06-13.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
	@AppStorage("username") var userName: String = "Tutor Name"
	@State var userinput = " "
	
	let userAuthVM = UserAuthVM()
	let timesheetVM = TimesheetVM()
	
	var body: some View {
		VStack{
			
			if (userAuthVM.isLoggedIn) {
				TimeEntryView()
			} else {
				SignInView()
			}

		}
		.navigationTitle("Login")
		.environment(timesheetVM)
		.environment(userAuthVM)
	}
}

#Preview {
	ContentView()
}


    
    


