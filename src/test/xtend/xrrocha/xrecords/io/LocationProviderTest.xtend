package xrrocha.xrecords.io

import com.sun.net.httpserver.HttpExchange
import com.sun.net.httpserver.HttpHandler
import com.sun.net.httpserver.HttpServer
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.InetAddress
import java.net.InetSocketAddress
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
import static xrrocha.xrecords.io.LocationInputStreamProviderTest.*

class LocationInputStreamProviderTest {
   @Test
   def void createsFileInputStream() {
        val file = File.createTempFile('xyz', '.tmp')
        file.deleteOnExit()
        val outputStream = new FileOutputStream(file)
        val content = 'Hey there!'
        val bytes = content.bytes
        outputStream.write(bytes)
        outputStream.close()
        
        val provider = new LocationInputStreamProvider => [
            location = file.absolutePath
        ]
        
        val buffer = newByteArrayOfSize(bytes.length + 1)
        val inputStream = provider.provide()
        assertEquals(bytes.length, inputStream.read(buffer))
        inputStream.close()
        assertEquals(content, new String(buffer, 0, bytes.length))
   } 
   
   @Test
   def void createsHttpInputStream() {
       startServer()
       
       try {
           val path = '/path/to/nowhere/index.html'
           val bytes = path.bytes
           
           val httpLocation = '''http://localhost:«serverPort»«path»'''
           val provider = new LocationInputStreamProvider => [
                location = httpLocation
           ]
        
            val buffer = newByteArrayOfSize(bytes.length + 1)
            val inputStream = provider.provide()
            assertEquals(bytes.length, inputStream.read(buffer))
            inputStream.close()
            assertEquals(path.toUpperCase, new String(buffer, 0, bytes.length))
       } finally {
           stopServer()
       }
   }
   
   static val serverPort = 4269
   static var HttpServer server

   static def startServer() {
        server = HttpServer.create(new InetSocketAddress(InetAddress.getLoopbackAddress(), serverPort), 0)
        server.createContext('/', new HttpHandler {
            override handle(HttpExchange exchange) {
                val response = exchange.requestURI.path.toUpperCase
                val bytes = response.bytes
                val length = bytes.length
                exchange.sendResponseHeaders(200, length)
                exchange.responseBody.write(bytes)
            }
        })  
        server.executor = null     
        server.start()
   }
   
   static def stopServer() {
       server.stop(0)
   }
}

class FileLocationOutputStreamProviderTest {
    @Test
    def void createsFileOutputStream() {
        val file = File.createTempFile('xyz', '.tmp')
        file.deleteOnExit()
        
        val provider = new FileLocationOutputStreamProvider => [
            location = file.absolutePath
        ]
        
        val outputStream = provider.provide
        
        val content = 'Hey there!'
        val bytes = content.bytes
        outputStream.write(bytes)
        outputStream.flush()
        outputStream.close()
        
        assertEquals(bytes.length, file.length)
    }    
}

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
    
    // TODO Test buildsProperFtpUri: credentials, port, path
    @Test
    def buildsProperFtpUri() {
        val host = 'someHost'
        val port = 2221
        val  user = 'someUser'
        val password = 'somePassword'
        val path = 'somePath'
        val expectedUrl = 'ftp://someUser:somePassword@someHost:2221/somePath'
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