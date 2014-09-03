package net.xrrocha.xrecords

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory

interface CopierListener {
    def void onSourceOpen(Source source)

    def void onSourceOpenError(Source source, Exception exception)

    def void onDestinationOpen(Destination destination)

    def void onDestinationOpenError(Destination destination, Exception exception)

    def void onHasNext(Source source, Record record, int index)

    def void onHasNextError(Source source, int index, Exception exception)

    def void onNext(Source source, Record record, int index)

    def void onNextError(Source source, int index, Exception exception)

    def void onFilter(Filter filter, Record record, boolean matches, int index)

    def void onFilterError(Filter filter, Record record, int index, Exception exception)

    def void onTransform(Transformer transformer, Record record, Record transformedRecord, int index)

    def void onTransformError(Transformer transformer, Record record, int index, Exception exception)

    def void onPut(Destination destination, Record record, int index)

    def void onPutError(Destination destination, Record record, int index, Exception exception)

    def void onStop(Exception exception, int index)

    def void onSourceClose(Source source, Stats stats)

    def void onSourceCloseError(Source source, Stats stats, Exception exception)

    def void onDestinationClose(Destination destination, Stats stats)

    def void onDestinationCloseError(Destination destination, Stats stats, Exception exception)
}

abstract class BaseCopierListener implements CopierListener {
    val logger = LoggerFactory.getLogger(class)
    
    def onRecursiveError(String context, Exception recursiveException) {
        logger.warn('''Recursive error: «context». Recursive exception: «recursiveException»''', recursiveException)
    }
}

abstract class DefaultCopierListener extends BaseCopierListener {
    override void onSourceOpen(Source source) {}

    override void onSourceOpenError(Source source, Exception exception) {}

    override void onDestinationOpen(Destination destination) {}

    override void onDestinationOpenError(Destination destination, Exception exception) {}

    override void onHasNext(Source source, Record record, int index) {}

    override void onHasNextError(Source source, int index, Exception exception) {}

    override void onNext(Source source, Record record, int index) {}

    override void onNextError(Source source, int index, Exception exception) {}

    override void onFilter(Filter filter, Record record, boolean matches, int index) {}

    override void onFilterError(Filter filter, Record record, int index, Exception exception) {}

    override void onTransform(Transformer transformer, Record record, Record transformedRecord, int index) {}

    override void onTransformError(Transformer transformer, Record record, int index, Exception exception) {}

    override void onPut(Destination destination, Record record, int index) {}

    override void onPutError(Destination destination, Record record, int index, Exception exception) {}

    override void onStop(Exception exception, int index) {}

    override void onSourceClose(Source source, Stats stats) {}

    override void onSourceCloseError(Source source, Stats stats, Exception exception) {}

    override void onDestinationClose(Destination destination, Stats stats) {}

    override void onDestinationCloseError(Destination destination, Stats stats, Exception exception) {}
}

class LoggingCopierListener extends DefaultCopierListener {
    @Accessors boolean verbose = false
    
    static val logger = LoggerFactory.getLogger(LoggingCopierListener)

    override void onSourceOpen(Source source) {
        if (logger.debugEnabled)
            logger.debug('''onSourceOpen(source: «source.class.name»)''')
    }

    override void onSourceOpenError(Source source, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onSourceOpenError(source: «source.class.name», exception: «exception»)''', exception)
    }

    override void onDestinationOpen(Destination destination) {
        if (logger.debugEnabled)
            logger.debug('''onDestinationOpen(destination: «destination.class.name»)''')
    }

    override void onDestinationOpenError(Destination destination, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onDestinationOpenError(destionation: «destination.class.name», exception: «exception»)''', exception)
    }

    override void onHasNext(Source source, Record record, int index) {
        if (verbose && logger.debugEnabled)
            logger.debug('''onHasNext(source: «source.class.name», index: «index», record: «record»)''')
    }
    override void onHasNextError(Source source, int index, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onHasNext(source: «source.class.name», index: «index», exception: «exception»)''', exception)
    }

    override void onNext(Source source, Record record, int index) {
        if (verbose && logger.debugEnabled)
            logger.debug('''onNext(source: «source.class.name», index: «index», record: «record»)''')
    }
    override void onNextError(Source source, int index, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onNextError(source: «source.class.name», index: «index», exception: «exception»)''', exception)
    }

    override void onFilter(Filter filter, Record record, boolean matches, int index) {
        if (verbose && logger.debugEnabled)
            logger.debug('''onFilter(filter: «filter.class.name», index: «index», record: «record»)''')
    }
    override void onFilterError(Filter filter, Record record, int index, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onFilterError(filter: «filter.class.name», exception: «exception», record: «record»)''', exception)
    }

    override void onTransform(Transformer transformer, Record record, Record transformedRecord, int index) {
        if (verbose && logger.debugEnabled)
            logger.debug('''onTransform(transformer: «transformer.class.name», index: «index», transformedRecord: «transformedRecord», record: «record»)''')
    }
    override void onTransformError(Transformer transformer, Record record, int index, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onTransformError(transformer: «transformer.class.name», index: «index», exception: «exception», record:  «record»)''', exception)
    }

    override void onPut(Destination destination, Record record, int index) {
        if (verbose && logger.debugEnabled)
            logger.debug('''onTransform(destination: «destination.class.name», index: «index», record:  «record»)''')
    }
    override void onPutError(Destination destination, Record record, int index, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onPutError(destination: «destination.class.name», exception: «exception», record: «record»)''',
                exception)
    }

    override void onStop(Exception exception, int index) {
        if (logger.warnEnabled)
            logger.warn('''onStop(index: «index», exception: «exception»)''', exception)
    }

    override void onSourceClose(Source source, Stats stats) {
        if (logger.debugEnabled)
            logger.debug('''onSourceClose(source: «source.class.name», «stats»)''')
    }

    override void onSourceCloseError(Source source, Stats stats, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onStop(source: «source.class.name», «stats», exception: «exception»)''', exception)
    }

    override void onDestinationClose(Destination destination, Stats stats) {
        if (logger.debugEnabled)
            logger.debug('''onSourceClose(destination: «destination.class.name», «stats»)''')
    }

    override void onDestinationCloseError(Destination destination, Stats stats, Exception exception) {
        if (logger.warnEnabled)
            logger.warn('''onStop(destination: «destination.class.name», «stats», exception: «exception»)''', exception)
    }
}

class SafeCopierListener extends BaseCopierListener {
    @Accessors CopierListener listener

    override void onSourceOpen(Source source) {
        try {
            listener?.onSourceOpen(source)
        } catch (Exception recursiveException) {
            onRecursiveError('''onSourceOpen(source: «source.class.name», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onSourceOpenError(Source source, Exception exception) {
        try {
            listener?.onSourceOpenError(source, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onSourceOpenError(source: «source.class.name», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onDestinationOpen(Destination destination) {
        try {
            listener?.onDestinationOpen(destination)
        } catch (Exception recursiveException) {
            onRecursiveError('''onDestinationOpen(destination: «destination.class.name», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onDestinationOpenError(Destination destination, Exception exception) {
        try {
            listener?.onDestinationOpenError(destination, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onDestinationOpenError(destination: «destination.class.name», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onHasNext(Source source, Record record, int index) {
        try {
            listener?.onHasNext(source, record, index)
        } catch (Exception recursiveException) {
            onRecursiveError('''onHasNext(source: «source.class.name», index: «index», recursiveException: «recursiveException», record:  «record»)''', recursiveException)
        }
    }
    override void onHasNextError(Source source, int index, Exception exception) {
        try {
            listener?.onHasNextError(source, index, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onHasNextError(source: «source.class.name», index: «index», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onNext(Source source, Record record, int index) {
        try {
            listener?.onNext(source, record, index)
        } catch (Exception recursiveException) {
            onRecursiveError('''onNext(source: «source.class.name», index: «index», recursiveException: «recursiveException», record:  «record»)''', recursiveException)
        }
    }
    override void onNextError(Source source, int index, Exception exception) {
        try {
            listener?.onNextError(source, index, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onNextError(source: «source.class.name», index: «index», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onFilter(Filter filter, Record record, boolean matches, int index) {
        try {
            listener?.onFilter(filter, record, matches, index)
        } catch (Exception recursiveException) {
            onRecursiveError('''onFilter(filter: «filter.class.name», index: «index», recursiveException: «recursiveException», record: «record»)''', recursiveException)
        }
    }
    override void onFilterError(Filter filter, Record record, int index, Exception exception) {
        try {
            listener?.onFilterError(filter, record, index, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onFilterError(filter: «filter.class.name», index: «index», exception: «exception», recursiveException: «recursiveException», record:  «record»)''', recursiveException)
        }
    }

    override void onTransform(Transformer transformer, Record record, Record transformedRecord, int index) {
        try {
            listener?.onTransform(transformer, record, transformedRecord, index)
        } catch (Exception recursiveException) {
            onRecursiveError('''onTransform(transformer: «transformer.class.name», index: «index», recursiveException: «recursiveException», transformedRecord: «transformedRecord», record: «record»)''', recursiveException)
        }
    }
    override void onTransformError(Transformer transformer, Record record, int index, Exception exception) {
        try {
            listener?.onTransformError(transformer, record, index, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onTransformError(transformer: «transformer.class.name», index: «index», exception: «exception», recursiveException: «recursiveException», record: «record»)''', recursiveException)
        }
    }

    override void onPut(Destination destination, Record record, int index) {
        try {
            listener?.onPut(destination, record, index)
        } catch (Exception recursiveException) {
            onRecursiveError('''onPut(destination: «destination.class.name», index: «index», recursiveException: «recursiveException», record: «record»)''', recursiveException)
        }
    }
    override void onPutError(Destination destination, Record record, int index, Exception exception) {
        try {
            listener?.onPutError(destination, record, index, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onPutError(destination: «destination.class.name», index: «index», exception: «exception», recursiveException: «recursiveException», record: «record»)''', recursiveException)
        }
    }

    override void onStop(Exception exception, int index) {
        try {
            listener?.onStop(exception, index)
        } catch (Exception recursiveException) {
            onRecursiveError('''onStop(index: «index», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onSourceClose(Source source, Stats stats) {
        try {
            listener?.onSourceClose(source, stats)
        } catch (Exception recursiveException) {
            onRecursiveError('''onSourceClose(source: «source.class.name», «stats», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onSourceCloseError(Source source, Stats stats, Exception exception) {
        try {
            listener?.onSourceCloseError(source, stats, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onSourceCloseError(source: «source.class.name», «stats», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onDestinationClose(Destination destination, Stats stats) {
        try {
            listener?.onDestinationClose(destination, stats)
        } catch (Exception recursiveException) {
            onRecursiveError('''onDestinationClose(destination: «destination.class.name», «stats», recursiveException: «recursiveException»)''', recursiveException)
        }
    }

    override void onDestinationCloseError(Destination destination, Stats stats, Exception exception) {
        try {
            listener?.onDestinationCloseError(destination, stats, exception)
        } catch (Exception recursiveException) {
            onRecursiveError('''onDestinationCloseError(destination: «destination.class.name», «stats», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
        }
    }
}

class MultiCopierListener extends BaseCopierListener {
    @Accessors List<? extends CopierListener> listeners

    new() {}

    new(List<? extends CopierListener> listeners) {
        this.listeners = listeners
    }

    override void onSourceOpen(Source source) {
        listeners?.forEach [ listener |
            try {
                listener?.onSourceOpen(source)
            } catch (Exception recursiveException) {
                onRecursiveError('''onSourceOpen(source: «source.class.name», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onSourceOpenError(Source source, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onSourceOpenError(source, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onSourceOpenError(source: «source.class.name», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onDestinationOpen(Destination destination) {
        listeners?.forEach [ listener |
            try {
                listener?.onDestinationOpen(destination)
            } catch (Exception recursiveException) {
                onRecursiveError('''onDestinationOpen(destination: «destination.class.name», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onDestinationOpenError(Destination destination, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onDestinationOpenError(destination, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onDestinationOpenError(destination: «destination.class.name», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onHasNext(Source source, Record record, int index) {
        listeners?.forEach [ listener |
            try {
                listener?.onHasNext(source, record, index)
            } catch (Exception recursiveException) {
                onRecursiveError('''onHasNext(source: «source.class.name», index: «index», recursiveException: «recursiveException», record: «record»)''', recursiveException)
            }
        ]
    }
    override void onHasNextError(Source source, int index, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onHasNextError(source, index, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onHasNextError(source: «source.class.name», index: «index», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onNext(Source source, Record record, int index) {
        listeners?.forEach [ listener |
            try {
                listener?.onNext(source, record, index)
            } catch (Exception recursiveException) {
                onRecursiveError('''onNext(source: «source.class.name», index: «index», recursiveException: «recursiveException», record: «record»)''', recursiveException)
            }
        ]
    }
    override void onNextError(Source source, int index, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onNextError(source, index, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onNextError(source: «source.class.name», index: «index», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onFilter(Filter filter, Record record, boolean matches, int index) {
        listeners?.forEach [ listener |
            try {
                listener?.onFilter(filter, record, matches, index)
            } catch (Exception recursiveException) {
                onRecursiveError('''onFilter(filter: «filter.class.name», index: «index», recursiveException: «recursiveException», record: «record»)''', recursiveException)
            }
        ]
    }
    override void onFilterError(Filter filter, Record record, int index, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onFilterError(filter, record, index, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onFilterError(filter: «filter.class.name», index: «index», exception: «exception», recursiveException: «recursiveException», record: «record»)''', recursiveException)
            }
        ]
    }

    override void onTransform(Transformer transformer, Record record, Record transformedRecord, int index) {
        listeners?.forEach [ listener |
            try {
                listener?.onTransform(transformer, record, transformedRecord, index)
            } catch (Exception recursiveException) {
                onRecursiveError('''onTransform(transformer: «transformer.class.name», index: «index», recursiveException: «recursiveException», transformedRecord: «transformedRecord», record: «record»)''', recursiveException)
            }
        ]
    }
    override void onTransformError(Transformer transformer, Record record, int index, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onTransformError(transformer, record, index, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onTransformError(transformer: «transformer.class.name», index: «index», exception: «exception», recursiveException: «recursiveException», record: «record»)''', recursiveException)
            }
        ]
    }

    override void onPut(Destination destination, Record record, int index) {
        listeners?.forEach [ listener |
            try {
                listener?.onPut(destination, record, index)
            } catch (Exception recursiveException) {
                onRecursiveError('''onPut(destination: «destination.class.name», index: «index», recursiveException: «recursiveException», record: «record»)''', recursiveException)
            }
        ]
    }
    override void onPutError(Destination destination, Record record, int index, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onPutError(destination, record, index, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onPutError(destination: «destination.class.name», index: «index», exception: «exception», recursiveException: «recursiveException», record: «record»)''', recursiveException)
            }
        ]
    }

    override void onStop(Exception exception, int index) {
        listeners?.forEach [ listener |
            try {
                listener?.onStop(exception, index)
            } catch (Exception recursiveException) {
                onRecursiveError('''onStop(index: «index», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onSourceClose(Source source, Stats stats) {
        listeners?.forEach [ listener |
            try {
                listener?.onSourceClose(source, stats)
            } catch (Exception recursiveException) {
                onRecursiveError('''onSourceClose(source: «source.class.name», «stats», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onSourceCloseError(Source source, Stats stats, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onSourceCloseError(source, stats, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onSourceCloseError(source: «source.class.name», «stats», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onDestinationClose(Destination destination, Stats stats) {
        listeners?.forEach [ listener |
            try {
                listener?.onDestinationClose(destination, stats)
            } catch (Exception recursiveException) {
                onRecursiveError('''onDestinationClose(destination: «destination.class.name», «stats», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }

    override void onDestinationCloseError(Destination destination, Stats stats, Exception exception) {
        listeners?.forEach [ listener |
            try {
                listener?.onDestinationCloseError(destination, stats, exception)
            } catch (Exception recursiveException) {
                onRecursiveError('''onDestinationCloseError(destination: «destination.class.name», «stats», exception: «exception», recursiveException: «recursiveException»)''', recursiveException)
            }
        ]
    }
}
