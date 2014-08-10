package net.xrrocha.xrecords

import java.io.FileReader
import net.xrrocha.xrecords.copier.Copier
import net.xrrocha.yamltag.DefaultYamlFactory

class Main {
    def static void main(String[] args) {
        val yamlFactory = new DefaultYamlFactory
        val yaml = yamlFactory.newYaml
        val reader = new FileReader(args.get(0))
        val copier = yaml.loadAs(reader, Copier)
        copier.copy()
    }
}