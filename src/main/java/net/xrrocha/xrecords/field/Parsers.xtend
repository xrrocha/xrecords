package net.xrrocha.xrecords.field

import java.math.BigDecimal
import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

interface Parser<T> {
    def T parse(String string)
    def String format(T item)    
}

class BooleanParser implements Parser<Boolean> {
    @Accessors String trueRepresentation = 'true'
    @Accessors String falseRepresentation = 'false'
    @Accessors Map<String, Boolean> representations = #{
        'true'  -> true,
        'false' -> false,
        'yes'   -> true,
        'no'    -> false,
        'on'    -> true,
        'off'   -> false
    }
    
    override parse(String string) {
        try {
            representations.get(string.toLowerCase).booleanValue
        } catch (NullPointerException npe) {
            throw new IllegalArgumentException('''Invalid boolean value: «string»''')
        }
    }
    
    override format(Boolean item) {
        if (item) trueRepresentation
        else falseRepresentation    
    }
}

abstract class NumericParser<N extends Number> {
    protected val DecimalFormat format
    
    abstract def void configureFormat(DecimalFormat format)
    
    new(String pattern) {
        this(pattern, 1)
    }
    
    new(String pattern, int multiplier) {
        format = new DecimalFormat(pattern)
        format.multiplier = multiplier
        configureFormat(format)
    }

    def N parse(String string) {
        cast(format.parse(string))
    }
    
    def String format(N value) {
        format.format(value)
    }
    
    def N cast(Number value) {
        value as N
    }
}

class IntegerParser extends NumericParser<Integer> implements Parser<Integer> {
    new() { super('##########') }
    new(String pattern) { super(pattern) }
    new(String pattern, int multiplier) { super(pattern, multiplier) }
    
    override configureFormat(DecimalFormat format) {
        format => [
            parseIntegerOnly = true
            parseBigDecimal = false
        ]
    }
    override cast(Number value) { value.intValue }
}

class DoubleParser extends NumericParser<Double> implements Parser<Double> {
    new() { super('############.##') }
    new(String pattern) { super(pattern) }
    new(String pattern, int multiplier) { super(pattern, multiplier) }
    
    override configureFormat(DecimalFormat format) {
        format => [
            parseIntegerOnly = false
            parseBigDecimal = false
        ]
    }
    override cast(Number value) { value.doubleValue }
}

class BigDecimalParser extends NumericParser<BigDecimal> implements Parser<BigDecimal> {
    new() { super('############.##') }
    new(String pattern) { super(pattern) }
    new(String pattern, int multiplier) { super(pattern, multiplier) }
    
    override configureFormat(DecimalFormat format) {
        format => [
            parseIntegerOnly = false
            parseBigDecimal = true
        ]
    }
}

class DateParser implements Parser<Date> {
    val SimpleDateFormat format
    
    new() {
        this('dd/MM/yyyy')
    }
    
    new(String pattern) {
        format = new SimpleDateFormat(pattern)
    }

    override Date parse(String string) {
        format.parse(string)
    }
    
    override String format(Date value) {
        format.format(value)
    }
}

class StringParser implements Parser<String> {
    new() {}
    
    new(String pattern) {
    }

    override String parse(String string) {
        string
    }
    
    override String format(String string) {
        string
    }
}
