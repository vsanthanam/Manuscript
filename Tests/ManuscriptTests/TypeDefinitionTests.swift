// Manuscript
// TypeDefinitionTests.swift
//
// MIT License
//
// Copyright (c) 2026 Varun Santhanam
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
//
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Manuscript
import Testing

@Suite("Type Definition Tests", .tags(.parsing))
struct TypeDefinitionTests {

    @Test("Decode a structure")
    func decodeStructure() throws {
        let json = """
        { "name": "Pet", "fields": [ { "name": "id", "type": "integer" } ] }
        """
        let type = try JSONDecoder().decode(TypeDefinition.self, from: Data(json.utf8))
        #expect(type.name == "Pet")
        #expect(type.documentation == nil)
        #expect(type.shape == .structure([Field(name: "id", type: .integer)]))
    }

    @Test("Decode an empty structure")
    func decodeEmptyStructure() throws {
        let json = """
        { "name": "Empty", "fields": [] }
        """
        let type = try JSONDecoder().decode(TypeDefinition.self, from: Data(json.utf8))
        #expect(type.shape == .structure([]))
    }

    @Test("Decode an enumeration")
    func decodeEnumeration() throws {
        let json = """
        { "name": "Status", "documentation": "Whether a pet is for sale.", "cases": ["available", "sold"] }
        """
        let type = try JSONDecoder().decode(TypeDefinition.self, from: Data(json.utf8))
        #expect(type.name == "Status")
        #expect(type.documentation == "Whether a pet is for sale.")
        #expect(type.shape == .enumeration(["available", "sold"]))
    }

    @Test("Neither fields nor cases throws")
    func neitherShape() {
        let json = """
        { "name": "Mystery" }
        """
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TypeDefinition.self, from: Data(json.utf8))
        }
    }

    @Test("Both fields and cases throws")
    func bothShapes() {
        let json = """
        { "name": "Mystery", "fields": [], "cases": [] }
        """
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TypeDefinition.self, from: Data(json.utf8))
        }
    }

    @Test("Encode a structure", .tags(.encoding))
    func encodeStructure() throws {
        let type = TypeDefinition(name: "Pet", shape: .structure([Field(name: "id", type: .integer)]))
        let object = try encode(type)
        #expect(object["name"] as? String == "Pet")
        #expect(object["documentation"] == nil)
        #expect(object["cases"] == nil)
        let fields = try #require(object["fields"] as? [[String: Any]])
        #expect(fields.count == 1)
        #expect(fields[0]["name"] as? String == "id")
    }

    @Test("Encode an enumeration", .tags(.encoding))
    func encodeEnumeration() throws {
        let type = TypeDefinition(name: "Status", documentation: "Docs", shape: .enumeration(["available"]))
        let object = try encode(type)
        #expect(object["name"] as? String == "Status")
        #expect(object["documentation"] as? String == "Docs")
        #expect(object["fields"] == nil)
        #expect(object["cases"] as? [String] == ["available"])
    }

    @Test("Round trip", .tags(.encoding))
    func roundTrip() throws {
        let types = [
            TypeDefinition(name: "Pet", documentation: "A pet.", shape: .structure([Field(name: "id", type: .integer)])),
            TypeDefinition(name: "Status", shape: .enumeration(["available", "sold"]))
        ]
        let data = try JSONEncoder().encode(types)
        #expect(try JSONDecoder().decode([TypeDefinition].self, from: data) == types)
    }

    private func encode(_ type: TypeDefinition) throws -> [String: Any] {
        let data = try JSONEncoder().encode(type)
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

}
