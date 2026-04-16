#Ruby class: Array
class Array
	#array:: another array
	#epsilon:: threshold accuracy
	#
	#returns:: true iff the arrays are equal, with a margin stablished by epsilon
	def eql_eps(array, epsilon)
		if array.length != self.length
			return false
		end
		i = 0
		result = true
		while i < self.length && result
			a = self[i]
			b = array[i]
			dif = a - b
			if dif < 0
				dif = -1*dif
			end
			result = (dif < epsilon)
			i+=1
		end
		return result		
	end
	
	#returns:: the array shuffled
	def shuffle	
		size.downto(1) { |n| push delete_at(rand(n)) }
		self
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a node of a linear linked list
class LinearLinkedListNode
	#LineDescriptor, Label, Point or Segment
	attr_accessor :key
	
	#First node of the colinear line list or the' points with same label' list
	attr_accessor :list
	
	#Next ListNode
	attr_accessor :_next
	
	#key:: LineDescriptor or Label
	#list:: first node of the colinear line list or the 'points with same label' list
	#_next:: Next ListNode
	#
	#Initializes the ListNode
	def initialize(key, list, _next)
		@key, @list, @_next = key, list, _next
	end
	
	#returns::a new LinearLinkedListNode, identical to this one, except for the field _next
	#which is nil in the cloned one
	def clone()
		new_list = nil
		if ((@list.kind_of? Fixnum) or !@list)
			new_list = @list
		else
			new_list = @list.clone
		end
		new_key = nil
		if @key.kind_of? Fixnum
			new_key = @key
		else
			new_key = @key.clone
		end
		return LinearLinkedListNode.new(new_key, new_list, nil)
	end
	
	#returns:: the hash code for this node
	def hash
		return [@key.hash, @list.hash].hash
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a linked list
class LinearLinkedList
	#First node of the list (LinearLinkedListNode)
	attr_accessor :first
	#Number of nodes in the list
	attr_accessor :size
	#Current node for getting the nodes in order
	attr_accessor :current_node
	#Last node of the list (LinearLinkedListNode)
	attr_accessor :last
	
	#Initializes the List
	def initialize()
		@first = nil
		@size = 0
		@current_node = Constants::START
		@last = nil
	end
	
	#n:: LinearLinkedListNode to add
	#
	#returns:: the inserted node or the previously existing node in case the key already exist in the list
	#Inserts the node, maintaining the order of the list
	def insert_node(n)
		previous = nil
		current = @first
		position_found = false
		exists = false
		while (current && !position_found && !exists)
			if (n.key < current.key)
				position_found = true
			elsif (n.key == current.key)
				exists = true
			else
				previous = current
				current = current._next
			end
		end

		if !exists #If the node does'n exist
			if !previous #Is the first node
				n._next = @first
				@first = n
				@current_node = Constants::START
				if (@size == 0)
					@last = n
				end
			else # General case (or last to be added if !position_found)
				if !position_found
					@last = n
				end
				previous._next = n
				n._next = current
			end
		
			@size += 1
			result =  n
		else
			result = current
		end
		return result
	end
	
  
	
	#returns:: the nodes of the list in the form of an array
	def to_array
		result = Array.new
		current = @first
		while current
			result.push current
			current = current._next
		end
		return result
	end
	
	#key::key of the node we want to recover
	#
	#returns:: the node with the specified key. In case it does not exists, returns nil.
	def get_node(key)
		result = nil
		current = @first
		found = false
		while (current && !found)
			if (current.key == key)
				found = true
				result = current
			else
				current = current._next
			end
		end
		return result
	end
	
	#key:: key of the node to remove
	#
	#returns:: true iff the node has been deleted, false otherwise.
	#Deletes the specified node
	def delete_node(key)
		previous = nil
		current = @first
		exists = false
		while (current && !exists)
			if (key == current.key)
				exists = true
			else
				previous = current
				current = current._next
			end
		end
		
		if exists
			if !previous #Is the first node
				@first = @first._next
				if (@size == 1)
					@last = nil
				end
			else #General case
				if !current._next
					@last = previous
				end
				previous._next = current._next
			end
			@size -= 1
			result = true
		else
			result = false
		end
		return result
	end
	
	#i::index ofthe node to be retrieved
	#
	#returns:: the node in the position i, or nil if i >= size of the list
	def get_node_i(i)
		if (i < @size)
			j = 0
			result = @first
			while (j < i)
				result = result._next
				j += 1
			end
		end
		return result
	end
	
	#returns:: returns, in each invocation, the next node, in order, in the list
	def get_next()
		if @current_node == Constants::START
			@current_node = @first
		elsif @current_node			
			@current_node = @current_node._next
		else
			self.reset_iterator
		end
		result = @current_node
		return result
	end
	
	#resets the iterator used by get_next()
	def reset_iterator()
		@current_node = Constants::START
	end
	
	#returns:: true iff the list is empty
	def empty?()
		return !@first
	end
	
	#returns:: a new LinearLinkedList, identical to this one
	def clone()
		new_lllist = LinearLinkedList.new
		current = @first
		while current
			new_node = current.clone
			new_lllist.insert_node(new_node)
			current = current._next
		end
		return new_lllist
	end
	
	#other_list:: another LinearLinkedList object
	#
	#returns:: true if this list is identical to the specified list
	def ==(other_list)
		result = false
		if !other_list
			other_list = LinearLinkedList.new
		end
		if other_list.kind_of? LinearLinkedList
			result = (@size == other_list.size)
			current = @first
			other_current = other_list.first
			while (result && current && other_current)
				result = ((current.key == other_current.key) && (current.list == other_current.list))
				current = current._next
				other_current = other_current._next
			end
		end
		return result
	end
	
	#returns:: the hash code for this list
	def hash
		array = self.to_array
		hash_array = Array.new
		array.each { |node|
			hash_array.push node.hash
		}
		return hash_array.hash
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a linked list used for the pi permutation of CurrentLabelledShape
class PiList
	#First node of the list (LinearLinkedListNode)
	attr_accessor :first
	#Number of nodes in the list
	attr_accessor :size
	#Current node for getting the nodes in order
	attr_accessor :current_node
	
	#Initializing
	def initialize
		@first = nil
		@size = 0
		@current_node = Constants::START
	end
	
	#n:: LinearLinkedListNode to add
	#
	#Inserts the node, maintaining the order of the list. Doesn't matter if keys are repeated
	def insert_node(n)
		previous = nil
		current = @first
		found = false
		while (current && !found)
			if (n.key < current.key)
				found = true
			elsif (n.key == current.key)
				found = true
			else
				previous = current
				current = current._next
			end
		end

		if !previous #Is the first node
			n._next = @first
			@first = n
			@current_node = Constants::START
		else # General case (or last to be added if !found)
			previous._next = n
			n._next = current
		end
	
		@size += 1
		result =  n

		return result
	end
	
	#i::index ofthe node to be retrieved
	#
	#returns:: the node in the position i, or nil if i >= size of the list
	def get_node_i(i)
		if (i < @size)
			j = 0
			result = @first
			while (j < i)
				result = result._next
				j += 1
			end
		end
		return result
	end
	
	#returns:: returns, in each invocation, the next node, in order, in the list
	def get_next()
		if @current_node == Constants::START
			@current_node = @first
		elsif @current_node			
			@current_node = @current_node._next
		else
			self.reset_iterator
		end
		result = @current_node
		return result
	end
	
	#resets the iterator used by get_next()
	def reset_iterator()
		@current_node = Constants::START
	end
	
	#returns:: an identical PiList object to this
	def clone()
		new_lllist = PiList.new
		current = @first
		while current
			new_node = current.clone
			new_lllist.insert_node(new_node)
			current = current._next
		end
		return new_lllist
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a node of a BalancedBinaryTree
class BalancedBinaryTreeNode
	
	#The height of the node in the tree
	attr_accessor :height
	
	#Left offspring TreeNode
	attr_accessor :left
	
	#Right offspring TreeNode
	attr_accessor :right
	
	#LineDescriptor or Label
	attr_accessor :key
	
	#First node of the colinear line list or the point with same label list
	attr_accessor :list
	
	#height::The height of the node in the tree
	#left::Left offspring TreeNode
	#right::Right offspring TreeNode
	#key::#LineDescriptor or Label
	#list::#First node of the colinear line list or the point with same label list
	#
	#Initialize the node
	def initialize(height, left, right, key, list)
		@height, @left, @right, @key, @list = height, left, right, key, list
	end
	
	#returns::a new BalancedBinaryTreeNode, identical to this one, except for the fields right and left
	#which are nil in the cloned one, and the height, which is 0
	def clone()
		return BalancedBinaryTreeNode.new(0, nil, nil, @key.clone, @list.clone)
	end
	
	#returns:: the hash code for this list
	def hash
		return [@height.hash, @key.hash, @list.hash]
	end
end

#Author:: Manuela Ruiz  (mailto:mruiz@lcc.uma.es)
#This class represents a Balanced Binary Tree
class BalancedBinaryTree
	
	#Root of the tree. It is a BalancedBinaryTreeNode
	attr_accessor :root
	#Number of nodes in the tree
	attr_accessor :size
	
	#Initialize the BalancedBinaryTree
	def initialize()
		@root = nil
		@size = 0
		@iterNode = @root
		@itNodePath = Array.new
	end
	
	#n:: a key to delete from this BalancedBinaryTree
	#
	#returns:: true iff removal is performed
	#Deletes the node n from the tree and rebalances the tree
	def delete_node(n)
		nodePath = Array.new
		
		current = @root
		
		while current
			nodePath.push current
			
			if n < current.key
				if ((current.left) && n == current.left.key)
					current.left = removeNode(current.left)	
					@size = @size - 1
					rebalanceTree(nodePath, false)
					return true
				end
				current = current.left
				
			elsif current.key < n
				if ((current.right) && n == current.right.key)
					current.right = removeNode(current.right)	
					@size = @size - 1
					rebalanceTree(nodePath, false)
					return true
				end
				current = current.right
				
			else
				@root = removeNode(current) #Root is to be removed
				@size = @size - 1
				rebalanceTree(nodePath, false)
				return true
			end
		end
		return false
	end
	
	#removalNode:: the node to be removed from the tree
	#
	#returns:: the node to replace the removed node
	#Removes the specified node from the tree, returning an appropiate replacement node
	def removeNode(removalNode)
		
		if (removalNode.left && removalNode.right)
			replacementNode = fetchSuccessor(removalNode)
			
			replacementNode.left = removalNode.left
			replacementNode.right = removalNode.right
			
			if ((height(replacementNode.left) - height(replacementNode.right)) == 2)
				if (height(replacementNode.left.left) >= height(replacementNode.left.right))
					replacementNode = rotateWithLeftChild(replacementNode)
				else
					replacementNode = doubleRotateWithLeftChild(replacementNode)
				end
			end
			
			replacementNode.height = ([height(replacementNode.left),height(replacementNode.right)].max) + 1
		else
			if removalNode.left
				replacementNode = removalNode.left
			else
				replacementNode = removalNode.right
			end
		end
		
		removalNode.left = nil
		removalNode.right = nil
		
		return replacementNode
		
	end
	
	#sRoot:: the root of the subtree of which to fetch the logical successor node
	#
	#returns:: the successor node of the specified subtree root node
	#Removes and returns the node that is the logical in-order successor of the specified subtree root node
	def fetchSuccessor(sRoot)
		if (!sRoot || !sRoot.right)
			return nil
		end
		
		successorNode = sRoot.right
		
		if !sRoot.right.left
			sRoot.right = successorNode.right
			return successorNode
		else
			nodePath = Array.new
			nodePath.push sRoot
			current = sRoot.right
			
			while (current.left.left)
				nodePath.push current
				
				current = current.left
			end
			
			nodePath.push current
			
			successorNode = current.left
			current.left = current.left.right
			
			rebalanceTreeAfterFetchSuccessor(nodePath)
			
			return successorNode
		end
	end
	
	#nodePath:: the stack which contains the nodes in the order that they were traversed
	#
	#Restores balance to the tree after a node successor has been fetched given the specified node traversal path
	def rebalanceTreeAfterFetchSuccessor(nodePath)
		
		while nodePath.size > 2
			current = nodePath.pop
			
			if (height(current.right) - height(current.left) == 2)
				if (height(current.right.right) >= height(current.right.left))
					nodePath.last.left = rotateWithRightChild(current)
				else
					nodePath.last.left = doubleRotateWithRightChild(current)
				end
			end
			
			current.height = ([height(current.left) , height(current.right)].max) + 1
		end
		#Current node is root of right subtree of removal node:
		current = nodePath.pop
		if (height(current.right) - height(current.left) == 2)
			if (height(current.right.right) >= height(current.right.left))
				nodePath.last.right = rotateWithRightChild(current)
			else
				nodePath.last.right = doubleRotateWithRightChild(current)
			end
		end
		
		current.height = ([height(current.left) , height(current.right)].max) + 1
	end
	
	#nodePath:: the stack which contains the nodes in the order that they were traversed
	#isInsertion:: Indicates whether insertion or removal was performed
	#
	#Rebalances the tree after an insertion or a removal
	def rebalanceTree(nodePath, isInsertion)
		while !nodePath.empty?
			current = nodePath.pop();

			#Check for an imbalance at the current node:
			if (height(current.left) - height(current.right) == 2)
				#Compare heights of subtrees of left child node of
				#imbalanced node (check for single or double rotation case
				if (height(current.left.left) >= height(current.left.right))
					#Check if imbalance is internal or at the tree root:
					if (!nodePath.empty?) 
						#Compare current element with element of parent
						#node (check which child reference to update for the
						#parent node):
						if (current.key < nodePath.last.key)
							nodePath.last.left = rotateWithLeftChild(current)
						else
							nodePath.last.right = rotateWithLeftChild(current)
						end
					else
						@root = rotateWithLeftChild(current)
					end
				else
					if (!nodePath.empty?)
						if (current.key < nodePath.last.key)
							nodePath.last.left = doubleRotateWithLeftChild(current)
						else
							nodePath.last.right = doubleRotateWithLeftChild(current)
						end
					else
						@root = doubleRotateWithLeftChild(current)
					end
				end

				current.height = ([height(current.left),height(current.right)].max) + 1

				if isInsertion
					break
				end
			elsif (height(current.right) - height(current.left) == 2) 
				if (height(current.right.right) >= height(current.right.left)) 
					if (!nodePath.empty?) 
						if ((current.key < nodePath.last.key)) 
							nodePath.last.left = rotateWithRightChild(current)
						else
							nodePath.last.right = rotateWithRightChild(current)
						end
					else
						@root = rotateWithRightChild(current)
					end
				else
					if (!nodePath.empty?)
						if ((current.key < nodePath.last.key)) 
							nodePath.last.left = doubleRotateWithRightChild(current)
						else
							nodePath.last.right = doubleRotateWithRightChild(current)
						end
					else
						@root = doubleRotateWithRightChild(current)
					end
				end

				current.height = ([height(current.left),height(current.right)].max) + 1

				if isInsertion
					break
				end
			else
				current.height = ([height(current.left),height(current.right)].max) + 1
			end
		end
	end

	
	#node::The node of which to get the height.
	#
	#returns:: The height of the node in the tree or -1 if the node is null.
	def height(node)
		if node
			return node.height
		else
			return -1
		end
	end
	
	#sRoot:: The root of the subtree with which to rotate the node's left child
	#
	#returns:: The node that is the new root of the specified root's subtree.
	def rotateWithLeftChild(sRoot)
		newRoot = sRoot.left
		sRoot.left = newRoot.right
		newRoot.right = sRoot
		
		sRoot.height = ([height(sRoot.left) , height(sRoot.right)].max) + 1
		newRoot.height = ([height(newRoot.left), sRoot.height].max) + 1
		return newRoot
	end
	
	#sRoot:: The root of the subtree with which to rotate the node's right child
	#
	#returns:: The node that is the new root of the specified root's subtree.
	def rotateWithRightChild(sRoot)
		newRoot = sRoot.right
		sRoot.right = newRoot.left
		newRoot.left = sRoot
		
		sRoot.height = ([height(sRoot.left) , height(sRoot.right)].max) + 1
		newRoot.height = ([sRoot.height, height(newRoot.right)].max) + 1
		
		return newRoot
	end
	
	#sRoot:: The root of the subtree with which to double rotate the node's left child
	#
	#returns:: The node that is the new root of the specified root's subtree.
	def doubleRotateWithLeftChild(sRoot)
		sRoot.left = rotateWithRightChild(sRoot.left)
		
		return rotateWithLeftChild(sRoot)
	end
	
	
	#sRoot:: The root of the subtree with which to double rotate the node's right child
	#
	#returns:: The node that is the new root of the specified root's subtree.
	def doubleRotateWithRightChild(sRoot)
		sRoot.right = rotateWithLeftChild(sRoot.right)
		
		return rotateWithRightChild(sRoot)
	end
	
	#n:: a BalancedBinaryTreeNode to add to this BalancedBinaryTree
	#
	#returns:: the inserted node or the previously existing node in case the key already exist in the tree
	# Adds the specified node as an offspring of the tree, maintaining the order
	def insert_node(n)
		nodePath = Array.new
		
		current = @root
		while current
			nodePath.push current
			
			if n.key < current.key
				
				if !current.left
					current.left = n
					@size += 1
					
					rebalanceTree(nodePath, true)
					
					return n
				end
				
				current = current.left
				
			elsif current.key < n.key
				
				if !current.right
					current.right = n
					@size += 1
					
					rebalanceTree(nodePath, true)
					
					return n
				end
				
				current = current.right
			else #Element is already stored in the tree
				return current
			end
		end
		
		#The tree is empty
		@root = n
		@size += 1
		return n
	end

	#key::key of the node we want to recover
	#
	#returns:: the node with the specified key. In case it does not exists, returns nil.
	def get_node(key)
		result = nil
		current = @root
		found = false
		while current && !found
			if key < current.key
				current = current.left
			elsif current.key < key
				current = current.right
			else
				found = true
				result = current
			end
		end
		return result
	end
	
	#returns::true iff the tree is empty
	def empty?
		return !@root
	end

	#Resets the iterator of the tree
	def reset_iterator
		@iterNode = @root
		@itNodePath = Array.new
	end
	
	#returns:: true if the iterator has more elements
	def has_next
		return (@iterNode or !@itNodePath.empty?)
	end
	
	#returns:: the next element of the iterator
	def get_next
		nextElement = nil
			
		while @iterNode
			@itNodePath.push(@iterNode)
			
			@iterNode = @iterNode.left
		end
		
		if !@itNodePath.empty?
			@iterNode = @itNodePath.pop
			nextElement = @iterNode
			@iterNode = @iterNode.right
		end
		
		return nextElement
	end
  
	#returns:: the nodes of the tree in the form of an array
	def to_array
		result = Array.new

		path = Array.new
		isDone = false
		current = @root

		while (!isDone)
			if current
				path.push current
				current = current.left
			else
				if !path.empty?
					current = path.pop
					result.push current
					current = current.right
				else
					isDone = true
				end
			end
		end

		return result   
	end
	
	#returns:: a BalancedBinaryTree object identical to this
	def clone
		new_tree = BalancedBinaryTree.new
		self.reset_iterator
		while self.has_next
			node = self.get_next
			new_node = node.clone
			new_tree.insert_node new_node
		end
		return new_tree
	end

	#another_bb_tree:: a BalancedBinaryTree
	#
	#returns:: true if this and another_bb_tree are equal
	def == (another_bb_tree)
		self_array = self.to_array
		if !another_bb_tree
			another_bb_tree = BalancedBinaryTree.new
		end
		other_array = another_bb_tree.to_array
		result = (self_array.length == other_array.length)
		if result
			i = 0
			while ((i < self_array.length) && result)
				self_node = self_array[i]
				other_node = other_array[i]
				result = (result && (self_node.key == other_node.key) && (self_node.list == other_node.list))
				i+= 1
			end
		end
		return result
		
	end
	
	#returns:: the hash code for this tree
	def hash
		array = self.to_array
		hash_array = Array.new
		array.each { |node|
			hash_array.push node.hash
		}
		return hash_array.hash
	end
end