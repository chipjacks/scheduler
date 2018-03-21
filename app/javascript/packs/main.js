// Run this example by adding <%= javascript_pack_tag "main" %> to the
// head of your layout file, like app/views/layouts/application.html.erb.

import Elm from '../Main'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-container')

  Elm.Main.embed(target)
})
