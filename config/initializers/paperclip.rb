module Paperclip
  class HasAttachedFile
    def add_active_record_callbacks
      name = @name
      @klass.send(:after_save) { send(name).send(:save) }
      @klass.send(:before_destroy) { send(name).send(:queue_all_for_delete) }
      #@klass.send(:after_commit, :on => :destroy) { send(name).send(:flush_deletes) }

      if @klass.respond_to?(:after_commit)
        @klass.send(:after_commit, :on => :destroy) { send(name).send(:flush_deletes) }
      else
        @klass.send(:after_destroy) { send(name).send(:flush_deletes) }
      end
    end

  end
end
