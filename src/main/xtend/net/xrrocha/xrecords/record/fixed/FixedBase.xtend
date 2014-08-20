package net.xrrocha.xrecords.record.fixed

import java.util.List
import net.xrrocha.xrecords.field.Field
import net.xrrocha.xrecords.field.FixedField
import net.xrrocha.xrecords.validation.Validatable
import org.eclipse.xtend.lib.annotations.Accessors

abstract class FixedBase implements Validatable {
    @Accessors int length
    @Accessors boolean trim = true
    @Accessors List<FixedField<Object>> fields // FIXME FixedField<?extends Object>
    
    override validate(List<String> errors) {
        if (length <= 0) {
            errors.add('''Invalid fixed record length: «length»''')
        }
        
        Field.validateFields(fields, errors)
        
        if (fields != null) {
            val overflowFields = fields.filter[offset + length > FixedBase.this.length].map[name]
            if (overflowFields.size > 0) {
                errors.add('''Field(s) exceed fixed length: «overflowFields»''')
            }
        }
    }
}