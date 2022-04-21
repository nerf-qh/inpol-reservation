# frozen_string_literal: true

require 'test_helper'

describe Inpol::Api, vcr: { match_requests_on: %i[host path body headers] } do
  before do
    @api = Inpol::Api.new
  end

  describe 'consts' do
    before do
      @user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) \
Chrome/100.0.4896.88 Safari/537.36"
    end
    it 'assign default constants' do
      assert_equal 'https://inpol.mazowieckie.pl', Inpol::Api::DEFAULT_HOST
      assert_equal @user_agent, Inpol::Api::USER_AGENT

      assert_equal ({ accept: '*/*', user_agent: @user_agent }), Inpol::Api::DEFAULT_HEADERS
    end
  end

  describe 'auth' do
    it 'must assign token' do
      username = 'test@example.com'
      password = 'password1'
      auth_token = @api.auth(username, password)
      assert_equal 'auth-token-123', auth_token
      assert_equal auth_token, @api.auth_token
    end
  end

  describe 'refresh' do
    before do
      @init_token = 'auth-token-123'
      @api.instance_variable_set('@auth_token', @init_token)
    end

    it 'change refresh token' do
      assert_equal @init_token, @api.auth_token
      auth_token = @api.refresh('case-123')
      assert_equal 'auth-token-234', @api.auth_token
      assert_equal auth_token, @api.auth_token
    end
  end

  describe 'dates' do
    before do
      @init_token = 'auth-token-123'
      @location_id = '3ab99932-8e53-4dff-9abf-45b8c6286a99'
      @api.instance_variable_set('@auth_token', @init_token)
    end

    it 'load dates' do
      dates = @api.dates(@location_id)
      assert_equal 28, dates.length
      dates.each do |date|
        assert_kind_of Date, date
      end
    end
  end

  describe 'slots' do
    before do
      @init_token = 'auth-token-123'
      @api.instance_variable_set('@auth_token', @init_token)
      @location_id = '3ab99932-8e53-4dff-9abf-45b8c6286a99'
      @date = '2022-05-19'
    end

    describe 'when empty' do
      it 'returns empty dates' do
        result = @api.slots(@location_id, @date)
        assert_equal true, result[:success]
        assert_equal [], result[:slots]
      end
    end

    describe 'when there are some slots' do
      it 'returns slots' do
        result = @api.slots(@location_id, @date)
        assert_equal true, result[:success]
        assert_equal 12, result[:slots].length
        assert_equal ({ 'id' => 12_960_377, 'date' => '2022-05-19T08:35:00', 'count' => 10 }), result[:slots][0]
        result[:slots].each do |slot|
          assert_equal %w[id date count], slot.keys
        end
      end
    end
  end

  describe 'reserve' do
    before do
      @init_token = 'auth-token-123'
      @api.instance_variable_set('@auth_token', @init_token)
      @location_id = '3ab99932-8e53-4dff-9abf-45b8c6286a99'
      @date = '2022-05-19'
      @case_id = 'D92155F8-FA08-4BF3-A671-0B0164A8E7A0'
      @slot_id = 12_960_386
      @name = 'Stafaniya'
      @last_name = 'Krautsova'
      @date_of_birth = '2019-12-17'
    end

    it 'reserves' do
      result = @api.reserve(location_id: @location_id, case_id: @case_id, slot_id: @slot_id, name: @name,
                            last_name: @last_name, date_of_birth: @date_of_birth)
      assert_equal 'bd243d39-d060-4240-a5d2-ed5d85315e61', result
    end
  end
end
