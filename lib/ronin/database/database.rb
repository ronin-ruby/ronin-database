#
# Copyright (c) 2006-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin.
#
# Ronin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ronin.  If not, see <http://www.gnu.org/licenses/>.
#

require 'ronin/database/exceptions/invalid_config'
require 'ronin/database/exceptions/unknown_repository'
require 'ronin/database/migrations'
require 'ronin/config'

require 'addressable/uri'
require 'yaml'
require 'dm-core'

module Ronin
  #
  # Manages the {Database} configuration and the defined repositories.
  # Also provides a simple wrapper around DataMapper, for initializing,
  # auto-upgrading and querying {Database} repositories.
  #
  module Database
    # Database configuration file
    CONFIG_FILE = File.join(Config::PATH,'database.yml')

    # Database log file
    DEFAULT_LOG_PATH = File.join(Config::PATH,'database.log')

    # Database log level
    DEFAULT_LOG_LEVEL = :info

    # Default database repository
    DEFAULT_REPOSITORY = Addressable::URI.new(
      :scheme => 'sqlite3',
      :path => File.join(Config::PATH,'database.sqlite3')
    )

    @repositories = {}
    @log = nil

    #
    # Returns the Database repositories to use.
    #
    # @return [Hash{Symbol => Addressable::URI}]
    #   The database repository names and URIs.
    #
    # @raise [InvalidConfig]
    #   The config file did not contain a YAML Hash.
    #
    # @since 1.0.0
    #
    # @api private
    #
    def Database.repositories
      if @repositories.empty?
        @repositories[:default] = DEFAULT_REPOSITORY

        if File.file?(CONFIG_FILE)
          conf = YAML.load_file(CONFIG_FILE)

          unless conf.kind_of?(Hash)
            raise(InvalidConfig,"#{CONFIG_FILE} must contain a YAML Hash of repositories")
          end

          conf.each do |name,uri|
            @repositories[name.to_sym] = Addressable::URI.parse(uri)
          end
        end
      end

      return @repositories
    end

    #
    # Determines if the Database provides a specific repository.
    #
    # @param [String, Symbol] name
    #   Name of the repository.
    #
    # @return [Boolean]
    #   Specifies if the Database provides the repository.
    #
    # @since 1.0.0
    #
    # @api semipublic
    #
    def Database.repository?(name)
      repositories.has_key?(name.to_sym)
    end

    #
    # Saves the Database configuration to `CONFIG_FILE`.
    #
    # @yield []
    #   If a block is given, it will be called before the database
    #   configuration is saved.
    #
    # @return [true]
    #
    # @since 1.0.0
    #
    # @api private
    #
    def Database.save
      yield if block_given?

      File.open(CONFIG_FILE,'w') do |file|
        hash = {}
        
        repositories.each do |name,value|
          hash[name.to_s] = value.to_s
        end

        YAML.dump(hash,file)
      end

      return true
    end

    #
    # Setup the Database log.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [String] :path (DEFAULT_LOG_PATH)
    #   The path of the log file.
    #
    # @option options [IO] :stream
    #   The stream to use for the log.
    #
    # @option options [Symbol] :level
    #   The level of messages to log.
    #   May be either `:fatal`, `:error`, `:warn`, `:info` or `:debug`.
    #
    # @return [true]
    #   Specifies that the log has been setup.
    #
    # @api private
    #
    def Database.setup_log(options={})
      path = options.fetch(:path,DEFAULT_LOG_PATH)
      stream = options.fetch(:stream,File.new(path,'w+'))
      level = options.fetch(:level,DEFAULT_LOG_LEVEL)

      @log = DataMapper::Logger.new(stream,level)
      return true
    end

    #
    # Determines if a specific database repository is setup.
    #
    # @param [Symbol] name
    #   The database repository name.
    #
    # @return [Boolean]
    #   Specifies wether or not the Database is setup.
    #
    # @api semipublic
    #
    def Database.setup?(name=:default)
      repository = DataMapper.repository(name)

      return repository.class.adapters.has_key?(repository.name)
    end

    #
    # Upgrades the Database, by running migrations for a given
    # ronin library, but only if the Database has been setup.
    #
    # @return [Boolean]
    #   Specifies whether the Database was migrated or is currently
    #   not setup.
    #
    # @api semipublic
    #
    def Database.upgrade!
      if setup?
        Migrations.migrate_up!
      else
        false
      end
    end

    #
    # Sets up the Database.
    #
    # @see Database.upgrade!
    #
    # @api semipublic
    #
    def Database.setup
      # setup the database log
      unless @log
        if ENV['DEBUG']
          setup_log(:stream => STDERR, :level => :debug)
        else
          setup_log
        end
      end

      # setup the database repositories
      repositories.each do |name,uri|
        DataMapper.setup(name,uri)
      end

      # apply any new migrations to the database
      upgrade!
    end

    #
    # Performs Database transactions within a given repository.
    #
    # @param [String, Symbol] name
    #   The name of the repository to access.
    #
    # @return [DataMapper::Repository]
    #   The Database repository.
    #
    # @raise [UnknownRepository]
    #   The specified Database repository is unknown.
    #
    # @since 1.0.0
    #
    # @api public
    #
    def Database.repository(name,&block)
      name = name.to_sym

      unless repository?(name)
        raise(UnknownRepository,"unknown database repository #{name}")
      end

      return DataMapper.repository(name,&block)
    end

    #
    # Clears the Database, by running destructive auto-migrations.
    #
    # @param [String, Symbol] name
    #   The name of the Database repository to clear.
    #
    # @yield []
    #   If a block is given, it will be called after the Database
    #   repository has been cleared.
    #
    # @return [nil]
    #
    # @raise [UnknownRepository]
    #   The specified Database repository is unknown.
    #
    # @since 1.0.0
    #
    # @api private
    #
    def Database.clear(name)
      name = name.to_sym

      unless repository?(name)
        raise(UnknownRepository,"unknown database repository #{name}")
      end

      DataMapper.auto_migrate!(name)

      yield if block_given?
      return nil
    end

    #
    # Performs Database transactions in each of the Database
    # repositories.
    #
    # @yield []
    #   The given block will be ran within the context of each Database
    #   repository.
    #
    # @return [Array]
    #   The results from each database transaction.
    #
    # @since 1.0.0
    #
    # @api public
    #
    def Database.map
      results = []

      repositories.each_key do |name|
        DataMapper.repository(name) do
          result = yield
          results << result unless result.nil?
        end
      end

      return results
    end
  end
end
