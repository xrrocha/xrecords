package xrrocha.xrecords.io

import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream
import xrrocha.xrecords.util.Provider

class LocationInputStreamProvider implements Provider<InputStream> {
    @Property String location
    
    override provide() {
        IOUtils.uriFromLocation(location).toURL.openStream()
    }
}

class FileLocationOutputStreamProvider implements Provider<OutputStream> {
    @Property String location
    
    override provide() {
        new FileOutputStream(location)
    }
}
