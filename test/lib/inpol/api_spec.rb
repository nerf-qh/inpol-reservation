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
      assert_equal Inpol::Api::DEFAULT_HOST, 'https://inpol.mazowieckie.pl'
      assert_equal Inpol::Api::USER_AGENT, @user_agent


      assert_equal Inpol::Api::DEFAULT_HEADERS, { accept: '*/*', user_agent: @user_agent }
    end
  end

  describe 'auth' do
    it 'must assign token' do
      username = 'test@example.com'
      password = 'password1'
      auth_token = @api.auth(username, password)
      assert_equal auth_token, 'auth-token-123'
      assert_equal @api.auth_token, auth_token
    end
  end

  describe 'refresh' do
    before do
      @init_token = 'auth-token-123'
      @api.instance_variable_set('@auth_token', @init_token)
    end

    it 'change refresh token' do
      assert_equal @api.auth_token, @init_token
      auth_token = @api.refresh('case-123')
      assert_equal @api.auth_token, 'auth-token-234'
      assert_equal @api.auth_token, auth_token
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
      assert_equal dates.length, 28
      dates.each do |date|
        assert_kind_of Date, date
      end
    end
  end
end
