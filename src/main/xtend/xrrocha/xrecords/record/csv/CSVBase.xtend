package xrrocha.xrecords.record.csv

import au.com.bytecode.opencsv.CSVWriter

abstract class CSVBase {
    @Property char separator = '\t'
    @Property boolean headerRecord = false
    @Property char quote = CSVWriter.NO_QUOTE_CHARACTER
}