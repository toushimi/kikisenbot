class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.bigint :discord_user_id
      t.references :voice_actor

      t.timestamps
    end
  end
end
