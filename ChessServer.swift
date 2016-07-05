//
//  ChessServer.swift
//  Kibitz
//
//  Copyright 2014 William Entriken, licensed under the MIT license:
//  http://opensource.org/licenses/MIT
//
//  Based on Kibitz / ChessServer 2006 Klaus Thul
//

@objc(ChessServer) // http://stackoverflow.com/a/24329118/300224
class ChessServer: NSObject, NSCoding {
    var serverName: String = "Free Internet Chess Server (FICS)"
    var serverAddress: String = "freechess.org"
    var serverPort: Int = 53 // another popular option is 5000
    var userName: String = "guest"
    var userPassword: String = "guest"
    var initCommands: String = " "
    var useTimeseal: Bool = false
    var connectAtStartup: Bool = false
    var issueSeek: Bool = false
    var seek: Seek = Seek()
    
    override var description: String {
        return self.serverName
    }
    
    override required init() {
        super.init()
    }

    required convenience init(coder: NSCoder) {
        self.init()
        
        if let serverName = coder.decodeObjectForKey("serverName") as? String {
            self.serverName = serverName
        }
        if let serverAddress = coder.decodeObjectForKey("serverAddress") as? String {
            self.serverAddress = serverAddress
        }
        if let serverPort = coder.decodeObjectForKey("serverPort") as? Int {
            self.serverPort = serverPort
        }
        if let userName = coder.decodeObjectForKey("userName") as? String {
            self.userName = userName
        }
        if let userPassword = coder.decodeObjectForKey("userPassword") as? String {
            self.userPassword = userPassword
        }
        if let initCommands = coder.decodeObjectForKey("initCommands") as? String {
            self.initCommands = initCommands
        }
        self.useTimeseal = coder.decodeBoolForKey("useTimeseal")
        self.connectAtStartup = coder.decodeBoolForKey("connectAtStartup")
        self.issueSeek = coder.decodeBoolForKey("issueSeek")
        if let seek = coder.decodeObjectForKey("seek") as? Seek {
            self.seek = seek
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.serverName, forKey: "serverName")
        aCoder.encodeObject(self.serverAddress, forKey: "serverAddress")
        aCoder.encodeObject(self.serverPort, forKey: "serverPort")
        aCoder.encodeObject(self.userName, forKey: "userName")
        aCoder.encodeObject(self.userPassword, forKey: "userPassword")
        aCoder.encodeObject(self.initCommands, forKey: "initCommands")
        aCoder.encodeBool(self.useTimeseal, forKey: "useTimeseal")
        aCoder.encodeBool(self.connectAtStartup, forKey: "connectAtStartup")
        aCoder.encodeBool(self.issueSeek, forKey: "issueSeek")
        aCoder.encodeObject(self.seek, forKey: "seek")
    }
}