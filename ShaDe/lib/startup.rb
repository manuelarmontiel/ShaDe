require 'sketchup' # First we pull in the standard API hooks.
require 'ShaDe//lib//main-structures.rb'
require 'ShaDe//lib//utils.rb'
require 'ShaDe//lib//interfaces//guitools.rb'
require 'ShaDe//lib//interfaces//guimenu.rb'

# Show the Ruby Console at startup so we can
# see any programming errors we may make.
Sketchup.send_action "showRubyPanel:"


# MAIN CODE ################################################################
# Add a menu item to launch our plugin, and prepare the plugin variables
menu = UI::menu("Plugins");
menu.add_separator;
menu.add_item("ShaDe Starter") {
	
	#We create the plugin context menu
	initContextMenu()
	
	#We open a new file
	Sketchup.file_new
	
	#We are inside SketchUp
	Shade.using_sketchup = true
	
	#We set the size of labels
	Shade.label_radius = Constants::LABEL_RADIUS
	
	#We set the epsilon variable
	Shade.custom_epsilon = Constants::EPSILON
	
	#We set the hausdorff_threshold variable
	Shade.hausdorff_threshold_sets 0.0, 0.0

	#We set the execution_environment_flag
	Shade.execution_environment_flag = true

	#We set mu_min
	Shade.mu_min = 0.5
 
	#We prepare the SU canvas
	ShadeUtils.prepare_canvas
	
	#Create the default project
	ShadeUtils.create_default_project
	
	#Create the toolbars
	create_static_toolbar()
	create_execution_toolbar()
	
	#Add the close observer
	close_observer = CloseObserver.new
	Sketchup.add_observer(close_observer)
	
	#Add the undo observer
	undo_observer = UndoObserver.new
	Sketchup.active_model.add_observer(undo_observer)
	
	#Refresh the project
	Shade.project.refresh(true)
	
	#Explicitly say that the grammar is saved
	Shade.project.execution.grammar.saved = true
	
	#Set showing text to false
	Shade.show_text = false
}
