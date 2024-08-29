//
//  TimeEntryView.swift
//  WriteSeattleTimesheet
//
//  Created by Russell Kernaghan on 2024-06-14.
//

import SwiftUI

class TimesheetData {
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

struct TimesheetRow: Identifiable {
    let sessionDate: String
    let sessionMinutes: String
    let sessionStudent: String
    let sessionService: String
    
    var id = UUID()
}

struct TimeEntryView: View {

    @AppStorage("username") var userName: String = "Tutor Name"
    
    @Environment(\.dismiss) var dismiss
    @Environment(UserAuthModel.self) var userAuthModel: UserAuthModel
    @Environment(TimesheetModel.self) var timesheetModel: TimesheetModel
 
    @State var selectedStudent: String = " "
    @State var selectedService: String = " "
    @State var selectedNote: String = " "
    
    @State var serviceDate: Date
    @State var minutes: String

    var timesheetData = TimesheetData()
    
    var body: some View {
        
        VStack {
            if timesheetModel.isDataLoaded {
                TimesheetHeaderView()
                Spacer()
                    
                StudentServicePickerView(selectedStudent: $selectedStudent, selectedService: $selectedService, selectedNote: $selectedNote, timesheetData: timesheetData)
                    
                Spacer()
                    
                DurationEntryView(minutes: $minutes)
            
                Spacer()

                DatePicker ("Date", selection: $serviceDate, displayedComponents: [.date])
                    .frame(width: 200, height: 40)
                
                Spacer()
                
                SubmitButtonView(selectedStudent: $selectedStudent, selectedService: $selectedService, serviceDate: $serviceDate, minutes: $minutes, timesheetData: timesheetData)
                    .environment(timesheetModel)
                
                Spacer()
                
                SessionHistoryView(timesheetData: timesheetData)
                
                Spacer()
                
            }
        }
            
            .onAppear(perform: {
                print("Start OnAppear")
                let currentDate = Date.now
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "M"
                let currentMonth = formatter1.string(from: currentDate)
                let currentMonthNum = Int(currentMonth)
                let currentMonthName = monthNames[currentMonthNum! - 1]
                formatter1.dateFormat = "yyyy"
                let currentYear = formatter1.string(from: currentDate)
                let spreadsheetName = "Timesheet " + currentYear + " " + userName
                print(spreadsheetName, currentMonthName)
                timesheetModel.readRefData(fileName: spreadsheetName, timesheetData: timesheetData, spreadsheetYear: currentYear, spreadsheetMonth: currentMonthName)
            })
        }
    }
 


struct TimesheetHeaderView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(UserAuthModel.self) var userAuthModel: UserAuthModel
    
    var body: some View {
        HStack {
            Image("Write_Seattle_Logo").resizable().frame(width: 50.0, height: 50.0)
            Text("Write Seattle Timesheet")
                .fontWeight(.black)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
        }
        
    
          
        Spacer()
        
        Button("Sign Out") {
            userAuthModel.signOut()
            dismiss() }
        Spacer()
    }
}

struct StudentServicePickerView: View {
    @Binding var selectedStudent: String
    @Binding var selectedService: String
    @Binding var selectedNote: String
    var timesheetData: TimesheetData
    
  
    var body: some View {
        
        VStack {
            
            Picker("Student", selection: $selectedStudent) {
                ForEach(timesheetData.students, id: \.self) {
                    Text($0)
                }
            }
        
 //           Spacer()
        
            Picker("Service", selection: $selectedService) {
                ForEach(timesheetData.services, id: \.self) {
                    Text($0)
                }
            }
            
            Picker("Note", selection: $selectedNote) {
                ForEach(timesheetData.notes, id: \.self) {
                    Text($0)
                }
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
    var timesheetData: TimesheetData
    
    @Environment(TimesheetModel.self) var timesheetModel: TimesheetModel
    
    var body: some View {

        Button("Submit") {
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            let stringDate = formatter1.string(from: serviceDate)
            timesheetModel.saveTimeEntry(spreadsheetID: timesheetData.fileID, studentName: selectedStudent, serviceName: selectedService, duration: minutes, serviceDate: serviceDate, sessionCount: timesheetData.sessionCount)
//            timesheetModel.saveTimeEntry(spreadsheetID: timesheetData.fileID, studentName: selectedStudent, serviceName: selectedService, duration: "15", serviceDate: serviceDate, sessionCount: timesheetData.sessionCount)
  
            let currentDate = Date.now
            
            formatter1.dateFormat = "yyyy"
            let currentYear = formatter1.string(from: currentDate)
            formatter1.dateFormat = "M"
            let currentMonth = formatter1.string(from: currentDate)
            let currentMonthNum = Int(currentMonth)
            let currentMonthName = monthNames[currentMonthNum! - 1]
            timesheetModel.loadMonthSessions(timesheetData: timesheetData, spreadsheetYear: currentYear, spreadsheetMonth: currentMonthName)
        }
    }
}

struct SessionHistoryView: View {
    var timesheetData: TimesheetData
    
    var body: some View {
 
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
                ForEach (timesheetData.sessions) { timesheet in
                    GridRow {
                        Text(timesheet.sessionDate).font(.footnote)
                        //                    Text(timesheet.sessionMinutes).font(.footnote)
                        Text(timesheet.sessionStudent).font(.footnote)
                        Text(timesheet.sessionService).font(.footnote)
                    }
                }
            }
        }
    }
}

#Preview {
    TimeEntryView(selectedStudent: " ", selectedService: " ", serviceDate: Date.now, minutes: " ")
//    TimeEntryView()
}

