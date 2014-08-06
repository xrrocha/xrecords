package xrrocha.xrecords.record

import org.junit.Test
import static org.junit.Assert.*

class RecordTest {
    @Test
    def void createsRecordFromMap() {
        val map = #{ 'one' -> 1, 'two' -> 2, 'three' -> 3 }
        val record = new Record => [
            setField('one', 1)
            setField('two', 2)
            setField('three', 3)
        ]
        assertEquals(record, Record.fromMap(map))
    }
    
    @Test
    def void rejectsNullName() {
        val record = new Record
        try {
            record.setField(null, "")
            fail("Failed to reject null field name")
        } catch (NullPointerException npe) {}
    }
    
    @Test
    def void rejectsBlankName() {
        val record = new Record
        try {
            record.setField("", "")
            fail("Failed to reject blank field name")
        } catch (IllegalArgumentException npe) {}
    }
    
    @Test
    def void acceptsNullValue() {
        val record = new Record
            record.setField("name", null)
    }
    
    @Test
    def storesAndRetrievesField() {
        val record = new Record

        record.setField("one", "1")
        assertEquals("1", record.getField("one"))
        assertEquals(1, record.fieldNames.size)

        record.setField("two", "2")
        assertEquals("1", record.getField("one"))
        assertEquals("2", record.getField("two"))
        assertEquals(2, record.fieldNames.size)
    }
    
    @Test
    def void getFailsForNonExistentName() {
        val record = new Record
        try {
            record.getField("nonExistent")
            fail("Returned non-existent field")
        } catch (IllegalArgumentException npe) {}
    }
    
    @Test
    def void removeFailsForNonExistentName() {
        val record = new Record
        try {
            record.getField("nonExistent")
            fail("Removed non-existent field")
        } catch (IllegalArgumentException npe) {}
    }
    
    @Test
    def void removesFields() {
        val record = new Record

        record.setField("one", "1")
        assertEquals("1", record.getField("one"))
        assertEquals(1, record.fieldNames.size)

        record.setField("two", "2")
        assertEquals("1", record.getField("one"))
        assertEquals("2", record.getField("two"))
        assertEquals(2, record.fieldNames.size)
        
        record.removeField("two")
        try {
            record.getField("two")
            fail("Retrieved non-existent field")
        } catch (IllegalArgumentException iae) {}
        assertEquals("1", record.getField("one"))
        assertEquals(1, record.fieldNames.size)
    }
    
    @Test
    def void clearEmptiesFields() {
        val record = new Record
        record.setField("one", "1")
        record.setField("two", "2")
        assertEquals(2, record.fieldNames.size)
        record.clear()
        assertEquals(0, record.fieldNames.size)
    }
    
    @Test
    def void retirevesFieldName() {
        val record = new Record
        record.setField("one", "1")
        record.setField("two", "2")
        assertEquals(#{"one", "two"}, record.fieldNames)
        record.removeField("one")
        assertEquals(#{"two"}, record.fieldNames)
    }
    
    @Test
    def void copiesToRecord() {
        val firstRecord = new Record
        firstRecord.setField("one", "1")
        firstRecord.setField("two", "2")
        assertEquals(#{"one", "two"}, firstRecord.fieldNames)
        
        val secondRecord = new Record
        secondRecord.setField("three", "3")
        assertEquals(#{"three"}, secondRecord.fieldNames)
        
        firstRecord.copyTo(secondRecord)
        assertEquals(#{"one", "two", "three"}, secondRecord.fieldNames)
        assertEquals(#{"one", "two"}, firstRecord.fieldNames)
    }
    
    @Test
    def void copiesFromRecord() {
        val firstRecord = new Record
        firstRecord.setField("one", "1")
        firstRecord.setField("two", "2")
        assertEquals(#{"one", "two"}, firstRecord.fieldNames)
        
        val secondRecord = new Record
        secondRecord.setField("three", "3")
        assertEquals(#{"three"}, secondRecord.fieldNames)
        
        secondRecord.copyFrom(firstRecord)
        assertEquals(#{"one", "two", "three"}, secondRecord.fieldNames)
        assertEquals(#{"one", "two"}, firstRecord.fieldNames)
    }
}