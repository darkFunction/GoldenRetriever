import XCTest
@testable import GoldenRetriever

let testClient = Client<TestEndpoint, TestBackendError>()

final class GoldenRetrieverTests: XCTestCase {
    func testOneUrlParameter() {
        let endpoint = TestEndpoint.tickets(param1: nil, param2: "singleparam")
        XCTAssertEqual(endpoint.url, URL(string: "https://example.com/tickets?param2=singleparam&param1=")!)
    }
    
    func testTwoUrlParameters() {
        let endpoint = TestEndpoint.tickets(param1: "testparam", param2: "string with spaces")
        XCTAssertEqual(endpoint.url, URL(string: "https://example.com/tickets?param1=testparam&param2=string%20with%20spaces")!)
    }

    static var allTests = [
        ("testOneUrlParameter", testOneUrlParameter),
        ("testTwoUrlParameters", testTwoUrlParameters),
    ]
}


enum TestEndpoint: Endpoint {
    var baseAddress: URL {
        return URL(string: "https://example.com")!
    }
    
    case tickets(param1: String?, param2: String?)
    
    var info: EndpointInfo {
        switch self {
        case .tickets(let param1, let param2):
            return .get(path: "/tickets", parameters: ["param1": param1, "param2": param2])
        }
    }
}

struct TestResponse: Codable {
    let something: String
}

struct TestBackendError: BackendErrorResponse {
    let reason: String
}
