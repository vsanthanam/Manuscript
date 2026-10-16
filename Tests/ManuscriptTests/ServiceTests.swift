// Manuscript
// ServiceTests.swift
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

@Suite("Service Tests", .tags(.parsing))
struct ServiceTests {

    @Test("Decode from a file")
    func decodeFromFile() throws {
        let url = try #require(Bundle.module.url(forResource: "petstore", withExtension: "json", subdirectory: "Resources"))
        let service = try Service(contentsOf: url)
        #expect(service.name == "Petstore")
        #expect(service.types.map(\.name) == ["Status", "Pet"])
        #expect(service.endpoints.map(\.name) == ["listPets", "getPet", "createPet"])
    }

    @Test("Decode from data")
    func decodeFromData() throws {
        let json = """
        { "name": "Empty", "types": [], "endpoints": [] }
        """
        let service = try Service(data: Data(json.utf8))
        #expect(service == Service(name: "Empty"))
    }

    @Test("Decode the petstore example")
    func decodePetstore() throws {
        let url = try #require(Bundle.module.url(forResource: "petstore", withExtension: "json", subdirectory: "Resources"))
        let service = try Service(contentsOf: url)
        let expected = Service(
            name: "Petstore",
            types: [
                TypeDefinition(name: "Status", shape: .enumeration(["available", "sold"])),
                TypeDefinition(
                    name: "Pet",
                    documentation: "A pet in the store.",
                    shape: .structure([
                        Field(name: "id", type: .integer),
                        Field(name: "name", type: .string),
                        Field(name: "status", type: .reference("Status"), isOptional: true),
                        Field(name: "tags", type: .array(.string))
                    ])
                )
            ],
            endpoints: [
                Endpoint(name: "listPets", method: .get, path: "/pets", response: "Pet"),
                Endpoint(name: "getPet", method: .get, path: "/pets/{id}", response: "Pet"),
                Endpoint(name: "createPet", method: .post, path: "/pets", request: "Pet", response: "Pet")
            ]
        )
        #expect(service == expected)
    }

    @Test("Missing file throws")
    func missingFile() {
        let url = URL(fileURLWithPath: "/nonexistent/manuscript.json")
        #expect(throws: (any Error).self) {
            try Service(contentsOf: url)
        }
    }

    @Test("Missing name throws")
    func missingName() {
        let json = """
        { "types": [], "endpoints": [] }
        """
        #expect(throws: DecodingError.self) {
            try Service(data: Data(json.utf8))
        }
    }

    @Test("Look up a type by name")
    func typeNamed() {
        let status = TypeDefinition(name: "Status", shape: .enumeration(["available"]))
        let service = Service(name: "Petstore", types: [status])
        #expect(service.type(named: "Status") == status)
        #expect(service.type(named: "Pet") == nil)
    }

    @Test("Look up an endpoint by name")
    func endpointNamed() {
        let listPets = Endpoint(name: "listPets", method: .get, path: "/pets")
        let service = Service(name: "Petstore", endpoints: [listPets])
        #expect(service.endpoint(named: "listPets") == listPets)
        #expect(service.endpoint(named: "getPet") == nil)
    }

    @Test("Round trip", .tags(.encoding))
    func roundTrip() throws {
        let url = try #require(Bundle.module.url(forResource: "petstore", withExtension: "json", subdirectory: "Resources"))
        let service = try Service(contentsOf: url)
        let encoded = try JSONEncoder().encode(service)
        #expect(try Service(data: encoded) == service)
    }

}
