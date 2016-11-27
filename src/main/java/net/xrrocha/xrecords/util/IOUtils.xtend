package net.xrrocha.xrecords.util

import java.io.File
import java.net.URI

/**
 * Assorted utility and extension methods for performing I/O.
*/
class IOUtils {
  /**
   * Inspect the given `location` to build an appropriate `URI`. Locations
   * containing the ':/' schema sub-string are deemed to contain a valid
   * URI. In absence of this subn-string the given `location` is deemed to be
   * a filename.
   *
   * @param location the URI location
   *
   * @return The URI built from the given `location`.
  */
  static def uriFromLocation(String location) {
    if(location.contains(':/')) {
      new URI(location)
    } else {
      new File(location).toURI
    }
  }
}