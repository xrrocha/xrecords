package net.xrrocha.xrecords.csv

import au.com.bytecode.opencsv.CSVWriter
import java.util.List
import net.xrrocha.xrecords.validation.Validatable
import org.eclipse.xtend.lib.annotations.Accessors

abstract class CSVBase implements Validatable {
  @Accessors char separator = ','
  @Accessors boolean headerRecord = false
  @Accessors char quote = CSVWriter.NO_QUOTE_CHARACTER

  override validate(List<String> errors) {
    if(separator == 0) {
      errors.add('Invalid zero separator')
    }
  }
}