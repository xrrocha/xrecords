package net.xrrocha.xrecords.script

import java.util.List
import java.util.Map
import org.junit.Test
import static org.junit.Assert.*
import static net.xrrocha.xrecords.util.Extensions.cast

class ScriptTest {
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
    def void runsScript() {
        val Map<String, Object> environment = cast(#{
            'who' -> 'Neo',
            'howMuch' -> 42
        })
        
        val scriptText = '''
            print(who + ' owes the matrix ' + howMuch + ' (' + what + ')')
        '''
        val script = new Script(scriptText, environment)
        
        script.execute(cast(#{ 'what' -> 'money'}))
    }
}