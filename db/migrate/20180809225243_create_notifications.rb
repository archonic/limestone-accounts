class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.string :action
      t.references :notifiable, polymorphic: true
      t.string :target_name_cached
      t.json :target_path_params
      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
