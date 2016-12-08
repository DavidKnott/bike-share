class Trip < ActiveRecord::Base
  # validates :duration, :start_station_id, :end_station_id, :start_date, :end_date, :bike_id, :subscription_type, :zip_code, presence: true
  belongs_to :trip_start, :class_name => 'Station', :foreign_key => 'start_station_id'
  belongs_to :trip_end, :class_name => 'Station', :foreign_key => 'end_station_id'
  belongs_to :condition, :foreign_key => 'start_date'

  def self.average_trip_duration
    average(:duration)
  end

  def self.longest_ride
    maximum(:duration)
  end

  def self.shortest_ride
    minimum(:duration)
  end

  def self.most_starting_rides_station
    station_id = group(:start_station_id).count.sort.first
    require 'pry' ; binding.pry
    Station.find(station_id)
  end

  def self.most_ending_rides_station
    station_id = group(:end_station_id).count.max_by{|k, v| v}.first
    Station.find(station_id)
  end

  def self.most_ridden_bike
    # [[bike_id, # of rides], [bike_id, # of rides]]
    bikes = group(:bike_id).count
    bikes.find_all do |bike|
      bike[1] == bikes.values.max
    end
  end

  def self.least_ridden_bike
    # [[bike_id, # of rides], [bike_id, # of rides]]
    bikes = group(:bike_id).count
    bikes.find_all do |bike|
      bike[1] == bikes.values.min
    end
  end

  def self.user_count
    subscribers = group(:subscription_type).count
    total = subscribers.values.reduce(:+).to_f
    subscribers.each do |subscriber|
      subscribers[subscriber[0]] = [subscriber[1], percent(subscriber[1] / total)]
    end
  end

  def self.percent(num)
    (num * 100).round(2)
  end

  def self.number_of_rides_by_month(year)
    trips_per_month = Hash.new(0)
    trips_per_year = where("extract (year from start_date) = ?", year)
    trips_per_year.each do |e|  
      trips_per_month[e.start_date.month] += 1
    end
    [trips_per_year.count, trips_per_month]
  end

  def self.most_trips
    group(:start_date).count.max_by{|k, v| v}
  end

  def self.least_trips
    group(:start_date).count.min_by{|k, v| v}
  end

  def self.condition_on_day_with_most_rides
    most_date = group(:start_date).count.max_by{|k, v| v}.first.strftime('%Y-%m-%d')
    Condition.where(date: most_date)
  end

  def self.condition_on_day_with_least_rides
    least_date = group(:start_date).count.min_by{|k, v| v}.first.strftime('%Y-%m-%d')
    Condition.where(date: least_date)
  end
end