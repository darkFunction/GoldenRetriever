# GoldenRetriever

Let me guess, your application needs to interact with a HTTP server to send and retreive data. GoldenRetriever allows you to specify all of your endpoints in a single, clear `enum`format with in-built support for JSON and `Codable` types, as well as authentication headers. The request syntax couldn't be easier- no need for a middle-man class to encapsulate interactions with your backend.

## Install

```
pod 'GoldenRetriever', :git => 'https://github.com/darkFunction/GoldenRetriever'
```

## 1. Define your endpoints in one neat specification

Just implement the `Endpoint` protocol. 

```swift
enum MyEndpoint: Endpoint {
    var baseAddress: URL {
        return URL(string: "https://www.ticketsamaritan.uk/api")!
    }

    case tickets(filter: String?)
    case login(username: String, password: String)
    case signup(user: CreateUser)
    case submitTicket(ticket: CreateTicket, user: UserManager.User)

    var info: EndpointInfo {
        switch self {
        case .tickets(let filter):
            return .get(path: "/tickets", parameters: ["filter": filter])
        case .login(let username, let password):
            return .post(path: "/users/login", credentials: .basicAuth(username: username, password: password))
        case .signup(let user):
            return .post(path: "/users", body: .json(user))
        case .submitTicket(let ticket, let user):
            return .post(path: "/tickets", body: .json(ticket), credentials: .bearerToken(user.token))
        }
    }
}
```

## 2. Define the format the backend responds with for errors 

Implement `BackendErrorResponse`

```swift
public struct TSBackendErrorResponse: BackendErrorResponse {
    public let reason: String
}
```

## Use it!

```swift
let myClient = Client<TSEndpoint, TSBackendErrorResponse>()

// Login with basic auth
myClient.request(
  .login(username: username, password: password),
  success: { (response: LoginResponse) in
  
  },
  failure: { error in
  
  })
  
// Fetch tickets (automatically decoded from JSON)
myClient.request(
  .tickets(filter: filter),
  success: { (tickets: [Ticket]) in

  },
  failure: { error in

  })
  
// Fetch tickets with custom decoding
myClient.request(
  .tickets(filter: filter),
  transform: { try myDecodeFunction($0) },
  .tickets(filter: filter),
  success: { (tickets: [Ticket]) in

  },
  failure: { error in

  })
```
