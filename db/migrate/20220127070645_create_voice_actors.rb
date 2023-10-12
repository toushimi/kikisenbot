class CreateVoiceActors < ActiveRecord::Migration[7.0]
  def change
    create_table :voice_actors do |t|
      t.string :name
      t.string :actor_type
      t.string :url
      t.string :uuid

      t.timestamps
    end
  end
end
