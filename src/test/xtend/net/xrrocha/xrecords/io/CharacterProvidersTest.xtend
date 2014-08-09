package net.xrrocha.xrecords.io

import org.junit.Test
import static org.junit.Assert.*

class StringReaderProviderTest {
    @Test
    def void providesContext() {
        val testContent = 'someContext'
        val provider = new StringReaderProvider => [
            content = testContent
        ]
        val char[] buffer = newCharArrayOfSize(testContent.length + 1)
        val length = provider.provide.read(buffer)
        assertEquals(testContent, new String(buffer, 0, length))
    }
}
