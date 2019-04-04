require 'rails_helper'

RSpec.describe FoosController, type: :controller do
  let(:oml) {OhMyLog::Log}

  context "#When using a custom configuration for the Logger" do
    before(:all) do
      Rake::Task['oh_my_log:install'].invoke
      Foo.destroy_all
      Doo.destroy_all
      OhMyLog.start
    end
    #reset the configuration to the default state
    before(:each) do
      oml.reset
      oml.configure do |config|
        config.print_log = true
        selector = oml::Selector.universal_for(actions: {"EXCEPT" => ["index"]})
        config.add_selector(selector)
        OhMyLog::SyslogConfiguration.use("RFC3164")
        syslog = OhMyLog::SyslogImplementor.new(hostname: "Staging", priority: 101, tag: "BRAINT")
        config.syslog = syslog
      end
    end

    after(:all) do
      Rake::Task['oh_my_log:clean'].invoke
    end

    it "Should not log anything when the response is 200 and we put 200 in the status_codes blacklist" do
      oml.configuration.selectors[-1].set_status_codes("EXCEPT" => [(200..204)])
      put :create, params: {name: 'foo name'}
      expect(oml.last_recorded).to eq(nil)
    end
    it "Should log when the response is 200 and we put 200 in the white_list" do
      oml.configuration.selectors[-1].set_status_codes("ONLY" => [(200..204)])
      put :create, params: {name: 'foo name'}
      expect(oml.last_recorded).not_to eq(nil)
    end
    it "Should not log when we removing the FooController from the permitted controller list" do
      oml.configuration.selectors[-1].set_controllers({"ONLY" => ["Doo"]})
      put :create, params: {name: 'foo name'}
      expect(oml.last_recorded).to eq(nil)
    end
    it "Should log when including FooController in the permitted controller list" do
      oml.configuration.selectors[-1].set_controllers({"ONLY" => ["Foo"]})
      put :create, params: {name: 'foo name'}
      expect(oml.last_recorded).not_to eq(nil)
    end
    it "Should not log when using the create method and using a configuration to only log the index action" do
      oml.configuration.selectors[-1].set_actions("EXCEPT" => ["create"])
      put :create, params: {name: 'foo name'}
      expect(oml.last_recorded).to eq(nil)
    end
    it "Should log when rooting to index and using a configuration to only log the index action" do
      oml.configuration.selectors[-1].set_actions("ONLY" => ["index"])
      get :index
      expect(oml.last_recorded).not_to eq(nil)
    end
    ##non va perchè non si riesce a fare il monkeypatch di application controller dato ceh abbiamo il rails dei poveri
    it "Should not log when black listing the local ip" do
      oml.configuration.selectors[-1].set_ips("EXCEPT" => ["192.168.0.1"])
      put :create, params: {name: 'foo name'}
      expect(oml.last_recorded).to eq(nil)
    end
    it "Should be able to correctly use multiple selector" do
      selector = OhMyLog::Log::Selector.new
      selector.set_controllers({"EXCEPT" => ["Foo"]})
      oml.configuration.add_selector(selector)
      put :create, params: {name: 'foo name'}
      expect(oml.last_recorded).to eq(nil)
    end
  end

  context "When testing the event logger for a generic Model" do
    before(:all) do
      Foo.destroy_all
      Doo.destroy_all
      @dummy = Foo.create(name: "Dummy model", value: 2)
    end
    before(:each) do
      oml.reset
      oml.configure do |config|
        config.print_log = true
        selector = oml::Selector.universal_for(actions: {"EXCEPT" => ["index"]})
        config.add_selector(selector)
        OhMyLog::SyslogConfiguration.use("RFC3164")
        syslog = OhMyLog::SyslogImplementor.new(hostname: "Staging", priority: 101, tag: "BRAINT")
        config.syslog = syslog
      end
    end
    it "Should create a log in the path specified in teh configuration" do
      expect(File.file?(Rails.root + "log/oh_my_log.log")).to eq(true)
    end
    it "Should write a log when creating a Model" do
      put :create, params: {name: 'foo name'}
      expect(oml.last_recorded).not_to eq(nil)
    end
    it "Should write a log when changing an Model" do
      if Rails::VERSION::MAJOR >= 5
        put :update, params: {name: "dummy name", value: 99, id: @dummy.id}
      else
        put :update, {name: "dummy name", value: 99, id: @dummy.id}
      end
      expect(oml.last_recorded).not_to eq(nil)
    end

    it "The log created should have a receiver if the action made any changes to the model" do
      if Rails::VERSION::MAJOR >= 5
        put :update, params: {name: "not dummy name", value: 99, id: @dummy.id}
      else
        put :update, {name: "not dummy name", value: 99, id: @dummy.id}
      end
      expect(oml.last_recorded.effects[0].receiver).not_to eq(nil)
    end

    it "The action indicated by the log should math the action did by the controller " do
      put :create, params: {name: "nameless dummy"}
      expect(oml.last_recorded.request.params["action"]).to eq("create")
    end
  end
end