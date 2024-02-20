class CreateCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :external_id
      t.string :public_key
      t.string :nickname

      t.timestamps
    end
  end
end
