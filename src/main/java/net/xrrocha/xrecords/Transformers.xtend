package net.xrrocha.xrecords

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * A general `Transformer` that changes the name of one or more fields in a
 * given `Record`. Unrenamed fields may be retained by configuring the
 * `preserveOthers` flag. Unless `preserveOthers` is set to `false`, unrenamed
  * field will be preserved in the resulting `Record`
*/
class FieldRenamingTransformer implements Transformer {
  /**
   * The `Map` of fields in the input `Record` that must be renamed in the
   * output one.
  */
  @Accessors Map<String, String> renames

  /**
   * Whether to preserve or remove fields not included in the `renames` map.
  */
  @Accessors boolean preserveOthers = true

  /**
   * Empty constructor. `preserveOthers` flags defaults to `true`.
   */
  new() {
  }

  /**
   * Constructor specifying `preserveOthers` flag.
   */
  new(boolean preserveOthers) {
    this.preserveOthers = preserveOthers
  }


  /**
   * Transform a `Record` into another according the `renames` mapping.
   * Fields not present in `renames` will be normally preserved unless the
   * `preserveOthers` flag is set to false.
   *
   * @param in The inputg `Record`
   *
   * @return The new `Record` with renamed and preserved/removed fields.
  */
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
