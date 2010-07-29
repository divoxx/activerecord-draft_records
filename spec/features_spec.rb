require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Integration features" do
  it "should save the record as draft and skip validation" do
    user = User.new :email => 'joe@example.com'
    user.should_not be_valid
    user.save_as_draft
    user.should be_a_draft
  end
  
  it "should allow trying to save the object and saving as a draft if it fails" do
    user = User.new :email => 'joe@example.com'
    user.should_not be_valid
    user.save_or_draft
    user.should be_a_draft
  end
  
  it "should not save the record as draft if validations pass when calling save_or_draft" do
    user = User.new :email => 'joe@example.com', :username => 'joe'
    user.should be_valid
    user.save_or_draft
    user.should_not be_a_draft
  end
  
  it "should create a record as draft and skip validations" do
    user = User.create_as_draft :email => 'joe@example.com'
    user.should be_instance_of(User)
    user.should_not be_a_new_record
    user.should be_a_draft
  end

  it "should allow trying to create a record and saving as a draft if it fails" do
    user = User.create_or_draft :email => 'joe@example.com'
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
  
  it "should save a record and attempt to transform into a non-draft" do
    user = User.create_as_draft :email => 'joe@example.com'
    user.username = 'joe'
    user.save_and_attempt_to_undraft.should be(true)
    user.should_not be_draft
    user.should_not be_changed
  end

  it "should save a record and attempt to transform into a non-draft but fail if validation fails" do
    user = User.create_as_draft :email => 'joe@example.com'
    user.age = 18
    user.save_and_attempt_to_undraft.should be(true)
    user.should be_draft
    user.should_not be_changed
    user.age.should == 18
  end
  
  it "should not transform a normal record in draft when calling save_and_attempt_to_undraft" do
    user = User.create :email => 'joe@example.com', :username => 'joe'
    user.username = nil
    user.save_and_attempt_to_undraft.should be(false)
    user.should_not be_draft
    user.should be_changed
  end
  
  it "should validate object as not draft" do
    User.create :email => 'joe@example.com', :username => 'joe'
    user = User.new :username => 'joe'
    user.save_as_draft.should be_true
    user.should_not be_valid
    user.errors.on(:username).should_not be_blank
    user.errors.on(:username).should include("has already been taken")
  end
end
