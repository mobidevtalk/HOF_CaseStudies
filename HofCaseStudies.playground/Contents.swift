//: A UIKit based Playground for presenting user interface
  
import Foundation
import XCTest

//: Higher Order Function Case studies
struct TwentyNine{
    
    func reckon() -> Int {
        return 0
    }
}


//: Test cases
class HofCaseStudiesTest: XCTestCase{
    func testSetup() {
        XCTAssert(true)
    }
    
    func test_reckon() {
        let twentyNine = TwentyNine()
        XCTAssertEqual(twentyNine.reckon(), 0, "Default reckon Value should be zero")
    }
}


//: Test Observer
class TestObserver: NSObject, XCTestObservation {
    func testCase(_ testCase: XCTestCase,
                  didFailWithDescription description: String,
                  inFile filePath: String?,
                  atLine lineNumber: Int) {
        assertionFailure(description, line: UInt(lineNumber))
    }
}

let testObserver = TestObserver()
XCTestObservationCenter.shared.addTestObserver(testObserver)
HofCaseStudiesTest.defaultTestSuite.run()
