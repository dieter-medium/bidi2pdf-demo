# frozen_string_literal: true

class ExampleRoutesController < ApplicationController
  def index
    @examples = [
      {
        title: 'Book Spread Example (Paged.js)',
        controller: 'ExampleBookSpreadController',
        action: 'show',
        description: 'This page demonstrates a Paged.js book spread example, inspired by',
        repo_url: 'https://gitlab.coko.foundation/pagedjs/starter-kits/book-spread_esm',
        repo_text: 'pagedjs/starter-kits/book-spread_esm',
        url: example_book_spread_url,
        pdf_url: example_book_spread_url(format: :pdf)
      },
      {
        title: 'Book Template Interface (Paged.js)',
        controller: 'ExampleAdvancetPagedjsInterfaceController',
        action: 'show',
        description: 'This page demonstrates a Paged.js book template with interface example, inspired by',
        repo_url: 'https://gitlab.coko.foundation/pagedjs/starter-kits/book_avanced-interface',
        repo_text: 'pagedjs/starter-kits/book_avanced-interface',
        url: example_advancet_pagedjs_interface_url,
        pdf_url: example_advancet_pagedjs_interface_url(format: :pdf)
      }
    ]
  end
end
