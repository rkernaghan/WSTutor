//
//  ContentView.swift
//  WriteSeattleTimesheet
//
//  Created by Russell Kernaghan on 2024-06-13.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @EnvironmentObject var vm: UserAuthModel
    @EnvironmentObject var ts: TimesheetModel
    @AppStorage("username") var userName: String = "Tutor Name"
    @State var userinput = " "
    
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
                TimeEntryView(selectedStudent: "Student 3")
                    .environmentObject(ts)
                    .environmentObject(vm)
 
 //               SignOutButton()
            } else {
                SignInView()
            }
            Text(vm.errorMessage)
        }.navigationTitle("Login")
    }
}


    
    


