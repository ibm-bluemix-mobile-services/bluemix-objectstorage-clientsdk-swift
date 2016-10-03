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



/// ObjectStorageObject instance represents a single object in the IBM Object Store service. Use ObjectStorageObject instance to load object content.
open class ObjectStorageObject{
    
    /// Object name
    open let name:String
    
    /// Object resource
    internal let resource:HttpResource
    
    internal let container:ObjectStorageContainer
    
    fileprivate let logger:Logger
    
    //HTTP Manager
    internal var httpManager:HttpManager
    
    /**
     Retrieved object NSData
     */
    open var data:Data? = nil
    
    internal init(name:String, resource: HttpResource, container:ObjectStorageContainer, data:Data? = nil){
        self.logger = Logger(forName:"ObjectStoreObject [\(container.name)]\\[\(name)]")
        self.name = name
        self.resource = resource
        self.container = container
        self.data = data
        self.httpManager = HttpClientManager()
    }
    
    /**
     Load the object content
     
     - Parameter shouldCache: Defines whether object content loaded from IBM Object Store service will be cached by this ObjectStoreObject instance
     */
    open func load(shouldCache:Bool = false, completionHandler:@escaping (ObjectStorageError?, Data?)->Void){
        logger.info("Loading object")
        
        container.objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error, nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            self.httpManager.get(resource: self.resource, headers: headers) { error, status, headers, data in
                if let error = error{
                    completionHandler(ObjectStorageError.from(httpError: error), nil)
                } else {
                    self.logger.info("Loaded object")
                    self.data = shouldCache ? data : nil;
                    completionHandler(nil, data)
                }
            }
        })
    }
    
    /**
     Delete the object
     */
    open func delete(completionHandler:@escaping (ObjectStorageError?)->Void){
        self.container.delete(object: self.name, completionHandler: completionHandler)
    }
    
    /**
     Update object metadata
     
     - Parameter metadata: a dictionary of metadata items, e.g. ["X-Object-Meta-Subject":"AmericanHistory"]. It is possible to supply multiple metadata items within same invocation. To delete a particular metadata item set it's value to an empty string, e.g. ["X-Object-Meta-Subject":""]. See Object Storage API v1 for more information about possible metadata items - http://developer.openstack.org/api-ref-objectstorage-v1.html
     */
    open func update(metadata:[String: String], completionHandler: @escaping (ObjectStorageError?)->Void){
        logger.info("Updating metadata :: \(metadata)")
        container.objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken, additionalHeaders: metadata)
            
            self.httpManager.post(resource: self.resource, headers: headers, data: nil) { error, status, headers, data in
                if let error = error {
                    completionHandler(ObjectStorageError.from(httpError: error))
                } else {
                    self.logger.info("Metadata updated :: \(metadata)")
                    completionHandler(nil)
                }
            }
        })
        
    }
    
    /**
     Retrieve object metadata. The metadata will be returned to a completionHandler as a [String: String] instance with set of keys and values
     
     */
    open func retrieveMetadata(completionHandler: @escaping (ObjectStorageError?, _ metadata: [String:String]?) -> Void){
        logger.info("Retrieving metadata")
        
        container.objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error, nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            self.httpManager.head(resource: self.resource, headers: headers) { error, status, headers, data in
                if let error = error {
                    completionHandler(ObjectStorageError.from(httpError: error), nil)
                } else {
                    self.logger.info("Metadata retrieved :: \(headers)")
                    completionHandler(nil, headers);
                }
            }
        })
    }
}
