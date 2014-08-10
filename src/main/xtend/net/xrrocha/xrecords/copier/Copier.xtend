package net.xrrocha.xrecords.copier

import java.util.ArrayList
import java.util.Iterator
import net.xrrocha.xrecords.validation.Validatable
import net.xrrocha.xrecords.validation.Validator

import static net.xrrocha.xrecords.validation.ValidationState.*

interface Lifecycle {
    def void open()
    def void close(int count)
}

interface Source<E> extends Lifecycle, Iterator<E> {}

interface Matcher<E> { def boolean matches(E element) }

interface Transformer<E> { def E transform(E element) }

interface Destination<E> extends Lifecycle { def void put(E element, int index) }

class Copier extends SafeCopierListener {
    @Property Source<Object> source
    @Property Matcher<Object> matcher
    @Property Transformer<Object> transformer
    @Property Destination<Object> destination
    
    @Property boolean stopOnError = true
    @Property CopierListener listener = new LoggingCopierListener
    
    final def copy() {
        if (validator.state == NEW) {
            validator.validate()
        }
        if (validator.state == FAILED) {
            throw new IllegalStateException('Cannot copy: validation failed')
        }
        
        open()
        
        var count = 0
        
        try {
            while (hasNext(count)) {
                try {
                    val element = next(count)
                    
                    if (matches(element, count)) {
                        val transformedElement = transform(element, count)
                        put(transformedElement, count)
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
    
    private def hasNext(int index) {
        try {
            source.hasNext
        } catch (Exception e) {
            onNextError(index, e)
            if (stopOnError) {
                onStop(index)
            }
            throw e
        }
    }

    private def next(int index) {
        try {
            val element = source.next
            onNext(element, index)
            element
        } catch (Exception e) {
            onNextError(index, e)
            throw e
        }
    }
    
    private def transform(Object element, int index) {
        if (transformer == null) {
            element
        } else {
            try {
                val transformedElement = transformer.transform(element)
                onTransform(element, transformedElement, index)
                transformedElement
            } catch (Exception e) {
                onTransformError(element, index, e)
                throw e
            }
        }
    }
    
    private def matches(Object element, int index) {
        if (matcher == null) {
            true
        } else {
            try {
                val matches = matcher.matches(element)
                onFilter(element, matches, index)
                matches
            } catch (Exception e) {
                onFilterError(element, index, e)
                throw e
            }
        }
    }
    
    private def put(Object element, int index) {
        try {
            destination.put(element, index)
            onPut(element,index)
        } catch (Exception e) {
            onPutError(element, index, e)
            throw e
        }
    }

    private def close(int count) {
        lifecycleComponents.forEach[safeClose(it, count)]
        onClose(count)
    }
    
    def safeClose(Lifecycle component, int count) {
        try {
            component.close(count)
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
    
    private val validator = new Validator [ errors |
        if (source == null) {
            errors.add('Missing source')
        } else if (source instanceof Validatable) {
            (source as Validatable).validate(errors)
        }
        if (destination == null) {
            errors.add('Missing destination')
        } else if (destination instanceof Validatable) {
            (destination as Validatable).validate(errors)
        }
        if (matcher != null && matcher instanceof Validatable) {
            (matcher as Validatable).validate(errors)
        }
        if (transformer != null && transformer instanceof Validatable) {
            (transformer as Validatable).validate(errors)
        }
    ]
}
