begin
	require 'sketchup' # First we pull in the standard API hooks.
	require 'ShaDe//lib//main-structures.rb'
	require 'ShaDe//lib//geometry.rb'
	require 'ShaDe//lib//data-structures.rb'
rescue LoadError
	require "#{File.dirname(__FILE__)}/main-structures"
	require "#{File.dirname(__FILE__)}/geometry"
	require "#{File.dirname(__FILE__)}/data-structures"
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class holds the constants used along the application
class Constants

	begin
		#Inside this begin block we define the constants used by SketchUp
		# Points for the default left shape for the rules (squares)
		PTS_1 = []
		PTS_1[0] = Geom::Point3d.new(0.m, 0.m, 0.m)
		PTS_1[1] = Geom::Point3d.new(0.m, 8.m, 0.m)
		PTS_1[2] = Geom::Point3d.new(8.m, 8.m, 0.m)
		PTS_1[3] = Geom::Point3d.new(8.m, 0.m, 0.m)
		
		# Points for the default right shape for the rules (squares)
		PTS_2 = []
		PTS_2[0] = Geom::Point3d.new(4.m, 4.m, 0.m)
		PTS_2[1] = Geom::Point3d.new(4.m, 12.m, 0.m)
		PTS_2[2] = Geom::Point3d.new(12.m, 12.m, 0.m)
		PTS_2[3] = Geom::Point3d.new(12.m, 4.m, 0.m)
	
		vector_translation = Geom::Vector3d.new -18.m,0.m,0.m
		# Default transformation for the left side of the rules
		LEFT_T = Geom::Transformation.translation vector_translation
		
		vector_translation = Geom::Vector3d.new 18.m,0.m,0.m
		# Default transformation for the right (without additive) side of the rules
		RIGHT_T = Geom::Transformation.translation vector_translation
		
		# Default transformation for the additive (without right) side of the rules
		ADDITIVE_T = RIGHT_T
		
		vector_circle = Geom::Vector3d.new 0.m,0.m,1.m
		#Vector for painting the labels
		LABEL_VECTOR = vector_circle.normalize!
		
		vector_translation = Geom::Vector3d.new 10.m,0.m,0.m
		translation = Geom::Transformation.translation vector_translation
		vector_rotation = Geom::Vector3d.new 0.m,0.m,1.m
		angle = 1
		rotation = Geom::Transformation.rotation PTS_1[0], vector_rotation, angle
		# Default rule transformation
		RULE_T = translation * rotation
		
		vector_translation = Geom::Vector3d.new 100.m,-20.m,0.m
		# Transformation for the axiom of the grammar
		AXIOM_T = Geom::Transformation.translation vector_translation
		
		# Default alpha for the materials
		ALPHA = 0.5
		
		# Default radius for the labels
		LABEL_RADIUS = (0.5).m
		
		# Default color for the shapes
		DEFAULT_COLOR = "White"
		
		# Static Toolbar name
		STATIC_TOOLBAR_NAME = "ShaDe - Edition toolbar"
		
		# Execution Toolbar name
		EXECUTION_TOOLBAR_NAME = "ShaDe - Execution toolbar"
		
		# Guidance Toolbar name
		GUIDANCE_TOOLBAR_NAME = "ShaDe - Guide Execution toolbar"
		
		# Grammar title point
		PT_GRAMMAR_TEXT = [0.m, 40.m, 0.m]
		
		# Grammar default title
		DEFAULT_GRAMMAR_TITLE = "Untitled"
		
		# Project title point
		PT_PROJECT_TEXT = [0.m, 40.m, 0.m]
		
		# Initial Points for the arrows
		PTS_ARROW = []
		PTS_ARROW[0] = [12.m, 4.m, 0.m]
		PTS_ARROW[1] = [15.m, 4.m, 0.m]
		PTS_ARROW[2] = [14.m, 5.m, 0.m]
		PTS_ARROW[3] = [14.m, 3.m, 0.m]
		
		# Initial Points for the origin references
		PTS_ORIGIN = []
		PTS_ORIGIN[0] = [-1.m,0.m, 0.m]
		PTS_ORIGIN[1] = [0.m,1.m, 0.m]
		PTS_ORIGIN[2] = [1.m,0.m, 0.m]
		PTS_ORIGIN[3] = [0.m,-1.m, 0.m]
		
		# Initial Points for the horizontal line
		PTS_H = []
		PTS_H[0] = [-100.m,-15.m,0.m]
		PTS_H[1] = [50.m,-15.m,0.m]
		
		# Points for the vertical line
		PTS_V = []
		PTS_V[0] = [50.m,100.m,0.m]
		PTS_V[1] = [50.m,-1000.m,0.m]
		
		# Initial Point for the rule titles
		PT_RULE_TEXT = [40.m,-12.5.m,0.m]
		
		# Point for the design title
		PT_DESIGN_TEXT = [51.m,40.m,0.m]
		
		vector_translation = Geom::Vector3d.new 0.m,-36.m,0.m
		# Iterative transformation for the rule elements, in order to descend along the screen
		DESCEND_T = Geom::Transformation.translation vector_translation
		
		#Delay time when seeing backtracking steps
		DELAY_TIME = 0.2
		
		#Initial height of the camera
		INITIAL_Z_CAMERA = 200.m
	rescue 
		remove_const("PTS_1")
		# Points for the default left shape for the rules (squares), in case we are not using SketchUp
		PTS_1 = []
		PTS_1[0] = Point.new(0, 0, 0)
		PTS_1[1] = Point.new(0, 8, 0)
		PTS_1[2] = Point.new(8, 8, 0)
		PTS_1[3] = Point.new(8, 0, 0)
		
		# Points for the default right shape for the rules (squares),  in case we are not using SketchUp
		PTS_2 = []
		PTS_2[0] = Point.new(4, 4, 0)
		PTS_2[1] = Point.new(4, 12, 0)
		PTS_2[2] = Point.new(12, 12, 0)
		PTS_2[3] = Point.new(12, 4, 0)
	end
	
	#Version
	VERSION = "4.0"
		
	# Default relative (to guitools.rb) Icons directory
	ICONS_DIR = "../resources/shade_icons"
	
	# Default absolute Icons directory
	ABS_ICONS_DIR = "lib/resources/shade_icons"
	
	# Default html dialogs directory
	HTML_DIR = "Plugins//ShaDe//lib//interfaces//html"
	
	# Default lib directory
	LIB_DIR= "Plugins/ShaDe/lib"
	
	#Default startup file name
	STARTUP_FILE_NAME = "startup.rb"
	
	#Default relative  (to guitools.rb)  temp directory
	TEMP_DIR = "../commands/temp"
	
	#Default relative  (to guitools.rb)  commands directory
	COMMANDS_DIR = "../commands"
	
	# Project default title
	DEFAULT_PROJECT_TITLE = "Untitled"
	
	#Shape file extension
	SHAPE_EXTENSION = "sh2"
	
	#Grammar file extension
	GRAMMAR_EXTENSION = "gr2"
	
	#Project file extension
	PROJECT_EXTENSION = "prj"

	#Epsilon for comparing arrays
	EPSILON = 0.01

	#Balance factor for BBTree when the left subtree is taller
	LEFT_TALLER = -1
	#Balance factor for BBTree when the right subtree is taller
	RIGHT_TALLER = +1
	#Balance factor for BBTree when the subtrees are balanced
	BALANCED = 0
	
	#For the LabelledShape.shape_expression algorithm, in order to 
	#determine wether we are working with colinear segments
	SEGMENTS = "Segments"
	
	#For the LabelledShape.shape_expression algorithm, in order to 
	#determine wether we are working with points with the same label
	POINTS = "Points"
	
	#For the LabelledShape.shape_expression algorithm, in order to 
	#distinguish the 'union' operation
	UNION = "Union"
	
	#For the LabelledShape.shape_expression algorithm, in order to 
	#distinguish the 'intersection' operation
	INTERSECTION = "Intersection"
	
	#For the LabelledShape.shape_expression algorithm, in order to 
	#distinguish the 'difference' operation
	DIFFERENCE = "Difference"
	
	#For the LabelledShape.shape_expression algorithm, in order to 
	#distinguish the 'subshape' relation
	SUBSHAPE = "Subshape"
	
	#For the LabelledShape.shape_expression algorithm, in order to 
	#distinguish the 'equal' relation
	EQUAL = "Equal"
	
	#For controlling the beggining of the iterators in trees and lists
	START = "Start"
	
	#The name for the intersection label
	INTERSECTION_LABEL = "Intersection_Label"
	
	#The name for the left part of the rule
	LEFT = "Left"
	
	#The name for the right part of the rule
	RIGHT = "Right"
	
	#Array with the recognized colors
	RECOGNIZED_COLORS = ["AliceBlue", "AntiqueWhite", "Aqua", "Aquamarine", "Azure", "Beige", "Bisque", "Black", "BlanchedAlmond", "Blue", "BlueViolet", "Brown", "BurlyWood", "CadetBlue", "Chartreuse", "Chocolate", "Coral", "CornflowerBlue", "Cornsilk", "Crimson", "Cyan", "DarkBlue", "DarkCyan", "DarkGoldenrod", "DarkGray", "DarkGreen", "DarkKhaki", "DarkMagenta", "DarkOliveGreen", "DarkOrange", "DarkOrchid", "DarkRed", "DarkSalmon", "DarkSeaGreen", "DarkSlateBlue", "DarkSlateGray", "DarkTurquoise", "DarkViolet", "DeepPink", "DeepSkyBlue", "DimGray", "DodgerBlue", "FireBrick", "FloralWhite", "ForestGreen", "Fuchsia", "Gainsboro", "GhostWhite", "Gold", "Goldenrod", "Gray", "Green", "GreenYellow", "Honeydew", "HotPink", "IndianRed", "Indigo", "Ivory", "Khaki", "Lavender", "LavenderBlush", "LawnGreen", "LemonChiffon", "LightBlue", "LightCoral", "LightCyan", "LightGoldenrodYellow", "LightGreen", "LightGrey", "LightPink", "LightSalmon", "LightSeaGreen", "LightSkyBlue", "LightSlateGray", "LightSteelBlue", "LightYellow", "Lime", "LimeGreen", "Linen", "Magenta", "Maroon", "MediumAquamarine", "MediumBlue", "MediumOrchid", "MediumPurple", "MediumSeaGreen", "MediumSlateBlue", "MediumSpringGreen", "MediumTurquoise", "MediumVioletRed", "MidnightBlue", "MintCream", "MistyRose", "Moccasin", "NavajoWhite", "Navy", "OldLace", "Olive", "OliveDrab", "Orange", "OrangeRed", "Orchid", "PaleGoldenrod", "PaleGreen", "PaleTurquoise", "PaleVioletRed", "PapayaWhip", "PeachPuff", "Peru", "Pink", "Plum", "PowderBlue", "Purple", "Red", "RosyBrown", "RoyalBlue", "SaddleBrown", "Salmon", "SandyBrown", "SeaGreen", "Seashell", "Sienna", "Silver", "SkyBlue", "SlateBlue", "SlateGray", "Snow", "SpringGreen", "SteelBlue", "Tan", "Teal", "Thistle", "Tomato", "Turquoise", "Violet", "Wheat", "White", "WhiteSmoke", "Yellow", "YellowGreen"]
end


#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#Utils class
class ShadeUtils
	
	def ShadeUtils.initialize_command
		Shade.using_sketchup = false

		#Create the project
		ShadeUtils.create_default_project

		project_directory = "#{File.dirname(__FILE__)}/commands/temp/project.txt"
		Shade.project.load(project_directory.gsub("/", "\\"))

		Shade.project.execution.reset

		current_shape_directory = "#{File.dirname(__FILE__)}/commands/temp/current_shape.txt"
		Shade.project.execution.current_shape.load(current_shape_directory.gsub("/", "\\"))
		Shade.project.execution.current_shape.create_pi

		history_directory = "#{File.dirname(__FILE__)}/commands/temp"
		history_directory.gsub!("/", "\\")
		Shade.project.execution.load_execution_history(history_directory)
		
		epsilon_path = "#{File.dirname(__FILE__)}/commands/temp/epsilon.txt"
		if File.exist? "#{epsilon_path}"
			File.open("#{epsilon_path}", 'r') do |f|
				while (line = f.gets)
					Shade.custom_epsilon = line.to_f
				end
			end
		end
		
		hausdorff_path = "#{File.dirname(__FILE__)}/commands/temp/hausdorff.txt"
		if File.exist? "#{hausdorff_path}"
			File.open("#{hausdorff_path}", 'r') do |f|
					htx = f.gets.to_f
					hty = f.gets.to_f
					Shade.hausdorff_threshold_sets(htx, hty)	
			end
		end
		
    mu_min_path = "#{File.dirname(__FILE__)}/commands/temp/mu_min.txt"
    if File.exist? "#{mu_min_path}"
      File.open("#{mu_min_path}", 'r') do |f|
        while (line = f.gets)
          Shade.mu_min = line.to_f
        end
      end
    end
		
    
    mu_path = "#{File.dirname(__FILE__)}/commands/temp/mu.txt"
    if File.exist? "#{mu_path}"
      File.open("#{mu_path}", 'r') do |f|
        while (line = f.gets)
          sLine = line.split
          key = sLine[0]
          value = sLine[1]
          Shade.project.execution.current_shape.mu[key] = value.to_f
        end
      end
    end
		
		#Delete files of temporal directory
   dir = Dir.new("#{File.dirname(__FILE__)}/commands/temp")
		dir.each { |file_name|
			if file_name == '.' or file_name == '..' then next
			else File.delete("#{File.dirname(__FILE__)}/commands/temp/#{file_name}")
			end
		}
	end
	
	def ShadeUtils.finish_command(n_applied)
    log_directory = "#{File.dirname(__FILE__)}/commands/temp/result.log"
    current_shape_directory = "#{File.dirname(__FILE__)}/commands/temp/current_shape.txt"
    history_directory = "#{File.dirname(__FILE__)}/commands/temp"
    
    if n_applied
      Shade.project.execution.current_shape.save(current_shape_directory.gsub("/", "\\"))
      File.open(log_directory.gsub("/", "\\"), 'w') do |f|
        f.write "#{Shade.project.execution.backtracking_steps}"
      end
      Shade.project.execution.save_execution_history(history_directory)
      
      mu_path = "#{File.dirname(__FILE__)}/commands/temp/mu.txt"
        File.open(mu_path.gsub("/", "\\"), 'w') do |f|
          Shade.project.execution.current_shape.mu.each{|key, value|
            f.write "#{key} #{value}"
          }
        end
      
    else
      File.open(log_directory.gsub("/", "\\"), 'w') do |f|
        f.write "false"
      end
    end
	end
	
	def ShadeUtils.finish_command2(result)
    log_directory = "#{File.dirname(__FILE__)}/commands/temp/result.log"
    current_shape_directory = "#{File.dirname(__FILE__)}/commands/temp/current_shape.txt"
    history_directory = "#{File.dirname(__FILE__)}/commands/temp"
    
    if result
      Shade.project.execution.current_shape.save(current_shape_directory.gsub("/", "\\"))
      File.open(log_directory.gsub("/", "\\"), 'w') do |f|
        f.write "true"
      end
      Shade.project.execution.save_execution_history(history_directory)
      
      mu_path = "#{File.dirname(__FILE__)}/commands/temp/mu.txt"
      File.open(mu_path.gsub("/", "\\"), 'w') do |f|
        #f.write Shade.project.execution.current_shape.mu
        Shade.project.execution.current_shape.mu.each{|key, value|
          f.write "#{key} #{value}"
        }
      end
      
    else
      File.open(log_directory.gsub("/", "\\"), 'w') do |f|
        f.write "false"
      end
    end
	end
	
	
	
	
	
	
	
	#point:: a Point object
	#segment:: a Segment object
	#
	#returns:: the distance, in meters, from point to segment (ortogonally projected)
	def ShadeUtils.point_segment_distance(point, segment)
		projected_point = OrderedPoint.new(point.project_to_line(segment.line_descriptor, segment.tail, segment.head))
		if segment.coincident? projected_point
			distance = point.distance(projected_point.point)
		else
			distance_start = point.distance(segment.tail.point)
			distance_end = point.distance(segment.head.point)
			distance = distance_end
			if distance_start < distance_end
				distance = distance_start
			end
		end
		return distance
	end
	
	#point:: a Point object
	#segment:: a Segment object
	#
	#returns:: the distance, in meters, from point to segment (ortogonally projected)
	def ShadeUtils.is_projected?(point, segment)
		result = false
		projected_point = OrderedPoint.new(point.project_to_line(segment.line_descriptor, segment.tail, segment.head))
		if segment.coincident? projected_point
			result = true
		end
		return result
	end
	
	#Shows a dialog for saving the project
	def ShadeUtils.ask_to_save_project()
		if Shade.using_sketchup
			project = Shade.project
			if !project.saved
				input = UI.messagebox("Save current project?", MB_YESNO)
				if input == 6
					if project.path
						project.save(project.path, true)
						project.saved = true
					else
						path_to_save_to = UI.savepanel "Save Project", "", "project.prj"
						if path_to_save_to
							project.save(path_to_save_to, true)
						end
						project.saved = true
					end
				end
				
			end
		end
	end

	#returns:: a default axiom
	def ShadeUtils.create_default_axiom()
		axiom = LabelledShape.new(Array.new, Array.new)
		segments = Array.new
		segments[0] = Segment.new(OrderedPoint.new(Constants::PTS_1[0].clone), OrderedPoint.new(Constants::PTS_1[1].clone))
		segments[1] = Segment.new(OrderedPoint.new(Constants::PTS_1[1].clone), OrderedPoint.new(Constants::PTS_1[2].clone))
		segments[2] = Segment.new(OrderedPoint.new(Constants::PTS_1[2].clone), OrderedPoint.new(Constants::PTS_1[3].clone))
		segments[3] = Segment.new(OrderedPoint.new(Constants::PTS_1[3].clone), OrderedPoint.new(Constants::PTS_1[0].clone))
		
		if Shade.using_sketchup
			Sketchup.active_model.layers.each { |layer|
				segments.each { |segment|
					segment_list = LinearLinkedList.new

					node = LinearLinkedListNode.new(segment.line_descriptor.clone, segment_list, nil)
					
					inserted_node = axiom.s[layer.name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment
					segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
					inserted_node.list.insert_node(segment_node)
				}
				
				Constants::PTS_1.each {|point|
					label = Label.new(Constants::INTERSECTION_LABEL)
					point_list = LinearLinkedList.new
					
					node = LinearLinkedListNode.new(label, point_list, nil)
					
					inserted_node = axiom.p[layer.name].insert_node(node) #Insert the node corresponding to the label of the point
				
					point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
					inserted_node.list.insert_node(point_node) #Insert the point node
				}
			}
		else
			segments.each { |segment|
				segment_list = LinearLinkedList.new

				node = LinearLinkedListNode.new(segment.line_descriptor.clone, segment_list, nil)
				
				inserted_node = axiom.s["Layer0"].insert_node(node) #Insert the node corresponding to the line descriptor of the segment
				segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
				inserted_node.list.insert_node(segment_node)
			}
			
			Constants::PTS_1.each {|point|
				label = Label.new(Constants::INTERSECTION_LABEL)
				point_list = LinearLinkedList.new
				
				node = LinearLinkedListNode.new(label, point_list, nil)
				
				inserted_node = axiom.p["Layer0"].insert_node(node) #Insert the node corresponding to the label of the point
			
				point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
				inserted_node.list.insert_node(point_node) #Insert the point node
			}
		end
		return axiom
	end
	
	
	#returns:: a default current shape
	def ShadeUtils.create_default_current_shape()
		current_shape = CurrentLabelledShape.new(Array.new, Array.new)
		segments = Array.new
		segments[0] = Segment.new(OrderedPoint.new(Constants::PTS_1[0].clone), OrderedPoint.new(Constants::PTS_1[1].clone))
		segments[1] = Segment.new(OrderedPoint.new(Constants::PTS_1[1].clone), OrderedPoint.new(Constants::PTS_1[2].clone))
		segments[2] = Segment.new(OrderedPoint.new(Constants::PTS_1[2].clone), OrderedPoint.new(Constants::PTS_1[3].clone))
		segments[3] = Segment.new(OrderedPoint.new(Constants::PTS_1[3].clone), OrderedPoint.new(Constants::PTS_1[0].clone))
		
		if Shade.using_sketchup
			Sketchup.active_model.layers.each { |layer|
				segments.each { |segment|
					segment_list = LinearLinkedList.new

					node = BalancedBinaryTreeNode.new(0, nil, nil, segment.line_descriptor.clone, segment_list)
					
					inserted_node = current_shape.s[layer.name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment
					segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
					inserted_node.list.insert_node(segment_node)
				}
				
				
				Constants::PTS_1.each {|point|
					label = Label.new(Constants::INTERSECTION_LABEL)
					point_list = LinearLinkedList.new
					
					node = LinearLinkedListNode.new(label, point_list, nil)
					
					inserted_node = current_shape.p[layer.name].insert_node(node) #Insert the node corresponding to the label of the point
				
					point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
					inserted_node.list.insert_node(point_node) #Insert the point node
				}
			}
		else
			segments.each { |segment|
				segment_list = LinearLinkedList.new

				node = BalancedBinaryTreeNode.new(0, nil, nil, segment.line_descriptor.clone, segment_list)
				
				inserted_node = current_shape.s["Layer0"].insert_node(node) #Insert the node corresponding to the line descriptor of the segment
				segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
				inserted_node.list.insert_node(segment_node)
			}
			
			
			Constants::PTS_1.each {|point|
				label = Label.new(Constants::INTERSECTION_LABEL)
				point_list = LinearLinkedList.new
				
				node = LinearLinkedListNode.new(label, point_list, nil)
				
				inserted_node = current_shape.p["Layer0"].insert_node(node) #Insert the node corresponding to the label of the point
			
				point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
				inserted_node.list.insert_node(point_node) #Insert the point node
			}
		end
		current_shape.create_pi
		return current_shape
	end
	
	#returns:: a default left shape for the rules
	def ShadeUtils.create_default_left_shape()
		shape = RuleLabelledShape.new(Array.new, Array.new, nil, nil)
		segments = Array.new
		segments[0] = Segment.new(OrderedPoint.new(Constants::PTS_1[0].clone), OrderedPoint.new(Constants::PTS_1[1].clone))
		segments[1] = Segment.new(OrderedPoint.new(Constants::PTS_1[1].clone), OrderedPoint.new(Constants::PTS_1[2].clone))
		segments[2] = Segment.new(OrderedPoint.new(Constants::PTS_1[2].clone), OrderedPoint.new(Constants::PTS_1[3].clone))
		segments[3] = Segment.new(OrderedPoint.new(Constants::PTS_1[3].clone), OrderedPoint.new(Constants::PTS_1[0].clone))
		
		if Shade.using_sketchup
			Sketchup.active_model.layers.each { |layer|
				segments.each { |segment|
					segment_list = LinearLinkedList.new

					node = LinearLinkedListNode.new(segment.line_descriptor.clone, segment_list, nil)
					
					inserted_node = shape.s[layer.name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment
					segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
					inserted_node.list.insert_node(segment_node)
				}

				Constants::PTS_1.each {|point|
					label = Label.new(Constants::INTERSECTION_LABEL)
					point_list = LinearLinkedList.new
					
					node = LinearLinkedListNode.new(label, point_list, nil)
					
					inserted_node = shape.p[layer.name].insert_node(node) #Insert the node corresponding to the label of the point
				
					point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
					inserted_node.list.insert_node(point_node) #Insert the point node
				}
			}
			shape.changed = true
		else
			segments.each { |segment|
				segment_list = LinearLinkedList.new

				node = LinearLinkedListNode.new(segment.line_descriptor.clone, segment_list, nil)
				
				inserted_node = shape.s["Layer0"].insert_node(node) #Insert the node corresponding to the line descriptor of the segment
				segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
				inserted_node.list.insert_node(segment_node)
			}

			Constants::PTS_1.each {|point|
				label = Label.new(Constants::INTERSECTION_LABEL)
				point_list = LinearLinkedList.new
				
				node = LinearLinkedListNode.new(label, point_list, nil)
				
				inserted_node = shape.p["Layer0"].insert_node(node) #Insert the node corresponding to the label of the point
			
				point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
				inserted_node.list.insert_node(point_node) #Insert the point node
			}
		end
		return shape
	end

	#returns:: a default right shape for the rules
	def ShadeUtils.create_default_right_shape()
		shape = RuleLabelledShape.new(Array.new, Array.new, nil, nil)
		segments = Array.new
		segments[0] = Segment.new(OrderedPoint.new(Constants::PTS_1[0].clone), OrderedPoint.new(Constants::PTS_1[1].clone))
		segments[1] = Segment.new(OrderedPoint.new(Constants::PTS_1[1].clone), OrderedPoint.new(Constants::PTS_1[2].clone))
		segments[2] = Segment.new(OrderedPoint.new(Constants::PTS_1[2].clone), OrderedPoint.new(Constants::PTS_1[3].clone))
		segments[3] = Segment.new(OrderedPoint.new(Constants::PTS_1[3].clone), OrderedPoint.new(Constants::PTS_1[0].clone))
		
		segments[4] = Segment.new(OrderedPoint.new(Constants::PTS_2[0].clone), OrderedPoint.new(Constants::PTS_2[1].clone))
		segments[5] = Segment.new(OrderedPoint.new(Constants::PTS_2[1].clone), OrderedPoint.new(Constants::PTS_2[2].clone))
		segments[6] = Segment.new(OrderedPoint.new(Constants::PTS_2[2].clone), OrderedPoint.new(Constants::PTS_2[3].clone))
		segments[7] = Segment.new(OrderedPoint.new(Constants::PTS_2[3].clone), OrderedPoint.new(Constants::PTS_2[0].clone))
		
		if Shade.using_sketchup
			Sketchup.active_model.layers.each { |layer|
				segments.each { |segment|
					segment_list = LinearLinkedList.new

					node = LinearLinkedListNode.new(segment.line_descriptor.clone, segment_list, nil)
					
					inserted_node = shape.s[layer.name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment
					segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
					inserted_node.list.insert_node(segment_node)
				}

				Constants::PTS_1.each {|point|
					label = Label.new(Constants::INTERSECTION_LABEL)
					point_list = LinearLinkedList.new
					
					node = LinearLinkedListNode.new(label, point_list, nil)
					
					inserted_node = shape.p[layer.name].insert_node(node) #Insert the node corresponding to the label of the point
				
					point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
					inserted_node.list.insert_node(point_node) #Insert the point node
				}
				
				Constants::PTS_2.each {|point|
					label = Label.new(Constants::INTERSECTION_LABEL)
					point_list = LinearLinkedList.new
					
					node = LinearLinkedListNode.new(label, point_list, nil)
					
					inserted_node = shape.p[layer.name].insert_node(node) #Insert the node corresponding to the label of the point
				
					point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
					inserted_node.list.insert_node(point_node) #Insert the point node
				}
				
				label = Label.new(Constants::INTERSECTION_LABEL)
				intersection_label_node = shape.p[layer.name].get_node(label)
			
				#Insert the other intersection points
				point_node1 = LinearLinkedListNode.new(OrderedPoint.new(Geom::Point3d.new(4,8,0)), nil, nil)
				point_node2 = LinearLinkedListNode.new(OrderedPoint.new(Geom::Point3d.new(8,4,0)), nil, nil)
				intersection_label_node.list.insert_node(point_node1) #Insert the point node
				intersection_label_node.list.insert_node(point_node2) #Insert the point node
			}
			
			shape.changed = true
		else
			segments.each { |segment|
				segment_list = LinearLinkedList.new

				node = LinearLinkedListNode.new(segment.line_descriptor.clone, segment_list, nil)
				
				inserted_node = shape.s["Layer0"].insert_node(node) #Insert the node corresponding to the line descriptor of the segment
				segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
				inserted_node.list.insert_node(segment_node)
			}

			Constants::PTS_1.each {|point|
				label = Label.new(Constants::INTERSECTION_LABEL)
				point_list = LinearLinkedList.new
				
				node = LinearLinkedListNode.new(label, point_list, nil)
				
				inserted_node = shape.p["Layer0"].insert_node(node) #Insert the node corresponding to the label of the point
			
				point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
				inserted_node.list.insert_node(point_node) #Insert the point node
			}
			
			Constants::PTS_2.each {|point|
				label = Label.new(Constants::INTERSECTION_LABEL)
				point_list = LinearLinkedList.new
				
				node = LinearLinkedListNode.new(label, point_list, nil)
				
				inserted_node = shape.p["Layer0"].insert_node(node) #Insert the node corresponding to the label of the point
			
				point_node = LinearLinkedListNode.new(OrderedPoint.new(point.clone), nil, nil)
				inserted_node.list.insert_node(point_node) #Insert the point node
			}
			
			label = Label.new(Constants::INTERSECTION_LABEL)
			intersection_label_node = shape.p["Layer0"].get_node(label)
		
			#Insert the other intersection points
			point_node1 = LinearLinkedListNode.new(OrderedPoint.new(Point.new(4,8,0)), nil, nil)
			point_node2 = LinearLinkedListNode.new(OrderedPoint.new(Point.new(8,4,0)), nil, nil)
			intersection_label_node.list.insert_node(point_node1) #Insert the point node
			intersection_label_node.list.insert_node(point_node2) #Insert the point node
		end
		return shape
	end
	
	
	#returns: a String object with a list of the present rule IDs, for example, if there are four rules: "1|2|3|4"
	def ShadeUtils.create_rule_list()
		execution = Shade.project.execution
		rule_list = ""
		rules_size = execution.grammar.rules.size
		rules_size.times do |s|
			if (s+1) == rules_size
				rule_list = "#{rule_list}#{s+1}"
			else
				rule_list = "#{rule_list}#{s+1}|"
			end
		end
		return rule_list
	end
	
	#origin_rule_idx: index of the origin rule
	#origin_rule_part: Constants::LEFT or Constants::RIGHT
	#destiny_rule_idx: index of the destiny rule. If -1, we refer to the axiom (that is, the shape is going to be copied to the axiom)
	#destiny_rule_part: "Left", "Right", "Additive" or "" in case we refer to the axiom
	#
	#Copies the origin shape (the one in the specified part of the specified rule) to the specified destiny
	#Maintains the old transformations
	def ShadeUtils.copy_shape(origin_rule_idx, origin_rule_part, destiny_rule_idx, destiny_rule_part)
		execution = Shade.project.execution
		origin_rule = execution.grammar.rules[origin_rule_idx]
		destiny_rule = execution.grammar.rules[destiny_rule_idx]
		
		if origin_rule_part == Constants::LEFT
			origin_shape = origin_rule.left
		elsif origin_rule_part == Constants::RIGHT
			origin_shape = origin_rule.right
		end
		
		new_shape = origin_shape.clone
		new_shape.host_rule_id = destiny_rule.rule_id
		new_shape.host_rule_part = destiny_rule_part
		
		if Shade.using_sketchup
			if destiny_rule_part == Constants::LEFT
				Sketchup.active_model.layers.each { |layer|
					shape_transformation = destiny_rule.alpha.shape_transformation[layer.name]
					layout_transformation = destiny_rule.alpha.layout_transformation
					destiny_rule.alpha.erase
					destiny_rule.alpha = new_shape
					destiny_rule.alpha.shape_transformation[layer.name]= shape_transformation
					destiny_rule.alpha.layout_transformation = layout_transformation
				}
			elsif destiny_rule_part == Constants::RIGHT
				Sketchup.active_model.layers.each { |layer|
					shape_transformation = destiny_rule.beta.shape_transformation[layer.name]
					layout_transformation = destiny_rule.beta.layout_transformation
					destiny_rule.beta.erase
					destiny_rule.beta = new_shape
					destiny_rule.beta.shape_transformation[layer.name] = shape_transformation
					destiny_rule.beta.layout_transformation = layout_transformation
				}
			end
		else
			if destiny_rule_part == Constants::LEFT
				destiny_rule.alpha.erase
				destiny_rule.alpha = new_shape
			elsif destiny_rule_part == Constants::RIGHT
				destiny_rule.beta.erase
				destiny_rule.beta = new_shape
			end
		end
				
		execution.grammar.saved = false
	end

	
	#Creates and loads a default grammar
	def ShadeUtils.create_default_new_grammar
		execution = Shade.project.execution
		rules = execution.grammar.rules
		
		size = rules.size
		i = 0
		while i < size
			execution.grammar.remove_rule(size-i-1)
			i += 1
		end
		
		# Create default shapes for the first rule
		left = ShadeUtils.create_default_left_shape()
		right = ShadeUtils.create_default_right_shape()
		
		# Create the first rule
		rule = ShadeUtils.paint_rule(1, left, right)
		execution.grammar.add_rule(rule)
		execution.grammar.saved = true
		
		#Create the axiom
		execution.grammar.axiom = create_default_axiom
		execution.reset
		
		Shade.project.refresh
	end

	
	
	#Creates and loads a new project
	def ShadeUtils.create_default_new_project()
		project = Shade.project
		project.set_title(Constants::DEFAULT_PROJECT_TITLE)
		
		project.set_path(nil)
		
		ShadeUtils.create_default_new_grammar()
		
		project.refresh
		
		project.saved = true
	end
	
	#returns:: a default project
	def ShadeUtils.create_default_project
		
		# Create the grammar
		grammar = Grammar.new
		
		# Create the execution
		execution = Execution.new(grammar, nil)
		
		# Create the project
		project = Project.new(execution)
		
		#Add the project to Shade
		Shade.project = project
		
		#Create default shapes for the first rule
		left = ShadeUtils.create_default_left_shape()
		right = ShadeUtils.create_default_right_shape()
		
		#Create the axiom
		execution.grammar.axiom = create_default_axiom
		execution.current_shape = create_default_current_shape

		# Create the first rule
		rule = ShadeUtils.paint_rule(1, left, right)
		

		# Add rule to the grammar
		grammar.add_rule rule
		
		grammar.saved = true
		
		# Associate the grammar with the execution
		execution.grammar = grammar
		
		if Shade.using_sketchup
			# We only need to do this once. Then, only changing observed ids is needed
			Shade.rule_groups_observer = RuleGroupsObserver.new
			Sketchup.active_model.entities.add_observer(Shade.rule_groups_observer)
		end
		
		# Return the project  
		return project
	end
	
	
	#rule_idx:: the index of a rule
	#layer_name:: a name of a layer
	#
	#Paints the given layer of the rule specified by rule_idx
	def ShadeUtils.paint_rule_layout(rule_idx, layer_name)
		
		if Shade.using_sketchup
			execution = Shade.project.execution
			rule = execution.grammar.rules[rule_idx]

			entities = Sketchup.active_model.entities 
			
			t = rule_idx
				
			Sketchup.active_model.layers.each { |layer|
				if layer.name == layer_name
					# Draw an arrow, for the rule
					point1 = Constants::PTS_ARROW[0].clone
					point2 = Constants::PTS_ARROW[1].clone
					point3 = Constants::PTS_ARROW[2].clone
					point4 = Constants::PTS_ARROW[3].clone
					
					t.times do
						point1.transform! Constants::DESCEND_T 
						point2.transform! Constants::DESCEND_T 
						point3.transform! Constants::DESCEND_T 
						point4.transform! Constants::DESCEND_T 
					end

					rule.arrow_group[layer.name] = entities.add_group
					rule.arrow_group[layer.name].entities.add_line point1, point2
					rule.arrow_group[layer.name].entities.add_line point3, point2
					rule.arrow_group[layer.name].entities.add_line point4, point2
					rule.arrow_group[layer.name].layer = layer
					rule.arrow_group[layer.name].locked = true
				end
			}

			Sketchup.active_model.layers.each { |layer|
				if layer.name == layer_name
					#Draw the origin references
					point1 = Constants::PTS_ORIGIN[0].clone
					point2 = Constants::PTS_ORIGIN[1].clone
					point3 = Constants::PTS_ORIGIN[2].clone
					point4 = Constants::PTS_ORIGIN[3].clone
					
					rule.group_origin_left[layer.name] = entities.add_group
					rule.group_origin_left[layer.name].entities.add_edges point1, point3
					rule.group_origin_left[layer.name].entities.add_edges point2, point4
					rule.group_origin_left[layer.name].transformation = rule.left.layout_transformation
					rule.group_origin_left[layer.name].layer = layer
					rule.group_origin_left[layer.name].locked = true
					
					
					rule.group_origin_right[layer.name] = entities.add_group
					rule.group_origin_right[layer.name].entities.add_edges point1, point3
					rule.group_origin_right[layer.name].entities.add_edges point2, point4
					rule.group_origin_right[layer.name].transformation = rule.right.layout_transformation
					rule.group_origin_right[layer.name].layer = layer
					rule.group_origin_right[layer.name].locked = true
				end
			}
			
			Sketchup.active_model.layers.each { |layer|
				if layer.name == layer_name
					#Draw horizontal line
					point_h1 = Constants::PTS_H[0].clone
					point_h2 = Constants::PTS_H[1].clone
					
					t.times do
						point_h1.transform! Constants::DESCEND_T 
						point_h2.transform! Constants::DESCEND_T 
					end
					rule.line_group[layer.name] = entities.add_group
					rule.line_group[layer.name].entities.add_line point_h1,point_h2
					rule.line_group[layer.name].layer = layer
					rule.line_group[layer.name].locked = true
				end
			}
		end
	end

	
	# Adds observers, descends the shapes and paint lines and arrow
	def ShadeUtils.paint_rule(id, left, right)
		
		execution = Shade.project.execution
		
		previous_rule = execution.grammar.search_rule_by_id(id)
		
		if previous_rule
			UI.messagebox("The id #{id} is already in use")
			return nil
		end
		
		if Shade.using_sketchup
		
			# Get handles
			entities = Sketchup.active_model.entities 
			
			if execution.grammar
				idx = execution.grammar.rules.size 
			else
				idx = 0
			end
			t = idx

			# Transform the layout transformation of the shapes
			t_left = Geom::Transformation.new
			t_right = Geom::Transformation.new
			t.times do
				t_left = Constants::DESCEND_T * t_left
				t_right = Constants::DESCEND_T * t_right
			end
			t_left = Constants::LEFT_T * t_left
			t_right = Constants::RIGHT_T * t_right
			left.layout_transformation =  t_left
			right.layout_transformation = t_right
			
			group_arrow = Hash.new(nil)
			Sketchup.active_model.layers.each { |layer|
				# Draw an arrow, for the rule
				point1 = Constants::PTS_ARROW[0].clone
				point2 = Constants::PTS_ARROW[1].clone
				point3 = Constants::PTS_ARROW[2].clone
				point4 = Constants::PTS_ARROW[3].clone
				
				t.times do
					point1.transform! Constants::DESCEND_T 
					point2.transform! Constants::DESCEND_T 
					point3.transform! Constants::DESCEND_T 
					point4.transform! Constants::DESCEND_T 
				end

				group_arrow[layer.name] = entities.add_group
				group_arrow[layer.name].entities.add_line point1, point2
				group_arrow[layer.name].entities.add_line point3, point2
				group_arrow[layer.name].entities.add_line point4, point2
				group_arrow[layer.name].layer = layer
				group_arrow[layer.name].locked = true
			}
			
			group_origin_right = Hash.new(nil)
			group_origin_left = Hash.new(nil)
			Sketchup.active_model.layers.each { |layer|
				#Draw the origin references
				point1 = Constants::PTS_ORIGIN[0].clone
				point2 = Constants::PTS_ORIGIN[1].clone
				point3 = Constants::PTS_ORIGIN[2].clone
				point4 = Constants::PTS_ORIGIN[3].clone
				
				group_origin_left[layer.name] = entities.add_group
				group_origin_left[layer.name].entities.add_edges point1, point3
				group_origin_left[layer.name].entities.add_edges point2, point4
				group_origin_left[layer.name].transformation = t_left
				group_origin_left[layer.name].layer = layer
				group_origin_left[layer.name].locked = true
				
				
				group_origin_right[layer.name] = entities.add_group
				group_origin_right[layer.name].entities.add_edges point1, point3
				group_origin_right[layer.name].entities.add_edges point2, point4
				group_origin_right[layer.name].transformation = t_right
				group_origin_right[layer.name].layer = layer
				group_origin_right[layer.name].locked = true
				
			}
			
			line_group = Hash.new(nil)
			Sketchup.active_model.layers.each { |layer|
				#Draw horizontal line
				point_h1 = Constants::PTS_H[0].clone
				point_h2 = Constants::PTS_H[1].clone
				
				t.times do
					point_h1.transform! Constants::DESCEND_T 
					point_h2.transform! Constants::DESCEND_T 
				end
				line_group[layer.name] = entities.add_group
				line_group[layer.name].entities.add_line point_h1,point_h2
				line_group[layer.name].layer = layer
				line_group[layer.name].locked = true
				
			}
		end
		
		# Create the rule
		rule = Rule.new(id, left, right, line_group, group_arrow, group_origin_left, group_origin_right)
		
		return rule
	end

	
	
	#axes:: true iff the axes are to be shown
	#
	#Prepares the canvas for the plugin
	def ShadeUtils.prepare_canvas(axes = true)
		if Shade.using_sketchup
			# Prepare view
			Sketchup.send_action("viewTop:")
			if axes
				Sketchup.send_action("viewShowAxes:")
			end
			
			# Center view 
			eye = [Constants::PTS_H[1][0], Constants::PTS_H[1][1], Constants::INITIAL_Z_CAMERA]
			target = Constants::PTS_H[1]
			up = Sketchup.active_model.active_view.camera.up
			Sketchup.active_model.active_view.camera.set eye, target, up
			
			# Draw vertical line
			point1 = Constants::PTS_V[0].clone
			point2 = Constants::PTS_V[1].clone
			group = Sketchup.active_model.entities.add_group
			group.entities.add_line point1,point2
		end
	end

	
	#path:: a String representing a path of a file inside the system
	#
	#returns:: the title of the file represented by the path
	def ShadeUtils.get_title_from_path(path)
		i = path.rindex("\\")+1
		j = path.rindex(".")-1
		return path[i..j]
	end
	
	#path:: a String representing a path of a file inside the system, returned by the SketchUp utils for getting paths
	#
	#returns:: the title of the file represented by the path
	def ShadeUtils.get_title_from_sketchup_path(path)
		i = path.rindex("/")+1
		j = path.rindex(".")-1
		return path[i..j]
	end

	#path:: a String representing a path of a file inside the system
	#
	#returns:: the extension of the file represented by the path
	def ShadeUtils.get_extension(path)
		if path.rindex(".")
			i = path.rindex(".") + 1
			j = (path.length) -1
			return path[i..j]
		else
			return nil
		end
	end
	
	#path:: a String representing a path of a file inside the system
	#
	#returns:: the parent directory of the file represented by the path
	def ShadeUtils.get_directory_from_path(path)
		i = path.rindex("\\")
		return path[0..i]
	end
	
	#path:: a String representing a path of a file inside the system, returned by the SketchUp utils for getting paths
	#
	#returns:: the parent directory of the file represented by the path
	def ShadeUtils.get_directory_from_sketchup_path(path)
		i = path.rindex("/")
		return path[0..i]
	end
	
	#returns:: the current shape
	def ShadeUtils.current_shape()
		return Shade.project.execution.current_shape
	end
	
	#returns:: the shape previous to the last rule application
	def ShadeUtils.previous_shape()
		if Shade.project.execution.execution_history
			return Shade.project.execution.execution_history.last[2]
		else
			return nil
		end
	end
	
	#returns:: the axiom
	def ShadeUtils.axiom()
		return Shade.project.execution.grammar.axiom
	end
	
	#shape:: a LabelledShape object
	#type:: String that can take the values "ALL" (referring to all types of labels) or "INTERSECTION" (referring only to the intersection points)
	#
	#returns:: an Array with the lists of labels present in the current shape
	def ShadeUtils.get_labels(shape, type)
		
		labels = Array.new
		case type
			when ("ALL" or "All")
				shape.p.each_key { |layer_name|
					ShadeUtils.current_shape.p[layer_name].reset_iterator
					while l_node = ShadeUtils.current_shape.p[layer_name].get_next
						labels.push l_node.list
					end
				}
			when ("INTERSECTION" or "Intersection")
				
				shape.p.each_key { |layer_name|
				
					l_node = ShadeUtils.current_shape.p[layer_name].get_node(Label.new(Constants::INTERSECTION_LABEL))
					if l_node
						labels.push l_node.list
					end
				}
			else
				shape.p.each_key { |layer_name|
					l_node = ShadeUtils.current_shape.p[layer_name].get_node(Label.new(type.capitalize))
					if l_node
						labels.push l_node.list
					end
				}

			
		end
		
		return labels
	end
	
	#returns:: the current execution
	def ShadeUtils.get_execution()
		return Shade.project.execution
	end
	
	#returns:: the current project
	def ShadeUtils.get_project()
		return Shade.project
	end
	
	#returns:: the current grammar
	def ShadeUtils.get_grammar()
		return Shade.project.execution.grammar
	end
	
	#returns:: the id of the last rule applied
	def ShadeUtils.last_rule_id()
		if Shade.project.execution.execution_history
			return Shade.project.execution.execution_history.last[0]
		else
			return nil
		end
	end
	
	#returns:: the id of the first rule applied
	def ShadeUtils.first_rule_id()
		if Shade.project.execution.execution_history
			return Shade.project.execution.execution_history.first[0]
		else
			return nil
		end
	end
	
	#returns:: the id of the rule applied previously to the last one
	def ShadeUtils.previous_rule_id()
		if Shade.project.execution.execution_history
			if Shade.project.execution.execution_history.size > 1
				return Shade.project.execution.execution_history[Shade.project.execution.execution_history.size - 2][0]
			else
				return nil
			end
		else
			return nil
		end
	end
	
	#returns:: the transformation of the last rule applied
	def ShadeUtils.last_rule_transformation()
		if Shade.project.execution.execution_history
			return Shade.project.execution.execution_history.last[1]
		else
			return nil
		end
	end
	
	#rule_idx:: an integer number
	#
	#returns:: the rule with the specified index, that is, that is in the rule_idx position of the array of rules
	def ShadeUtils.get_rule(rule_idx)
		if rule_idx > Shade.project.execution.grammar.rules.size
			puts "Index out of range"
		else
			return Shade.project.execution.grammar.rules[rule_idx]
		end
	end
	
	def ShadeUtils.c_factor(t)
	  fx = Math.sqrt(((t[0]**2)+(t[1]**2)))
    fy = Math.sqrt(((t[3]**2)+(t[4]**2)))
    return fx, fy
	end
	
  def ShadeUtils.init_flags(design)
      
        flags = LinearLinkedList.new
        design.reset_iterator
        while l_node = design.get_next
          list = LinearLinkedList.new()
          l_node.list.reset_iterator
          while(node = l_node.list.get_next)
            new_node = LinearLinkedListNode.new(node.key,false,nil)
            list.insert_node(new_node)
          end
          newNode = LinearLinkedListNode.new(l_node.key, list, nil)
          flags.insert_node newNode
        end
      return flags
   end
   
  def ShadeUtils.diameter(array)
   cont = 0
   distance = 0
   while cont < array.size
     cont2 = cont+1
     while cont2 < array.size
       if (array[cont].key.point.distance(array[cont2].key.point)>distance)
         distance = array[cont].key.point.distance(array[cont2].key.point)
       end
       cont2 += 1
     end
     cont += 1
   end
   return distance
 end
		
end
