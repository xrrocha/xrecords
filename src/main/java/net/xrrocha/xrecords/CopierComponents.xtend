package net.xrrocha.xrecords

abstract class AbstractLifecycle<S> implements Lifecycle {
    protected var S state

    protected abstract def S doOpen()

    protected abstract def void doClose(S state, Stats stats)

    final override open() {
        state = doOpen()
    }

    final override close(Stats stats) {
        doClose(state, stats)
    }
}

abstract class AbstractSource<S, R> extends AbstractLifecycle<S> implements Source {
    abstract def R next(S state)

    abstract def Record buildRecord(R representation)

    private var R previous = null
    private var boolean requested = false

    final override hasNext() {
        if (!requested) {
            previous = next(state)
        }
        requested = true
        previous != null
    }

    final override next() {
        requested = false
        buildRecord(previous)
    }

    final override remove() {
        throw new UnsupportedOperationException('Source.remove(): unimplemented')
    }
}

abstract class AbstractDestination<S> extends AbstractLifecycle<S> implements Destination {
    abstract def void doPut(S state, Record record)

    final override put(Record record) {
        doPut(state, record)
    }
}
