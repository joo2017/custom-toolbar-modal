class CreateLotteryEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :lottery_events do |t|
      t.references :post, null: false, foreign_key: true,
                   index: { unique: true, name: 'index_lottery_events_on_post_id' }
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, default: 'pending', null: false
      t.text :description
      t.integer :max_winners, default: 1
      t.timestamps
    end
    
    # Additional performance indexes for common query patterns
    add_index :lottery_events, [:status, :start_time], 
              name: 'index_lottery_events_status_start_time'
    add_index :lottery_events, [:status, :end_time],
              name: 'index_lottery_events_status_end_time'
  end
end
