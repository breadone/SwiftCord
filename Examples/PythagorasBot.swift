//
//  PythagorasBot.swift
//
//  This bot calculates the hypotenuse of a right-angle triangle
//
//  Created by Pradyun Setti on 15/07/22.
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


// setup the options for the x and y side of the triangle
let optX = CommandOption(.number, name: "x", description: "the x side of the triangle")
let optY = CommandOption(.number, name: "y", description: "the y side of the triangle")

// make the command itself
let pythag = Command(name: "pythagoras", // this is the name users see on discord, must be all lowercase
                     description: "Calculate the hypotenuse of a right-angle triangle", // a short description of the command
                     options: [optX, optY]) { info in
    
    let x = Double(info.getOptionValue(for: "x")!) ?? 0 // since we know there are x and y parameters, FA is safe
    let y = Double(info.getOptionValue(for: "y")!) ?? 0
    
    return Embed(title: "ANSWER", text: "\(hypot(x, y))") // return the answer in a nice embed
}

bot.addCommands(pythag)

await bot.connect()
