module OhMyLog
  class MongoidObserver < ::Mongoid::Observer

    #this is the callback that happens every time after we made changes to the model
    def after_save(model)
      #we only add this model in the target list if this model got SUCCESSFULLY changed
      must_be_logged = model.methods.include?(:saved_changes) ? model.saved_changes.empty? : model.changes.empty?
      Log::add_target(model) unless must_be_logged
    end
  end
end