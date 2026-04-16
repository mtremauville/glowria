class AddRuleTypeToConflictRules < ActiveRecord::Migration[8.1]
  def change
    add_column :conflict_rules, :rule_type, :string, default: "conflict", null: false
    ConflictRule.update_all(rule_type: "conflict")
  end
end
