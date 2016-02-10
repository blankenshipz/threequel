require 'hirb'
require 'threequel/executioner/script'
require 'threequel/executioner/sorter'
require 'threequel/executioner/config_loader'

module Threequel
  class Executioner
    def self.execute_folder(folder_path)
      self.new.execute_folder folder_path
    end

    def self.execute(file_path)
      self.new.execute file_path
    end

    def self.execute_folders(folders)
      self.new.execute_folders folders
    end

    def connection
      ActiveRecord::Base.connection_pool.checkout
    end

    def execute(path)
      script             = Script.new(path)
      current_connection = connection

      command = SQL::Command.new(script.code, path, {}) do |config|
        config.extend(Threequel::Logging)
        config.add_logging_to :execute_on, :db, :console
      end

      command.execute_on(current_connection)

      current_connection.reconnect!

      ActiveRecord::Base.connection_pool.checkin(current_connection)
    end

    def execute_folder(folder_path, opts = {})
      exceptions = opts.delete(:except)
      (ConfigLoader.new(folder_path).tsorted_scripts - [exceptions].flatten).each do |script|
        execute File.join(folder_path, script)
      end
    end

    def execute_folders(folders)
      folders.each do |folder|
        begin
          execute_folder(folder)
        rescue Exception => ex
          puts ex.message
          puts ex.backtrace.join("\n")
        end
      end
    end
  end
end
