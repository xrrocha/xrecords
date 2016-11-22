package net.xrrocha.xrecords.io

import com.sun.net.httpserver.HttpExchange
import com.sun.net.httpserver.HttpHandler
import com.sun.net.httpserver.HttpServer
import java.io.File
import java.io.FileOutputStream
import java.net.InetAddress
import java.net.InetSocketAddress
import org.junit.Test

import static org.junit.Assert.*

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
