package xrrocha.copier

import java.util.ArrayList
import java.util.Iterator
import java.util.List

interface CopierComponent {
    def void open()
    def void close()
}

interface Source<E> extends CopierComponent, Iterator<E> {}

interface Filter<E> { def Boolean matches(E element) }

interface Transformer<E> { def E transform(E element) }

interface Destination<E> extends CopierComponent { def void put(E element) }

class Copier<E> extends SafeCopierListener<E> {
    @Property Source<E> source
    @Property Filter<E> filter
    @Property Transformer<E> transformer
    @Property Destination<E> destination
    @Property boolean stopOnError = true
    @Property CopierListener<E> listener = new LoggingCopierListener

    final def copy() {
        open()
        
        try {
            source.forEach [
                try {
                    val element = transform(it)
                    if (matches(element)) {
                        put(element)
                    }
                } catch (Exception e) {
                    if (stopOnError) {
                        throw e
                    }
                }
            ]
        } finally {
            close()
        }
    }

    private def open() {
        val openedSoFar = new ArrayList

        components.forEach [
            try {
                it.open()
                onOpen(it)
            } catch (Exception e) {
                openedSoFar.forEach[safeClose]
                onOpenError(it, e)
                throw e
            }

            openedSoFar.add(it)
        ]
    }
    
    private def transform(E element) {
        try {
            val transformedElement = transformer?.transform(element) ?: element
            onTransform(element, transformedElement)
            transformedElement
        } catch (Exception e) {
            onTransformError(element, e)
            throw e
        }
    }
    
    private def matches(E element) {
        try {
            val matches = filter?.matches(element) ?: true
            onFilter(element, matches)
            matches
        } catch (Exception e) {
            onFilterError(element, e)
            throw e
        }
    }
    
    private def put(E element) {
        try {
            destination.put(element)
            onPut(element)
        } catch (Exception e) {
            onPutError(element, e)
            throw e
        }
    }

    private def close() {
        components.forEach[safeClose]
    }
    
    def safeClose(CopierComponent component) {
        try {
            component.close()
            onClose(component)
        } catch (Exception e) {
            onCloseError(component, e)
        }
    }
    
    private def components() {
        val List<CopierComponent> components = newArrayList(source)
        
        if (transformer instanceof CopierComponent)
            components.add(transformer as CopierComponent)
        
        if (filter instanceof CopierComponent)
            components.add(filter as CopierComponent)

        components.add(destination)
        
        components
    }
}

