require 'spec_helper'

describe GraphQL::InterfaceType do
  let(:interface) { EdibleInterface }
  it 'has possible types' do
    assert_equal([CheeseType, MilkType], interface.possible_types)
  end

  it 'resolves types for objects' do
    assert_equal(CheeseType, interface.resolve_type(CHEESES.values.first))
    assert_equal(MilkType, interface.resolve_type(MILKS.values.first))
  end

  it 'handles when interfaces are re-assigned' do
    iface = GraphQL::InterfaceType.define do
    end
    type = GraphQL::ObjectType.define do
      interfaces [iface]
    end
    assert_equal([type], iface.possible_types)

    type.interfaces = []
    assert_equal([], iface.possible_types)

    type.interfaces = [iface]
    assert_equal([type], iface.possible_types)

    type.interfaces = [iface]
    assert_equal([type], iface.possible_types)
  end

  describe 'query evaluation' do
    let(:result) { DummySchema.execute(query_string, context: {}, variables: {"cheeseId" => 2})}
    let(:query_string) {%|
      query fav {
        favoriteEdible { fatContent }
      }
    |}
    it 'gets fields from the type for the given object' do
      expected = {"data"=>{"favoriteEdible"=>{"fatContent"=>0.04}}}
      assert_equal(expected, result)
    end
  end

  describe 'mergable query evaluation' do
    let(:result) { DummySchema.execute(query_string, context: {}, variables: {"cheeseId" => 2})}
    let(:query_string) {%|
      query fav {
        favoriteEdible { fatContent }
        favoriteEdible { origin }
      }
    |}
    it 'gets fields from the type for the given object' do
      expected = {"data"=>{"favoriteEdible"=>{"fatContent"=>0.04, "origin"=>"Antiquity"}}}
      assert_equal(expected, result)
    end
  end

  describe '#resolve_type' do
    let(:interface) {
      GraphQL::InterfaceType.define do
        resolve_type -> (object) {
          :custom_resolve
        }
      end
    }

    it 'can be overriden in the definition' do
      assert_equal(interface.resolve_type(123), :custom_resolve)
    end
  end
end
