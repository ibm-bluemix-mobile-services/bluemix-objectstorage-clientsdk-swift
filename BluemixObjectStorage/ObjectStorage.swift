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
#if swift(>=3)
    import SimpleLogger
    import SimpleHttpClient
#else
    typealias ErrorProtocol = ErrorType
#endif

/// Use ObjectStore instance to connect to IBM Object Store service and manage containers
public class ObjectStorage {
    
    /// Use this value in .connect(...)  methods to connect to Dallas instance of IBM Object Store
    public static let REGION_DALLAS = "DALLAS"
    internal static let DALLAS_RESOURCE = HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_")
    
    /// Use this value in .connect(...)  methods to connect to London instance of IBM Object Store
    public static let REGION_LONDON = "LONDON"
    internal static let LONDON_RESOURCE = HttpResource(schema: "https", host: "lon.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_")
    
    private let logger:Logger
    
    internal var projectId:String! = ""
    internal var projectResource: HttpResource?
    internal var authTokenManager:AuthTokenManager?
    internal var httpManager: HttpManager?
    
    /**
     Initialize ObjectStore by supplying projectId
     
     - Parameter projectId: ProjectId provided by the IBM Object Store. Can be obtained via VCAP_SERVICES, service instance keys or IBM Object Store dashboard.
     */
    public init(projectId:String){
        self.projectId = projectId
        logger = Logger(forName:"ObjectStore [\(self.projectId)]")
        httpManager = HttpClientManager()
    }
    
    /**
     Connect to ObjectStorage using userId and password.
     
     - Parameter userId: UserId provided by the IBM Object Store. Can be obtained via VCAP_SERVICES, service instance keys or IBM Object Store dashboard.
     - Parameter password: Password provided by the IBM Object Store. Can be obtained via VCAP_SERVICES, service instance keys or IBM Object Store dashboard.
     - Parameter region: Defines whether ObjectStore should connect to Dallas or London instance of IBM Object Store. Use *ObjectStore.REGION_DALLAS* and *ObjectStore.REGION_LONDON* as values
     */
    public func connect(userId userId:String, password:String, region:String, completionHandler:(error: ObjectStorageError?) -> Void) {
        self.authTokenManager = self.httpManager!.getAuthTokenManager(projectId, userId: userId, password: password)
        
        authTokenManager?.refreshAuthToken { (error, authToken) in
            if error != nil {
                self.authTokenManager = nil
                completionHandler(error: ObjectStorageError.FailedToRetrieveAuthToken)
            } else {
                self.projectResource = (region == ObjectStorage.REGION_DALLAS) ?
                    ObjectStorage.DALLAS_RESOURCE.resourceByAddingPathComponent(pathComponent: self.projectId) :
                    ObjectStorage.LONDON_RESOURCE.resourceByAddingPathComponent(pathComponent: self.projectId)
                
                completionHandler(error: nil)
            }
        }
    }
    
    /**
     Connect to ObjectStorage using pre-obtained authToken.
     
     - Parameter authToken: authToken obtained from Identity Server
     - Parameter region: Defines whether ObjectStore should connect to Dallas or London instance of IBM Object Store. Use *ObjectStore.REGION_DALLAS* and *ObjectStore.REGION_LONDON* as values
     */
    public func connect(authToken:String, region:String, completionHandler:(error: ObjectStorageError?) -> Void) {
        self.authTokenManager = self.httpManager!.getAuthTokenManager(projectId, authToken: authToken)
        
        //if first time calling this method, the project resource could be nil, then would fail when retrieveContainer is called
        self.projectResource = (region == ObjectStorage.REGION_DALLAS) ?
            ObjectStorage.DALLAS_RESOURCE.resourceByAddingPathComponent(pathComponent: self.projectId) :
            ObjectStorage.LONDON_RESOURCE.resourceByAddingPathComponent(pathComponent: self.projectId)
        
        self.retrieveContainersList { (error, containers) in
            if let error = error{
                self.authTokenManager = nil
                completionHandler(error: error)
            } else {
                self.projectResource = (region == ObjectStorage.REGION_DALLAS) ?
                    ObjectStorage.DALLAS_RESOURCE.resourceByAddingPathComponent(pathComponent: self.projectId) :
                    ObjectStorage.LONDON_RESOURCE.resourceByAddingPathComponent(pathComponent: self.projectId)
                completionHandler(error: nil)
            }
        }
    }
    
    
    /**
     Create a new container
     
     - Parameter name: The name of container to be created
     */
    public func createContainer(name name:String, completionHandler: (error:ObjectStorageError?, container: ObjectStorageContainer?) -> Void){
        logger.info("Creating container [\(name)]")
        
        guard projectResource != nil else{
            logger.error(String(ObjectStorageError.NotConnected))
            return completionHandler(error: ObjectStorageError.NotConnected, container: nil)
        }
        
        authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, container: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.projectResource?.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager!.put(resource: resource!, headers: headers, data: nil) { error, status, headers, data in
                if let error = error {
                    completionHandler(error: ObjectStorageError.from(httpError: error), container: nil)
                } else {
                    self.logger.info("Created container [\(name)]")
                    let container = ObjectStorageContainer(name: name, resource: resource!, objectStore: self)
                    completionHandler(error: nil, container: container)
                }
            }
        })
    }
    
    
    /**
     Retrieve an existing container
     
     - Parameter name: The name of container to retrieve
     */
    public func retrieveContainer(name name:String, completionHandler: (error:ObjectStorageError?, container: ObjectStorageContainer?) -> Void){
        logger.info("Retrieving container [\(name)]")
        
        guard projectResource != nil else{
            logger.error(String(ObjectStorageError.NotConnected))
            return completionHandler(error: ObjectStorageError.NotConnected, container: nil)
        }
        
        authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, container: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.projectResource?.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager!.get(resource: resource!, headers: headers) { error, status, headers, data in
                if let error = error {
                    completionHandler(error: ObjectStorageError.from(httpError: error), container: nil)
                } else {
                    self.logger.info("Retrieved container [\(name)]")
                    let container = ObjectStorageContainer(name: name, resource: resource!, objectStore: self)
                    completionHandler(error: nil, container: container)
                }
            }
        })
    }
    
    /**
     Retrieve a list of existing containers
     
     */
    public func retrieveContainersList(completionHandler completionHandler: (error:ObjectStorageError?, containers: [ObjectStorageContainer]?) -> Void){
        logger.info("Retrieving containers list")
        
        guard projectResource != nil else{
            logger.error(String(ObjectStorageError.NotConnected))
            return completionHandler(error: ObjectStorageError.NotConnected, containers: nil)
        }
        
        authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, containers: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            
            self.httpManager!.get(resource: self.projectResource!, headers: headers) {error, status, headers, data in
                if let error = error{
                    completionHandler(error: ObjectStorageError.from(httpError: error), containers: nil)
                } else {
                    self.logger.info("Retrieved containers list")
                    var containersList = [ObjectStorageContainer]()
                    let responseBodyString = String(data: data!, encoding: NSUTF8StringEncoding)!
                    
                    let containerNames = responseBodyString.componentsSeparatedByString("\n")
                    
                    for containerName:String in containerNames{
                        if containerName.characters.count == 0 {
                            continue
                        }
                        let containerResource = self.projectResource?.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + containerName))
                        let container = ObjectStorageContainer(name: containerName, resource: containerResource!, objectStore: self)
                        containersList.append(container)
                    }
                    completionHandler(error: nil, containers: containersList)
                }
            }
        })
        
    }
    
    /**
     Delete an existing container
     
     - Parameter name: The name of container to delete
     */
    public func deleteContainer(name name:String, completionHandler: (error:ObjectStorageError?) -> Void){
        logger.info("Deleting container [\(name)]")
        
        guard projectResource != nil else{
            logger.error(String(ObjectStorageError.NotConnected))
            return completionHandler(error: ObjectStorageError.NotConnected)
        }
        
        authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.projectResource?.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager!.delete(resource: resource!, headers: headers) { error, status, headers, data in
                if let error = error {
                    completionHandler(error: ObjectStorageError.from(httpError: error))
                } else {
                    self.logger.info("Deleted container [\(name)]")
                    completionHandler(error: nil)
                }
            }
        })
    }
    
    
    /**
     Update account metadata
     
     - Parameter metadata: a dictionary of metadata items, e.g. ["X-Account-Meta-Subject":"AmericanHistory"]. It is possible to supply multiple metadata items within same invocation. To delete a particular metadata item set it's value to an empty string, e.g. ["X-Account-Meta-Subject":""]. See Object Storage API v1 for more information about possible metadata items - http://developer.openstack.org/api-ref-objectstorage-v1.html
     */
    public func updateMetadata(metadata metadata:Dictionary<String, String>, completionHandler: (error:ObjectStorageError?) -> Void){
        logger.info("Updating metadata :: \(metadata)")
        
        guard projectResource != nil else {
            logger.error(String(ObjectStorageError.NotConnected))
            return completionHandler(error: ObjectStorageError.NotConnected)
        }
        
        authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken, additionalHeaders: metadata)
            self.httpManager!.post(resource: self.projectResource!, headers: headers, data:nil) { error, status, headers, data in
                if let error = error {
                    completionHandler(error:ObjectStorageError.from(httpError: error))
                } else {
                    self.logger.info("Metadata updated :: \(metadata)")
                    completionHandler(error:nil)
                }
            }
        });
        
    }
    
    /**
     Retrieve account metadata. The metadata will be returned to a completionHandler as a Dictionary<String, String> instance with set of keys and values
     
     */
    public func retrieveMetadata(completionHandler completionHandler: (error: ObjectStorageError?, metadata: [String:String]?) -> Void) {
        logger.info("Retrieving metadata")
        
        guard projectResource != nil else{
            logger.error(String(ObjectStorageError.NotConnected))
            return completionHandler(error: ObjectStorageError.NotConnected, metadata: nil)
        }
        
        authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, metadata: nil)
            }
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            //osHttpManager.head(...)
            self.httpManager!.head(resource: self.projectResource!, headers: headers) { error, status, headers, data in
                if let error = error {
                    completionHandler(error: ObjectStorageError.from(httpError: error), metadata: nil)
                } else {
                    self.logger.info("Metadata retrieved :: \(headers)")
                    completionHandler(error: nil, metadata: headers);
                }
            }
        })
    }
}

