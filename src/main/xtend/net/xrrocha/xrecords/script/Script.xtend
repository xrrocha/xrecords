package net.xrrocha.xrecords.script

import java.util.List
import java.util.Map
import javax.script.ScriptContext
import javax.script.ScriptEngine
import javax.script.ScriptEngineManager
import net.xrrocha.xrecords.validation.Validatable

class Script implements Validatable {
    @Property String script
    @Property String language = DEFAULT_LANGUAGE
    @Property Map<String, Object> environment = newHashMap
    
    public static val DEFAULT_LANGUAGE = 'javascript'
    
    private static val factory = new ScriptEngineManager()
    
    new() {}
    
    new(String script) {
        this(DEFAULT_LANGUAGE, script)
    }
    
    new(String language, String script) {
        this(language, script, newHashMap)
    }
    
    new(String script, Map<String, Object> environment) {
        this(DEFAULT_LANGUAGE, script, environment)
    }
    
    new(String language, String script, Map<String, Object> environment) {
        this.language = language
        this.script = script
        this.environment = environment
    }
    
    def execute() {
        execute(null)
    }
    
    def execute(Map<String, Object> environment) {
        if (script == null) {
            throw new IllegalStateException('Missing script')
        }
        
        val engine = getEngine
        
        val bindings = engine.createBindings
        if (this.environment != null) {
            bindings.putAll(this.environment)
        }
        if (environment != null) {
            bindings.putAll(environment)
        }
        
        engine.eval(script, bindings)
    }
    
    private var ScriptEngine engine
    def getEngine() {
        if (engine == null) {
            if (language == null) {
                language = DEFAULT_LANGUAGE
            }
            
            engine = factory.getEngineByName(language)
            if (engine == null) {
                throw new IllegalArgumentException('''No such scripting language: «language»''')
            }
            
            if (environment != null) {
                environment.forEach[k, v | engine.put(k, v)]
            }
        }
        
        engine
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