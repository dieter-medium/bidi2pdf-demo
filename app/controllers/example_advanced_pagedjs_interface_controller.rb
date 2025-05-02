class ExampleAdvancedPagedjsInterfaceController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf {
        @in_pdf = true
        render pdf: "example_pagedjs_interface"
      }
    end
  end
end
