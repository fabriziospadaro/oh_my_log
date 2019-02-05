namespace :oh_my_log do
  desc "Generate the observers for each ActiveRecord model"
#in futuro fare che puoi passare parametri e in base a quello limita gli observer da generare
  task generate_observers: :environment do
    raise "Cannot create observers without an initializer, did you created it with 'oh_my_log:generate_initializer'" unless File.file?(Rails.root + "config/initializers/oh_my_log_initializer.rb")
    OhMyLog::ObserverFactory::generate_collection
  end
  desc "Generate a template initializer for OhMyLog"
#in futuro puoi passare direttamente qui alcune impostazioni dell' initialize
  task generate_initializer: :environment do
    #ARGV.each { |a| task a.to_sym do ; end }
    #binding.pry
    raise "The initializer has been already generated!" if File.file?(Rails.root + "config/initializers/oh_my_log_initializer")
    OhMyLog::generate_initializer
  end
end