# SwiftCord: Modern Discord API Wrapper, in Swift 5

 SwiftCord provides a super easy way of managing Discord's notoriously difficult slash commands, and uses the following modern Swift features:
- async/await
- Hashable, Codable, Custom protocols
- WebSockets (Starscream)


## Installation
1. Create a Swift Executable package:
```bash
$ mkdir myBot
$ cd myBot
$ swift package init --type executable  
```

2. Add `https://github.com/breadone/SwiftCord` to your `Package.swift`:
```
dependencies: [
    .package(url: "https://github.com/breadone/SwiftCord.git", branch: "main")
],
targets: [
    .target(
            name: "myBot",
            dependencies: ["SwiftCord"])
] 

```

3. Start using your bot!
```swift
import SwiftCord

let bot = SCBot(token: <your token>, appId: <your app id>, intents: <your intents>)

let ping = Command(name: "ping", description: "Play ping pong!", type: .slashCommand) { _ in
    return "Pong!"
}

bot.addCommands(ping)

bot.connect()
```


