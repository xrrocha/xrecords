package xrrocha.xrecords.io

import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream
import java.net.URL
import xrrocha.xrecords.util.Provider

class LocationInputStreamProvider implements Provider<InputStream> {
    @Property String location
    
    override provide() {
        IOUtils.uriFromLocation(location).toURL.openStream()
    }
}

class FtpOutputStreamProvider implements Provider<OutputStream> {
    @Property String host
    @Property int port = 21
    @Property String user = 'anonymous'
    @Property String password = 'someone@somewhere.net'
    @Property String path
    
    private String location
    
    override provide() {
        if (location == null) {
            location = buildFtpUri(host, port, user, password, path)
        }    
        // TODO binary mode?
        new URL(location).openConnection.outputStream
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

class FileLocationOutputStreamProvider implements Provider<OutputStream> {
    @Property String location
    
    override provide() {
        new FileOutputStream(location)
    }
}
