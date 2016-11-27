package net.xrrocha.xrecords.csv

import au.com.bytecode.opencsv.CSVWriter
import org.eclipse.xtend.lib.annotations.Accessors

abstract class CSVBase {
  @Accessors char separator = ','
  @Accessors boolean headerRecord = false
  @Accessors char quote = CSVWriter.NO_QUOTE_CHARACTER
}