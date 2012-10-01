# -*- coding: utf-8 -*-

# assuming these executables are in PATH.
# memo: 'spidermonkey' is a symlink to my local spidermonkey build.
JS_EXECUTABLES = %w[rhino spidermonkey]
COMMON_JS_EXECUTABLES = %w[node narwhal]

JS_TESTS = %w[js]
COMMON_JS_TESTS = %w[commonjs]

SAMPLE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', 'sample'))
def on_dir(name, &blk)
  Dir.chdir(File.join(SAMPLE_DIR, name)) do
    blk.call
  end
end


describe 'Engine Compatibility' do

  js_expected = <<-EOS
# module: math module
# test: add
ok 1
ok 2
ok 3 - passing 3 args
ok 4 - just one arg
ok 5 - no args
not ok 6 - expected: '7' got: '1'
not ok 7 - with message, expected: '7' got: '1'
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
# bar' got: 'foo
# bar'
not ok 16 - with\r
# multiline
# message, expected: 'foo
# bar' got: 'foo\r
# bar'
1..16
EOS

  JS_TESTS.product(JS_EXECUTABLES).each do |test, command|
    context "#{test} test on #{command}" do
      before do
        on_dir(test) do
          @output = `#{command} run_tests.js`
        end
      end
      subject { @output }
      it { should == js_expected }
    end
  end

  JS_TESTS.product(["./phantomjs_test.sh"]).each do |test, command|
    context "#{test} test on #{command}" do
      before do
        on_dir(test) do
          @output = `#{command}`
        end
      end
      subject { @output }
      it { should == js_expected }
    end
  end

  commonjs_math_expected = <<-EOS
# module: math module
# test: add
ok 1
ok 2
ok 3 - passing 3 args
ok 4 - just one arg
ok 5 - no args
not ok 6 - expected: '7' got: '1'
not ok 7 - with message, expected: '7' got: '1'
ok 8
ok 9 - with message
not ok 10
not ok 11 - with message
1..11
EOS

  commonjs_incr_expected = <<-EOS
# module: incr module
# test: increment
ok 1
ok 2
1..2
EOS

  commonjs_tap_compliance_expected = <<-EOS
# module: TAP spec compliance
# test: Diagnostic lines
ok 1 - with\r
# multiline
# message
not ok 2 - with\r
# multiline
# message, expected: 'foo\r
# bar' got: 'foo
# bar'
not ok 3 - with\r
# multiline
# message, expected: 'foo
# bar' got: 'foo\r
# bar'
1..3
EOS


  COMMON_JS_TESTS.product(COMMON_JS_EXECUTABLES).each do |test, command|
    context "#{test} test on #{command}" do
      context "math" do
        before do
          on_dir(test) do
            @output = `#{command} test/math_test.js`
          end
        end
        subject { @output }
        it { should == commonjs_math_expected }
      end
      context "incr" do
        before do
          on_dir(test) do
            @output = `#{command} test/incr_test.js`
          end
        end
        subject { @output }
        it { should == commonjs_incr_expected }
      end
      context "TAP spec compliance" do
        before do
          on_dir(test) do
            @output = `#{command} test/tap_compliance_test.js`
          end
        end
        subject { @output }
        it { should == commonjs_tap_compliance_expected }
      end
    end
  end

end
