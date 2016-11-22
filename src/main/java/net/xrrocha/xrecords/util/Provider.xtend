package net.xrrocha.xrecords.util

interface Provider<T> {
  def T provide()
}
