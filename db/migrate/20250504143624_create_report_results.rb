class CreateReportResults < ActiveRecord::Migration[8.0]
  def change
    create_table :report_results do |t|
      t.string :report_id
      t.integer :lock_version

      t.timestamps
    end
    add_index :report_results, :report_id, unique: true
  end
end
