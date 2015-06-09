require 'spec_helper'

describe Relation do
  before(:all) do
    class Cat < SQLObject
      belongs_to :human, foreign_key: :owner_id

      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      has_many :cats, foreign_key: :owner_id
      belongs_to :house

      finalize!
    end

    class House < SQLObject
      has_many :humans

      finalize!
    end
  end

  let(:query_hash) { { select: '*', from: 'cats', where: { id: 1 } } }
  let(:human_relation) { Relation.new('Human') }
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

    it 'can accept array methods with blocks' do
      cat_names = ['Breakfast', 'Earl', 'Haskell', 'Markov', 'Stray Cat']
      expect(relation.map { |cat| cat.name }).to eq(cat_names)
    end

    it 'has elements of the correct type' do
      expect(relation.first).to be_a(SQLObject)
      expect(relation.first.class.name).to eq('Cat')
    end
  end

  describe '#where' do
    it 'returns a new relation' do
      expect(relation.where(id: 1).class).to eq(Relation)
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
      expect(relation.where(cats: { owner_id: 3 }).length).to eq(2)
    end
  end

  describe '#selects' do
    it 'returns a new relation' do
      expect(relation.selects(:owner_id).class).to eq(Relation)
    end

    it 'sets a single column to select' do
      selected_relation = relation.selects(:owner_id)
      expect(selected_relation.first.name).to be_nil
    end

<<<<<<< HEAD
    it 'specifies tables' do
      selected_relation = relations.selects(cats: :owner_id)
      expect(selected_relation.first.owner_id).to eq(1)
      expect(selected_relation.first.name).to be_nil
    end

    it 'specifies multiple columns from a table' do
      selected_relation = relations.selects(cats: [:owner_id, :id])
      expect(selected_relation.first.owner_id).to eq(1)
      expect(selected_relation.first.id).to eq(1)
      expect(selected_relation.first.name).to be_nil
=======
    it 'sets multiple columns to select' do
      selected_relation = relation.selects(:owner_id, :name)
      expect(selected_relation.first.name).to eq('Breakfast')
      expect(selected_relation.first.owner_id).to eq(1)

      expect(selected_relation.first.id).to be_nil
    end

    it 'overwrites previous selections' do
      one_selected = relation.selects(:owner_id)
      two_selected = one_selected.selects(:name)

      expect(one_selected.first.name).to be_nil
      expect(one_selected.first.owner_id).to_not be_nil

      expect(two_selected.first.name).to_not be_nil
      expect(two_selected.first.owner_id).to be_nil
    end

    it 'specifies tables' do
      one_selected = relation.selects(cats: :owner_id)
      expect(one_selected.first.owner_id).to_not be_nil
>>>>>>> 726fb918a76c0523a7e3bc4410e6af7c0d4e11a0
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
      expect(relation.limit(3).class).to eq(Relation)
    end

    it 'limits the output' do
      selected_relation = relation.limit(3)
      expect(selected_relation.length).to eq(3)
    end

    it 'does not modify the previous relation when stacked' do
      one_limited = relation.selects(:owner_id)
      two_limited = one_limited.limit(3)

      expect(one_limited.length).to eq(5)
      expect(two_limited.length).to eq(3)
    end
  end

  describe '#offset' do
    it 'returns a new relation' do
      expect(relation.limit(1).offset(3).class).to eq(Relation)
    end

    it 'skips results' do
      offset_relation = relation.limit(1).offset(3)
      expect(offset_relation.first.id).to eq(4)
    end

    it 'does not modify the previous relation when stacked' do
      one_offset = relation.selects(:owner_id)
      two_offset = one_offset.offset(3).limit(10)

      expect(one_offset.length).to eq(5)
      expect(two_offset.length).to eq(2)
    end
  end

  describe '#joins' do
    it 'returns a new relation' do
      expect(relation.joins(:human).class).to eq(Relation)
    end

    it 'joins a belongs_to association' do
<<<<<<< HEAD
      joins_relation = relation.joins(:human)
      expect(joins_relation.length).to eq(4)
      expect(joins_relation.all? { |cat| !cat.owner_id.nil? }).to be_true
    end

    it 'joins a has_many association' do
      joins_relation = human_relation.joins(:house)
      expect(joins_relation.length).to eq(4)
      expect(joins_relation.all? { |human| !human.house_id.nil? }).to be_true
    end

    it 'joins multiple associations' do
      joins_relation = human_relation
                       .joins(:house, :cat)
                       .selects(house: :address, cat: :name)
      expect(joins_relation)
=======
      cat_joins_human = relation.joins(:human)
      expect(cat_joins_human.length).to eq(4)
      expect(cat_joins_human.all? { |cat| !cat.owner_id.nil? }).to be true
    end

    it 'joins a has_many association' do
      human_joins_house = human_relation.joins(:house)

      expect(human_joins_house.length).to eq(3)
      expect(human_joins_house.all? { |human| !human.house_id.nil? }).to be true
    end

    it 'joins multiple associations' do
      human_joins = human_relation
                    .joins(:house, :cats)
                    .selects(cats: :name, houses: :address)
      p human_joins[0..-1]
>>>>>>> 726fb918a76c0523a7e3bc4410e6af7c0d4e11a0
    end

    it 'joins single-level nested associations' do
      joins_relation = relation.joins(:human)
    end

    it 'joins multiple-level nested associations' do
    end

    it 'can be stacked' do
    end

    it 'does not modify the previous relation when stacked' do
    end
  end
end
