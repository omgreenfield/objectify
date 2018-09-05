require 'spec_helper'
require 'objectify'

describe Objectify do
  context 'when including the module' do
    class ObjectifyTest
      include Objectify
    end

    it 'should include the .object method' do
      expect(ObjectifyTest).to respond_to(:object)
    end

    context 'when calling .object' do
      before(:all) { ObjectifyTest.object :thing, attrs: [:name] }

      it 'should create a new class' do
        expect(ObjectifyTest.const_defined?('Thing')).to be true
      end

      it 'should register the collection' do
        expect(Objectify::things).to eq([])
      end

      context 'when calling the newly created .thing method' do
        subject { ObjectifyTest.thing name: 'test name' }

        it { should be_a ObjectifyTest::Thing }

        it 'should get attributes assigned' do
          expect(subject.name).to eq('test name')
        end

        it 'should be added to the registered collection' do
          expect(Objectify::things).to include(subject)
        end
      end
    end
  end
end
