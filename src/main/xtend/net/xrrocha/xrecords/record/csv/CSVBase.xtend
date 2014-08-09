package net.xrrocha.xrecords.record.csv

import au.com.bytecode.opencsv.CSVWriter
import java.util.List
import net.xrrocha.xrecords.validation.Validatable

abstract class CSVBase implements Validatable {
    @Property char separator = '\t'
    @Property boolean headerRecord = false
    @Property char quote = CSVWriter.NO_QUOTE_CHARACTER

    override validate(List<String> errors) {
        if (separator == 0) {
            errors.add('Invalid zero separator')
        }
        if (quote == 0) {
            errors.add('Invalid zero quote')
        }
    }
}