package xrrocha.xrecords.io

abstract class FtpBase {
    @Property String host
    @Property int port = 21
    @Property String user = 'anonymous'
    @Property String password = 'someone@somewhere.net'
    @Property String path
    
    private var String location
    
    protected def getLocation() {
        if (location == null) {
            location = buildFtpUri(host, port, user, password, path)
        }
        location    
    }
    
    static def String buildFtpUri(String host, int port, String user, String password, String path) {
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
        '''ftp://«credentialsFragment»«host»«portFragment»«pathFragment»'''
    }
}