begin
	require 'sketchup' # First we pull in the standard API hooks.
	require 'ShaDe//lib//utils.rb'
	require 'ShaDe//lib//data-structures.rb'
	require 'ShaDe//lib//main-structures.rb'
rescue LoadError
	require "#{File.dirname(__FILE__)}/utils"
	require "#{File.dirname(__FILE__)}/data-structures"
	require "#{File.dirname(__FILE__)}/main-structures"
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#Class that establishes a lexicographyc ordering of the points, taking into account
#a tolerance threshold given by Constants::EPSILON
class OrderedPoint
	
	attr_writer :point

	#point:: a 3D point
	#
	#Initializes the ordered point
	def initialize(point)
		@point = point
	end
	
	#other_point:: another OrderedPoint
	#
	#returns:: true if this point is lesser than other_point
	def < (other_point)
		result = false
		dif_x = @point.x - other_point.x
		abs_x = dif_x.abs
		if (dif_x < 0) && (abs_x > Constants::EPSILON)
			result = true
		elsif abs_x < Constants::EPSILON
			dif_y = @point.y - other_point.y
			abs_y = dif_y.abs
			if (dif_y < 0) && (abs_y > Constants::EPSILON)
				result = true
			end
		end
		return result
	end
	
	#other_point:: another OrderedPoint
	#
	#returns:: true if this point is equal to other_point
	def == (other_point)
		result = false
		if other_point.kind_of? OrderedPoint
			dif_x = @point.x - other_point.x
			abs_x = dif_x.abs
			dif_y = @point.y - other_point.y
			abs_y = dif_y.abs
			if ((abs_x < Constants::EPSILON) && (abs_y < Constants::EPSILON))
				result = true
			end
		end
		return result	
	end
	
	#other_point:: another OrderedPoint
	#
	#returns:: true if this point is bigger than other_point
	def > (other_point)
		return (other_point < self)
	end
	
	#other_point:: another OrderedPoint
	#
	#returns:: true if this point is lesser or equal than other_point
	def <= (other_point)
		less = (self < other_point)
		equal = (self == other_point)
		return (less || equal)
	end
	
	#other_point:: another OrderedPoint
	#
	#returns:: true if this point is bigger or equal than other_point
	def >= (other_point)
		great = (other_point < self)
		equal = (self== other_point)
		return (great || equal)
	end
	
	#returns:: the x coordinate
	def x()
		return @point.x
	end
	
	#returns:: the y coordinate
	def y()
		return @point.y
	end
	
	#returns:: an OrderedPoint object identical to this
	def clone()
		return OrderedPoint.new(@point.clone)
	end
	
	#other_point:: another OrderedPoint
	#
	#returns:: true if this point is equal to other_point
	def eql?(other_point)
		result = false
		if other_point.kind_of? OrderedPoint
			dif_x = @point.x - other_point.x
			abs_x = dif_x.abs
			dif_y = @point.y - other_point.y
			abs_y = dif_y.abs
			if ((abs_x < Constants::EPSILON) && (abs_y < Constants::EPSILON))
				result = true
			end
		end
		return result		
	end
	
	#returns:: the hash code of this point
	def hash
		return [self.x.hash, self.y.hash].hash
	end
	
	#t:: 2x3 transformation matrix
	#
	#Transform the point according to t
	def transform(t)
		#Extract the coefficients of the transformation matrix
		ax = t[0]
		bx = t[1]
		cx = t[2]
		ay = t[3]
		by = t[4]
		cy = t[5]
		new_shape = self.clone

		#Transform the point
		new_x = @point.x * ax + @point.y * bx + cx
		new_y = @point.x * ay + @point.y * by + cy
		
		@point.x = new_x
		@point.y = new_y
	end
	
	#returns:: the internal Point
	def point()
		if Shade.using_sketchup
			return Geom::Point3d.new(@point.x, @point.y, 0)
		else
			return @point
		end
	end
end


#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#Class that represents a 3D point
class Point
	attr_accessor :x
	attr_accessor :y
	attr_accessor :z
	
	#x:: x coordinate of the point
	#y:: y coordinate of the point
	#z:: z coordinate of the point (optional)
	#
	#Initializes the point
	def initialize(x, y, z = 0)
		@x, @y, @z = x, y, z
	end
	
	#another_point:: a Point object
	#
	#returns:: the distance between this point and another_point
	def distance(another_point)
		return Math.sqrt((@x - another_point.x)**2 + (@y - another_point.y)**2)
	end
	
	#line_descriptor:: a LineDescriptor object
	#a:: a Point object of the line described by line_descriptor
	#b:: a Point object of the line described by line_descriptor, distinct from a
	#
	#returns:: the point in the line_descriptor that is the ortogonal projection of this point on the line described by line_descriptor
	def project_to_line(line_descriptor, a, b)
		r = ((a.y - @y)*(a.y - b.y) - (a.x - @x)*(b.x - a.x)).quo(Math.sqrt((b.x - a.x)**2 + (b.y - a.y)**2)**2)
		
		px = a.x + r*(b.x - a.x)
		py = a.y + r*(b.y - a.y)
		
		return Point.new(px, py, 0)
		
	end
	
	#returns:: a Point object identical to this
	def clone()
		return Point.new(@x, @y, @z)
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a Line Descriptor, used to describe the 'mother line' of a set of segments
class LineDescriptor
	#The sine of the angle
	attr_reader :sine
	
	#Intercept:: the point in which the line intercepts the y-axis. In case it is vertical, the x-axis
	attr_reader :intercept
	
	#sine:: the sine of the angle of the line.
	#intercept:: the point in which the line intercepts the y-axis. In case it is vertical, the x-axis
	#
	# Initializes the line
	def initialize(sine, intercept)
		@sine, @intercept = sine, intercept
	end
	
	#point:: an OrderedPoint
	#
	#returns:: true iff the point satisfies the line ecuation
	def satisfied? (point)
		result = false
		
		cosine = Math.sqrt(1-(@sine**2))
		if cosine == 0 #Vertical
			result = (point.x == @intercept)
		elsif @sine == 0 #Horizontal
			result = (point.y== @intercept)
		else #General case
			slope = @sine /cosine
			result = (point.y == (point.x * slope + @intercept))
		end
		
		return result
	end
	
	#other_line_descriptor:: another LineDescriptor object
	#
	#returns:: true iff this LineDescriptor is lesser than other_line_descriptor, w.r.t. a lexicographic order of (sine, intercept)
	def < (other_line_descriptor)
		#It works because the angles of the lines are always on the first and fourth quadrant. The growth of the sine 
		#in these quadrants is identical to the tangent growth.
		
		result = false
		if other_line_descriptor.kind_of? LineDescriptor
			dif_sine = (@sine-other_line_descriptor.sine)
			abs_sine = dif_sine.abs
			if (dif_sine < 0) && (abs_sine > Constants::EPSILON)
				result = true
			elsif abs_sine < Constants::EPSILON
				dif_intercept =(@intercept-other_line_descriptor.intercept)
				abs_intercept = dif_intercept.abs
				if (dif_intercept < 0) && (abs_intercept > Constants::EPSILON)
					result = true
				end
			end
		end
		return result

	end
		  
	#other_line_descriptor:: another LineDescriptor object
	#
	#returns:: true iff this LineDescriptor is equal than other_line_descriptor
	def == (other_line_descriptor)
		
		result = false
		if other_line_descriptor.kind_of? LineDescriptor
			dif_sine = (@sine-other_line_descriptor.sine).abs
			dif_intercept = (@intercept-other_line_descriptor.intercept).abs
			result = ((dif_sine < Constants::EPSILON) && (dif_intercept < Constants::EPSILON))
		end
		return result
	end
	
	#returns:: a new LineDescriptor, identical to this one
	def clone()
		return LineDescriptor.new(@sine, @intercept)
	end
	
	#returns:: the hash code for this line_descriptor
	def hash
		return [@sine.hash, @intercept.hash].hash
	end
	
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a segment, with its end points
class Segment
	
	#An OrderedPoint for the tail (the smaller point) of the segment
	attr_reader :tail
	#An OrderedPoint for the head (the bigger point) of the segment
	attr_reader :head
	#A LineDescriptor object for the line on which the segment lies
	attr_reader :line_descriptor
	
	#tail:: the first point of the segment
	#head:: the second point of the segment
	#
	#Initialize the segment, ordering the tail and head propertly, so tail < head
	def initialize(tail, head)
		#Order the tail and head
		if tail < head
			@tail = tail
			@head = head
		else
			@tail = head
			@head = tail
		end
		
		#Compute the line descriptor
		if (@tail.x - @head.x).abs < Constants::EPSILON #Vertical
			sine = 1
			intercept = @tail.x
		elsif (@tail.y - @head.y).abs <  Constants::EPSILON #Horizontal
			sine = 0
			intercept = @tail.y
		else
			sine = ((@head.y - @tail.y) / Math.sqrt(((@head.x - @tail.x)**2 )+((@head.y - @tail.y)**2)))
			if ((@head.x - @tail.x) > 0)
				den = Math.sqrt((@head.x - @tail.x)**2)
			else
				den = -1 * Math.sqrt((@head.x - @tail.x)**2)
			end
			if ((@head.y - @tail.y) > 0)
				mult = Math.sqrt((@head.y - @tail.y)**2)
			else
				mult = -1 * Math.sqrt((@head.y - @tail.y)**2)
			end
			intercept = (-1*@tail.x/den)*(mult) + @tail.y
		end
		@line_descriptor = LineDescriptor.new(sine, intercept)
	end
	
	#new_tail:: an OrderedPoint
	#
	#Sets the tail to new_tail
	def tail=(new_tail)
		#Order the tail and head
		if new_tail < @head
			@tail = new_tail
		else
			@tail = @head
			@head = new_tail
		end
		
		#Compute the line descriptor
		if (@tail.x - @head.x).abs < Constants::EPSILON #Vertical
			sine = 1
			intercept = @tail.x
		elsif (@tail.y - @head.y).abs <  Constants::EPSILON#Horizontal
			sine = 0
			intercept = @tail.y
		else
			sine = ((@head.y - @tail.y) / Math.sqrt(((@head.x - @tail.x)**2 )+((@head.y - @tail.y)**2)))
			if ((@head.x - @tail.x) > 0)
				den = Math.sqrt((@head.x - @tail.x)**2)
			else
				den = -1 * Math.sqrt((@head.x - @tail.x)**2)
			end
			if ((@head.y - @tail.y) > 0)
				mult = Math.sqrt((@head.y - @tail.y)**2)
			else
				mult = -1 * Math.sqrt((@head.y - @tail.y)**2)
			end
			intercept = (-1*@tail.x/den)*(mult) + @tail.y
		end
		@line_descriptor = LineDescriptor.new(sine, intercept)
	end
	
	#new_head:: an OrderedPoint
	#
	#Sets the head to new_head
	def head=(new_head)
		#Order the tail and head
		if @tail < new_head
			@head = new_head
		else
			@head = @tail
			@tail = new_head
		end
		
		#Compute the line descriptor
		if (@tail.x - @head.x).abs < Constants::EPSILON #Vertical
			sine = 1
			intercept = @tail.x
		elsif (@tail.y - @head.y).abs < Constants::EPSILON #Horizontal
			sine = 0
			intercept = @tail.y
		else
			sine = ((@head.y - @tail.y) / Math.sqrt(((@head.x - @tail.x)**2)+((@head.y - @tail.y)**2)))
			if ((@head.x - @tail.x) > 0)
				den = Math.sqrt((@head.x - @tail.x)**2)
			else
				den = -1 * Math.sqrt((@head.x - @tail.x)**2)
			end
			if ((@head.y - @tail.y) > 0)
				mult = Math.sqrt((@head.y - @tail.y)**2)
			else
				mult = -1 * Math.sqrt((@head.y - @tail.y)**2)
			end
			intercept = (-1*@tail.x/den)*(mult) + @tail.y
		end
		@line_descriptor = LineDescriptor.new(sine, intercept)
	end
	
	#point:: a point
	#
	#returns:: true iff the point is coincident with the segment, that is, is 'inside' the segment
	def coincident?(point)
		result = false
		
		if (point == @tail) || (point == @head)
			result = true
		elsif (@line_descriptor.satisfied? point) && (@tail < point) && (point < @head)
			result = true
		end
		
		return result
	end
	
	#other_segment:: another segment
	#
	#returns:: the resulting segment in case the two segments overlap.
	def overlap?(other_segment)
		raise ArgumentError, 'The argument is not of type Segment' unless other_segment.kind_of? Segment
		result = nil
		if collinear?(other_segment)
			if (@tail < other_segment.head) && (other_segment.tail < @head)
				new_tail = @tail
				if @tail < other_segment.tail
					new_tail = other_segment.tail
				end
				
				new_head = @head
				if other_segment.head < @head
					new_head = other_segment.head
				end
				
				result = Segment.new(new_tail, new_head)
			end
		end
		return result
	end
	
	#other_segment:: another segment
	#
	#returns:: true iff both line descriptors are equal, that is, both segments share the same 'mother line'
	def collinear?(other_segment)
		raise ArgumentError, 'The argument is not of type Segment' unless other_segment.kind_of? Segment
		return @line_descriptor == other_segment.line_descriptor
	end
	
	#other_segment:: another segment
	#
	#returns:: true iff this segment is lesser than other_segment. Only collinear segments can be compared. 
	#A segment A is lesser than a segment B iff the head of A is smaller than the tail of B.
	def < (other_segment)
		raise ArgumentError, 'The argument is not of type Segment' unless other_segment.kind_of? Segment
		#raise ArgumentError, 'Segments are not collinear' unless collinear?(other_segment)
		return @head < other_segment.tail
	end
	
	#other_segment:: another segment
	#
	#returns:: true iff this segment is equal to other_segment. Only collinear segments can be compared. 
	def == (other_segment)
		result = false
		if other_segment.kind_of? Segment
			result = ((@head == other_segment.head) && (@tail == other_segment.tail))
		end
		return result
	end
	
	#returns:: a new Segment object, identical to this one
	def clone()
		return Segment.new(@tail.clone, @head.clone)
	end
	
	#returns:: the hash code for this segment
	def hash
		return [@line_descriptor.hash, @tail.hash, @head.hash].hash
	end
	
	#returns:: the distance between the tail and the head of this segment
	def length
		return @tail.point.distance(@head.point)
	end
	
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#A label can be associated to points
class Label
	#Value of the label. It is basically a Sketchup::Material object or Constants::INTERSECTION_LABEL
	attr_reader :value
	
	#value:: the value for the label
	#
	#Initializing the label
	def initialize(value)
		if Shade.using_sketchup
			if (value.kind_of? Sketchup::Material)
				@value = value.name
			else
				@value = value
			end
		else
			@value = value
		end
	end
	
	#other_label:: another Label
	#
	#returns:: true if this label is lesser than the specified label
	def <(other_label)
		if Shade.using_sketchup
			if @value.kind_of? Sketchup::Material
				name = @value.name
			else
				name = @value
			end
		else
			name = @value
		end
		if Shade.using_sketchup
			if other_label.value.kind_of? Sketchup::Material
				other_name = other_label.value.name
			else
				other_name = other_label.value
			end
		else
			other_name = other_label.value
		end
		return name < other_name
	end
	
	#returns:: the name of the label
	def name()
		if Shade.using_sketchup
			if @value.kind_of? Sketchup::Material
				return @value.name
			else
				return @value
			end
		else
			return @value
		end
	end
	
	
	#other_label:: another Label
	#
	#returns:: true if this label and other_label are identical
	def == (other_label)
		result = false
		if other_label.kind_of? Label
			if Shade.using_sketchup
				if @value.kind_of? Sketchup::Material
					name = @value.name
				else
					name = @value
				end
			else
				name = @value
			end
			if Shade.using_sketchup
				if other_label.value.kind_of? Sketchup::Material
					other_name = other_label.value.name
				else
					other_name = other_label.value
				end
			else
				other_name = other_label.value
			end
			result = (name == other_name)
		end
		return result
	end
	
	#is_design:: true iff we need a design shape
	#
	#Produces another Label, identical to this one
	def clone()
		new_label = Label.new(@value)
		return new_label
	end
	
	#returns:: the hash code for this label
	def hash
		return @value.hash
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a LabelledShape, that is, a shape with any number of labels
class LabelledShape
	#Hash of lists of ListNodes, for the colinear segments
	#There is one list for each present layer, mapped by the layer name
	attr_accessor :s
	
	#Hash of list of ListNodes, for the labelled points
	#There is one list for each present layer, mapped by the layer name
	attr_accessor :p
	
	#edges:: list of edges
	#points_and_materials:: list of pairs (point, material)
	#
	#Initializes the hashes of maximal lines and labelled points, associated with layer 0
	def initialize(edges, points_and_materials)
		if !@s
			@s = Hash.new(nil)
			if Shade.using_sketchup
				Sketchup.active_model.layers.each { |layer|
					@s[layer.name] = LinearLinkedList.new
				}
			else
				@s["Layer0"] = LinearLinkedList.new
			end
		end
		if !@p
			@p = Hash.new(nil)
			if Shade.using_sketchup
				Sketchup.active_model.layers.each { |layer|
					@p[layer.name] = LinearLinkedList.new
				}
			else
				@p["Layer0"] = LinearLinkedList.new
			end
		end
		edges.each { |e|
			segment = Segment.new(OrderedPoint.new(e.start.position), OrderedPoint.new(e.end.position))
			segment_list = LinearLinkedList.new

			if @s["Layer0"].kind_of? LinearLinkedList
				node = LinearLinkedListNode.new(segment.line_descriptor, segment_list, nil)
			else
				node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, segment.line_descriptor, segment_list)
			end
			
			inserted_node = @s["Layer0"].insert_node(node) #Insert the node corresponding to the line descriptor of the segment

			#We create an auxiliar list filled with the new segment to add, in order to make the union and obtain the maximal lines
			new_segment_list = LinearLinkedList.new
			segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
			new_segment_list.insert_node(segment_node)
			
			op_rel(inserted_node.list,  new_segment_list, Constants::UNION, Constants::SEGMENTS)
		}
		
		#Compound the label lists
		points_and_materials.each { |pair|
			point = OrderedPoint.new(pair[0])
			label = Label.new(pair[1])
			point_list = LinearLinkedList.new
			
			if @p["Layer0"].kind_of? LinearLinkedList
				node = LinearLinkedListNode.new(label, point_list, nil)
			else
				node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, label, point_list)
			end
			
			inserted_node = @p["Layer0"].insert_node(node) #Insert the node corresponding to the label of the point
			
			point_node = LinearLinkedListNode.new(point, nil, nil)
			inserted_node.list.insert_node(point_node) #Insert the point node
		}		
		recompute_intersection_points
	end
	
	#edges:: an array of SketchUp Edges
	#points_and_materials:: an array of pairs [Point3d, Material], both of them are classes of SketchUp
	#layer:: name of the layer that is affected
	#
	#Refresh the internal representation of the shape according to the current SketchUp canvas content inside the group of the shape 
	def refresh_from_info(edges, points_and_materials, layer)
		if (@s[layer] and @p[layer])
			if @s[layer].kind_of? BalancedBinaryTree
				@s[layer] = BalancedBinaryTree.new
			else
				@s[layer] = LinearLinkedList.new
			end
			@p[layer] = LinearLinkedList.new
			edges.each { |e|
				segment = Segment.new(OrderedPoint.new(e.start.position), OrderedPoint.new(e.end.position))
				segment_list = LinearLinkedList.new

				if @s[layer].kind_of? LinearLinkedList
					node = LinearLinkedListNode.new(segment.line_descriptor, segment_list, nil)
				else
					node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, segment.line_descriptor, segment_list)
				end
				
				inserted_node = @s[layer].insert_node(node) #Insert the node corresponding to the line descriptor of the segment

				#We create an auxiliar list filled with the new segment to add, in order to make the union and obtain the maximal lines
				new_segment_list = LinearLinkedList.new
				segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
				new_segment_list.insert_node(segment_node)
				
				op_rel(inserted_node.list,  new_segment_list, Constants::UNION, Constants::SEGMENTS)
			}
			
			#Compound the label lists
			points_and_materials.each { |pair|
				point = OrderedPoint.new(pair[0])
				label = Label.new(pair[1])
				point_list = LinearLinkedList.new
				
				if @p[layer].kind_of? LinearLinkedList
					node = LinearLinkedListNode.new(label, point_list, nil)
				else
					node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, label, point_list)
				end
				
				inserted_node = @p[layer].insert_node(node) #Insert the node corresponding to the label of the point
				
				point_node = LinearLinkedListNode.new(point, nil, nil)
				inserted_node.list.insert_node(point_node) #Insert the point node
			}		
			recompute_intersection_points
		end
	end
	
	#point:: a Point object
	#value:: the name of the label value
	#layer_name:: the name of the layer on which the label is going to be added
	#
	#Adds a label to the shape in the position determined by point, with the specified value and in the specified layer
	def add_label(point, value, layer_name)
		if @p[layer_name]
			label = Label.new(value)
			point_list = LinearLinkedList.new
			
			node = LinearLinkedListNode.new(label, point_list, nil)
			
			inserted_node = @p[layer_name].insert_node(node) #Insert the node corresponding to the label of the point
			
			point_node = LinearLinkedListNode.new(OrderedPoint.new(point), nil, nil)
			inserted_node.list.insert_node(point_node) #Insert the point node
		end
	end
	
	#other_shape:: another LabelledShape
	#op_rel_type:: the operation or relation to perform. One of the following: Constants::UNION, Constants::INTERSECTION, Constants::DIFFERENCE,
	#Constants::SUBSHAPE, Constants::EQUAL
	#c:: Constants::SEGMENTS if segments are affected, Constants::POINTS if points are affected.
	#
	#returns:: true iff the specified relation (subshape or equal) holds (or false if it does not hold). In case it is an operation,
	#it just overwrites this shape with the resulting shape of the operation OR returns another shape in case it is an intersection
	def shape_expression(other_shape, op_rel_type, c, print = false)

		global_flag = true
		
		result = LabelledShape.new(Array.new, Array.new)
		if (c == Constants::SEGMENTS)
			c1_hash = @s
			c2_hash = other_shape.s
			c3_hash = result.s
		elsif (c==Constants::POINTS)
			c1_hash = @p
			c2_hash = other_shape.p  
			c3_hash = result.p
		end

		c2_hash.each_key { |layer_name|
		
			flag = true
			#Initialization
			
			c1 = c1_hash[layer_name]
			c2 = c2_hash[layer_name]
			c3 = c3_hash[layer_name]
			
			#NOTE: if c2 is empty, then the subshape relation DOES hold
			
			if (!c1) 
				if (c == Constants::SEGMENTS)
					if self.kind_of? CurrentLabelledShape
						c1 = BalancedBinaryTree.new
						c1_hash[layer_name] = c1
					else
						c1 = LinearLinkedList.new
						c1_hash[layer_name] = c1
					end
				else
					c1 = LinearLinkedList.new
					c1_hash[layer_name] = c1
				end
			end
			if (!c2) 
				if (c == Constants::SEGMENTS)
					if self.kind_of? CurrentLabelledShape
						c2 = BalancedBinaryTree.new
						c2_hash[layer_name] = c2
					else
						c2 = LinearLinkedList.new
						c2_hash[layer_name] = c2
					end
				else
					c2 = LinearLinkedList.new
					c2_hash[layer_name] = c2
				end
			end
			c2.reset_iterator
			while ((v = c2.get_next) && flag)
				if (!(v.key == Label.new(Constants::INTERSECTION_LABEL))) #we do not need to compare intersection points
					u = c1.get_node(v.key)
					if u #Matching keys found. Perform the appropiate action
						if (op_rel_type == Constants::UNION) || (op_rel_type == Constants::INTERSECTION) || (op_rel_type == Constants::DIFFERENCE)
							if (op_rel_type == Constants::UNION) || (op_rel_type == Constants::DIFFERENCE)
								op_rel(u.list, v.list, op_rel_type, c)
							else
								result_list = op_rel(u.list, v.list, op_rel_type, c)
								node = LinearLinkedListNode.new(v.key.clone, result_list, nil)
								c3.insert_node node
							end
							if u.list.empty?
								c1.delete_node(u.key) 
								flag =  !c1.empty? #CHECK: es esto equivalente al alg. de krishnamurti??
							end
						elsif (op_rel_type == Constants::SUBSHAPE) || (op_rel_type == Constants::EQUAL)
							flag = op_rel(u.list, v.list, op_rel_type, c)
						end
					else #There is no node with the same key value as v
						if op_rel_type == Constants::UNION
							if c1.kind_of? BalancedBinaryTree
								new_node = BalancedBinaryTreeNode.new(0,nil,nil,v.key.clone, v.list.clone)
							else
								new_node = LinearLinkedListNode.new(v.key.clone, v.list.clone, nil)
							end
							c1.insert_node(new_node)					
						elsif (op_rel_type == Constants::SUBSHAPE) || (op_rel_type == Constants::EQUAL)
							flag = false
						end
					end
				end
			end
			
			if (c == Constants::SEGMENTS)
				#puts "#{layer_name}: #{flag}"
			end

			global_flag = (global_flag and flag)
		}
		
		#Finishing touches
		if ((op_rel_type == Constants::SUBSHAPE) || (op_rel_type == Constants::EQUAL))
			return global_flag
		elsif (op_rel_type == Constants::INTERSECTION)
			if (c == Constants::SEGMENTS)
				result.recompute_intersection_points
			end
			return result
		elsif (c == Constants::SEGMENTS)
			self.recompute_intersection_points
		end
	end
	
	
	def hausdorff_subshape(other_shape, max_distance, factor) 
    
	  result = false
    designList = []
    h_distance = 0.0
    h_distance_map = Hash.new(nil)
		@p.each_key { |layer_name|  
      @p[layer_name].reset_iterator()
      distance = 0.0
      h_distance = 0.0
      hx = 0
      hy = 0
      #designPointsList = LinearLinkedList.new
      patternList = []
      designList = []
      cont = 0
   
      while (pattern_node = @p[layer_name].get_next) 
        #other_shape[layer_name].reset_iterator         
        design_node = other_shape.p[layer_name].get_node(pattern_node.key)
        
        # pattern_list -> actual pattern node list
        # design_list -> actual design node list
        pattern_list = pattern_node.list
        design_list = design_node.list
        
        # ppoint -> pattern point
        # dpoint -> design point
        pattern_list.reset_iterator
        while (ppoint = pattern_list.get_next)
          design_list.reset_iterator
          dpoint = design_list.get_next
          distance = ppoint.key.point.distance(dpoint.key.point)
          d = dpoint.clone
          p = ppoint.clone
          while (dpoint = design_list.get_next)
            if (ppoint.key.point.distance(dpoint.key.point)<distance)
              distance = ppoint.key.point.distance(dpoint.key.point)
              d = dpoint.clone
            end 
          end
          
          patternList[cont] = p
          designList[cont] = d
          cont = cont+1
          
          if (h_distance < distance)
            h_distance = distance
            hx = (p.key.point.x - d.key.point.x).abs
            hy = (p.key.point.y - d.key.point.y).abs
          end
        end 
      end 
      
      h_distance_map[layer_name] = h_distance
      
      #deleting duplicated points
      cont2 = 0
      while (cont2<designList.size())
        cont3 = cont2+1
        while ((cont3>cont2) and (cont3<designList.size()))
          if  designList[cont2].key == designList[cont3].key
            designList.delete_at(cont3)
          end             
          cont3 = cont3+1
        end
        cont2 = cont2+1
      end

      
      if (hx <= (max_distance[0]*factor[0]) and hy <= (max_distance[1]*factor[1]))
          if ((patternList.size() == designList.size()) and (patternList.size()>=3))
            cont2 = 0
            result = true
            while (cont2<patternList.size())
              cont3 = cont2+1
              while ((cont3>cont2) and (cont3<patternList.size()))
                @s[layer_name].reset_iterator()
                connectedPattern = self.connected?(patternList[cont2].key.point, patternList[cont3].key.point, layer_name)
                
                other_shape.s[layer_name].reset_iterator
                connectedDesign = other_shape.connected?(designList[cont2].key.point, designList[cont3].key.point, layer_name)
                
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
            return [false, h_distance_map]
            #return [false, designList]
          end
      else
         return [false, h_distance_map]
         #return [false, designList]
      end
    }
    return [result, h_distance_map]
    #return [result, designList]
	end
	
	def connected?(point1, point2, layer_name, print = false)
     found = false
     newSegment = Segment.new(OrderedPoint.new(point1),OrderedPoint.new(point2))
     if(node = self.s[layer_name].get_node(newSegment.line_descriptor))
       if print
         puts "Descriptor encontrado: #{node.key.sine}, #{node.key.intercept}"
       end
       list = node.list
       list.reset_iterator
       while((seg = list.get_next) and !found)
          if (seg.key.tail <= newSegment.tail)
            if (newSegment.head <= seg.key.head)
              found = true
            end
          end
#          if (seg.key.overlap?(newSegment))
#            found = true
#          end
       end
     end
     return found
   end
	
   
   def atLast3Points
     @p.each_key { |layer_name|  
           @p[layer_name].reset_iterator()
           cont = 0
           
           while (pattern_node = @p[layer_name].get_next) 
             pattern_list = pattern_node.list
             cont = cont + pattern_list.size
           end
           if cont<3
             return false 
           end
      }
      return true
   end
   
   
	#Recompute the intersection points of the shape
	def recompute_intersection_points(testing = false)
		
		@s.each_key { |layer_name|
			#First, we remove the old intersection points, if any
			@p[layer_name].delete_node(Label.new(Constants::INTERSECTION_LABEL))
	    
			s_array = @s[layer_name].to_array
	    
			#Second, we obtain the nodes of the maximal lines in order
			@s[layer_name].reset_iterator
			i = 0
			while (node = @s[layer_name].get_next)
				j = i
				#Obtain next_node without breaking the iterator
				while (j < s_array.size)
					#puts "Comparing #{i} line with #{j} line"
					next_node = s_array[j]
					if !(next_node.key.sine == node.key.sine) #If line descriptors are not parallel...
						current_segment_node = node.list.first
						found1 = false
						#While there are segments in node and the intersection is not found
						while (current_segment_node && !found1)
							current_segment = current_segment_node.key
							segment_node = next_node.list.first
							found2 = false
							#While there are segments in next_node and the intersection is not found
							while (segment_node && !found1 && !found2)
								segment = segment_node.key
								#Calculate ua
								#Numerator
								uan = (((segment.head.x - segment.tail.x)*(current_segment.tail.y - segment.tail.y)) - ((segment.head.y - segment.tail.y)*(current_segment.tail.x - segment.tail.x)))
								#Denominator
								uad = (((segment.head.y - segment.tail.y)*(current_segment.head.x - current_segment.tail.x)) - ((segment.head.x - segment.tail.x)*(current_segment.head.y - current_segment.tail.y)))
								#The denominator is not going to be zero since the studied lines are not parallel neither coincident
								ua = uan/uad
								
								#Calculate ub
								#Numerator
								ubn = (((current_segment.head.x - current_segment.tail.x)*(current_segment.tail.y - segment.tail.y)) - ((current_segment.head.y - current_segment.tail.y)*(current_segment.tail.x - segment.tail.x)))
								#Denominator
								ubd = uad
								#The denominator is not going to be zero since the studied lines are not parallel neither coincident
								ub = ubn/ubd
								#if testing
									#puts "ua: #{ua}, ub: #{ub}"
								#end
								if (ua > (1 + Constants::EPSILON)) #The current_segment does not intersect with the next_node line descriptor. Maybe some higher segment does intersect
									found2 = true
								elsif (ua < (0 - Constants::EPSILON))
									found1 = true #We can stop searching this pair of lines, since there is not any pair of segments that intersect
								elsif ((((0 - Constants::EPSILON) <= ub) && (ub <= (1 + Constants::EPSILON))) && (((0 - Constants::EPSILON) <= ua) && (ua <= (1 + Constants::EPSILON)))) #We have found the intersection
									found1 = true #We can stop searching this pair of lines
									label = Label.new(Constants::INTERSECTION_LABEL)
									point_list = LinearLinkedList.new
									if @p[layer_name].kind_of? LinearLinkedList
										label_node = LinearLinkedListNode.new(label, point_list, nil)
									else
										label_node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, label, point_list)
									end
									
									inserted_node = @p[layer_name].insert_node(label_node) #Insert the node corresponding to the label of the point
								
									#Calculate the point
									x = current_segment.tail.x + (ua * (current_segment.head.x - current_segment.tail.x))
									y = current_segment.tail.y + (ua * (current_segment.head.y - current_segment.tail.y))
									point = Point.new(x,y,0)
									point_node = LinearLinkedListNode.new(OrderedPoint.new(point), nil, nil)
									inserted_node.list.insert_node(point_node) #Insert the point node
									#puts "point inserted: #{point.x}, #{point.y}"
								end
								segment_node = segment_node._next
							end
							current_segment_node = current_segment_node._next
						end
					end
					j+=1
				end
				i+=1
			end
		}
	end
	
	#list1: a LinearLinkedList of Segments or Points
	#list2: a LinearLinkedList of Segments or Points
	#op_rel_type:: the operation or relation to perform. One of the following: Constants::UNION, Constants::INTERSECTION, Constants::DIFFERENCE,
	#Constants::SUBSHAPE, Constants::EQUAL
	#c:: Constants::SEGMENT if segments are affected, Constants::POINTS if points are affected.
	#
	#returns::true iff the specified relation (subshape or equal) holds (or false if it does not hold). In case it is an union or difference operation,
	#it just overwrites list1  with the resulting list of the operation. In case it is an intersection, it returns a new segment list.
	def op_rel(list1, list2, op_rel_type, c)
		if (c == Constants::SEGMENTS)
			if (op_rel_type == Constants::UNION)
				#Step 0
				working_line_node = list2.first
				linej_node = list1.first
				if !list1.empty?
					#Step 1
					step1_union(list1, list2, working_line_node, linej_node)
				else
					#Step 8
					#There may still be some unexamined lines in line2. Copy all the unexamined lines in line2 in their order, and attach them
					#to the end of list list1
					step8_union(list1, list2, working_line_node, linej_node)
				end
			elsif (op_rel_type == Constants::DIFFERENCE)
				#Step 0
				if !list1.empty?
					#step 1
					working_line_node = list2.first
					linej_node = list1.first
					step1_difference(list1, list2, working_line_node, linej_node)
				end
			elsif (op_rel_type == Constants::INTERSECTION)
				if !list1.empty?
					#Step 0
					working_line_node = list2.first
					linej_node = list1.first
					list3 = LinearLinkedList.new
					#step 1
					step1_intersection(list1, list2, list3, working_line, linej)
				end
			elsif (op_rel_type == Constants::SUBSHAPE)
				#step 0
				flag = true
				if !list1.empty?
					#step 1
					working_line_node = list2.first
					linej_node = list1.first
					flag = step1_subshape(flag, list1, list2, working_line_node, linej_node)
				else
					flag = (list2.empty?)
				end
			elsif (op_rel_type == Constants::EQUAL)
				flag = (list1 == list2)
			end
		elsif (c == Constants::POINTS)
			if (op_rel_type == Constants::UNION)
				list2.reset_iterator
				while n = list2.get_next
					point = n.key
					list1.insert_node(LinearLinkedListNode.new(point.clone, nil, nil))
				end
			elsif (op_rel_type == Constants::DIFFERENCE)
				list2.reset_iterator
				while n = list2.get_next
					point = n.key
					list1.delete_node(point)
				end				
			elsif (op_rel_type == Constants::INTERSECTION)
				list3 = LinearLinkedList.new
				list2.reset_iterator
				while n = list2.get_next
					point = n.key
					if list1.get_node(point)
						list3.insert_node(LinearLinkedListNode.new(point.clone, nil, nil))
					end
				end
			elsif (op_rel_type == Constants::SUBSHAPE)
				flag = true
				list2.reset_iterator
				while (flag && n = list2.get_next)
					point = n.key
					flag = list1.get_node(point)
					if !flag
						flag = false
					else
						flag = true
					end
				end
			elsif (op_rel_type == Constants::EQUAL)
				flag = (list1 == list2)
			end
		end
		
		if (op_rel_type == Constants::INTERSECTION)
			return list3
		elsif (op_rel_type == Constants::SUBSHAPE) || (op_rel_type == Constants::EQUAL)
			return flag
		end
	end
	
	#First step of the union algorithm of Krishnamurti
	def step1_union(list1, list2, working_line_node, linej_node)
		if (linej_node.key.tail <= working_line_node.key.head) 
			#Step 3
			if (working_line_node.key.tail <= linej_node.key.head)
				#Step 5
				if (working_line_node.key.tail < linej_node.key.tail)
					linej_node.key.tail = working_line_node.key.tail.clone
				else
					working_line_node.key.tail = linej_node.key.tail.clone
				end
				#Step 6
				if (linej_node.key.head >= working_line_node.key.head) 
					#GOTO step 2
					step2_union(list1, list2, working_line_node, linej_node)
				else
					list1.delete_node(linej_node.key)
					#Step 4
					step4_union(list1, list2, working_line_node, linej_node)
				end
				
			else
				#Step 4
				step4_union(list1, list2, working_line_node, linej_node)
			end
		else #the working line shares no common line with any line line(k>1) in list1, and working_line < linej
			#insert working_line into list1 as the maximal line immediately preceding linej in the list
			list1.insert_node(LinearLinkedListNode.new(working_line_node.key.clone, nil, nil))
			#Step 2
			step2_union(list1, list2, working_line_node, linej_node)
		end
	end
	
	#Second step of the union algorithm of Krishnamurti
	def step2_union(list1, list2, working_line_node, linej_node)
		if (working_line_node._next)
			working_line_node = working_line_node._next
			#GOTO step1
			step1_union(list1, list2, working_line_node, linej_node)
		else
			#Step 9
			return
		end
	end 
	
	#Fourth step of the union algorithm of Krishnamurti
	def step4_union(list1, list2, working_line_node, linej_node)
		if (linej_node._next)
			linej_node = linej_node._next
			#GOTO step1
			step1_union(list1, list2, working_line_node, linej_node)
		else
			list1.insert_node(LinearLinkedListNode.new(working_line_node.key.clone, nil, nil))
			#GOTO Step 8
			step8_union(list1, list2, working_line_node, linej_node)
		end
	end
	
	#Eighth step of the union algorithm of Krishnamurti
	def step8_union(list1, list2, working_line_node, linej_node)
		while (working_line_node)
			list1.insert_node(LinearLinkedListNode.new(working_line_node.key.clone, nil, nil))
			working_line_node = working_line_node._next
		end
	end

	#First step of the difference algorithm of Krishnamurti
	def step1_difference(list1, list2, working_line_node, linej_node)
		if (linej_node.key.tail < working_line_node.key.head)
			#step 3
			if (working_line_node.key.tail < linej_node.key.head)
				#step 5
				lineA = Segment.new(linej_node.key.tail, working_line_node.key.tail)
				lineB = Segment.new(working_line_node.key.head, linej_node.key.head)
				if (linej_node.key.tail < working_line_node.key.tail) && (linej_node.key.head <= working_line_node.key.head)
					linej_node.key = lineA.clone
					step4_difference(list1, list2, working_line_node, linej_node)
				elsif (working_line_node.key.tail <= linej_node.key.tail) && (working_line_node.key.head < linej_node.key.head)
					linej_node.key = lineB.clone
					step2_difference(list1, list2, working_line_node, linej_node)
				elsif (linej_node.key.tail < working_line_node.key.tail) && (working_line_node.key.head < linej_node.key.head)
					linej_node.key = lineB.clone
					list1.insert_node(LinearLinkedListNode.new(lineA.clone, nil, nil))
					step2_difference(list1, list2, working_line_node, linej_node)
				elsif (working_line_node.key.tail <= linej_node.key.tail) && (linej_node.key.head <= working_line_node.key.head)
					list1.delete_node(linej_node.key)
					step4_difference(list1, list2, working_line_node, linej_node)
				end
			else
				#step 4
				step4_difference(list1, list2, working_line_node, linej_node)
			end
		else
			#step 2
			step2_difference(list1, list2, working_line_node, linej_node)
		end
	end
	
	#Second step of the difference algorithm of Krishnamurti
	def step2_difference(list1, list2, working_line_node, linej_node)
		if (working_line_node._next)
			working_line_node = working_line_node._next
			step1_difference(list1, list2, working_line_node, linej_node)
		else
			return
		end
	end
	
	#Fourth step of the difference algorithm of Krishnamurti
	def step4_difference(list1, list2, working_line_node, linej_node)
		if (linej_node._next)
			linej_node = linej_node._next
			step1_difference(list1, list2, working_line_node, linej_node)
		else
			return
		end
	end
	
	#First step of the intersection algorithm of Krishnamurti
	def step1_intersection(list1, list2, list3, working_line_node, linej_node)
		if (linej_node.key.tail < working_line_node.key.head)
			#step 3
			if (working_line_node.key.tail < linej_node.key.head)
				#step 5
				#step 5.1
				if (linej_node.key.tail < working_line_node.key.tail)
					new_tail = working_line_node.key.tail
				else
					new_tail = linej_node.key.tail
				end
				if (working_line_node.key.head < linej_node.key.head) || (linej_node.key.head == working_line_node.key.head)
					#step 5.2
					new_head = working_line_node.key.head
					segmentk = Segment.new(new_tail, new_head)
					list3.insert_node(LinearLinkedListNode.new(segmentk, nil, nil))
					step2_intersection(list1, list2, list3, working_line_node, linej_node)
				else
					#step 5.3
					new_head = linej_node.key.head
					segmentk = Segment.new(new_tail, new_head)
					list3.insert_node(LinearLinkedListNode.new(segmentk, nil, nil))
					step4_intersection(list1, list2, list3, working_line_node, linej_node)
				end
			else
				#step 4
				step4_intersection(list1, list2, list3, working_line_node, linej_node)
			end
		else
			#step 2
			step2_intersection(list1, list2, list3, working_line_node, linej_node)
		end
	end
	
	#Second step of the intersection algorithm of Krishnamurti
	def step2_intersection(list1, list2, list3, working_line_node, linej_node)
		if (working_line_node._next)
			working_line_node = working_line_node._next
			step1_intersection(list1, list2, list3, working_line_node, linej_node)
		end
	end
	
	#Fourth step of the intersection algorithm of Krishnamurti
	def step4_intersection(list1, list2, list3, working_line_node, linej_node)
		if (linej_node._next)
			linej_node = linej_node._next
			step1_intersection(list1, list2, list3, working_line, linej)
		end
	end
	
	#First step of the subshape algorithm of Krishnamurti
	def step1_subshape(flag, list1, list2, working_line_node, linej_node)
		if (working_line_node.key.tail < linej_node.key.head)
			#step3
			if (linej_node.key.tail < working_line_node.key.head)
				#step4
				if ((working_line_node.key.tail >= linej_node.key.tail) && (working_line_node.key.head <= linej_node.key.head))
					#step 5
					if (working_line_node._next)
						working_line_node = working_line_node._next
						flag = step1_subshape(flag, list1, list2, working_line_node, linej_node)
					end
				else
					flag = false
				end
			else
				flag = false
			end
		else
			#step2
			if (linej_node._next)
				linej_node = linej_node._next
				flag = step1_subshape(flag, list1, list2, working_line_node, linej_node)
			else
				flag = false
			end
		end
		return flag
	end
	
	#path:: path to save the shape in
	#
	#Saves the shape in the specified path
	def save(path)
    
		if Shade.using_sketchup
			extension = ShadeUtils.get_extension(path)

			if extension == "skp"
				rules = Shade.project.execution.grammar.rules
				rules.each {|rule|
					rule.erase
				}
				Sketchup.active_model.entities
				Shade.project.execution.current_shape.erase

				Sketchup.active_model.active_entities.erase_entities(Sketchup.active_model.active_entities.to_a) 

				self.paint

				path = path.tr("\\","/") 
				Sketchup.active_model.save(path)

				ShadeUtils.prepare_canvas(false)
				rules.each {|rule|
					rule.repaint
				}
				Shade.project.execution.current_shape.paint
			elsif extension == "txt"
				File.open(path, 'w') do |f|
					Sketchup.active_model.layers.each { |layer|
						f.write("LAYER: #{layer.name}\n")
						@s[layer.name].reset_iterator
						while s_node = @s[layer.name].get_next
							s_node.list.reset_iterator
							while s = s_node.list.get_next
								f.write("S: #{s.key.tail.x.to_f.to_m} #{s.key.tail.y.to_f.to_m} #{s.key.head.x.to_f.to_m} #{s.key.head.y.to_f.to_m}\n")
							end
						end
						@p[layer.name].reset_iterator
						while l_node = @p[layer.name].get_next
							if !(l_node.key.value == Constants::INTERSECTION_LABEL)
								l_node.list.reset_iterator
								while l = l_node.list.get_next
									f.write("L: #{l.key.x.to_f.to_m} #{l.key.y.to_f.to_m} #{l_node.key.value}\n")
								end
							end
						end
					}
				end
			end
		else
			extension = ShadeUtils.get_extension(path)
			if extension == "txt"
				File.open(path, 'w') do |f|
					@s.each_key { |layer_name|
						f.write("LAYER: #{layer_name}\n")
						@s[layer_name].reset_iterator
						while s_node = @s[layer_name].get_next
							s_node.list.reset_iterator
							while s = s_node.list.get_next
								f.write("S: #{s.key.tail.x.to_f} #{s.key.tail.y.to_f} #{s.key.head.x.to_f} #{s.key.head.y.to_f}\n")
							end
						end
						@p[layer_name].reset_iterator
						while l_node = @p[layer_name].get_next
							if !(l_node.key.value == Constants::INTERSECTION_LABEL)
								l_node.list.reset_iterator
								while l = l_node.list.get_next
									f.write("L: #{l.key.x.to_f} #{l.key.y.to_f} #{l_node.key.value}\n")
								end
							end
						end
					}
				end
			end
		end

	end
	
	#path:: path to load the shape from
	#
	#Loads the shape in the specified path
	def load(path)
    
		if Shade.using_sketchup
			extension = ShadeUtils.get_extension(path)

			if extension == "skp"

				#We remove everything
				rules = Shade.project.execution.grammar.rules
				rules.each {|rule|
					rule.erase
				}
				Shade.project.execution.current_shape.erase
				Sketchup.active_model.active_entities.erase_entities(Sketchup.active_model.active_entities.to_a) 

				path = path.tr("\\","/") 
				Sketchup.active_model.save("trash.skp")
				Sketchup.open_file(path) #A group is loaded
				File.delete("trash.skp")
				entities = Sketchup.active_model.entities[0].entities

				edges = Array.new
				points_and_materials = Array.new

				entities.each { |e|
					if e.kind_of? Sketchup::Edge
						edges.push e
					elsif e.kind_of? Sketchup::Group
						e.entities.each { |ge| 
							if ge.kind_of? Sketchup::ConstructionPoint
								points_and_materials.push [ge.position, e.material]
							end
						}

					end
				}

				self.refresh_from_info(edges, points_and_materials)

				Sketchup.active_model.active_entities.erase_entities(Sketchup.active_model.active_entities.to_a) 

				#We repaint everything
				ShadeUtils.prepare_canvas(false)
				rules.each {|rule|
					rule.repaint
				}
				Shade.project.execution.current_shape.paint
			elsif extension == "txt"
				File.open(path, 'r') do |f|
					layer_found = false
					while line = f.gets
						line_a1 = line.split(":")
						if line_a1[0].strip == "S" #Segment
							if !layer_found
								if self.kind_of? CurrentLabelledShape
									@s["Layer0"] = BalancedBinaryTree.new
								else
									@s["Layer0"] = LinearLinkedList.new
								end
								@p["Layer0"] = LinearLinkedList.new
								layer_name = "Layer0"
								layer_found = true
							end
							line_a = line_a1[1].split
							segment = Segment.new(OrderedPoint.new(Geom::Point3d.new(line_a[0].to_f.m, line_a[1].to_f.m, 0)), OrderedPoint.new(Geom::Point3d.new(line_a[2].to_f.m, line_a[3].to_f.m, 0)))
							segment_list = LinearLinkedList.new

							if @s[layer_name].kind_of? LinearLinkedList
								node = LinearLinkedListNode.new(segment.line_descriptor, segment_list, nil)
							else
								node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, segment.line_descriptor, segment_list)
							end

							inserted_node = @s[layer_name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment

							#We create an auxiliar list filled with the new segment to add, in order to make the union and obtain the maximal lines
							new_segment_list = LinearLinkedList.new
							segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
							new_segment_list.insert_node(segment_node)

							op_rel(inserted_node.list,  new_segment_list, Constants::UNION, Constants::SEGMENTS)

						elsif line_a1[0].strip == "L" #Label
							if !layer_found
								if self.kind_of? CurrentLabelledShape
									@s["Layer0"] = BalancedBinaryTree.new
								else
									@s["Layer0"] = LinearLinkedList.new
								end
								@p["Layer0"] = LinearLinkedList.new
								layer_name = "Layer0"
								layer_found = true
							end
							line_a = line_a1[1].split
							color = line_a[2]
							raise LoadError, "The color name: #{color} of shape in file #{path} is not recognized" unless Constants::RECOGNIZED_COLORS.include? color

							label = Label.new(line_a[2])
							point = OrderedPoint.new(Geom::Point3d.new(line_a[0].to_f.m, line_a[1].to_f.m, 0))
							point_list = LinearLinkedList.new

							if @p[layer_name].kind_of? LinearLinkedList
								node = LinearLinkedListNode.new(label, point_list, nil)
							else
								node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, label, point_list)
							end

							inserted_node = @p[layer_name].insert_node(node) #Insert the node corresponding to the label of the point
							
							point_node = LinearLinkedListNode.new(point, nil, nil)
							inserted_node.list.insert_node(point_node) #Insert the point node
						elsif line_a1[0].strip == "LAYER" #Layer
							layer_name = line_a1[1].strip
							if self.kind_of? CurrentLabelledShape
								@s[layer_name] = BalancedBinaryTree.new
							else
								@s[layer_name] = LinearLinkedList.new
							end
							@p[layer_name] = LinearLinkedList.new
							layer_found = true
						end
					end
				end
				recompute_intersection_points
				#paint
			end
		else
			extension = ShadeUtils.get_extension(path)
		
			if extension == "txt"
				layer_name = "Layer0"
				File.open(path, 'r') do |f|
					layer_found = false
					while line = f.gets
						line_a1 = line.split(":")
						if line_a1[0].strip == "S" #Segment
							if !layer_found
								if self.kind_of? CurrentLabelledShape
									@s["Layer0"] = BalancedBinaryTree.new
								else
									@s["Layer0"] = LinearLinkedList.new
								end
								@p["Layer0"] = LinearLinkedList.new
								layer_name = "Layer0"
								layer_found = true
							end
							line_a = line_a1[1].split
							segment = Segment.new(OrderedPoint.new(Point.new(line_a[0].to_f, line_a[1].to_f, 0)), OrderedPoint.new(Point.new(line_a[2].to_f, line_a[3].to_f, 0)))
							segment_list = LinearLinkedList.new

							if @s[layer_name].kind_of? LinearLinkedList
								node = LinearLinkedListNode.new(segment.line_descriptor, segment_list, nil)
							else
								node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, segment.line_descriptor, segment_list)
							end

							inserted_node = @s[layer_name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment

							#We create an auxiliar list filled with the new segment to add, in order to make the union and obtain the maximal lines
							new_segment_list = LinearLinkedList.new
							segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
							new_segment_list.insert_node(segment_node)

							op_rel(inserted_node.list,  new_segment_list, Constants::UNION, Constants::SEGMENTS)

						elsif line_a1[0].strip == "L" #Label
							if !layer_found
								if self.kind_of? CurrentLabelledShape
									@s["Layer0"] = BalancedBinaryTree.new
								else
									@s["Layer0"] = LinearLinkedList.new
								end
								@p["Layer0"] = LinearLinkedList.new
								layer_name = "Layer0"
								layer_found = true
							end
							line_a = line_a1[1].split
							color = line_a[2]
							raise LoadError, "The color name: #{color} of shape in file #{path} is not recognized" unless Constants::RECOGNIZED_COLORS.include? color
							label = Label.new(line_a[2])
							point = OrderedPoint.new(Point.new(line_a[0].to_f, line_a[1].to_f, 0))
							point_list = LinearLinkedList.new

							if @p[layer_name].kind_of? LinearLinkedList
								node = LinearLinkedListNode.new(label, point_list, nil)
							else
								node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, label, point_list)
							end

							inserted_node = @p[layer_name].insert_node(node) #Insert the node corresponding to the label of the point
							
							point_node = LinearLinkedListNode.new(point, nil, nil)
							inserted_node.list.insert_node(point_node) #Insert the point node
						elsif line_a1[0].strip == "LAYER" #Layer
							layer_name = line_a1[1].strip
							if self.kind_of? CurrentLabelledShape
								@s[layer_name] = BalancedBinaryTree.new
							else
								@s[layer_name] = LinearLinkedList.new
							end
							@p[layer_name] = LinearLinkedList.new
							layer_found = true
						end
					end
				end
				recompute_intersection_points
				#paint
			end
		end

	end

	#Paints the view of the shape
	def paint()
		if Shade.using_sketchup
			entities = Sketchup.active_model.entities
			
			layers = Sketchup.active_model.layers
					
			@s.each_key { |layer_name|
				@s[layer.name].reset_iterator
				while (node = @s[layer.name].get_next)
					node.list.reset_iterator
					while (segment_node = node.list.get_next)
						entities.add_edges segment_node.key.tail.point, segment_node.key.head.point
					end
				end
			}
				
			@p.each_key { |layer_name|
				@p[layer.name].reset_iterator
				while (node = @p[layer.name].get_next)
					label = node.key
					node.list.reset_iterator
					while (labelled_point_node = node.list.get_next)	
						if !(label.value==Constants::INTERSECTION_LABEL) #The label is a coloured circle
							label_group = entities.add_group
							
							# Add circle
							edges = label_group.entities.add_circle labelled_point_node.key.point, Constants::LABEL_VECTOR, Shade.label_radius
							#Add construction point in order to locate the center later
							label_group.entities.add_cpoint labelled_point_node.key.point
							#Add face
							face = label_group.entities.add_face edges					
							#Give color to the face
							label_group.material = label.value
						end
					end
				end
				
			}
		end
	end
	
	#returns:: the hash code for this labelled shape
	def hash
		return [@s["Layer0"].hash, @p["Layer0"].hash].hash
	end
	

	
	
end
#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a RuleLabelledShape, that is, a shape which is part of a rule
class RuleLabelledShape < LabelledShape
		
	#Hash that stores, according to the layers, the SU objects that groups the units
	attr_accessor :group
	#Hash that stores, according to the layers, the transformations applied to the shape
	attr_accessor :shape_transformation 
	#The layout transformations (that is, to comply with the canvas arrangement) applied to the shape (to all its layers)
	attr_accessor :layout_transformation
	#Hash that stores, according to the layers, the observers which will listen to changes in the SU objects
	attr_accessor :observer
	
	#ID of the host rule
	attr_accessor :host_rule_id
	#Part of the host rule (Right, Left or Additive)
	attr_accessor :host_rule_part
	
	#True iff the shape representation has been changed
	attr_accessor :changed
	#True iff the user has erased the shape
	attr_accessor :badly_erased
	#True iff the partner shape (the Right if it is a Left shape, and viceversa), has been changed
	attr_accessor :partner_changed
	#Used as a trick for avoid SU bugs 
	attr_accessor :avoid_bug
	
	#ID of the shape
	attr_reader :shape_id
	
	#shape_id:: identification of the shape
	#edges:: list of edges
	#points_and_materials:: list of pairs (point, material)
	#host_rule_id:: id of the host rule, in case the shape is a rule shape
	#host_rule_part:: part of the host rule, in case the shape is a rule shape
	#is_visual:: true iff the shape is to be seen
	#
	#Initializes the rule shape, putting the edges and points into layer 0 
	def initialize(edges, points_and_materials, host_rule_id, host_rule_part)
		@shape_id = -1
		@group = Hash.new(nil)
		
		if Shade.using_sketchup
			@shape_transformation = Hash.new(Geom::Transformation.new)
			@layout_transformation = Geom::Transformation.new
			
			@observer = Hash.new(nil)
			
			@changed = true
			@badly_erased = false
			@partner_changed = false
			@avoid_bug = false
			
			@host_rule_id = host_rule_id
			@host_rule_part = host_rule_part
			
			@shape_id = shape_id
			
			@s = Hash.new(nil)
			Sketchup.active_model.layers.each { |layer|
				@s[layer.name] = LinearLinkedList.new
			}
			@p = Hash.new(nil)
			Sketchup.active_model.layers.each { |layer|
				@p[layer.name] = LinearLinkedList.new
			}
		else
			@shape_id = shape_id
		
			@s = Hash.new(nil)
			@s["Layer0"] = LinearLinkedList.new
			@p = Hash.new(nil)
			@p["Layer0"] = LinearLinkedList.new
		end
		
		super(edges, points_and_materials)
		
	end
	
	#path:: path to save the shape in
	#
	#Saves the shape in the specified path
	def save(path)
		if Shade.using_sketchup
			extension = ShadeUtils.get_extension(path)

			if extension == "skp"
				rules = Shade.project.execution.grammar.rules
				rules.each {|rule|
					rule.erase
				}
				Sketchup.active_model.entities
				Shade.project.execution.current_shape.erase
				
				Sketchup.active_model.active_entities.erase_entities(Sketchup.active_model.active_entities.to_a) 
				
				layout_t = @layout_transformation
				@layout_transformation = Geom::Transformation.new
				self.paint
				@layout_transformation = layout_t
				
				path = path.tr("\\","/") 
				Sketchup.active_model.save(path)
				
				ShadeUtils.prepare_canvas(false)
				rules.each {|rule|
					rule.repaint
				}
				Shade.project.execution.current_shape.paint
			elsif extension == "txt"
				File.open(path, 'w') do |f|
					Sketchup.active_model.layers.each {|layer|
						f.write("LAYER: #{layer.name}\n")
						if @s[layer.name]
							@s[layer.name].reset_iterator
							while s_node = @s[layer.name].get_next
								s_node.list.reset_iterator
								while s = s_node.list.get_next
								tail_x = ((s.key.tail.x.to_f.to_m * 100).round.to_f / 100)
								tail_y = ((s.key.tail.y.to_f.to_m * 100).round.to_f / 100)
								head_x = ((s.key.head.x.to_f.to_m* 100).round.to_f / 100)
								head_y = ((s.key.head.y.to_f.to_m * 100).round.to_f / 100)
									f.write("S: #{tail_x} #{tail_y} #{head_x} #{head_y}\n")
								end
							end
						end
						if @p[layer.name]
							@p[layer.name].reset_iterator
							while l_node = @p[layer.name].get_next
								if !(l_node.key.value == Constants::INTERSECTION_LABEL)
									l_node.list.reset_iterator
									while l = l_node.list.get_next
										key_x = ((l.key.x.to_f.to_m * 100).round.to_f / 100)
										key_y = ((l.key.y.to_f.to_m * 100).round.to_f / 100)
										f.write("L: #{key_x} #{key_y} #{l_node.key.value}\n")
									end
								end
							end
						end
					}
				end
			end
		else
			extension = ShadeUtils.get_extension(path)

			if extension == "txt"
				File.open(path, 'w') do |f|
					@s.each_key { |layer_name|
						f.write("LAYER: #{layer_name}\n")
						@s[layer_name].reset_iterator
						while s_node = @s[layer_name].get_next
							s_node.list.reset_iterator
							while s = s_node.list.get_next
								f.write("S: #{s.key.tail.x.to_f} #{s.key.tail.y.to_f} #{s.key.head.x.to_f} #{s.key.head.y.to_f}\n")
							end
						end
						@p[layer_name].reset_iterator
						while l_node = @p[layer_name].get_next
							if !(l_node.key.value == Constants::INTERSECTION_LABEL)
								l_node.list.reset_iterator
								while l = l_node.list.get_next
									f.write("L: #{l.key.x.to_f} #{l.key.y.to_f} #{l_node.key.value}\n")
								end
							end
						end
					}
				end
			end
		end

		
	end
	
	#path:: path to load the shape from
	#
	#Loads the shape in the specified path
	def load(path)

		if Shade.using_sketchup
			extension = ShadeUtils.get_extension(path)

			if extension == "skp"
				
				#We remove everything
				rules = Shade.project.execution.grammar.rules
				rules.each {|rule|
					rule.erase
				}
				Shade.project.execution.current_shape.erase
				Sketchup.active_model.active_entities.erase_entities(Sketchup.active_model.active_entities.to_a) 
				
				path = path.tr("\\","/") 
				Sketchup.active_model.save("trash.skp")
				Sketchup.open_file(path) #A group is loaded
				File.delete("trash.skp")
				entities = Sketchup.active_model.entities[0].entities
				
				edges = Array.new
				points_and_materials = Array.new
				
				entities.each { |e|
					if e.kind_of? Sketchup::Edge
						edges.push e
					elsif e.kind_of? Sketchup::Group
						e.entities.each { |ge| 
							if ge.kind_of? Sketchup::ConstructionPoint
								points_and_materials.push [ge.position, e.material]
							end
						}
						
					end
				}
				
				@shape_transformation = @layout_transformation.inverse * Sketchup.active_model.entities[0].transformation

				self.refresh_from_info(edges, points_and_materials)
				
				Sketchup.active_model.active_entities.erase_entities(Sketchup.active_model.active_entities.to_a) 
				
				#We repaint everything
				ShadeUtils.prepare_canvas(false)
				rules.each {|rule|
					rule.repaint
				}
				Shade.project.execution.current_shape.paint
			elsif extension == "txt"
				layer_found = false
				File.open(path, 'r') do |f|
					while line = f.gets
						line_a1 = line.split(":")
						if line_a1[0].strip == "S" #Segment
							if !layer_found
								if self.kind_of? CurrentLabelledShape
									@s["Layer0"] = BalancedBinaryTree.new
								else
									@s["Layer0"] = LinearLinkedList.new
								end
								@p["Layer0"] = LinearLinkedList.new
								layer_name = "Layer0"
								layer_found = true
							end
							line_a = line_a1[1].split
							segment = Segment.new(OrderedPoint.new(Geom::Point3d.new(line_a[0].to_f.m, line_a[1].to_f.m, 0)), OrderedPoint.new(Geom::Point3d.new(line_a[2].to_f.m, line_a[3].to_f.m, 0)))
							segment_list = LinearLinkedList.new

							if @s[layer_name].kind_of? LinearLinkedList
								node = LinearLinkedListNode.new(segment.line_descriptor, segment_list, nil)
							else
								node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, segment.line_descriptor, segment_list)
							end

							inserted_node = @s[layer_name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment

							#We create an auxiliar list filled with the new segment to add, in order to make the union and obtain the maximal lines
							new_segment_list = LinearLinkedList.new
							segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
							new_segment_list.insert_node(segment_node)

							op_rel(inserted_node.list,  new_segment_list, Constants::UNION, Constants::SEGMENTS)

						elsif line_a1[0].strip == "L" #Label
							if !layer_found
								if self.kind_of? CurrentLabelledShape
									@s["Layer0"] = BalancedBinaryTree.new
								else
									@s["Layer0"] = LinearLinkedList.new
								end
								@p["Layer0"] = LinearLinkedList.new
								layer_name = "Layer0"
								layer_found = true
							end
							line_a = line_a1[1].split
							color = line_a[2]
							raise LoadError, "The color name: #{color} of shape in file #{path} is not recognized" unless Constants::RECOGNIZED_COLORS.include? color
							label = Label.new(line_a[2])
							point = OrderedPoint.new(Geom::Point3d.new(line_a[0].to_f.m, line_a[1].to_f.m, 0))
							point_list = LinearLinkedList.new

							if @p[layer_name].kind_of? LinearLinkedList
								node = LinearLinkedListNode.new(label, point_list, nil)
							else
								node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, label, point_list)
							end

							inserted_node = @p[layer_name].insert_node(node) #Insert the node corresponding to the label of the point

							point_node = LinearLinkedListNode.new(point, nil, nil)
							inserted_node.list.insert_node(point_node) #Insert the point node
						elsif line_a1[0].strip == "LAYER"
							layer_found = true
							layer_name = line_a1[1].strip
							if self.kind_of? CurrentLabelledShape
								@s[layer_name] = BalancedBinaryTree.new
							else
								@s[layer_name] = LinearLinkedList.new
							end
							@p[layer_name] = LinearLinkedList.new
						end
					end
				end
				recompute_intersection_points
				paint
			end
		else
			extension = ShadeUtils.get_extension(path)

			if extension == "txt"
				File.open(path, 'r') do |f|
					layer_found = false
					while line = f.gets
						line_a1 = line.split(":")
						if line_a1[0].strip == "S" #Segment
							if !layer_found
								if self.kind_of? CurrentLabelledShape
									@s["Layer0"] = BalancedBinaryTree.new
								else
									@s["Layer0"] = LinearLinkedList.new
								end
								@p["Layer0"] = LinearLinkedList.new
								layer_name = "Layer0"
								layer_found = true
							end
							line_a = line_a1[1].split
							segment = Segment.new(OrderedPoint.new(Point.new(line_a[0].to_f, line_a[1].to_f, 0)), OrderedPoint.new(Point.new(line_a[2].to_f, line_a[3].to_f, 0)))
							segment_list = LinearLinkedList.new

							if @s[layer_name].kind_of? LinearLinkedList
								node = LinearLinkedListNode.new(segment.line_descriptor, segment_list, nil)
							else
								node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, segment.line_descriptor, segment_list)
							end

							inserted_node = @s[layer_name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment

							#We create an auxiliar list filled with the new segment to add, in order to make the union and obtain the maximal lines
							new_segment_list = LinearLinkedList.new
							segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
							new_segment_list.insert_node(segment_node)

							op_rel(inserted_node.list,  new_segment_list, Constants::UNION, Constants::SEGMENTS)

						elsif line_a1[0].strip == "L" #Label
							if !layer_found
								if self.kind_of? CurrentLabelledShape
									@s["Layer0"] = BalancedBinaryTree.new
								else
									@s["Layer0"] = LinearLinkedList.new
								end
								@p["Layer0"] = LinearLinkedList.new
								layer_name = "Layer0"
								layer_found = true
							end
							line_a = line_a1[1].split
							color = line_a[2]
							raise LoadError, "The color name: #{color} of shape in file #{path} is not recognized" unless Constants::RECOGNIZED_COLORS.include? color
							label = Label.new(line_a[2])
							point = OrderedPoint.new(Point.new(line_a[0].to_f, line_a[1].to_f, 0))
							point_list = LinearLinkedList.new

							if @p[layer_name].kind_of? LinearLinkedList
								node = LinearLinkedListNode.new(label, point_list, nil)
							else
								node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, label, point_list)
							end

							inserted_node = @p[layer_name].insert_node(node) #Insert the node corresponding to the label of the point

							point_node = LinearLinkedListNode.new(point, nil, nil)
							inserted_node.list.insert_node(point_node) #Insert the point node
						elsif line_a1[0].strip == "LAYER"
							layer_found = true
							layer_name = line_a1[1].strip
							if self.kind_of? CurrentLabelledShape
								@s[layer_name] = BalancedBinaryTree.new
							else
								@s[layer_name] = LinearLinkedList.new
							end
							@p[layer_name] = LinearLinkedList.new
						end
					end
				end
				recompute_intersection_points
				paint
			end
		end

		
	end

	#t:: a transformation, represented by an array of 6 positions (representing a 2x3 transformation matrix)
	#
	#Returns a new shape that is the result of transforming this shape by means of the specified transformation
	def transform(t)
		#Extract the coefficients of the transformation matrix
		ax = t[0]
		bx = t[1]
		cx = t[2]
		ay = t[3]
		by = t[4]
		cy = t[5]
		new_shape = self.clone
		@s.each_key {|layer_name|
			#First, we transform the segments
			new_s = LinearLinkedList.new
			new_shape.s[layer_name].reset_iterator
			#Second, we remove the intersection points, if any
			new_shape.p[layer_name].delete_node(Label.new(Constants::INTERSECTION_LABEL))
			while (node = new_shape.s[layer_name].get_next)
				new_line_descriptor = nil
				
				segment_list = node.list
				segment_list.reset_iterator
				
				new_segment_list = LinearLinkedList.new
				while (segment_node = segment_list.get_next)
					tail = segment_node.key.tail
					head = segment_node.key.head
					#Transform the tail
					new_tail_x = tail.x * ax + tail.y * bx + cx
					new_tail_y = tail.x * ay + tail.y * by + cy
					new_tail = Point.new(new_tail_x, new_tail_y, 0)
					#Transform the head
					new_head_x = head.x * ax + head.y * bx + cx
					new_head_y = head.x * ay + head.y * by + cy
					new_head = Point.new(new_head_x, new_head_y, 0)
					
					new_segment = Segment.new(OrderedPoint.new(new_tail), OrderedPoint.new(new_head))
					new_segment_list.insert_node(LinearLinkedListNode.new(new_segment, nil, nil))
					if !new_line_descriptor
						new_line_descriptor = new_segment.line_descriptor
					end
				end
				new_node = LinearLinkedListNode.new(new_line_descriptor, new_segment_list, nil)
				new_s.insert_node(new_node)
			end
			new_shape.s[layer_name] = new_s
			
			#Second, we transform the points
			new_p = LinearLinkedList.new
			new_shape.p[layer_name].reset_iterator
			while (node = new_shape.p[layer_name].get_next)
				new_label = node.key
				
				point_list = node.list
				point_list.reset_iterator
				
				new_point_list = LinearLinkedList.new
				while (point_node = point_list.get_next)
					point = point_node.key.point
					#Transform the point
					new_point_x = point.x * ax + point.y * bx + cx
					new_point_y = point.x * ay + point.y * by + cy
					new_point = Point.new(new_point_x, new_point_y, 0)
					
					new_point_list.insert_node(LinearLinkedListNode.new(OrderedPoint.new(new_point), nil, nil))
				end
				new_node = LinearLinkedListNode.new(new_label, new_point_list, nil)
				new_p.insert_node(new_node)
			end
			new_shape.p[layer_name] = new_p
		}
		
		new_shape.recompute_intersection_points
		
		return new_shape
	end
	
	#layer_name:: name of the layer whose transformation is to be known
	#
	#Returns transformation w.r.t. the origin
	def transformation(layer_name)
		return @layout_transformation * @shape_transformation[layer_name]
	end
	#point:: a Point object
	#value:: the name of the label value
	#layer_name:: the layer name on which the label is going to be added
	#
	#Adds a label to the shape in the position determined by point, with the specified value and in the specified layer
	def add_label(point, value, layer_name)
		label = Label.new(value)
		point_list = LinearLinkedList.new
		
		node = LinearLinkedListNode.new(label, point_list, nil)
		
		inserted_node = @p[layer_name].insert_node(node) #Insert the node corresponding to the label of the point
		
		point_node = LinearLinkedListNode.new(OrderedPoint.new(point), nil, nil)
		inserted_node.list.insert_node(point_node) #Insert the point node
	end

	#force:: true if you want to force the refreshing (that is, to refresh it even when the flag for @changed is false); false otherwise
	#
	#Refreshes the view of the shape, in case it has been changed
	def refresh(force = false)
		if Shade.using_sketchup
			Shade.project.modifying = true
			if @changed or @badly_erased or force
				@avoid_bug = (@avoid_bug or @badly_erased)
				@changed = false
				@badly_erased = false
				paint()		
				@avoid_bug = false
			end
			Shade.project.modifying = false
		end
	end
	
	#edges:: an array of SketchUp Edges
	#points_and_materials:: an array of pairs [Point3d, Material], both of them are classes of SketchUp
	#layer:: SketchUp Layer object that is affected
	#
	#Refresh the internal representation of the shape according to the current SketchUp canvas content inside the group of the shape 
	def refresh_from_entities(entities, transformation, layer_name)
		if Shade.using_sketchup
			
			edges = Array.new
			points_and_materials = Array.new
			
			final_transformation = transformation.inverse * @shape_transformation[layer_name]
			
			entities.each { |e|
				if e.kind_of? Sketchup::Edge
					edges.push e
				elsif e.kind_of? Sketchup::Group
					e.entities.each { |ge| 
						if ge.kind_of? Sketchup::ConstructionPoint
							#points_and_materials.push [final_transformation * ge.position, e.material]
							#I don't understand why it is not necessary to apply the transformation to the construction points
							#Maybe their position is not given w.r.t. their parent groups...
							t =  @layout_transformation.inverse * e.transformation
							points_and_materials.push [t * ge.position, e.material]
						end
					}
					
				end
			}
			
			@s[layer_name] = LinearLinkedList.new
			@p[layer_name] = LinearLinkedList.new
			edges.each { |e|
				segment = Segment.new(OrderedPoint.new(final_transformation*e.start.position), OrderedPoint.new(final_transformation*e.end.position))
				segment_list = LinearLinkedList.new

				if @s[layer_name].kind_of? LinearLinkedList
					node = LinearLinkedListNode.new(segment.line_descriptor, segment_list, nil)
				else
					node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, segment.line_descriptor, segment_list)
				end
				
				inserted_node = @s[layer_name].insert_node(node) #Insert the node corresponding to the line descriptor of the segment

				#We create an auxiliar list filled with the new segment to add, in order to make the union and obtain the maximal lines
				new_segment_list = LinearLinkedList.new
				segment_node = LinearLinkedListNode.new(segment.clone, nil, nil)
				new_segment_list.insert_node(segment_node)
				
				op_rel(inserted_node.list,  new_segment_list, Constants::UNION, Constants::SEGMENTS)
			}
			
			#Compound the label lists
			points_and_materials.each { |pair|
				point = pair[0]
	      
				label = Label.new(pair[1])
				
				point_list = LinearLinkedList.new
				
				if @p[layer_name].kind_of? LinearLinkedList
					node = LinearLinkedListNode.new(label, point_list, nil)
				else
					node = BalancedBinaryTreeNode.new(Constants::BALANCED, nil, nil, label, point_list)
				end
				inserted_node = @p[layer_name].insert_node(node) #Insert the node corresponding to the label of the point
				
				point_node = LinearLinkedListNode.new(OrderedPoint.new(point), nil, nil)
				inserted_node.list.insert_node(point_node) #Insert the point node
			}		
	    
			recompute_intersection_points
		end
	end
	
	#Erases the shape
	def erase(print = false)
		if Shade.using_sketchup
			Shade.rule_groups_observer.observed_id_list.delete @shape_id
			Shade.project.modifying = true
			Shade.project.erasing = true
			@group.each_key {|layer_name|
			
				if @group[layer_name] and !@group[layer_name].deleted?
					@group[layer_name].entities.remove_observer @observer[layer_name]
					@observer[layer_name] = nil
					if @group[layer_name].valid? and !@avoid_bug #For avoiding bugs
						Sketchup.active_model.entities.erase_entities @group[layer_name]
						
					end
				end
				Shade.project.modifying = true
			}
			Shade.project.modifying = false
			Shade.project.erasing = false
			@group = Hash.new(nil)
		end
	end
	

	#layer:: name of the layer that is to be painted
	#
	#Paints the view of the shape
	def paint(layer = nil)
		if Shade.using_sketchup	
			Shade.project.modifying = true
			entities = Sketchup.active_model.entities
			
			if !layer
				erase
				Shade.project.modifying = true
				@s.each_key { |layer_name|
				
					if ((@s[layer_name].size > 0) or (@p[layer_name].size > 0))
				
						@group[layer_name] = entities.add_group
						
						
						@s[layer_name].reset_iterator
						while (node = @s[layer_name].get_next)
							node.list.reset_iterator
							while (segment_node = node.list.get_next)
								@group[layer_name].entities.add_edges segment_node.key.tail.point, segment_node.key.head.point
							end
						end
						
						@p[layer_name].reset_iterator
						while (node = @p[layer_name].get_next)
							label = node.key
							node.list.reset_iterator
							while (labelled_point_node = node.list.get_next)	
								if !(label.value==Constants::INTERSECTION_LABEL) #The label is a coloured circle
									label_group = @group[layer_name].entities.add_group
									
									# Add circle
									edges = label_group.entities.add_circle labelled_point_node.key.point, Constants::LABEL_VECTOR, Shade.label_radius
									#Add construction point in order to locate the center later
									label_group.entities.add_cpoint labelled_point_node.key.point
									#Add face
									face = label_group.entities.add_face edges	
									
									#Give color to the face
									label_group.material = label.value
								end
							end
						end
						
						#Find or create the layer
						found = false
						layer = nil
						i = 0
						while (!found and (i < Sketchup.active_model.layers.length))
							if (Sketchup.active_model.layers[i].name == layer_name)
								found = true
								layer = Sketchup.active_model.layers[i]
							end
							i+=1
						end
						if !found
							layer = Sketchup.active_model.layers.add(layer_name)
							# Draw vertical line
							point1 = Constants::PTS_V[0].clone
							point2 = Constants::PTS_V[1].clone
							v_group = Sketchup.active_model.entities.add_group
							v_group.entities.add_line point1,point2
							v_group.layer = layer
						end
						
						@group[layer_name].layer = layer
						
						@group[layer_name].transformation = @layout_transformation
						
						@observer[layer_name] = RuleShapeObserver.new(self)
						@group[layer_name].entities.add_observer @observer[layer_name]
						@shape_id = @group[layer_name].entityID
						Shade.rule_groups_observer.observed_id_list.push @group[layer_name].entityID
					end
				}
			else
				if ((@s[layer.name].size > 0) or (@p[layer.name].size > 0))
					@group[layer.name] = entities.add_group
						
						
					@s[layer.name].reset_iterator
					while (node = @s[layer.name].get_next)
						node.list.reset_iterator
						while (segment_node = node.list.get_next)
							@group[layer.name].entities.add_edges segment_node.key.tail.point, segment_node.key.head.point
						end
					end
					
					@p[layer.name].reset_iterator
					while (node = @p[layer.name].get_next)
						label = node.key
						node.list.reset_iterator
						while (labelled_point_node = node.list.get_next)	
							if !(label.value==Constants::INTERSECTION_LABEL) #The label is a coloured circle
								label_group = @group[layer.name].entities.add_group
								
								# Add circle
								edges = label_group.entities.add_circle labelled_point_node.key.point, Constants::LABEL_VECTOR, Shade.label_radius
								#Add construction point in order to locate the center later
								label_group.entities.add_cpoint labelled_point_node.key.point
								#Add face
								face = label_group.entities.add_face edges	
								
								#Give color to the face
								label_group.material = label.value
							end
						end
					end
					
					@group[layer.name].layer = layer
					
					@group[layer.name].transformation = @layout_transformation
					
					@observer[layer.name] = RuleShapeObserver.new(self)
					@group[layer.name].entities.add_observer @observer[layer.name]
					@shape_id = @group[layer.name].entityID
					Shade.rule_groups_observer.observed_id_list.push @group[layer.name].entityID	
				end
			end
			Shade.project.modifying = false
		end
	end
	
	#other_shape:: another LabelledShape
	#
	#returns:: true iff this shape and the specified one are identical
	def ==(other_shape)
		result = true
		if (other_shape.kind_of? RuleLabelledShape)
			i = 0
			@s.keys.each{ |layer_name|
				result = (result && ((@s[layer_name] == other_shape.s[layer_name])&&(@p[layer_name] == other_shape.p[layer_name])))
				
				i+=1
			}
		else
			result = false
		end
		return result
	end

	#Produces another RuleLabelledShape, identical to this one
	def clone()
		new_shape = RuleLabelledShape.new(Array.new,Array.new,nil,nil)
		@s.each_key { |layer_name|
			new_shape.s[layer_name] = @s[layer_name].clone
		}
		@p.each_key { |layer_name|
			new_shape.p[layer_name] = @p[layer_name].clone
		}
		return new_shape
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents the current LabelledShape, that is, the design
class CurrentLabelledShape < LabelledShape
	
	#Hash for the SU objects that group the units
	attr_accessor :group
	
	#Hash for the permutation of @p, so its subsets are ordered in ascendent order of cardinality
	attr_accessor :pi
	
	attr_accessor :mu
	
	
	#edges:: list of edges
	#points_and_materials:: list of pairs (point, material)
	#
	#Initializes the current labelled shape (the design), adding the edges and the points to the layer 0
	def initialize(edges, points_and_materials)
		
		if Shade.using_sketchup
			@s = Hash.new(nil)
			Sketchup.active_model.layers.each { |layer|
				@s[layer.name] = BalancedBinaryTree.new
			}
			@p = Hash.new(nil)
			Sketchup.active_model.layers.each { |layer|
				@p[layer.name] = LinearLinkedList.new
			}
		else
			@s = Hash.new(nil)
			@s["Layer0"] = BalancedBinaryTree.new
			@p = Hash.new(nil)
			@p["Layer0"] = LinearLinkedList.new
		end
		
		super(edges, points_and_materials)
		
		@pi = Hash.new(nil)
		if Shade.using_sketchup
			Sketchup.active_model.layers.each { |layer|
				@pi[layer.name] = PiList.new
			}
		else
			@pi["Layer0"] = PiList.new
		end
		
		@p["Layer0"].reset_iterator
		i =0
		while (n=@p["Layer0"].get_next)
			cardinality = n.list.size
			node = LinearLinkedListNode.new(cardinality, i, nil)
			#So the indexes (i) are sorted by ascending order of the cardinalities
			@pi["Layer0"].insert_node(node)
			i+=1
		end
		
		@group = Hash.new(nil)
		@mu = Hash.new(nil)
		
		if Shade.using_sketchup
      Sketchup.active_model.layers.each { |layer|
        @mu[layer.name] = 1
      }
    else
      @mu["Layer0"] = 1
    end
	end
	
	#Creates the permutation for ordering the labelled point list
	def create_pi()
		@p.keys.each {|layer_name|
			@pi[layer_name] = PiList.new
			@p[layer_name].reset_iterator
			i =0
			while (n=@p[layer_name].get_next)
				cardinality = n.list.size
				node = LinearLinkedListNode.new(cardinality, i, nil)
				#So the indexes (i) are sorted by ascending order of the cardinalities
				@pi[layer_name].insert_node(node)
				i+=1
			end
			#puts "pi size: #{@pi[layer_name].size}"
		}
	end
	
	#show_labels:: true if the labels are to be shown in the canvas; false otherwise
	#Refreshes the view of the shape, in case it has been changed
	def refresh(show_labels = true)
		if Shade.using_sketchup
			paint(show_labels)	
		end
	end
	
	#Erases the shape
	def erase()
		if Shade.using_sketchup
			Sketchup.active_model.layers.each {|layer|
				if (@group[layer.name] and !@group[layer.name].deleted?)
					Sketchup.active_model.entities.erase_entities @group[layer.name]
				end
			}
			@group = Hash.new(nil)
		end
	end
	

	#show_labels:: true if the labels are to be shown in the canvas; false otherwise
	#layer:: SketchUp Layer object that is to be painted
	#
	#Paints the view of the shape
	def paint(show_labels = true, layer = nil)
		if Shade.using_sketchup
			entities = Sketchup.active_model.entities
			
			if !layer
				erase
				@s.each_key {|layer_name|
					@group[layer_name] = entities.add_group

					@s[layer_name].reset_iterator
					while (node = @s[layer_name].get_next)
						node.list.reset_iterator
						while (segment_node = node.list.get_next)
							@group[layer_name].entities.add_line segment_node.key.tail.point, segment_node.key.head.point
						end
					end
					
					if show_labels
						@p[layer_name].reset_iterator
						while (node = @p[layer_name].get_next)
							label = node.key
							node.list.reset_iterator
							while (labelled_point_node = node.list.get_next)	
								if !(label.value==Constants::INTERSECTION_LABEL) #The label is a coloured circle
									label_group = @group[layer_name].entities.add_group
									
									# Add circle
									edges = label_group.entities.add_circle labelled_point_node.key.point, Constants::LABEL_VECTOR, Shade.label_radius
									#Add construction point in order to locate the center later
									label_group.entities.add_cpoint labelled_point_node.key.point
									#Add face
									face = label_group.entities.add_face edges	
									
									#Give color to the face
									label_group.material = label.value
								end
							end
						end
					end
					
					#Find or create the layer
					found = false
					layer = nil
					i = 0
					while (!found and (i < Sketchup.active_model.layers.length))
						if (Sketchup.active_model.layers[i].name == layer_name)
							found = true
							layer = Sketchup.active_model.layers[i]
						end
						i+=1
					end
					if !found
						layer = Sketchup.active_model.layers.add(layer_name)
						# Draw vertical line
						point1 = Constants::PTS_V[0].clone
						point2 = Constants::PTS_V[1].clone
						v_group = Sketchup.active_model.entities.add_group
						v_group.entities.add_line point1,point2
						v_group.layer = layer
					end
					@group[layer_name].layer = layer

					@group[layer_name].transformation = Constants::AXIOM_T
				}
			else
				@group[layer.name] = entities.add_group
				
				@group[layer.name].layer = layer
					
				@s[layer.name].reset_iterator
				while (node = @s[layer.name].get_next)
					node.list.reset_iterator
					while (segment_node = node.list.get_next)
						@group[layer.name].entities.add_line segment_node.key.tail.point, segment_node.key.head.point
					end
				end
				
				if show_labels
					@p[layer.name].reset_iterator
					while (node = @p[layer.name].get_next)
						label = node.key
						node.list.reset_iterator
						while (labelled_point_node = node.list.get_next)	
							if !(label.value==Constants::INTERSECTION_LABEL) #The label is a coloured circle
								label_group = @group[layer.name].entities.add_group
								
								# Add circle
								edges = label_group.entities.add_circle labelled_point_node.key.point, Constants::LABEL_VECTOR, Shade.label_radius
								#Add construction point in order to locate the center later
								label_group.entities.add_cpoint labelled_point_node.key.point
								#Add face
								face = label_group.entities.add_face edges	
								
								#Give color to the face
								label_group.material = label.value
							end
						end
					end
				end

				@group[layer.name].transformation = Constants::AXIOM_T
			end
		end
	end
	
	#other_shape:: another LabelledShape
	#
	#returns:: true iff this shape and the specified one are identical
	def ==(other_shape)
		result = true
		if (other_shape.kind_of? CurrentLabelledShape)
			@p.keys.each { |layer_name|
				result = (result && ((@s[layer_name] == other_shape.s[layer_name])&&(@p[layer_name] == other_shape.p[layer_name])))
			}
		else
			result = false
		end
		return result
	end
	
	#returns:: a new CurrentLabelledShape object identical to this one
	def clone()
		new_shape = CurrentLabelledShape.new(Array.new, Array.new)
		
		@s.each_key { |layer_name|
			new_shape.s[layer_name] = @s[layer_name].clone
		}
		@p.each_key { |layer_name|
			new_shape.p[layer_name] = @p[layer_name].clone
		}
		
		new_shape.create_pi
		new_shape.mu = @mu
		
		return new_shape
	end
	
	def mu_calc(ht_calc, factor)
    b = 1
    ht = Math.sqrt(  ((Shade.hausdorff_threshold[0]**2)*factor[0])  + ((Shade.hausdorff_threshold[1]**2)*factor[1])  )
	  a = ((Shade.mu_min-b)/ht)
	  result = ((a*ht_calc)+b)
#	  puts "ht #{ht.to_m}"
#	  puts "htx #{Shade.hausdorff_threshold[0]}"
#	  puts "hty #{Shade.hausdorff_threshold[1]}"
	  return result
	end
end