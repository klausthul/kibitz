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
        
        if let serverName = coder.decodeObject(forKey: "serverName") as? String {
            self.serverName = serverName
        }
        if let serverAddress = coder.decodeObject(forKey: "serverAddress") as? String {
            self.serverAddress = serverAddress
        }
        if let serverPort = coder.decodeObject(forKey: "serverPort") as? Int {
            self.serverPort = serverPort
        }
        if let userName = coder.decodeObject(forKey: "userName") as? String {
            self.userName = userName
        }
        if let userPassword = coder.decodeObject(forKey: "userPassword") as? String {
            self.userPassword = userPassword
        }
        if let initCommands = coder.decodeObject(forKey: "initCommands") as? String {
            self.initCommands = initCommands
        }
        self.useTimeseal = coder.decodeBool(forKey: "useTimeseal")
        self.connectAtStartup = coder.decodeBool(forKey: "connectAtStartup")
        self.issueSeek = coder.decodeBool(forKey: "issueSeek")
        if let seek = coder.decodeObject(forKey: "seek") as? Seek {
            self.seek = seek
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.serverName, forKey: "serverName")
        aCoder.encode(self.serverAddress, forKey: "serverAddress")
        aCoder.encode(self.serverPort, forKey: "serverPort")
        aCoder.encode(self.userName, forKey: "userName")
        aCoder.encode(self.userPassword, forKey: "userPassword")
        aCoder.encode(self.initCommands, forKey: "initCommands")
        aCoder.encode(self.useTimeseal, forKey: "useTimeseal")
        aCoder.encode(self.connectAtStartup, forKey: "connectAtStartup")
        aCoder.encode(self.issueSeek, forKey: "issueSeek")
        aCoder.encode(self.seek, forKey: "seek")
    }
}
