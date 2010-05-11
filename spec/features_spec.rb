require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Integration features" do
  it "should save the record as draft and skip validation" do
    user = User.new :email => 'joe@example.com'
    user.should_not be_valid
    user.save_as_draft
    user.should be_a_draft
  end
  
  it "should create a record as draft and skip validations" do
    user = User.create_as_draft :email => 'joe@example.com'
    user.should be_instance_of(User)
    user.should_not be_a_new_record
    user.should be_a_draft
  end

  it "should not return draft records on queries" do
    user = User.create_as_draft :email => 'joe@example.com'
    User.all.should_not include(user)
  end
  
  it "should provide a version of ActiveRecord::Base#find that will look for drafts" do
    user = User.create_as_draft :email => 'joe@example.com'
    User.find_drafts(:all).should include(user)
  end
end
