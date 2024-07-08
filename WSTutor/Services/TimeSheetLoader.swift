//
//  TimesheetLoader.swift
//  WriteSeattleTimesheet
//
//  Created by Russell Kernaghan on 2024-06-14.
//
import SwiftUI
import Foundation
import GoogleSignIn
import GoogleAPIClientForREST

func readData() {
    
print("Getting sheet data...")
    
let sheetService = GTLRSheetsService()
let currentUser = GIDSignIn.sharedInstance.currentUser
    
//sheetService.apiKey = "AIzaSyCO8rSNfxXriwDwspPoULQuANKv6fSbnaQ"
//sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
sheetService.authorizer = currentUser?.fetcherAuthorizer
    
let spreadsheetId = "18GxBUhOAG2arOR0YkTFcv546ujKZ_JyJYkhyawVSMiY"
let range = "Master!A1:A10"
let query = GTLRSheetsQuery_SpreadsheetsValuesGet
    .query(withSpreadsheetId: spreadsheetId, range:range)

sheetService.executeQuery(query) { (ticket, result, error) in
    if let error = error {
        print(error)
        print("Failed to read data:\(error.localizedDescription)")
        return
    }
    guard let result = result as? GTLRSheets_ValueRange else {
        return
    }
    
    let rows = result.values!
    var stringRows = rows as! [[String]]
    
    for row in stringRows {
        stringRows.append(row)
        print(row)
        }
    if rows.isEmpty {
        print("No data found.")
        return
    }
    print("Success!")
    print("Number of rows in sheet: \(rows.count)")
}
}
