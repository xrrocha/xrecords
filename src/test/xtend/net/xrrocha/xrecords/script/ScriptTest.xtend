package net.xrrocha.xrecords.script

import java.util.List
import java.util.Map
import net.xrrocha.xrecords.Record
import org.junit.Test

import static org.junit.Assert.*

class ScriptTest {
    @Test
    def void runsScript() {
        val Map<String, ?extends Object> scriptBindings = #{ 'lower' -> 0}
        val Map<String, ?extends Object> executionBindings = #{ 'upper' -> 42}
        val script = new Script('lower < upper', scriptBindings)
        assertTrue(script.execute(executionBindings) as Boolean)
    }

    @Test
    def void validatesAll() {
        val script = new Script => [
            script = null
            language = 'nonExistent'
        ]
        val List<String> errors = newLinkedList
        script.validate(errors)
        assertTrue(errors.size == 2)
    }
    
    @Test
    def void matches() {
        val script = new ScriptingCopierComponent => [
            script = 'id > 0'
            language = 'javascript'
        ]
        val record = new Record => [
            setField('id', 123)
        ]
        assertTrue(script.matches(record))
    }
    
    @Test
    def void transforms() {
        val script = new ScriptingCopierComponent => [
            script = '({code: id * 2})'
            language = 'javascript'
        ]

        val inputRecord = new Record => [
            setField('id', 123d)
        ]

        val expectedRecord = new Record => [
            setField('code', 246d)
        ]

        val actualRecord = script.transform(inputRecord)
        assertEquals(expectedRecord, actualRecord)
    }
}