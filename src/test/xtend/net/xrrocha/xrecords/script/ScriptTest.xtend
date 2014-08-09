package net.xrrocha.xrecords.script

import java.util.Map
import org.junit.Test
import static net.xrrocha.xrecords.util.Extensions.cast 

class ScriptTest {
    @Test
    def void runsScript() {
        val Map<String, Object> scriptBindings = cast(#{
            'who' -> 'Neo',
            'howMuch' -> 42
        })
        
        val scriptText = '''
            print(who + ' owes the matrix ' + howMuch)
        '''
        val script = new Script(scriptText, scriptBindings)
        
        script.execute
    }
}