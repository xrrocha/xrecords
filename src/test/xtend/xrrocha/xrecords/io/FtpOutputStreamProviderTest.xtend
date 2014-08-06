package xrrocha.xrecords.io

import java.io.File
import java.io.FileInputStream
import java.util.ArrayList
import java.util.Date
import org.apache.ftpserver.FtpServer
import org.apache.ftpserver.FtpServerFactory
import org.apache.ftpserver.ftplet.Authority
import org.apache.ftpserver.listener.ListenerFactory
import org.apache.ftpserver.usermanager.ClearTextPasswordEncryptor
import org.apache.ftpserver.usermanager.PropertiesUserManagerFactory
import org.apache.ftpserver.usermanager.impl.BaseUser
import org.apache.ftpserver.usermanager.impl.WritePermission
import org.junit.Test

import static org.junit.Assert.*

class FtpOutputStreamProviderTest {
    static val int serverPort = 4269
    static var FtpServer server
    
    static val userName = 'theUser'
    static val userPassword = 'thePassword'

    static val tempDirectory = new File(System.getProperty('java.io.tmpdir'))
    
    static val userDirectory = {
        val directory = new File(tempDirectory, '''usr_«System.currentTimeMillis»''')
        assertTrue(directory.mkdir())
        directory
    }
    
    @Test
    def buildsCompleteFtpUri() {
        val host = 'someHost'
        val port = 2221
        val  user = 'someUser'
        val password = 'somePassword'
        val path = 'somePath'
        val expectedUrl = 'ftp://someUser:somePassword@someHost:2221/somePath'
        assertEquals(expectedUrl, FtpOutputStreamProvider.buildFtpUri(host, port, user, password, path))        
    }
    
    @Test
    def buildsFtpUrlWithoutCredentials() {
        val host = 'someHost'
        val port = 2221
        val String user = null
        val String password = null
        val path = 'somePath'
        val expectedUrl = 'ftp://someHost:2221/somePath'
        assertEquals(expectedUrl, FtpOutputStreamProvider.buildFtpUri(host, port, user, password, path))        
    }
    
    @Test
    def buildsFtpUrlWithUserOnly() {
        val host = 'someHost'
        val port = 2221
        val String user = 'someUser'
        val String password = null
        val path = 'somePath'
        val expectedUrl = 'ftp://someUser@someHost:2221/somePath'
        assertEquals(expectedUrl, FtpOutputStreamProvider.buildFtpUri(host, port, user, password, path))        
    }
    
    @Test
    def buildsFtpUrlWithBothUserAndPassword() {
        val host = 'someHost'
        val port = 2221
        val String user = 'someUser'
        val String password = 'somePassword'
        val path = 'somePath'
        val expectedUrl = 'ftp://someUser:somePassword@someHost:2221/somePath'
        assertEquals(expectedUrl, FtpOutputStreamProvider.buildFtpUri(host, port, user, password, path))        
    }
    
    @Test
    def buildsFtpUrlForDefaultPort() {
        val host = 'someHost'
        val port = 21
        val String user = 'someUser'
        val String password = 'somePassword'
        val path = 'somePath'
        val expectedUrl = 'ftp://someUser:somePassword@someHost/somePath'
        assertEquals(expectedUrl, FtpOutputStreamProvider.buildFtpUri(host, port, user, password, path))        
    }
    
    @Test
    def buildsFtpUrlForNonDefaultPort() {
        val host = 'someHost'
        val port = 1234
        val String user = 'someUser'
        val String password = 'somePassword'
        val path = 'somePath'
        val expectedUrl = 'ftp://someUser:somePassword@someHost:1234/somePath'
        assertEquals(expectedUrl, FtpOutputStreamProvider.buildFtpUri(host, port, user, password, path))        
    }
    
    @Test
    def buildsFtpUrlForNonAbsolutePath() {
        val host = 'someHost'
        val port = 1234
        val String user = 'someUser'
        val String password = 'somePassword'
        val path = 'somePath'
        val expectedUrl = 'ftp://someUser:somePassword@someHost:1234/somePath'
        assertEquals(expectedUrl, FtpOutputStreamProvider.buildFtpUri(host, port, user, password, path))        
    }
    
    @Test
    def buildsFtpUrlForAbsolutePath() {
        val host = 'someHost'
        val port = 1234
        val String user = 'someUser'
        val String password = 'somePassword'
        val path = '/somePath'
        val expectedUrl = 'ftp://someUser:somePassword@someHost:1234/somePath'
        assertEquals(expectedUrl, FtpOutputStreamProvider.buildFtpUri(host, port, user, password, path))        
    }

    @Test
    def putsRemoteFile() {
        startServer()
        
        val filePath = '/file.txt'
        val file = new File(userDirectory, filePath)
        file.delete()
        file.deleteOnExit()
        assertFalse(file.exists())
        
        try {
            val provider = new FtpOutputStreamProvider => [
                host = 'localhost'
                port = serverPort
                user = userName
                password = userPassword
                path = filePath
            ]
            
            val content = '''The current time is «new Date»'''
            val bytes = content.bytes
            
            val outputStream = provider.provide
            outputStream.write(bytes)
            outputStream.flush()
            outputStream.close()
            
            assertTrue(file.exists)
            assertEquals(bytes.length, file.length)

            val buffer = newByteArrayOfSize(bytes.length + 1)
            val inputStream = new FileInputStream(file)
            assertEquals(bytes.length, inputStream.read(buffer))
            inputStream.close()
            assertEquals(content, new String(buffer, 0, bytes.length))
        } finally {
            file.delete()
            stopServer()
        }
    }
    
    static def startServer() {
        val userPropertyFile = File.createTempFile('users', '.properties')
        userPropertyFile.deleteOnExit()
        
        val userManagerFactory = new PropertiesUserManagerFactory()
        userManagerFactory.file = userPropertyFile
        userManagerFactory.passwordEncryptor = new ClearTextPasswordEncryptor()
        val authorities = new ArrayList<Authority>()
        authorities.add(new WritePermission())
        val userManager = userManagerFactory.createUserManager()

        val user = new BaseUser => [
            name = userName
            password = userPassword
            homeDirectory = userDirectory.absolutePath
        ]
        user.authorities = authorities
        userManager.save(user)
        
        val serverFactory = new FtpServerFactory()
        val listenerFactory = new ListenerFactory
        listenerFactory.port = serverPort
        serverFactory.addListener('default', listenerFactory.createListener)
        serverFactory.userManager = userManager
        server = serverFactory.createServer()
        server.start()
    }
    
    static def stopServer() {
        userDirectory.delete()
        server.stop()
    }
}