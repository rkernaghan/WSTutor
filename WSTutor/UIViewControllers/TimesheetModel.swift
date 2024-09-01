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

@Observable class TimesheetModel  {
    
    var isDataLoaded: Bool
        
    init() {
        isDataLoaded = false
    }
//
// This function loads the Tutor's reference data from their RefDaTa sheet.
// 1) Call Google Drive to search for for the Tutor's timesheet file name in order to get the file's Google File ID
// 2) If only a single file is retreived, call loadStudentServices to retrieve the Tutor's assigned Student list, Services list and Notes options as well as the Tutor service history for the month
//
    func readRefData(fileName: String, timesheetData: TimesheetData, spreadsheetYear: String, spreadsheetMonth: String) {
        
        print("Getting fileID for '\(fileName)'")
        
        let sheetService = GTLRSheetsService()
        let driveService = GTLRDriveService()
        let currentUser = GIDSignIn.sharedInstance.currentUser
        
        sheetService.authorizer = currentUser?.fetcherAuthorizer
        driveService.authorizer = currentUser?.fetcherAuthorizer
        
        let dquery = GTLRDriveQuery_FilesList.query()
        dquery.pageSize = 100
        
        let root = "name = '\(fileName)' and mimeType = 'application/vnd.google-apps.spreadsheet' and trashed=false"
        dquery.q = root
        dquery.spaces = "drive"
        dquery.corpora = "user"
        dquery.fields = "files(id,name),nextPageToken"
// Retreive all files with Tutor timesheet name (should only be one)
        driveService.executeQuery(dquery, completionHandler: {(ticket, files, error) in
            if let filesList : GTLRDrive_FileList = files as? GTLRDrive_FileList {
                
                if let filesShow : [GTLRDrive_File] = filesList.files {
                    let fileCount = filesShow.count
                    switch fileCount {
                    case 0:
                        print("Tutor timesheet file not found - '\(fileName)")
                        GIDSignIn.sharedInstance.signOut()
                    case 1:
                        let name = filesShow[0].name ?? ""
                        timesheetData.fileID = filesShow[0].identifier ?? ""
                        print(name, timesheetData.fileID)
                        self.loadStudentsServices(timesheetData: timesheetData, spreadsheetYear: spreadsheetYear, spreadsheetMonth: spreadsheetMonth)
                    default:
                        print("Error: more than one tutor timesheet for '\(fileName)")
                        GIDSignIn.sharedInstance.signOut()
                    }
                } else {
                    print("no files returned")
                }
            }
            else {
                    print("error no files returned from Drive search call")
                    return
                }
        })
    }
    
   
    func loadStudentsServices(timesheetData: TimesheetData, spreadsheetYear: String, spreadsheetMonth: String)  {
        
        let sheetService = GTLRSheetsService()
        let currentUser = GIDSignIn.sharedInstance.currentUser
        sheetService.authorizer = currentUser?.fetcherAuthorizer
        
        let range = "RefData!A5:P32"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: timesheetData.fileID, range:range)
// Load RefData data for Tutor
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
 //               print(row)
            }
            
            if rows.isEmpty {
                print("No data found.")
                return
            }
            
            print("Student count is '\(rows[0][1])")
            print("Service count is '\(rows[1][1])")
            print("Notes count is '\(rows[2][1])")
            
 //           print("Service 1 is '\(rows[2][3])")
 //           print("Student 1 is '\(rows[2][10])")
            print("Number of rows in sheet: \(rows.count)")
            timesheetData.studentCount = Int(stringRows[0][1])! ?? 0
            timesheetData.serviceCount = Int(stringRows[1][1])! ?? 0
            timesheetData.notesCount = Int(stringRows[2][1])! ?? 0

            
// Load the Tutor's assigned Services
            timesheetData.students.removeAll()          // empty the array before loading as this could be a refresh
            
            timesheetData.students.insert(PgmConstants.studentPrompt, at: 0)
            var studentIndex = 1
            var rowNumber = 2
            while studentIndex <= timesheetData.studentCount {
                timesheetData.students.insert(stringRows[rowNumber][10], at: studentIndex)
                studentIndex += 1
                rowNumber += 1
            }

// Load the Tutor's assigned Services                   // empty the array before loading as this could be a refresh
            timesheetData.services.removeAll()
            timesheetData.services.insert(PgmConstants.servicePrompt, at: 0)
            var serviceIndex = 1
            rowNumber = 2
            while serviceIndex <= timesheetData.serviceCount {
                timesheetData.services.insert(stringRows[rowNumber][3], at: serviceIndex)
                serviceIndex += 1
                rowNumber += 1
            }
            
// Load the Tutor's Notes options
            timesheetData.notes.removeAll()             // empty the array before loading as this could be a refresh
            timesheetData.notes.insert(PgmConstants.notePrompt, at: 0)
            var noteIndex = 1
            rowNumber = 0
            while noteIndex <= timesheetData.notesCount {
                timesheetData.notes.insert(stringRows[rowNumber][15], at: noteIndex)
                noteIndex += 1
                rowNumber += 1
            }
            
// Load the Tutor's service session history
            self.loadMonthSessions(timesheetData: timesheetData, spreadsheetYear: spreadsheetYear, spreadsheetMonth: spreadsheetMonth)
        }
        
    }

// Load the Tutor's service session history for the month
    func loadMonthSessions(timesheetData: TimesheetData, spreadsheetYear: String, spreadsheetMonth: String) {

        let sheetService = GTLRSheetsService()
        let currentUser = GIDSignIn.sharedInstance.currentUser
        sheetService.authorizer = currentUser?.fetcherAuthorizer

        let cellRange = spreadsheetMonth + "!A3:D100"
//        print(cellRange)
        
//        print(timesheetData.fileID)
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: timesheetData.fileID, range:cellRange)
        
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                print("Failed to read timesheet sessions:\(error.localizedDescription)")
                return
            }
            guard let result = result as? GTLRSheets_ValueRange else {
                return
            }
            
            let rows = result.values!
            var stringRows = rows as! [[String]]
            
            for row in stringRows {
                stringRows.append(row)
 //               print(row)
            }
            
            if rows.isEmpty {
                print("No data found.")
                return
            }
// Load the count of service sessions from the Tutor's Timesheet
            timesheetData.sessionCount = Int(stringRows[0][1])! ?? 0
            print("Session count is '\(rows[0][1])")
            print("Session student 1 is '\(rows[2][0])")
            print("timesheet data session count is '\(timesheetData.sessionCount)")
            
// Empty the array before reading in existing timesheet entries for the month
            timesheetData.sessions.removeAll()
            
            var sessionIndex = 0
            var rowNumber = 2
            var loadCount: Int
            
  //          if timesheetData.sessionCount > 3 {
  //              loadCount = 3
  //          }
  //          else {
                loadCount = timesheetData.sessionCount
  //          }
            print(loadCount)
// Load the service sessions from the Tutor's timesheet
            while sessionIndex < loadCount {
                var session = TimesheetRow(sessionDate: stringRows[rowNumber][1], sessionMinutes: stringRows[rowNumber][2], sessionStudent: stringRows[rowNumber][0], sessionService: stringRows[rowNumber][3])
 //               print(session)
                timesheetData.sessions.insert(session, at: sessionIndex)
                sessionIndex += 1
                rowNumber += 1
            }
//            print(timesheetData.sessions)
//
            self.isDataLoaded = true
            print("Session Data Loaded")
        }
    }
    
    func saveTimeEntry(timesheetData: TimesheetData, studentName: String, serviceName: String, duration: String, serviceDate: Date, note: String) {
        
        let spreadsheetID = timesheetData.fileID
        let sessionCount = timesheetData.sessionCount
        
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let stringDate = formatter1.string(from: serviceDate)
        
        let monthNum = Calendar.current.component(.month, from: serviceDate)
        print(monthNum)
        let monthName = PgmConstants.monthNames[monthNum-1]
        print(monthName)
        
        let sheetService = GTLRSheetsService()
        let currentUser = GIDSignIn.sharedInstance.currentUser
        
        sheetService.authorizer = currentUser?.fetcherAuthorizer
            
        let newRow = PgmConstants.firstTimesheetRow + sessionCount
        print("New row", newRow)
        let newRowString = String(newRow)
        let range = monthName + "!A" + newRowString + ":E" + newRowString
        print("Range", range)
 //       let updateValues = [[studentName, serviceDate, duration, serviceName]]
        let updateValues = [[studentName, stringDate, duration, serviceName, note]]
        let valueRange = GTLRSheets_ValueRange() // GTLRSheets_ValueRange holds the updated values and other params
        valueRange.majorDimension = "ROWS" // Indicates horizontal row insert
        valueRange.range = range
        valueRange.values = updateValues
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetID, range: range)
        query.valueInputOption = "USER_ENTERED"
        sheetService.executeQuery(query) { ticket, object, error in
            if let error = error {
                print(error)
                print("Failed to save data:\(error.localizedDescription)")
                return
            }
            else {
                print("service entry saved")

                let currentDate = Date.now
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "M"
                let currentMonth = formatter1.string(from: currentDate)
                let currentMonthNum = Int(currentMonth)
                let currentMonthName = PgmConstants.monthNames[currentMonthNum! - 1]
                formatter1.dateFormat = "yyyy"
                let spreadsheetYear = formatter1.string(from: currentDate)
 
                self.loadMonthSessions(timesheetData: timesheetData, spreadsheetYear: spreadsheetYear, spreadsheetMonth: currentMonthName)
                print("reloaded month sessions after Save")
            }
        }
    }
    
    func validateTimesheetInput(selectedStudent: String, selectedService: String, selectedNote: String, duration: String, serviceDate: Date) -> Bool {
        
        var validationResult = true
        submitErrorMsg = " "
        
        if selectedStudent == PgmConstants.studentPrompt {
            print("Student not selected")
            submitErrorMsg += "Error: Student not selected \n"
            validationResult = false
        }
        
        if selectedService == PgmConstants.servicePrompt {
            print("Service not selected")
            submitErrorMsg += "Error: Service not selected \n"
            validationResult = false
        }
        
        if selectedNote == PgmConstants.notePrompt {
            print ("Note not selected")
            submitErrorMsg += "Error: Note not selected \n"
            validationResult = false
        }
        
        let minutes = Int( duration.trimmingCharacters(in: .whitespacesAndNewlines) ) ?? 0
        if (minutes < 1) || (minutes > 240) {
            print ("invalid duration")
            submitErrorMsg += "Error: Invalid duration"
            validationResult = false
        }
        
        return(validationResult)
        
        }
    

}
    

