module Types
  class MutationType < BaseObject
    field :add_item, mutation: Mutations::AddItem
    field :update_item, mutation: Mutations::UpdateItem
    field :remove_item, mutation: Mutations::RemoveItem
  end
end
