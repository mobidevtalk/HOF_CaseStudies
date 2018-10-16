import Foundation
import XCTest

enum Favourite: String{
    case equal = "💖 = "
    case blue = "💙 = "
    case green = "💚 = "
}

extension Favourite{
    var weight: Int{
        switch self {
        case .green:
            return 2
        case .blue:
            return 1
        default:
            return 0
        }
    }
    
}

typealias CombinedValue = (precedence: Favourite, count: Int)

func mix(_ s1: String, _ s2: String) -> String {
    let combined = combinedMaxChar(s1, s2)
    let sortedKey = sortKeys(combined)
    
    return format(combined, with: sortedKey)
}

func format(_ input: [Character: CombinedValue]?, with sortedKeys: [Character]?) -> String {
    guard let input = input, let sortedKeys = sortedKeys, input.count > 0, sortedKeys.count > 0 else { return "" }
    
    var combine = ""
    sortedKeys.forEach({
        guard let value = input[$0]else{return}
        
        combine += value.precedence.rawValue
        
        for _ in 1...value.count {
            combine += String($0)
        }
        
        combine += "\n"
    })
    combine.removeLast()
    print("combine:\n\(combine)")
    return combine
}

func sortKeys(_ input: [Character: CombinedValue]?) -> [Character]?{
    guard let input = input, input.count > 0 else { return nil }
    return input.sorted(by: {
        $0.value.count == $1.value.count ?
            $0.value.precedence.weight == $1.value.precedence.weight ?
                $0.key < $1.key // 3. count same and weight(1,2,E) same, so based on alphabatically
                : $0.value.precedence.weight > $1.value.precedence.weight // 2. count same, so based on weight 1 > 2 > 3
            : $0.value.count > $1.value.count   // 1. based on count
    }).map({ $0.key })
}

func combinedMaxChar(_ firstInput: String, _ secondInput: String) -> [Character: CombinedValue]?{
    guard firstInput != secondInput else { return nil }
    
    let firstCharList = parseChar(firstInput)
    let secondCharList = parseChar(secondInput)
    
    if (firstCharList == nil && secondCharList == nil) || (firstCharList?.count == 0 && secondCharList?.count == 0){
        return nil
    }
    
    let firstCombine = firstCharList?.mapValues({ CombinedValue(precedence: .green, $0) })
    let secondCombine = secondCharList?.mapValues({ CombinedValue(precedence: .blue, $0) })
    
    return firstCombine?.merging(secondCombine!, uniquingKeysWith: { $0.count > $1.count ? $0 : $0.count == $1.count ? CombinedValue(precedence: .equal, count: $0.count) : $1 })
}

func parseChar(_ input: String) -> [Character: Int]?{
    let valid = input.components(separatedBy: CharacterSet.lowercaseLetters.inverted).joined()
    guard valid.count > 1 else { return nil }
    
    var output = [Character: Int]()
    
    valid.map({ output[$0] = output.keys.contains($0) ? output[$0]! + 1 :  1 })
    
    return output.filter({ $0.value > 1 })
}

class SolutionTest: XCTestCase {
    
    // MARK: - Parsing
    func test_parseChar_EmptyChar_occuranceNil() {
        XCTAssertNil(parseChar(""))
    }
    
    func test_parseChar_single_occuranceNotNil() {
        XCTAssertNotNil(parseChar("aa"))
    }
    
    func test_parseChar_forSingleChar_occuranceNil() {
        XCTAssertNil(parseChar("a"))
    }
    
    func test_parseChar_TwoSameChar_occuranceTwo() {
        let total = parseChar("aa")?["a"]
        XCTAssertEqual(total, 2)
    }
    
    func test_parseChar_ThreeSameChar_occuranceThree() {
        let total = parseChar("aaa")?["a"]
        XCTAssertEqual(total, 3)
    }
    
    func test_parseChar_mixChar_occuranceCorrespondingTimes() {
        let output = parseChar("aaabbbb")
        let totalA = output?["a"]
        let totalB = output?["b"]
        
        XCTAssertEqual(totalA, 3)
        XCTAssertEqual(totalB, 4)
    }
    
    func test_parseChar_mixChar_SingleEntry_occuranceNil_ForSingleEntry() {
        let output = parseChar("aaabbbbc")
        let totalA = output?["a"]
        let totalB = output?["b"]
        let totalC = output?["c"]
        
        XCTAssertEqual(totalA, 3)
        XCTAssertEqual(totalB, 4)
        XCTAssertNil(totalC)
    }
    
    func test_parseChar_mixChar_InvalidCahrEntry_occuranceNil_ForInvalidCahr() {
        let output = parseChar("aaabbbbc***##)))")
        let totalA = output?["a"]
        let totalB = output?["b"]
        let totalC = output?["c"]
        let totalStart = output?["*"]
        let totalHash = output?["#"]
        let totalBraces = output?[")"]
        
        XCTAssertEqual(totalA, 3)
        XCTAssertEqual(totalB, 4)
        XCTAssertNil(totalC)
        XCTAssertNil(totalStart)
        XCTAssertNil(totalHash)
        XCTAssertNil(totalBraces)
    }
    
    func test_parseChar_String() {
        let input = "Are they here yes, they are here"
        let output = parseChar(input)
        
        XCTAssertEqual(output?["e"], 9)
        XCTAssertEqual(output?["y"], 3)
        XCTAssertEqual(output?["h"], 4)
        XCTAssertEqual(output?["r"], 4)
    }
    
    // MARK: - combinedMaxChar
    func test_combinedMaxChar_sameString_nil() {
        XCTAssertNil(combinedMaxChar("asd", "asd"))
    }
    
    func test_combinedMaxChar_noRepeatCharEntry_nil() {
        XCTAssertNil(combinedMaxChar("asd", "qasd"))
    }
    
    func test_combinedMaxChar_differentString_notNil() {
        XCTAssertNotNil(combinedMaxChar("aasd", "qasd"))
    }
    
    func test_combinedMaxChar_sameCharRepeatBothEntry_max() {
        let val = combinedMaxChar("aasd", "qasd")
        XCTAssertEqual(val?["a"]?.count, 2)
    }
    
    func test_combinedMaxChar_differentCharRepeatBothEntry_maxTimesChar() {
        let val = combinedMaxChar("aasd", "qassssd")
        XCTAssertEqual(val?["a"]?.count, 2)
        XCTAssertEqual(val?["s"]?.count, 4)
    }
    
    func test_combinedMaxChar_withInvalidChar_differentCharRepeatBothEntry_maxTimesChar() {
        let val = combinedMaxChar("aasd^#@$nnnna", "qaspqqq..,-0tttsssd")
        XCTAssertEqual(val?["a"]?.count, 3)
        XCTAssertEqual(val?["s"]?.count, 4)
        XCTAssertEqual(val?["n"]?.count, 4)
        XCTAssertEqual(val?["q"]?.count, 4)
        XCTAssertEqual(val?["t"]?.count, 3)
        
        XCTAssertNil(val?["d"])
        XCTAssertNil(val?["p"])
    }
    
    func test_combinedMaxChar_differentCharRepeatBothEntry_maxTimesChar_withPresedence() {
        let val = combinedMaxChar("aasd^#@$nnnna", "qaspqqq..,-0tttsssd")
        XCTAssertEqual(val?["a"]?.count, 3)
        XCTAssertEqual(val?["a"]?.precedence, .green)
        
        XCTAssertEqual(val?["s"]?.count, 4)
        XCTAssertEqual(val?["s"]?.precedence, .blue)
        
        XCTAssertEqual(val?["n"]?.count, 4)
        XCTAssertEqual(val?["n"]?.precedence, .green)
        
        XCTAssertEqual(val?["q"]?.count, 4)
        XCTAssertEqual(val?["q"]?.precedence, .blue)
        
        XCTAssertEqual(val?["t"]?.count, 3)
        XCTAssertEqual(val?["t"]?.precedence, .blue)
        
        XCTAssertNil(val?["d"])
        XCTAssertNil(val?["p"])
    }
    
    func test_combinedMaxChar_sameTimesCharBoth_equal() {
        let val = combinedMaxChar("aaakkoa", "ilannaelkjdaa")
        XCTAssertEqual(val?["a"]?.precedence, .equal)
        
    }
    
    // MARK: - Sorting
    
    func test_sortingKey_nilInput_nilOutput() {
        XCTAssertNil(sortKeys(nil))
    }
    
    func test_sortingKey_emptyInput_nilOutput() {
        XCTAssertNil(sortKeys([Character: CombinedValue]()))
    }
    
    func test_sortingKey_properInput_notNilOutput() {
        let input: [Character: CombinedValue] = ["d": (Favourite.green, 4)]
        XCTAssertNotNil(sortKeys(input))
    }
    
    func test_sortingKey_heightCount_loweIndex() {
        let input: [Character: CombinedValue] = ["d": (Favourite.green, 4),
                                                 "v": (Favourite.blue, 8)]
        let output = sortKeys(input)
        XCTAssertTrue(output!.firstIndex(of: "v")! < output!.firstIndex(of: "d")!)
    }
    
    func test_sortingKey_sameCount_precedenceOrdered() {
        let input:[Character: CombinedValue] = ["z": (Favourite.equal, 4),
                                                "d": (Favourite.blue, 4),
                                                "j": (Favourite.green, 4),
                                                "v": (Favourite.blue, 8)
        ]
        let output = sortKeys(input)!
        let firstOrder = output.firstIndex(of: "j")! < output.firstIndex(of: "d")!
        let secondOrder = output.firstIndex(of: "d")! < output.firstIndex(of: "z")!
        XCTAssertTrue(firstOrder && secondOrder)
    }
    
    func test_sortingKey_sameCountSamePrecedence_alphabeticOrdered() {
        let input:[Character: CombinedValue] = [
            "z": (Favourite.equal, 4),
            "d": (Favourite.blue, 4),
            "j": (Favourite.green, 4),
            "k": (Favourite.blue, 4),
            "i": (Favourite.green, 4),
            "l": (Favourite.equal, 4),
            "o": (Favourite.equal, 6),
            "v": (Favourite.blue, 8)
        ]
        let output = sortKeys(input)!
        let firstOrder = output.firstIndex(of: "i")! < output.firstIndex(of: "j")!
        let secondOrder = output.firstIndex(of: "j")! < output.firstIndex(of: "d")!
        let thirdOrder = output.firstIndex(of: "d")! < output.firstIndex(of: "k")!
        let fourthOrder = output.firstIndex(of: "k")! < output.firstIndex(of: "l")!
        let fifthOrder = output.firstIndex(of: "l")! < output.firstIndex(of: "z")!
        XCTAssertTrue(firstOrder && secondOrder && thirdOrder && fourthOrder && fifthOrder)
    }
    
    // MARK: - Formatter
    func test_format_nil_empty() {
        let val = format(nil, with: nil)
        XCTAssertNotNil(val)
        XCTAssertEqual(val, "")
    }
    
    func test_format_empty_empty() {
        let val = format([Character: CombinedValue](), with: [Character]())
        XCTAssertNotNil(val)
        XCTAssertEqual(val, "")
    }
    
    func test_format_alternateNilEmpty_empty() {
        let inputNotNil = format([Character: CombinedValue](), with: nil)
        XCTAssertNotNil(inputNotNil)
        XCTAssertEqual(inputNotNil, "")
        
        let val = format(nil, with: [Character]())
        XCTAssertNotNil(val)
        XCTAssertEqual(val, "")
    }
    
    func test_format_multpleChar_timesPrint(){
        let output = format(["z": (Favourite.equal, 4)],
                            with: ["z"])
        XCTAssertTrue(output.contains("zzzz"))
    }
    
    func test_format_returnShouldContainInputAsPrefix() {
        let output = format(["z": (Favourite.equal, 4)],
                            with: ["z"])
        XCTAssertTrue(output.contains("💖 = zzzz"))
    }
    
    func test_format_lasEntry_shouldNotContaintSlash() {
        let output = format(["z": (Favourite.equal, 4)],
                            with: ["z"])
        XCTAssertNotEqual(String(output.last!), "\n")
    }
    
    func test_amongTwoEntry_slashShouldPresent() {
        let output = format([
            "z": (Favourite.equal, 4),
            "a": (Favourite.green, 3)
            ], with: ["z" , "a"])
        XCTAssertTrue(output.contains("\n"))
        XCTAssertEqual(output.filter({ $0 == "\n" }).count, 1)
    }
    
    static var allTests = [
        ("mix", testExample),
        ]
    
    func testing(_ s1: String, _ s2: String, _ expected: String) {
        XCTAssertEqual(mix(s1, s2), expected)
    }
    
    func testExample() {
        testing("Are they here", "yes, they are here",
                "💙 = eeeee\n💙 = yy\n💖 = hh\n💖 = rr")
        testing("looping is fun but dangerous", "less dangerous than coding",
                "💚 = ooo\n💚 = uuu\n💙 = sss\n💖 = nnn\n💚 = ii\n💙 = aa\n💙 = dd\n💙 = ee\n💖 = gg")
        testing(" In many languages", " there's a pair of functions",
                "💚 = aaa\n💚 = nnn\n💚 = gg\n💙 = ee\n💙 = ff\n💙 = ii\n💙 = oo\n💙 = rr\n💙 = ss\n💙 = tt")
        testing("Lords of the Fallen", "gamekult", "💚 = ee\n💚 = ll\n💚 = oo")
        testing("codewars", "codewars", "")
        testing("A generation must confront the looming ",
                "codewarrs", "💚 = nnnnn\n💚 = ooooo\n💚 = tttt\n💚 = eee\n💚 = gg\n💚 = ii\n💚 = mm\n💖 = rr")
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
SolutionTest.defaultTestSuite.run()
