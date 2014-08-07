package xrrocha.xrecords.io

import org.junit.Test

import static org.junit.Assert.*

class FtpBaseTest {
    @Test
    def void buildsLocationOnDemand() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 2221
            user = 'someUser'
            password = 'somePassword'
            path = 'somePath'
        ]
        assertNotNull(ftpBase.getLocation)
    }

    @Test
    def buildsCompleteFtpUri() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 2221
            user = 'someUser'
            password = 'somePassword'
            path = 'somePath'
        ]
        val expectedUrl = 'ftp://someUser:somePassword@someHost:2221/somePath'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
    
    @Test
    def buildsFtpUrlWithoutCredentials() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 2221
            user = null
            password = null
            path = 'somePath'
        ]
        val expectedUrl = 'ftp://someHost:2221/somePath'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
    
    @Test
    def buildsFtpUrlWithUserOnly() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 2221
            user = 'someUser'
            password = null
            path = 'somePath'
        ]
        val expectedUrl = 'ftp://someUser@someHost:2221/somePath'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
    
    @Test
    def buildsFtpUrlWithBothUserAndPassword() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 2221
            user = 'someUser'
            password = 'somePassword'
            path = 'somePath'
        ]
        val expectedUrl = 'ftp://someUser:somePassword@someHost:2221/somePath'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
    
    @Test
    def buildsFtpUrlForDefaultPort() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 21
            user = 'someUser'
            password = 'somePassword'
            path = 'somePath'
        ]
        val expectedUrl = 'ftp://someUser:somePassword@someHost/somePath'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
    
    @Test
    def buildsFtpUrlForNonDefaultPort() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 1234
            user = 'someUser'
            password = 'somePassword'
            path = 'somePath'
        ]
        val expectedUrl = 'ftp://someUser:somePassword@someHost:1234/somePath'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
    
    @Test
    def buildsFtpUrlForNonAbsolutePath() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 1234
            user = 'someUser'
            password = 'somePassword'
            path = 'somePath'
        ]
        val expectedUrl = 'ftp://someUser:somePassword@someHost:1234/somePath'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
    
    @Test
    def buildsFtpUrlForAbsolutePath() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 1234
            user = 'someUser'
            password = 'somePassword'
            path = '/somePath'
        ]
        val expectedUrl = 'ftp://someUser:somePassword@someHost:1234/somePath'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
    
    @Test
    def buildsFtpUrlBinaryMode() {
        val ftpBase = new FtpBase {} => [
            host = 'someHost'
            port = 1234
            user = 'someUser'
            password = 'somePassword'
            path = '/somePath'
            binary = true
        ]
        val expectedUrl = 'ftp://someUser:somePassword@someHost:1234/somePath;type=i'
        assertEquals(expectedUrl, ftpBase.buildFtpUri)        
    }
}