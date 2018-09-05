require 'objectify'

module Thing
  include Objectify

  # creates a new class Thing with attributes :title, and :text
  object :thing, attrs: [:title, :text]

  # creates instances of that new class
  thing title: 'Title1', text: 'Text1'
  thing title: 'Title2', text: 'Text2'
  thing title: 'Title3', text: 'Text3'

  # the collection is also registered on the Objectify module
  def self.get_thing(index)
    Objectify::things[index]
  end
end
