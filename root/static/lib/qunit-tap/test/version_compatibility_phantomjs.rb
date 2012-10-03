# -*- coding: utf-8 -*-
require 'fileutils'
require 'rubygems'
require 'versionomy'

describe 'QUnit Version Compatibility' do

  latest_output_format = <<-EOS
# module: math module
# test: add
ok 1
ok 2
ok 3 - passing 3 args
ok 4 - just one arg
ok 5 - no args
not ok 6 - expected: '7', got: '1', test: add, module: math module
not ok 7 - with message, expected: '7', got: '1', test: add, module: math module
ok 8
ok 9 - with message
not ok 10 - test: add, module: math module
not ok 11 - with message, test: add, module: math module
# module: incr module
# test: increment
ok 12
ok 13
# module: TAP spec compliance
# test: Diagnostic lines
ok 14 - with\r
# multiline
# message
not ok 15 - with\r
# multiline
# message, expected: 'foo\r
# bar', got: 'foo
# bar', test: Diagnostic lines, module: TAP spec compliance
not ok 16 - with\r
# multiline
# message, expected: 'foo
# bar', got: 'foo\r
# bar', test: Diagnostic lines, module: TAP spec compliance
1..16
EOS

  output_from_1_0_0_to_1_9_0 = <<-EOS
# module: math module
# test: add
ok 1
ok 2
ok 3 - passing 3 args
ok 4 - just one arg
ok 5 - no args
not ok 6 - expected: '7', got: '1'
not ok 7 - with message, expected: '7', got: '1'
ok 8
ok 9 - with message
not ok 10
not ok 11 - with message
# module: incr module
# test: increment
ok 12
ok 13
# module: TAP spec compliance
# test: Diagnostic lines
ok 14 - with\r
# multiline
# message
not ok 15 - with\r
# multiline
# message, expected: 'foo\r
# bar', got: 'foo
# bar'
not ok 16 - with\r
# multiline
# message, expected: 'foo
# bar', got: 'foo\r
# bar'
1..16
EOS

  pretty_old_output = <<-EOS
# module: math module
# test: add
ok 1 - okay: 5
ok 2 - okay: -1
ok 3 - passing 3 args: 8
ok 4 - just one arg: 2
ok 5 - no args: 0
not ok 6 - failed, expected: 7 result: 1
not ok 7 - with message, expected: 7 result: 1
ok 8
ok 9 - with message
not ok 10
not ok 11 - with message
# module: incr module
# test: increment
ok 12 - okay: 2
ok 13 - okay: -2
# module: TAP spec compliance
# test: Diagnostic lines
ok 14 - with\r
# multiline
# message
not ok 15 - with\r
# multiline
# message, expected: "foo\r
# bar" result: "foo
# bar"
not ok 16 - with\r
# multiline
# message, expected: "foo
# bar" result: "foo\r
# bar"
1..16
EOS

  SUITE_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'compatibility'))
  VERSIONS = Dir.glob("#{SUITE_DIR}/*").map{|d| d.split('/').last}.sort.freeze
  QUNIT_RUNNER = File.expand_path(File.join(File.dirname(__FILE__), '..', 'sample', 'js', 'run_qunit.js'))
  SUITE_FILE_NAME = 'test_compat.html'
  SUITE_FILE = "#{File.dirname(__FILE__)}/phantomjs/#{SUITE_FILE_NAME}"
  HEAD_VERSION_TEST_DIR = "#{SUITE_DIR}/current"

  def self.lessThan(base, version)
    begin
      return Versionomy.parse(version) < Versionomy.parse(base)
    rescue Versionomy::Errors::ParseError => e
    end
    true
  end

  before(:all) do
    FileUtils::mkdir_p HEAD_VERSION_TEST_DIR
    FileUtils::cp SUITE_FILE, HEAD_VERSION_TEST_DIR
    FileUtils::cp "#{File.dirname(__FILE__)}/../test/compatibility/stable/qunit.js", HEAD_VERSION_TEST_DIR
  end
  after(:all) do
    FileUtils::rm_rf HEAD_VERSION_TEST_DIR
  end

  VERSIONS.each do |version|
    context "compatibility test upon #{version}" do
      before do
        unless File.exist? "#{SUITE_DIR}/#{version}/#{SUITE_FILE_NAME}"
          FileUtils::cp SUITE_FILE, "#{SUITE_DIR}/#{version}"
        end
      end
      after do
        FileUtils::rm "#{SUITE_DIR}/#{version}/#{SUITE_FILE_NAME}"
      end
      let(:output) { `phantomjs #{QUNIT_RUNNER} file://#{SUITE_DIR}/#{version}/#{SUITE_FILE_NAME}` }

      case
      when version == "001_two_args"
        it { output.should == pretty_old_output }
      when version == "stable"
        it { output.should == latest_output_format }
      when lessThan('1.10.0', version)
        it { output.should == output_from_1_0_0_to_1_9_0 }
      else
        it { output.should == latest_output_format }
      end
    end
  end

end
