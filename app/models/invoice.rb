# TODO This is formatting data for presentation in the model and violating MVC
# Ditch the reciepts gem and just do a pdf view
class Invoice < ApplicationRecord
  include CurrencyHelper
  belongs_to :account
  serialize :lines, JSON

  def receipt
    Receipts::Receipt.new(
      id: id,
      product: "Limestone",
      company: {
        name: "Limestone Inc.",
        address: "123 Example St\nSuite 42\nNew York City, NY 10012",
        email: "support@example.com",
        logo: Rails.root.join("app/assets/images/logo.png")
      },
      line_items: [
        ["Date",           formatted_invoice_date],
        ["Account Owner", "#{account.owner_au.try(:full_name)} (#{account.owner_au.try(:email)})"],
        ["Product",        "Example Product"],
        ["Amount",         formatted_amount(amount, currency)],
        ["Charged to",     formatted_card]
      ]
    )
  end

  # This assumes that the card charged is the one currently on file
  # That will always be the case unless the account manages to change their card
  # and get invoiced before the stripe webhook updates their account (super unlikely).
  def formatted_card
    "#{account.card_type} (**** **** **** #{account.card_last4})"
  end

  def cost
    formatted_amount(amount, currency)
  end

  def formatted_invoice_date
    paid_at.strftime('%l:%M %P, %B %d, %Y') << " UTC"
  end
end
