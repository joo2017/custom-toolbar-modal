# frozen_string_literal: true

class CreateLotteryWinners < ActiveRecord::Migration[7.0]
  def change
    create_table :lottery_winners do |t|
      t.references :lottery_event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :floor_number, null: false # 中奖楼层
      t.string :win_type, null: false # 'random' 或 'specific'
      t.timestamps
    end

    add_index :lottery_winners, [:lottery_event_id, :user_id], unique: true
  #  add_index :lottery_winners, :lottery_event_id
  #  add_index :lottery_winners, :user_id
  end
end
