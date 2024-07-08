//
//  UserAuthModel.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-06-29.
//

import Foundation
import SwiftUI
import GoogleSignIn


class UserAuthModel: ObservableObject {
    
    @Published var givenName: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    
    init(){
        check()
    }
    
    func checkStatus(){
        if(GIDSignIn.sharedInstance.currentUser != nil){
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else {
                return }
            let givenName = user.profile?.givenName
            
            self.givenName = givenName ?? ""
            print(self.givenName)
            checkAuthScope()
            self.isLoggedIn = true
        } else {
            self.isLoggedIn = false
            self.givenName = "Not Logged In"
        }
    }
    
    func check(){
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
                print(self.errorMessage)
            }
            
            self.checkStatus()
        }
    }
    
    func checkAuthScope() {
//        let user = GIDSignIn.sharedInstance.currentUser
//        guard let user = user else { return }
//        let grantedScopes = user.grantedScopes
//        print(grantedScopes)
        let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets"]
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            return ;  /* Not signed in. */
        }
        let grantedScopes = currentUser.grantedScopes
        if grantedScopes == nil || !grantedScopes!.contains(additionalScopes) {
          // Request additional  scope.
            guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                return}
            
//             currentUser.addScopes(additionalScopes, presenting: (UIApplication.shared.windows.last?.rootViewController)!) { signInResult, error in

            currentUser.addScopes(additionalScopes, presenting: presentingViewController) { signInResult, error in
                guard error == nil else {
                    return }
                guard let signInResult = signInResult else {
                    let temp = signInResult
                    return }
                let grantedScopes = currentUser.grantedScopes
            if grantedScopes == nil || !grantedScopes!.contains(additionalScopes) {
                    print("Additional scopes not granted")
                }
                else {
                    print("Got the additional scopes")
                    readData()
                }

            }
//            let grantedScopes = currentUser.grantedScopes
            // Check if the user granted access to the scopes you requested.
        }
    }
    
    func signIn(){
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController) {signInResult, error in
                guard let result = signInResult else {
                    // Inspect error
                    return
                }
                self.checkAuthScope()
  //              readData()
  //              TimeEntryView()
                // If sign in succeeded, display the app's main content View.
            }
  //              self.checkAuthScope()
  //              self.checkStatus()
  //              readData()
            }
        
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
    }
}
