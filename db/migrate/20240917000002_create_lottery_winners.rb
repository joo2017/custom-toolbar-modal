class CreateLotteryWinners < ActiveRecord::Migration[6.1]
  def change
    create_table :lottery_winners do |t|
      t.references :lottery_event, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.string :status, default: 'pending', null: false
      t.datetime :selected_at
      t.timestamps
    end
    
    # Prevent duplicate entries per user per lottery event
    add_index :lottery_winners, [:lottery_event_id, :user_id], 
              unique: true, name: 'index_lottery_winners_event_user_unique'
    
    # Performance index for user-centric queries
    add_index :lottery_winners, [:status, :selected_at],
              name: 'index_lottery_winners_status_selected_at'
  end
end
