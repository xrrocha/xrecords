package xrrocha.xrecords.field

class Field {
    @Property String name
}

class FormattedField<T> extends Field {
    @Property Parser<T> format
    
    def parse(String s) {
        getFormat.parse(s)
    }
    
    def format(T t) {
        getFormat.format(t)
    }
}

class FixedField<T> extends FormattedField<T> {
    @Property int offset
    @Property int length
    
    def get(char[] chars) {
        parse(new String(chars, offset, length))
    }
    
    def put(T t, char[] chars) {
        val parsedChars = format(t).toCharArray
        if (parsedChars.length > length) {
            throw new IllegalArgumentException('''Formatted length («parsedChars.length» exceeds configured field length («length»)''')
        }
        System.arraycopy(parsedChars, 0, chars, offset, Math.min(length, parsedChars.length))
    }
}
