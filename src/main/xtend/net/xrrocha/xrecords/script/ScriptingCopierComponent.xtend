package net.xrrocha.xrecords.script

import java.util.Map
import net.xrrocha.xrecords.copier.Matcher
import net.xrrocha.xrecords.copier.Transformer
import net.xrrocha.xrecords.record.Record

class ScriptingCopierComponent extends Script implements Matcher<Record>, Transformer<Record> {
    new() {
    }

    new(String script) {
        super(script)
    }

    new(String language, String script) {
        super(language, script, newHashMap)
    }

    new(String script, Map<String, ? extends Object> environment) {
        super(script, environment)
    }

    override matches(Record record) {
        val result = super.execute(record.toMap)

        switch (result) {
            Boolean:
                result
            default:
                throw new IllegalArgumentException('''Expected boolean, got: «result»''')
        }
    }

    override transform(Record record) {
        val result = super.execute(record.toMap)

        switch (result) {
            Record:
                result
            Map<?, ?>:
                new Record => [
                    result.forEach[n, v|setField(n.toString, v)]
                ]
            default:
                throw new IllegalArgumentException('''Don't know how to build record from «result»''')
        }
    }

}
