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

interface Filter {
    def boolean matches(Record record)

    val nullFilter = new Filter {
        override matches(Record record) { true }
    }
}

interface Transformer {
    def Record transform(Record record)

    val nullTransformer = new Transformer {
        override transform(Record record) { record }
    }
}

interface Destination extends Lifecycle {
    def void put(Record record)
}

// TODO Add pre/post hooks to Copier (w/scripting implementation)
class Copier extends SafeCopierListener {
    @Accessors Source source
    @Accessors Filter filter = Filter.nullFilter
    @Accessors Transformer transformer = Transformer.nullTransformer
    @Accessors Destination destination

    @Accessors boolean stopOnError = true

    final def copy() {
        validate()

        open()

        var recordsRead = 0
        var recordsSkipped = 0

        try {
            while (hasNext(recordsRead)) {
                try {
                    val element = next(recordsRead)

                    if (filter(element, recordsRead)) {
                        val transformedRecord = transform(element, recordsRead)
                        put(transformedRecord, recordsRead)
                    } else {
                        recordsSkipped += 1
                    }
                } catch (Exception e) {
                    if (stopOnError) {
                        onStop(e, recordsRead)
                        throw e
                    }
                }

                recordsRead = recordsRead + 1
            }
        } finally {
            close(recordsRead, recordsSkipped)
        }
    }

    private def open() {
        try {
            source.open()
            onSourceOpen(source)
        } catch (Exception e) {
            onSourceOpenError(source, e)
            throw e
        }

        try {
            destination.open()
            onDestinationOpen(destination)
        } catch (Exception d) {
            onDestinationOpenError(destination, d)
            try {
                source.close(Stats.ZERO_STATS)
                onSourceClose(source, Stats.ZERO_STATS)
            } catch (Exception s) {
                onSourceCloseError(source, Stats.ZERO_STATS, s)
            }
            throw d
        }
    }

    private def hasNext(int index) {
        try {
            source.hasNext
        } catch (Exception e) {
            onHasNextError(source, index, e)
            if (stopOnError) {
                onStop(e, index)
            }
            throw e
        }
    }

    private def next(int index) {
        try {
            val record = source.next
            onNext(source, record, index)
            record
        } catch (Exception e) {
            onNextError(source, index, e)
            throw e
        }
    }

    private def filter(Record record, int index) {
        if (filter == null || filter == Filter.nullFilter) {
            true
        } else {
            try {
                val matches = filter.matches(record)
                onFilter(filter, record, matches, index)
                matches
            } catch (Exception e) {
                onFilterError(filter, record, index, e)
                throw e
            }
        }
    }

    private def transform(Record record, int index) {
        if (transformer == null || transformer == Transformer.nullTransformer) {
            record
        } else {
            try {
                val transformedRecord = transformer.transform(record)
                onTransform(transformer, record, transformedRecord, index)
                transformedRecord
            } catch (Exception e) {
                onTransformError(transformer, record, index, e)
                throw e
            }
        }
    }

    private def put(Object destinationHandler, Record record, int index) {
        try {
            destination.put(record)
            onPut(destination, record, index)
        } catch (Exception e) {
            onPutError(destination, record, index, e)
            throw e
        }
    }

    private def close(int recordsRead, int recordsSkipped) {
        val stats = new Stats(recordsRead, recordsSkipped)
        val destinationSuccess = try {
            destination.close(stats)
            onDestinationClose(destination, stats)
            true
        } catch (Exception e) {
            onDestinationCloseError(destination, stats, e)
            false
        }

        val sourceSuccess = try {
            source.close(stats)
            onSourceClose(source, stats)
            true
        } catch (Exception e) {
            onSourceCloseError(source, stats, e)
            false
        }

        if (!(destinationSuccess && sourceSuccess)) {
            throw new IllegalStateException('Error closing source/destination')
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
