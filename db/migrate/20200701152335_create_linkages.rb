class CreateLinkages < ActiveRecord::Migration[6.0]
  def change
    create_table :linkages do |t|
      t.string :token

      t.timestamps
    end
  end
end
