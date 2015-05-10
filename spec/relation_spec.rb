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
    it 'returns a new relation' do
      expect(relation.where(id: 1).class).to eq (Relation)
    end

    it 'filters the results' do
      filtered_relation = relation.where(owner_id: 3)

      expect(filtered_relation.length).to eq(2)
    end

    it 'can be stacked' do
      filtered_relation = relation.where(owner_id: 3)
      filtered_relation = filtered_relation.where(name: 'Breakfast')

      expect(filtered_relation.length).to eq(0)
    end

    it 'does not modify the previous relation when stacked' do
      one_filtered = relation.where(owner_id: 3)
      two_filtered = one_filtered.where(name: 'Breakfast')

      expect(one_filtered.length).to eq(2)
      expect(two_filtered.length).to eq(0)
    end

    it 'lets tables be specified' do
      expect(relation.where(cats: { owner_id: 3}).length).to eq(2)
    end
  end
end
