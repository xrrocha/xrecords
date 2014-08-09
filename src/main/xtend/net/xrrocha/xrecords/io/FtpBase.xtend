package net.xrrocha.xrecords.io

abstract class FtpBase {
    @Property String host
    @Property int port = 21
    @Property String user = 'anonymous'
    @Property String password = 'someone@somewhere.net'
    @Property String path
    @Property boolean binary = false
    
    private var String location
    
    def getLocation() {
        if (location == null) {
            location = buildFtpUri
        }
        location    
    }

    def String buildFtpUri() {
        val credentialsFragment = {
            if (user == null) ''
            else if (password == null) '''«user»@'''
            else '''«user»:«password»@'''
        }
        
        val portFragment = {
            if (port == 21) ''
            else ''':«port»'''
        }
        
        val pathFragment = {
            if (path.startsWith('/')) path
            else '''/«path»'''
        }
        
        val binaryFragment =
            if (binary) ";type=i"
            else ""
            
        '''ftp://«credentialsFragment»«host»«portFragment»«pathFragment»«binaryFragment»'''
    }
}