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

internal class HttpClientManager: HttpManager{
    
    internal func get(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.get(resource:resource, headers: headers, completionHandler: completionHandler)
    }
    
    internal func put(resource: HttpResource, headers:[String:String]?, data:Data?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.put(resource: resource, headers: headers, data: data, completionHandler: completionHandler)
    }
    
    internal func delete(resource: HttpResource, headers:[String:String]?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.delete(resource:resource, headers: headers, completionHandler: completionHandler)
    }
    
    internal func post(resource: HttpResource, headers:[String:String]?, data:Data?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.post(resource: resource, headers: headers, data: data, completionHandler: completionHandler)
    }
    
    internal func head(resource: HttpResource, headers:[String:String]?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.head(resource:resource, headers: headers, completionHandler: completionHandler)
    }
    
    internal func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, userId: userId, password: password)
    }
    
    internal func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, authToken: authToken)
    }
}
