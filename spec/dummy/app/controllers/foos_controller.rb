class FoosController < ActionController::Base

  def create
    Foo.create(name: params["name"],value: 0)
  end

  def update
    Foo.find(params["id"]).update(name: params["name"],value: params["value"])
  end

  def two_in_one
    Doo.create(name: "doo dummy", value: 2)
    Foo.first.update(name: "Dummy nameee",value: 4)
  end

end