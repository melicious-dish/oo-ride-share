require 'csv'
require 'time'
require 'pry'
require_relative 'user'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(user_file = 'support/users.csv',
                   trip_file = 'support/trips.csv',
                   driver_file = 'support/drivers.csv')
      @passengers = load_users(user_file)
      @drivers = load_drivers(driver_file)
      @trips = load_trips(trip_file)
    end

    def load_users(filename)
      users = []

      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        users << User.new(input_data)
      end

      return users
    end


    def load_trips(filename)
      trips = []
      trip_data = CSV.open(filename, 'r', headers: true,
                                          header_converters: :symbol)

      trip_data.each do |raw_trip|

        passenger = find_passenger(raw_trip[:passenger_id].to_i)
        driver = find_driver(raw_trip[:driver_id].to_i)


        start_time = Time.parse(raw_trip[:start_time])
        end_time = Time.parse(raw_trip[:end_time])

        # in trips ID = Driver ID
        parsed_trip = {
          id: raw_trip[:id].to_i, #trip ID
          passenger: passenger, #passenger ID
          start_time: start_time,
          end_time: end_time,
          cost: raw_trip[:cost].to_f,
          rating: raw_trip[:rating].to_i,
          driver: driver
        }
        # adding passenger from user.rb to into trip
        trip = Trip.new(parsed_trip)
        passenger.add_trip(trip)
        driver.add_trip(trip)
        driver.add_trip(trip)
        trips << trip

      end
      return trips
    end

    def load_drivers(filename)

      drivers = []

      driver_data = CSV.open(filename, 'r', headers: true,
        header_converters: :symbol)

        driver_data.each do |raw_driver|

          driver_name = find_passenger(raw_driver[:id].to_i).name
          driver_phone = find_passenger(raw_driver[:id].to_i).phone_number

          parsed_trip = {
            id: raw_driver[:id].to_i, #trip ID
            vin: raw_driver[:vin],
            status: raw_driver[:status].to_sym,
            name: driver_name.to_s,
            phone: driver_phone

          }


          drivers << Driver.new(parsed_trip)
      # binding.pry
      #     # find them and replace the `User` object with a `Driver` object. You should also be loading the `driven_tripss` for each `Driver` at this stage.
      #     # driver = @passengers.find do |user|
      #     #   user == driver
      #
          end
      #     # add to drivers array
      #     # passenger.add_driver(driver)
      #     binding.pry
      #
      #     drivers << driver
      #     # end
      #   end
        return drivers

      end

      def find_driver(id)
        check_id(id)
        return @drivers.find { |driver| driver.id == id }
      end

      def find_passenger(id)
        check_id(id)
        return @passengers.find { |passenger| passenger.id == id }
      end




    def inspect
      return "#<#{self.class.name}:0x#{self.object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    # private

    def check_id(id)
      raise ArgumentError, "ID cannot be blank or less than zero. (got #{id})" if id.nil? || id <= 0
    end
  end
end
