class CreateExtraVoices < ActiveRecord::Migration[7.0]
  def change
    create_table :extra_voices do |t|
      t.references :voice_actor, null: false, foreign_key: true
      t.string :matching

      t.timestamps
    end
  end
end
