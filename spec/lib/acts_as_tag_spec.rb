require 'spec_helper'

describe ActsAsTag do
  before(:all) do
    build_model :category do
      string :name
      acts_as_tag :name
    end

    build_model :item do
      string :name
      attr_accessible :name
      is_taggable_with :categories
    end

    build_model :categories_items do
      integer :item_id
      integer :category_id
    end
  end

  describe :acts_as_tag? do
    context 'model not acting as tag' do
      it 'should not be available' do
        expect(Item).to_not respond_to(:acts_as_tag?)
      end
    end

    context 'model acting as tag' do
      it 'should be true' do
        expect(Category.acts_as_tag?).to be_true
      end
    end
  end

  describe :from_s do
    context 'with a clean database' do
      it 'should be a collection of fresh records' do
        categories = Category.from_s('JavaScript, CSS, Ruby')
        expect(categories).to have(3).items
        expect(categories).to be_all(&:new_record?)
        expect(categories).to be_all { |c| c.is_a?(Category) }
      end

      it 'should be without duplicates and blanks' do
        categories = Category.from_s('JavaScript,  CSS  ,  CsS, CSS ,css,,  ,')
        expect(categories.map(&:name)).to match_array(['JavaScript', 'CSS'])
      end
    end

    context 'with some records in the database' do
      before(:all) do
        ['JavaScript', 'CSS', 'Ruby'].each do |category|
          Category.create!(name: category)
        end
      end

      after(:all) do
        Category.destroy_all
      end

      it 'should find existing records' do
        categories = Category.from_s('JavaScript, css  , rUBY ')
        expect(categories).to_not be_any(&:new_record?)
      end

      it 'should find existing and build new ones' do
        categories = Category.from_s('javascript ,Perl')
        expect(categories).to be_any(&:new_record?)
        expect(categories).to_not be_all(&:new_record?)
        expect(categories.map(&:name)).to match_array(['JavaScript', 'Perl'])
      end
    end
  end

  describe :to_s do
    it 'should be the name' do
      s = Category.new(name: 'Python').to_s
      expect(s).to eq('Python')
    end
  end

  describe :is_taggable_with do
    it 'should set up a has_and_belongs_to_many association' do
      reflection = Item.reflect_on_association(:categories)
      expect(reflection).to_not be_nil
      expect(reflection.macro).to eq(:has_and_belongs_to_many)
    end
  end

  describe :tags= do
    it 'should set the tags from a string' do
      item = Item.new(name: 'Example')
      item.categories = 'JavaScript, CSS, Ruby'
      expect(item.categories).to have(3).items
      expect(item.categories).to be_all { |c| c.is_a?(Category) }
    end

    it 'should be available for mass assignment' do
      item = Item.new(name: 'something', categories: 'Java, CSS, Perl, Ruby')
      expect(item.categories).to have(4).items
    end
  end
end
