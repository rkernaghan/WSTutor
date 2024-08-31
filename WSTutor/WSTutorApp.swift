//
//  WSTutorApp.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-06-26.
//

import SwiftUI
import GoogleSignIn

struct PgmConstants {
    static let monthNames = ["Jan", "Feb", "Mar", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
    static let firstTimesheetRow = 5
    static let servicePrompt = "Choose Service"
    static let studentPrompt = "Choose Student"
    static let notePrompt = "Choose Note"
}
var submitErrorMsg: String = " "

@main
struct WSTutorApp: App {
    @State var userAuth: UserAuthModel =  UserAuthModel()
    @State var timeSheet: TimesheetModel =  TimesheetModel()
    
    var body: some Scene {
        WindowGroup {

                ContentView()
            }
    }
}

