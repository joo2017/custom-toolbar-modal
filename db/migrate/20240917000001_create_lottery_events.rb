# frozen_string_literal: true

class CreateLotteryEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :lottery_events do |t|
      # 修改下面这行，直接在创建时就指定我们想要的 unique index
      t.references :post, null: false, foreign_key: true, index: { unique: true, name: 'index_lottery_events_on_post_id' }

      t.string :activity_name, null: false, limit: 200
      t.text :prize_description, null: false
      t.string :prize_image_url, limit: 500
      t.datetime :draw_time, null: false
      t.integer :winner_count, null: false
      t.text :specific_floors
      t.integer :participation_threshold, null: false, default: 1
      t.string :backup_strategy, null: false, default: 'continue'
      t.text :additional_notes
      t.string :status, null: false, default: 'pending'
      t.timestamps
    end

    # 不再需要单独添加 post_id 的索引，因为它已经在上面创建好了
    # add_index :lottery_events, :post_id, unique: true  <- 我们删除了这一行

    # 其他索引保持不变
    add_index :lottery_events, :draw_time
    add_index :lottery_events, :status
    add_index :lottery_events, [:status, :draw_time]
  end
end
