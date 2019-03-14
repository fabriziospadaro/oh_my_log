OhMyLog::Log.configure do |config|
  config.print_log = true
  selector = OhMyLog::Log::Selector.universal_for(actions: {"EXCEPT" => ["index"]})
  #selector.set_status_codes("ONLY" => [(0..200)])
  config.add_selector(selector)
  OhMyLog.start if File.directory?(Rails.root + "app/models/observers/oh_my_log")
  #put your configs here
end