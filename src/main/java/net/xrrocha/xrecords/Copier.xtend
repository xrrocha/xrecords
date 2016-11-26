package net.xrrocha.xrecords

import java.util.Iterator
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * A `Lifecycle` class provides methods for `open`ing and `close`ing it.
 *
 * This interface is extended by `Source` and `Destination` so that their
 * interal resources (files, database connections, network connections, etc.)
 * are created prior to `Record` copying and disposed of afterwards.
*/
interface Lifecycle {
  def void open()
  def void close()
}

interface Source extends Iterator<Record>, Lifecycle {
}

interface Filter {
  def boolean matches(Record record)
}

interface Transformer {
  def Record transform(Record record)
}

interface Destination extends Lifecycle {
  def void put(Record record)
}

@Accessors
class Copier {
  Source source
  Filter filter = [ record | true ]
  Transformer transformer = [ record | record ]
  Destination destination

  final def copy() {
    #[source, destination].forEach[open]

    try {
      source.
        filter[filter.matches(it)].
        map[transformer.transform(it)].
        forEach[destination.put(it)]
    } finally {
      #[source, destination].forEach[close]
    }
  }
}

