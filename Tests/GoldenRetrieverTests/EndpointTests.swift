import XCTest
@testable import GoldenRetriever

final class EndpointTests: XCTestCase {
    func testOneEmptyParameter() {
        let endpoint = MockEndpoint.tickets(param1: nil, param2: "singleparam")
        guard let url = endpoint.url, let queryItems = URLComponents(string: url.absoluteString)?.queryItems else {
            XCTAssert(false, "URL construction failed")
            return
        }
        
        XCTAssertEqual(queryItems.count, 2, "Wrong number of URL queries")
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "param1", value: "")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "param2", value: "singleparam")))

    }
    
    func testTwoParameters() {
        let endpoint = MockEndpoint.tickets(param1: "testparam", param2: "string with spaces")
        guard let url = endpoint.url, let queryItems = URLComponents(string: url.absoluteString)?.queryItems else {
            XCTAssert(false, "URL construction failed")
            return
        }
        
        XCTAssertEqual(queryItems.count, 2, "Wrong number of URL queries")
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "param1", value: "testparam")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "param2", value: "string with spaces")))
    }

    static var allTests = [
        ("testOneEmptyParameter", testOneEmptyParameter),
        ("testTwoParameters", testTwoParameters),
    ]
}
