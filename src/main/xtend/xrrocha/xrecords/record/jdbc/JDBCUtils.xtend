package xrrocha.xrecords.record.jdbc

import java.util.List

class JDBCUtils {
    static def String buildInsertSql(String tableName, List<String> fieldNames) {
        '''
            INSERT INTO "«tableName»"(«fieldNames.map['''"«it»"'''].join(', ')»)
            VALUES(«(0 ..< fieldNames.size).map['?'].join(', ')»)
        '''
    }
}