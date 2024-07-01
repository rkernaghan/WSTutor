//
//  TimeEntryView.swift
//  WriteSeattleTimesheet
//
//  Created by Russell Kernaghan on 2024-06-14.
//

import SwiftUI

struct TimeEntryView: View {
 //   @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {

                         
            Spacer()
            Text("Write Seattle Timesheet")
                .fontWeight(.black)
                .foregroundColor(Color.black)
            
            Image("Write_Seattle_Logo").resizable().frame(width: 50.0, height: 50.0)

            Spacer()
            
            Button("Sign Out") {
 //               authViewModel.signOut()
                dismiss()}
            
            Spacer()
            
            Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text("Student")) {
                Text("Student 1").tag(1)
                Text("Student 2").tag(2)
                Text("Student 3").tag(3)
                
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
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
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
    }
}

    
#Preview {
    TimeEntryView()
}

