package net.xrrocha.xrecords.field

import java.util.List
import net.xrrocha.xrecords.Record
import org.eclipse.xtend.lib.annotations.Accessors

class Field {
  @Accessors String name
}

class FormattedField<T> extends Field {
  @Accessors Parser<T> parser

  def fromString(String s) {
    parser.parse(s)
  }

  def toString(T t) {
    parser.format(t)
  }

  def formatValueFrom(Record record) {
    val value = record.getField(name) as T
    if(value == null) ''
    else toString(value)
  }
}

class IndexedField<T> extends FormattedField<T> {
  @Accessors int index

  def getValueFrom(List<String> list) {
    fromString(list.get(index))
  }
}

class FixedField<T> extends FormattedField<T> {
  @Accessors int offset
  @Accessors int length

  def get(char[] chars) {
    fromString(new String(chars, offset, length))
  }

  def put(T t, char[] chars) {
    val parsedChars = toString(t).toCharArray
    if(parsedChars.length > length) {
      throw new IllegalArgumentException('''Formatted length («parsedChars.length» exceeds configured field length («length»)''')
    }
    System.arraycopy(parsedChars, 0, chars, offset, Math.min(length, parsedChars.length))
  }
}
