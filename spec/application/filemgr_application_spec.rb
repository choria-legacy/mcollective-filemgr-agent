#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'application', 'filemgr.rb')

module MCollective
  class Application
    describe Filemgr do
      before do
        application_file = File.join(File.dirname(__FILE__), '../../', 'application', 'filemgr.rb')
        @app = MCollective::Test::ApplicationTest.new('filemgr', :application_file => application_file).plugin
      end

      describe '#application_description' do
        it 'should have a description' do
          @app.should have_a_description
        end
      end

      describe '#validate_configuration' do
        it 'should default to touch unless a command has been supplied' do
          @app.validate_configuration(@app.configuration)
          @app.configuration[:command].should == 'touch'
        end

        it 'should not default to touch if a command has been supplied' do
          @app.configuration[:command] = 'remove'
          @app.validate_configuration(@app.configuration)
          @app.configuration[:command].should == 'remove'
        end
      end

      describe '#main' do
        let(:rpcclient) { mock }

        before do
          @app.stubs(:rpcclient).returns(rpcclient)
          rpcclient.stubs(:disconnect)
          rpcclient.stubs(:stats).returns({})
          @app.stubs(:halt)
          @app.stubs(:printrpcstats)
        end

        it 'should call and print the results of remove' do
          @app.configuration[:command] = 'remove'
          rpcclient.expects(:remove)
          @app.expects(:printrpc)
          @app.main
        end

        it 'should call and print the results of touch' do
          @app.configuration[:command] = 'touch'
          rpcclient.expects(:touch)
          @app.expects(:printrpc)
          @app.main
        end

        it 'should call and print the results of status if details is configured' do
          @app.configuration[:command] = 'status'
          @app.configuration[:details] = true
          rpcclient.expects(:status)
          @app.expects(:printrpc)
          @app.main
        end

        it 'should call and print the results of status if details is not configured' do
          @app.configuration[:command] = 'status'
          @app.configuration[:details] = false
          rpcclient.expects(:status).returns([{:sender => 'rspec', :data => {:output => 'ok'}}])
          @app.expects(:printf).with("%-40s: %s\n", 'rspec', 'ok')
          @app.main
        end

        it 'should fail on an invalid command' do
          @app.configuration[:command] = 'rspec'
          expect{
            @app.main
          }.to raise_error
        end
      end
    end
  end
end
