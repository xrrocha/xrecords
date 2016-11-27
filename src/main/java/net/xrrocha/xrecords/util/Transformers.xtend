package net.xrrocha.xrecords.util

import java.util.Map
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Transformer
import org.eclipse.xtend.lib.annotations.Accessors

class FieldRenamingTransformer implements Transformer {
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
}
