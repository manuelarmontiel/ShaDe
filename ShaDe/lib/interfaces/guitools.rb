require 'sketchup' # First we pull in the standard API hooks.
require 'ShaDe//lib//utils.rb'
require 'ShaDe//lib//geometry.rb'
require 'ShaDe//lib//data-structures.rb'
require 'ShaDe//lib//main-structures.rb'

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents the observer for a rule shape group. There is one observer of this kind for every present rule shape.
class RuleShapeObserver < Sketchup::EntitiesObserver
	
	#Initializing
	def initialize(shape)
		@shape = shape
	end
	
	#Method that triggers when something is modified inside a rule shape group, in order to update the internal representation of the affected rule shape
	def onElementModified(entities, entity)
		
		if !Shade.project.modifying
			if !Shade.project.erasing
				Shade.project.modifying = true
				execution = Shade.project.execution
				layer_name = Sketchup.active_model.active_layer.name
				@shape.refresh_from_entities(entities, @shape.transformation(layer_name), layer_name)
				execution.grammar.saved = false
				Shade.project.modifying = false
			end
		end
	end

	#Method that triggers when a rule shape group is erased, in order to update the internal representation of the affected rule shape
	def onEraseEntities(entities)
		
		if !Shade.project.modifying
			Shade.project.modifying = true
			layer_name = Sketchup.active_model.active_layer.name
			@shape.p[layer_name] = LinearLinkedList.new
			@shape.s[layer_name] = LinearLinkedList.new
			execution = Shade.project.execution
			execution.grammar.saved = false
			Shade.project.modifying = false
		end
	end

	#Method that triggers when some element is added into a rule shape group, in order to update the internal representation of the affected rule shape
	def onElementAdded(entities, entity)
		
		if !Shade.project.modifying
			
			Shade.project.modifying = true
			execution = Shade.project.execution
			layer_name = Sketchup.active_model.active_layer.name
			@shape.refresh_from_entities(entities, @shape.transformation(layer_name), layer_name)
			execution.grammar.saved = false
			Shade.project.modifying = false
		end
	end
	
	#Method that triggers when some element is removed from a rule shape group, in order to update the internal representation of the affected rule shape
	def onElementRemoved(entities, entity_id)
		
		if !Shade.project.modifying
			Shade.project.modifying = true
			execution = Shade.project.execution
			layer_name = Sketchup.active_model.active_layer.name
			@shape.refresh_from_entities(entities, @shape.transformation(layer_name), layer_name)
			execution.grammar.saved = false
			Shade.project.modifying = false
		end
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents the observer for all the rule shape groups. There is only one observer of this kind.
class RuleGroupsObserver < Sketchup::EntitiesObserver
	
	attr_accessor :observed_id_list
	
	#Initializing the observer
	def initialize()
		#List of entity ids that cannot be modified
		#These entities are the main groups of the rule shapes
		@observed_id_list = Array.new
		@undoing = false
		super
	end
	
	#Method that triggers when some rule shape group is modified (transformed) as a whole, in order to update the internal representation of the affected rule shape
	def onElementModified(entities, entity)
		
		if @observed_id_list.include? entity.entityID
			
			if !Shade.project.modifying
				Shade.project.modifying = true
				execution = Shade.project.execution
				shape = execution.grammar.search_shape_by_id(entity.entityID)

				if shape
					#refresh the transformation										
					layout_t = shape.layout_transformation
					layout_t_i = layout_t.inverse
					shape_t = layout_t_i * entity.transformation
					
					layer_name = Sketchup.active_model.active_layer.name
					shape.shape_transformation[layer_name] = shape_t
					
					shape.refresh_from_entities(entity.entities, Geom::Transformation.new, layer_name)
					
					execution.grammar.saved = false
				end
				Shade.project.modifying = false
			end
		end
	end
	
end



#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
# Observer attached to  Sketchup. Triggers when SU is closed
class CloseObserver < Sketchup::AppObserver	
	#Asks to save the project and removes the observers
	def onQuit
		ShadeUtils.ask_to_save_project()
	end
	
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#Observer attached to Sketchup.active_model, triggers when the user makes an UNDO
class UndoObserver < Sketchup::ModelObserver
	
	#Reexecutes the grammar and shows a message, saying that it is not allowed to undo
	def onTransactionUndo(model)
		Sketchup.active_model.start_operation("Undo Done")
		#Shade.project.need_refresh = true
		UI.messagebox("We are sorry, you cannot use the undo command.")
		Sketchup.active_model.commit_operation
	end
end
#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#Tool for painting a label
class AddLabelTool

	#shape:: the shape to which the label is going to be added
	#value:: the value of the label
	#
	#Initializing the tool
	def initialize(shape, value)
		@id_cursor = nil
		@shape = shape
		@value = value
	end
	
	#Activates the cursor
	def activate
		file_name = Sketchup.find_support_file "add_label.png", "Plugins/ShaDe/#{Constants::ABS_ICONS_DIR}"
		@id_cursor = UI.create_cursor file_name, 18, 18
	end
	
	#Method that triggers when the cursor is chosen
	def onSetCursor
		UI.set_cursor  @id_cursor
	end
	
	#Method that triggers when the left button of the mouse is pressed
	def onLButtonDown(flags, x, y, view)

		inputpoint = view.inputpoint x,y
		point = inputpoint.position
		
		#Obtain point relative to shape
		t = @shape.layout_transformation.inverse
		pt_label = t * point
		layer_name = Sketchup.active_model.active_layer.name
		@shape.add_label(pt_label, @value, layer_name)
		
		@shape.changed = true
		
		Shade.project.refresh
		Shade.project.execution.reset
	end
end

#Saves the project, the current shape and the execution history
def save_temp_files()
	project = Shade.project
	
	#STEP 1: Save project
	project_path = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/project.txt"
	project_path.gsub!("/", "\\")
	project.save(project_path, true)

	#STEP 2: Save current shape 
	current_shape_path = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/current_shape.txt"
	current_shape_path.gsub!("/", "\\")
	project.execution.current_shape.save(current_shape_path)

	#STEP 3: Save execution history
	history_directory = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}"
	history_directory.gsub!("/", "\\")
	project.execution.save_execution_history(history_directory)
	
	#STEP 4: Save epsilon 
	epsilon_path = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/epsilon.txt"
	File.open(epsilon_path.gsub("/", "\\"), 'w') do |f|
		f.write Shade.custom_epsilon
	end
	
	#STEP 5: Save hausdorff_threshold 
	hausdorff_path = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/hausdorff.txt"
	File.open(hausdorff_path.gsub("/", "\\"), 'w') do |f|
		f.puts Shade.hausdorff_threshold[0]
		f.puts Shade.hausdorff_threshold[1]
	end
	
  #STEP 6: Save mu 
    mu_min_path = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/mu_min.txt"
    File.open(mu_min_path.gsub("/", "\\"), 'w') do |f|
      f.write Shade.mu_min
    end
    
  #STEP 7: Save actual mu 
      mu_path = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/mu.txt"
      File.open(mu_path.gsub("/", "\\"), 'w') do |f|
        #f.write Shade.project.execution.current_shape.mu
        Shade.project.execution.current_shape.mu.each{|key, value|
          f.write "#{key} #{value}"
        }
      end
	
end

#Loads the temp files
def load_temp_files()
	execution = Shade.project.execution

	#STEP 1: Load execution history
	history_directory = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}"
	history_directory.gsub!("/", "\\")
	execution.load_execution_history(history_directory)
	
	#STEP 1: Load current shape
	current_shape_path = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/current_shape.txt"
	current_shape_path.gsub!("/", "\\")
	execution.current_shape.load(current_shape_path)
	execution.current_shape.refresh
	execution.current_shape.create_pi
	
  mu_path = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/mu.txt"
     if File.exist? "#{mu_path}"
       File.open("#{mu_path}", 'r') do |f|
#         while (line = f.gets)
#           Shade.project.execution.current_shape.mu = line.to_f
#         end
         while (line = f.gets)
          sLine = line.split
          key = sLine[0]
          value = sLine[1]
          Shade.project.execution.current_shape.mu[key] = value.to_f
         end
       end
     end
	
end

#Deletes all the files inside temp folder
def delete_temp_files()
	dir = Dir.new("#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}")
	dir.each { |file_name|
		if file_name == '.' or file_name == '..' then next
		else File.delete("#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/#{file_name}")
		end
	}
end

#Method that creates the toolbar for saving and loading projects, grammars and shapes, as well as editing rules
def create_static_toolbar()
	
	toolbar = UI.toolbar Constants::STATIC_TOOLBAR_NAME

	#New Project command
	newp_cmd = UI::Command.new("new_project"){
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
	}
	newp_cmd.tooltip = "New project"
	newp_cmd.small_icon = File.join(Constants::ICONS_DIR, "new_project.PNG")
	newp_cmd.large_icon = File.join(Constants::ICONS_DIR, "new_project.PNG")
	toolbar.add_item newp_cmd
	
	#Open Project command
	openp_cmd = UI::Command.new("open_project"){
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
  
	}
	openp_cmd.tooltip = "Open project"
	openp_cmd.small_icon = File.join(Constants::ICONS_DIR, "open_project.PNG")
	openp_cmd.large_icon = File.join(Constants::ICONS_DIR, "open_project.PNG")
	toolbar.add_item openp_cmd
	
	#Save Project command
	savep_cmd = UI::Command.new("save_project"){
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
	}
	savep_cmd.tooltip = "Save project"
	savep_cmd.small_icon = File.join(Constants::ICONS_DIR, "save_project.PNG")
	savep_cmd.large_icon = File.join(Constants::ICONS_DIR, "save_project.PNG")
	toolbar.add_item savep_cmd
	
	#Save Project as command
	savepas_cmd = UI::Command.new("save_project_as"){
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

	}
	savepas_cmd.tooltip = "Save project as"
	savepas_cmd.small_icon = File.join(Constants::ICONS_DIR, "save_project_as.PNG")
	savepas_cmd.large_icon = File.join(Constants::ICONS_DIR, "save_project_as.PNG")
	toolbar.add_item savepas_cmd
	
	toolbar.add_separator
	
	#New Grammar command
	newg_cmd = UI::Command.new("new_grammar"){
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
	}
	newg_cmd.tooltip = "New grammar"
	newg_cmd.small_icon = File.join(Constants::ICONS_DIR, "new_grammar.PNG")
	newg_cmd.large_icon = File.join(Constants::ICONS_DIR, "new_grammar.PNG")
	toolbar.add_item newg_cmd
	
	#Open Grammar command
	openg_cmd = UI::Command.new("open_grammar"){
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
	}
	openg_cmd.tooltip = "Open grammar"
	openg_cmd.small_icon = File.join(Constants::ICONS_DIR, "open_grammar.PNG")
	openg_cmd.large_icon = File.join(Constants::ICONS_DIR, "open_grammar.PNG")
	toolbar.add_item openg_cmd
	
	#Save Grammar As command
	savegas_cmd = UI::Command.new("save_grammar_as"){
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
	}
	savegas_cmd.tooltip = "Save grammar as"
	savegas_cmd.small_icon = File.join(Constants::ICONS_DIR, "save_grammar_as.PNG")
	savegas_cmd.large_icon = File.join(Constants::ICONS_DIR, "save_grammar_as.PNG")
	toolbar.add_item savegas_cmd
	
	toolbar.add_separator
	
	#Add Rule command
	add_rule_cmd = UI::Command.new("add_rule"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active

		size = execution.grammar.rules.size
		
		#Create the default shapes
		left = ShadeUtils.create_default_left_shape
		right = ShadeUtils.create_default_right_shape
		
		#Obtain new rule id
		last_id = execution.grammar.rules[size-1].rule_id
		
		#Create new rule
		new_rule = ShadeUtils.paint_rule(last_id+1, left, right)
		execution.grammar.add_rule(new_rule)
		project.refresh
	}
	add_rule_cmd.tooltip = "Add rule"
	add_rule_cmd.small_icon = File.join(Constants::ICONS_DIR, "add_rule.PNG")
	add_rule_cmd.large_icon = File.join(Constants::ICONS_DIR, "add_rule.PNG")
	toolbar.add_item add_rule_cmd
	
	#Delete Rule command
	delete_rule_cmd = UI::Command.new("delete_rule"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active

		if execution.grammar.rules.size > 1
			prompts = ["Rule to delete: "]
			default = ["1"]
			rule_list = ShadeUtils.create_rule_list()
			list = [rule_list]
			input = UI.inputbox prompts, default, list, "Delete Rule"
			if input
				chosen_rule_idx = input[0].to_i-1
				
				if ((chosen_rule_idx == 0) && (!execution.file_axiom))
					previous_rule = execution.grammar.rules[1]
					# Add new axiom			
					new_axiom = LabelledShape.new(Array.new, Array.new)
					Sketchup.active_model.layers.each { |layer|
						new_axiom.p[layer.name] = previous_rule.left.p[layer.name].clone
						new_axiom.s[layer.name] = previous_rule.left.s[layer.name].clone
					}
					execution.grammar.axiom = new_axiom
					
					execution.reset
				end
				execution.grammar.remove_rule(chosen_rule_idx)
				# Transform the position of the rules from chosen_rule_idx
				idx = chosen_rule_idx
  
				while idx < execution.grammar.rules.size
					
					current_rule = execution.grammar.rules[idx]
					
					current_rule.left.layout_transformation = current_rule.left.layout_transformation * Constants::DESCEND_T.inverse
					current_rule.right.layout_transformation = current_rule.right.layout_transformation * Constants::DESCEND_T.inverse
					
					current_rule.left.changed = true
					current_rule.right.changed = true
			 
					Sketchup.active_model.layers.each { |layer|
						current_rule.arrow_group[layer.name].locked = false
						current_rule.arrow_group[layer.name].transform! Constants::DESCEND_T.inverse
						current_rule.arrow_group[layer.name].locked = true
						
						current_rule.line_group[layer.name].locked = false
						current_rule.line_group[layer.name].transform! Constants::DESCEND_T.inverse
						current_rule.line_group[layer.name].locked = true
						
						current_rule.group_origin_left[layer.name].locked = false
						current_rule.group_origin_left[layer.name].transform! Constants::DESCEND_T.inverse
						current_rule.group_origin_left[layer.name].locked = true
						
						current_rule.group_origin_right[layer.name].locked = false
						current_rule.group_origin_right[layer.name].transform! Constants::DESCEND_T.inverse
						current_rule.group_origin_right[layer.name].locked = true
					}
    
					idx += 1
				end
				execution.reset
				project.refresh
			end
		else
			UI.messagebox("You cannot delete all rules")
		end
	}
	delete_rule_cmd.tooltip = "Delete rule"
	delete_rule_cmd.small_icon = File.join(Constants::ICONS_DIR, "delete_rule.PNG")
	delete_rule_cmd.large_icon = File.join(Constants::ICONS_DIR, "delete_rule.PNG")
	toolbar.add_item delete_rule_cmd
	
	#Copy Rule command
	copy_rule_cmd = UI::Command.new("copy_rule"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active
		
		prompts = ["Rule to copy: "]
		default = ["1"]
		
		rule_list = ShadeUtils.create_rule_list()
		list = [rule_list]
		input = UI.inputbox prompts, default, list, "Rule to copy"
		if input
			n_rule = input[0].to_i-1
			if n_rule < execution.grammar.rules.size
				rule = execution.grammar.rules[n_rule]
				size = execution.grammar.rules.size
				
				# Obtain shape transformations
				t_left = rule.left.shape_transformation
				t_right = rule.right.shape_transformation
				
				# Obtain the new shapes
				left = rule.left.clone
				right = rule.right.clone
				
				#Paint the rule
				last_id = execution.grammar.rules[size-1].rule_id

				new_rule = ShadeUtils.paint_rule(last_id+1, left, right)
  
				#Transform the shapes
				left.shape_transformation = t_left
				right.shape_transformation = t_right
  
				execution.grammar.add_rule(new_rule)
				project.refresh
			else
				UI.messagebox("Rule " + (n_rule+1).to_s + " doesn't exist")
			end
		end
	}
	copy_rule_cmd.tooltip = "Copy rule"
	copy_rule_cmd.small_icon = File.join(Constants::ICONS_DIR, "copy_rule.PNG")
	copy_rule_cmd.large_icon = File.join(Constants::ICONS_DIR, "copy_rule.PNG")
	toolbar.add_item copy_rule_cmd
	
	#Add label command
	add_label_cmd = UI::Command.new("add_label"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active

		prompts = ["Rule ID ", "Rule part ", "Color "]
		default = ["1", Constants::LEFT, "Red"]
		rule_list = ShadeUtils.create_rule_list()
		list = [rule_list, "#{Constants::LEFT}|#{Constants::RIGHT}", "Red|Green|Blue|Yellow|White|Black"]
		input = UI.inputbox prompts, default, list, "Add label to shape:"
		if input
			rule_idx = input[0].to_i - 1
			rule = execution.grammar.rules[rule_idx]
			if input[1] == Constants::LEFT
				shape = rule.left
			else
				shape = rule.right
			end
			color = input[2]
			add_label_tool = AddLabelTool.new(shape, color)
			Sketchup.active_model.select_tool add_label_tool
		end
	}
	add_label_cmd.tooltip = "Add label to shape"
	add_label_cmd.small_icon = File.join(Constants::ICONS_DIR, "add_label.PNG")
	add_label_cmd.large_icon = File.join(Constants::ICONS_DIR, "add_label.PNG")
	toolbar.add_item add_label_cmd
	
	# Copy shape command
	copy_shape_cmd = UI::Command.new("copy_shape"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active
		
		prompts = ["Origin Rule ID  ", "Origin Rule part  ", "Destiny Rule ID  ", "Destiny rule part "]
		default = ["1", Constants::LEFT, "1", Constants::RIGHT]
		rule_list = ShadeUtils.create_rule_list()
		list = [rule_list, "#{Constants::LEFT}|#{Constants::RIGHT}", rule_list, "#{Constants::LEFT}|#{Constants::RIGHT}"]
		input = UI.inputbox prompts, default, list, "Copy shape:"
		if input
			origin_rule_idx = input[0].to_i - 1
			origin_rule_part = input[1]
			destiny_rule_idx = input[2].to_i - 1
			destiny_rule_part = input[3]
			ShadeUtils.copy_shape(origin_rule_idx, origin_rule_part, destiny_rule_idx, destiny_rule_part)
			project.refresh
		end
	}
	copy_shape_cmd.tooltip = "Copy shape"
	copy_shape_cmd.small_icon = File.join(Constants::ICONS_DIR, "copy_shape.PNG")
	copy_shape_cmd.large_icon = File.join(Constants::ICONS_DIR, "copy_shape.PNG")
	toolbar.add_item copy_shape_cmd
  
	# Add shape box command
	add_shape_box_command = UI::Command.new("add_shape_box"){
		Sketchup.active_model.close_active
		prompts = ["Rule ID ", "Rule part "]
		default = ["1", "Left"]
		rule_list = ShadeUtils.create_rule_list()
		list = [rule_list, "Left|Right"]
		input = UI.inputbox prompts, default, list, "Choose shape:"
		
		if input
			rule_idx = input[0].to_i - 1
			# Transform the layout transformation of the shapes
			t = Geom::Transformation.new
			rule_idx.times do
				t = Constants::DESCEND_T * t
			end

			rule = Shade.project.execution.grammar.rules[rule_idx]
			if input[1] == "Left"
				t = Constants::LEFT_T * t
				rule.alpha.erase
				rule.alpha = ShadeUtils.create_default_left_shape    
				rule.alpha.layout_transformation =  t
				rule.alpha.paint
				if ((rule_idx == 0) and (!Shade.project.execution.file_axiom))
					new_axiom = ShadeUtils.create_default_axiom
					Shade.project.execution.grammar.axiom = new_axiom
					Shade.project.execution.reset
				end
			else
				t = Constants::RIGHT_T * t
				rule.beta.erase
				rule.beta= ShadeUtils.create_default_right_shape    
				rule.beta.layout_transformation =  t
				rule.beta.paint
			end
		end
	}
	add_shape_box_command.tooltip = "Add Shape Box"
	add_shape_box_command.small_icon = File.join(Constants::ICONS_DIR, "create_shape_box.PNG")
	add_shape_box_command.large_icon = File.join(Constants::ICONS_DIR, "create_shape_box.PNG")
	toolbar.add_item add_shape_box_command
	
	toolbar.add_separator
	
	# Load shape command
	load_shape_cmd = UI::Command.new("load_shape"){
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
	}
	load_shape_cmd.tooltip = "Load shape"
	load_shape_cmd.small_icon = File.join(Constants::ICONS_DIR, "load_shape.PNG")
	load_shape_cmd.large_icon = File.join(Constants::ICONS_DIR, "load_shape.PNG")
	toolbar.add_item load_shape_cmd
	
	# Save shape command
	save_shape_cmd = UI::Command.new("save_shape"){
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
	}
	save_shape_cmd.tooltip = "Save shape"
	save_shape_cmd.small_icon = File.join(Constants::ICONS_DIR, "save_shape.PNG")
	save_shape_cmd.large_icon = File.join(Constants::ICONS_DIR, "save_shape.PNG")
	toolbar.add_item save_shape_cmd
	
	toolbar.add_separator
	
	# About command
	about_cmd = UI::Command.new("about"){
		UI.messagebox("ShaDe v#{Constants::VERSION}\nAll rights reserved\nFor research use only \n(c) Manuela Ruiz Montiel, Fernando López Romero \nand Universidad de Malaga")
	}
	about_cmd.tooltip = "About"
	about_cmd.small_icon = File.join(Constants::ICONS_DIR, "about.PNG")
	about_cmd.large_icon = File.join(Constants::ICONS_DIR, "about.PNG") 
	toolbar.add_item about_cmd
	
	toolbar.show
end

#Method that creates the toolbar for performing execution tasks 
def create_execution_toolbar()
 
	toolbar = UI.toolbar Constants::EXECUTION_TOOLBAR_NAME
	
	# Load Axiom command
	load_axiom_cmd = UI::Command.new("load_axiom"){
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
	}
	load_axiom_cmd.tooltip = "Load Axiom"
	load_axiom_cmd.small_icon = File.join(Constants::ICONS_DIR, "load_axiom.PNG")
	load_axiom_cmd.large_icon = File.join(Constants::ICONS_DIR, "load_axiom.PNG")
	toolbar.add_item load_axiom_cmd
	
	# First-Rule Axiom command
	first_rule_axiom_cmd = UI::Command.new("first_rule_axiom"){
		execution = Shade.project.execution
		execution.file_axiom = false
		rule = execution.grammar.rules[0]
		# Add new axiom			
		new_axiom = LabelledShape.new(Array.new, Array.new)
		Sketchup.active_model.layers.each { |layer|
			new_axiom.p[layer.name] = rule.left.p[layer.name].clone
			new_axiom.s[layer.name] = rule.left.s[layer.name].clone
		}
		execution.grammar.axiom = new_axiom
		
		execution.reset
	}
	first_rule_axiom_cmd.tooltip = "Set the axiom to the first-rule-left shape"
	first_rule_axiom_cmd.small_icon = File.join(Constants::ICONS_DIR, "first_rule_axiom.PNG")
	first_rule_axiom_cmd.large_icon = File.join(Constants::ICONS_DIR, "first_rule_axiom.PNG")
	toolbar.add_item first_rule_axiom_cmd
	
	toolbar.add_separator
  
	# Execute command
	exe_cmd = UI::Command.new("apply_rule"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active

		prompts = ["Chosen rule id"]
		default = [1]
		rule_list = ShadeUtils.create_rule_list()
		list = [rule_list]
		input = UI.inputbox prompts, default, list, "Apply Rule"
		if input
			chosen_rule_idx = input[0]
			chosen_rule_id = execution.grammar.rules[chosen_rule_idx.to_i - 1].rule_id
			
			if Shade.execution_environment_flag() 
  			#STEP 1: Save temp files
  			save_temp_files()
  			
  			#STEP 2: Call external command with argument: chosen_rule_id
  			command_directory = "#{File.dirname(__FILE__)}/#{Constants::COMMANDS_DIR}/execute-command.rb"
  			command_directory.gsub!("/", "\\")
  			output = system("ruby \"#{command_directory}\" #{chosen_rule_id}")
  			
  			#STEP 3: Catch return from external command
  			if !($? == 0)
  				UI.messagebox("The loaded constraints/goals use some functions of SketchUp API. The execution will be performed inside the SketchUp environment, and it may take more time.")
  				#puts output
  				
          success = execution.apply_rule(chosen_rule_id)
  				
  				if !success
  					UI.messagebox("The rule cannot be applied")
  				end
  			else
  				log_directory = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/result.log"
  				log_directory.gsub!("/", "\\")
  				File.open(log_directory, 'r') do |f|
  					line = f.gets.strip
  					if (line == "true")
  						load_temp_files()
  					elsif (line == "false")
  						UI.messagebox("The rule cannot be applied")
  					end
  				end
  			end
			else
       success = execution.apply_rule(chosen_rule_id)
        if !success
          UI.messagebox("The rule cannot be applied")
        end
			end
			
			#STEP 4: delete files of temporal directory
			delete_temp_files()
		end
	}
	exe_cmd.tooltip = "Apply rule"
	exe_cmd.small_icon = File.join(Constants::ICONS_DIR, "execute.PNG")
	exe_cmd.large_icon = File.join(Constants::ICONS_DIR, "execute.PNG")
	toolbar.add_item exe_cmd
	
	# Ramdom Execute command
	rand_exe_cmd = UI::Command.new("apply_random_rule"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active
		
		if Shade.execution_environment_flag() 
    		#STEP 1: Save temp files
    		save_temp_files()
    		
    		#STEP 2: Call external command with argument: chosen_rule_id
    		command_directory = "#{File.dirname(__FILE__)}/#{Constants::COMMANDS_DIR}/execute-random-command.rb"
    		command_directory.gsub!("/", "\\")
    		system("ruby \"#{command_directory}\"")
    
    		#STEP 3: Catch return from external command
    		if !($? == 0)
    			UI.messagebox("The loaded constraints/goals use some functions of SketchUp API. The execution will be performed inside the SketchUp environment, and it may take more time.")
    			success = execution.apply_rule_random()
    			if !success
    				UI.messagebox("No rule can be applied")
    			end
    		else
    			log_directory = "#{File.dirname(__FILE__)}/#{Constants::TEMP_DIR}/result.log"
    			log_directory.gsub!("/", "\\")
    			File.open(log_directory, 'r') do |f|
    				line = f.gets.strip
    				if (line == "true")
    					load_temp_files()
    				elsif (line == "false")
    					UI.messagebox("No rule can be applied")
    				end
    			end	
    		end
		else
      success = execution.apply_rule_random()
      if !success
        UI.messagebox("No rule can be applied")
      end
		end
		
		
		#STEP 4: delete files of temporal directory
		delete_temp_files()
	}
	rand_exe_cmd.tooltip = "Apply random rule"
	rand_exe_cmd.small_icon = File.join(Constants::ICONS_DIR, "execute_random.PNG")
	rand_exe_cmd.large_icon = File.join(Constants::ICONS_DIR, "execute_random.PNG")
	toolbar.add_item rand_exe_cmd
	
	# Undo step command
	undo_step_cmd = UI::Command.new("undo_step"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active
		
		execution.undo
	}
	undo_step_cmd.tooltip = "Undo Step"
	undo_step_cmd.small_icon = File.join(Constants::ICONS_DIR, "undo.PNG")
	undo_step_cmd.large_icon = File.join(Constants::ICONS_DIR, "undo.PNG")
	toolbar.add_item undo_step_cmd
	
	# Reset command
	reset_cmd = UI::Command.new("reset"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active
		
		execution.reset
	}
	reset_cmd.tooltip = "Reset"
	reset_cmd.small_icon = File.join(Constants::ICONS_DIR, "reset.PNG")
	reset_cmd.large_icon = File.join(Constants::ICONS_DIR, "reset.PNG")
	toolbar.add_item reset_cmd
	
	toolbar.add_separator
	
	#Custom epsilon
	custom_epsilon_cmd = UI::Command.new("custom_epsilon"){
		# Find and show our html file
		html_path = Sketchup.find_support_file "GUIDialogEpsilon.html" ,Constants::HTML_DIR
		name_dialog = create_choose_epsilon_dialog
		name_dialog.set_file(html_path)
		name_dialog.show()
	}
	custom_epsilon_cmd.tooltip = "Custom epsilon"
	custom_epsilon_cmd.small_icon = File.join(Constants::ICONS_DIR, "epsilon.PNG")
	custom_epsilon_cmd.large_icon = File.join(Constants::ICONS_DIR, "epsilon.PNG")
	toolbar.add_item custom_epsilon_cmd
	
#	#mu_min
#  mu_min_cmd = UI::Command.new("mu_min"){
#    prompts = ["Mu_min"]
#    default = [0.5]
#    list = [""]
#    input = UI.inputbox prompts, default, list, "Mu_min"
#    if input
#      Shade.mu_min = input[0]
#      project = Shade.project
#      execution = Shade.project.execution
#      Sketchup.active_model.close_active    
#      project.refresh(true)
#    end
#  }
#  mu_min_cmd.tooltip = "Mu_min"
#  mu_min_cmd.small_icon = File.join(Constants::ICONS_DIR, "Mu.PNG")
#  mu_min_cmd.large_icon = File.join(Constants::ICONS_DIR, "Mu.PNG")
#  toolbar.add_item mu_min_cmd
	
	
	
	#current parameters (epsilon, hausdorff_threshold)
  current_parameters_cmd = UI::Command.new("current_parameters"){
    prompts = ["Current_parameters"]
    epsilon = Shade.custom_epsilon
#    hausdorff = Shade.hausdorff_threshold
#    mu_min = Shade.mu_min
    mu = ShadeUtils.current_shape.mu["Layer0"]
    
#    muString = "\n"
#    mu.each{|key, value|
#      muString = muString.concat("#{key} #{value}")
#    }
    
  #  UI.messagebox "ɛ = #{epsilon} \nHt = #{hausdorff}\nMu min = #{mu_min}\nMu = ".concat(muString) , MB_MULTILINE
    UI.messagebox "ɛ = #{epsilon}\nMu = #{mu}", MB_MULTILINE
    
  }
  current_parameters_cmd.tooltip = "Current_parameters"
  current_parameters_cmd.small_icon = File.join(Constants::ICONS_DIR, "barras.PNG")
  current_parameters_cmd.large_icon = File.join(Constants::ICONS_DIR, "barras.PNG")
  toolbar.add_item current_parameters_cmd
	
  #execution_environment
  current_execution_flag_cmd = UI::Command.new("current_execution_flag"){
    prompts = ["Current_execution_flag"]
    eeflag = Shade.execution_environment_flag
    
    UI.messagebox "Execution environment flag = #{eeflag} \n\nflag = true (run rules outside sketchup)\nflag = false (run rules into sketchup)" , MB_MULTILINE
    
  }
  current_execution_flag_cmd.tooltip = "Current_execution_flag"
  current_execution_flag_cmd.small_icon = File.join(Constants::ICONS_DIR, "environment.PNG")
  current_execution_flag_cmd.large_icon = File.join(Constants::ICONS_DIR, "environment.PNG")
  toolbar.add_item current_execution_flag_cmd
  
  
  #change execution_environment
  change_execution_flag_cmd = UI::Command.new("change_execution_flag"){
    prompts = ["Change_execution_flag"]
    eeflag = Shade.execution_environment_flag
   
   result = UI.messagebox "Do you want to run rules outside sketchup?" , MB_YESNO
   if result == 6
     Shade.execution_environment_flag=(true)
   else
     Shade.execution_environment_flag=(false)
   end
  
  }
  change_execution_flag_cmd.tooltip = "Change_execution_flag"
  change_execution_flag_cmd.small_icon = File.join(Constants::ICONS_DIR, "changeenvironment.PNG")
  change_execution_flag_cmd.large_icon = File.join(Constants::ICONS_DIR, "changeenvironment.PNG")
  toolbar.add_item change_execution_flag_cmd
  
   toolbar.add_separator
	
	#Show labels command
	show_cmd = UI::Command.new("show_labels"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active
		execution.show_labels = true
		project.refresh()
	}
	show_cmd.tooltip = "Show labels"
	show_cmd.small_icon = File.join(Constants::ICONS_DIR, "show_labels.PNG")
	show_cmd.large_icon = File.join(Constants::ICONS_DIR, "show_labels.PNG")
	toolbar.add_item show_cmd
	
	#Hide labels command
	hide_cmd = UI::Command.new("hide_labels"){
		project = Shade.project
		execution = Shade.project.execution
		Sketchup.active_model.close_active		
		execution.show_labels = false
		project.refresh()
	}
	hide_cmd.tooltip = "Hide labels"
	hide_cmd.small_icon = File.join(Constants::ICONS_DIR, "hide_labels.PNG")
	hide_cmd.large_icon = File.join(Constants::ICONS_DIR, "hide_labels.PNG")
	toolbar.add_item hide_cmd
	
	#Change size of labels command
	change_label_radius_cmd = UI::Command.new("change_label_radius"){
		prompts = ["New radius (between 0.1 and 0.9)"]
		default = [0.5]
		list = [""]
		input = UI.inputbox prompts, default, list, "New radius of labels"
		if input
			Shade.label_radius = input[0].to_f.m
			project = Shade.project
			execution = Shade.project.execution
			Sketchup.active_model.close_active		
			project.refresh(true)
		end
	}
	change_label_radius_cmd.tooltip = "Change label radius"
	change_label_radius_cmd.small_icon = File.join(Constants::ICONS_DIR, "change_label_radius.PNG")
	change_label_radius_cmd.large_icon = File.join(Constants::ICONS_DIR, "change_label_radius.PNG")
	toolbar.add_item change_label_radius_cmd
	
	toolbar.add_separator
	
	# Save Design command
	save_design_cmd = UI::Command.new("save_design"){
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
	}
	save_design_cmd.tooltip = "Save Design"
	save_design_cmd.small_icon = File.join(Constants::ICONS_DIR, "save_design.PNG")
	save_design_cmd.large_icon = File.join(Constants::ICONS_DIR, "save_design.PNG")
	toolbar.add_item save_design_cmd
	
	toolbar.add_separator

	toolbar.show
end


