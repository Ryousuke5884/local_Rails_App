class CreateRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end


    #複合キーインデックスをつける。これによりuser.follower_idやuser.followed_idなどの探索が早くなる
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    #unique:trueは同じユーザーを何度もフォローできなくするため。同じ関係性を保存しない
    add_index :relationships, [:follower_id, :followed_id], unique: true

  end
end
