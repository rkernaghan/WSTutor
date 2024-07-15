//
//  TimeEntryView.swift
//  WriteSeattleTimesheet
//
//  Created by Russell Kernaghan on 2024-06-14.
//

import SwiftUI

class TimesheetData {
    var studentCount: Int
    var serviceCount: Int
    var students: [String] = []
    var services: [String] = []
    
    init() {
        studentCount = 0
        serviceCount = 0
        }
    }

struct TimeEntryView: View {
  //  @State var vm: UserAuthModel
    @Environment(\.dismiss) var dismiss
    @AppStorage("username") var userName: String = "Tutor Name"
    @Environment(UserAuthModel.self) var userAuthModel: UserAuthModel
    @Environment(TimesheetModel.self) var timesheetModel: TimesheetModel
    @State var selectedStudent: String
    @State var selectedService: String
    @State var serviceDate: Date
    @State var minutes: String
    
 //   @State private var ts: TimesheetModel

    
//    var services = ["Tutoring", "Library Tutoring", "Virtual Call", "Thesis"]
//    var students = ["Maria","Russell", "Alana", "Stephen" ]
//    var selectedService: String
//    var selectedStudent: String
    var timesheetData = TimesheetData()
//    @State var duration: String
    
    var body: some View {
        VStack {
            if timesheetModel.isDataLoaded {
                Spacer()
                Text("Write Seattle Timesheet")
                    .fontWeight(.black)
                    .foregroundColor(Color.black)
                
                Image("Write_Seattle_Logo").resizable().frame(width: 50.0, height: 50.0)
                
                Spacer()
                
                Button("Sign Out") {
                    userAuthModel.signOut()
                    dismiss()}
                
                Spacer()
                
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
                
                TextField("Duration (minutes)",text: $minutes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                DatePicker(
                        "Service Date",
                        selection: $serviceDate,
                        displayedComponents: [.date]
                    )
                
                Spacer()
                
                Button("Submit") {
                    
                    let formatter1 = DateFormatter()
                    formatter1.dateStyle = .short
                    let stringDate = formatter1.string(from: serviceDate)
                    timesheetModel.saveTimeEntry(spreadsheetID: "1DplB9gONhQK8aurzYyFoLtBZCsB0fh-yhTfGoV0w0TI", studentName: selectedStudent, serviceName: selectedService, duration: minutes, serviceDate: stringDate)
                    
                }
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                
                Spacer()
                List {
                    Text("Student Date Service")
                    Text("Student Date Service")
                    Text("Student Date Service")
                    Text("Student Date Service")
                }.frame(width: 300, height: 180.0)
                
                Spacer()
            }
        }
        .padding(0.0)
        .frame(width: 340.0, height: 800.0)
        .onAppear(perform: {
            let temp = userName
            let spreadsheetName = "Timesheet 2024 " + userName
            timesheetModel.readRefData(fileName: spreadsheetName, timesheetData: timesheetData)
            print(timesheetData.studentCount)
            print(timesheetData.serviceCount)
            print(timesheetData.students)
            print(timesheetData.services)
            
        })
    }
}

    
//#Preview {
//    TimeEntryView()
//}

