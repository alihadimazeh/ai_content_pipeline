class AddToneToPipelines < ActiveRecord::Migration[8.1]
  def change
    add_column :pipelines, :tone, :string, default: "professional"
  end
end
