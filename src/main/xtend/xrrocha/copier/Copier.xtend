package xrrocha.copier

import java.util.ArrayList
import java.util.Iterator

interface Lifecycle {
    def void open()
    def void close()
}

interface Source<E> extends Iterator<E> {}

interface Filter<E> { def boolean matches(E element) }

interface Transformer<E> { def E transform(E element) }

interface Destination<E> { def void put(E element) }

class Copier<E> extends SafeCopierListener<E> {
    @Property Source<E> source
    @Property Filter<E> filter
    @Property Transformer<E> transformer
    @Property Destination<E> destination
    
    @Property boolean stopOnError = true
    @Property CopierListener<E> listener = new LoggingCopierListener

    final def copy() {
        open()
        
        var recno = 0
        
        try {
            while (hasNext(recno)) {
                val nextElement = next(recno)
                
                val element = transform(nextElement, recno)
                
                if (matches(element, recno)) {
                    put(element, recno)
                }
                
                recno = recno + 1
            }
        } catch (Exception e) {
            if (stopOnError) {
                onStop(recno)
                throw e
            }
        } finally {
            close(recno)
        }
    }

    private def open() {
        val openedSoFar = new ArrayList

        lifecycleComponents.forEach [ component |
            try {
                component.open()
                onOpen(component)
            } catch (Exception e) {
                openedSoFar.forEach[safeClose(it, 0)]
                onOpenError(component, e)
                throw e
            }

            openedSoFar.add(component)
        ]
    }
    
    private def hasNext(int recno) {
        try {
            source.hasNext
        } catch (Exception e) {
            onNextError(recno, e)
            throw e
        }
    }

    private def next(int recno) {
        try {
            val element = source.next
            onNext(element, recno)
            element
        } catch (Exception e) {
            onNextError(recno, e)
            throw e
        }
    }
    
    private def transform(E element, int recno) {
        if (transformer == null) {
            element
        } else {
            try {
                val transformedElement = transformer.transform(element)
                onTransform(element, transformedElement, recno)
                transformedElement
            } catch (Exception e) {
                onTransformError(element, recno, e)
                throw e
            }
        }
    }
    
    private def matches(E element, int recno) {
        if (filter == null) {
            true
        } else {
            try {
                val matches = filter.matches(element)
                onFilter(element, matches, recno)
                matches
            } catch (Exception e) {
                onFilterError(element, recno, e)
                throw e
            }
        }
    }
    
    private def put(E element, int recno) {
        try {
            destination.put(element)
            onPut(element,recno)
        } catch (Exception e) {
            onPutError(element, recno, e)
            throw e
        }
    }

    private def close(int count) {
        lifecycleComponents.forEach[safeClose(it, count)]
        onClose(count)
    }
    
    def safeClose(Lifecycle component, int count) {
        try {
            component.close()
            onCloseComponent(component, count)
        } catch (Exception e) {
            onCloseComponentError(component, count, e)
        }
    }
    
    private def lifecycleComponents() {
        #[source, filter, transformer, destination].
            filter [it instanceof Lifecycle].
            map[it as Lifecycle]
    }
}

