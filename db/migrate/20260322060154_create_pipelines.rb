class CreatePipelines < ActiveRecord::Migration[8.1]
  def change
    create_table :pipelines do |t|
      t.references :user, null: false, foreign_key: true
      t.string :topic
      t.jsonb :formats, default: [], null: false
      t.string :status, default: "pending", null: false

      t.timestamps
    end
  end
end
