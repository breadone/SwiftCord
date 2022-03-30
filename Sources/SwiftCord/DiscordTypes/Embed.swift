//
// Created by Pradyun Setti on 30/03/22.
//

import Foundation

public struct Embed {
    public let title: String

    public let description: String

    public let url: String

    public let color: Int

    public let image: Image
}

// Embed substructs
extension Embed {
    public struct Image {
        public let url: String

        public let proxyURL: String?

        public let width: Int

        public let height: Int
    }

    public struct Video {

    }
}