package xrrocha.xrecords.io

import java.io.File
import java.io.FileOutputStream
import org.junit.Test

import static org.junit.Assert.*

class LocationInputStreamProviderTest {
   @Test
   def void createsFileInputStream() {
        val file = File.createTempFile("xyz", ".tmp")
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
}

class FileLocationOutputStreamProviderTest {
    @Test
    def void createsFileOutputStream() {
        val file = File.createTempFile("xyz", ".tmp")
        file.deleteOnExit()
        
        val provider = new FileLocationOutputStreamProvider => [
            location = file.absolutePath
        ]
        
        val outputStream = provider.provide
        
        val content = 'Hey there!'
        val bytes = content.bytes
        outputStream.write(bytes)
        outputStream.close()
        
        assertEquals(bytes.length, file.length)
    }    
}