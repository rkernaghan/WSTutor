//
//  Utilities.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-11-23.
//
import GoogleSignIn
import GoogleAPIClientForREST

func getAccessToken() async -> (Bool) {
	var returnResult: Bool = true
	
	let accessToken = oauth2Token.accessToken
	
	if let accessToken = accessToken {
		//		print("Access Token before check \(accessToken)")
		if isTokenExpired() {
			print("access token expired")
			do {
				let time = Date()
				let timeFormatter = DateFormatter()
				timeFormatter.dateFormat = "HH:mm"
				let stringDate = timeFormatter.string(from: time)
				print("Refreshing Access Token at \(stringDate)")
				let (newExpiryDate, newAccessToken) = try await refreshAccessToken()
				
				oauth2Token.expiresAt = newExpiryDate
				print("New Token expires at \(oauth2Token.expiresAt!)")
				oauth2Token.accessToken = newAccessToken
				//				print("Access Token after refresh \(oauth2Token.accessToken!)")
				//				print("Refresh Token after refresh \(oauth2Token.refreshToken!)")
			} catch {
				print("Could not refresh access Token")
			}
		} else {
			print("Utilities-getAccessToken: Access Token is not expired")
			returnResult = true
		}
	} else {
		returnResult = false
		print("ERROR: Access Token is nil in getAccessToken")
	}
	
	return(returnResult)
}

func isTokenExpired() -> Bool {
	let token = oauth2Token.accessToken
	if let token = token {
		let tokenExpiry = oauth2Token.expiresAt
		if let tokenExpiry = tokenExpiry {
			print("Checking token expiry - time: \(Date()) expires at: \(tokenExpiry)")
			if Date() >= tokenExpiry {
				print("Token Time Expiry Test Failed")
			} else {
				print("Token not expired")
			}
			return Date() >= tokenExpiry
		} else {
			return true
		}
	} else {
		return true // No token available
	}
}

func refreshAccessToken() async throws -> (Date?, String?) {
	var newAccessToken: String?
	var newTokenExpiryDate: Date?
	
	var bodyParameters = [String: String]()
	let url = URL(string: "https://oauth2.googleapis.com/token")!
	
	// Set up the request parameters
	var request = URLRequest(url: url)
	request.httpMethod = "POST"
	request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
	
	// HTTP request body with URL-encoded parameters
	let refreshToken = oauth2Token.refreshToken
	print("Refreshing Access Token")
	
	if let refreshToken = refreshToken {
		let clientID = oauth2Token.clientID
		if let clientID = clientID {
			bodyParameters = [
				"client_id": clientID,
				"refresh_token": refreshToken,
				"grant_type": "refresh_token"
			]
			
			request.httpBody = bodyParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
			
			// Perform the network request asynchronously
			let (data, response) = try await URLSession.shared.data(for: request)
			
			// Check for HTTP response status
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
				throw NSError(domain: "Invalid Response", code: statusCode, userInfo: nil)
			}
			
			// Parse the response JSON to retrieve the new access token
			guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
			      let newAccessToken = json["access_token"] as? String,
			      let expiresIn = json["expires_in"] as? Double
			else {
				throw NSError(domain: "Invalid JSON structure", code: -1, userInfo: nil)
			}
			let newExpirationDate = Date().addingTimeInterval(expiresIn)
			return(newExpirationDate, newAccessToken)
		} else {
			print("Error: Client ID is nil")
			
		}
	} else {
		print("Error: Refresh Token is nil")
		
	}
	return(newTokenExpiryDate, newAccessToken)
	
}



func getFileID(fileName: String) async throws -> (Bool, String) {
	var fileID: String = ""
	var fileFound: Bool = false
	//	var accessToken: String
	
	//	let currentUser = GIDSignIn.sharedInstance.currentUser
	//	if let user = currentUser {
	//		accessToken = user.accessToken.tokenString
	
	let tokenFound = await getAccessToken()
	if tokenFound {
		let accessToken = oauth2Token.accessToken
		if let accessToken = accessToken {
			// URL for Google Sheets API
			let urlString = "https://www.googleapis.com/drive/v3/files?q=name='\(fileName)'&fields=files(id,name)"
			guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
				print("Invalid URL")
				return(false, " ")
			}
			
			// Set up the request with OAuth 2.0 token
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			
			// Use async URLSession to fetch the data
			
			let (data, response) = try await URLSession.shared.data(for: request)
			
			//        if let httpResponse = response as? HTTPURLResponse {
			//            print("Find File ID Error: \(httpResponse.statusCode)")
			//        }
			// Check if the response is successful
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
				throw NSError(domain: "Invalid HTTP Response in getFileID", code: statusCode, userInfo: nil)
			}
			
			// Parse the JSON response
			if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
			   let files = json["files"] as? [[String: Any]], !files.isEmpty,
			   let fileId = files.first?["id"] as? String {
				return (true, fileId)
			} else {
				return (false, "")
			}
		}
		return (false, "")
	}
	else {
		return(false, "")
	}
}

func readSheetCells(fileID: String, range: String) async throws -> SheetData? {
	var values = [[String]]()
	var sheetData: SheetData?
	
	//	let currentUser = GIDSignIn.sharedInstance.currentUser
	//	if let user = currentUser {
	//		accessToken = user.accessToken.tokenString
	print("Utilities-readSheetCells: Range:\(range)| FileID:\(fileID)")
	
	let tokenFound = await getAccessToken()
	if tokenFound {
		let accessToken = oauth2Token.accessToken
		if let accessToken = accessToken {
			// URL for Google Sheets API
			let urlString = "https://sheets.googleapis.com/v4/spreadsheets/\(fileID)/values/\(range)"
			guard let url = URL(string: urlString) else {
				throw URLError(.badURL)
			}
			
			// Set up the request with OAuth 2.0 token
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			
//			print("Utilities-readSheetCells: Granted scopes: \(grantedScopes)")
			
			// Use async URLSession to fetch the data
			//    print("Before Read Cells URL Session call \(fileID)")
			let (data, response) = try await URLSession.shared.data(for: request)
			
			//    print("After Read Cells URL Session call \(fileID)")
			if let httpResponse = response as? HTTPURLResponse {
				if httpResponse.statusCode != 200 {
					print("Read Sheet HTTP Result Error Code: \(httpResponse.statusCode)")
				}
			}
			// Check if the response is successful
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				throw URLError(.badServerResponse)
			}
			
			// Decode the JSON data into the SheetData structure
			sheetData = try JSONDecoder().decode(SheetData.self, from: data)
			print("Utilities-readSheetCells: Read range \(range)")
		}
		
	}
	//        if let sheetData = sheetData {
	return sheetData
	//        }
}

func readSheetCellsSynch(fileID: String, range: String) throws {
	
	print("\n Asynch read cells start")
	let urlString = "https://sheets.googleapis.com/v4/spreadsheets/\(fileID)/values/\(range)"
	guard let url = URL(string: urlString) else {
		print("Bad URL in readSheetCellsSynch")
		throw URLError(.badURL)
	}
	let accessToken = oauth2Token.accessToken
	
	let sheetService = GTLRSheetsService()
	let currentUser = GIDSignIn.sharedInstance.currentUser
	sheetService.authorizer = currentUser?.fetcherAuthorizer
	
	let spreadsheetId = fileID
	let query = GTLRSheetsQuery_SpreadsheetsValuesGet
		.query(withSpreadsheetId: spreadsheetId, range:range)
	
	sheetService.executeQuery(query) { (ticket, result, error) in
	// Set up the request with OAuth 2.0 token
		if let error = error {
			// Access the error description
			print("Read Sheets Synch Error: \(error.localizedDescription)")
		}
		
		print("Asynch Read Cells after GETRequest")
		
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
	print("Asynch read cells End\n ")
	
}

func writeSheetCells(fileID: String, range: String, values: [[String]]) async throws -> Bool {
	var completionFlag: Bool = true
	
	let tokenFound = await getAccessToken()
	if tokenFound {
		let accessToken = oauth2Token.accessToken
		if let accessToken = accessToken {		let urlString = "https://sheets.googleapis.com/v4/spreadsheets/\(fileID)/values/\(range)?valueInputOption=USER_ENTERED"
			guard let url = URL(string: urlString) else {
				throw URLError(.badURL)
			}
			
			// Prepare the request
			var request = URLRequest(url: url)
			request.httpMethod = "PUT"  // Using PUT to update the values in the sheet
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			
			// Prepare the request body with the data to write
			let body: [String: Any] = [
				"range": range,
				"majorDimension": "ROWS",  // Writing row by row
				"values": values            // The 2D array of values to write
			]
			
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
			
			
			// Perform the network request asynchronously using async/await
			let (data, response) = try await URLSession.shared.data(for: request)
			
			if let httpResponse = response as? HTTPURLResponse {
				if httpResponse.statusCode != 200 {
					print("Write Sheet HTTP Result Error Code: \(httpResponse.statusCode)")
					completionFlag = false
				}
			}
			// Check for HTTP response status
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
				throw NSError(domain: "Invalid Response", code: statusCode, userInfo: nil)
			}
			
			// Handle the response (if needed)
			if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
				//           print("writeSheetCells Response: \(json)")
			}
		}
	} else {
		completionFlag = false
	}
	return(completionFlag)
}



// Function to get the sheet ID based on sheet name using spreadsheets.get
func getSheetIdByName(spreadsheetId: String, sheetName: String) async throws -> Int? {
	//	    var accessToken: String
	
	let urlString = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)?fields=sheets.properties"
	
	let tokenFound = await getAccessToken()
	if tokenFound {
		let accessToken = oauth2Token.accessToken
		if let accessToken = accessToken {
			
			guard let url = URL(string: urlString) else {
				throw URLError(.badURL)
			}
			
			// Set up the request
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			
			// Perform the network request asynchronously
			let (data, response) = try await URLSession.shared.data(for: request)
			
			// Check for HTTP response status
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
				throw NSError(domain: "Invalid Response", code: statusCode, userInfo: nil)
			}
			
			// Parse the response JSON to find the sheet ID
			if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
			   let sheets = json["sheets"] as? [[String: Any]] {
				
				for sheet in sheets {
					if let properties = sheet["properties"] as? [String: Any],
					   let title = properties["title"] as? String,
					   let sheetId = properties["sheetId"] as? Int,
					   title == sheetName {
						return sheetId // Return the sheet ID if the name matches
					}
				}
			}
		}
	}
	// If the sheet name was not found, return nil
	return nil
}

struct GoogleSheetsResponse: Codable {
	struct Sheet: Codable {
		let properties: Properties
	}
	
	struct Properties: Codable {
		let title: String
		let sheetId: Int
	}
	
	let sheets: [Sheet]
}

func getSheetCount(spreadsheetId: String) async throws -> Int {
	var sheetCount: Int = 0
	
	let urlString = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)"
	guard let url = URL(string: urlString) else {
		throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
	}
	let tokenFound = await getAccessToken()
	if tokenFound {
		let accessToken = oauth2Token.accessToken
		if let accessToken = accessToken {
			let accessToken = oauth2Token.accessToken
			if let accessToken = accessToken {
				var request = URLRequest(url: url)
				request.httpMethod = "GET"
				request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
				//		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
				
				// Send the request with async/await
				let (data, response) = try await URLSession.shared.data(for: request)
				
				// Check for HTTP errors
				if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
					throw NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)
				}
				
				// Parse the JSON response
				let googleSheetsResponse = try JSONDecoder().decode(GoogleSheetsResponse.self, from: data)
				sheetCount = googleSheetsResponse.sheets.count
			}
		}
	}
	// Return the count of sheets
	return sheetCount
	
}



func getCurrentMonthYear() -> (String, String) {
	var currentMonthName: String = ""
	var currentYearName: String = ""
	
	if let monthInt = Calendar.current.dateComponents([.month], from: Date()).month {
		currentMonthName = PgmConstants.monthNames[monthInt - 1]
	}
	
	if let yearInt = Calendar.current.dateComponents([.year], from: Date()).year {
		currentYearName = String(yearInt)
	}
	return(currentMonthName, currentYearName)
}

func getPrevMonthYear() -> (String, String) {
	var prevMonthName: String = ""
	var billingYear: String = ""
	
	if let monthInt = Calendar.current.dateComponents([.month], from: Date()).month {
		var prevMonthInt = monthInt - 2                  // subtract 2 from current month name to get prev month with 0-based array index
		if prevMonthInt == -1 {
			prevMonthInt = 11
		}
		prevMonthName = PgmConstants.monthNames[prevMonthInt]
	}
	
	if let yearInt = Calendar.current.dateComponents([.year], from: Date()).year {
		if prevMonthName == PgmConstants.monthNames[11] {            // if month is December than use previous year
			billingYear = String(yearInt - 1)
		} else {
			billingYear = String(yearInt)
		}
	}
	return(prevMonthName, billingYear)
}

func findPrevMonthYear(currentMonth: String, currentYear: String) -> (String, String) {
	var prevMonthName: String = ""
	var prevYearName: String = ""
	var monthNum: Int = 0
	
	if currentMonth == "Jan" {
		let prevYear = Int(currentYear) ?? 0
		prevYearName = String(prevYear - 1)
	} else {
		prevYearName = currentYear
	}
	
	if let index = PgmConstants.monthNames.firstIndex(of: currentMonth) {
		if index == 0 {
			monthNum = 11
		} else {
			monthNum = index - 1
		}
		prevMonthName = PgmConstants.monthNames[monthNum]
	}
	
	return(prevMonthName, prevYearName)
}

