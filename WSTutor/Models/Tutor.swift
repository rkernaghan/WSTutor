//
//  Tutor.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-11-23.
//
import Foundation

class Tutor: Identifiable {

	var timesheetFileID: String?
	var studentCount: Int?
	var serviceCount: Int?
	var notesCount: Int?
	var tutorStudents = [TutorStudent]()
	var tutorServices = [TutorService]()
	var tutorNotes = [TutorNote]()
	let id = UUID()
	
//	init( tutorName: String, timesheetFileID: String, tutorStudentCount: Int, tutorServiceCount: Int) {
//		self.tutorName = tutorName
//		self.tutorTimesheetFileID = timesheetFileID
//		self.tutorStudentCount = tutorStudentCount
//		self.tutorServiceCount = tutorServiceCount
//	}
	
	func findTutorStudentByKey(studentKey: String) -> (Bool, Int) {
		var studentFound = false
		var tutorStudentNum = 0
		
		while tutorStudentNum < tutorStudents.count && !studentFound {
			if tutorStudents[tutorStudentNum].studentKey == studentKey {
				studentFound = true
			} else {
				tutorStudentNum += 1
			}
		}
		return(studentFound, tutorStudentNum)
	}
	
	func findTutorServiceByKey(serviceKey: String) -> (Bool, Int) {
		var serviceFound = false
		var tutorServiceNum = 0
		
		while tutorServiceNum < tutorServices.count && !serviceFound {
			if tutorServices[tutorServiceNum].serviceKey == serviceKey {
				serviceFound = true
			} else {
				tutorServiceNum += 1
			}
		}
		return(serviceFound, tutorServiceNum)
	}
	
	func findTutorServiceByName(serviceName: String) -> (Bool, Int) {
		var serviceFound = false
		var tutorServiceNum = 0
		
		while tutorServiceNum < tutorServices.count && !serviceFound {
			if tutorServices[tutorServiceNum].timesheetServiceName == serviceName {
				serviceFound = true
			} else {
				tutorServiceNum += 1
			}
		}
		return(serviceFound, tutorServiceNum)
	}
	
	func loadTutorStudent(newTutorStudent: TutorStudent) {
		tutorStudents.append(newTutorStudent)
	}
	
	
	
	func loadTutorService(newTutorService: TutorService) {
		tutorServices.append(newTutorService)
	}
	
	func loadTutorNote(newTutorNote: TutorNote) {
		tutorNotes.append(newTutorNote)
	}
	
	
	func loadTutorDetails(tutorNum: Int, tutorName: String, tutorDataFileID: String) async -> Bool {
		var completionFlag: Bool = true
		
		if let serviceCount = self.serviceCount {
			if serviceCount > 0 {
				completionFlag = await self.fetchTutorServiceData( tutorName: tutorName, tutorServiceCount: serviceCount)
			}
		}
		if let studentCount = self.studentCount {
			if studentCount > 0  {
				completionFlag = await self.fetchTutorStudentData( tutorName: tutorName, tutorStudentCount: studentCount)
			}
		}
		
		return(completionFlag)
	}
	
	
	func fetchTutorStudentData(tutorName: String, tutorStudentCount: Int) async -> Bool {
		var completionFlag: Bool = true
		
		var sheetCells = [[String]]()
		var sheetData: SheetData?
		
		tutorStudents.removeAll()
		
		// Read in the Tutor Students data from the Tutor Details spreadsheet
		if tutorStudentCount > 0 {
			do {
				let range = tutorName + PgmConstants.tutorStudentsRange + String(PgmConstants.tutorDataStudentsStartingRowNumber + tutorStudentCount - 1)
				sheetData = try await readSheetCells(fileID: tutorDetailsFileID, range: range )
				// Build the Tutor Students list from the cells read in
				if let sheetData = sheetData {
					sheetCells = sheetData.values
					loadTutorStudentRows(tutorStudentCount: tutorStudentCount, sheetCells: sheetCells)
				} else {
					completionFlag = false
				}
			} catch {
				print("ERROR: could not read Tutor Student sheet cells for \(tutorName)")
				completionFlag = false
			}
		}
		return(completionFlag)
	}
	
	
	
	
	func loadTutorStudentRows(tutorStudentCount: Int, sheetCells: [[String]] ) {
		var rowNum = 0
		var studentNum = 0
		while studentNum < tutorStudentCount {
			let studentKey = sheetCells[rowNum][PgmConstants.tutorDataStudentKeyPosition]
			let studentName = sheetCells[rowNum][PgmConstants.tutorDataStudentNamePosition]
			let clientName = sheetCells[rowNum][PgmConstants.tutorDataStudentClientNamePosition]
			let clientEmail = sheetCells[rowNum][PgmConstants.tutorDataStudentClientEmailPosition]
			let clientPhone = sheetCells[rowNum][PgmConstants.tutorDataStudentClientPhonePosition]
			let assignedDate = sheetCells[rowNum][PgmConstants.tutorDataStudentAssignedDatePosition]
			
			let newTutorStudent = TutorStudent(studentKey: studentKey, studentName: studentName, clientName: clientName, clientEmail: clientEmail, clientPhone: clientPhone, assignedDate: assignedDate)
			
			self.loadTutorStudent( newTutorStudent: newTutorStudent)
			rowNum += 1
			studentNum += 1
		}
		//       print("Loaded \(studentCount) Students for Tutor \(referenceData.tutors.tutorsList[tutorNum].tutorName)")
	}
	
	func fetchTutorServiceData(tutorName: String, tutorServiceCount: Int) async -> Bool {
		var completionFlag: Bool = true
		
		var sheetCells = [[String]]()
		var sheetData: SheetData?
	
		tutorServices.removeAll()
	
		// Read in the Tutor Services data from the Tutor Details spreadsheet
		if tutorServiceCount > 0 {
			do {
				let range = tutorName + PgmConstants.tutorServicesRange + String(PgmConstants.tutorDataServicesStartingRowNumber + tutorServiceCount - 1)
				sheetData = try await readSheetCells(fileID: tutorDetailsFileID, range: range)
				// Build the Tutor Services list from the cells read in
				if let sheetData = sheetData {
					sheetCells = sheetData.values
					loadTutorServiceRows(tutorServiceCount: tutorServiceCount, sheetCells: sheetCells)
				} else {
					completionFlag = false
				}
			} catch {
				print("ERROR: could not read Tutor Services sheet cells for \(tutorName)")
				completionFlag = false
			}
		}
		return(completionFlag)
	}
	

	
	func loadTutorServiceRows(tutorServiceCount: Int, sheetCells: [[String]] ) {
		
		var rowNum = 0
		var serviceNum = 0
		
		while serviceNum < tutorServiceCount {
			let serviceKey = sheetCells[rowNum][PgmConstants.tutorDataServiceKeyPosition]
			let timesheetName = sheetCells[rowNum][PgmConstants.tutorDataServiceTimesheetNamePosition]
			let invoiceName = sheetCells[rowNum][PgmConstants.tutorDataServiceInvoiceNamePosition]
			let billingType: BillingTypeOption = BillingTypeOption(rawValue: sheetCells[rowNum][PgmConstants.tutorDataServiceBillingTypePosition]) ?? .Fixed
			let cost1 = Float(sheetCells[rowNum][PgmConstants.tutorDataServiceCost1Position]) ?? 0.0
			let cost2 = Float(sheetCells[rowNum][PgmConstants.tutorDataServiceCost2Position]) ?? 0.0
			let cost3 = Float(sheetCells[rowNum][PgmConstants.tutorDataServiceCost3Position]) ?? 0.0
			let price1 = Float(sheetCells[rowNum][PgmConstants.tutorDataServicePrice1Position]) ?? 0.0
			let price2 = Float(sheetCells[rowNum][PgmConstants.tutorDataServicePrice2Position]) ?? 0.0
			let price3 = Float(sheetCells[rowNum][PgmConstants.tutorDataServicePrice3Position]) ?? 0.0
			
			let newTutorService = TutorService(serviceKey: serviceKey, timesheetName: timesheetName, invoiceName: invoiceName, billingType: billingType, cost1: cost1, cost2: cost2, cost3: cost3, price1: price1, price2: price2, price3: price3)
			
			self.loadTutorService( newTutorService: newTutorService)
			rowNum += 1
			serviceNum += 1
		}
		//       print("Loaded \(serviceCount) Services for Tutor \(referenceData.tutors.tutorsList[tutorNum].tutorName)")
	}
	
	func fetchTutorNotesData(tutorName: String, tutorNotesCount: Int) async -> Bool {
		var completionFlag: Bool = true
		
		var sheetCells = [[String]]()
		var sheetData: SheetData?
		
		tutorNotes.removeAll()
		
		// Read in the Tutor Services data from the Tutor Details spreadsheet
		if tutorNotesCount > 0 {
			do {
				let range =  PgmConstants.tutorNotesRange + String(PgmConstants.tutorDataNotesStartingRowNumber + tutorNotesCount - 1)
				sheetData = try await readSheetCells(fileID: tutorDetailsFileID, range: range)
				// Build the Tutor Notes list from the cells read in
				if let sheetData = sheetData {
					sheetCells = sheetData.values
					loadTutorNotesRows(tutorNotesCount: tutorNotesCount, sheetCells: sheetCells)
				} else {
					completionFlag = false
				}
			} catch {
				print("ERROR: could not read Tutor Notes sheet cells for \(tutorName)")
				completionFlag = false
			}
		}
		return(completionFlag)
	}
	
	
	
	func loadTutorNotesRows(tutorNotesCount: Int, sheetCells: [[String]] ) {
		
		var rowNum = 0
		var noteNum = 0
		
		while noteNum < tutorNotesCount {
			let noteText = sheetCells[rowNum][PgmConstants.tutorDataNoteTextPosition]
			
			let newTutorNote = TutorNote(noteText: noteText)
			
			self.loadTutorNote( newTutorNote: newTutorNote)
			rowNum += 1
			noteNum += 1
		}
	}
}
