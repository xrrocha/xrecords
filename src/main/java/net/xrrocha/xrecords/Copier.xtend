package net.xrrocha.xrecords

import java.util.Iterator
import net.xrrocha.xrecords.validation.Validatable
import net.xrrocha.xrecords.validation.Validator
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

import static net.xrrocha.xrecords.validation.ValidationState.*

@Data class Stats {
    int recordsRead
    int recordsSkipped

    public static val ZERO_STATS = new Stats(0, 0)
    
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
	final CopierListener listener

	private var count = 0
	
	new(Source source, CopierListener listener) {
		this.source = source
		this.listener = listener
	}
	
	override open() {
		try {
			source.open()
			listener.onSourceOpen(source)
		} catch (Exception e) {
			listener.onSourceOpenError(source, e)
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
			listener.onSourceClose(source, stats)
		} catch(Exception e) {
			listener.onSourceCloseError(source, stats, e)
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
	final CopierListener listener

	private var count = 0
	
	new(Filter filter, CopierListener listener) {
		this.filter = filter
		this.listener = listener
	}
	
	override matches(Record record) {
		try {
			val matches = filter.matches(record)
			if (matches) {
				count++
			}
			listener.onFilter(filter, record, matches, count)
			matches
		} catch (Exception e) {
			listener.onFilterError(filter, record, count, e)
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
	final CopierListener listener
	
	private var count = 0
	
	new(Transformer transformer, CopierListener listener) {
		this.transformer = transformer
		this.listener = listener
	}
	
	override def transform(Record record) {
		count++
		try {
			val transformedRecord = transformer.transform(record)
			listener.onTransform(transformer, record, transformedRecord, count)
			transformedRecord
		} catch (Exception e) {
			listener.onTransformError(transformer, record, count, e)
			throw e
		}
	}
}

interface Destination extends Lifecycle {
    def void put(Record record)
}

class DelegatingDestination implements Destination {
	final Destination destination
	final CopierListener listener
	final boolean stopOnError
	
	private var count = 0
	
	new(Destination destination, CopierListener listener, boolean stopOnError) {
		this.destination = destination
		this.listener = listener
		this.stopOnError = stopOnError
	}
	
	override open() {
		try {
			destination.open()
			listener.onDestinationOpen(destination)
		} catch (Exception e) {
			listener.onDestinationOpenError(destination, e)
			throw e
		}
	}	
	
	override put(Record record) {
		count++
		try {
			destination.put(record)
			listener.onPut(destination, record, count)
		} catch (Exception e) {
			listener.onPutError(destination, record, count, e)
			if (stopOnError) {
				throw e
			}
		}
	}
	
	override close(Stats stats) {
		try {
			destination.close(stats)
			listener.onDestinationClose(destination, stats)
		} catch (Exception e) {
			listener.onDestinationCloseError(destination, stats, e)
		}
	}
}

// TODO Add pre/post hooks to Copier (w/scripting implementation)
@Accessors
class Copier extends SafeCopierListener {
    Source source
    Filter filter = Filter.nullFilter
    Transformer transformer = Transformer.nullTransformer
    Destination destination

	// TODO Add tally and copy of bad records
    boolean stopOnError = true
    
    val listener = new SafeCopierListener

    final def copy() {
        validate()
        
        val source = new DelegatingSource(this.source, listener)
        val filter = new DelegatingFilter(this.filter, listener)
        val transformer = new DelegatingTransformer(this.transformer, listener)
        val destination = new DelegatingDestination(this.destination, listener, stopOnError)

        #[source, destination].forEach[open]
        	
        try {
	        source.
	        	filter[filter.matches(it)].
	        	map[transformer.transform(it)].
	        	forEach[destination.put(it)]
        } finally {
        	val stats = new Stats(source.recordsRead, filter.recordsSkipped)
        	#[source, destination].forEach[close(stats)]
        }
    }

    def validate() {
        if (validator.state == NEW) {
            validator.validate()
        }
        if (validator.state == FAILED) {
            throw new IllegalStateException('Cannot copy: validation failed')
        }
    }

    private val validator = new Validator [ errors |
        if (source == null) {
            errors.add('Missing source')
        } else if (source instanceof Validatable) {
            (source as Validatable).validate(errors)
        }
        if (filter != null && filter instanceof Validatable) {
            (filter as Validatable).validate(errors)
        }
        if (transformer != null && transformer instanceof Validatable) {
            (transformer as Validatable).validate(errors)
        }
        if (destination == null) {
            errors.add('Missing destination')
        } else if (destination instanceof Validatable) {
            (destination as Validatable).validate(errors)
        }
    ]}
