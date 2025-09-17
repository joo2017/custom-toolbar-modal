# frozen_string_literal: true

class CreateLotteryEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :lottery_events do |t|
      t.references :post, null: false, foreign_key: true
      t.string :activity_name, null: false, limit: 200
      t.text :prize_description, null: false
      t.string :prize_image_url, limit: 500
      t.datetime :draw_time, null: false
      t.integer :winner_count, null: false
      t.text :specific_floors # 存储指定中奖楼层，逗号分隔
      t.integer :participation_threshold, null: false, default: 1
      t.string :backup_strategy, null: false, default: 'continue' # 'continue' 或 'cancel'
      t.text :additional_notes
      t.string :status, null: false, default: 'pending' # pending, active, drawn, cancelled
      t.timestamps
    end

    add_index :lottery_events, :post_id, unique: true
    add_index :lottery_events, :draw_time
    add_index :lottery_events, :status
    add_index :lottery_events, [:status, :draw_time]
  end
end
