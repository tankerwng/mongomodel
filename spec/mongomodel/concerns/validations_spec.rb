require 'spec_helper'

module MongoModel
  module ValidationHelpers
    def clear_validations! 
      reset_callbacks(:validate)
    end
  end
  
  specs_for(Document, EmbeddedDocument) do
    describe "validations" do
      define_class(:TestDocument, described_class) do
        property :title, String
        validates_presence_of :title
        
        extend MongoModel::ValidationHelpers
      end
      
      if specing?(EmbeddedDocument)
        define_class(:ParentDocument, Document) do
          property :child, TestDocument
        end
        
        let(:child) { TestDocument.new }
        let(:parent) { ParentDocument.new(:child => child) }
        let(:doc) { parent }
        
        subject { parent.child }
      else
        let(:doc) { TestDocument.new }
        
        subject { doc }
      end
      
      it "should have an errors collection" do
        subject.errors.should be_an_instance_of(ActiveModel::Errors)
      end
      
      context "when validations are not met" do
        before(:each) { subject.valid? }
        
        it { should_not be_valid }
        it { should have(1).error }
      end
      
      describe "validation on create" do
        before(:each) do
          TestDocument.clear_validations!
          TestDocument.validates_presence_of :title, :on => :create
        end
        
        context "new document" do
          it { should_not be_valid }
        end
        
        context "existing document" do
          before(:each) do
            subject.title = 'Valid title'
            doc.save!
            subject.title = nil
          end
          
          it { should be_valid }
        end
      end
      
      describe "validation on update" do
        before(:each) do
          TestDocument.clear_validations!
          TestDocument.validates_presence_of :title, :on => :update
        end
        
        context "new document" do
          it { should be_valid }
        end
      
        context "existing document" do
          before(:each) do
            subject.title = 'Valid title'
            doc.save!
            subject.title = nil
          end
        
          it { should_not be_valid }
        end
      end
    end
  end
  
  specs_for(EmbeddedDocument) do
    describe "validations" do
      define_class(:ChildDocument, EmbeddedDocument) do
        property :title, String
        validates_presence_of :title
      
        extend MongoModel::ValidationHelpers
      end
    
      define_class(:ParentDocument, Document) do
        property :child, ChildDocument
      end
      
      let(:child) { ChildDocument.new }
      let(:parent) { ParentDocument.new(:child => child) }
    
      subject { parent.child }
    
      context "child document is invalid" do
        before(:each) { parent.valid? }
        
        specify "parent should be invalid" do
          parent.should_not be_valid
        end
        
        specify "parent should have error on child" do
          parent.should have(1).error
          parent.errors[:child].should_not be_nil
        end
        
        specify "child should be invalid" do
          child.should_not be_valid
        end
        
        specify "child should have error" do
          child.errors[:title].should_not be_nil
        end
      end
      
      context "parent has no child" do
        before(:each) do
          parent.child = nil
          parent.valid?
        end
        
        specify "parent should be valid" do
          parent.should be_valid
        end
      end
    end
  end
end