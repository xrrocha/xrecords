package net.xrrocha.xrecords

import java.io.File
import java.io.FileReader
import net.xrrocha.xrecords.copier.Copier
import net.xrrocha.yamltag.DefaultYamlFactory

// TODO Expand yaml content with variables set from CLI (e.g. --myValue=someValue)
class Main {
    def static void main(String[] args) {
        if (args.length < 1) {
            System.err.println('Usage: Main script.yaml')
            System.exit(1)    
        }
        
        val file = new File(args.get(0))
        if (!(file.exists && file.canRead)) {
            System.err.println('''Can't open file: «file.absolutePath»''')
            System.exit(1)
        }
        
        val reader = new FileReader(file)
        val yamlFactory = new DefaultYamlFactory
        val yaml = yamlFactory.newYaml

        val copier = yaml.loadAs(reader, Copier)

        copier.copy()
    }
}
