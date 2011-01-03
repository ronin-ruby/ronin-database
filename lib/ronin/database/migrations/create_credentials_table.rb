#
# Ronin - A Ruby platform for exploit development and security research.
#
# Copyright (c) 2006-2010 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ronin/database/migrations/create_user_names_table'
require 'ronin/database/migrations/create_passwords_table'
require 'ronin/database/migrations/create_open_ports_table'
require 'ronin/database/migrations/create_urls_table'
require 'ronin/database/migrations/create_proxies_table'
require 'ronin/database/migrations/migrations'

module Ronin
  module Database
    module Migrations
      migration(
        :create_credentials_table,
        :needs => [
          :create_user_names_table,
          :create_passwords_table,
          :create_open_ports_table,
          :create_urls_table,
          :create_proxies_table
        ]
      ) do
        up do
          create_table :ronin_credentials do
            column :id, Serial
            column :user_name_id, Integer, :not_null => true
            column :password_id, Integer, :not_null => true

            column :open_port_id, Integer
            column :email_address_id, Integer
            column :url_id, Integer
            column :proxy_id, Integer
          end

          create_index :ronin_credentials,
                       :user_name_id, :password_id,
                       :open_port_id, :email_address_id, :url_id, :proxy_id,
                       :name => :unique_index_ronin_credentials,
                       :unique => true
        end

        down do
          drop_table :ronin_credentials
        end
      end
    end
  end
end
