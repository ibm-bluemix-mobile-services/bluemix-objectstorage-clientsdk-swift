/*
*     Copyright 2016 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/

import Foundation



internal class AuthTokenManager {
	fileprivate static let TOKEN_ENDPOINT = "https://identity.open.softlayer.com/v3/auth/tokens"
	fileprivate static let TOKEN_RESOURCE = HttpResource(schema: "https", host: "identity.open.softlayer.com", port: "443", path: "/v3/auth/tokens")
	fileprivate static let X_SUBJECT_TOKEN = "X-Subject-Token"
	fileprivate let logger = Logger.init(forName: "AuthTokenManager")
	
	fileprivate static let TOKEN_REFRESH_THRESHOLD = -120.0;
	
	var userId: String?
	var password: String?
	var projectId: String
	var authToken: String?
	var expiresAt: Date?
	
	init(projectId: String, userId: String, password: String){
		self.projectId = projectId
		self.userId = userId
		self.password = password
		self.expiresAt = Date()
	}
	
	init(projectId: String, authToken: String){
		logger.warn("ObjectStorage is initialized with explicit authToken. Will not be able to refresh token automatically.")
		self.projectId = projectId
		self.userId = nil
		self.password = nil
		self.authToken = authToken
		self.expiresAt = Date().addingTimeInterval(86400) // 24 hours
	}
	 
	func refreshAuthToken(_ completionHandler:@escaping (ObjectStorageError?, String?) -> Void) {
		// Check whether authToken exists and it is still valid
		let now = Date()
		let bestBefore = self.expiresAt?.addingTimeInterval(AuthTokenManager.TOKEN_REFRESH_THRESHOLD)
		if let authToken = authToken, let bestBefore = bestBefore , bestBefore.isGreaterThanDate(now) {
			return completionHandler(nil, authToken)
		}

		// userId and password are mandatory to be able to automatically refresh authToken
		guard userId != nil && password != nil else {
			logger.error(String(describing: ObjectStorageError.cannotRefreshAuthToken))
			return completionHandler(ObjectStorageError.cannotRefreshAuthToken, nil)
		}
		
		logger.info("Obtaining new authToken")
		
		let headers = ["Content-Type":"application/json"];
		let authRequestData = AuthorizationRequestBody(userId: userId!, password: password!, projectId: projectId).data()
		
		HttpClient.post(resource: AuthTokenManager.TOKEN_RESOURCE, headers: headers, data: authRequestData) { error, status, headers, data in
			if let error = error {
				completionHandler(ObjectStorageError.from(httpError: error), nil)
			} else {
				self.logger.debug("authToken Retrieved")
				self.authToken = headers![AuthTokenManager.X_SUBJECT_TOKEN]
				
                let responseJson = (try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments)) as! [String: Any]
                let expiresAt = (responseJson["token"] as! [String: Any])["expires_at"] as! String
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
				dateFormatter.timeZone = TimeZone(identifier: "UTC")
				self.expiresAt = dateFormatter.date(from: expiresAt)
				
				completionHandler(nil, self.authToken)
			}
		}
	}
}

internal extension Date {
	func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
		return self.compare(dateToCompare) == ComparisonResult.orderedDescending
	}
}
