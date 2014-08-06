package xrrocha.xrecords.record.jdbc

import org.junit.Test
import static org.junit.Assert.assertEquals

class JDBCUtilsTest {
    @Test
    def void buildsInsertSql() {
        val expectedInsertSql =
            '''
                INSERT INTO "tableName"("field1", "field2", "field3")
                VALUES(?, ?, ?)
            '''
               
        val tableName = 'tableName'
        val fieldNames = #['field1', 'field2', 'field3']
        val actualInsertSql = JDBCUtils.buildInsertSql(tableName, fieldNames)

        assertEquals(expectedInsertSql, actualInsertSql)
    }
}