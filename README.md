# WorkCalendar
A gem to do simple date calculations

## Installation
```console
git clone https://github.com/kpandya91/WorkCalendar.git 
cd WorkCalendar
gem build workcalendar.gemspec 
gem install workcalendar-0.1.0.gem 
```

## Configuration
```ruby
WorkCalendar.configure do |c|
  c.weekdays = %i[mon tue wed thu fri]
  c.holidays = [Date.new(2014, 12, 31), Date.new(2015, 1, 1), Date.new(2015, 7, 3), Date.new(2015, 12, 25), Date.new(2015, 4, 15), Date.new(2015, 9, 15), Date.new(2015, 11, 22)]
end
```

## Usage

Check if a date is active (is a weekday and not a holiday):
```ruby
# true if the given date is active, false otherwise
WorkCalendar.active?(Date.new(2015, 7, 3))
# => false

WorkCalendar.active?(Date.new(2015, 10, 14))
# => true
```

Get nth active date before the given date:
```ruby
WorkCalendar.days_before(7, Date.new(2015, 1, 8))
# => #<Date: 2014-12-26 ((2457018j,0s,0n),+0s,2299161j)>
```

Get nth active date after the given date:
```ruby
WorkCalendar.days_after(5, Date.new(2015, 4, 11))
# => #<Date: 2015-04-20 ((2457133j,0s,0n),+0s,2299161j)>
```

Get all active dates between the two given dates
```ruby
WorkCalendar.between(Date.new(2014, 12, 26), Date.new(2015, 1, 7))
#  => [
#     #<Date: 2014-12-26 ((2457018j,0s,0n),+0s,2299161j)>,
#     #<Date: 2014-12-29 ((2457021j,0s,0n),+0s,2299161j)>,
#     #<Date: 2014-12-30 ((2457022j,0s,0n),+0s,2299161j)>,
#     #<Date: 2015-01-02 ((2457025j,0s,0n),+0s,2299161j)>,
#     #<Date: 2015-01-05 ((2457028j,0s,0n),+0s,2299161j)>,
#     #<Date: 2015-01-06 ((2457029j,0s,0n),+0s,2299161j)>
#     ]
```

## Documentation
Find rdoc generated documentation [here!](http://kumarpandya.com/workcalendar)

## Implementation

#### Configuration.rb
[Documentation](http://kumarpandya.com/workcalendar/WorkCalendar/Configuration.html)

The class to save configuration for WorkCalendar module

###### #holidays
+ We save holidays as **Set** to have O(1) lookup when checking if a date is holiday (since we don't care if we lose duplicates and set in ruby are hashed)
+ One alternative would've been to use **Array** with O(n) lookup. This could get really expensive for **days_before**, **days_after** and **between** methods if the array isn't sorted.
+ Second alternative is to use **linked list** to store holidays. For that, we can initially generate a sorted linked list of holidays. Checking if given date is holiday would be O(n). **days_before**, **days_after** and **between** would also be O(n) since we can initially set the pointer in the linked list to first holiday that comes after the starting date and move one at a time afterwards if we find a match.

###### #weekdays
+ We create hash to save weekdays with index of the weekday as key (i.e. 0-6 representing sun-sat)
+ In order for date to be able to skip over non-active days without any cost, we set each value to be Hash with prev (:-) and next (:+) keys and cost of moving from the given day as value

  e.g.
  ```ruby
  c.weekdays = %i[mon tue wed thu fri]
  # 	 => {   0=>{:+=>1, :-=>2},  # Next active day (:+) after Sunday is Monday -> 1 day apart
  # 		    1=>{:+=>1, :-=>3},	# Previous active day (:-) before Monday is Friday -> 3 days apart
  # 		    2=>{:+=>1, :-=>1},
  # 		    3=>{:+=>1, :-=>1},
  # 		    4=>{:+=>1, :-=>1},
  # 		    5=>{:+=>3, :-=>1},
  # 		    6=>{:+=>2, :-=>1} }
  ```

#### Date.rb
[Documentation](http://kumarpandya.com/workcalendar/Date.html)

This file extends the functionalities of default ruby date library.

* If I am a Date, I can:
  1. Know if I am a weekday
  2. Know if I am a holiday
  3. Give the next active date
  4. Give the previous active date

* The reason behind implementing it this way is that the functonalities being added to Date are lightweight and we are not overriding or reimplementing existing methods.

* The alternative would've been to not take Object oriented approach and have WorkCalendar module work solely with Configuration class to do date calculations.

* Date also reads its settings for weekdays and holidays from WorkCalendar module for the sake of not having duplicate data. The alternative for that would be to set weekdays and holidays as class variables for Date class.

* [A different implementation](https://github.com/kpandya91/WorkCalendar2) that doesn't temper with Date library

#### WorkCalendar.rb
[Documentation](http://kumarpandya.com/workcalendar/WorkCalendar.html)

This file contains the main methods for our library.
