package xrrocha.xrecords.io

import java.io.File
import org.junit.Test

import static org.junit.Assert.*

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
