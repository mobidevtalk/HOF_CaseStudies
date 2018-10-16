//: A UIKit based Playground for presenting user interface
  
import Foundation
import XCTest

//: Higher Order Function Case studies

enum Precedence: Int{
    case Low
    case High
}

struct Value{
    let point: Int
    let precedence: Precedence?
}

extension Value: ExpressibleByIntegerLiteral{
    typealias IntegerLiteralType = Int
    
    init(integerLiteral value: Int) {
        self = Value(point: 0, precedence: Precedence(rawValue: 0))
    }
}

enum Card: Value{
    case Jack = Value(point: 3, precedence: nil)
    case Nine = 2
    case Ace = 1
    case Ten = 1
}

extension Card: RawRepresentable{
    typealias RawValue = Value
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case <#pattern#>:
            <#code#>
        default:
            <#code#>
        }
    }
}

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
    
    private func assert(for card:Card , point: Int){
        XCTAssertEqual(card.rawValue, point)
    }
    
    func test_JackEqualThreePoints() {
        assert(for: .Jack, point: 3)
    }
    
    func test_NineEquealsTwoPoints() {
        assert(for: .Nine, point: 2)
    }
    
    func test_AceEqualsOnePoints() {
        assert(for: .Ace, point: 1)
    }
    
    func test_TenEqualsOnePoints() {
        assert(for: .Ten, point: 1)
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
