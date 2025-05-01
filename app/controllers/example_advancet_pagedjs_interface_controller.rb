class ExampleAdvancetPagedjsInterfaceController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf { render pdf: "example_pagedjs_interface" }
    end
  end
end
