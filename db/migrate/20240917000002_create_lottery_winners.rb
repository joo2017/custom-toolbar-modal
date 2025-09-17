# frozen_string_literal: true

class CreateLotteryWinners < ActiveRecord::Migration[7.0]
  def change
    create_table :lottery_winners do |t|
      # 这行会自动创建 lottery_event_id 并添加索引
      t.references :lottery_event, null: false, foreign_key: true
      
      # 这行会自动创建 user_id 并添加索引
      t.references :user, null: false, foreign_key: true
      
      t.integer :floor_number, null: false
      t.string :win_type, null: false
      t.timestamps
    end

    # 只保留这个复合唯一索引，因为它提供了 t.references 无法自动提供的功能
    add_index :lottery_winners, [:lottery_event_id, :user_id], unique: true
    
    # 下面这两行都因为 t.references 的存在而变得多余，可以删除
    # add_index :lottery_winners, :lottery_event_id
    # add_index :lottery_winners, :user_id
  end
end
