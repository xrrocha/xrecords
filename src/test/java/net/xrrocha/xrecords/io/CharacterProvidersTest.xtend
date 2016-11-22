package net.xrrocha.xrecords.io

import java.io.File
import org.junit.Test

import static org.junit.Assert.*

class StringReaderProviderTest {
  @Test
  def void providesStringReader() {
    val testContent = 'someContext'
    val provider = new StringReaderProvider => [
      content = testContent
    ]
    val char[] buffer = newCharArrayOfSize(testContent.length + 1)
    val length = provider.provide.read(buffer)
    assertEquals(testContent, new String(buffer, 0, length))
  }

  @Test
  def void providesLocationReader() {
    val file = File.createTempFile("temp", ".tmp")
    file.deleteOnExit()

    val provider = new LocationInputStreamProvider => [
      location = file.toURI.toString
    ]
    assertNotNull(provider.provide)
  }

  @Test
  def void providesReaderLocationReader() {
    val file = File.createTempFile("temp", ".tmp")
    file.deleteOnExit()

    val provider = new LocationReaderProvider => [
      location = file.toURI.toString
    ]
    assertNotNull(provider.provide)
  }

  @Test
  def void providesStringWriter() {
    val provider = new StringWriterProvider
    val writer = provider.provide
    writer.write('Odi et amo'.toCharArray)
    assertEquals('Odi et amo', writer.toString)
  }

  @Test
  def void providesFileLocation() {
    val file = File.createTempFile("temp", ".tmp")
    file.deleteOnExit()

    val provider = new FileLocationWriterProvider => [
      location = file.absolutePath
    ]
    val writer = provider.provide
    assertNotNull(writer)
  }
}
