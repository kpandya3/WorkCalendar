require 'set'

module WorkCalendar

	# == Configuration class
	# 
	# Class to save and lookup WorkCalendar configuration
	# 
	class Configuration

		attr_reader :holidays, :weekdays

		# Initialize gem with mon-fri weekdays and empty holiday set
		def initialize
			@weekdays = self.class.get_weekday_delta(%i[mon tue wed thu fri])
			@holidays = Set.new []
		end

		# Save holidays as a set for O(1) lookup
		#
		# +arr+ - Array of Date object, each representing a holiday
		#
		def holidays=(arr)
			@holidays = Set.new arr
		end

		# Set weekdays to a hash representing next and previous weekday for O(1) lookup
		# 
		# +active_days+ - Array of weekdays
		# 
		def weekdays=(active_days)
			@weekdays = self.class.get_weekday_delta(active_days)
		end

	private

		# Get difference in days beweeen the next (or prev) weekday from current one
		# 
		# +n+ - The current day of the week (0-6)
		# +active_days+ - List of weekdays for current configuration
		# +operator+ - To be able to get both prev and next differences (:+ by default)
		# 
		def self.get_norp_wday(n, active_days, operator=:+)
			count = 1
			alldays = %i[sun mon tue wed thu fri sat]
			loop do
				n = n.send(operator, 1)
				if active_days.include?alldays[n%7]
					return count
				end
				count += 1
			end
		end

		# Given a list of w
		# 
		# +active_days+ - Array of weekdays e.g. [:mon, :tue, :wed, :thu. :fri, :sat]
		# 
		# ==== Examples
		# 
		# Illustrate the behaviour of the method using examples. Indent examples:
		#
		#    Configuration.get_weekday_delta(%i[mon tue wed thu fri])
		# 	 => {0=>{:+=>1, :-=>2}, # Next active day (:+) after Sunday is Monday -> 1 day apart
		# 		 1=>{:+=>1, :-=>3},	# Previous active day (:-) before Monday is Friday -> 3 days apart
		# 		 2=>{:+=>1, :-=>1},
		# 		 3=>{:+=>1, :-=>1},
		# 		 4=>{:+=>1, :-=>1},
		# 		 5=>{:+=>3, :-=>1},
		# 		 6=>{:+=>2, :-=>1}}
		def self.get_weekday_delta(active_days)
			# We make sure that theres at least one active day in a week
			raise "Weekdays array is empty" if active_days.empty?

			# Convert the input to set for O(1) lookup
			active_days = Set.new active_days

			# Create hash for result set
			delta = {}

			# Go through each day of the week (sun..sat)
			(0..6).each do |i|
				delta[i] = {}

				# Set delta between current and next active day
				delta[i][:+] = get_norp_wday(i, active_days)

				# Set delta between current and prev active day
				delta[i][:-] = get_norp_wday(i, active_days, :-)
			end
			delta
		end
	end
end