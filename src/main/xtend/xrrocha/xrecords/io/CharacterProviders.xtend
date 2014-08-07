package xrrocha.xrecords.io

import java.io.File
import java.io.FileWriter
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.io.Reader
import java.io.StringReader
import java.io.StringWriter
import java.io.Writer
import java.net.URL
import xrrocha.xrecords.util.Provider

class StringReaderProvider implements Provider<Reader> {
    @Property String content
    
    override provide() {
        new StringReader(content)
    }
}

class LocationReaderProvider implements Provider<Reader> {
    @Property String location
    
    override provide() {
        val provider = new LocationInputStreamProvider => [
            location = LocationReaderProvider.this.location
        ]
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
    @Property String location
    
    override provide() {
        new FileWriter(new File(location))
    }
}

class FtpWriterProvider extends FtpBase implements Provider<Writer> {
    override provide() {
        new OutputStreamWriter(new URL(location).openConnection.outputStream)
    }
}