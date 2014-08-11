package net.xrrocha.xrecords.record

import java.util.Map
import net.xrrocha.xrecords.copier.Transformer

class FieldRenamingTransformer implements Transformer<Record> {
    @Property Map<String, String> renames
    
    override transform(Record in) {
        val out = new Record
        renames.forEach [ sourceName, destinationName |
            out.setField(destinationName, in.getField(sourceName))
        ]
        out
    }
}