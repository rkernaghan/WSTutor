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
//    @State var ts: TimesheetModel = TimesheetModel()
//    @State var vm: UserAuthModel

    let vm = UserAuthModel()
    let ts = TimesheetModel()
    
    fileprivate func SignInButton() -> Button<Text> {
        Button(action: {
            vm.signIn()
        }) {
            Text("Sign In")
        }
    }
    
    fileprivate func SignOutButton() -> Button<Text> {
        Button(action: {
            vm.signOut()
        }) {
            Text("Sign Out")
        }
    }
    
    fileprivate func UserInfo() -> Text {
        return Text(vm.givenName)
    }
    
    var body: some View {
        VStack{
            
            if(vm.isLoggedIn){
                TimeEntryView(selectedStudent: " ", selectedService: " ", serviceDate: Date.now, minutes: " ")
 //               .environmentObject(vm)
 
 //               SignOutButton()
            } else {
                SignInView()
            }
            Text(vm.errorMessage)
        }
        .navigationTitle("Login")
        .environment(ts)
        .environment(vm)
    }
}


    
    


