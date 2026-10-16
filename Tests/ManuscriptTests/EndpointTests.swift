// Manuscript
// EndpointTests.swift
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

@Suite("Endpoint Tests", .tags(.parsing))
struct EndpointTests {

    @Test("Decode with request and response")
    func decodeFull() throws {
        let json = """
        { "name": "createPet", "method": "post", "path": "/pets", "request": "Pet", "response": "Pet" }
        """
        let endpoint = try JSONDecoder().decode(Endpoint.self, from: Data(json.utf8))
        #expect(endpoint == Endpoint(name: "createPet", method: .post, path: "/pets", request: "Pet", response: "Pet"))
    }

    @Test("Request and response default to nil")
    func decodeMinimal() throws {
        let json = """
        { "name": "deletePet", "method": "delete", "path": "/pets/{id}" }
        """
        let endpoint = try JSONDecoder().decode(Endpoint.self, from: Data(json.utf8))
        #expect(endpoint.request == nil)
        #expect(endpoint.response == nil)
    }

    @Test(
        "Decode every method",
        arguments: [
            ("get", HTTPMethod.get),
            ("post", HTTPMethod.post),
            ("put", HTTPMethod.put),
            ("patch", HTTPMethod.patch),
            ("delete", HTTPMethod.delete)
        ]
    )
    func decodeMethod(raw: String, expected: HTTPMethod) throws {
        let json = """
        { "name": "op", "method": "\(raw)", "path": "/" }
        """
        let endpoint = try JSONDecoder().decode(Endpoint.self, from: Data(json.utf8))
        #expect(endpoint.method == expected)
    }

    @Test("Unknown method throws")
    func unknownMethod() {
        let json = """
        { "name": "op", "method": "GET", "path": "/" }
        """
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Endpoint.self, from: Data(json.utf8))
        }
    }

    @Test(
        "Path parameters",
        arguments: [
            ("/pets", [String]()),
            ("/pets/{id}", ["id"]),
            ("/users/{userID}/posts/{postID}", ["userID", "postID"]),
            ("/pets/{id}.json", []),
            ("{id}", ["id"]),
            ("/", [])
        ]
    )
    func pathParameters(path: String, expected: [String]) {
        let endpoint = Endpoint(name: "op", method: .get, path: path)
        #expect(endpoint.pathParameters == expected)
    }

    @Test("Round trip", .tags(.encoding))
    func roundTrip() throws {
        let endpoints = [
            Endpoint(name: "listPets", method: .get, path: "/pets", response: "Pet"),
            Endpoint(name: "createPet", method: .post, path: "/pets", request: "Pet", response: "Pet")
        ]
        let data = try JSONEncoder().encode(endpoints)
        #expect(try JSONDecoder().decode([Endpoint].self, from: data) == endpoints)
    }

}
