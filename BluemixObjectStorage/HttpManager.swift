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

internal protocol HttpManager{
    
    /**
     Send a GET request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func get(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler)
    
    /**
     Send a PUT request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter data: The data to send in request body
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func put(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler)
    
    /**
     Send a DELETE request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func delete(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler)
    
    /**
     Send a POST request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter data: The data to send in request body
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func post(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler)
    
    /**
     Send a HEAD request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    func head(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler)
    
    func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager
    
    func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager
}