package xrrocha.xrecords.copier

import java.util.ArrayList
import java.util.Iterator

interface Lifecycle {
    def void open()
    def void close()
}

interface Source<E> extends Iterator<E> {}

interface Matcher<E> { def boolean matches(E element) }

interface Transformer<E> { def E transform(E element) }

interface Destination<E> { def void put(E element) }

class Copier extends SafeCopierListener {
    @Property Source<Object> source
    @Property Matcher<Object> matcher
    @Property Transformer<Object> transformer
    @Property Destination<Object> destination
    
    @Property boolean stopOnError = true
    @Property CopierListener listener = new LoggingCopierListener

    final def copy() {
        open()
        
        var count = 0
        
        try {
            while (hasNext(count)) {
                try {
                    val nextElement = next(count)
                    
                    val element = transform(nextElement, count)
                    
                    if (matches(element, count)) {
                        put(element, count)
                    }
                } catch (Exception e) {
                    if (stopOnError) {
                        onStop(count)
                        throw e
                    }
                }
                
                count = count + 1
            }
        } finally {
            close(count)
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
            if (stopOnError) {
                onStop(recno)
            }
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
    
    private def transform(Object element, int recno) {
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
    
    private def matches(Object element, int recno) {
        if (matcher == null) {
            true
        } else {
            try {
                val matches = matcher.matches(element)
                onFilter(element, matches, recno)
                matches
            } catch (Exception e) {
                onFilterError(element, recno, e)
                throw e
            }
        }
    }
    
    private def put(Object element, int recno) {
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

    private var Iterable<Lifecycle> components 
    private def lifecycleComponents() {
        if (components == null) {
            components = #[source, matcher, transformer, destination].
                filter [it instanceof Lifecycle].
                map[it as Lifecycle]
        }
        components
    }
}
