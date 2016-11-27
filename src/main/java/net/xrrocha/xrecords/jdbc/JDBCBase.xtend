package net.xrrocha.xrecords.jdbc

import javax.sql.DataSource
import org.eclipse.xtend.lib.annotations.Accessors

// Add suport for array fields jdbc
abstract class JDBCBase {
  @Accessors DataSource dataSource
}
