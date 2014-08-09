package net.xrrocha.xrecords.script

import java.util.List
import java.util.Map
import javax.script.ScriptEngine
import javax.script.ScriptEngineManager
import net.xrrocha.xrecords.validation.Validatable

class Script implements Validatable {
    @Property String script
    @Property String language = DEFAULT_LANGUAGE
    @Property Map<String, Object> bindings = newHashMap
    
    public static val DEFAULT_LANGUAGE = 'javascript'
    
    private var ScriptEngine engine;
    
    new() {}
    
    new(String script) {
        this(DEFAULT_LANGUAGE, script)
    }
    
    new(String language, String script) {
        this(language, script, newHashMap)
    }
    
    new(String language, String script, Map<String, Object> bindings) {
        this.language = language
        this.script = script
        this.bindings = bindings

        init()
    }
    
    def execute() {
        execute(null)
    }
    
    def execute(Map<String, Object> bindings) {
        if (engine == null) {
            init()
        }
        
        if (bindings != null) {
            bindings.forEach[k, v | engine.put(k, v)] 
        }
        
        engine.eval(script)
    }
    
    private def init() {
        if (script == null) {
            throw new IllegalStateException('Missing script')
        }

        if (language == null) {
            language = DEFAULT_LANGUAGE
        }
        
        val factory = new ScriptEngineManager()
        engine = factory.getEngineByName(language)
        
        if (bindings != null) {
            bindings.forEach[k, v | engine.put(k, v)]  
        }
    }
    
    override validate(List<String> errors) {
        if (script == null) {
            errors.add('Missing script')
        }
    }
}