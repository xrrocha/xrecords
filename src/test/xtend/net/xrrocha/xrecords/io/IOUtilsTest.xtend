package net.xrrocha.xrecords.io

import java.io.File
import org.junit.Test
import static org.junit.Assert.*
import java.net.URI

class IOUtilsTest {
    @Test
    def buildsFileURIForMissingProtocol() {
        val location = 'file.txt'
        val file = new File(location)
        val uri = IOUtils.uriFromLocation(location)
        assertEquals(file.toURI, uri)
    }

    @Test
    def buildsProperURIForProtocol() {
        val location = 'http://localhost/index.html'
        val index = new URI(location)
        val uri = IOUtils.uriFromLocation(location)
        assertEquals(index, uri)
    }
}
