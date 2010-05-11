module ActiveRecord
  module DraftRecords
    def self.included(klass)
      klass.extend(ClassMethods)
      # Define default_scope to not include drafts
      klass.send(:default_scope, :conditions => {:draft => false})
    end
    
    module ClassMethods
      # Same as ActiveRecord::Base#create, but sets the record as a draft and save
      # ignoring validations.
      def create_as_draft(attributes = {}, &block)
        if attributes.is_a?(Array)
           attributes.collect { |attr| create_as_draft(attr, &block) }
         else
           object = new(attributes)
           yield(object) if block_given?
           object.save_as_draft
           object
         end
      end
      
      # Attempt to create the record, if it fails, save it as a draft
      def create_or_draft(attributes = {}, &block)
        if attributes.is_a?(Array)
           attributes.collect { |attr| create_as_draft(attr, &block) }
         else
           object = new(attributes)
           yield(object) if block_given?
           object.save_or_draft
           object
         end        
      end
      
      # Returns a ActiveRecord::Scope that fetchs all the drafts
      def find_drafts(*args)
        with_exclusive_scope { self.scoped(:conditions => {:draft => true}).find(*args) }
      end
    end
    
    # Save the record as a draft, setting the record attribute 'draft' to true
    # and saving the record ignoring the validations.
    def save_as_draft
      self.draft = true
      save(false)
    end
    
    # Attempt to save the record, if any validation fails, save it as a draft.
    def save_or_draft
      save || save_as_draft
    end
  end
end