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
        // Nocturne's Food.Id is nullable, and several of the numeric/string fields
        // below are nullable in Nocturne's server-side model too. Decode those
        // defensively with fallbacks rather than failing the whole list over one
        // bad record. name, type, carbs, and portion are required for a food to be
        // usable for display, so those stay strict.
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        type = try container.decode(String.self, forKey: .type)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        subcategory = try container.decodeIfPresent(String.self, forKey: .subcategory) ?? ""
        name = try container.decode(String.self, forKey: .name)
        portion = try container.decode(Double.self, forKey: .portion)
        carbs = try container.decode(Double.self, forKey: .carbs)
        fat = try container.decodeIfPresent(Double.self, forKey: .fat) ?? 0
        protein = try container.decodeIfPresent(Double.self, forKey: .protein) ?? 0
        energy = try container.decodeIfPresent(Double.self, forKey: .energy) ?? 0
        gi = try container.decodeIfPresent(Int.self, forKey: .gi) ?? 0
        unit = try container.decodeIfPresent(String.self, forKey: .unit) ?? ""
    }
}
