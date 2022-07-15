//
// Created by Pradyun Setti on 30/03/22.
//

import Foundation

public struct Embed {
    // TODO: make max length of title 256 and desc 4096
    public let title: String

    public let description: String?

    public let url: String?

    public let color: Int?

    public let image: Image?
    
    public var fields: [[String: String]]
    
    public init(title: String,
                text: String,
                url: String? = nil,
                colour: Int? = nil,
                image: Image? = nil,
                fields: [[String: String]] = []) {
        self.title = title
        self.description = text
        self.url = url
        self.color = colour
        self.image = image
        self.fields = fields
    }
    
    public mutating func addField(title: String, text: String) {
        self.fields.append(["name": title, "value": text])
    }
    
    public var arrayRepresentation: JSONObject {
        var content: JSONObject = ["title": self.title, "fields": self.fields]
        
        if let description = description {
            content["description"] = description
        }
        
        if let url = url {
            content["url"] = url
        }
        
        if let color = color {
            content["color"] = color
        }
        
        if let image = image {
            content["image"] = image
        }
        
        return content
    }
}

// Embed substructs
extension Embed {
    public struct Image {
        public let url: String

        public let proxyURL: String?

        public let width: Int

        public let height: Int
    }
}