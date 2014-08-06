package xrrocha.xrecords.io

import java.io.File
import java.net.URI

class IOUtils {
    static def uriFromLocation(String location) {
        if (location.contains(":/")) {
            new URI(location)
        } else {
            new File(location).toURI
        }
    }
}