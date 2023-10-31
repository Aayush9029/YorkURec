//
//  Mock+Extensions.swift
//  YorkURec
//
//  Created by Aayush Pokharel on 2023-10-31.
//


import Foundation

enum MockupError: Error {
    case fileNotFound
    case invalidData
}

// MARK: - Reads a JSON file stored in project and returns Data Type

func localJSONFile(forName name: String) throws -> Data {
    if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
        let fileUrl = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: fileUrl)
        return data
    } else {
        print("\(name): File doesn't exits")
        throw MockupError.fileNotFound
    }
}

// MARK: - Automatically reads JSON files and generates swift models based on parent struct.

func exampleModel<T: Decodable>(forName name: String) -> T? {
    guard let data = try? localJSONFile(forName: name) else {
        print("JSON Model Generation Error: Something's wrong with your \(name).json file, It might not be a valid .json file")
        return nil
    }
    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch let DecodingError.valueNotFound(value, context) {
        print("Value '\(value)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch let DecodingError.typeMismatch(type, context) {
        print("Type '\(type)' mismatch:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch {
        print(String(describing: error))
    }
    return nil
}

// Usage: static let example: StreamerModel? = exampleModel(forName: "streamer")

