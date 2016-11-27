package net.xrrocha.xrecords.util

/**
 * A producer of objects that will  return a new, different instance on each
 * `provide()` invocation.
 *
 * A typical example is an `InputStream` provider that will repeatedly open
 * the same file on each invocation or an FTP client that will open a new
 * connection to the same remote file.
 *
 * @param <T> The type of the object being created on each `provide()`
 * invocation.
*/
interface Provider<T> {
  /**
   * Create a new, fresh instance of type `T`.
   *
   * @return The newly created <T> instance
  */
  def T provide()
}
