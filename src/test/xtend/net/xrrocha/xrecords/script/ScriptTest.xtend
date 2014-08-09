package net.xrrocha.xrecords.script

import java.util.List
import java.util.Map
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
}