require 'relation'
require 'sql_object'

describe Relation do
  before(:all) do
    class Cat < SQLObject
      finalize!
    end
  end

  let(:query_hash) { { select: '*', from: 'cats', where: { id: 1 } } }
  subject(:relation) { Relation.new('Cat') }

  describe '::new' do
    it 'takes a class name' do
      expect(relation.class).to eq(Relation)
    end

    it 'optionally takes a query' do
      expect(Relation.new('Cat', query_hash).class).to eq(Relation)
    end

    it 'returns a relation' do
      expect(relation.class).to eq(Relation)
    end

    it 'can accept array methods' do
      expect(relation.length).to eq(5)
    end

    it 'has elements of the correct type' do
      expect(relation.first).to be_a(SQLObject)
      expect(relation.first.class.name).to eq('Cat')
    end
  end

  describe '#where' do
  end
end
