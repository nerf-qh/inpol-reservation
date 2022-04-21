# frozen_string_literal: true

module Inpol
  class Api
    attr_reader :host, :auth_token

    DEFAULT_HOST = 'https://inpol.mazowieckie.pl'
    USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) \
AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.88 Safari/537.36"
    DEFAULT_HEADERS = { accept: '*/*', user_agent: USER_AGENT }.freeze

    def auth(username, password)
      params = { email: username, password: password, expiryMinutes: 0 }
      h = headers(content_type: 'application/json', referer: 'https://inpol.mazowieckie.pl/login', origin: 'https://inpol.mazowieckie.pl')
      response = RestClient.post("#{host}/identity/sign-in", params.to_json, h)
      check_response_code!(response)

      @auth_token = response.body
    end

    def refresh(case_id)
      h = headers_with_auth(content_type: 'application/json', origin: 'https://inpol.mazowieckie.pl', referer: "https://inpol.mazowieckie.pl/home/cases/#{case_id}")
      response = RestClient.post("#{host}/identity/refresh?expiry=15", {}.to_json, h)
      check_response_code!(response)

      @auth_token = response.body
    end

    def dates(location_id)
      h = headers_with_auth
      response = RestClient.get("#{host}/api/reservations/queue/#{location_id}/dates", h)
      check_response_code!(response)

      result = JSON.parse(response.body)
      result.map { |date| Date.parse(date) }
    end

    def slots(location_id, date)
      h = headers_with_auth

      response = RestClient.get("#{host}/api/reservations/queue/#{location_id}/#{date}/slots", h)
      response.code == 200 ? { success: true, slots: response.body } : { success: false }
    end

    def reserve(location_id:, case_id:, slot_id:, name:, last_name:, date_of_birth:)
      params = { proceedingId: case_id, slotId: slot_id, name: name, lastName: last_name, dateOfBirth: date_of_birth }
      h = headers_with_auth
      response = RestClient.post("#{host}/api/reservations/queue/#{location_id}/reserve", params.to_json, h)
      response.code == 200
    end

    private

    def initialize(host = DEFAULT_HOST)
      @host = host
    end

    def headers(options = {})
      DEFAULT_HEADERS.merge(options)
    end

    def headers_with_auth(options = {})
      authorization = "Bearer #{auth_token}"
      headers(**options, authorization: authorization)
    end

    def check_response_code!(response, code = 200)
      raise StandardError, "Unable to process #{response.code}" if response.code != code
    end
  end
end
