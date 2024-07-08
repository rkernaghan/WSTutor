//
//  WSTutorApp.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-06-26.
//

import SwiftUI
import GoogleSignIn

@main
struct WSTutorApp: App {
    @StateObject var userAuth: UserAuthModel =  UserAuthModel()
   
    var body: some Scene {
        WindowGroup {

                ContentView()
            }
            .environmentObject(userAuth)
        
    }
}

