require 'sketchup.rb'
require 'extensions.rb'

#Create a new extension object
shadeExtension = SketchupExtension.new "ShaDe", "ShaDe/lib/startup.rb"

#Specify some data of the plugin
shadeExtension.description="Shape Grammar Interpreter"

shadeExtension.copyright = "2011, University of Málaga"

shadeExtension.version = "4.0"

shadeExtension.creator = "University of Málaga"

#Register the extension
Sketchup.register_extension shadeExtension, false