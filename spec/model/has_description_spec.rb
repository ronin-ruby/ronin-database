require 'spec_helper'
require 'model/models/described_model'

require 'ronin/model/has_description'

describe Model::HasDescription do
  let(:model) { DescribedModel }

  before(:all) { DescribedModel.auto_migrate! }

  describe ".included" do
    subject { model }

    it "should include Ronin::Model" do
      expect(subject.ancestors).to include(Model)
    end

    it "should define a description property" do
      expect(subject.properties).to be_named(:description)
    end
  end

  describe ".describing" do
    subject { model }

    let(:description1) { 'foo one' }
    let(:description2) { 'foo bar two' }

    before do
      subject.create!(description: description1)
      subject.create!(description: description2)
    end

    it "should be able to find resources with similar descriptions" do
      resources = subject.describing('foo')

      expect(resources.length).to be(2)
      expect(resources[0].description).to be == description1
      expect(resources[1].description).to be == description2
    end

    after { subject.destroy }
  end
end
