package xrrocha.copier

import java.util.List
import org.slf4j.LoggerFactory

interface CopierListener<E> {
    def void onOpen(CopierComponent component)
    def void onOpenError(CopierComponent offendingComponent, Exception exception)
    
    def void onFilter(E element, boolean matches)
    def void onFilterError(E element, Exception exception)
    
    def void onTransform(E element, E transformedElement)
    def void onTransformError(E element, Exception exception)
    
    def void onPut(E element)
    def void onPutError(E element, Exception exception)
    
    def void onClose(CopierComponent component)
    def void onCloseError(CopierComponent offendingComponent, Exception exception)
}

abstract class BaseCopierListener<E> implements CopierListener<E> {
    def onRecursiveError(String context, Exception exception) {}
}

abstract class DefaultCopierListener<E>  extends BaseCopierListener<E> {
    override onOpen(CopierComponent component) {}
    override onOpenError(CopierComponent offendingComponent, Exception exception) {}
        
    override onFilter(E element, boolean matches) {}
    override onFilterError(E element, Exception exception) {}
    
    override onTransform(E element, E transformedElement) {}
    override onTransformError(E element, Exception exception) {}
    
    override onPut(E element) {}
    override onPutError(E element, Exception exception) {}
    
    override onClose(CopierComponent component) {}
    override onCloseError(CopierComponent offendingComponent, Exception exception) {}
}

class LoggingCopierListener<E> extends DefaultCopierListener<E> {
   static val logger = LoggerFactory.getLogger(LoggingCopierListener)
   
    override onOpen(CopierComponent component) {
        if (logger.debugEnabled)
            logger.debug('''onOpen(«component.getClass.getName»)''')
    }
    override onOpenError(CopierComponent offendingComponent, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onOpenError(«offendingComponent.getClass.getName», «exception»)''', exception)
    }
        
    override onFilter(E element, boolean matches) {}
    override onFilterError(E element, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onFilterError(«element», «exception»)''', exception)
    }
    
    override onTransformError(E element, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onTransformError(«element», «exception»)''', exception)
    }
    
    override onPutError(E element, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onPutError(«element», «exception»)''', exception)
    }
    
    override onClose(CopierComponent component) {
        if (logger.debugEnabled)
            logger.debug('''onClose(«component.getClass.getName»)''')
    }
    override onCloseError(CopierComponent offendingComponent, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onCloseError(«offendingComponent.getClass.getName», «exception»)''', exception)
    }
}

class SafeCopierListener<E> extends BaseCopierListener<E> {
    @Property CopierListener<E> listener
    
    override onOpen(CopierComponent component) {
        try {
            listener?.onOpen(component)
        } catch (Exception r) {
            onRecursiveError('onOpen', r)
        }
    }
    override onOpenError(CopierComponent offendingComponent, Exception exception) {
        try {
            listener?.onOpenError(offendingComponent, exception)
        } catch (Exception r) {
            onRecursiveError('onOpenError', r)
        }
    }
        
    override onFilter(E element, boolean matches) {
        try {
            listener?.onFilter(element, matches)
        } catch (Exception r) {
            onRecursiveError('onFilter', r)
        }
    }
    override onFilterError(E element, Exception exception) {
        try {
            listener?.onFilterError(element, exception)
        } catch (Exception r) {
            onRecursiveError('onFilterError', r)
        }
    }
    
    override onTransform(E element, E transformedElement) {
        try {
            listener?.onTransform(element, transformedElement)
        } catch (Exception r) {
            onRecursiveError('onTransform', r)
        }
    }
    override onTransformError(E element, Exception exception) {
        try {
            listener?.onTransformError(element, exception)
        } catch (Exception r) {
            onRecursiveError('onTransformationError', r)
        }
    }
    
    override onPut(E element) {
        try {
            listener?.onPut(element)
        } catch (Exception r) {
            onRecursiveError('onPut', r)
        }
    }
    override onPutError(E element, Exception exception) {
        try {
            listener?.onPutError(element, exception)
        } catch (Exception r) {
            onRecursiveError('onPutError', r)
        }
    }
    
    override onClose(CopierComponent component) {
        try {
            listener?.onClose(component)
        } catch (Exception r) {
            onRecursiveError('onClose', r)
        }
    }
    override onCloseError(CopierComponent offendingComponent, Exception exception) {
        try {
            listener?.onCloseError(offendingComponent, exception)
        } catch (Exception r) {
            onRecursiveError('onCloseError', r)
        }
    }
}

class MultiCopierListener<E> extends BaseCopierListener<E> {
    @Property List<CopierListener<E>> listeners
    
    override onOpen(CopierComponent component) {
        listeners?.forEach[
            try {
                it?.onOpen(component)
            } catch (Exception r) {
                onRecursiveError('onOpen', r)
            }
        ]
    }
    override onOpenError(CopierComponent offendingComponent, Exception exception) {
        listeners?.forEach[
            try {
                it?.onOpenError(offendingComponent, exception)
            } catch (Exception r) {
                onRecursiveError('onOpenError', r)
            }
        ]
    }
       
    override onFilter(E element, boolean matches) {
        listeners?.forEach[
            try {
                it?.onFilter(element, matches)
            } catch (Exception r) {
                onRecursiveError('onFilter', r)
            }
        ]
    }
    override onFilterError(E element, Exception exception) {
        listeners?.forEach[
            try {
                it?.onFilterError(element, exception)
            } catch (Exception r) {
                onRecursiveError('onFilterError', r)
            }
        ]
    }
    
    override onTransform(E element, E transformedElement) {
        listeners?.forEach[
            try {
                it?.onTransform(element, transformedElement)
            } catch (Exception r) {
                onRecursiveError('onTransform', r)
            }
        ]
    }
    override onTransformError(E element, Exception exception) {
        listeners?.forEach[
            try {
                it?.onTransformError(element, exception)
            } catch (Exception r) {
                onRecursiveError('onTransformError', r)
            }
        ]
    }
    
    override onPut(E element) {
        listeners?.forEach[
            try {
                it?.onPut(element)
            } catch (Exception r) {
                onRecursiveError('onPut', r)
            }
        ]
    }
    override onPutError(E element, Exception exception) {
        listeners?.forEach[
            try {
                it?.onPutError(element, exception)
            } catch (Exception r) {
                onRecursiveError('onPutError', r)
            }
        ]
    }
    
    override onClose(CopierComponent component) {
        listeners?.forEach[
            try {
                it?.onClose(component)
            } catch (Exception r) {
                onRecursiveError('onClose', r)
            }
        ]
    }
    override onCloseError(CopierComponent offendingComponent, Exception exception) {
        listeners?.forEach[
            try {
                it?.onCloseError(offendingComponent, exception)
            } catch (Exception r) {
                onRecursiveError('onCloseError', r)
            }
        ]
    }
}

