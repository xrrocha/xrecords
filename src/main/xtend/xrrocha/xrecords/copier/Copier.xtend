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
        
        val delegate = new CopierDelegate(this)
        
        try {
            delegate.forEach [
                try {
                    val element = delegate.transform(it)
                    
                    if (delegate.matches(element)) {
                        delegate.put(element)
                    }
                } catch (Exception e) {
                    if (stopOnError) {
                        onStop(delegate.recno)
                        throw e
                    }
                }
            ]
        } finally {
            close(delegate.recno)
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

class CopierDelegate<E> implements Iterator<Object> {
    Copier copier
    
    @Property int recno = 0
    
    new(Copier copier) {
        this.copier = copier        
    }
 
    override hasNext() {
        try {
            copier.source.hasNext
        } catch (Exception e) {
            copier.onNextError(recno, e)
            copier.onStop(recno)
            throw e
        }
    }
    
    override next() {
        try {
            val result = copier.source.next
            copier.onNext(result, recno)
            result
        } catch (Exception e) {
            copier.onNextError(recno, e)
            copier.onStop(recno)
            throw e
        }
    }
    
    def boolean matches(Object element) {
        if (copier.matcher == null) {
            true
        } else {
            try {
                val matches = copier.matcher.matches(element)
                copier.onFilter(element, matches, recno)
                matches
            } catch (Exception e) {
                copier.onFilterError(element, recno, e)
                throw e
            }
        }
    }
    
    def Object transform(Object element) {
        if (copier.transformer == null) {
            element
        } else {
            try {
                val transformedElement = copier.transformer.transform(element)
                copier.onTransform(element, transformedElement, recno)
                transformedElement
            } catch (Exception e) {
                copier.onTransformError(element, recno, e)
                throw e
            }
        }
    }
    
    def void put(Object element) {
        try {
            copier.destination.put(element)
            copier.onPut(element,recno)
            recno = recno + 1
        } catch (Exception e) {
            copier.onPutError(element, recno, e)
            throw e
        }
    }
    
    override remove() {
        throw new UnsupportedOperationException("CopierDelegate.remove: unimplemented")
    }
}
