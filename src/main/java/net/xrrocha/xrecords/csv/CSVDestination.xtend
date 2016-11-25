package net.xrrocha.xrecords.csv

import au.com.bytecode.opencsv.CSVWriter
import java.io.Writer
import java.util.List
import net.xrrocha.xrecords.AbstractDestination
import net.xrrocha.xrecords.Destination
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.field.Field
import net.xrrocha.xrecords.field.FormattedField
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate

class CSVDestination extends CSVBase implements Destination {
  @Accessors Provider<Writer> output
  @Accessors List<FormattedField<?extends Object>> fields

  @Delegate Destination delegate = new AbstractDestination<CSVWriter> {
    override doOpen() {
      val writer = new CSVWriter(output.provide, separator, quote)

      if(headerRecord) {
        val String[] headers = newArrayOfSize(fields.size)
        (0 ..< fields.size).forEach [ i |
          headers.set(i, fields.get(i).name)
        ]
        writer.writeNext(headers);
      }

      writer
    }

    override doPut(CSVWriter writer, Record record) {
      val String[] recordValues = newArrayOfSize(fields.size)

      (0 ..< fields.size).forEach [ i |
        recordValues.set(i, fields.get(i).formatValueFrom(record))
      ]

      writer.writeNext(recordValues)
    }

    override doClose(CSVWriter writer) {
      writer.close()
    }
  }

  override validate(List<String> errors) {
    super.validate(errors)
    if(output == null) {
      errors.add('Missing output')
    }
    Field.validateFields(fields, errors)
  }
}