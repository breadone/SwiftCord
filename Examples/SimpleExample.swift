//
//  SimpleExample.swift
//
//  This example bot replies "pong" when /ping is used
//
//  Created by Pradyun Setti on 13/07/22.
//

import Foundation
import SwiftCord

// replace these with your own values
let botToken: Int = 0
let appID: Int = 0
let intents: Int = 1 << 16

// initialise the bot
let bot = SCBot(token: botToken,
                appId: appID,
                intents: intents,
                options: SCOptions(displayCommandMessages: false))


// create the ping command
let ping = Command(name: "ping", description: "Play ping pong!") { _ in
    return "Pong!"
}

bot.addCommands(ping)

await bot.connect()
