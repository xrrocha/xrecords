package net.xrrocha.xrecords.io

import java.io.ByteArrayOutputStream
import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream
import java.net.URL
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors

class LocationInputStreamProvider implements Provider<InputStream> {
  @Accessors String location

  new() {
  }
  new (String location) { this.location = location }

  override provide() {
    IOUtils.uriFromLocation(location).toURL.openStream()
  }
}

class FtpOutputStreamProvider extends FtpBase implements Provider<OutputStream> {
  override provide() {
    new URL(location).openConnection.outputStream
  }
}

class FileLocationOutputStreamProvider implements Provider<OutputStream> {
  @Accessors String location

  new() {
  }
  new (String location) { this.location = location }

  override provide() {
    new FileOutputStream(location)
  }
}

class ByteArrayOutputStreamProvider implements Provider<OutputStream> {
  override provide() {
    new ByteArrayOutputStream
  }
}
