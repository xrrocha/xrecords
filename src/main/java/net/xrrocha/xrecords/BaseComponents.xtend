package net.xrrocha.xrecords

// Base classes for Lifecycle, Source and Destination


/**
 * Base class to implement `Lifecycle` by having subclasses return a state
 * associated with their internal resources opun opening as well as dispose
 * of such statre upon closing.
 *
 * @param <S> The resource state kept on behalf of the extending class
*/
abstract class AbstractLifecycle<S> implements Lifecycle {
  /**
   * The subclass-accessible resource state
  */
  protected var S state

  /**
   * Open resources and return their associated state.
   * @return The state embodying the component's resources
  */
  protected abstract def S doOpen()

  /**
   * Close resources embodied in the given state.
   *
   * @param state The state originally returned by `doOpen()`
  */
  protected abstract def void doClose(S state)

  /**
   * Open the source or destination and store the returned resource state.
  */
  final override open() {
    state = doOpen()
  }

  /**
   * Close the source or destination disposing of its resource state.
  */
  final override close() {
    doClose(state)
  }
}

/**
 * Base classs extending `AbstractLifecycle` and implementing `Source`
 * (in its `Iterator<Record>` aspect). This class relieves concrete subclasses
 * from keeping track of current/next elements. In return, subclasses must
 * provide:
 *
 * - A way to retrieve the next "raw" (i. e., non-record) element. An example
 * of a "raw" input element is the next line in a CSV file or an open JDBC
 * `ResultSet`.
 * - A way to build a `Record` from the current input element An example of
 * this is the selection of positional, named fields in a CSV line or the use
 * of JDBC's '`RecordSetMetaData` and `RecordSet`.
 *
*/
abstract class AbstractSource<S, R> extends AbstractLifecycle<S>
implements Source
{
  /**
   * Return the next input elemet given the component's resource state.
   *
   * @param state The state originally returned upon opening this component.
   *
   * @return The next input element.
  */
  abstract def R next(S state)

  /**
   * Convert the current input element to a `Record` representation.
   *
   * @param inputElement The element to be represented as a `Record`
   *
   * @return The resulting `Record`
  */
  abstract def Record buildRecord(R inputElement)

  /**
   * The last input element returned by the concrete subclass.
  */
  private var R previous = null

  /**
   * Whether the current element has already been requested or not.
  */
  private var boolean requested = false

  /**
   * Determine whether there are more results to be returned (as per the
   * `Iterator Record>` contract)
   *
   * @return Whether there is an element to be returned by `next()`.
  */
  final override hasNext() {
    if(!requested) {
      previous = next(state)
    }
    requested = true
    previous != null
  }

  /**
   * Return the next `Record` as per the `Iterator<Record>` contract.
   *
   * @return The next `Record` to be processed
   */
  final override next() {
    requested = false
    buildRecord(previous)
  }

  /**
   * Remove the current `Record`. This method is left unimplemented.
  */
  final override remove() {
    throw new UnsupportedOperationException('Source.remove(): unimplemented')
  }
}

/**
 * Base classs extending `AbstractLifecycle` and implementing `Destination`.
 * This class relieves concrete subclasses from keeping tack of their resource
 * states by adding the current state to the current record during `put()`. *
*/
abstract class AbstractDestination<S> extends AbstractLifecycle<S>
implements Destination
{
  /**
   * Actually put the given `record` onto the current `state`
   *
   * @param state The current resource state originally returned on `open()`
   * @param record The `Record` to be put into the destination
  */
  abstract def void doPut(S state, Record record)

  /**
   * Implement `Destination` by forcing concrete subclasses to perform actual
   * record consumption through method `doPut(S, Record)`.
  */
  final override put(Record record) {
    doPut(state, record)
  }
}
