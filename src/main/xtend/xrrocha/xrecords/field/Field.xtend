package xrrocha.xrecords.field

import java.util.List
import xrrocha.xrecords.record.Record

class Field {
    @Property String name
}

class FormattedField<T> extends Field {
    @Property Parser<T> format
    
    def fromString(String s) {
        format.parse(s)
    }
    
    def toString(T t) {
        format.format(t)
    }
    
    // TODO Test formatValueFrom
    def formatValueFrom(Record record) {
        val value = record.getField(name) as T
        if (value == null) ""
        else toString(value)
    }
}

class IndexedField<T> extends FormattedField<T> {
    @Property int index
    
    def getValueFrom(List<String> list) {
        fromString(list.get(index))
    }
}

class FixedField<T> extends FormattedField<T> {
    @Property int offset
    @Property int length
    
    def get(char[] chars) {
        fromString(new String(chars, offset, length))
    }
    
    def put(T t, char[] chars) {
        val parsedChars = toString(t).toCharArray
        if (parsedChars.length > length) {
            throw new IllegalArgumentException('''Formatted length («parsedChars.length» exceeds configured field length («length»)''')
        }
        System.arraycopy(parsedChars, 0, chars, offset, Math.min(length, parsedChars.length))
    }
}
