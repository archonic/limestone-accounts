# Limestone Accounts

Limestone is a boilerplate SaaS app built with Rails 5.2 and has an opinionated integration with NPM using [Webpacker](https://github.com/rails/webpacker). The opinions of this boilerplate stop short of choosing a front-end framework like [React](https://facebook.github.io/react/) or [Vue](https://vuejs.org/), so you can use what you like. This is a work in progress.

Limestone Accounts is multitenant, meaning each account has one subscription and potentially many users. If you want each user to have their own subscription, try [Limestone](https://github.com/archonic/limestone).

## The Stack
The gemset has been chosen to be modern, performant, and take care of a number of business concerns common to SaaS.
* Administrate
* Apartment
* Bootstrap 4
* CoffeeScript
* Devise
* Discard
* Flipper
* HAML
* jQuery
* Postgres
* Pretender
* Pundit
* Rspec (w/ shoulda_matchers, database_cleaner)
* Rolify
* Searchkick
* Shrine
* Sidekiq
* Simple Form
* Stripe (w/ stripe-ruby-mock, stripe_event)
* Turbolinks 5

## Features
* Free trial begins upon registration without credit card.
* Subscription management. Card update form and cancel account button.
* Emails for welcome, billing updated, invoice paid, invoice failed and trial expiring. All except welcome are controlled by Stripe webhooks.
* Invoice PDF attached to invoice paid email.
* Mail sends through Sidekiq with `deliver_later`. Devise mailing also configured for Sidekiq dispatch.
* Direct uploading to S3 with ActiveStorage. Lazy transform for resizing. Demonstrated with user avatars.
* Icon helper for user avatars with fallback to circle with user initials. Icon helper for font awesome icons.
* Administrate dashboard lets you CRUD records (ex: users). Easy to add more and customize as you like. Visit /admin/.
* Impersonate users through administrate dashboard.
* Pretty modals using bootstrap integrated into rails_ujs data-confirm. Demonstrated with cancel account button.
* Banner with a link to billing page for accounts that are past due.
* Opinionated search integration using Elasticsearch via Searchkick. Gem is in place but integration is up to you.
* Feature control using the flipper gem. Demonstrated with public_registration.
* 86% RSpec test coverage.

## Roadmap
* In-browser image cropping using jcrop or the likes.
* Custom error pages.
* Per-seat billing.
* Comprehensive permissions groups and resource access management.

## Notes
* RSpec controller tests have been omitted in favour of requests tests.
* You can run tests locally with `docker-compose run website rspec`
* Because this is a boilerplate, there are no migrations. Rely on schema.rb and use `rails db:setup` to create the db and seed.

## Getting Started
* Install [Docker](https://docs.docker.com/engine/installation/)
* Customize .env from .env-example
* run `docker-compose run webpacker yarn install --pure-lockfile` to install all node modules. See issue #3 about this.
* run `docker-compose up --build` to create and run the various images, volumes, containers and a network
* run `docker-compose exec website rails db:setup` to create DB, load schema and seed. Seeding will also create your plan(s) in Stripe.
* Visit localhost:3000 and rejoice

### Bonus points
* Login as the admin user that was created (from .env)
* Visit /admin/flipper
* Create the feature `public_registration` and enable it. Now anyone can register :clap:

### Setting up production
A wiki will be written about this.
