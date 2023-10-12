class AddCountColumnToVoiceActor < ActiveRecord::Migration[7.0]
  def change
    add_column :voice_actors, "count", :bigint, default:0, null: false
  end
end
