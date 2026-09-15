import Foundation

struct NocturneFavoriteFood: Decodable, Equatable, Identifiable {
    let id: String
    let type: String
    let category: String
    let subcategory: String
    let name: String
    let portion: Double
    let carbs: Double
    let fat: Double
    let protein: Double
    let energy: Double
    let gi: Int
    let unit: String

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, category, subcategory, name, portion, carbs, fat, protein, energy, gi, unit
    }

    init(id: String, type: String, category: String, subcategory: String, name: String, portion: Double, carbs: Double, fat: Double, protein: Double, energy: Double, gi: Int, unit: String) {
        self.id = id
        self.type = type
        self.category = category
        self.subcategory = subcategory
        self.name = name
        self.portion = portion
        self.carbs = carbs
        self.fat = fat
        self.protein = protein
        self.energy = energy
        self.gi = gi
        self.unit = unit
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Nocturne's Food.Id is nullable; every real favorite has one, but decode
        // defensively rather than failing the whole list over one bad record.
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        type = try container.decode(String.self, forKey: .type)
        category = try container.decode(String.self, forKey: .category)
        subcategory = try container.decode(String.self, forKey: .subcategory)
        name = try container.decode(String.self, forKey: .name)
        portion = try container.decode(Double.self, forKey: .portion)
        carbs = try container.decode(Double.self, forKey: .carbs)
        fat = try container.decode(Double.self, forKey: .fat)
        protein = try container.decode(Double.self, forKey: .protein)
        energy = try container.decode(Double.self, forKey: .energy)
        gi = try container.decode(Int.self, forKey: .gi)
        unit = try container.decode(String.self, forKey: .unit)
    }
}
