package net.xrrocha.xrecords.script

import java.util.List
import java.util.Map
import javax.script.ScriptEngine
import javax.script.ScriptEngineManager
import net.xrrocha.xrecords.validation.Validatable

class Script implements Validatable {
    @Property String script
    @Property String language = DEFAULT_LANGUAGE
    @Property Map<String, ?extends Object> environment = newHashMap
    
    // TODO Inject utility object into scripts to deal w/records
    // TODO Add per-language prolog/epilog
    
    public static val DEFAULT_LANGUAGE = 'javascript'
    
    private static val factory = new ScriptEngineManager()
    
    new() {}
    
    new(String script) {
        this(DEFAULT_LANGUAGE, script)
    }
    
    new(String language, String script) {
        this(language, script, newHashMap)
    }
    
    new(String script, Map<String, ?extends Object> environment) {
        this(DEFAULT_LANGUAGE, script, environment)
    }
    
    new(String language, String script, Map<String, ?extends Object> environment) {
        this.language = language
        this.script = script
        this.environment = environment
    }
    
    def execute() {
        execute(null)
    }
    
    def execute(Map<String, ?extends Object> environment) {
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
        }
        
        engine
    }
    
    override validate(List<String> errors) {
        if (script == null) {
            errors.add('Missing script')
        }
        
        try {
            getEngine
        } catch (Exception e) {
            errors.add(e.message)
        }
    }
}