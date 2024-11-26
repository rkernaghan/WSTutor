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
	
	static let tutorDataStudentCountRow = 3
	static let tutorDataStudentCountCol = 1
	static let tutorDataServiceCountRow = 4
	static let tutorDataServiceCountCol = 1
	
	static let tutorDataStudentsStartingRowNumber = 3
	static let tutorDataStudentKeyPosition = 0
	static let tutorDataStudentNamePosition = 1
	static let tutorDataStudentClientNamePosition = 2
	static let tutorDataStudentClientEmailPosition = 3
	static let tutorDataStudentClientPhonePosition = 4
	static let tutorDataStudentAssignedDatePosition = 5
	
	static let tutorDataServicesStartingRowNumber = 3
	static let tutorDataServiceKeyPosition = 0
	static let tutorDataServiceTimesheetNamePosition = 1
	static let tutorDataServiceInvoiceNamePosition = 2
	static let tutorDataServiceBillingTypePosition = 3
	static let tutorDataServiceCost1Position = 4
	static let tutorDataServiceCost2Position = 5
	static let tutorDataServiceCost3Position = 6
	static let tutorDataServicePrice1Position = 7
	static let tutorDataServicePrice2Position = 8
	static let tutorDataServicePrice3Position = 9
	
	static let tutorDataNoteTextPosition: Int = 0
	static let tutorNotesRange: String = "RefData!B2:B"
	static let tutorDataNotesStartingRowNumber: Int = 2
	
	static let timesheetSessionCountRow: Int = 2
	static let timesheetSessionCountCol: Int = 1
	static let timesheetFirstSessionRow: Int = 5
	static let timesheetStudentCol = 0
	static let timesheetDateCol = 1
	static let timesheetDurationCol = 2
	static let timesheetServiceCol = 3
	static let timesheetNotesCol = 4
	static let timesheetCostCol = 5
	static let timesheetClientNameCol = 6
	static let timesheetClientEmailCol = 7
	static let timesheetClientPhoneCol = 8
	static let timesheetReadDataRange = "!A1:I102"
	static let timesheetWriteDataRange = "!A5:E"
	static let timesheetTutorNameCell = "RefData!A2:A2"
	
	static let tutorDataRange = "!A2:B6"
	static let tutorCountsRange = "!A1:B5"
	static let tutorStudentsRange = "!O3:T"
	static let tutorServicesRange = "!D3:M"
	static let tutorDataCountsRange = "!B4:B5"
	static let tutorDataTutorNameCell = "!A3:A3"
	
	static let tutorDetailsProdFileID = "1W6AUOVc91D1YCm2miloHQeMmcOZc2jjc7nEbE0Gnkmg"
	static let tutorDetailsTestFileID = "1NaSjIe43RrGEa4AdAKHuF343eHlfogzuMuS5SPvowS8"
}
var submitErrorMsg: String = " "

struct SheetData: Decodable {
	let range: String
	let majorDimension: String
	let values: [[String]]
}

enum BillingTypeOption: String, CaseIterable, Identifiable, CustomStringConvertible {
	case Fixed
	case Variable
	
	var id: Self { self }
	
	var description: String {
		
		switch self {
			case .Fixed:
				return "Fixed"
			case .Variable:
				return "Variable"
		}
	}
}

class OAuth2Token{
	var accessToken: String?
	var refreshToken: String?
	var expiresAt: Date?
	var clientID: String?
}

let oauth2Token = OAuth2Token()

var accessOAuthToken: String = ""
var refreshOAuthToken: String = ""
var clientOAuthID: String = ""
var tokenExpiryTime: Date = Date.now
var runMode = "Test"
var tutorDetailsFileID: String = ""

var timesheetData = Timesheet()
var tutorData = Tutor()

@main
struct WSTutorApp: App {
    @State var userAuth: UserAuthVM =  UserAuthVM()
    @State var timeSheet: TimesheetVM =  TimesheetVM()
    
    var body: some Scene {
        WindowGroup {

                ContentView()
            }
    }
}

