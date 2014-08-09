package net.xrrocha.xrecords.field

import java.math.BigDecimal
import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.Date

interface Parser<T> {
    def T parse(String string)
    def String format(T item)    
}

class IntegerParser implements Parser<Integer> {
    val DecimalFormat format
    
    new() {
        this('############')
    }
    
    new(String pattern) {
        format = new DecimalFormat(pattern) => [
            parseIntegerOnly = true
            parseBigDecimal = false
        ]
    }

    override Integer parse(String string) {
        format.parse(string).intValue
    }
    
    override String format(Integer value) {
        format.format(value)
    }
}

class DoubleParser implements Parser<Double> {
    val DecimalFormat format
    
    new() {
        this('############.##')
    }
    
    new(String pattern) {
        format = new DecimalFormat(pattern) => [
            parseIntegerOnly = false
            parseBigDecimal = false
        ]
    }

    override Double parse(String string) {
        format.parse(string).doubleValue
    }
    
    override String format(Double value) {
        format.format(value)
    }
}

class BigDecimalParser implements Parser<BigDecimal> {
    val DecimalFormat format
    
    new() {
        this('############.##')
    }
    
    new(String pattern) {
        format = new DecimalFormat(pattern) => [
            parseIntegerOnly = false
            parseBigDecimal = true
        ]
    }

    override BigDecimal parse(String string) {
        format.parse(string) as BigDecimal
    }
    
    override String format(BigDecimal value) {
        format.format(value)
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
    new() {
    }
    
    new(String pattern) {
    }

    override String parse(String string) {
        string
    }
    
    override String format(String string) {
        string
    }
}
