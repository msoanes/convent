require '01_sql_object'

describe 'Relation' do
  before(:each) do
    class Cat < SQLObject
      self.finalize!
    end
  end

  let(:query_hash) { {select: '*', from: 'cats', where: { id: 1 } } }

  describe '::new' do
    it 'takes a class name' do
      expect(Relation.new('Cat').class).to eq(Relation)
    end

    it 'optionally takes a query' do
      expect(Relation.new('Cat', query_hash).class).to eq(Relation)
    end
  end

  describe '#where' do
    it 'returns a new relation' do
      expect(Relation.new('Cat').where(id: 1).class).to eq(Relation)
    end

    it 'updates the query_hash' do
      old_relation = Relation.new('Cat')
      old_query_hash = old_relation.send(:instance_variable_get, '@query_hash')
      new_relation = old_relation.where(id: 1)
      new_query_hash = new_relation.send(:instance_variable_get, '@query_hash')

      expect(old_query_hash).to eq({select: '*', from: 'cats'})
      expect(new_query_hash).to eq(query_hash)
    end

    it 'filters results' do
      old_relation = Relation.new('Cat')
      new_relation = old_relation.where(id: 1)

      expect(old_relation.length).to eq(5)
      expect(new_relation.length).to eq(1)
      expect(new_relation.first.name).to eq('Breakfast')
    end

    it 'filters results when chained' do
      relation = Relation.new('Cat').where(owner_id: 3).where(name: 'Markov')
      expect(relation.count).to eq(1)
    end
  end

  describe '#limit' do
    it 'limits the result set' do
      relation = Relation.new('Cat').limit(2)
      expect(relation[0..-1].count).to eq(2)
      expect(relation[2]).to be_nil 
    end
  end
end
