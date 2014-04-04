# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../../spec_helper'
require 'logger'
require 'stringio'

require 'kitchen'

describe Kitchen::Driver::Base do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:state)         { Hash.new }

  let(:busser) do
    stub(:setup_cmd => "setup", :sync_cmd => "sync", :run_cmd => "run")
  end

  let(:instance) do
    stub(
      :name => "coolbeans",
      :logger => logger,
      :busser => busser,
      :to_str => "instance"
    )
  end

  let(:driver) do
    Kitchen::Driver::Base.new(config).finalize_config!(instance)
  end

  it "#instance returns its instance" do
    driver.instance.must_equal instance
  end

  it "#name returns the name of the driver" do
    driver.name.must_equal "Base"
  end

  describe "#logger" do

    before  { @klog = Kitchen.logger }
    after   { Kitchen.logger = @klog }

    it "returns the instance's logger if defined" do
      driver.send(:logger).must_equal logger
    end

    it "returns the default logger if instance's logger is not set" do
      driver = Kitchen::Driver::Base.new(config)
      Kitchen.logger = "yep"

      driver.send(:logger).must_equal Kitchen.logger
    end
  end

  it "#puts calls logger.info" do
    driver.send(:puts, "yo")

    logged_output.string.must_match /I, /
    logged_output.string.must_match /yo\n/
  end

  it "#print calls logger.info" do
    driver.send(:print, "yo")

    logged_output.string.must_match /I, /
    logged_output.string.must_match /yo\n/
  end

  [:create, :converge, :setup, :verify, :destroy].each do |action|

    it "has a #{action} method that takes state" do
      state = Hash.new
      driver.public_send(action, state).must_be_nil
    end
  end

  it "has a login command that raises ActionFailed by default" do
    proc { driver.login_command(Hash.new) }.must_raise Kitchen::ActionFailed
  end

  it "has a default verify dependencies method" do
    driver.verify_dependencies.must_be_nil
  end

  it "#busser returns the instance's busser" do
    driver.send(:busser).must_equal busser
  end

  it "#busser_setup_cmd calls busser.setup_cmd" do
    driver.send(:busser_setup_cmd).must_equal "setup"
  end

  it "#busser_sync_cmd calls busser.sync_cmd" do
    driver.send(:busser_sync_cmd).must_equal "sync"
  end

  it "#busser_run_cmd calls busser.run_cmd" do
    driver.send(:busser_run_cmd).must_equal "run"
  end
end