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

// FIXME Does Copier need a generic type?
class Copier<E> extends SafeCopierListener<E> {
    @Property Source<E> source
    @Property Matcher<E> matcher
    @Property Transformer<E> transformer
    @Property Destination<E> destination
    
    @Property boolean stopOnError = true
    @Property CopierListener<E> listener = new LoggingCopierListener

    final def copy() {
        open()
        
        val delegate = new CopierDelegate<E>(this)
        
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

class CopierDelegate<E> implements Source<E>, Matcher<E>, Transformer<E>, Destination<E> {
    Source<E> source
    Matcher<E> matcher
    Transformer<E> transformer
    Destination<E> destination
    CopierListener<E> listener
    
    @Property int recno = 0
    
    new(Copier<E> copier) {
        this.source = copier.source
        this.matcher = copier.matcher
        this.transformer = copier.transformer
        this.destination = copier.destination
        this.listener = copier        
    }
 
    override hasNext() {
        try {
            source.hasNext
        } catch (Exception e) {
            listener.onNextError(recno, e)
            listener.onStop(recno)
            throw e
        }
    }
    
    override next() {
        try {
            val result = source.next
            listener.onNext(result, recno)
            result
        } catch (Exception e) {
            listener.onNextError(recno, e)
            listener.onStop(recno)
            throw e
        }
    }
    
    override boolean matches(E element) {
        if (matcher == null) {
            true
        } else {
            try {
                val matches = matcher.matches(element)
                listener.onFilter(element, matches, recno)
                matches
            } catch (Exception e) {
                listener.onFilterError(element, recno, e)
                throw e
            }
        }
    }
    
    override E transform(E element) {
        if (transformer == null) {
            element
        } else {
            try {
                val transformedElement = transformer.transform(element)
                listener.onTransform(element, transformedElement, recno)
                transformedElement
            } catch (Exception e) {
                listener.onTransformError(element, recno, e)
                throw e
            }
        }
    }
    
    override void put(E element) {
        try {
            destination.put(element)
            listener.onPut(element,recno)
            recno = recno + 1
        } catch (Exception e) {
            listener.onPutError(element, recno, e)
            throw e
        }
    }
    
    override remove() {
        throw new UnsupportedOperationException("CopierDelegate.remove: unimplemented")
    }
}
