#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), "../../", "agent", "filemgr.rb")

module MCollective
  module Agent
    describe Filemgr do
      before do
        agent_file = File.join([File.dirname(__FILE__), "../../", "agent", "filemgr.rb"])
        @agent = MCollective::Test::LocalAgentTest.new("filemgr", :agent_file => agent_file).plugin
      end

      describe "#touch" do
        it "should touch the file when a name is supplied" do
          FileUtils.expects(:touch).with("/tmp/foo")
          @agent.call(:touch, :file => "/tmp/foo")
        end

        it "should touch the file specified in config" do
          pluginconf = mock
          pluginconf.stubs(:pluginconf).returns({"filemgr.touch_file" => "/tmp/foo2"})
          @agent.stubs(:config).returns(pluginconf)

          FileUtils.expects(:touch).with("/tmp/foo2")
          @agent.call(:touch, :file => nil)
        end

        it "should touch the default file if its neither supplied or in conf" do
          FileUtils.expects(:touch).with("/var/run/mcollective.plugin.filemgr.touch")
          @agent.call(:touch, :file => nil)
        end

        it "should reply with a failure message if the file cannot be touched" do
          FileUtils.expects(:touch).raises("error")
          result = @agent.call(:touch, :file => nil)
          result.should be_aborted_error
        end
      end

      describe "remove" do
        it "should not try to remove a file that isn't present" do
          File.expects(:exists?).with("/tmp/foo").returns(false)
          result = @agent.call(:remove, :file => "/tmp/foo")
          result.should be_aborted_error
        end

        it "should fail if it can't remove the file" do
          File.expects(:exists?).with("/tmp/foo").returns(true)
          FileUtils.expects(:rm).raises("error")
          result = @agent.call(:remove, :file => "/tmp/foo")
          result.should be_aborted_error
        end

        it "should remove a file" do
          File.expects(:exists?).with("/tmp/foo").returns(true)
          FileUtils.expects(:rm)
          result = @agent.call(:remove, :file => "/tmp/foo")
          result.should be_successful
        end
      end

      describe "status" do
        it "should fail if the file isn't present" do
          File.expects(:exists?).with("/tmp/foo").returns(false)
          result = @agent.call(:status, :file => "/tmp/foo")
          result.should be_aborted_error
        end

        it "should return the file status" do
          stat = mock

          File.expects(:exists?).with("/tmp/foo").returns(true)
          File.expects(:symlink?).returns(false)
          File.expects(:stat).with("/tmp/foo").returns(stat)
          File.stubs(:read).returns("")
          stat.expects(:size).returns(123)
          stat.expects(:mtime).returns(123).twice
          stat.expects(:ctime).returns(123).twice
          stat.expects(:atime).returns(123).twice
          stat.expects(:uid).returns(500)
          stat.expects(:gid).returns(500)
          stat.expects(:mode).returns(511)
          stat.stubs(:file?).returns(true)
          Digest::MD5.expects(:hexdigest).returns("AB12")
          stat.stubs(:directory?).returns(false)
          stat.stubs(:symlink?).returns(false)
          stat.stubs(:socket?).returns(false)
          stat.stubs(:chardev?).returns(false)
          stat.stubs(:blockdev?).returns(false)

          result = @agent.call(:status, :file => "/tmp/foo")
          result.should be_successful
          result.should have_data_items(:output => "present",
                                        :present => 1,
                                        :size => 123,
                                        :mtime => 123,
                                        :ctime => 123,
                                        :atime => 123,
                                        :uid => 500,
                                        :gid => 500,
                                        :mtime_seconds => 123,
                                        :ctime_seconds => 123,
                                        :atime_seconds => 123,
                                        :mode => "777",
                                        :md5 => "AB12",
                                        :type => "file")
        end
      end
    end
  end
end
