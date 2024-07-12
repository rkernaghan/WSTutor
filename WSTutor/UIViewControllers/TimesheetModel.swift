//
//  TimesheetModel.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-07-11.
//

import Foundation

import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST


final class TimesheetModel: ObservableObject {
    
    @Published var services: [String] = []
    @Published var students: [String] = []
    var serviceCount: Int?
    var studentCount: Int?
    var fileID: String
    
    init() {
      fileID = " "
    }
    
    func fetchData() {
        Task { @MainActor in
            do {
                self.fileID = try await getFileID(fileName: "Tutor 2")
            } catch {
                // .. handle error
            }
        }
    }
    
    func getFileID(fileName: String) async throws -> String {
  
        let driveService = GTLRDriveService()
        let currentUser = GIDSignIn.sharedInstance.currentUser
        
        driveService.authorizer = currentUser?.fetcherAuthorizer

        let dquery = GTLRDriveQuery_FilesList.query()
        dquery.pageSize = 100
        let fileName = "Timesheet 2024 Tutor 2"
        let root = "fullText contains '\(fileName)' and mimeType = 'application/vnd.google-apps.spreadsheet'"
        dquery.q = root
        dquery.spaces = "drive"
        dquery.corpora = "user"
        dquery.fields = "files(id,name),nextPageToken"
        
        let error = try await driveService.executeQuery(dquery)
   
        return(fileID)
    }
}
    

