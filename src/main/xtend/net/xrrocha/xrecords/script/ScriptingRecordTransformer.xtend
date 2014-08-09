package net.xrrocha.xrecords.script

import java.util.Map
import net.xrrocha.xrecords.copier.Transformer
import net.xrrocha.xrecords.record.Record
import sun.org.mozilla.javascript.NativeObject

class ScriptingRecordTransformer extends Script implements Transformer<Record> {
    override transform(Record record) {
        val result = super.execute(record.toMap)

        switch (result) {
            Record: result
            NativeObject: {
                val newRecord = new Record
                result.ids.forEach[
                    newRecord.setField(it.toString, result.get(it))
                ]
                newRecord
            }
            Map<?, ?>: new Record => [
                result.forEach[n, v| setField(n.toString, v)]
            ]
            default:
                throw new IllegalArgumentException('''Don't know how to build record from «result»''')
        }
    }
}