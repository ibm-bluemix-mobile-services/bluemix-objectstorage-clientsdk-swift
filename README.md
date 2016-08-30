<img src="https://bluemixassets.eu-gb.mybluemix.net/api/Products/image/logos/object-storage.svg?key=[bluemix-objectstorage-clientsdk-swift]&event=readme-image-view" alt="[BluemixObjectStorageSDK]" width="200px"/>

## Object Storage
Bluemix Client SDK for Object Storage in Swift

[![](https://img.shields.io/badge/bluemix-powered-blue.svg)](https://bluemix.net)
[![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bluemix-objectstorage-clientsdk-swift.svg?branch=master)](https://travis-ci.org/ibm-bluemix-mobile-services/bluemix-objectstorage-clientsdk-swift)
 [![Platform](https://img.shields.io/cocoapods/p/BluemixObjectStorage.svg?style=flat)](http://cocoadocs.org/docsets/BluemixObjectStorage)

### Table of Contents
* [Summary](#summary)
* [Requirements](#requirements)
* [Installation](#installation)
* [Example Usage](#example-usage)
* [License](#license)

### Summary
Object Storage provides an unstructured cloud data store to build and deliver cloud applications and services with lowered cost, reliability, and speed to market. Bluemix developers and users can access and store unstructured data content and can interactively compose and connect to applications and services. The Object Storage service also provides programmatic access via API, SDKs and a consumable UI for object management.

You can use this client SDK to store and retrieve binary data on your Object Storage service instance on Bluemix from your iOS application.

Read the [official documentation](https://new-console.ng.bluemix.net/docs/services/ObjectStorage/index.html) for information about getting started with Object Storage.

[//]: # (Link to the Getting Started docs)
[//]: # (Replace [Service] with your Service name)

### Requirements
* iOS 8.0+
* Xcode 7+

### Installation
The Bluemix Mobile services Swift SDKs are available via [Cocoapods](https://cocoapods.org/pods/BluemixObjectStorage)

##### Cocoapods
To install Object Storage using Cocoapods, add it to your `Podfile`:
```ruby
use_frameworks!

target 'MyApp' do
    pod 'BluemixObjectStorage', '~> 0.0'
end
```
Then run the `pod install` command.


### Example Usage
[//]: # (You are going to want to put common scenarios for the examples here to avoid looking through the docs for non-complex usage)

* [Account metadata](#account-metadata)
* [Connecting to Object Storage](#connecting-to-object-storage)
* [Managing containers](#managing-containers)
* [Managing objects](#managing-objects)
* [Types of errors](#types-of-errors)

> View the complete API reference [here]().
[//]: # (link to JavaDoc, Jazzy for Swift, etc.)

--

#### Account metadata

##### Update account metadata

```swift
let metadata:Dictionary<String, String> = ["X-Account-Meta-SomeName":"SomeValue"]
objstorage.updateMetadata(metadata: metadata) { (error) in
	if let error = error {
		print("updateMetadata error :: \(error)")
	} else {
		print("updateMetadata success")
	}
}
```

##### Retrieve account metadata

```swift
objstorage.retrieveMetadata { (error, metadata) in
	if let error = error {
		print("retrieveMetadata error :: \(error)")
	} else {
		print("retrieveMetadata success :: \(metadata)")
	}
}
```
> [View examples](#example-usage)

--

#### Connecting to Object Storage
Use `ObjectStorage` instance to connect to IBM Object Storage service.

##### Connect to the IBM Object Storage service using userId and password

```swift
let objstorage = ObjectStorage(projectId:"your-project-id")
objstorage.connect(	userId: "your-service-userId",
 					password: "your-service-password",
					region: ObjectStorage.REGION_DALLAS) { (error) in
	if let error = error {
		print("connect error :: \(error)")
	} else {
		print("connect success")
	}							
}
```

##### Connect to the IBM Object Storage service using explicit authToken

```swift
let objstorage = ObjectStorage(projectId:"your-project-id")
objstorage.connect(	authToken: "your-auth-token",
					region: ObjectStorage.REGION_DALLAS) { (error) in
	if let error = error {
		print("connect error :: \(error)")
	} else {
		print("connect success")
	}							
}
```
> [View examples](#example-usage)

--

#### Managing containers
Use ObjectStorage instance to manage containers.

##### Create a new container

```swift
objstorage.createContainer(name: "container-name") { (error, container) in
	if let error = error {
		print("createContainer error :: \(error)")
	} else {
		print("createContainer success :: \(container?.name)")
	}
}
```

##### Retrieve an existing container

```swift
objstorage.retrieveContainer(name: "container-name") { (error, container) in
	if let error = error {
		print("retrieveContainer error :: \(error)")
	} else {
		print("retrieveContainer success :: \(container?.name)")
	}
}
```

##### Retrieve a list of existing containers

```swift
objstorage.retrieveContainersList { (error, containers) in
	if let error = error {
		print("retrieveContainersList error :: \(error)")
	} else {
		print("retrieveContainersList success :: \(containers?.description)")
	}
}
```

##### Delete an existing container

```swift
objstorage.deleteContainer(name: "container-name") { (error) in
	if let error = error {
		print("deleteContainer error :: \(error)")
	} else {
		print("deleteContainer success")
	}
}
```
You can also use `ObjectStorageContainer` instance to manage containers


##### Delete the container

```swift
container.delete { (error) in
	if let error = error {
		print("deleteContainer error :: \(error)")
	} else {
		print("deleteContainer success")
	}
}
```

##### Update container metadata

```swift
let metadata:Dictionary<String, String> = ["X-Container-Meta-SomeName":"SomeValue"]
container.updateMetadata(metadata: metadata) { (error) in
	if let error = error {
		print("updateMetadata error :: \(error)")
	} else {
		print("updateMetadata success")
	}
}
```

##### Retrieve container metadata

```swift
container.retrieveMetadata { (error, metadata) in
	if let error = error {
		print("retrieveMetadata error :: \(error)")
	} else {
		print("retrieveMetadata success :: \(metadata)")
	}
}
```

> [View examples](#example-usage)

--

#### Managing Objects

Use `ObjectStorageContainer` instance to manage objects inside of particular container

##### Create a new object or update an existing one

```swift
#if os(Linux)
	let data = "testdata".dataUsingEncoding(NSUTF8StringEncoding)!
#else
	let data = "testdata".data(using: NSUTF8StringEncoding)!
#endif
let data = str.dataUsingEncoding(NSUTF8StringEncoding)
container.storeObject(name: "object-name", data: data) { (error, object) in
	if let error = error {
		print("storeObject error :: \(error)")
	} else {
		print("storeObject success :: \(object?.name)")
	}
}
```

##### Retrieve an existing object

```swift
container.retrieveObject(name: "object-name") { (error, object) in
	if let error = error {
		print("retrieveObject error :: \(error)")
	} else {
		print("retrieveObject success :: \(object?.name)")
	}
}
```

##### Retrieve a list of existing objects

```swift
container.retrieveObjectsList { (error, objects) in
	if let error = error {
		print("retrieveObjectsList error :: \(error)")
	} else {
		print("retrieveObjectsList success :: \(objects?.description)")
	}
}
```

##### Delete an existing object

```swift
container.deleteObject(name: "object-name") { (error) in
	if let error = error {
		print("deleteObject error :: \(error)")
	} else {
		print("deleteObject success")
	}
}
```

Use `ObjectStorageObject` instance to load object content on demand

##### Load the object content

```swift
object.load(shouldCache: false) { (error, data) in
	if let error = error {
		print("load error :: \(error)")
	} else {
		print("load success :: \(data)")
	}
}
```

##### Update object metadata

```swift
let metadata:Dictionary<String, String> = ["X-Object-Meta-SomeName":"SomeValue"]
object.updateMetadata(metadata: metadata) { (error) in
	if let error = error {
		print("updateMetadata error :: \(error)")
	} else {
		print("updateMetadata success")
	}
}
```

##### Retrieve object metadata

```swift
object.retrieveMetadata { (error, metadata) in
	if let error = error {
		print("retrieveMetadata error :: \(error)")
	} else {
		print("retrieveMetadata success :: \(metadata)")
	}
}
```
> [View examples](#example-usage)

--

#### Types of errors

#### ObjectStorageError

The `ObjectStorageError` is an enum with possible failure reasons

```swift
enum ObjectStorageError: ErrorType {
	case ConnectionFailure
	case NotFound
	case Unauthorized
	case ServerError
	case InvalidUri
	case FailedToRetrieveAuthToken
	case NotConnected
	case CannotRefreshAuthToken
}
```


### License
This package contains code licensed under the Apache License, Version 2.0 (the "License"). You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and may also view the License in the LICENSE file within this package.
