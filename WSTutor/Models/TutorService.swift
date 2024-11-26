//
//  TutorService.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-11-23.
//

import Foundation

class TutorService: Identifiable {
	
	var serviceKey: String
	var timesheetServiceName: String
	var invoiceServiceName: String
	var billingType: BillingTypeOption
	var cost1: Float
	var cost2: Float
	var cost3: Float
	var totalCost: Float
	let id = UUID()
	
	init(serviceKey: String, timesheetName: String, invoiceName: String,  billingType: BillingTypeOption, cost1: Float, cost2: Float, cost3: Float, price1: Float, price2: Float, price3: Float) {
		self.serviceKey = serviceKey
		self.timesheetServiceName = timesheetName
		self.invoiceServiceName = invoiceName
		self.billingType = billingType
		self.cost1 = cost1
		self.cost2 = cost2
		self.cost3 = cost3
		self.totalCost = cost1 + cost2 + cost3
	}
	
	func computeSessionCostPrice(duration: Int) -> (Float, Float, Float) {
		
		var cost: Float = 0.0
		var quantity: Float = 0.0
		var rate: Float = 0.0
		
		if billingType == .Fixed {
			quantity = 1.0
			cost = cost1 + cost2 + cost3

		} else {
			quantity = Float(duration) / 60.0
			cost = quantity * cost1 + cost2 + cost3
		}
		
		return(quantity, rate, cost)
	}
	
}
