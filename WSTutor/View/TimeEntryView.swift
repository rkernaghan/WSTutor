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
    @EnvironmentObject var vm: UserAuthModel
    @EnvironmentObject var ts: TimesheetModel
    @Environment(\.dismiss) var dismiss
    @AppStorage("username") var userName: String = "Tutor Name"
    @State var selectedStudent:String
    
//    var services = ["Tutoring", "Library Tutoring", "Virtual Call", "Thesis"]
//    var students = ["Maria","Russell", "Alana", "Stephen" ]
//    var selectedService: String
//    var selectedStudent: String
    var timesheetData = TimesheetData()
    
    var body: some View {
        VStack {

            Spacer()
            Text("Write Seattle Timesheet")
                .fontWeight(.black)
                .foregroundColor(Color.black)
            
            Image("Write_Seattle_Logo").resizable().frame(width: 50.0, height: 50.0)

            Spacer()
            
            Button("Sign Out") {
                vm.signOut()
                dismiss()}
            
            Spacer()
            
            Picker("Student", selection: $selectedStudent) {
                ForEach(timesheetData.students, id: \.self) {
                                Text($0)
                            }
                
            }
            Spacer()
            Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text("Service")) {
                Text("Tutoring 45").tag(1)
                Text("Thirty-Minute Session").tag(2)
                Text("Two-Student Simultaneous Tutoring")
            }
            Spacer()
            DatePicker(selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, label: { /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/ })
            Spacer()
            Button("Submit") {
                ts.saveTimeEntry(spreadsheetID: "1DplB9gONhQK8aurzYyFoLtBZCsB0fh-yhTfGoV0w0TI", studentName: "Student 3", serviceName: "Tutoring", duration: "75", serviceDate: "7/12/2024")
                
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
        .padding(0.0)
        .frame(width: 340.0, height: 800.0)
        .onAppear(perform: {
            let temp = userName
            let spreadsheetName = "Timesheet 2024 " + userName
            ts.readRefData(fileName: spreadsheetName, timesheetData: timesheetData)
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

