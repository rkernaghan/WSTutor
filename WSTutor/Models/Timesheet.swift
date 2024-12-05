//
//  Timesheet.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-11-23.
//

import Foundation

// Timesheet is a class to hold one Tutor Timesheet for one month.  It consists of an array of TimesheetRow classes, each of which holds a Timesheet row (one tutoring session)
//
@Observable class Timesheet: Identifiable {
	var timesheetRows = [TimesheetRow]()
	var isTimesheetLoaded: Bool
	
	init() {
		isTimesheetLoaded = false
	}
	//
	// This function adds one row to a Timesheet
	//		timesheetRow: an object containing data from one row of a Timesheet spreadsheet
	func addTimesheetRow(timesheetRow: TimesheetRow) {
		self.timesheetRows.append(timesheetRow)
	}
	
	//
	// This function reads in a Tutor Timesheet for one month and loads the data into this Timesheet object
	//		tutorName: the name of the tutor who's Timesheet is being loaded
	//		month: the String name of the month to load the Timesheet data from
	//		timesheetID: the Google Drive File ID of the Tutor Timesheet
	//
	func loadTimesheetData(tutorName: String, month: String, timesheetID: String) async -> Bool {
		var completionFlag: Bool = true
		timesheetData.isTimesheetLoaded = false
		timesheetRows.removeAll()
		
		var sheetData: SheetData?
		let range = month + PgmConstants.timesheetReadDataRange
		// read in the cells from one month's Timesheet
		do {
			sheetData = try await readSheetCells(fileID: timesheetID, range: range)
			// Load the sheet cells into this Timesheet
			if let sheetData = sheetData {
				loadTimesheetRows(tutorName: tutorName, sheetCells: sheetData.values)
				isTimesheetLoaded = true
			} else {
				completionFlag = false
			}
		} catch {
			print("ERROR: could not readSheetCells for \(tutorName) Timesheet")
			completionFlag = false
		}
		return(completionFlag)
	}
	
	//
	// This function takes a 2 dimensional array of strings (spreadsheet cells from a Tutor Timesheet for a month) and loads them into this Timesheet object
	//		tutorName: the name of the tutor who's Timesheet is being loaded
	//		sheetCells: a 2 dimensional array of Strings with each element containing one spreadsheet cell
	//
	func loadTimesheetRows(tutorName: String, sheetCells: [[String]] ) {
		
		if sheetCells.count > 0 {
			let entryCount = Int(sheetCells[PgmConstants.timesheetSessionCountRow][PgmConstants.timesheetSessionCountCol]) ?? 0
			var entryCounter = 0
			var rowNum = PgmConstants.timesheetFirstSessionRow - 1				// subtract 1 for zero-based array
			let rowCounter = entryCount + 12                                                // 12 blank rows allowed
			while entryCounter < entryCount && rowNum < rowCounter {
				if sheetCells[rowNum].count == 9 {						// Ignore rows where all cells are not populated
					let date = sheetCells[rowNum][PgmConstants.timesheetDateCol]
					if date != "" && date != " " {
						let student = sheetCells[rowNum][PgmConstants.timesheetStudentCol]
						let date = sheetCells[rowNum][PgmConstants.timesheetDateCol]
						let duration = Int(sheetCells[rowNum][PgmConstants.timesheetDurationCol]) ?? 0
						let service = sheetCells[rowNum][PgmConstants.timesheetServiceCol]
						let note = sheetCells[rowNum][PgmConstants.timesheetNotesCol]
						//					let cost = Float(sheetCells[rowNum][PgmConstants.timesheetCostCol]) ?? 0.0
						//					let clientName = sheetCells[rowNum][PgmConstants.timesheetClientNameCol]
						//					let clientEmail = sheetCells[rowNum][PgmConstants.timesheetClientEmailCol]
						//					let clientPhone = sheetCells[rowNum][PgmConstants.timesheetClientPhoneCol]
						//					let newTimesheetRow = TimesheetRow(studentName: student, serviceDate: date, duration: duration, serviceName: service, notes: notes, cost: cost, clientName: clientName, clientEmail: clientEmail, clientPhone: clientPhone, tutorName: tutorName)
						let newTimesheetRow = TimesheetRow(studentName: student, serviceDate: date, duration: duration, serviceName: service, note: note)
						self.addTimesheetRow(timesheetRow: newTimesheetRow)
						//   print(tutorName, student, date, service)
						entryCounter += 1
					}
				}
				rowNum += 1
			}
		}
	}
	
	func saveTimesheetData(monthName: String, timesheetFileID: String) async -> Bool {
		var completionFlag: Bool = true
		// Write the Timesheet rows to the Tutor Timesheet spreadsheet
		let updateValues = unloadTimesheetRows()
		let count = updateValues.count
		let range = monthName + PgmConstants.timesheetWriteDataRange + String(PgmConstants.timesheetFirstSessionRow + updateValues.count - 1)
		do {
			let result = try await writeSheetCells(fileID: timesheetFileID, range: range, values: updateValues)
			if !result {
				completionFlag = false
			}
		} catch {
			print ("Error: Saving Timesheet rows failed")
			completionFlag = false
		}
		
		return(completionFlag)
	}
	
	
	func unloadTimesheetRows() -> [[String]] {
		
		var updateValues = [[String]]()
		var sessionNum = 0
		let sessionCount = self.timesheetRows.count
		while sessionNum < sessionCount {

			let studentName = timesheetRows[sessionNum].studentName
			let serviceDate = timesheetRows[sessionNum].serviceDate
			let duration = String(timesheetRows[sessionNum].duration)
			let serviceName = timesheetRows[sessionNum].serviceName
			let note = timesheetRows[sessionNum].note
//			let cost = String(timesheetRows[sessionNum].cost.formatted(.number.precision(.fractionLength(2))))
//			let clientName = timesheetRows[sessionNum].clientName
//			let clientEmail = timesheetRows[sessionNum].clientEmail
//			let clientPhone = timesheetRows[sessionNum].clientPhone
//			let tutorName = timesheetRows[sessionNum].tutorName
			
//			updateValues.insert([studentName, serviceDate, duration, serviceName, notes, cost, clientName, clientEmail, clientPhone, tutorName], at: sessionNum)
			updateValues.insert([studentName, serviceDate, duration, serviceName, note], at: sessionNum)
			sessionNum += 1
		}
		
		return( updateValues)
	}
}

