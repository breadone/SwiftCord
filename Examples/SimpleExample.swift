//
//  File.swift
//  
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
                options: SCOptions(displayCommandMessages: false)
                )


// setup the options for the pingUser command
let pingUser_option = CommandOption(.string,
                                     name: "user",
                                     description: "Which user to ping",
                                     choices: (name: "breadone", value: "<@123456>"), (name: "breauxmoment", value: "<@7891011>"))

// create the pingUser command
let pingUser = Command(name: "pingthem", description: "Ping the selected user", options: [pingUser_option]) { info in
    return info.options[0].value // this returns the value of the option, ie the user's tag (<@123456> or <@7891011>)
}

bot.addCommands(pingUser)

await bot.connect()
