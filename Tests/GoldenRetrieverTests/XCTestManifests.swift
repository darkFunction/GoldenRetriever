import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EndpointTests.allTests),
        testCase(ClientTests.allTests)
    ]
}
#endif
