#!/usr/bin/env ruby
# coding: utf-8

require 'sinatra'
require 'faraday'
require 'json'
require 'pp'

class Grl
  attr_accessor :data
  attr_accessor :res

  def initialize
    @data = []
  end

  def request_release_data username: , repository: 
    uri = 'https://api.github.com/'
    conn = Faraday::Connection.new(:url => uri) do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Adapter::NetHttp
    end
    @res = conn.get "/repos/#{username}/#{repository}/releases/latest"
  end

  def build_response
    assets = JSON.parse(@res.body, {:symbolize_names => true})[:assets]
    assets.each do |asset|
      @data << asset[:browser_download_url]
    end
  end

end

get '/:username/:repository' do
  grl = Grl.new
  grl.request_release_data username: params[:username], repository: params[:repository]
  grl.build_response if grl.res.status == 200
  return grl.data.to_json
end

not_found do
  'Not found.'
end
