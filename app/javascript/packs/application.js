/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'jquery'
window.$ = window.jQuery = require('jquery');

import 'bootstrap'

import Rails from 'rails-ujs';
Rails.start();
window.Rails = Rails;
import Turbolinks from 'turbolinks';
window.Turbolinks = Turbolinks;
Turbolinks.start();

import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))

import * as ActiveStorage from "activestorage"
ActiveStorage.start()

// Does not process requires when imported like this
import '../packs/src/subscriptions'
import '../packs/src/modals'
import '../packs/src/global'
console.log('Hello World from Webpacker')
