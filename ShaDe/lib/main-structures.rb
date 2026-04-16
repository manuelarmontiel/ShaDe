begin
	require 'sketchup' # First we pull in the standard API hooks.
	require 'ShaDe//lib//utils.rb'
	require 'ShaDe//lib//geometry.rb'
	require 'ShaDe//lib//data-structures.rb'
rescue LoadError
	require "#{File.dirname(__FILE__)}/utils"
	require "#{File.dirname(__FILE__)}/geometry"
	require "#{File.dirname(__FILE__)}/data-structures"
end


#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a rule
class Rule
	
	#Internal rule ID
	attr_accessor :rule_id
	
	#The left labelled shape
	attr_accessor :alpha
	#The right labelled shape
	attr_accessor :beta
	#The difference left - right shape
	attr_accessor :alpha_minus_beta
	#The difference right - left shape
	attr_accessor :beta_minus_alpha
	
	#Hashes of groups (one for each layer)
	attr_accessor :line_group
	attr_accessor :arrow_group
	attr_accessor :group_origin_left
	attr_accessor :group_origin_right
	
	attr_accessor :line_group_component
	attr_accessor :arrow_group_component
	attr_accessor :group_origin_left_component
	attr_accessor :group_origin_right_component
	
	#rule_id: internal id for the rule
	#alpha: the left RuleLabelledShape
	#beta: the right RuleLabelledShape
	#
	#Initializes the rule
	def initialize(rule_id, alpha, beta, line_group, arrow_group, group_origin_left, group_origin_right)
		
		@rule_id = rule_id
		
		@alpha = alpha
		@alpha.host_rule_id = rule_id
		@alpha.host_rule_part = Constants::LEFT
		
		@beta = beta
		@beta.host_rule_id = rule_id
		@beta.host_rule_part = Constants::RIGHT

		
		@line_group = line_group
		@arrow_group = arrow_group
		@group_origin_left = group_origin_left
		@group_origin_right = group_origin_right
		
	end
	
	#returns:: the left shape of the rule
	def left
		return @alpha
	end
	
	#returns:: the right shape of the rule
	def right
		return @beta
	end
	
	#Repaints the rule
	def repaint
		if Shade.using_sketchup
			@alpha.paint
			@beta.paint
			
			entities = Sketchup.active_model.entities

			t = Shade.project.execution.grammar.get_rule_index(self)

			# Transform the layout transformation of the origins
			t_left = Geom::Transformation.new
			t_right = Geom::Transformation.new
			t.times do
				t_left = Constants::DESCEND_T * t_left
				t_right = Constants::DESCEND_T * t_right
			end
			t_left = Constants::LEFT_T * t_left
			t_right = Constants::RIGHT_T * t_right

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

			@arrow_group = entities.add_group
			@arrow_group.entities.add_edges point1, point2
			@arrow_group.entities.add_edges point3, point2
			@arrow_group.entities.add_edges point4, point2
			@arrow_group.locked = true
			
			#Draw the origin references
			point1 = Constants::PTS_ORIGIN[0].clone
			point2 = Constants::PTS_ORIGIN[1].clone
			point3 = Constants::PTS_ORIGIN[2].clone
			point4 = Constants::PTS_ORIGIN[3].clone
			
			@group_origin_left = entities.add_group
			@group_origin_left.entities.add_edges point1, point3
			@group_origin_left.entities.add_edges point2, point4
			@group_origin_left.transformation = t_left
			@group_origin_left.locked = true
			
			@group_origin_right = entities.add_group
			@group_origin_right.entities.add_edges point1, point3
			@group_origin_right.entities.add_edges point2, point4
			@group_origin_right.transformation = t_right
			@group_origin_right.locked = true
			
			#Draw horizontal line
			point_h1 = Constants::PTS_H[0].clone
			point_h2 = Constants::PTS_H[1].clone
			
			t.times do
				point_h1.transform! Constants::DESCEND_T 
				point_h2.transform! Constants::DESCEND_T 
			end
			@line_group = entities.add_group
			@line_group.entities.add_line point_h1,point_h2
			@line_group.locked = true
		end
	end	
	
	#returns:: the resulting shape of making the difference: alpha - beta (left and right shapes, respectively)
	def alpha_minus_beta		
		alpha_minus_beta = @alpha.clone
		alpha_minus_beta.shape_expression(@beta, Constants::DIFFERENCE, Constants::SEGMENTS)
		alpha_minus_beta.shape_expression(@beta, Constants::DIFFERENCE, Constants::POINTS)
		return alpha_minus_beta
	end
	
	#returns:: the resulting shape of making the difference: beta - alpha (right and left shapes, respectively)
	def beta_minus_alpha
		
		beta_minus_alpha = @beta.clone
		beta_minus_alpha.shape_expression(@alpha, Constants::DIFFERENCE, Constants::SEGMENTS)
		beta_minus_alpha.shape_expression(@alpha, Constants::DIFFERENCE, Constants::POINTS)
		return beta_minus_alpha
	end
	
	#Erases the SU objects attached to the rule
	def erase()
		if Shade.using_sketchup
			entities = Sketchup.active_model.entities
			
			Sketchup.active_model.layers.each { |layer|
				
				if @arrow_group
					if @arrow_group[layer.name]
						@arrow_group[layer.name].locked = false
						entities.erase_entities @arrow_group[layer.name]
					end
				end
					
				if @line_group
					if @line_group[layer.name]
						@line_group[layer.name].locked = false
						entities.erase_entities @line_group[layer.name]
					end
				end
					
				if @group_origin_left
					if @group_origin_left[layer.name]
						@group_origin_left[layer.name].locked = false
						entities.erase_entities @group_origin_left[layer.name]
					end
				end
					
				if @group_origin_right
					if @group_origin_right[layer.name]
						@group_origin_right[layer.name].locked = false
						entities.erase_entities @group_origin_right[layer.name]
					end
				end
			}
			
			@alpha.erase
			@beta.erase
		end
	end
	
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#Abstract representation of a grammar, that is, a set of rules
class Grammar
	#Array for the rules
	attr_reader :rules
	
	#The axiom LabelledShape
	attr_reader :axiom
	
	#True iff the grammar has been saved
	attr_accessor :saved
	
	#Initializing
	def initialize()
		@rules = Array.new
		@saved = true
	end
	
	#rule:: a Rule object to add
	#
	#Adds a rule to the grammar
	def add_rule(rule)
		@rules.push(rule)
	end
	
	#i:: index of the rule to remove
	#
	#Removes the rule in the grammar with the index i
	def remove_rule(i)
		rule = @rules[i]
		rule.erase
		#Delete from the array
		@rules.delete_at(i)
	end
	
	#shape:: a LabelledShape that will be the axiom of the grammar
	#
	#Sets the axiom to the specified shape
	def axiom=(shape)
		@axiom = shape
	end	
	
	#rule:: a Rule object, representing one of the grammar rules
	#
	#returns:: the index of the rule (not the ID)
	def get_rule_index(rule)
		result = nil
		i = 0
		while ((i < @rules.size) && !result)
			if @rules[i].rule_id == rule.rule_id
				result = i
			end
			i+=1
		end
		return result
	end
	
	#rule_id:: an id
	#
	#returns the rule with the internal id rule_id. In case it does not exist, returns nil
	def search_rule_by_id(rule_id)
		i = 0
		found = false
		size = @rules.size
		rule = nil
		
		while i < size and !found
			if @rules[i].rule_id == rule_id
				rule = @rules[i]
				found = true
			end
			i +=1
		end
		return rule
	end
	
	#shape_id:: an id
	#
	#returns the shape with the internal id shape_id. In case it does not exist, returns nil
	def search_shape_by_id(shape_id)
		i = 0
		found = false
		size = @rules.size
		shape = nil
		
		while i < size and !found
			if @rules[i].left.shape_id == shape_id
				shape = @rules[i].left
				found = true
			elsif @rules[i].right.shape_id == shape_id
				shape = @rules[i].right
				found = true
			end
			i +=1
		end
		return shape	
	end

	#path:: the path to save the shape in
	#
	#Saves the shape in the specified path
	def save(path, text = false)
		#the path is a .gr2 file
		#we need the directory
		directory = ShadeUtils.get_directory_from_path(path)
		title = ShadeUtils.get_title_from_path(path)
		
		if text
			extension = "txt"
		else
			extension = "skp"
		end
		
		File.open(path.strip, 'w') do |f|
			@rules.each { |rule|
				f.write("alpha#{rule.rule_id}#{title}.#{extension} beta#{rule.rule_id}#{title}.#{extension}\n")
				rule.alpha.save("#{directory}alpha#{rule.rule_id}#{title}.#{extension}")
				rule.beta.save("#{directory}beta#{rule.rule_id}#{title}.#{extension}")
			}
			if Shade.project.execution.file_axiom
				f.write("AXIOM: axiom#{title}.#{extension}\n")
				@axiom.save("#{directory}axiom#{title}.#{extension}")
			end
		end
		
		
	end
	
	#path:: the path to load the shape from
	#
	#Loads the shape from the specified path
	def load(path)
		
		#the path is a .gr2 file
		#we need the directory
		directory = ShadeUtils.get_directory_from_path(path)
		
		size = @rules.size
		i = 0
		while i < size
			remove_rule(size-i-1)
			i += 1
		end
		@rules = Array.new
		
		Shade.project.execution.file_axiom = false
    
		filename = path.strip
		
		File.open(filename, 'r') do |f|
			while line = f.gets
				line_a = line.split
				if line_a[0] == "AXIOM:"
					Shade.project.execution.file_axiom = true
					@axiom = LabelledShape.new(Array.new, Array.new)
					@axiom.load("#{directory}#{line_a[1]}")
				else
					alpha_title = line_a[0]
					beta_title = line_a[1]
					alpha = RuleLabelledShape.new(Array.new, Array.new, nil, nil)
					alpha.load("#{directory}#{alpha_title}")
					
					beta = RuleLabelledShape.new(Array.new, Array.new, nil, nil)
					beta.load("#{directory}#{beta_title}")
					if @rules.empty?
						last_id = 0
					else
						last_id = @rules.last.rule_id
					end
					rule = ShadeUtils.paint_rule(last_id+1, alpha, beta)
					@rules.push rule
				end		
			end
		end
		
		if !Shade.project.execution.file_axiom
			new_axiom = LabelledShape.new(Array.new, Array.new)
			@rules[0].left.p.each_key {|layer_name|
				new_axiom.p[layer_name] = @rules[0].left.p[layer_name].clone
			}
			@rules[0].left.s.each_key {|layer_name|
				new_axiom.s[layer_name] = @rules[0].left.s[layer_name].clone
			}
			Shade.project.execution.grammar.axiom = new_axiom
		end

		Shade.project.execution.reset
	end
end
	
#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class gathers the current grammar in order to execute it and produce designs
class Execution
	#A Grammar object
	attr_accessor :grammar
	
	#A CurrentLabelledShape object (the current design)
	attr_accessor :current_shape
	
	#True if we want the labels to appear in the current shape
	attr_accessor :show_labels
	
	#An array of pairs [rule_id, transformation] applied to the axiom, in order of application
	attr_accessor :execution_history
	
	attr_accessor :file_axiom
	
	#grammar:: the grammar to apply
	#current_shape:: shape in which to store the design
	def initialize(grammar, current_shape)
		@grammar= grammar
		@current_shape = current_shape
		@show_labels = true
		@execution_history = Array.new
		@file_axiom = false
	end
	
	#directory:: the directory to save the execution history in
	#
	#Saves the execution history (that is, the sequence of applied rules and the produced shape in each step) into the specified directory
	def save_execution_history(directory)
		if @execution_history
			if @execution_history.size > 0
				if File.exist? "#{directory}\\entries.txt"
					File.delete("#{directory}\\entries.txt")
				end
				File.open("#{directory}\\entries.txt", 'w') do |f|
			
					execution_history.each{ |entry|
						t_string = nil
						entry[1].each { |e|
							if t_string
								t_string = "#{t_string},#{e}"
							else
								t_string = "#{e}"
							end
						}
						#puts t_string
						f.write "#{entry[0]},#{t_string}\n"
					}
				
				end
				execution_history.each_with_index{ |entry, i|
					entry[2].save("#{directory}\\shape#{i}.txt")
				}
			end
		end
	end
	
	#directory:: the directory to load the execution history from
	#
	#Loads the execution history (that is, the sequence of applied rules and the produced shape in each step) from the specified directory
	def load_execution_history(directory)
		@execution_history = Array.new
		if File.exist? "#{directory}\\entries.txt"
			j = 0
			File.open("#{directory}\\entries.txt", 'r') do |f|
				while (line = f.gets)
					line_a = line.split(",")
					
					if line_a.size > 1
						rule_id = line_a[0].to_i
						t = Array.new(6)
						for i in 1..6
							t[i-1] = line_a[i].to_f
						end
						
						shape = CurrentLabelledShape.new([], [])
						shape.load("#{directory}\\shape#{j}.txt")
						
						@execution_history.push [rule_id, t, shape]
						j += 1
					end
				end
			end
		end
	end
	
	#Prints the applied transformations in the ruby console
	def print_transformations
		@execution_history.each { |triple|
			puts triple[1]
			puts "--"
		}
		return nil
	end	
	
	#Auxiliar method for computing the determinant of a matrix
	def cramer(m, b)#b is i
		result = Array.new
		det = determinant(m)
		
		for i in 0..2
			c = substitute(m,b,i)
			
			temp_det = determinant(c)
			
			result[i] = temp_det/det
		end
		
		return result
	end
	
	#Auxiliar method for computing the determinant of a matrix
	def substitute(m,b,pos)
		result = Array.new
		result[0] = Array.new
		result[1] = Array.new
		result[2] = Array.new
		
		for i in 0..2
			for j in 0..2
				if j == pos
					result[i][j] = b[i]
				else
					result[i][j] = m[i][j]
				end
			end
		end
		
		return result
	end
	
	#m:: a matrix
	#
	#returns:: the determinant of matrix m
	def determinant(m)
		#Sarrus rule
		det = (m[0][0]*m[1][1]*m[2][2]) + (m[0][1]*m[1][2]*m[2][0]) + (m[0][2]*m[1][0]*m[2][1])- ((m[0][2]*m[1][1]*m[2][0]) + (m[0][1]*m[1][0]*m[2][2]) + (m[0][0]*m[1][2]*m[2][1]))
		
		return det
	end
	
	#a:: an Array of three positions
	#
	#returns:: the sum of elements in the array
	def sum(a)
		result = 0
		for i in 0..2
			result = result + a[i]
		end
		return result
	end
	
#dp_alpha:: Array with three points of the left shape of a Rule. This three points have to form a triangle.
#dp_current::Array with three points of the current shape. This three points have form an equivalent triangle to that of dp_alpha
#
#returns:: the transformation that has to be applied in order to convert the triangle formed by dp_alpha into the one formed by dp_current.  #The transformation is an Array of six positions [a, b, c, d, e, f]; c and f are the traslation coefficients and a, b, d, e are the scale and rotation factors.	
#dp_alpha = patrón
#dp_current sol_actual, puntos del diseño
def get_transformation(dp_alpha, dp_current)
  #Construct the x-matrix
  #TODO 
  
  m_x = Array.new
  b_x = Array.new
  
  m11 = m12 = m13 = m22 = m23 = m33 = 0
  dp_alpha.each{|p|
    m11 += ((p.x)**2)
    m12 += ((p.x)*(p.y))
    m13 += (p.x)
    m22 += ((p.y)**2)
    m23 += (p.y)
    m33 += 2
  }
  
  cont = i1 = i2 = i3 = i4 = i5 = i6 = 0
  while(cont<dp_alpha.size)
    i1 += ((dp_alpha[cont].x)*(dp_current[cont].x))
    i2 += ((dp_alpha[cont].y)*(dp_current[cont].x))
    i3 += (dp_current[cont].x)
    i4 += ((dp_alpha[cont].x)*(dp_current[cont].y))
    i5 += ((dp_alpha[cont].y)*(dp_current[cont].y))
    i6 += (dp_current[cont].y)
    cont += 1
  end
  
  m_x[0] = Array.new
  m_x[0][0] = (2*m11)
  m_x[0][1] = (2*m12)
  m_x[0][2] = (2*m13)
  b_x[0] = (2*i1)
 
  m_x[1] = Array.new
  m_x[1][0] = (2*m12)
  m_x[1][1] = (2*m22)
  m_x[1][2] = (2*m23)
  b_x[1] = (2*i2)
  
  m_x[2] = Array.new
  m_x[2][0] = (2*m13)
  m_x[2][1] = (2*m23)
  m_x[2][2] = m33
  b_x[2] = (2*i3)
  
#dp_alpha.each{|p|
#   puts "dp_alpha #{p.point}"
# }
#     
#dp_current.each{|p|
#   puts "dp_current #{p.point}"
# }
  
#  puts"m_x[0] = #{m_x[0][0]} #{m_x[0][1]} #{m_x[0][2]}"
#  puts"m_x[1] = #{m_x[1][0]} #{m_x[1][1]} #{m_x[1][2]}"
#  puts"m_x[2] = #{m_x[2][0]} #{m_x[2][1]} #{m_x[2][2]}"
#  puts"b_x = #{b_x[0]} #{b_x[1]} #{b_x[2]}"
  
  coef_x = cramer(m_x, b_x)
  

  #Construct the y-matrix
  m_y = Array.new
  b_y = Array.new
  
  m_y[0] = Array.new
  m_y[0][0] = (2*m11)
  m_y[0][1] = (2*m12)
  m_y[0][2] = (2*m13)
  b_y[0] = (2*i4)
  
  m_y[1] = Array.new
  m_y[1][0] = (2*m12)
  m_y[1][1] = (2*m22)
  m_y[1][2] = (2*m23)
  b_y[1] = (2*i5)
  
  m_y[2] = Array.new
  m_y[2][0] = (2*m13)
  m_y[2][1] = (2*m23)
  m_y[2][2] = m33
  b_y[2] = (2*i6)
  
#puts"m_y[0] = #{m_y[0][0]} #{m_y[0][1]} #{m_y[0][2]}"
#puts"m_y[1] = #{m_y[1][0]} #{m_y[1][1]} #{m_y[1][2]}"
#puts"m_y[2] = #{m_y[2][0]} #{m_y[2][1]} #{m_y[2][2]}"
#puts"b_y = #{b_y[0]} #{b_y[1]} #{b_y[2]}"
  
  
  coef_y = cramer(m_y, b_y)
  
  result = Array.new
  for i in 0..2
    result[i] = coef_x[i]
  end
  for i in 3..5
    result[i] = coef_y[i-3]
  end
  return result
end
	
	#rule_id:: internal id of the rule to apply to the current shape
	#transformation:: optional argument; when it is specified, the possible transformations of the rule corresponding to rule_id are not computed
	#
	#Applies the specified rule to the current shape.
	def apply_rule(rule_id, transformation = nil, print = false)
		applied = nil
		rule = @grammar.search_rule_by_id(rule_id)
		
		#By deffinition, all our alpha shapes have at least three distinct labelled points that form a triangle, since in the initialization of
		#shapes, an Error is raised when this condition does not hold.
		
		#If there are labels in alpha that do not exist in the current shape, then the rule cannot be applied
		possible = true
		@current_shape.p.each_key { |layer_name|
			
			current_labels = @current_shape.p[layer_name]
			alpha_labels = rule.alpha.p[layer_name]
			if alpha_labels
				alpha_labels.reset_iterator
				
				while (possible && (alpha_label_node = alpha_labels.get_next))
					current_label_node = current_labels.get_node(alpha_label_node.key)
					if !current_label_node 
						#If an alpha label value do not exist in the current shape, then the rule cannot be applied
						possible = false
					elsif current_label_node.list.size < alpha_label_node.list.size
						#If for a given value of an alpha label, there are less points in the current shape than in the alpha shape,
						#then the rule cannot be applied
						possible = false
					end
				end
			end
			
		}	
		
		#If the rule can by this moment be applied
		if possible
			if transformation

				flag_s= @current_shape.shape_expression(rule.alpha.transform(transformation),Constants::SUBSHAPE, Constants::SEGMENTS)
				flag_p = @current_shape.shape_expression(rule.alpha.transform(transformation),Constants::SUBSHAPE, Constants::POINTS)
				flag_subshape = flag_s && flag_p

				if (flag_subshape) #The transformed alpha is a subshape of the current shape
					#Apply the rule
					@execution_history.push [rule_id, transformation, @current_shape.clone]
					t_alpha_minus_beta = rule.alpha_minus_beta.transform(transformation)
					t_beta_minus_alpha = rule.beta_minus_alpha.transform(transformation)
					
					@current_shape.shape_expression(t_alpha_minus_beta, Constants::DIFFERENCE, Constants::SEGMENTS)
					@current_shape.shape_expression(t_alpha_minus_beta, Constants::DIFFERENCE, Constants::POINTS)
					
					@current_shape.shape_expression(t_beta_minus_alpha, Constants::UNION, Constants::SEGMENTS)
					@current_shape.shape_expression(t_beta_minus_alpha, Constants::UNION, Constants::POINTS)
					
					applied = true
				else
					#puts "Not a subshape. Transformation: #{transformation}. Flag s: #{flag_s}. Flag p: #{flag_p}"
					puts "Not a subshape"
				end
				
				
			else

				layer_name = "Layer0"
			
				possible_ts = possible_transformations(rule, layer_name)
				
				if !possible_ts.empty? #Then the rule can be applied to the current shape

					chosen_transformation = possible_ts[0]
          
					a11 = chosen_transformation[0][0]
					a12 = chosen_transformation[0][1]
					b1 = chosen_transformation[0][2]

					a21 = chosen_transformation[0][3]
					a22 = chosen_transformation[0][4]
					b2 = chosen_transformation[0][5]

					dp_alpha = chosen_transformation[1]
					dp_current = chosen_transformation[2]
          
					#Calculate the error associated to the transformation
					cont = 0
					e = 0
					dp_alpha.each{|p|
						x1 = ((a11)*(p.x))+((a12)*(p.y))+b1
						y1 = ((a21)*(p.x))+((a22)*(p.y))+b2
						t_alpha_point = Point.new(x1,y1)
						#puts"t_alpha_point #{t_alpha_point.x} #{t_alpha_point.y}"
						current_point = dp_current[cont]
						#puts"current_point #{current_point.point}"

						e += t_alpha_point.distance(current_point)
						cont+=1
					}
          
					#Calculate the diameter of the current shape
					 @current_shape.p["Layer0"].reset_iterator
					 point_list = Array.new
					 while (node = @current_shape.p["Layer0"].get_next)
					#            puts"key #{node.key.value}"
					#            puts"first #{node.list.first.key.point}"
					#            puts"last #{node.list.last.key.point}"
					    point_list.push node.list.to_array
					 end
					point_list.flatten!()
          
					d = ShadeUtils.diameter(point_list)
         
					@current_shape.mu["Layer0"] = [@current_shape.mu["Layer0"], (e/d)].max
          
          
					chosen_transformation = possible_ts[0][0]
          
      
					#Apply the rule
					@execution_history.push [rule_id, chosen_transformation, @current_shape.clone]
					t_alpha_minus_beta = rule.alpha_minus_beta.transform(chosen_transformation)
					t_beta_minus_alpha = rule.beta_minus_alpha.transform(chosen_transformation)

					@current_shape.shape_expression(t_alpha_minus_beta, Constants::DIFFERENCE, Constants::SEGMENTS)
					@current_shape.shape_expression(t_alpha_minus_beta, Constants::DIFFERENCE, Constants::POINTS)
					
					@current_shape.shape_expression(t_beta_minus_alpha, Constants::UNION, Constants::SEGMENTS)
					@current_shape.shape_expression(t_beta_minus_alpha, Constants::UNION, Constants::POINTS)
										
					applied = true

				end
			end
			
			if applied 
				@current_shape.create_pi
				if Shade.using_sketchup
					@current_shape.refresh(@show_labels)
				end
			end
			
		end
		
		return applied
	end
	
	
#rule:: a Rule object
  #layer_name:: the name of the affected layer
  #shape:: optional argument; when it is specified, the possible transformations are computed over it instead of the current shape
  #
  #returns:: an array with all the possible transformations that can be applied to the left part of the specified rule in order to become
  #a subshape of the specified shape, or the current shape when there is no specified shape

	
def possible_transformations_All(rule, layer_name, shape = nil, print = false)
   #TODO
    
    if !shape
      shape = @current_shape
    end
    possible_transformations = Array.new
    pattern = rule.alpha.p[layer_name]
    design = shape.p[layer_name]
    flags = design.clone
    sol_actual = Array.new
    sol = Array.new
    res = possible_All(pattern, flags, 0, sol_actual, sol)
    #puts"res = #{res} \nsize = #{sol.size}"
    
    dp_alpha = Array.new
    n_pattern = length(pattern)
    cont = 0
    while (cont < n_pattern)
      dp_alpha.push search(pattern,cont).key
      cont += 1
    end

    sol.each{|dp_current|
      #puts "dp_current: #{dp_current}"
      t = get_transformation(dp_alpha, dp_current)
      t_alpha = rule.alpha.transform(t)
      p_t_alpha = t_alpha.p[layer_name]
      t_alpha_array = Array.new
      n_pt_alpha = length(p_t_alpha)
      cont = 0 
      while (cont < n_pt_alpha)
        t_alpha_array.push search(p_t_alpha,cont).key
        cont += 1
      end
      
      
     
      if ((t_alpha_array.size() == dp_current.size()) and (t_alpha_array.size()>=3))
        cont2 = 0
        result = true
        while (cont2<t_alpha_array.size())
          cont3 = cont2+1
          while ((cont3>cont2) and (cont3<t_alpha_array.size()))
            t_alpha.s[layer_name].reset_iterator()
            connectedPattern = t_alpha.connected?(t_alpha_array[cont2].point, t_alpha_array[cont3].point, layer_name)
            
            shape.s[layer_name].reset_iterator
            connectedDesign = shape.connected?(dp_current[cont2].point, dp_current[cont3].point, layer_name)
            
            result = (result and (!connectedPattern or connectedDesign))
            
            if result== true
              #puts "Puntos conectados del disenio #{designList[cont2].key.point} #{designList[cont3].key.point}" 
              #puts "Puntos conectados del patron #{patternList[cont2].key.point} #{patternList[cont3].key.point}"
            end
            
            cont3 = cont3+1
          end
          cont2 = cont2+1
        end
      else
        result = false
      end      
      
      
      if result
        possible_transformations.push [t, dp_alpha, dp_current]
      end
     # puts"------------------------------------------------------------"
    }    
  return possible_transformations
  end
  
  def possible_All(pattern, chosen_points, n, sol_actual, sol)
    pattern_angle = nil
    pattern_angle1 = nil
    pattern_size = length(pattern)-1
    if (n>=2 and n<pattern_size)
        pattern_points = Array.new
        pattern_points[0] = search(pattern, n-2).key.point
        pattern_points[1] = search(pattern, n-1).key.point
        pattern_points[2] = search(pattern, n).key.point
          
        pattern_angle = get_angle(pattern_points)
        
    elsif (n>=2)
        pattern_points = Array.new
        pattern_points[0] = search(pattern, n-2).key.point
        pattern_points[1] = search(pattern, n-1).key.point
        pattern_points[2] = search(pattern, n).key.point
        
        pattern_angle = get_angle(pattern_points)
        
        pattern_final_points = Array.new
        pattern_final_points[0] = search(pattern, n).key.point
        pattern_final_points[1] = search(pattern, 0).key.point
        pattern_final_points[2] = search(pattern, 1).key.point
        
        pattern_angle1 = get_angle(pattern_final_points)
    end  
   
    
      
    found = false  
    type = get_type(pattern,n)
    if (type != nil)
      brothers = Array.new
      brothers = get_brothers(type,chosen_points)
      brothers.each{|d_point|
        sol_actual[n] = d_point.key
        res_angles = angles_comparer(sol_actual, pattern_angle, pattern_angle1, n, pattern_size) 
  
        if ((n == (length(pattern)-1))and res_angles)
          found = true
          sol.insert(0, sol_actual.clone)
          #puts"#{sol_actual}"
        else
          if res_angles
            cp_chosen_points = chosen_points.clone()
            chosen_points.get_node(type).list.reset_iterator
            cp_chosen_points.get_node(type).list.get_node(d_point.key).list = 1
            found = possible_All(pattern, cp_chosen_points, n+1, sol_actual, sol)
          end
        end
        }
     end
    return found
  end

		
	
def possible_transformations(rule, layer_name, shape = nil, print = false)
  #TODO
   
   if !shape
     shape = @current_shape
   end
   possible_transformations = Array.new
   pattern = rule.alpha.p[layer_name]
   
#   pattern_array = Array.new
#   pattern_array = pattern.clone
#   pattern_array = pattern_array.to_array.shuffle
#   pattern_array.each{|elem|
#     elem.list = elem.list.to_array.shuffle
#     elem.list.each{|p|
#       puts"points #{p.key.point}"
#     } 
#   }
  
   design = shape.p[layer_name]
   flags = design.clone
   sol = Array.new
   res = possible(pattern, flags, 0, sol, possible_transformations, rule, layer_name, shape)
     
     
 return possible_transformations
 end
 
 def possible(pattern, chosen_points, n, sol, possible_transformations, rule, layer_name, shape)
   pattern_angle = nil
   pattern_angle1 = nil
   #pattern_size = length_Array(pattern)-1
   pattern_size = length(pattern)-1
   if (n>=2 and n<pattern_size)
       pattern_points = Array.new
#       pattern_points[0] = search_Array(pattern, n-2).key.point
#       pattern_points[1] = search_Array(pattern, n-1).key.point
#       pattern_points[2] = search_Array(pattern, n).key.point
       
       pattern_points[0] = search(pattern, n-2).key.point
       pattern_points[1] = search(pattern, n-1).key.point
       pattern_points[2] = search(pattern, n).key.point
         
       pattern_angle = get_angle(pattern_points)
       
   elsif (n>=2)
       pattern_points = Array.new
#       pattern_points[0] = search_Array(pattern, n-2).key.point
#       pattern_points[1] = search_Array(pattern, n-1).key.point
#       pattern_points[2] = search_Array(pattern, n).key.point
       
       pattern_points[0] = search(pattern, n-2).key.point
       pattern_points[1] = search(pattern, n-1).key.point
       pattern_points[2] = search(pattern, n).key.point
       
       pattern_angle = get_angle(pattern_points)
       
       pattern_final_points = Array.new
#       pattern_final_points[0] = search_Array(pattern, n).key.point
#       pattern_final_points[1] = search_Array(pattern, 0).key.point
#       pattern_final_points[2] = search_Array(pattern, 1).key.point
       
       pattern_final_points[0] = search(pattern, n).key.point
       pattern_final_points[1] = search(pattern, 0).key.point
       pattern_final_points[2] = search(pattern, 1).key.point
       
       pattern_angle1 = get_angle(pattern_final_points)
   end  
  
   
     
   found = false  
   type = get_type(pattern,n)
   #type = get_type_Array(pattern,n)
   if (type != nil)
     brothers = Array.new
     brothers = get_brothers(type,chosen_points)
     brothers = brothers.shuffle()
     cont=0
     while (!found and cont<brothers.size) #brothers.each{|d_point|
       d_point = brothers[cont]
       sol[n] = d_point.key
       res_angles = angles_comparer(sol, pattern_angle, pattern_angle1, n, pattern_size) 
       #if ((n == (length_Array(pattern)-1))and res_angles)
       if ((n == (length(pattern)-1))and res_angles)
         subshape = subshape?(pattern, sol, possible_transformations, rule, layer_name, shape)
         if subshape
          found = true
         end
       else
         if res_angles
           cp_chosen_points = chosen_points.clone()
           chosen_points.get_node(type).list.reset_iterator
           cp_chosen_points.get_node(type).list.get_node(d_point.key).list = 1
           found = possible(pattern, cp_chosen_points, n+1, sol, possible_transformations, rule, layer_name, shape)
         end
       end
       cont += 1
      end
    end
   return found
 end
    
 
 def subshape?(pattern_array, dp_current, possible_transformations, rule, layer_name, shape)
   dp_alpha = Array.new
   #  n_pattern = length_Array(pattern_array)
     n_pattern = length(pattern_array)
     cont = 0
     while (cont < n_pattern)
       dp_alpha.push search(pattern_array,cont).key
       #dp_alpha.push search_Array(pattern_array,cont).key
       cont += 1
     end
  
     
       #puts "dp_current: #{dp_current}"
       t = get_transformation(dp_alpha, dp_current)
       t_alpha = rule.alpha.transform(t)
       p_t_alpha = t_alpha.p[layer_name]
       t_alpha_array = Array.new
       n_pt_alpha = length(p_t_alpha)
       cont = 0 
       while (cont < n_pt_alpha)
         t_alpha_array.push search(p_t_alpha,cont).key
         cont += 1
       end
       
       
      
       if ((t_alpha_array.size() == dp_current.size()) and (t_alpha_array.size()>=3))
         cont2 = 0
         result = true
         while (cont2<t_alpha_array.size())
           cont3 = cont2+1
           while ((cont3>cont2) and (cont3<t_alpha_array.size()))
             t_alpha.s[layer_name].reset_iterator()
             connectedPattern = t_alpha.connected?(t_alpha_array[cont2].point, t_alpha_array[cont3].point, layer_name)
             
             shape.s[layer_name].reset_iterator
             connectedDesign = shape.connected?(dp_current[cont2].point, dp_current[cont3].point, layer_name)
             
             result = (result and (!connectedPattern or connectedDesign))
             
             cont3 = cont3+1
           end
           cont2 = cont2+1
         end
       else
         result = false
       end      
       
       
       if result
         possible_transformations.push [t, dp_alpha.clone, dp_current.clone]
         return true
       else
         return false
       end
      # puts"------------------------------------------------------------"
     
 end
 
 
 
 
     
  def angles_comparer(sol, pattern_angle, pattern_angle1, n, pattern_size)
    if (n>=2 and n<pattern_size)
            
      sol_points = Array.new
      sol_points[0] = sol[n-2]
      sol_points[1] = sol[n-1]
      sol_points[2] = sol[n]
      
      sol_angle = get_angle(sol_points)
      
     if (Shade.custom_epsilon == Constants::EPSILON)
       return ((pattern_angle - sol_angle).abs < Constants::EPSILON)
     elsif (Shade.custom_epsilon == -1.0)
       return true 
     else
       return ((pattern_angle - sol_angle).abs < Shade.custom_epsilon)
     end
    
    elsif (n>=2)
      sol_points = Array.new
      sol_points[0] = sol[n-2]
      sol_points[1] = sol[n-1]
      sol_points[2] = sol[n]
     
      sol_angle = get_angle(sol_points)
     
      
      sol_final_points = Array.new
      sol_final_points[0] = sol[n]
      sol_final_points[1] = sol[0]
      sol_final_points[2] = sol[1]
     
      sol_angle1 = get_angle(sol_final_points)
      
     if (Shade.custom_epsilon == Constants::EPSILON)
       return (((pattern_angle - sol_angle).abs < Constants::EPSILON) and ((pattern_angle1 - sol_angle1).abs < Constants::EPSILON))
     elsif (Shade.custom_epsilon == -1.0)
       return true 
     else
       return (((pattern_angle - sol_angle).abs < Shade.custom_epsilon) and ((pattern_angle1 - sol_angle1).abs < Shade.custom_epsilon)) 
     end  
       
       
    else
      return true
    end
  end
   
  def get_angle(points)
     
     n=2
     
     distances = Array.new
     #For the points 0 and 1 (a)
     distances[0] = Math.sqrt(((points[n-2].y - points[n-1].y)**2) + ((points[n-2].x - points[n-1].x)**2))
     #For the points 1 and 2 (b)
     distances[1] = Math.sqrt(((points[n-1].y - points[n].y)**2) + ((points[n-1].x - points[n].x)**2))
     #For the points 2 and 0 (c)
     distances[2] = Math.sqrt(((points[n].y - points[n-2].y)**2) + ((points[n].x - points[n-2].x)**2))
     
     #puts"sol_angles = #{sol}"
         
         c = distances[0]
         a = distances[1]
         b = distances[2]
   
         #ad = ((b**2 + c**2 - a**2)/(2*b*c))
     bd = ((a**2 + c**2 - b**2)/(2*a*c))
     #cd = ((a**2 + b**2 - c**2)/(2*a*b))
     
     angle = nil  
     if (bd >= 1.0)
       angle = 0
     elsif (bd <= -1.0)
       angle = Math::PI
     else
       angle = Math.acos(bd)
     end
     return angle
  end
  
  
  
#  def selectPoint(pattern, design, d_flags, n)
#    p_point = search(pattern, n)
#    
#    #puts("p_point #{p_point[0].value}")
#    #puts("p_point #{p_point[1].key.point}")
#    
#    if p_point[0] != nil
#      pos = searchNext(p_point[0], d_flags)
#      
#      #puts("pos #{pos}")
#      
#      if (pos != nil)
#        d_point = design.get_node(p_point[0]).list.get_node_i(pos)
#        return d_point
#      else
#        return nil
#      end
#    else
#      return nil
#    end
#  end
  
#  def searchNext(type, d_flags)
#    flag_node = d_flags.get_node(type)
#    
#    found =false
#    flag_node.list.reset_iterator()
#    pos = 0
#    while ((fn = flag_node.list.get_next()) and !found)
#      #puts"fn.list #{fn.list}"
#      if (fn.list==false)
#        found = true
#        fn.list = true 
#      else
#        pos += 1
#      end
#    end 
#    if found
#      return pos
#    else
#      return nil
#    end
#  end
  
  
def get_brothers(type,chosen_points)
   chosen_node = chosen_points.get_node(type)
   chosen_node.list.reset_iterator()
   sol = Array.new
   while (fn = chosen_node.list.get_next())
     if (!fn.list)
       sol.push fn 
     end
   end 
   return sol
 end
  
  
#  def search(list, n)
#    sum = 0
#    node = 0
#    found = false
#    while (l_node = list.get_node_i(node) and !found)
#      if (sum + l_node.list.size)>n
#        found = true
#      else
#        sum = sum + (l_node.list.size())
#        node += 1
#      end
#    end
#    if found
#      pos = n-sum
#      #puts"pos = #{pos}"
#      el = [list.get_node_i(node).key, list.get_node_i(node).list.get_node_i(pos)]  
#    else
#      # el returns [key, point]
#      el = [nil, nil]
#    end
#    return el
#  end
 
def search(list, n)
    sum = 0
    node = 0
    found = false
    while (l_node = list.get_node_i(node) and !found)
      if (sum + l_node.list.size)>n
        found = true
      else
        sum = sum + (l_node.list.size())
        node += 1
      end
    end
    if found
      pos = n-sum
      #puts"pos = #{pos}"
      el = list.get_node_i(node).list.get_node_i(pos)  
    else
      # el returns [key, point]
      el = nil
    end
    return el
  end
  
def search_Array(list, n)
    sum = 0
    node = 0
    found = false
    while (l_node = list[node] and !found)
      if (sum + l_node.list.size)>n
        found = true
      else
        sum = sum + (l_node.list.size())
        node += 1
      end
    end
    if found
      pos = n-sum
      #puts"pos = #{pos}"
      el = list[node].list[pos]  
    else
      # el returns [key, point]
      el = nil
    end
    return el
  end

  def get_type(list, n)
    sum = 0
    node = 0
    found = false
    while ((l_node = list.get_node_i(node)) and !found)
      if (sum + l_node.list.size)>n
        found = true
      else
        sum = sum + (l_node.list.size())
        node += 1
      end
    end
    if found
     el = list.get_node_i(node).key  
    else
      el = nil
    end
    return el
  end
  
def get_type_Array(list, n)
    sum = 0
    node = 0
    found = false
    while ((l_node = list[node]) and !found)
      if (sum + l_node.list.size)>n
        found = true
      else
        sum = sum + (l_node.list.size())
        node += 1
      end
    end
    if found
     el = list[node].key  
    else
      el = nil
    end
    return el
  end
  
  
  def length(l_points)
    sum = 0
    l_points.reset_iterator
    while (l_node = l_points.get_next)
      sum += l_node.list.size
    end
    return sum
  end
  
def length_Array(l_points)
  sum = 0
  cont=0
  l_points.each{|l_node|
    sum += l_node.list.size
  }
  return sum
end
  
  
	#c1:: a float number
	#c2:: a float number
	#c3:: a float number
	#
	#returns:: true if the three numbers are equal with a tolerance given by Constants::EPSILON	
 def eql_c_eps(a_alpha, a_current)
   dif1 = (a_alpha[0] - a_current[0]).abs
   result = (dif1 < Constants::EPSILON)
   dif2 = (a_alpha[1] - a_current[1]).abs
   result = (result && (dif2 < Constants::EPSILON))
   dif3 = (a_alpha[2] - a_current[2]).abs
   result = (result && (dif3 < Constants::EPSILON))
   return result
 end
	
#	def eql_c_eps(c1, c2, c3)
#		dif1 = (c1 - c2).abs
#		result = (dif1 < Constants::EPSILON)
#		dif2 = (c2 - c3).abs
#		result = (result && (dif2 < Constants::EPSILON))
#    dif3 = (c1 - c3).abs
#    result = (result && (dif3 < Constants::EPSILON))
#    return result
#	end
	
	#c1:: a float number
	#c2:: a float number
	#c3:: a float number
	#
	#returns:: true if the three numbers are equal with a tolerance given by ep
 def eql_c_eps_custom(a_alpha, a_current, newEpsilon)
    dif1 = (a_alpha[0] - a_current[0]).abs
    result = (dif1 < newEpsilon)
    dif2 = (a_alpha[1] - a_current[1]).abs
    result = (result && (dif2 < newEpsilon))
    dif3 = (a_alpha[2] - a_current[2]).abs
    result = (result && (dif3 < newEpsilon))
    return result
 end

#	def eql_c_eps_custom(c1, c2, c3, newEpsilon)
#		dif1 = (c1 - c2).abs
#		result = (dif1 < newEpsilon)
#		dif2 = (c2 - c3).abs
#		result = (result && (dif2 < newEpsilon))
#    dif3 = (c1 - c3).abs
#    result = (result && (dif3 < newEpsilon))
#    return result
#	end
	
	
	#Applies a random rule to the current shape
	def apply_rule_random()
		rules_index = Array.new
		for i in 0..(@grammar.rules.size-1)
			rules_index[i] = i
		end
		
		applied = false
		
		while (!applied && !rules_index.empty?)
			random_rule_index = rules_index[rand(rules_index.size)]
			random_rule_id = @grammar.rules[random_rule_index].rule_id
			
			applied = self.apply_rule(random_rule_id)

			if !applied
				rules_index.delete random_rule_index
			end
		end
		return applied
		
	end
	
	
	#Undoes the last taken step (that is, the current shape becomes the one that existed when the last rule had not been applied)
	def undo
		
		pair = @execution_history.pop
		if pair
			@current_shape.erase
			@current_shape = pair[2]
			@current_shape.refresh
		end
	end
	
	#Resets the execution, so the current shape becomes the axiom again
	def reset
		@execution_history = Array.new
		if @current_shape
			@current_shape.erase
		end
		
		@current_shape = CurrentLabelledShape.new(Array.new, Array.new)
		
		@grammar.axiom.p.each_key {|layer_name|
			@current_shape.p[layer_name] = @grammar.axiom.p[layer_name].clone
		}
		
		@grammar.axiom.s.each_key {|layer_name|
			@current_shape.s[layer_name] = BalancedBinaryTree.new
			@grammar.axiom.s[layer_name].reset_iterator
			while (s_node = @grammar.axiom.s[layer_name].get_next)
				@current_shape.s[layer_name].insert_node BalancedBinaryTreeNode.new(0, nil, nil, s_node.key, s_node.list.clone)
			end
		}
		
		@current_shape.create_pi
		@current_shape.paint(@show_labels)
	end
	
end
#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class gathers an Execution object and the necessary information in order to save it in a file
class Project
	
	#The Execution object
	attr_accessor :execution
	#The title
	attr_reader :title
	#True iff the project is saved
	attr_writer :saved
	#Path in which the project has been saved
	attr_reader :path
	#true iff the view is been refreshed
	attr_accessor :modifying
	#true iff a rule shape is being deleted
	attr_accessor :erasing
	
	#Initializing
	def initialize(execution)
		@execution = execution
		
		@saved = true
		@path = nil       #the path in the OS file system
		
		@title = Constants::DEFAULT_PROJECT_TITLE
		
		@modifying = false
		
		@erasing = false

	end
	
	#path:: path to save the project in
	#
	#Saves the project in the specified path
	def save(path = @path, text = false)
		#the path is a .prj file
		#we need the directory
		directory = ShadeUtils.get_directory_from_path(path)
		title = ShadeUtils.get_title_from_path(path)
		File.open(path.strip, 'w') do |f|
			f.write("#{title}Grammar.gr2\n")
		end
		@path = path
		@execution.grammar.save("#{directory}#{title}Grammar.gr2", text)
		@saved = true
	end
	
	#Returns true if both the project and its related grammar are saved
	def saved()
		return (@execution.grammar.saved and @saved)
	end
	
	#Removes all the attached observers
	def remove_observers()
		if Shade.using_sketchup
			size = execution.grammar.rules.size
			i = 0
			while i < size
				execution.grammar.remove_rule(size-i-1)
				i += 1
			end

			Sketchup.active_model.entities.remove_observer Shade.rule_groups_observer
			Shade.rule_groups_observer = nil
			GC.start
		end
	end
	
	#new_title:: String with the new title for the project
	#closing:: true iff SketchUp is being closed
	#
	#Changes the title of the project to new_title
	def set_title(new_title, closing = false)
		@title = title
		if Shade.using_sketchup
			if !closing
				if @title_text
					Sketchup.active_model.entities.erase_entities @title_text
				end
				if Shade.show_text
					@title_text = Sketchup.active_model.entities.add_text("Project: " + @title, Constants::PT_PROJECT_TEXT)
				end
			end
		end
	end
	
	#path:: new path
	#closing:: true iff we are closing SU
	#
	#Sets the path
	def set_path(path, closing = false)
		#Set the path attribute
		@path = path
		
		if path
			set_title(ShadeUtils.get_title_from_path(path), closing)
		else
			set_title(Constants::DEFAULT_PROJECT_TITLE, closing)
		end
	end
	
	#path:: path to load the project from
	#
	#Loads the project from the specified path
	def load(path)
		@path = path
		#the path is a .prj file
		#we need the directory
		directory = ShadeUtils.get_directory_from_path(path)
		
		File.open(path.strip, 'r') do |f|
			while line = f.gets
				grammar_title = line.strip
				@execution.grammar.load("#{directory}#{grammar_title}")
			end
		end
	end
	
	#force:: true if we want to force refreshing, even when no changes have been registered
	#
	#Refreshes the view of the shapes in the project (that is, the rule shapes and the current shape)
	def refresh(force = false)
		if Shade.using_sketchup
			@modifying = true
			if @execution
				@execution.current_shape.refresh(@execution.show_labels)
				if @execution.grammar
					@execution.grammar.rules.each {|rule|
						rule.alpha.refresh(force)
						rule.beta.refresh(force)
					}
				end
			end
			@modifying = false
		end
	end
	
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class wrapps some global variables, including the current project
class Shade
	
	#returns:: true if SketchUp is being used 
	def Shade.using_sketchup
		return @@using_sketchup
	end
	
	#using_sketchup:: true if SketchUp is being used
	#
	#Sets the flag using_sketchup to the specified value
	def Shade.using_sketchup=(using_sketchup)
		@@using_sketchup = using_sketchup
	end

	#returns:: the current Project object
	def Shade.project
		return @@project
	end
	
	#project:: a Project object
	#
	#Sets the project
	def Shade.project=(project)
		@@project = project
	end
	
	#returns:: the RuleGroupsObserver object
	def Shade.rule_groups_observer
		return @@rule_groups_observer
	end
	
	#rule_groups_observer:: a RuleGroupsObserver object
	#
	#Sets the rule groups observer
	def Shade.rule_groups_observer=(rule_groups_observer)
		@@rule_groups_observer = rule_groups_observer
	end
	
	#returns:: the flag show_text
	def Shade.show_text
		return @@show_text
	end
	
	#show_text:: true iff text is to be shown in the SketchUp canvas (titles for the project and the grammar)
	#
	#Sets the show_text flag
	def Shade.show_text=(show_text)
		@@show_text = show_text
	end
	
	#label_radius:: the desired radius, in meters, for the labels
	#
	#Sets the label radius to the specified value
	def Shade.label_radius=(label_radius)
		@@label_radius = label_radius
	end
	
	#returns:: the current label radius
	def Shade.label_radius
		return @@label_radius
	end
	
	#epsilon:: the desired epsilon
	#
	#Sets epsilon to the specified value given by the user
	def Shade.custom_epsilon=(new_epsilon)
		@@custom_epsilon = new_epsilon
	end
	
	#returns:: the current epsilon
	def Shade.custom_epsilon
		return @@custom_epsilon
	end
	
	
	#mu_min:: the desired mu
	#
	#Sets mu to the specified value given by the user
	def Shade.mu_min=(new_mu_min)
		@@mu_min = new_mu_min
	end

	#returns:: the current mu_min
	def Shade.mu_min
		return @@mu_min
	end

	#hausdorff_threshold:: the desired hausdorff_threshold
	#
	#Sets hausdorff_threshold to the specified value given by the user
	def Shade.hausdorff_threshold_sets(new_hausdorff_threshold_X, new_hausdorff_threshold_Y)
		@@hausdorff_threshold_X = new_hausdorff_threshold_X
		@@hausdorff_threshold_Y = new_hausdorff_threshold_Y
	end

	#returns:: the current hausdorff_threshold
	def Shade.hausdorff_threshold
		return [@@hausdorff_threshold_X, @@hausdorff_threshold_Y] 
	end
	
	
	#execution_environment:: the desired execution_environment between ruby or sketchup
	#
	#Sets execution_environment to the specified value given by the user
	def Shade.execution_environment_flag=(new_execution_environment)
		@@execution_environment_flag = new_execution_environment
	end

	#returns:: the current execution_environment
	def Shade.execution_environment_flag
		return @@execution_environment_flag
	end	
	
	
end
