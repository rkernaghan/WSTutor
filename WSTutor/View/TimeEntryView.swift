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
    var students: [String] = []
    var services: [String] = []
    var sessions = [TimesheetRow] ()
    
    init() {
        studentCount = 0
        serviceCount = 0
        sessionCount = 0
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

    @State var selectedStudent: String
    @State var selectedService: String
    @State var serviceDate: Date
    @State var minutes: String

    var timesheetData = TimesheetData()
    
    var body: some View {
        VStack {
            if timesheetModel.isDataLoaded {
                Spacer()
                Text("Write Seattle Timesheet")
                    .fontWeight(.black)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                
                Image("Write_Seattle_Logo").resizable().frame(width: 50.0, height: 50.0)
                
                Spacer()
                
                Button("Sign Out") {
                    userAuthModel.signOut()
                    dismiss()}
                
                Spacer()
 //               List {
                    Section {
         
                    
                    Picker("Student", selection: $selectedStudent) {
                        ForEach(timesheetData.students, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Spacer()
                    
                    Picker("Service", selection: $selectedService) {
                        ForEach(timesheetData.services, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Spacer()

                    HStack {
                        Text("Duration")
                        TextField("Duration", text: $minutes)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        }
                    
                    Spacer()
                    
                    DatePicker(
                        "Service Date",
                        selection: $serviceDate,
                        displayedComponents: [.date]
                    )
                    
                    Spacer()
                        
                    }
                    Section {
                        Button("Submit") {
                            
                            let formatter1 = DateFormatter()
                            formatter1.dateStyle = .short
                            let stringDate = formatter1.string(from: serviceDate)
                            timesheetModel.saveTimeEntry(spreadsheetID: timesheetData.fileID, studentName: selectedStudent, serviceName: selectedService, duration: minutes, serviceDate: stringDate, sessionCount: timesheetData.sessionCount)
                            
                            let currentDate = Date.now
                            
                            formatter1.dateFormat = "yyyy"
                            let currentYear = formatter1.string(from: currentDate)
                            formatter1.dateFormat = "M"
                            let currentMonth = formatter1.string(from: currentDate)
                            let currentMonthNum = Int(currentMonth)
                            let currentMonthName = monthNames[currentMonthNum! - 1]
                            timesheetModel.loadMonthSessions(timesheetData: timesheetData, spreadsheetYear: currentYear, spreadsheetMonth: currentMonthName)
                        }
                        
                        
                        Spacer()
                    }
                    Section  {
                        Grid {
                            GridRow {
                                Text("Date")
                                Text("Minutes")
                                Text("Student")
                                Text("Service")
                            }
                            .bold()
                            Divider()
                            ForEach(timesheetData.sessions) { timesheet in
                                GridRow {
                                    Text(timesheet.sessionDate)
                                    Text(timesheet.sessionMinutes)
                                    Text(timesheet.sessionStudent)
                                    Text(timesheet.sessionService)
                                }
//                                   if timesheet != timesheetData.sessions.last {
//                                       Divider()
//                                   }
                            }
//                        }
                    }
                    
                    
                    Spacer()
                }
            }
        }
        .padding(0.0)
        .background(Color.gray)
//        .frame(width: 340.0, height: 800.0)
        .onAppear(perform: {
            
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
            
            print(timesheetData.studentCount)
            print(timesheetData.serviceCount)
            print(timesheetData.students)
            print(timesheetData.services)
            
        })
    }
}

    
#Preview {
    TimeEntryView(selectedStudent: " ", selectedService: " ", serviceDate: Date.now, minutes: " ")
}

