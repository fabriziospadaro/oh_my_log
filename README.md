# OhMyLog

[![Build Status](https://travis-ci.com/fabriziospadaro/oh_my_log.svg?branch=master)](https://travis-ci.com/fabriziospadaro/oh_my_log)[![Coverage Status](https://coveralls.io/repos/github/fabriziospadaro/oh_my_log/badge.svg?branch=master)](https://coveralls.io/github/fabriziospadaro/oh_my_log?branch=master)[![Maintainability](https://api.codeclimate.com/v1/badges/adf9807d95dab0112f0c/maintainability)](https://codeclimate.com/github/fabriziospadaro/oh_my_log/maintainability)

![N|Solid](https://i.ibb.co/WgCY6WX/oh-my-log-logo-256x270.png)
 
##### Oh my log is a powerful auditing system gem that tracks each changes on a model without being intrusive at all
___
### Dependecy
* Rails
* ActiveRecord or MongoId
### How to use:
* 1- Include this gem in your gemfile:

```sh
gem 'oh_my_log'
```

* 2- Install the gem following rake task:

```sh
bundle exec rake oh_my_log:install
```

This rake task will generate a simple initializer that you can later change:

```sh
OhMyLog::Log.configure do |config|
  OhMyLog::Log.configure do |config|
    config.print_log = true
    selector = OhMyLog::Log::Selector.universal_for(actions: {"EXCEPT" =>["index"]})
    #selector.set_status_codes("ONLY" =>[(0..200)])
    config.add_selector(selector)
    OhMyLog.start if File.directory?(Rails.root + "app/models/observers/oh_my_log")
    #put your configs here
  end
end
```

and a collection of observes based on the first initializer configuration that you can find under app/models/observers/oh_my_log.

If you made any changes to the initializer you can REBUILD the observers list using the following task.

**This will destroy all the files inside app/models/observers/oh_my_log and recreate them**

```sh
bundle exec rake oh_my_log:generate_observers
```

 ---
#### Configuration Class

###### Instance variables:

>models Hash(the key is the rule: ONLY/EXCEPT/ALL the value is an array of models' name)

>print_log bool (print the results on the console)

>record_history bool (keep track of all the activity recorded by OML)

>log_instance File (instance of the file where you want to store the recorded activities)

>log_path string (path of the file where you want to store the recorded activities)

>selectors Selector[] (instance list of all the selectors)

###### Instance methods:

>add_selector(selector ->Selector) (use this to add a new selector inside the configuration,
you need to pass an instance of the Selector class)

----

#### Selector Class

When using multiple selectors remember that if any of the conditions among all selectors fails the logger will not register

###### Instance variables:

>[read only] controllers Hash(the key is the rule: ONLY/EXCEPT/ALL the value is an array of Controller Names)

>[read only] actions Hash(the key is the rule: ONLY/EXCEPT/ALL the value is an array of actions)

>[read only] ips Hash(the key is the rule: ONLY/EXCEPT/ALL the value is an array of ips)

>[read only] status_codes Hash(the key is the rule: ONLY/EXCEPT/ALL the value is an array of status codes)

###### Instance methods:

>set_controllers (controller ->Hash{string =>string[]})

>set_actions (actions ->Hash{string =>string[]})

>set_ips (ips ->Hash{string =>string[]})

>set_status_codes (status_codes ->Hash{string =>Range[]})

###### Class methods:

>universal_for(action: {"ALL" =>[]}, controllers: {"ALL" =>[]}) (inside the hash only or
except you can put an array of actions)

Complex initializer example:

```sh
OhMyLog::Log.configure do |config|
  config.print_log = true
  selector = OhMyLog::Log::Selector.new
  selector.set_controllers("EXCEPT" =>["ApplicationController"])
  selector.set_actions("ONLY" =>["index","create","destroy"])
  selector.set_status_codes("ONLY" =>[(0..200)])
  selector.set_ips("EXCEPT"=>["192.168.0.1"])
  config.add_selector(selector)
  #put your configs here
end
```

---

#### OhMyLog::Log Module

###### Module variables:

>targets Model[] (list of all models affected by the current action)

>configuration Configuration (configuration for the Log)

>history Result[] (history of all the results occurred during a session)

>last_recorded Result (result produced by the last loggable action)

###### Module methods:

>configure(&block) (use configure method to pass a configuration block)

>clear (clear the history)

>flush (get rid of all the cached data(targets) stored in the Log)

#### OhMyLog::Log::Result Class

###### Instance variables:

>effects Effect[] (list of effects that an action has caused)

>request Request (request done by the user)

>flush (get rid of all the cached data(targets) stored in the Log)

---

#### OhMyLog::Log::Request Class

###### Instance variables:

>sender string(who did the action, if you are logged with devise it will be the email of the logged user, else it will be the ip wich the request came from)

>date Time (when did the action occured in UTC)

>params string (headers of the rails request)

>method string (method of the request: GET/HEAD/POST/PATCH/PUT/DELETE)

>status int (status code of the request) 

---

#### OhMyLog::Log::Effect Class

###### Instance variables:

>receiver Model (instance of the model that got affected by the action) 

>changes string (changes that this model had before and after the action)

---
 
### Development 

Developed by Fabrizio Spadaro 

### License:
MIT
 
**Free Software, Hell Yeah!**