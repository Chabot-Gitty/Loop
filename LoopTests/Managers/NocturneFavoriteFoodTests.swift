import XCTest
@testable import Loop

final class NocturneFavoriteFoodTests: XCTestCase {
    func testDecodesFoodEntry() throws {
        let json = """
        {
          "_id": "abc123",
          "type": "food",
          "category": "Breakfast",
          "subcategory": "",
          "name": "Oatmeal",
          "portion": 1,
          "carbs": 27,
          "fat": 3,
          "protein": 5,
          "energy": 620,
          "gi": 2,
          "unit": "g"
        }
        """.data(using: .utf8)!

        let food = try JSONDecoder().decode(NocturneFavoriteFood.self, from: json)

        XCTAssertEqual(food.id, "abc123")
        XCTAssertEqual(food.type, "food")
        XCTAssertEqual(food.name, "Oatmeal")
        XCTAssertEqual(food.carbs, 27)
        XCTAssertEqual(food.portion, 1)
        XCTAssertEqual(food.unit, "g")
    }

    func testDecodesQuickpickEntryIgnoringExtraFields() throws {
        let json = """
        {
          "_id": "combo1",
          "type": "quickpick",
          "category": "Breakfast",
          "subcategory": "",
          "name": "Breakfast Combo",
          "portion": 1,
          "carbs": 40,
          "fat": 0,
          "protein": 0,
          "energy": 0,
          "gi": 2,
          "unit": "g",
          "foods": [
            { "name": "Toast", "portion": 1, "carbs": 15, "unit": "g", "portions": 1.0 }
          ]
        }
        """.data(using: .utf8)!

        let food = try JSONDecoder().decode(NocturneFavoriteFood.self, from: json)

        XCTAssertEqual(food.type, "quickpick")
        XCTAssertEqual(food.name, "Breakfast Combo")
        XCTAssertEqual(food.carbs, 40)
    }

    func testDecodesMissingIdWithGeneratedFallback() throws {
        let json = """
        {
          "type": "food",
          "category": "",
          "subcategory": "",
          "name": "No ID Food",
          "portion": 1,
          "carbs": 10,
          "fat": 0,
          "protein": 0,
          "energy": 0,
          "gi": 2,
          "unit": "g"
        }
        """.data(using: .utf8)!

        let food = try JSONDecoder().decode(NocturneFavoriteFood.self, from: json)

        XCTAssertFalse(food.id.isEmpty)
        XCTAssertEqual(food.name, "No ID Food")
    }
}
