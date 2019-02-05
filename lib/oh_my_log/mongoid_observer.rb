module OhMyLog
  class MongoidObserver < ::Mongoid::Observer

    #this is the callback that happens every time after we made changes to the model
    def after_save(model)
      #we only add this model in the target list if this model got SUCCESSFULLY changed
      if (model.methods.include?(:saved_changes))
        Log::add_target(model) unless model.saved_changes.empty?
      else
        Log::add_target(model) unless model.changes.empty?
      end
    end
  end
end