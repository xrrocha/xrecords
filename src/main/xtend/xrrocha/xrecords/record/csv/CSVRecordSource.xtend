package xrrocha.xrecords.record.csv

import au.com.bytecode.opencsv.CSVReader
import java.io.Reader
import java.util.List
import xrrocha.xrecords.copier.Source
import xrrocha.xrecords.field.IndexedField
import xrrocha.xrecords.record.Record
import xrrocha.xrecords.util.Provider

class CSVRecordSource extends CSVBase implements Source<Record> {
    @Property Provider<Reader> input
    // TODO Validate field name and index uniqueness in fields
    @Property List<IndexedField<Object>> fields
    
    private CSVReader reader
    private String[] fieldValues
    
    override open() {
        val lineCount = if (headerRecord) 1 else 0
        reader = new CSVReader(input.provide, separator, quote, lineCount)
    }

    override hasNext() {
        fieldValues = reader.readNext()
        fieldValues != null
    }

    override next() {
        val record = new Record

        fields.forEach [ field |
            val value = field.getValueFrom(fieldValues)
            record.setField(field.name, value)
        ]

        record
    }

    override close(int count) {
        reader.close()
    }

    override validate(List<String> errors) {
        super.validate(errors)
        if (input == null) {
            errors.add('Missing input')
        }
        if (fields == null) {
            errors.add('Missing fields')
        } else {
            for (i: 0..< fields.size) {
                if (fields.get(i) == null) {
                    errors.add('''Missing field «i»''')
                } else {
                    fields.get(i).validate(errors)
                }
            }
        }
    }

    override remove() {
        throw new UnsupportedOperationException('CSVRecordSource.remove: unimplemented')
    }
}