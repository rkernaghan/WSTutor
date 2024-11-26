//
//  TimesheetRow.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-11-23.
//
import Foundation

struct TimesheetRow: Identifiable {
	var studentName: String
	var serviceDate: String
	var duration: Int
	var serviceName: String
	var note: String
//	var cost: Float
//	var clientName: String
//	var clientEmail: String
//	var clientPhone: String
//	var tutorName: String
	let id = UUID()
	
//	init(studentName: String, serviceDate: String, duration: Int, serviceName: String, notes: String, cost: Float, clientName: String, clientEmail: String, clientPhone: String, tutorName: String) {
	init(studentName: String, serviceDate: String, duration: Int, serviceName: String, note: String) {
		self.studentName = studentName
		self.serviceDate = serviceDate
		self.duration = duration
		self.serviceName = serviceName
		self.note = note
//		self.cost = cost
//		self.clientName = clientName
//		self.clientEmail = clientEmail
//		self.clientPhone = clientPhone
//		self.tutorName = tutorName
	}
}
