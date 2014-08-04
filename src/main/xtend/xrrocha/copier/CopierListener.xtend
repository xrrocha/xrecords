package xrrocha.copier

import java.util.List
import org.slf4j.LoggerFactory

interface CopierListener<E> {
    def void onOpen(Lifecycle component)
    def void onOpenError(Lifecycle offendingComponent, Exception exception)
    
    def void onFilter(E element, boolean matches, int recno)
    def void onFilterError(E element, int recno, Exception exception)
    
    def void onNext(E element, int recno)
    def void onNextError(int recno, Exception exception)
    
    def void onTransform(E element, E transformedElement, int recno)
    def void onTransformError(E element, int recno, Exception exception)
    
    def void onPut(E element, int recno)
    def void onPutError(E element, int recno, Exception exception)
    
    def void onStop(int recno)
    
    def void onCloseComponent(Lifecycle component, int count)
    def void onCloseComponentError(Lifecycle offendingComponent, int count, Exception exception)
    def void onClose(int count)
}

abstract class BaseCopierListener<E> implements CopierListener<E> {
    def onRecursiveError(String context, Exception exception) {}
}

abstract class DefaultCopierListener<E>  extends BaseCopierListener<E> {
    override onOpen(Lifecycle component) {}
    override onOpenError(Lifecycle offendingComponent, Exception exception) {}
        
    override onFilter(E element, boolean matches, int recno) {}
    override onFilterError(E element, int recno, Exception exception) {}
    
    override onTransform(E element, E transformedElement, int recno) {}
    override onTransformError(E element, int recno, Exception exception) {}
    
    override onPut(E element, int recno) {}
    override onPutError(E element, int recno, Exception exception) {}
    
    override onCloseComponent(Lifecycle component, int count) {}
    override onCloseComponentError(Lifecycle offendingComponent, int count, Exception exception) {}
    override onClose(int count)
}

class LoggingCopierListener<E> extends DefaultCopierListener<E> {
   static val logger = LoggerFactory.getLogger(LoggingCopierListener)
   
    override onOpen(Lifecycle component) {
        if (logger.debugEnabled)
            logger.debug('''onOpen(«component.getClass.getName»)''')
    }
    override onOpenError(Lifecycle offendingComponent, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onOpenError(«offendingComponent.getClass.getName», «exception»)''', exception)
    }

    override onNext(E element, int recno) {
        if (logger.debugEnabled)
            logger.debug('''onNext(«element», «recno»)''')
    }
    
    override onNextError(int recno, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onNextError(«recno», «exception»)''', exception)
    }
        
    override onFilterError(E element, int recno, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onFilterError(«element», «exception»)''', exception)
    }
    
    override onTransformError(E element, int recno, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onTransformError(«element», «exception»)''', exception)
    }
    
    override onPutError(E element, int recno, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onPutError(«element», «exception»)''', exception)
    }
    
    override void onStop(int recno) {
        if (logger.warnEnabled)
            logger.warn('''onStop(«recno»)''')
    }
    
    override onCloseComponent(Lifecycle component, int count) {
        if (logger.debugEnabled)
            logger.debug('''onCloseComponent(«component.getClass.getName»)''')
    }
    override onCloseComponentError(Lifecycle offendingComponent, int count, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onCloseComponentError(«offendingComponent.getClass.getName», «exception»)''', exception)
    }
    override onClose(int count) {
        if (logger.debugEnabled)
            logger.debug('''onClose(«count»)''')
    }
}

class SafeCopierListener<E> extends BaseCopierListener<E> {
    @Property CopierListener<E> listener
    
    override onOpen(Lifecycle component) {
        try {
            listener?.onOpen(component)
        } catch (Exception r) {
            onRecursiveError('onOpen', r)
        }
    }
    override onOpenError(Lifecycle offendingComponent, Exception exception) {
        try {
            listener?.onOpenError(offendingComponent, exception)
        } catch (Exception r) {
            onRecursiveError('onOpenError', r)
        }
    }

    override onNext(E element, int recno) {
        try {
            listener?.onNext(element, recno)
        } catch (Exception r) {
            onRecursiveError('onNext', r)
        }
    }
    
    override onNextError(int recno, Exception exception) {
        try {
            listener?.onNextError(recno, exception)
        } catch (Exception r) {
            onRecursiveError('onNextError', r)
        }
    }
        
    override onFilter(E element, boolean matches, int recno) {
        try {
            listener?.onFilter(element, matches, recno)
        } catch (Exception r) {
            onRecursiveError('onFilter', r)
        }
    }

    override onFilterError(E element, int recno, Exception exception) {
        try {
            listener?.onFilterError(element, recno, exception)
        } catch (Exception r) {
            onRecursiveError('onFilterError', r)
        }
    }
    
    override onTransform(E element, E transformedElement, int recno) {
        try {
            listener?.onTransform(element, transformedElement, recno)
        } catch (Exception r) {
            onRecursiveError('onTransform', r)
        }
    }
    override onTransformError(E element, int recno, Exception exception) {
        try {
            listener?.onTransformError(element, recno, exception)
        } catch (Exception r) {
            onRecursiveError('onTransformationError', r)
        }
    }
    
    override onPut(E element, int recno) {
        try {
            listener?.onPut(element, recno)
        } catch (Exception r) {
            onRecursiveError('onPut', r)
        }
    }
    override onPutError(E element, int recno, Exception exception) {
        try {
            listener?.onPutError(element, recno, exception)
        } catch (Exception r) {
            onRecursiveError('onPutError', r)
        }
    }
    
    override void onStop(int recno) {
        try {
            listener?.onStop(recno)
        } catch (Exception r) {
            onRecursiveError('onStop', r)
        }
    }
    
    override onCloseComponent(Lifecycle component, int count) {
        try {
            listener?.onCloseComponent(component, count)
        } catch (Exception r) {
            onRecursiveError('onCloseComponent', r)
        }
    }
    override onCloseComponentError(Lifecycle offendingComponent, int count, Exception exception) {
        try {
            listener?.onCloseComponentError(offendingComponent, count, exception)
        } catch (Exception r) {
            onRecursiveError('onCloseComponentError', r)
        }
    }
    override onClose(int count) {
        try {
            listener?.onClose(count)
        } catch (Exception r) {
            onRecursiveError('onClose', r)
        }
    }
}

class MultiCopierListener<E> extends BaseCopierListener<E> {
    @Property List<?extends CopierListener<E>> listeners
    
    new() {}
    
    new(List<?extends CopierListener<E>> listeners) { this.listeners = listeners }
    
    override onOpen(Lifecycle component) {
        listeners?.forEach[
            try {
                it?.onOpen(component)
            } catch (Exception r) {
                onRecursiveError('onOpen', r)
            }
        ]
    }
    override onOpenError(Lifecycle offendingComponent, Exception exception) {
        listeners?.forEach[
            try {
                it?.onOpenError(offendingComponent, exception)
            } catch (Exception r) {
                onRecursiveError('onOpenError', r)
            }
        ]
    }

    override onNext(E element, int recno) {
        listeners?.forEach[
            try {
                it?.onNext(element, recno)
            } catch (Exception r) {
                onRecursiveError('onNext', r)
            }
        ]
    }
    
    override onNextError(int recno, Exception exception) {
        listeners?.forEach[
            try {
                it?.onNextError(recno, exception)
            } catch (Exception r) {
                onRecursiveError('onNextError', r)
            }
        ]
    }
       
    override onFilter(E element, boolean matches, int recno) {
        listeners?.forEach[
            try {
                it?.onFilter(element, matches, recno)
            } catch (Exception r) {
                onRecursiveError('onFilter', r)
            }
        ]
    }
    override onFilterError(E element, int recno, Exception exception) {
        listeners?.forEach[
            try {
                it?.onFilterError(element, recno, exception)
            } catch (Exception r) {
                onRecursiveError('onFilterError', r)
            }
        ]
    }
    
    override onTransform(E element, E transformedElement, int recno) {
        listeners?.forEach[
            try {
                it?.onTransform(element, transformedElement, recno)
            } catch (Exception r) {
                onRecursiveError('onTransform', r)
            }
        ]
    }
    override onTransformError(E element, int recno, Exception exception) {
        listeners?.forEach[
            try {
                it?.onTransformError(element, recno, exception)
            } catch (Exception r) {
                onRecursiveError('onTransformError', r)
            }
        ]
    }
    
    override onPut(E element, int recno) {
        listeners?.forEach[
            try {
                it?.onPut(element, recno)
            } catch (Exception r) {
                onRecursiveError('onPut', r)
            }
        ]
    }
    override onPutError(E element, int recno, Exception exception) {
        listeners?.forEach[
            try {
                it?.onPutError(element, recno, exception)
            } catch (Exception r) {
                onRecursiveError('onPutError', r)
            }
        ]
    }
    
    override void onStop(int recno) {
        listeners?.forEach[
            try {
                it?.onStop(recno)
            } catch (Exception r) {
                onRecursiveError('onStop', r)
            }
        ]
    }

    override onCloseComponent(Lifecycle component, int count) {
        listeners?.forEach[
            try {
                it?.onCloseComponent(component, count)
            } catch (Exception r) {
                onRecursiveError('onCloseComponent', r)
            }
        ]
    }
    override onCloseComponentError(Lifecycle offendingComponent, int count, Exception exception) {
        listeners?.forEach[
            try {
                it?.onCloseComponentError(offendingComponent, count, exception)
            } catch (Exception r) {
                onRecursiveError('onCloseComponentError', r)
            }
        ]
    }
    override onClose(int count) {
        listeners?.forEach[
            try {
                it?.onClose(count)
            } catch (Exception r) {
                onRecursiveError('onClose', r)
            }
        ]
    }    
}
