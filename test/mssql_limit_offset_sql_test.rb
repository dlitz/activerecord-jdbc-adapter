#! /usr/bin/env jruby

require 'active_record'
require 'arjdbc/mssql/adapter'
require 'test/unit'

# This tests ArJdbc::MsSQL#add_lock! without actually connecting to the database.
class LimitOffsetSqlTest < Test::Unit::TestCase

  def test_find_first
    # Note the "from" in the condition
    add_limit_offset_test 'FlowDetailAttribute.find(:first, :conditions => {:name => "hello"})',
      "SELECT * FROM flow_detail_attributes WHERE (flow_detail_attributes.[name] = N'hello')",
      "SELECT t.* FROM (SELECT ROW_NUMBER() OVER(ORDER BY flow_detail_attributes.id) AS _row_num, flow_detail_attributes.* FROM flow_detail_attributes WHERE (flow_detail_attributes.[name] = N'hello')) AS t WHERE t._row_num BETWEEN 1 AND 1"
  end

  def test_find_first_with_sql_keywords_in_conditions
    # Note the "from" in the condition
    add_limit_offset_test 'FlowDetailAttribute.find(:first, :conditions => {:name => "select from where"})',
      "SELECT * FROM flow_detail_attributes WHERE (flow_detail_attributes.[name] = N'select from where')",
      "SELECT t.* FROM (SELECT ROW_NUMBER() OVER(ORDER BY flow_detail_attributes.id) AS _row_num, flow_detail_attributes.* FROM flow_detail_attributes WHERE (flow_detail_attributes.[name] = N'select from where')) AS t WHERE t._row_num BETWEEN 1 AND 1"
  end

  private

    #class Dummy2000
    #  include ::ArJdbc::MsSQL
    #  include ::ArJdbc::MsSQL::LimitHelpers::SqlServer2000AddLimitOffset
    #end

    class Dummy
      include ::ArJdbc::MsSQL
      include ::ArJdbc::MsSQL::LimitHelpers::SqlServerAddLimitOffset

      def determine_primary_key(*)
        "id"
      end
    end

    def add_limit_offset!(sql, options={})
      result = sql.dup
      Dummy.new.add_limit_offset!(result, {:limit=>1}.merge(options))
      result
    end

    def add_limit_offset_test(message, before, after, options={})
      before = before.gsub(/\s*\n\s*/m, " ").strip
      after = after.gsub(/\s*\n\s*/m, " ").strip
      assert_equal after, add_limit_offset!(before, options).strip, message
    end
end
