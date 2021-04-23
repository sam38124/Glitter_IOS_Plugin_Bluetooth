import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Glitter_BLETests.allTests),
    ]
}
#endif
