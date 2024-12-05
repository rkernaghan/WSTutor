//
//  TimeEntryView.swift
//  WriteSeattleTimesheet
//
//  Created by Russell Kernaghan on 2024-06-14.
//

import SwiftUI

@Observable class TimesheetData {
	var fileID: String
	var studentCount: Int
	var serviceCount: Int
	var sessionCount: Int
	var notesCount: Int
	var students: [String] = []
	var services: [String] = []
	var notes: [String] = []
	var sessions = [TimesheetRow] ()
	
	init() {
		studentCount = 0
		serviceCount = 0
		sessionCount = 0
		notesCount = 0
		fileID = " "
	}
}


struct TimeEntryView: View {
	
	@AppStorage("username") var userName: String = "Tutor Name"
	
	@Environment(\.dismiss) var dismiss
	@Environment(UserAuthVM.self) var userAuthVM: UserAuthVM
	@Environment(TimesheetVM.self) var timesheetVM: TimesheetVM
	
	@State var selectedStudent: String = " "
	@State var selectedService: String = " "
	@State var selectedNote: String = " "
	@State var serviceDate: Date
	@State var minutes: String
	
	@State var showAlert: Bool = false
	@State var errorMsg: String = " "
	
	var body: some View {
		
		VStack {
			if timesheetVM.isDataLoaded {
				
				TimesheetHeaderView(userName: userName, timesheetData: timesheetData, tutorData: tutorData, selectedStudent: $selectedStudent, selectedService: $selectedService, selectedNote: $selectedNote)
					.environment(timesheetVM)
				
				//               Spacer()
				
				StudentServicePickerView(selectedStudent: $selectedStudent, selectedService: $selectedService, selectedNote: $selectedNote, timesheetData: timesheetData, tutorData: tutorData)
				
				Spacer()
				
				DurationEntryView(minutes: $minutes)
				
				Spacer()
				
				DatePicker ("Date", selection: $serviceDate, displayedComponents: [.date])
					.frame(width: 200, height: 40)
				
				Spacer()
				if let timesheetFileID = tutorData.timesheetFileID {
					SubmitButtonView(selectedStudent: $selectedStudent, selectedService: $selectedService, serviceDate: $serviceDate, minutes: $minutes, selectedNote: $selectedNote, timesheetData: timesheetData, userName: userName, timesheetFileID: timesheetFileID)
						.environment(timesheetVM)
				}
				
				Spacer()
				
				//              Text(errorMsg)
				
				Divider()
					.frame(height: 10)
					.overlay(.orange)
				
				SessionHistoryView(timesheetData: timesheetData)
				
				Spacer()
				
			}
		}
		.border(.orange, width: 8)
		.alert("Could not read Tutor Data for \(userName)", isPresented: $showAlert) {
			Button("OK", role: .cancel) {
				userAuthVM.signOut()
			}
		}
		
		.onAppear(perform: {
			Task {
				print("Start OnAppear")
				let currentDate = Date.now
				let formatter1 = DateFormatter()
				formatter1.dateFormat = "M"
				let currentMonth = formatter1.string(from: currentDate)
				let currentMonthNum = Int(currentMonth)
				let currentMonthName = PgmConstants.monthNames[currentMonthNum! - 1]
				formatter1.dateFormat = "yyyy"
				let currentYear = formatter1.string(from: currentDate)
				let spreadsheetName = "Timesheet " + currentYear + " " + userName
				print(spreadsheetName, currentMonthName)
				
				let tutorResult = await timesheetVM.getTutorData(tutorName: userName, tutorData: tutorData)
				if !tutorResult {
					print("Error: Could not get Tutor data")
					showAlert = true
				} else {
					if let timesheetFileID = tutorData.timesheetFileID {
						let timesheetResult = await timesheetVM.getTimesheetData(tutorName: userName, month: currentMonthName, timesheetFileID: timesheetFileID )
						if !timesheetResult {
							print("Error: Could not get Timesheet data")
						} else {
							print("Got Tutor and Timesheet data")
						}
					} else {
						print("Error: no TimesheetFileID available")
					}
						
				}
			}
		})
	}
}

struct TimesheetHeaderView: View {
	var userName: String
	var timesheetData: Timesheet
	var tutorData: Tutor
	
	@Binding var selectedStudent: String
	@Binding var selectedService: String
	@Binding var selectedNote: String
	
	@Environment(\.dismiss) var dismiss
	@Environment(UserAuthVM.self) var userAuthVM: UserAuthVM
	@Environment(TimesheetVM.self) var timesheetVM: TimesheetVM
	
	var body: some View {
		HStack {
			Image("Write_Seattle_Logo").resizable().frame(width: 50.0, height: 50.0)
			Text("Write Seattle Timesheet")
				.fontWeight(.black)
				.foregroundColor(Color.black)
				.multilineTextAlignment(.center)
		}
		
		Spacer()
		
		HStack {
			
			Button(action: {
				Task {
					selectedStudent = PgmConstants.studentPrompt
					selectedService = PgmConstants.servicePrompt
					selectedNote = PgmConstants.notePrompt
					timesheetVM.isDataLoaded = false
					let currentDate = Date.now
					let formatter1 = DateFormatter()
					formatter1.dateFormat = "M"
					let currentMonth = formatter1.string(from: currentDate)
					let currentMonthNum = Int(currentMonth)
					let currentMonthName = PgmConstants.monthNames[currentMonthNum! - 1]
					formatter1.dateFormat = "yyyy"
					let currentYear = formatter1.string(from: currentDate)
					let spreadsheetName = "Timesheet " + currentYear + " " + userName
					let tutorResult = await timesheetVM.getTutorData(tutorName: userName, tutorData: tutorData)
					if !tutorResult {
						print("Error: Could not get Tutor data on refresh")
					} else {
						if let timesheetFileID = tutorData.timesheetFileID {
							let timesheetResult = await timesheetVM.getTimesheetData(tutorName: userName, month: currentMonthName, timesheetFileID: timesheetFileID)
							if !timesheetResult {
								print("Error: Could not get Timesheet data on refresh")
							} else {
								print("Got Tutor and Timesheet data on refresh")
							}
						}
					}
				}
			}){
				Text("Refresh")
			}
			.padding()
			.background(Color.orange)
			.foregroundColor(Color.white)
			.clipShape(RoundedRectangle(cornerRadius: 10))
			
			Spacer()
			
			Button(action: {
				userAuthVM.signOut()
				dismiss() }) {
					Text("Sign Out")
				}
				.padding()
				.background(Color.orange)
				.foregroundColor(Color.white)
				.clipShape(RoundedRectangle(cornerRadius: 10))
			
		}
		Spacer()
	}
}

struct StudentServicePickerView: View {
	@Binding var selectedStudent: String
	@Binding var selectedService: String
	@Binding var selectedNote: String
	var timesheetData: Timesheet
	var tutorData: Tutor
	
	
	var body: some View {
		let tutorStudentsList = tutorData.tutorStudents
		let tutorServicesList = tutorData.tutorServices
		let tutorNotesList = tutorData.tutorNotes
		
		VStack {
			HStack {
				Text("Student: ")
				Picker("Student", selection: $selectedStudent) {
					ForEach(tutorStudentsList) { option in
						Text(String(option.studentName)).tag(option.studentName)
					}
				}
				.accentColor(Color.black)
				.pickerStyle(.menu)
			}
			
			HStack {
				Text("Service: ")
				Picker("Service", selection: $selectedService) {
					ForEach(tutorServicesList) { option in
						Text(String(option.timesheetServiceName)).tag(option.timesheetServiceName)
					}
				}
				.accentColor(Color.black)
				.pickerStyle(.menu)
			}
			
			HStack {
				Text("Note: ")
				Picker("Note", selection: $selectedNote) {
					ForEach(tutorNotesList) { option in
						Text(String(option.noteText)).tag(option.noteText)
					}
				}
				.accentColor(Color.black)
				.pickerStyle(.menu)
			}
		}
	}
}

struct DurationEntryView: View {
	@Binding var minutes: String
	
	enum FocusedField {
		case int, dec
	}
	@FocusState private var focusedField: FocusedField?
	
	var body: some View {
		
		HStack {
			Text("Duration")
			TextField("Duration", text: $minutes)
				.frame(width: 60)
				.textFieldStyle(.roundedBorder)
				.focused($focusedField, equals: .int)
				.keyboardType(.numberPad)
			Text(" in Minutes")
		}
		.toolbar {
			ToolbarItem(placement: .keyboard) {
				Spacer()
			}
			ToolbarItem(placement: .keyboard) {
				Button {
					focusedField = nil
				} label: {
					Image(systemName: "keyboard.chevron.compact.down")
				}
			}
		}
	}
}

struct SubmitButtonView: View {
	@Binding var selectedStudent: String
	@Binding var selectedService: String
	@Binding var serviceDate: Date
	@Binding var minutes: String
	@Binding var selectedNote: String
	var timesheetData: Timesheet
	var userName: String
	var timesheetFileID: String
	
	@Environment(TimesheetVM.self) var timesheetVM: TimesheetVM
	@State private var showAlert = false
	
	var body: some View {
		
		Button(action: {
			Task {
				let validationResult = timesheetVM.validateTimesheetInput(selectedStudent: selectedStudent, selectedService: selectedService, selectedNote: selectedNote, duration: minutes, serviceDate: serviceDate)
				
				if validationResult == true {
					
					let saveResult = await timesheetVM.saveTimeEntry(timesheetData: timesheetData, studentName: selectedStudent, serviceName: selectedService, duration: minutes, serviceDate: serviceDate, note: selectedNote, timesheetFileID: timesheetFileID)
					
					let formatter1 = DateFormatter()
					formatter1.dateStyle = .short
					let currentDate = Date.now
					formatter1.dateFormat = "yyyy"
					formatter1.dateFormat = "M"
					let currentMonth = formatter1.string(from: currentDate)
					let currentMonthNum = Int(currentMonth)
					let currentMonthName = PgmConstants.monthNames[currentMonthNum! - 1]
					let timesheetResult = await timesheetVM.getTimesheetData(tutorName: userName, month: currentMonthName, timesheetFileID: timesheetFileID)
				}
				
				else {
					showAlert = true
				}
			}
		}) {
			Text("Submit")
		}
		.alert(submitErrorMsg, isPresented: $showAlert) {
			Button("OK", role: .cancel) { }
		}
		.padding()
		.background(Color.orange)
		.foregroundColor(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 10))
		
	}
}


struct SessionHistoryView: View {
	var timesheetData: Timesheet
	
	var body: some View {
		let timesheetList = timesheetData.timesheetRows
		if timesheetData.isTimesheetLoaded {
			ScrollView {
				Grid {
					GridRow {
						Text("Date")
						//                Text("Minutes")
						Text("Student")
						Text("Service")
					}
					.bold()
					Divider()
					ForEach (timesheetList) { row in
						GridRow {
							Text(row.serviceDate).font(.footnote)
							//                    Text(timesheet.sessionMinutes).font(.footnote)
							Text(row.studentName).font(.footnote)
							Text(row.serviceName).font(.footnote)
						}
					}
				}
			}
			.frame(height: 150)
		}
	}
}

#Preview {
	TimeEntryView(selectedStudent: PgmConstants.studentPrompt, selectedService: PgmConstants.servicePrompt, selectedNote: PgmConstants.notePrompt, serviceDate: Date.now, minutes: " ")
	//    TimeEntryView()
}


