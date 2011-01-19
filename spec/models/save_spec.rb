require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe DelegatesAttributesTo, 'with dirty delegations' do

  [false, true].each do |bool|
    ActiveRecord::Base.partial_updates = bool

    describe "partial update (#{bool}) " do
      before :each do
        @user = UserWithFirstnameValidation.create! :firstname => "Bob"
        @id = @user.id
        @user = UserWithFirstnameValidation.find(@id)
      end

      describe "#save" do

        it "should save delegated attributes" do
          @user.lastname = "Marley"
          @user.save.should be_true
          @user = UserWithFirstnameValidation.find(@id)
          @user.firstname.should == "Bob"
          @user.lastname.should  == "Marley"
        end

        it "should save with invalid association" do
          @user.lastname = "Marley"
          @user.contact.stub(:valid?).and_return(false)
          @user.save.should be_true
          @user.reload.lastname.should == "Marley"
        end

        it "should NOT save with blank firstname" do
          @user.firstname = ""
          @user.save.should be_false
          @user.errors[:firstname].should == "can't be blank"
        end
      end



      describe "#save(false)" do

        it "should save delegated attributes" do
          @user.lastname = "Marley"
          @user.save(false).should be_true
          @user = UserWithFirstnameValidation.find(@id)
          @user.firstname.should == "Bob"
          @user.lastname.should  == "Marley"
        end

        it "should save with invalid association" do
          @user.contact.stub(:valid?).and_return(false)
          @user.save(false).should be_true
        end

        it "should save with blank firstname" do
          @user.firstname = ""
          @user.save(false).should be_true
          @user = UserWithFirstnameValidation.find(@id)
          @user.firstname.should be_blank
        end
      end



      describe "#save!" do

        it "should save delegated attributes" do
          @user.lastname = "Marley"
          @user.save!
          @user = UserWithFirstnameValidation.find(@id)
          @user.firstname.should == "Bob"
          @user.lastname.should  == "Marley"
        end

        it "should save with invalid association" do
          @user.lastname = "Marley"
          @user.contact.stub(:valid?).and_return(false)
          @user.save!.should be_true
          @user.reload.lastname.should == "Marley"
        end

        it "should raise ActiveRecord::RecordInvalid error with blank firstname" do
          @user.firstname = ""
          lambda { @user.save! }.should raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
