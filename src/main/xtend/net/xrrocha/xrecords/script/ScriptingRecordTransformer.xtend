package net.xrrocha.xrecords.script

import java.util.Map
import net.xrrocha.xrecords.copier.Transformer
import net.xrrocha.xrecords.record.Record

class ScriptingRecordTransformer extends Script implements Transformer<Record> {
    new() {}
    
    new(String script) {
        super(script)
    }
    
    new(String language, String script) {
        super(language, script, newHashMap)
    }
    
    new(String script, Map<String, ?extends Object> environment) {
        super(script, environment)
    }

    override transform(Record record) {
        val result = super.execute(record.toMap)

        switch (result) {
            Record: result
            Map<?, ?>: new Record => [
                result.forEach[n, v| setField(n.toString, v)]
            ]
            default:
                throw new IllegalArgumentException('''Don't know how to build record from «result»''')
        }
    }
}

/*
import sun.org.mozilla.javascript.NativeObject
NativeObject: {
    val newRecord = new Record
    result.ids.forEach [
        newRecord.setField(it.toString, result.get(it))
    ]
    newRecord
}
 */