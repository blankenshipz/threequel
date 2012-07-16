module Threequel
  module Commandant
    class SQLCommand

      attr_reader :sql, :name

      def initialize(sql, name = 'Anonymous', opts = {})
        @sql, @name = sql, name
        @log_to_db = opts.delete(:log_to_db) || false
      end

      def sanitized_sql
        Threequel::SQLUtils.sanitize_sql(@sql)
      end

      def statements
        @statements ||= sanitized_sql.map.with_index do |statement, i|
          SQLStatement.new(statement, "#{@name}[statement#{i}]", @name).tap do |s|
            s.extend(Logging) if @log_to_db
          end
        end
      end

      def execute_on(connection)
        puts "-- Starting SQL Execution for: #{@name} at #{Time.now}"
        statements.each{|statement| statement.execute_on connection}
        puts "-- Finishing SQL Execution for: #{@name} at #{Time.now}\n"
      end

      def formatted_sql
        "#{@sql}\nGO\n\n"
      end

    end    

  end
end
