package net.xrrocha.xrecords.script

import java.util.List
import java.util.Map
import javax.script.ScriptEngineManager
import net.xrrocha.xrecords.validation.Validatable

class Script implements Validatable {
    @Property String script
    @Property String language = DEFAULT_LANGUAGE
    @Property Map<String, Object> bindings = newHashMap
    
    public static val DEFAULT_LANGUAGE = 'javascript'
    
    new() {}
    
    new(String script) {
        this(DEFAULT_LANGUAGE, script)
    }
    
    new(String language, String script) {
        this(language, script, newHashMap)
    }
    
    new(String script, Map<String, Object> bindings) {
        this(DEFAULT_LANGUAGE, script, bindings)
    }
    
    new(String language, String script, Map<String, Object> bindings) {
        this.language = language
        this.script = script
        this.bindings = bindings
    }
    
    def execute() {
        execute(null)
    }
    
    def execute(Map<String, Object> bindings) {
        if (script == null) {
            throw new IllegalStateException('Missing script')
        }

        if (language == null) {
            language = DEFAULT_LANGUAGE
        }
        
        val factory = new ScriptEngineManager()
        val engine = factory.getEngineByName(language)
        if (engine == null) {
            throw new IllegalArgumentException('''No such scripting language: «language»''')
        }
        
        if (this.bindings != null) {
            this.bindings.forEach[k, v | engine.put(k, v)]  
        }
        
        if (bindings != null) {
            bindings.forEach[k, v | engine.put(k, v)] 
        }
        
        engine.eval(script)
    }
    
    override validate(List<String> errors) {
        if (script == null) {
            errors.add('Missing script')
        }
        
        if (language != null) {
            val factory = new ScriptEngineManager()
            val engine = factory.getEngineByName(language)
            if (engine == null) {
                errors.add('''No such scripting language: «language»''')
            }
        }
    }
}