package net.xrrocha.xrecords.record

import java.util.Map
import net.xrrocha.xrecords.copier.Transformer
import org.eclipse.xtend.lib.annotations.Accessors

// TODO Validate and test FieldRenamingTransformer
class FieldRenamingTransformer implements Transformer<Record> {
    @Accessors Map<String, String> renames
    
    override transform(Record in) {
        val out = new Record
        renames.forEach [ sourceName, destinationName |
            out.setField(destinationName, in.getField(sourceName))
        ]
        out
    }
}