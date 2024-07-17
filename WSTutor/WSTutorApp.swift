//
//  WSTutorApp.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-06-26.
//

import SwiftUI
import GoogleSignIn

let monthNames = ["Jan", "Feb", "Mar", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
let firstTimesheetRow = 5

@main
struct WSTutorApp: App {
    @State var userAuth: UserAuthModel =  UserAuthModel()
    @State var timeSheet: TimesheetModel =  TimesheetModel()
    
    var body: some Scene {
        WindowGroup {

                ContentView()
            }
 //           .environmentObject(userAuth)
 //           .environmentObject(timeSheet)
        
    }
}

