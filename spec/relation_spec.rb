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

  describe '#selects' do
    it 'returns a new relation' do
      expect(relation.selects(:owner_id).class).to eq (Relation)
    end

    it 'describes columns to select' do
      selected_relation = relation.selects(:owner_id)
      expect(selected_relation.first.owner_id).to eq(1)
      expect(selected_relation.first.name).to be_nil
    end

    it 'does not modify the previous relation when stacked' do
      one_filtered = relation.selects(:owner_id)
      two_filtered = one_filtered.selects(:name)

      expect(one_filtered.first.name).to be_nil
      expect(two_filtered.first.name).to_not be_nil
    end
  end

  describe '#limit' do
    it 'returns a new relation' do
      expect(relation.limit(3).class).to eq (Relation)
    end

    it 'limits the output' do
      selected_relation = relation.limit(3)
      expect(selected_relation.length).to eq(3)
    end

    it 'does not modify the previous relation when stacked' do
      one_filtered = relation.selects(:owner_id)
      two_filtered = one_filtered.limit(3)

      expect(one_filtered.length).to eq(5)
      expect(two_filtered.length).to eq(3)
    end
  end
end
