package net.xrrocha.xrecords.fixed

import java.util.List
import net.xrrocha.xrecords.field.FixedField
import org.eclipse.xtend.lib.annotations.Accessors

abstract class FixedBase {
  @Accessors int length
  @Accessors List<FixedField<Object>> fields
}