// Manuscript
// FieldTests.swift
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

@Suite("Field Tests", .tags(.parsing))
struct FieldTests {

    @Test("Optional defaults to false")
    func optionalDefault() throws {
        let json = """
        { "name": "id", "type": "integer" }
        """
        let field = try JSONDecoder().decode(Field.self, from: Data(json.utf8))
        #expect(field == Field(name: "id", type: .integer))
        #expect(!field.isOptional)
    }

    @Test("Optional can be set")
    func optionalExplicit() throws {
        let json = """
        { "name": "status", "type": "Status", "optional": true }
        """
        let field = try JSONDecoder().decode(Field.self, from: Data(json.utf8))
        #expect(field == Field(name: "status", type: .reference("Status"), isOptional: true))
    }

    @Test("Missing type throws")
    func missingType() {
        let json = """
        { "name": "id" }
        """
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Field.self, from: Data(json.utf8))
        }
    }

    @Test("Encoding omits optional when false", .tags(.encoding))
    func encodeRequired() throws {
        let data = try JSONEncoder().encode(Field(name: "id", type: .integer))
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["name"] as? String == "id")
        #expect(object["type"] as? String == "integer")
        #expect(object["optional"] == nil)
    }

    @Test("Encoding includes optional when true", .tags(.encoding))
    func encodeOptional() throws {
        let data = try JSONEncoder().encode(Field(name: "status", type: .reference("Status"), isOptional: true))
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["optional"] as? Bool == true)
    }

    @Test("Round trip", .tags(.encoding))
    func roundTrip() throws {
        let fields = [
            Field(name: "id", type: .integer),
            Field(name: "tags", type: .array(.string), isOptional: true)
        ]
        let data = try JSONEncoder().encode(fields)
        #expect(try JSONDecoder().decode([Field].self, from: data) == fields)
    }

}
