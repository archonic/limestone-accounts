# Limestone Accounts Demo
[ ![Codeship Status for archonic/limestone-accounts](https://app.codeship.com/projects/eb53d150-02ea-0136-1806-3ebecea35641/status?branch=master)](https://app.codeship.com/projects/280180)

Limestone Accounts is a boilerplate SaaS app built with Rails 5.2 and has an opinionated integration with NPM using [Webpacker](https://github.com/rails/webpacker) and [Stimulus](https://stimulusjs.org/).

Limestone Accounts is multitenant, meaning each account has one subscription and potentially many users through invitations. If you want each user to have their own subscription, try [Limestone](https://github.com/archonic/limestone).

## The Stack
The [gemset](https://github.com/archonic/limestone-accounts/blob/master/Gemfile) has been chosen to be modern, performant, and take care of a number of business concerns common to SaaS.

## Features
* Free trial begins upon registration without credit card.
* Per-seat billing.
* Subscription management. Card update form and cancel account button.
* Emails for welcome, billing updated, invoice paid, invoice failed and trial expiring. All except welcome are controlled by Stripe webhooks.
* Invoice PDF attached to invoice paid email.
* Mail sends through Sidekiq with `deliver_later`. Devise mailing also configured for Sidekiq dispatch.
* Direct uploading to S3 with ActiveStorage. Lazy transform for resizing. Demonstrated with user avatars.
* Icon helper for user avatars with fallback to user initials. Icon helper for font awesome icons.
* Administrate dashboard lets you manage records (ex: accounts, users, invoices). Easy to add more and customize as you like. Visit /admin.
* Impersonate users through administrate dashboard.
* Pretty modals using bootstrap integrated into rails_ujs data-confirm. Demonstrated with cancel account button.
* Persistent banner with link to billing page for accounts that are past due.
* Opinionated search integration using Elasticsearch via Searchkick. Gem is in place but integration is up to you.
* Feature control using the flipper gem. Demonstrated with public_registration.
* Notifications with ActionCable. See console example in app/models/notification.rb.
* 88% RSpec test coverage.

## Roadmap
* In-browser image cropping using jcrop or the likes.
* Custom error pages.

## Notes
* RSpec controller tests have been omitted in favour of requests tests.
* You can run tests locally with `docker-compose run web rspec`
* Because this is a boilerplate, there are no migrations. Rely on schema.rb and use `rails db:setup` to create the db and seed.

## Getting Started
* Install [Docker](https://docs.docker.com/engine/installation/)
* Customize .env from .env-example
* run `docker-compose run webpack yarn install --pure-lockfile` to install all node modules.
* run `docker-compose up --build` to create and run the various images, volumes, containers and a network
* run `docker-compose exec web rails db:setup` to create DB, load schema and seed. Seeding will also create your plan(s) in Stripe.
* Visit lvh.me:3000 and rejoice

### Bonus points
* Login as the admin user that was created (from .env)
* Visit /admin/flipper
* Create the feature `public_registration` and enable it. Now anyone can register :clap:
* You'll probably want to change the `role` enum on the accounts_user model, and the default role in schema.rb.

### Setting up production
A wiki will be written about this. Test edit.
