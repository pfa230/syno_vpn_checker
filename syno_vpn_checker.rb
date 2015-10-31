#!/usr/bin/ruby

require 'json'
require 'net/http'

PACKAGES = ['deluge', 'transmission']
EXPECTED_COUNTRY = 'Netherlands'

def update_status(vpn_active)
  PACKAGES.each do |pkg|
    cmd = "/var/packages/#{pkg}/scripts/start-stop-status"
    running = !(/is not running/ =~ `#{cmd} status`)

    if !running && vpn_active
      out = `#{cmd} start`
      `synodsmnotify @administrators 'VPN connected' 'Starting package #{pkg}: #{out}'`
    elsif running && !vpn_active
      out = `#{cmd} stop`
      `synodsmnotify @administrators 'VPN disconnected' 'Stopping package #{pkg}: #{out}'`
    end
  end
end

country = JSON.parse(Net::HTTP.get_response(URI.parse('http://ip-api.com/json')).body)['country']

update_status(country == EXPECTED_COUNTRY)
