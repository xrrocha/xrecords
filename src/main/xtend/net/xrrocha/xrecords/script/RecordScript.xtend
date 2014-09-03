package net.xrrocha.xrecords.script

import java.util.Map
import net.xrrocha.xrecords.Record

abstract class RecordScript extends Script {
    new() {}

    new(String script) {
        super(script)
    }

    new(String language, String script) {
        super(language, script, newHashMap)
    }

    new(String script, Map<String, ? extends Object> environment) {
        super(script, environment)
    }

    def execute(Record record) {
        val scriptRecord = new Record => [
            copyFrom(record)
        ]
        super.execute(scriptRecord.toMap)
    }
}
