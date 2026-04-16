#class Numeric of Ruby
class Numeric
	#returns:: this number
	#This method is defined in the API of SketchUp in order to work with meters instead of inches. When this command is used, we are working without SkethUp,
	#so we do not need this conversion. We define thus this method for avoiding errors when the invocations of .m are done; since Ruby does not define it.
	#Obviously, when SketchUp is not being used, this method does not do anything, returning the same number.
	def m
		return self
	end
end

require "#{File.dirname(__FILE__)}/../main-structures"
require "#{File.dirname(__FILE__)}/../utils"

ShadeUtils.initialize_command

result = Shade.project.execution.apply_rule_random()

ShadeUtils.finish_command2(result)