# frozen_string_literal: true

require 'active_record'
require 'rails-observers'
require 'rails/observers/activerecord/base'
module ActiveRecord
  autoload :Observer, 'rails/observers/activerecord/observer'
end
require_relative "../active_record_observer"

