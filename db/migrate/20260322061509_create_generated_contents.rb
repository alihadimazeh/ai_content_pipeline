class CreateGeneratedContents < ActiveRecord::Migration[8.1]
  def change
    create_table :generated_contents do |t|
      t.references :pipeline, null: false, foreign_key: true
      t.string :format, null: false
      t.text :body
      t.integer :version, default: 1, null: false
      t.string :status, default: "pending", null: false

      t.timestamps
    end
  end
end
