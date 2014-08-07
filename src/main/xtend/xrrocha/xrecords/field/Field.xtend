package xrrocha.xrecords.field

import java.util.List
import xrrocha.xrecords.record.Record
import xrrocha.xrecords.validation.Validatable

class Field implements Validatable {
    @Property String name
    
    override validate(List<String> errors) {
        if (name == null || name.trim.length == 0) {
            errors.add('Missing field name')
        }
    }
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
    
    override validate(List<String> errors) {
        super.validate(errors)
        if (format == null) {
            errors.add('Missing field format')
        }
    }
}

class IndexedField<T> extends FormattedField<T> {
    @Property int index
    
    def getValueFrom(List<String> list) {
        fromString(list.get(index))
    }
    
    override validate(List<String> errors) {
        super.validate(errors)
        if (index < 0) {
            errors.add('Negative index in field')
        }
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
    
    override validate(List<String> errors) {
        super.validate(errors)
        if (offset < 0) {
            errors.add('Negative offset in field')
        }
        if (length <= 0) {
            errors.add('Negative or zero length in field')
        }
    }
}
