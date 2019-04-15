# frozen_string_literal: true

require "oh_my_log/orm/#{OHMYLOG_ORM}"

if OHMYLOG_ORM == :active_record
  MIGRATION_CLASS =
      if Rails.gem_version >= Gem::Version.new('5.0')
        ActiveRecord::Migration[Rails.version.to_f]
      else
        ActiveRecord::Migration
      end
end
