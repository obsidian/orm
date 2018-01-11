require "./spec_helper"

module ORMSpecs

  model User do
    schema do
      primary_key id : Int32
      field first_name : String
      field last_name : String

      has_many posts : Post, through: postings : Posting
    end
  end

  describe Orm do
    # TODO: Write tests

    it "works" do
      false.should eq(true)
    end
  end

end
