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

@Observable class TimesheetVM  {
    
	var isDataLoaded: Bool
	
	init() {
		isDataLoaded = false
	}
	
	func checkTutorName(tutorName: String) async -> Bool {
		var checkResult: Bool = true
		print("TimesheetVM-checkTutorName: checking tutor name \(tutorName)")
		
		if tutorName.isEmpty {
			return false
		} else {
			let range = tutorName + "!A1:A1"
			do {
				let sheetCells = try await readSheetCells(fileID: tutorDetailsFileID, range: range)
				if sheetCells == nil {
					print("TimesheetVM-checkTutorName: unable to read tutor details")
					checkResult = false
				} else {
					print("TimesheetVM-checkTutorName: tutor details found")
					checkResult = true
				}
			} catch {
				checkResult = false
			}
		}
		return(checkResult)
	}
	
	//
	// This function loads the Tutor's reference data from their RefDaTa sheet.
	// 1) Call Google Drive to search for for the Tutor's timesheet file name in order to get the file's Google File ID
	// 2) If only a single file is retreived, call loadStudentServices to retrieve the Tutor's assigned Student list, Services list and Notes options as well as the Tutor service history for the month
	//
	func getTutorData(tutorName: String, tutorData: Tutor) async -> Bool {
		var readResult: Bool = true
		
		// Read in the Tutor Details sheet for the Tutor to get the Timesheet File ID, Services assigned to the Tutor, Students assigned to the Tutor and Notes avaiable to the Tutor
		let range = PgmConstants.tutorDataRange
		
		if runMode != "PROD" {
			tutorDetailsFileID = PgmConstants.tutorDetailsTestFileID
		} else {
			tutorDetailsFileID = PgmConstants.tutorDetailsProdFileID
		}
		
		let (fetchResult, studentCount, serviceCount, notesCount, timesheetFileID) = await fetchTutorDataCounts(tutorName: tutorName)
		
		if !fetchResult {
			readResult = false
		} else {
			tutorData.timesheetFileID = timesheetFileID
			let loadServicesResult = await tutorData.fetchTutorServiceData(tutorName: tutorName, tutorServiceCount: serviceCount)
			if !loadServicesResult {
				readResult = false
			} else {
				let loadStudentsResult = await tutorData.fetchTutorStudentData(tutorName: tutorName, tutorStudentCount: studentCount)
				if !loadStudentsResult {
					readResult = false
				} else {
					let loadNotesResult = await tutorData.fetchTutorNotesData(tutorName: tutorName, tutorNotesCount: notesCount)
					if !loadNotesResult {
						readResult = false
					} else {
						self.isDataLoaded = true
					}
				}
			}
		}

		return(readResult)
	}
	
	func getTimesheetData(tutorName: String, month: String, timesheetFileID: String) async -> Bool {

		let loadTimesheetResult = await timesheetData.loadTimesheetData(tutorName: tutorName, month: month, timesheetID: timesheetFileID)
		
		return(loadTimesheetResult)
	}
	
	func fetchTutorDataCounts(tutorName: String) async -> (Bool, Int, Int, Int, String){
		var sheetCells = [[String]]()
		var sheetData: SheetData?
		var range: String
		var timesheetFileID: String = ""
		var studentCount: Int
		var serviceCount: Int
		var notesCount: Int
		var fetchResult: Bool = true
		
		// Read in the Tutor Data counts from the Tutor Details spreadsheet
		
		do {
			range = tutorName + PgmConstants.tutorDataRange
			
//			try readSheetCellsSynch(fileID: tutorDetailsFileID, range: range )

			sheetData = try await readSheetCells(fileID: tutorDetailsFileID, range: range )
			
			if let sheetData = sheetData {
				sheetCells = sheetData.values

				timesheetFileID = sheetCells[1][1]
				studentCount = Int( sheetCells[2][1] ) ?? 0
				serviceCount = Int( sheetCells[3][1] ) ?? 0
				notesCount = Int( sheetCells[4][1] ) ?? 0
			} else {
				studentCount = 0
				serviceCount = 0
				notesCount = 0
				fetchResult = false
			}
			
		} catch {
			print("TimesheetVM-fetchTutorDataCounts: Error: could not read Tutor Data Counts for Tutor \(tutorName), will try again")
			do {
				sheetData = try await readSheetCells(fileID: tutorDetailsFileID, range: range )
				
				if let sheetData = sheetData {
					sheetCells = sheetData.values

					timesheetFileID = sheetCells[1][1]
					studentCount = Int( sheetCells[2][1] ) ?? 0
					serviceCount = Int( sheetCells[3][1] ) ?? 0
					notesCount = Int( sheetCells[4][1] ) ?? 0
				} else {
					studentCount = 0
					serviceCount = 0
					notesCount = 0
					fetchResult = false
				}
				
			} catch {
				print("TimesheetVM-fetchTutorDataCounts: Error: could not Tutor Data Counts for Tutor \(tutorName) on second attempt")
				studentCount = 0
				serviceCount = 0
				notesCount = 0
				fetchResult = false
			}
		}
		return(fetchResult, studentCount, serviceCount, notesCount, timesheetFileID)
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
		if let currentMonthInt = Calendar.current.dateComponents([.month], from: Date()).month {
			let timesheetMonthNum = Calendar.current.component(.month, from: serviceDate)
			if currentMonthInt != timesheetMonthNum {
				submitErrorMsg = "Service must be from current month"
				validationResult = false
			}
		}
	
		return(validationResult)
		
	}
	
	
	func saveTimeEntry(timesheetData: Timesheet, studentName: String, serviceName: String, duration: String, serviceDate: Date, note: String, timesheetFileID: String) async -> Bool {
		
		let durationInt = Int(duration) ?? 0
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		let serviceDateString = dateFormatter.string(from: serviceDate)
		
		let monthNumber = Calendar.current.component(.month, from: serviceDate)
		let monthName = PgmConstants.monthNames[monthNumber - 1]
		
		let newTimesheetRow = TimesheetRow(studentName: studentName, serviceDate: serviceDateString, duration: durationInt, serviceName: serviceName, note: note)
		timesheetData.addTimesheetRow(timesheetRow: newTimesheetRow)
		
		let saveResult = await timesheetData.saveTimesheetData(monthName: monthName, timesheetFileID: timesheetFileID)
		
		return(saveResult)
		
	}
	
	
}


