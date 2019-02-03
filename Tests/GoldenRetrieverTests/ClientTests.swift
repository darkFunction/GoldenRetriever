import XCTest
@testable import GoldenRetriever

fileprivate typealias TestClient = Client<TestEndpoint, TestBackendError>

final class ClientTests: XCTestCase {
    
    struct MockTicket: Codable {
        let name = "a ticket"
    }
    
    func testCodableDataReturnedCallsSuccess() {
        struct MockSession: NetworkSession {
            func request(_ request: URLRequest, completion: NetworkSession.Response?) {
                let data = try? MockTicket().toJSON()
                completion?(data, nil, nil)
            }
        }
        
        let completedExpectation = expectation(description: "completion called")
        
        TestClient(networkSession: MockSession()).request(.tickets(param1: nil, param2: nil), success: { (response: MockTicket) in
            completedExpectation.fulfill();
        }) { (error) in
            
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testNoDataReturnedCallsFailure() {
        struct MockSession: NetworkSession {
            func request(_ request: URLRequest, completion: NetworkSession.Response?) {
                let data = try? MockTicket().toJSON()
                completion?(nil, nil, nil)
            }
        }
        
        let failureExpectation = expectation(description: "fail closure called")
        
        TestClient(networkSession: MockSession()).request(.tickets(param1: nil, param2: nil), success: { (response: MockTicket) in
        }) { (error) in
            failureExpectation.fulfill();
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testNonDecodableDataReturnedCallsFailure() {
        struct MockSession: NetworkSession {
            func request(_ request: URLRequest, completion: NetworkSession.Response?) {
                completion?("random string".data(using: .utf8), nil, nil)
            }
        }
        
        let failureExpectation = expectation(description: "fail closure called")
        
        TestClient(networkSession: MockSession()).request(.tickets(param1: nil, param2: nil), success: { (response: MockTicket) in
        }) { (error) in
            failureExpectation.fulfill();
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    static var allTests = [
        ("testCodableDataReturnedCallsSuccess", testCodableDataReturnedCallsSuccess)
    ]
}

