require 'spec_helper'

module MongoModel
  describe MongoOptions do
    define_class(:TestDocument, Document)
    
    shared_examples_for "options without conditions" do
      it "should have an empty selector hash" do
        subject.selector.should == {}
      end
    end
    
    shared_examples_for "options with conditions only" do
      it "should have an empty options hash" do
        subject.options.should == {}
      end
    end
    
    context "with blank options" do
      subject { MongoOptions.new(TestDocument) }
      
      it_should_behave_like "options without conditions"
      
      it "should have an empty options hash" do
        subject.options.should == {}
      end
    end
    
    context "with basic conditions" do
      subject { MongoOptions.new(TestDocument, :conditions => { :foo => 'bar' }) }
      
      it_should_behave_like "options with conditions only"
      
      it "should include the conditions in the selector" do
        subject.selector.should == { :foo => 'bar' }
      end
    end
    
    context "with conditions using an operator" do
      subject { MongoOptions.new(TestDocument, :conditions => { :age.gt => 10 }) }
      
      it_should_behave_like "options with conditions only"
      
      it "should include the expanded conditions in the selector" do
        subject.selector.should == { :age => { '$gt' => 10 } }
      end
    end
    
    context "with conditions using a property" do
      subject { MongoOptions.new(TestDocument, :conditions => { :id => '123' }) }
      
      it_should_behave_like "options with conditions only"
      
      it "should use the property as value in the selector" do
        subject.selector.should == { '_id' => '123' }
      end
    end
    
    context "with basic options (no conditions or order)" do
      subject { MongoOptions.new(TestDocument, :offset => 20, :limit => 10, :select => [ :foo, :bar ]) }
      
      it_should_behave_like "options without conditions"
      
      it "should include converted options in options hash" do
        subject.options.should == { :skip => 20, :limit => 10, :fields => [ :foo, :bar ]}
      end
    end
    
    context "with string order" do
      subject { MongoOptions.new(TestDocument, :order => 'foo DESC') }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['foo', :descending] ] }
      end
    end
    
    context "with symbol order" do
      subject { MongoOptions.new(TestDocument, :order => :bar) }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['bar', :ascending] ]}
      end
    end
    
    context "with symbol(asc) order" do
      subject { MongoOptions.new(TestDocument, :order => :bar.asc) }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['bar', :ascending] ]}
      end
    end
    
    context "with multiple orders in array" do
      subject { MongoOptions.new(TestDocument, :order => ['foo ASC', :bar.desc]) }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['foo', :ascending], ['bar', :descending]] }
      end
    end
    
    context "with multiple orders in string" do
      subject { MongoOptions.new(TestDocument, :order => 'foo DESC, baz') }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['foo', :descending], ['baz', :ascending] ] }
      end
    end
    
    context "with an order using a property" do
      subject { MongoOptions.new(TestDocument, :order => :id.desc) }
      
      it_should_behave_like "options without conditions"
      
      it "should use property as value as sort column" do
        subject.options.should == { :sort => [ ['_id', :descending] ] }
      end
    end
    
    context "with conditions and options" do
      subject { MongoOptions.new(TestDocument, :conditions => { :age => 18 }, :order => :id.desc, :limit => 5) }
      
      it "should use conditions for selector" do
        subject.selector.should == { :age => 18 }
      end
      
      it "should convert options" do
        subject.options.should == { :sort => [ ['_id', :descending] ], :limit => 5 }
      end
      
      it "should convert to array" do
        subject.to_a.should == [ subject.selector, subject.options ]
      end
    end
  end
  
  describe MongoOperator do
    subject { MongoOperator.new(:age, :gt) }
    
    it "should convert to mongo selector" do
      subject.to_mongo_selector(14).should == { '$gt' => 14 }
    end
    
    it "should be equal to a MongoOperator with the same field and operator" do
      subject.should == MongoOperator.new(:age, :gt)
    end
    
    it "should not be equal to a MongoOperator with a different field/operator" do
      subject.should_not == MongoOperator.new(:age, :lte)
      subject.should_not == MongoOperator.new(:date, :gt)
    end
    
    it "should be created from symbol methods" do
      :age.gt.should == MongoOperator.new(:age, :gt)
      :date.lte.should == MongoOperator.new(:date, :lte)
    end
    
    it "should be equal within a hash" do
      { :age.gt => 10 }.should == { :age.gt => 10 }
    end
  end
end