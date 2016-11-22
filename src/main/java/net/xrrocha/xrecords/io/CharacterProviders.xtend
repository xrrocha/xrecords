package net.xrrocha.xrecords.io

import java.io.File
import java.io.FileWriter
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.io.Reader
import java.io.StringReader
import java.io.StringWriter
import java.io.Writer
import java.net.URL
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors

class StringReaderProvider implements Provider<Reader> {
  @Accessors String content

  new() {
  }
  new(String content) { this.content = content }

  override provide() {
    new StringReader(content)
  }
}

class LocationReaderProvider implements Provider<Reader> {
  @Accessors String location

  new() {
  }
  new (String location) { this.location = location }

  override provide() {
    val provider = new LocationInputStreamProvider(location)
    new InputStreamReader(provider.provide)
  }
}

class StringWriterProvider implements Provider<Writer> {
  private var StringWriter stringWriter

  override provide() {
    stringWriter = new StringWriter
    stringWriter
  }

  override toString() {
    stringWriter.toString
  }
}

class FileLocationWriterProvider implements Provider<Writer> {
  @Accessors String location

  new() {
  }
  new (String location) { this.location = location }

  override provide() {
    new FileWriter(new File(location))
  }
}

class FtpWriterProvider extends FtpBase implements Provider<Writer> {
  override provide() {
    new OutputStreamWriter(new URL(location).openConnection.outputStream)
  }
}