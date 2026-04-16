def initContextMenu()	
	pluginMenu = UI::menu("Plugins")
	submenu = pluginMenu.add_submenu("Shade Menu");
	
	submenu.add_item("New project") {newProjectMenu()}
	submenu.add_item("Open project") {openProjectMenu()}
	submenu.add_item("Save project") {saveProjectMenu()}
	submenu.add_item("Save project as") {saveProjectAsMenu()}
	submenu.add_separator;
	submenu.add_item("New Grammar") {newGrammarMenu()}
	submenu.add_item("Open Grammar") {openGrammarMenu()}	
	submenu.add_item("Save Grammar as") {saveGrammarAsMenu()}
	submenu.add_separator;
	submenu.add_item("Load Shape") {loadShapeMenu()}
	submenu.add_item("Save Shape") {saveShapeMenu()}
	submenu.add_separator;
	submenu.add_item("Load Axiom") {loadAxiomMenu()}
	submenu.add_item("Save Design") {saveDesignMenu()}
	submenu.add_separator;
	submenu.add_item("Create Script") {createScriptMenu()}
	submenu.add_item("Load Script") {loadScriptMenu()}
	submenu.add_separator;
	
end


#New Project command
def newProjectMenu()
	project = Shade.project
	execution = Shade.project.execution
	Sketchup.active_model.close_active
	execution.reset

	#Before creating a new project, we save the current one if necessary
	if !project.saved
		input = UI.messagebox("Save current project?", MB_YESNOCANCEL)
		if input == 6
			if project.path
				project.save(project.path, true)
			else
				saved = false
				while !saved
					path_to_save_to = UI.savepanel "Save Project", "", "project.prj"
					if path_to_save_to
						if ShadeUtils.get_extension(path_to_save_to) == "prj"
							begin
								project.save(path_to_save_to, true)
								saved = true
							rescue
								UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
								end
						else
							UI.messagebox("Please save the project as a .prj file")
						end
					else
						saved = true
					end
				 end
			end
		end
	end    
	ShadeUtils.create_default_new_project()
end

#Open Project command
def openProjectMenu()	
	project = Shade.project
	execution = Shade.project.execution
	Sketchup.active_model.close_active
	#execution.reset
   
	if !project.saved
		input = UI.messagebox("Save current project?", MB_YESNOCANCEL)
		if input == 6
			if project.path
				project.save(project.path, true)
			else
				saved = false
				while !saved
					path_to_save_to = UI.savepanel "Save Project", "", "project.prj"
					if path_to_save_to
						if ShadeUtils.get_extension(path_to_save_to) == "prj"
							begin
								project.save(path_to_save_to, true)
								saved = true
							rescue
								UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
							end
						else
							UI.messagebox("Please save the project as a .prj file")
						end
					else
						saved = true
					end
				end
			end
		end
	end
	opened = false
	while !opened
		chosen_project_path = UI.openpanel("Open project", "" ,"*.prj")
		if chosen_project_path	
			if ShadeUtils.get_extension(chosen_project_path) == "prj"				
				begin
					project.load(chosen_project_path)
					project.saved = true
					project.refresh
					opened = true
				rescue
					UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
				rescue LoadError => e
					UI.messagebox(e.message)
				end
			else
				UI.messagebox("Please choose a .prj file")
			end
		else
			opened = true
		end
	end
end

def saveProjectMenu()
	project = Shade.project
	execution = Shade.project.execution
	Sketchup.active_model.close_active
    
	if project.path
		project.save(project.path, true)
	else
		saved = false
		while !saved
			path_to_save_to = UI.savepanel "Save Project", "", "project.prj"
			if path_to_save_to
				if ShadeUtils.get_extension(path_to_save_to) == "prj"
					begin
						project.save(path_to_save_to, true)
						saved = true
					rescue
						UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
					end
				else
					UI.messagebox("Please save the project as a .prj file")
				end
			else
				saved = true
			end
		end
	end
end

def saveProjectAsMenu()
	project = Shade.project
	execution = Shade.project.execution
	Sketchup.active_model.close_active
	
	saved = false
	while !saved
		path_to_save_to = UI.savepanel "Save Project", "", "project.prj"
		if path_to_save_to
			if ShadeUtils.get_extension(path_to_save_to) == "prj"
				begin
					project.save(path_to_save_to, true)
					saved = true
				rescue
					UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
				end
			else
				UI.messagebox("Please save the project as a .prj file")
			end
		else
			saved = true
		end
	end
end


def newGrammarMenu()
	project = Shade.project
	execution = Shade.project.execution
	Sketchup.active_model.close_active
	execution.reset
	if !execution.grammar.saved
		input = UI.messagebox("Save current grammar?", MB_YESNOCANCEL)
		if input == 6
			saved = false
			while !saved
				path_to_save_to = UI.savepanel "Save Grammar", "", "grammar.gr2"
				if path_to_save_to
					if ShadeUtils.get_extension(path_to_save_to) == "gr2"
						begin
							execution.grammar.save(path_to_save_to, true)
							saved = true
						rescue
							UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
						end
					else
						UI.messagebox("Please save the grammar as a .gr2 file")
					end
				else
					saved = true
				end
			end
		end
	end
	ShadeUtils.create_default_new_grammar()
	project.saved = false
	project.refresh
end

def openGrammarMenu()
	project = Shade.project
	execution = Shade.project.execution
	Sketchup.active_model.close_active
	execution.reset
	if !execution.grammar.saved
		input = UI.messagebox("Save current grammar?", MB_YESNOCANCEL)
		if input == 6
			saved = false
			while !saved
				path_to_save_to = UI.savepanel "Save Grammar", "", "grammar.gr2"
				if path_to_save_to
					if ShadeUtils.get_extension(path_to_save_to) == "gr2"
						begin
							execution.grammar.save(path_to_save_to, true)
							saved = true
						rescue
							UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
						end
					else
						UI.messagebox("Please save the grammar as a .gr2 file")
					end
				else
					saved = true
				end
			end
		end
	end
	opened = false
	while !opened
		chosen_grammar_path = UI.openpanel("Open grammar", "" ,"*.gr2")
		if chosen_grammar_path
			if ShadeUtils.get_extension(chosen_grammar_path) == "gr2"
				begin
					execution.grammar.load(chosen_grammar_path)
					opened = true
					project.saved = false
					project.refresh
				rescue LoadError => e
					UI.messagebox(e.message)
				rescue
					UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
				end
			else
				UI.messagebox("Please choose a .gr2 file")
			end
		else
			opened = true
		end
	end
end
	

def saveGrammarAsMenu()
	project = Shade.project
	execution = Shade.project.execution
	Sketchup.active_model.close_active
	saved = false
	while !saved
		path_to_save_to = UI.savepanel "Save Grammar", "", "grammar.gr2"
		if path_to_save_to
			if ShadeUtils.get_extension(path_to_save_to) == "gr2"
				begin
					execution.grammar.save(path_to_save_to, true)
					saved = true
				rescue
					UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
				end
			else
				UI.messagebox("Please save the grammar as a .gr2 file")
			end
		else
			saved = true
		end
	end
end


def loadShapeMenu()
	Sketchup.active_model.close_active
	prompts = ["Rule ID ", "Rule part "]
	default = ["1", "Left"]
	rule_list = ShadeUtils.create_rule_list()
	list = [rule_list, "Left|Right"]
	input = UI.inputbox prompts, default, list, "Choose shape:"
	if input
		rule_idx = input[0].to_i - 1
		rule = Shade.project.execution.grammar.rules[rule_idx]
		if input[1] == "Left"
			shape = rule.left
		else
			shape = rule.right
		end
		opened = false
		while !opened
			load_shape_path = UI.openpanel "Load Shape", "", "*.txt"
			if load_shape_path
				if ShadeUtils.get_extension(load_shape_path) == "txt"
					begin
						shape.load(load_shape_path)
						opened = true
						if ((rule_idx == 0) && (input[1] == "Left") && (!Shade.project.execution.file_axiom))
							# Add new axiom			
							new_axiom = LabelledShape.new(Array.new, Array.new)
							Sketchup.active_model.layers.each { |layer|
								new_axiom.p = shape.p.clone
								new_axiom.s = shape.s.clone
							}
							Shade.project.execution.grammar.axiom = new_axiom
							Shade.project.execution.reset
						end
					rescue LoadError => e
						UI.messagebox(e.message)
					rescue
						UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
					end
				else
					UI.messagebox("Please choose a .txt file")
				end
			else
				opened = true
			end
		end
	end
end	


def saveShapeMenu()
	Sketchup.active_model.close_active
	prompts = ["Rule ID ", "Rule part "]
	default = ["1", "Left"]
	rule_list = ShadeUtils.create_rule_list()
	list = [rule_list, "Left|Right"]
	input = UI.inputbox prompts, default, list, "Choose shape:"
	if input
		rule_idx = input[0].to_i - 1
		rule = Shade.project.execution.grammar.rules[rule_idx]
		if input[1] == "Left"
			shape = rule.left
		else
			shape = rule.right
		end
		saved = false
		while !saved
			save_shape_path = UI.savepanel "Save Shape", "", "shape.txt"
			if save_shape_path
				if ShadeUtils.get_extension(save_shape_path) == "txt"
					begin
						shape.save(save_shape_path)
						saved = true
					rescue
						UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
					end
				else
					UI.messagebox("Please save the shape as a .txt file")
				end
			else
				saved = true
			end
		end
	end
end

def loadAxiomMenu()
	Sketchup.active_model.close_active
    
	opened = false
	while !opened
		chosen_axiom_path = UI.openpanel("Load axiom", "" ,"*.txt")
		if chosen_axiom_path
			if ShadeUtils.get_extension(chosen_axiom_path) == "txt"
				begin
					new_axiom = LabelledShape.new(Array.new, Array.new)
					new_axiom.load(chosen_axiom_path)
					Shade.project.execution.file_axiom = true
					Shade.project.execution.grammar.axiom = new_axiom
					Shade.project.execution.reset
					opened = true
				rescue LoadError => e
					UI.messagebox(e.message)
				rescue
					UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
				end
			else
				UI.messagebox("Please choose a .txt file")
			end
		else
			opened = true
		end
	end
end

def saveDesignMenu()
	project = Shade.project
	execution = Shade.project.execution
	Sketchup.active_model.close_active
	
	saved = false
	while !saved
		path_to_save_to = UI.savepanel "Save Design", "", "design.txt"
		if (path_to_save_to)
			if ShadeUtils.get_extension(path_to_save_to) == "txt"
				begin
					execution.current_shape.save(path_to_save_to)
					saved = true
				rescue
					UI.messagebox("The path you have chosen is not valid (maybe it has some special character?)")
				end
			else
				UI.messagebox("Please save the design as a .txt file")
			end
		else
			saved = true
		end
	end
end


def createScriptMenu()
	Sketchup.active_model.close_active
	# Find and show our html file
	html_path = Sketchup.find_support_file "createRobot.html" , Constants::HTML_DIR
	robot_dialog = create_robot_dialog
	robot_dialog.set_file(html_path)
	robot_dialog.show()
end

def loadScriptMenu()
	Sketchup.active_model.close_active
	chosen_robot_path = UI.openpanel("Open script", "" ,"*.txt")
	if chosen_robot_path			
		robot = Robot.new
		robot.load(chosen_robot_path)
		Shade.robot = robot
	end
end

