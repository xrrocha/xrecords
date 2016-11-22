package net.xrrocha.xrecords.util

import java.util.List
import java.util.Map
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Transformer
import net.xrrocha.xrecords.validation.Validatable
import org.eclipse.xtend.lib.annotations.Accessors

class FieldRenamingTransformer implements Transformer, Validatable {
  @Accessors Map<String, String> renames
  @Accessors boolean preserveOthers = true

  override transform(Record in) {
    val out = new Record

    if(preserveOthers) {
      in.fieldNames.
      filter[!renames.containsKey(it)].
      forEach [ fieldName |
        out.setField(fieldName, in.getField(fieldName))
      ]
    }

    renames.forEach [ sourceName, destinationName |
      out.setField(destinationName, in.getField(sourceName))
    ]

    out
  }

  override validate(List<String> errors) {
    if(renames == null) {
      errors.add('Missing renames')
    }
  }
}
