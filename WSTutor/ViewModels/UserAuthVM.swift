//
//  UserAuthModel.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-06-29.
//

import Foundation
import SwiftUI
import GoogleSignIn


@Observable class UserAuthVM {
    
	var isLoggedIn: Bool = false
	var errorMessage: String = ""
	var accessOAuthToken: String = ""
	var refreshOAuthToken: String = ""

	
	init() {
		print("UserAuthVM-init: Starting")
		
		Task {
			await restoreSignIn()
		}
		print("UserAuthVM-init: Ending")
	}
	

	func signIn() async {
		guard let presentingViewController = await UIApplication.shared.connectedScenes
			.compactMap({ $0 as? UIWindowScene })
			.first?.keyWindow?.rootViewController else {
			print("UserAuthVM-signin: Could not get presenting view controller")
			return
		}
		
		do {
			print("UserAuthVM-signIn: About to attempt Sign In")
			let _ = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
			print("UserAuthVM-signIn: Sign In Request Successful")
			await checkSignInStatus()
			
		} catch {
			print("UserAuthVM-signin: Signin request failed \(error.localizedDescription)")
		}
	}
	
	
	// Attempts to restore previous Google signin
	//
	func restoreSignIn() async {
		do {
			try await GIDSignIn.sharedInstance.restorePreviousSignIn()
			print("UserAuthVM-restoreSignIn: Successfully restored previous signin")
			await checkSignInStatus()
			
		} catch {
			self.errorMessage = "error: \(error.localizedDescription)"
			print("UserAuthVM-restoreSignIn: Could not restore previous signin \(self.errorMessage)")
		}
	}
	
	// Checks if user is logged in and if so:
	//		- sets up OAuth attributes to manage token expiry
	//		- determines whether the user already has necessary Google scope
	//
	func checkSignInStatus() async {
		var tokenExpirationDate: Date?
		
		print("UserAuthVM-checkSignInStatus: Starting checkSignInStatus")
		
		if (GIDSignIn.sharedInstance.currentUser != nil) {
			print("UserAuthVM-checkSignInStatus: User is logged in")
			
			let user = GIDSignIn.sharedInstance.currentUser
			guard let user = user else {
				print("UserAuthVM-checkSignInStatus: User signed in but user is nil, returning early")
				return }
			
			let currentUser = GIDSignIn.sharedInstance.currentUser
			if let user = currentUser {
				
				let clientID = GIDSignIn.sharedInstance.configuration?.clientID
				let currentUser = GIDSignIn.sharedInstance.currentUser
				if let user = currentUser {
					accessOAuthToken = user.accessToken.tokenString
					refreshOAuthToken = user.refreshToken.tokenString
					tokenExpirationDate = user.accessToken.expirationDate
				}
				
				if let tokenExpirationDate = tokenExpirationDate {
					oauth2Token.accessToken = accessOAuthToken
					oauth2Token.refreshToken = refreshOAuthToken
					oauth2Token.expiresAt = tokenExpirationDate
					oauth2Token.clientID = clientID
				}
				
						print("\nUserAuthVM-checkSignInStatus: accessToken: \(accessOAuthToken)")
						print("UserAuthVM-checkSignInStatus: refreshToken: \(refreshOAuthToken)")
						print("UserAuthVM-checkSignInStatus: tokenExpirationDate: \(String(describing: tokenExpirationDate))")
						print("UserAuthVM-checkSignInStatus: clientID: \(String(describing: clientID))\n")
				
				let scopeStatus = checkAuthScope()
				if !scopeStatus {
					print("UserAuthVM-checkSignInStatus: User did not have scope, requesting it")
					let scopeRequest = await getAuthScope()
					if scopeRequest {
						print("UserAuthVM-checkSignInStatus: Scope request succeeded")
						self.isLoggedIn = true
					} else {
						self.isLoggedIn = false
						print("UserAuthVM-checkSignInStatus: Scope request failed")
					}
				} else {
					print("UserAuthVM-checkSignInStatus: User already has scope")
					self.isLoggedIn = true
				}
			} else {
				print("UserAuthVM-checkSignInStatus: User not logged in")
				self.isLoggedIn = false
			}
		} else {
			print("UserAuthVM-checkSignInStatus: User is not logged in")
			self.isLoggedIn = false
		}
	}
	
	

	
	func checkAuthScope() -> Bool {
		
		let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets"]
		//       let additionalScopes = ["https://www.googleapis.com/auth/drive.readonly"]
		//      let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets"]
		guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
			print("UserAuthVM-checkAuthScope: Not signed in")
			return(false) ;  /* Not signed in. */
		}
		let grantedScopes = currentUser.grantedScopes
		if grantedScopes == nil || !grantedScopes!.contains(additionalScopes) {
			print("UserAuthVM-checkAuthScope - Need to request additional scope")
			return(false)
			
		} else {
			print("UserAuthVM-checkAuthScope - Already have scope")
			return(true)
		}
	}
	
	func getAuthScope() async -> Bool {
		print("UserAuthVM-getAuthScope: Starting")
		
		let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets"]
		
		guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
			print("UserAuthVM-getAuthScope: Not signed in")
			return false
		}
		
		guard let presentingViewController = await UIApplication.shared.connectedScenes
			.compactMap({ $0 as? UIWindowScene })
			.first?.keyWindow?.rootViewController else {
			print("UserAuthVM-getAuthScope: No presenting window")
			return false
		}
		
		do {
			let signInResult = try await currentUser.addScopes(additionalScopes, presenting: presentingViewController)
			print("UserAuthVM-getAuthScope: Additional scopes granted.")
			
			if let grantedScopes = signInResult.user.grantedScopes {
				print("UserAuthVM-getAuthScope: Granted scopes: \(grantedScopes)")
			}
			
			self.isLoggedIn = true
			return true
			
		} catch {
			print("UserAuthVM-getAuthScope: Error requesting additional scopes: \(error.localizedDescription)")
			self.isLoggedIn = false
			return false
		}
	}

	
	func signOut() {
		GIDSignIn.sharedInstance.signOut()
		isLoggedIn = false
	}
}

