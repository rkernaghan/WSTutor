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
    
    @Published var isDataLoaded: Bool
    @Published var services: [String] = []
    @Published var students: [String] = []
    var serviceCount: Int
    var studentCount: Int
    var fileID: String
    
    init() {
        fileID = " "
        isDataLoaded = false
        serviceCount = 0
        studentCount = 0
    }
    
    func readRefData(fileName: String, timesheetData: TimesheetData) {
        
        print("Getting fileID for '\(fileName)'")
        
        let sheetService = GTLRSheetsService()
        let driveService = GTLRDriveService()
        let currentUser = GIDSignIn.sharedInstance.currentUser
        
        sheetService.authorizer = currentUser?.fetcherAuthorizer
        driveService.authorizer = currentUser?.fetcherAuthorizer
        
        let dquery = GTLRDriveQuery_FilesList.query()
        dquery.pageSize = 100
        
        let root = "name = '\(fileName)' and mimeType = 'application/vnd.google-apps.spreadsheet'"
        dquery.q = root
        dquery.spaces = "drive"
        dquery.corpora = "user"
        dquery.fields = "files(id,name),nextPageToken"
        var ssID: String?
        
        driveService.executeQuery(dquery, completionHandler: {(ticket, files, error) in
            if let filesList : GTLRDrive_FileList = files as? GTLRDrive_FileList {
                if let filesShow : [GTLRDrive_File] = filesList.files {
                    //             print("files \(filesShow)")
                    for ArrayList in filesShow {
                        let name = ArrayList.name ?? ""
                        ssID = ArrayList.identifier ?? ""
                        print(name, ssID)
                    }
                    //              let t = type(of: fileID)
                    //              print("'\(fileID)' of type '\(t)'")
                    //              let spreadsheetID = "1DplB9gONhQK8aurzYyFoLtBZCsB0fh-yhTfGoV0w0TI"
                    let spreadsheetID = ssID!
                    let range = "RefData!A5:K32"
                    let query = GTLRSheetsQuery_SpreadsheetsValuesGet
                        .query(withSpreadsheetId: spreadsheetID, range:range)
                    
                    sheetService.executeQuery(query) { (ticket, result, error) in
                        if let error = error {
                            print(error)
                            print("Failed to read data:\(error.localizedDescription)")
                            return
                        }
                        guard let result = result as? GTLRSheets_ValueRange else {
                            return
                        }
                        
                        let rows = result.values!
                        var stringRows = rows as! [[String]]
                        
                        for row in stringRows {
                            stringRows.append(row)
                            print(row)
                        }
                        
                        if rows.isEmpty {
                            print("No data found.")
                            return
                        }
                        
                        print("Success!")
                        print("Student count is '\(rows[0][1])")
                        print("Service count is '\(rows[1][1])")
                        print("Service 1 is '\(rows[2][3])")
                        print("Student 1 is '\(rows[2][10])")
                        print("Number of rows in sheet: \(rows.count)")
                        timesheetData.studentCount = Int(stringRows[0][1])! ?? 0
                        timesheetData.serviceCount = Int(stringRows[1][1])! ?? 0
                        
                        var studentIndex = 0
                        var rowNumber = 2
                        while studentIndex < timesheetData.studentCount {
                            timesheetData.students.insert(stringRows[rowNumber][10], at: studentIndex)
                            studentIndex += 1
                            rowNumber += 1
                        }
                        
                        var serviceIndex = 0
                        rowNumber = 2
                        while serviceIndex < timesheetData.serviceCount {
                            timesheetData.services.insert(stringRows[rowNumber][3], at: serviceIndex)
                            serviceIndex += 1
                            rowNumber += 1
                        }
                        self.isDataLoaded = true
                        print("Data Loaded")
                    }
                    
                } else {
                    print("no files returned")
                }
                return
            }
        })
    }
    
    func saveTimeEntry(spreadsheetID: String, studentName: String, serviceName: String, duration: String, serviceDate: String) {
        
        let months = ["Jan", "Feb", "Mar", "April", "May", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
        let sheetService = GTLRSheetsService()
        let currentUser = GIDSignIn.sharedInstance.currentUser
        
        sheetService.authorizer = currentUser?.fetcherAuthorizer
    
        let range = "July!B3"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetID, range:range)
        
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                print("Failed to read data:\(error.localizedDescription)")
                return
            }
            guard let result = result as? GTLRSheets_ValueRange else {
                return
            }
            
            let rows = result.values!
            var stringRows = rows as! [[String]]
            
            for row in stringRows {
                stringRows.append(row)
                print(row)
            }
            
            let range = "July!A5:D5"
            let updateValues = [[studentName, serviceDate, duration, serviceName]]
            let valueRange = GTLRSheets_ValueRange() // GTLRSheets_ValueRange holds the updated values and other params
            valueRange.majorDimension = "ROWS" // Indicates horizontal row insert
            valueRange.range = range
            valueRange.values = updateValues
            let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetID, range: range) // Use an append query to append at the first blank row
            query.valueInputOption = "USER_ENTERED"
            sheetService.executeQuery(query) { ticket, object, error in
                if let error = error {
                    print(error)
                    print("Failed to read data:\(error.localizedDescription)")
                    return
                }
            } // `GTLRServiceCompletionHandler` closure containing the service ticket, `GTLRSheets_AppendValuesResponse`, and any error
            
            if rows.isEmpty {
                print("No data found.")
                return
            }
        }
    }
}
    

