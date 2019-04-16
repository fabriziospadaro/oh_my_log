OhMyLog::Log.configure do |config|
  config.print_log = true
  selector = OhMyLog::Log::Selector.universal_for(actions: {"EXCEPT" => ["index"]})
  config.add_selector(selector)
end
OhMyLog.start
