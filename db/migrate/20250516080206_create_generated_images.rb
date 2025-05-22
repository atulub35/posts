class CreateGeneratedImages < ActiveRecord::Migration[7.0]
  def change
    create_table :generated_images do |t|
      t.text :prompt
      t.references :user, null: false, foreign_key: true
      t.string :original_url
      t.string :style
      t.boolean :is_variant, default: false

      t.timestamps
    end
  end
end
