package net.xrrocha.xrecords.csv

import au.com.bytecode.opencsv.CSVReader
import java.io.Reader
import java.util.List
import net.xrrocha.xrecords.AbstractSource
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Source
import net.xrrocha.xrecords.Stats
import net.xrrocha.xrecords.field.Field
import net.xrrocha.xrecords.field.IndexedField
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate

class CSVSource extends CSVBase implements Source {
  @Accessors Provider<Reader> input
  @Accessors List<IndexedField<?extends Object>> fields

  @Delegate Source delegate = new AbstractSource<CSVReader, String[]>() {
    override doOpen() {
      val lineCount = if(headerRecord) 1 else 0
      new CSVReader(input.provide, separator, quote, lineCount)
    }

    override next(CSVReader reader) {
      reader.readNext()
    }

    override buildRecord(String[] fieldValues) {
      val record = new Record

      fields.forEach [ field |
        val value = field.getValueFrom(fieldValues)
        record.setField(field.name, value)
      ]

      record
    }

    override doClose(CSVReader reader, Stats stats) {
      reader.close()
    }
  }

  override validate(List<String> errors) {
    super.validate(errors)
    if(input == null) {
      errors.add('Missing input')
    }
    Field.validateFields(fields, errors)
  }
}