class ExampleBookSpreadController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf { render pdf: "example_book_spread" }
    end
  end
end
