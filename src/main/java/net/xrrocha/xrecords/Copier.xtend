package net.xrrocha.xrecords

import java.util.Iterator
import java.util.concurrent.atomic.AtomicInteger
import net.xrrocha.xrecords.validation.Validatable
import net.xrrocha.xrecords.validation.Validator
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

import static net.xrrocha.xrecords.validation.ValidationState.*

@Data class Stats {
  AtomicInteger recordsRead
  AtomicInteger recordsSkipped

  public new() {
    this(0, 0)
  }

  public new(int recordsRead, int recordsSkipped) {
    this.recordsRead = new AtomicInteger(recordsRead)
    this.recordsSkipped = new AtomicInteger(recordsSkipped)
  }

  public new(AtomicInteger recordsRead, AtomicInteger recordsSkipped) {
    this.recordsRead = recordsRead
    this.recordsSkipped = recordsSkipped
  }

  public static val ZERO_STATS = new Stats

  override toString() {
    '''recordsRead: «recordsRead», recordsSkipped: «recordsSkipped»'''
  }
}

interface Lifecycle {
  def void open()

  def void close(Stats stats)
}

interface Source extends Iterator<Record>, Lifecycle {}

class DelegatingSource implements Source {
  final Source source

  private var count = 0

  new(Source source) {
    this.source = source
  }

  override open() {
    try {
      source.open()
    } catch(Exception e) {
    }
  }

  override boolean hasNext() {
    source.hasNext
  }

  override next() {
    count++
    val record = source.next
    record
  }

  override close(Stats stats) {
    try {
      source.close(stats)
    } catch(Exception e) {
    }
  }

  def recordsRead() { count }
}

interface Filter {
  def boolean matches(Record record)

  val nullFilter = new Filter {
    override matches(Record record) { true }
  }
}

class DelegatingFilter implements Filter {
  final Filter filter

  private var count = 0

  new(Filter filter) {
    this.filter = filter
  }

  override matches(Record record) {
    try {
      val matches = filter.matches(record)
      if(matches) {
        count++
      }
      matches
    } catch(Exception e) {
      throw e
    }
  }

  def recordsSkipped() { count }
}

interface Transformer {
  def Record transform(Record record)

  val nullTransformer = new Transformer {
    override transform(Record record) { record }
  }
}

class DelegatingTransformer implements Transformer {
  final Transformer transformer

  private val count = new AtomicInteger(0)

  new(Transformer transformer) {
    this.transformer = transformer
  }

  override def transform(Record record) {
    count.incrementAndGet
    try {
      val transformedRecord = transformer.transform(record)
      transformedRecord
    } catch(Exception e) {
      throw e
    }
  }
}

interface Destination extends Lifecycle {
  def void put(Record record)
}

class DelegatingDestination implements Destination {
  final Destination destination
  final boolean stopOnError

  private var count = 0

  new(Destination destination, boolean stopOnError) {
    this.destination = destination
    this.stopOnError = stopOnError
  }

  override open() {
    try {
      destination.open()
    } catch(Exception e) {
      throw e
    }
  }

  override put(Record record) {
    count++
    try {
      destination.put(record)
    } catch(Exception e) {
      if(stopOnError) {
        throw e
      }
    }
  }

  override close(Stats stats) {
    try {
      destination.close(stats)
    } catch(Exception e) {
    }
  }
}

// TODO Add pre/post hooks to Copier (w/scripting implementation)
@Accessors
class Copier {
  Source source
  Filter filter = Filter.nullFilter
  Transformer transformer = Transformer.nullTransformer
  Destination destination

  // TODO Add tally and copy of bad records
  boolean stopOnError = true

  final def copy() {
    validate()

    #[source, destination].forEach[open]

    try {
      source.
      filter[filter.matches(it)].
      map[transformer.transform(it)].
      forEach[destination.put(it)]
    } finally {
      val stats = new Stats //new Stats(source.recordsRead, filter.recordsSkipped)
      #[source, destination].forEach[close(stats)]
    }
  }

  def validate() {
    if(validator.state == NEW) {
      validator.validate()
    }
    if(validator.state == FAILED) {
      throw new IllegalStateException('Cannot copy: validation failed')
    }
  }

  private val validator = new Validator [ errors |
    if(source == null) {
      errors.add('Missing source')
    } else if(source instanceof Validatable) {
      (source as Validatable).validate(errors)
    }
    if(filter != null && filter instanceof Validatable) {
      (filter as Validatable).validate(errors)
    }
    if(transformer != null && transformer instanceof Validatable) {
      (transformer as Validatable).validate(errors)
    }
    if(destination == null) {
      errors.add('Missing destination')
    } else if(destination instanceof Validatable) {
      (destination as Validatable).validate(errors)
    }
  ]}
