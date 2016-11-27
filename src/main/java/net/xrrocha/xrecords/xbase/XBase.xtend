package net.xrrocha.xrecords.xbase

abstract class XBase {
  private static val BYTES = 'CNDLD'.bytes

  public static val CHARACTER = BYTES.get(0)
  public static val NUMERIC = BYTES.get(1)
  public static val DOUBLE = BYTES.get(2)
  public static val LOGICAL = BYTES.get(3)
  public static val DATE = BYTES.get(4)
}