// Manuscript
// FieldTypeTests.swift
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

@Suite("Field Type Tests", .tags(.parsing))
struct FieldTypeTests {

    @Test(
        "Decode primitives",
        arguments: [
            ("\"string\"", FieldType.string),
            ("\"integer\"", FieldType.integer),
            ("\"double\"", FieldType.double),
            ("\"boolean\"", FieldType.boolean)
        ]
    )
    func decodePrimitive(json: String, expected: FieldType) throws {
        #expect(try decode(json) == expected)
    }

    @Test("Decode a reference")
    func decodeReference() throws {
        #expect(try decode("\"Pet\"") == .reference("Pet"))
    }

    @Test("Decode an array")
    func decodeArray() throws {
        #expect(try decode("{ \"array\": \"string\" }") == .array(.string))
    }

    @Test("Decode a nested array")
    func decodeNestedArray() throws {
        #expect(try decode("{ \"array\": { \"array\": \"Pet\" } }") == .array(.array(.reference("Pet"))))
    }

    @Test("Empty reference throws")
    func emptyReference() {
        #expect(throws: DecodingError.self) {
            try decode("\"\"")
        }
    }

    @Test("Object without array key throws")
    func objectWithoutArray() {
        #expect(throws: DecodingError.self) {
            try decode("{ \"list\": \"string\" }")
        }
    }

    @Test("Non-string throws")
    func nonString() {
        #expect(throws: DecodingError.self) {
            try decode("42")
        }
    }

    @Test(
        "Encode",
        .tags(.encoding),
        arguments: [
            (FieldType.string, "\"string\""),
            (FieldType.integer, "\"integer\""),
            (FieldType.double, "\"double\""),
            (FieldType.boolean, "\"boolean\""),
            (FieldType.reference("Pet"), "\"Pet\""),
            (FieldType.array(.integer), "{\"array\":\"integer\"}"),
            (FieldType.array(.array(.reference("Pet"))), "{\"array\":{\"array\":\"Pet\"}}")
        ]
    )
    func encode(type: FieldType, expected: String) throws {
        let data = try JSONEncoder().encode(type)
        #expect(String(decoding: data, as: UTF8.self) == expected)
    }

    private func decode(_ json: String) throws -> FieldType {
        try JSONDecoder().decode(FieldType.self, from: Data(json.utf8))
    }

}
