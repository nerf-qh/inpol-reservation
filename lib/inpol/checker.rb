# frozen_string_literal: true

module Inpol
  class Checker
    attr_reader :location_id, :username, :password, :start_date

    def call
      api = InpolApi.new(host)
      api.auth(username, password)
      dates = get_available_dates
      selected_dates = select_dates(dates)
      process_dates(selected_dates)
    end

    def fetch_available_dates
      counter = 1000
      loop do
        return nil if counter <= 0

        result = api.dates(location_id)
        return result.body if result.code == 200

        counter -= 1
      end
    end

    def select_dates
      dates.select { |date| date >= start_date }
    end

    def process_dates
      queue = Queue.new
      select_dates.each { |date| queue.push(date) }
      # threads = Array.new(select_dates.length) do
      #   Thread.new do
      #     until queue.empty?
      #       date = queue.shift

      #       check_date(date)
      #     end
      #   end
      # end
      # threads.push(
      #     Thread.new do
      #         slots_checker
      #     end
      # )

      threads.each { |th| th.join(2) }
    end

    def check_date(date)
      loop do
        result = api.slots(location_id, date)
        if result[:success]
          @available_slots[date] = result[:slots]
          return
        end
      end
    end

    def slots_checker; end

    private

    def initialize
      @host = ENV['HOST']
      @available_slots = {}

      @username = ENV['USERNAME']
      @password = ENV['PASSWD']

      @location_id = ENV['LOCATION_ID']
      @start_date = Date.parse(ENV['START_DATE'])

      # Reservation
      @name = ENV['NAME']
      @last_name = ENV['LAST_NAME']
      @date_of_birth = Time.parse(ENV['DATE_OF_BIRTH']).strftime('%FT%RZ')
      @case_id = ENV['CASE_ID']
    end
  end
end
