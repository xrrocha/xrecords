package net.xrrocha.xrecords.field

import java.util.List
import net.xrrocha.xrecords.record.Record
import net.xrrocha.xrecords.validation.Validatable

import static extension net.xrrocha.xrecords.util.Extensions.*

// Add suport for array fields
class Field implements Validatable {
    @Property String name
    
    override validate(List<String> errors) {
        if (name == null || name.trim.length == 0) {
            errors.add('Missing field name')
        }
    }
    
    static def validateFields(List<?extends Field> fields, List<String> errors) {
        if (fields == null) {
            errors.add('Missing fields')
        } else {
            val duplicateNames = fields.groupBy[name].filter[n, f | f.size > 1].keySet
            if (duplicateNames.size > 0) {
                errors.add('''Duplicate field name(s): «duplicateNames.toList.sort.join(', ')»''')
            }

            for (i: 0..< fields.size) {
                if (fields.get(i) == null) {
                    errors.add('''Missing field «i»''')
                } else {
                    fields.get(i).validate(errors)
                }
            }
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

// TODO Fixed fields must specify implicit decimal position
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
