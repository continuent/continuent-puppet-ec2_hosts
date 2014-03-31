# Copyright (C) 2014 Continuent, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.  You may obtain
# a copy of the License at
# 
#         http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

module Puppet::Parser::Functions
  newfunction(:getEC2Hosts, :type => :rvalue) do |args|
    tag_group = Marshal.load(args[0])
    include_short_hostname = args[1]
    if include_short_hostname == nil
      include_short_hostname = false
    end
    
    # Create a regex to match the local region
    az = Facter.value('ec2_placement_availability_zone')
    azre = Regexp.compile("#{az[0,az.length-1]}.*")
    
    hosts = {}
    tag_group.each{|id,details|
      hostname = details['tags']['Name']
      aliases = []
      if include_short_hostname == true
        hostname_parts = hostname.split(".")
        if hostname_parts[0] != hostname
          aliases << hostname_parts[0]
        end
      end
      
      # If this host is in the local region, use its private address
      if azre.match(details['az']) != nil
        ip = details['private-address']
      else
        ip = details['public-address']
      end
      hosts[hostname] = {
        "ip" => ip,
        "host_aliases" => aliases,
        "comment" => "Generated by ec2_hosts in #{details['region']}"
      }
    }
    hosts
  end
end