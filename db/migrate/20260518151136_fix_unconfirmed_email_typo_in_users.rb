class FixUnconfirmedEmailTypoInUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :uncomfirmed_email, :unconfirmed_email
  end
end
