package net.xrrocha.xrecords.script

import org.junit.Test

class ScriptTest {
    @Test
    def void runsScript() {
        val script = new Script('print("Hello world")')
        script.execute
    }
}